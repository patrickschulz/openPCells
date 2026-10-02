#include "gdsparser.h"

#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <string.h>
#include <assert.h>

#include "lua/lauxlib.h"

#include "_modulemanager.h"

#include "filesystem.h"
#include "hashmap.h"
#include "helpers.h"
#include "lua_util.h"
#include "math.h"
#include "point.h"
#include "util.h"
#include "vector.h"

#include "timeperf.h"

enum datatypes {
    NONE                = 0x00,
    BIT_ARRAY           = 0x01,
    TWO_BYTE_INTEGER    = 0x02,
    FOUR_BYTE_INTEGER   = 0x03,
    FOUR_BYTE_REAL      = 0x04,
    EIGHT_BYTE_REAL     = 0x05,
    ASCII_STRING        = 0x06
};

enum recordtypes {
    HEADER, BGNLIB, LIBNAME, UNITS, ENDLIB, BGNSTR, STRNAME, ENDSTR, BOUNDARY, PATH, SREF, AREF, TEXT, LAYER, DATATYPE, WIDTH, XY, ENDEL, SNAME,
    COLROW, TEXTNODE, NODE, TEXTTYPE, PRESENTATION, SPACING, STRING, STRANS, MAG, ANGLE, UINTEGER, USTRING, REFLIBS, FONTS, PATHTYPE, GENERATIONS,
    ATTRTABLE, STYPTABLE, STRTYPE, ELFLAGS, ELKEY, LINKTYPE, LINKKEYS, NODETYPE, PROPATTR, PROPVALUE, BOX, BOXTYPE, PLEX, BGNEXTN, ENDEXTN,
    TAPENUM, TAPECODE, STRCLASS, RESERVED, FORMAT, MASK, ENDMASKS, LIBDIRSIZE, SRFNAME, LIBSECUR
};

const char* recordnames[] = {
    "HEADER", "BGNLIB", "LIBNAME", "UNITS", "ENDLIB", "BGNSTR", "STRNAME", "ENDSTR", "BOUNDARY", "PATH", "SREF", "AREF", "TEXT", "LAYER",
    "DATATYPE", "WIDTH", "XY", "ENDEL", "SNAME", "COLROW", "TEXTNODE", "NODE", "TEXTTYPE", "PRESENTATION", "SPACING", "STRING", "STRANS", "MAG",
    "ANGLE", "UINTEGER", "USTRING", "REFLIBS", "FONTS", "PATHTYPE", "GENERATIONS", "ATTRTABLE", "STYPTABLE", "STRTYPE", "ELFLAGS", "ELKEY",
    "LINKTYPE", "LINKKEYS", "NODETYPE", "PROPATTR", "PROPVALUE", "BOX", "BOXTYPE", "PLEX", "BGNEXTN", "ENDEXTN", "TAPENUM", "TAPECODE",
    "STRCLASS", "RESERVED", "FORMAT", "MASK", "ENDMASKS", "LIBDIRSIZE", "SRFNAME", "LIBSECUR",
};

static const char* _recordname(enum recordtypes recordtype)
{
    if((size_t)recordtype < sizeof(recordnames) / sizeof(recordnames[0]))
    {
        return recordnames[recordtype];
    }
    return "UNKNOWN";
}

struct record {
    uint16_t length;
    enum recordtypes recordtype;
    uint8_t datatype;
    uint8_t* data;
};

// must hold at least one complete record (the maximum record length is 65535 bytes)
#define STREAM_BUFFER_SIZE (1 << 20)

struct stream {
    FILE* file;
    uint8_t* buffer;
    size_t pos; // start of the next record in buffer
    size_t end; // end of valid data in buffer
    long long bufferoffset; // file offset of buffer[0]
    struct record current; // data points into buffer, valid until the next _get_next_record call
    size_t index; // number of records read so far
};

static struct stream* _open_stream(const char* filename)
{
    FILE* file = fopen(filename, "rb");
    if(!file)
    {
        fprintf(stderr, "gdsparser: could not open file '%s'\n", filename);
        return NULL;
    }
    struct stream* stream = malloc(sizeof(*stream));
    stream->file = file;
    stream->buffer = malloc(STREAM_BUFFER_SIZE);
    stream->pos = 0;
    stream->end = 0;
    stream->bufferoffset = 0;
    stream->index = 0;
    return stream;
}

static void _destroy_stream(struct stream* stream)
{
    fclose(stream->file);
    free(stream->buffer);
    free(stream);
}

// make sure that at least 'numbytes' unread bytes are available in the buffer, starting at stream->pos
// a partially read record is moved to the front of the buffer before refilling it
static int _ensure_available(struct stream* stream, size_t numbytes)
{
    if(stream->end - stream->pos >= numbytes)
    {
        return 1;
    }
    size_t remaining = stream->end - stream->pos;
    memmove(stream->buffer, stream->buffer + stream->pos, remaining);
    stream->bufferoffset += stream->pos;
    stream->pos = 0;
    stream->end = remaining;
    while(stream->end < numbytes)
    {
        size_t read = fread(stream->buffer + stream->end, 1, STREAM_BUFFER_SIZE - stream->end, stream->file);
        if(read == 0)
        {
            return 0;
        }
        stream->end += read;
    }
    return 1;
}

static struct record* _get_next_record(struct stream* stream)
{
    if(!_ensure_available(stream, 4))
    {
        fprintf(stderr, "gdsparser: stream abort before ENDLIB (at byte %lld)\n", stream->bufferoffset + (long long)stream->end);
        return NULL;
    }
    const uint8_t* header = stream->buffer + stream->pos;
    uint16_t length = (header[0] << 8) | header[1];
    if(length < 4 || !_ensure_available(stream, length))
    {
        fprintf(stderr, "gdsparser: stream abort before ENDLIB (at byte %lld)\n", stream->bufferoffset + (long long)stream->end);
        return NULL;
    }
    // _ensure_available might have moved the record to the front of the buffer
    uint8_t* recordstart = stream->buffer + stream->pos;
    stream->current.length = length;
    stream->current.recordtype = recordstart[2];
    stream->current.datatype = recordstart[3];
    stream->current.data = recordstart + 4;
    stream->pos += length;
    ++stream->index;
    return &stream->current;
}

static void _reset_stream(struct stream* stream)
{
    rewind(stream->file);
    stream->pos = 0;
    stream->end = 0;
    stream->bufferoffset = 0;
    stream->index = 0;
}

// bit 0 of a bit array is the most significant bit of the first byte
static inline int _parse_bit(const uint8_t* data, int bit)
{
    return (data[bit / 8] >> (7 - bit % 8)) & 1;
}

static inline int16_t _parse_two_byte_integer(const uint8_t* data)
{
    return (int16_t)((data[0] << 8) | data[1]);
}

static inline int32_t _parse_four_byte_integer(const uint8_t* data)
{
    return (int32_t)(((uint32_t)data[0] << 24) | ((uint32_t)data[1] << 16) | ((uint32_t)data[2] << 8) | data[3]);
}

static inline void _parse_single_point_i(uint8_t* data, size_t i, struct point* pt)
{
    pt->x = (int32_t)(((uint32_t)data[i * 8] << 24) | ((uint32_t)data[i * 8 + 1] << 16) | ((uint32_t)data[i * 8 + 2] << 8) | data[i * 8 + 3]);
    pt->y = (int32_t)(((uint32_t)data[i * 8 + 4] << 24) | ((uint32_t)data[i * 8 + 5] << 16) | ((uint32_t)data[i * 8 + 6] << 8) | data[i * 8 + 7]);
}

static struct vector* _parse_points(uint8_t* data, size_t length)
{
    struct vector* points = vector_create(length >> 3, point_destroy);
    for(size_t i = 0; i < length >> 3; ++i)
    {
        struct point* pt = point_create(0, 0);
        _parse_single_point_i(data, i, pt);
        vector_append(points, pt);
    }
    return points;
}

static void _parse_xy_i(uint8_t* data, size_t i, coordinate_t* xy)
{
    *xy = (int32_t)(((uint32_t)data[i * 4] << 24) | ((uint32_t)data[i * 4 + 1] << 16) | ((uint32_t)data[i * 4 + 2] << 8) | data[i * 4 + 3]);
}

static coordinate_t* _parse_points_xy(uint8_t* data, size_t length)
{
    coordinate_t* points = malloc(sizeof(*points) * (length >> 2));
    for(size_t i = 0; i < length >> 2; ++i)
    {
        _parse_xy_i(data, i, points + i);
    }
    return points;
}

static double _parse_four_byte_real(const uint8_t* data)
{
    int sign = data[0] & 0x80;
    int8_t exp = data[0] & 0x7f;
    double mantissa = data[1] / 256.0
        + data[2] / 256.0 / 256.0
        + data[3] / 256.0 / 256.0 / 256.0;
    if(sign)
    {
        return -mantissa * pow(16.0, exp - 64);
    }
    else
    {
        return mantissa * pow(16.0, exp - 64);
    }
}

static double _parse_eight_byte_real(const uint8_t* data)
{
    int sign = data[0] & 0x80;
    int8_t exp = data[0] & 0x7f;
    double mantissa = data[1] / 256.0
                    + data[2] / 256.0 / 256.0
                    + data[3] / 256.0 / 256.0 / 256.0
                    + data[4] / 256.0 / 256.0 / 256.0 / 256.0
                    + data[5] / 256.0 / 256.0 / 256.0 / 256.0 / 256.0
                    + data[6] / 256.0 / 256.0 / 256.0 / 256.0 / 256.0 / 256.0
                    + data[7] / 256.0 / 256.0 / 256.0 / 256.0 / 256.0 / 256.0 / 256.0;
    if(sign)
    {
        return -mantissa * pow(16.0, exp - 64);
    }
    else
    {
        return mantissa * pow(16.0, exp - 64);
    }
}

static char* _parse_string(uint8_t* data, size_t length)
{
    char* string = malloc(length + 1);
    if(!string)
    {
        return NULL;
    }
    strncpy(string, (const char*) data, length);
    string[length] = 0;
    return string;
}

struct hierarchy_cellref {
    char* name;
    struct vector* references;
};

struct hierarchy_cellref* _make_hierarchy_cellref(void)
{
    struct hierarchy_cellref* cell = malloc(sizeof(*cell));
    cell->name = NULL;
    cell->references = vector_create(1, free);
    return cell;
}

void _destroy_hierarchy_cellref(void* v)
{
    struct hierarchy_cellref* cell = v;
    free(cell->name);
    vector_destroy(cell->references);
    free(cell);
}

static struct vector* _read_cells(struct stream* stream)
{
    TIMEPERF_START();
    struct vector* cells = vector_create(1, _destroy_hierarchy_cellref);
    struct hierarchy_cellref* cell = NULL;
    int isobj = 0;
    char* objname = NULL;
    int success = 0;
    while(1)
    {
        struct record* record = _get_next_record(stream);
        if(!record)
        {
            puts("gdsparser: end of stream before ENDLIB");
            break;
        }
        else if(record->recordtype == BGNSTR)
        {
            if(cell)
            {
                puts("gdsparser: BGNSTR inside of structure");
                break;
            }
            cell = _make_hierarchy_cellref();
        }
        else if(record->recordtype == ENDSTR)
        {
            if(!cell || !cell->name)
            {
                puts("gdsparser: ENDSTR outside of structure or structure without STRNAME");
                break;
            }
            vector_append(cells, cell);
            cell = NULL;
        }
        else if(record->recordtype == STRNAME)
        {
            if(!cell)
            {
                puts("gdsparser: STRNAME outside of structure");
                break;
            }
            free(cell->name);
            cell->name = _parse_string(record->data, record->length - 4);
        }
        else if((record->recordtype == SREF) || (record->recordtype == AREF))
        {
            isobj = 1;
        }
        else if(record->recordtype == ENDEL)
        {
            if(isobj)
            {
                if(!cell || !objname)
                {
                    puts("gdsparser: malformed SREF/AREF");
                    break;
                }
                vector_append(cell->references, objname);
                objname = NULL;
                isobj = 0;
            }
        }
        else if(record->recordtype == SNAME)
        {
            free(objname);
            objname = _parse_string(record->data, record->length - 4);
        }
        else if(record->recordtype == ENDLIB)
        {
            if(cell)
            {
                puts("gdsparser: ENDLIB inside of structure");
            }
            else
            {
                success = 1;
            }
            break;
        }
    }
    free(objname);
    if(cell)
    {
        _destroy_hierarchy_cellref(cell);
    }
    if(!success)
    {
        vector_destroy(cells);
        cells = NULL;
    }
    TIMEPERF_STOP();
    return cells;
}

static struct const_vector* _get_cell_references(struct hierarchy_cellref* cell)
{
    struct const_vector* references = const_vector_create(1);
    struct vector_iterator* it = vector_iterator_create(cell->references);
    while(vector_iterator_is_valid(it))
    {
        const char* refname = vector_iterator_get(it);
        const_vector_append(references, refname);
        vector_iterator_next(it);
    }
    vector_iterator_destroy(it);
    return references;
}

static struct hierarchy_cellref* _find_cell(struct vector* cells, const char* cellname)
{
    struct vector_iterator* it = vector_iterator_create(cells);
    while(vector_iterator_is_valid(it))
    {
        struct hierarchy_cellref* cell = vector_iterator_get(it);
        if(strcmp(cell->name, cellname) == 0)
        {
            vector_iterator_destroy(it);
            return cell;
        }
        vector_iterator_next(it);
    }
    vector_iterator_destroy(it);
    return NULL;
}

static int _is_not_referenced(const char* name, struct const_vector* referenced)
{
    struct const_vector_iterator* it = const_vector_iterator_create(referenced);
    while(const_vector_iterator_is_valid(it))
    {
        const char* refname = const_vector_iterator_get(it);
        if(strcmp(name, refname) == 0)
        {
            const_vector_iterator_destroy(it);
            return 0;
        }
        const_vector_iterator_next(it);
    }
    const_vector_iterator_destroy(it);
    return 1;
}

static struct const_vector* _get_toplevel_cells(struct vector* cells)
{
    TIMEPERF_START();
    struct vector_iterator* it;

    struct const_vector* referenced = const_vector_create(1);
    it = vector_iterator_create(cells);
    while(vector_iterator_is_valid(it))
    {
        struct hierarchy_cellref* cell = vector_iterator_get(it);
        struct const_vector* references = _get_cell_references(cell);
        struct const_vector_iterator* refit = const_vector_iterator_create(references);
        while(const_vector_iterator_is_valid(refit))
        {
            const char* refname = const_vector_iterator_get(refit);
            const_vector_append(referenced, refname);
            const_vector_iterator_next(refit);
        }
        const_vector_iterator_destroy(refit);
        const_vector_destroy(references);
        vector_iterator_next(it);
    }
    vector_iterator_destroy(it);

    struct const_vector* toplevelcells = const_vector_create(1);
    it = vector_iterator_create(cells);
    while(vector_iterator_is_valid(it))
    {
        struct hierarchy_cellref* cell = vector_iterator_get(it);
        if(_is_not_referenced(cell->name, referenced))
        {
            const_vector_append(toplevelcells, cell);
        }
        vector_iterator_next(it);
    }
    vector_iterator_destroy(it);

    const_vector_destroy(referenced);

    TIMEPERF_STOP();
    return toplevelcells;
}

struct tree_element {
    const char* name;
    size_t level;
};

struct tree_element* _make_tree_element(const struct hierarchy_cellref* cell, size_t level)
{
    struct tree_element* element = malloc(sizeof(*element));
    element->name = cell->name;
    element->level = level;
    return element;
}

void _destroy_tree_element(void* v)
{
    free(v);
}

static void _assemble_tree_element(struct vector* cells, struct vector* tree, const struct hierarchy_cellref* cell, size_t level)
{
    struct vector_iterator* it = vector_iterator_create(cell->references);
    while(vector_iterator_is_valid(it))
    {
        const char* refname = vector_iterator_get(it);
        const struct hierarchy_cellref* sub = _find_cell(cells, refname);
        if(sub) // references to cells not defined in this library are skipped
        {
            vector_append(tree, _make_tree_element(sub, level + 1));
            _assemble_tree_element(cells, tree, sub, level + 1);
        }
        vector_iterator_next(it);
    }
    vector_iterator_destroy(it);
}

static struct vector* _resolve_hierarchy(struct vector* cells)
{
    struct const_vector* toplevelcells = _get_toplevel_cells(cells);
    struct vector* tree = vector_create(1, _destroy_tree_element);
    struct const_vector_iterator* it = const_vector_iterator_create(toplevelcells);
    while(const_vector_iterator_is_valid(it))
    {
        const struct hierarchy_cellref* cell = const_vector_iterator_get(it);
        vector_append(tree, _make_tree_element(cell, 0));
        _assemble_tree_element(cells, tree, cell, 0);
        const_vector_iterator_next(it);
    }
    const_vector_iterator_destroy(it);
    const_vector_destroy(toplevelcells);
    return tree;
}

void gdsparser_show_cell_hierarchy(const char* filename, size_t depth)
{
    struct stream* stream = _open_stream(filename);
    if(!stream)
    {
        return;
    }
    struct vector* cells = _read_cells(stream);
    _destroy_stream(stream);
    if(!cells)
    {
        return;
    }
    struct vector* tree = _resolve_hierarchy(cells);
    struct vector_iterator* it = vector_iterator_create(tree);
    while(vector_iterator_is_valid(it))
    {
        struct tree_element* element = vector_iterator_get(it);
        if(depth == 0 || element->level < depth)
        {
            for(size_t i = 0; i < element->level; ++i)
            {
                putchar(' ');
                putchar(' ');
                putchar(' ');
                putchar(' ');
            }
            puts(element->name);
        }
        vector_iterator_next(it);
    }
    vector_iterator_destroy(it);
    vector_destroy(cells);
    vector_destroy(tree);
}

int gdsparser_show_cell_definitions(const char* filename)
{
    struct stream* stream = _open_stream(filename);
    if(!stream)
    {
        return 0;
    }

    int is_structure = 0;
    while(1)
    {
        struct record* record = _get_next_record(stream);
        if(!record)
        {
            _destroy_stream(stream);
            return 0;
        }
        if(record->recordtype == BGNSTR)
        {
            is_structure = 1;
        }
        if(record->recordtype == ENDSTR)
        {
            is_structure = 0;
        }
        if(is_structure && record->recordtype == STRNAME)
        {
            for(int i = 0; i < record->length - 4; ++i)
            {
                char ch = ((char*)record->data)[i];
                if(ch) // odd-length strings are zero padded, don't print that character
                {
                    putchar(ch);
                }
            }
            putchar('\n');
        }

        if(record->recordtype == ENDLIB)
        {
            break;
        }
    }
    _destroy_stream(stream);
    return 1;
}

// collects output and writes it in large blocks, avoiding one stdio call per character
#define OUTBUFFER_SIZE (1 << 16)

struct outbuffer {
    FILE* file;
    size_t pos;
    char data[OUTBUFFER_SIZE];
};

static struct outbuffer* _create_outbuffer(FILE* file)
{
    struct outbuffer* out = malloc(sizeof(*out));
    out->file = file;
    out->pos = 0;
    return out;
}

static void _flush_outbuffer(struct outbuffer* out)
{
    fwrite(out->data, 1, out->pos, out->file);
    out->pos = 0;
}

static void _destroy_outbuffer(struct outbuffer* out)
{
    _flush_outbuffer(out);
    free(out);
}

static inline void _out_char(struct outbuffer* out, char ch)
{
    if(out->pos == OUTBUFFER_SIZE)
    {
        _flush_outbuffer(out);
    }
    out->data[out->pos] = ch;
    ++out->pos;
}

static void _out_bytes(struct outbuffer* out, const char* bytes, size_t len)
{
    if(out->pos + len > OUTBUFFER_SIZE)
    {
        _flush_outbuffer(out);
        if(len > OUTBUFFER_SIZE)
        {
            fwrite(bytes, 1, len, out->file);
            return;
        }
    }
    memcpy(out->data + out->pos, bytes, len);
    out->pos += len;
}

static void _out_string(struct outbuffer* out, const char* str)
{
    _out_bytes(out, str, strlen(str));
}

static void _out_fill(struct outbuffer* out, char ch, size_t len)
{
    while(len > 0)
    {
        if(out->pos == OUTBUFFER_SIZE)
        {
            _flush_outbuffer(out);
        }
        size_t num = MIN2(len, OUTBUFFER_SIZE - out->pos);
        memset(out->data + out->pos, ch, num);
        out->pos += num;
        len -= num;
    }
}

static const char digitpairs[] =
    "0001020304050607080910111213141516171819"
    "2021222324252627282930313233343536373839"
    "4041424344454647484950515253545556575859"
    "6061626364656667686970717273747576777879"
    "8081828384858687888990919293949596979899";

static inline unsigned int _count_digits(uint32_t num)
{
    if(num < 10) return 1;
    if(num < 100) return 2;
    if(num < 1000) return 3;
    if(num < 10000) return 4;
    if(num < 100000) return 5;
    if(num < 1000000) return 6;
    if(num < 10000000) return 7;
    if(num < 100000000) return 8;
    if(num < 1000000000) return 9;
    return 10;
}

static void _out_uint32(struct outbuffer* out, uint32_t num)
{
    // uint32_t has at most 10 digits
    if(out->pos + 10 > OUTBUFFER_SIZE)
    {
        _flush_outbuffer(out);
    }
    // digits are written directly into the buffer from the back, two at a time
    unsigned int numdigits = _count_digits(num);
    char* ptr = out->data + out->pos + numdigits;
    out->pos += numdigits;
    while(num >= 100)
    {
        uint32_t pair = num % 100;
        num /= 100;
        ptr -= 2;
        ptr[0] = digitpairs[2 * pair];
        ptr[1] = digitpairs[2 * pair + 1];
    }
    if(num >= 10)
    {
        ptr -= 2;
        ptr[0] = digitpairs[2 * num];
        ptr[1] = digitpairs[2 * num + 1];
    }
    else
    {
        ptr[-1] = '0' + num;
    }
}

static void _out_int32(struct outbuffer* out, int32_t num)
{
    if(num < 0)
    {
        _out_char(out, '-');
        // negate in unsigned arithmetic, -INT32_MIN is not representable as int32_t
        _out_uint32(out, 0u - (uint32_t)num);
    }
    else
    {
        _out_uint32(out, num);
    }
}

static void _out_int16(struct outbuffer* out, int16_t num)
{
    _out_int32(out, num);
}

static void _out_real(struct outbuffer* out, double num)
{
    // "%g " needs at most 14 characters ("-1.23457e+308 ")
    if(out->pos + 32 > OUTBUFFER_SIZE)
    {
        _flush_outbuffer(out);
    }
    out->pos += snprintf(out->data + out->pos, 32, "%g ", num);
}

static void _out_byte_hex_with_prefix(struct outbuffer* out, uint8_t num)
{
    static const char lut[] = "0123456789abcdef";
    char str[4] = { '0', 'x', lut[(num & 0xf0) >> 4], lut[num & 0x0f] };
    _out_bytes(out, str, 4);
}

static void _print_pos_int16(FILE* file, int16_t num)
{
    if(num > 9)
    {
        _print_pos_int16(file, num / 10);
    }
    fputc((num % 10) + '0', file);
}

static void _print_int16(FILE* file, int16_t num)
{
    if(num < 0)
    {
        fputc('-', file);
        num *= -1;
    }
    if(num > 9)
    {
        _print_pos_int16(file, num / 10);
    }
    fputc((num % 10) + '0', file);
}

static void _print_pos_int32(FILE* file, int32_t num)
{
    if(num > 9)
    {
        _print_pos_int32(file, num / 10);
    }
    fputc((num % 10) + '0', file);
}

static void _print_int32(FILE* file, int32_t num)
{
    if(num < 0)
    {
        fputc('-', file);
        num *= -1;
    }
    if(num > 9)
    {
        _print_pos_int32(file, num / 10);
    }
    fputc((num % 10) + '0', file);
}

int gdsparser_show_records(const char* filename, int raw)
{
    TIMEPERF_START();
    struct stream* stream = _open_stream(filename);
    if(!stream)
    {
        return 0;
    }
    struct outbuffer* out = _create_outbuffer(stdout);

    unsigned int indent = 0;
    while(1)
    {
        struct record* record = _get_next_record(stream);
        if(!record)
        {
            _destroy_outbuffer(out);
            _destroy_stream(stream);
            return 0;
        }
        if(record->recordtype == ENDLIB || record->recordtype == ENDSTR || record->recordtype == ENDEL)
        {
            --indent;
        }
        _out_fill(out, ' ', 4 * indent);
        _out_string(out, _recordname(record->recordtype));
        _out_bytes(out, " (", 2);
        _out_uint32(out, record->length);
        _out_char(out, ')');

        // print data
        if(record->length > 4)
        {
            _out_bytes(out, " -> data: ", 10);
            // parsed data
            switch(record->datatype)
            {
                case TWO_BYTE_INTEGER:
                {
                    for(int i = 0; i < (record->length - 4) / 2; ++i)
                    {
                        _out_int16(out, _parse_two_byte_integer(record->data + i * 2));
                        _out_char(out, ' ');
                    }
                    break;
                }
                case FOUR_BYTE_INTEGER:
                {
                    for(int i = 0; i < (record->length - 4) / 4; ++i)
                    {
                        _out_int32(out, _parse_four_byte_integer(record->data + i * 4));
                        _out_char(out, ' ');
                    }
                    break;
                }
                case FOUR_BYTE_REAL:
                {
                    for(int i = 0; i < (record->length - 4) / 4; ++i)
                    {
                        _out_real(out, _parse_four_byte_real(record->data + i * 4));
                    }
                    break;
                }
                case EIGHT_BYTE_REAL:
                {
                    for(int i = 0; i < (record->length - 4) / 8; ++i)
                    {
                        _out_real(out, _parse_eight_byte_real(record->data + i * 8));
                    }
                    break;
                }
                case ASCII_STRING:
                {
                    // odd-length strings are zero padded, don't print zero characters
                    _out_char(out, '"');
                    const char* str = (const char*)record->data;
                    size_t len = record->length - 4;
                    while(len > 0)
                    {
                        const char* zero = memchr(str, 0, len);
                        size_t runlen = zero ? (size_t)(zero - str) : len;
                        _out_bytes(out, str, runlen);
                        if(!zero)
                        {
                            break;
                        }
                        len -= runlen + 1;
                        str = zero + 1;
                    }
                    _out_char(out, '"');
                    break;
                }
                case BIT_ARRAY:
                {
                    char bits[16];
                    for(int i = 0; i < 16; ++i)
                    {
                        bits[i] = _parse_bit(record->data, i) ? '1' : '0';
                    }
                    _out_bytes(out, bits, 16);
                    break;
                }
                default:
                    break;
            }
        }
        if(raw)
        {
            _out_bytes(out, " (", 2);
            for(int i = 0; i < record->length - 4; ++i)
            {
                _out_byte_hex_with_prefix(out, record->data[i]);
                if(i < record->length - 5)
                {
                    _out_char(out, ' ');
                }
            }
            _out_char(out, ')');
        }
        _out_char(out, '\n');

        if(record->recordtype == BGNLIB ||
           record->recordtype == BGNSTR ||
           record->recordtype == BOUNDARY ||
           record->recordtype == PATH ||
           record->recordtype == SREF ||
           record->recordtype == AREF ||
           record->recordtype == TEXT)
        {
            ++indent;
        }
        if(record->recordtype == ENDLIB)
        {
            break;
        }
    }
    _destroy_outbuffer(out);
    _destroy_stream(stream);
    TIMEPERF_STOP();
    return 1;
}

static void _rectangle_coordinates(const coordinate_t* points, coordinate_t* blx, coordinate_t* bly, coordinate_t* trx, coordinate_t* try)
{
    *blx = MIN4(points[0], points[2], points[4], points[6]);
    *bly = MIN4(points[1], points[3], points[5], points[7]);
    *trx = MAX4(points[0], points[2], points[4], points[6]);
    *try = MAX4(points[1], points[3], points[5], points[7]);
}

struct cellref {
    char* name;
    struct point* origin;
    int16_t xrep;
    int16_t yrep;
    coordinate_t xpitch;
    coordinate_t ypitch;
    int reflected; // STRANS bit 0: reflection about the x-axis
    double angle;
};

static int _check_rectangle(const coordinate_t* points)
{
    return ((points[1] == points[3])  &&
            (points[2] == points[4])  &&
            (points[5] == points[7])  &&
            (points[6] == points[8])  &&
            (points[0] == points[8])  &&
            (points[1] == points[9])) ||
           ((points[0] == points[2])  &&
            (points[3] == points[5])  &&
            (points[4] == points[6])  &&
            (points[7] == points[9])  &&
            (points[0] == points[8])  &&
            (points[1] == points[9]));
}

struct layermapping {
    int16_t layer;
    int16_t purpose;
    char* map;
    char** mappings;
    size_t num;
};

static void _destroy_mapping(void* v)
{
    struct layermapping* mapping = v;
    if(mapping->mappings)
    {
        for(unsigned int i = 0; i < mapping->num; ++i)
        {
            free(mapping->mappings[i]);
        }
        free(mapping->mappings);
    }
    if(mapping->map)
    {
        free(mapping->map);
    }
    free(mapping);
}

struct vector* gdsparser_create_layermap(struct technology_state* techstate)
{
    if(!techstate)
    {
        return NULL;
    }
    TIMEPERF_START();
    lua_State* L = util_create_basic_lua_state();
    module_load_tools(L);
    // call tools.reverse_layermap
    lua_getglobal(L, "tools");
    lua_getfield(L, -1, "reverse_layermap");
    technology_push_layermap_table(L, techstate);
    lua_pushstring(L, "gds"); // target export
    int ret = lua_pcall(L, 2, 1, 0);
    if(ret != LUA_OK)
    {
        const char* msg = lua_tostring(L, -1);
        fprintf(stderr, "error while loading gdslayermap:\n  %s\n", msg);
        lua_close(L);
        return NULL;
    }
    struct vector* map = vector_create(1, _destroy_mapping);
    lua_len(L, -1);
    size_t len = lua_tointeger(L, -1);
    lua_pop(L, 1);
    for(size_t i = 1; i <= len; ++i)
    {
        struct layermapping* layermapping = malloc(sizeof(*layermapping));
        layermapping->map = NULL;
        layermapping->mappings = NULL;
        layermapping->num = 0;
        lua_rawgeti(L, -1, i); // get entry

        lua_getfield(L, -1, "layer");
        layermapping->layer = lua_tointeger(L, -1);
        lua_pop(L, 1);

        lua_getfield(L, -1, "purpose");
        layermapping->purpose = lua_tointeger(L, -1);
        lua_pop(L, 1);

        lua_getfield(L, -1, "map");
        if(!lua_isnil(L, -1))
        {
            layermapping->map = util_strdup(lua_tostring(L, -1));
        }
        lua_pop(L, 1);

        lua_getfield(L, -1, "mappings");
        if(!lua_isnil(L, -1))
        {
            lua_len(L, -1);
            size_t maplen = lua_tointeger(L, -1);
            lua_pop(L, 1);
            layermapping->num = maplen;
            layermapping->mappings = malloc(maplen * sizeof(*layermapping->mappings));
            for(size_t j = 1; j <= maplen; ++j)
            {
                lua_rawgeti(L, -1, j);
                const char* mapping = lua_tostring(L, -1);
                layermapping->mappings[j - 1] = util_strdup(mapping);
                lua_pop(L, 1);
            }
        }
        lua_pop(L, 1);

        lua_pop(L, 1); // pop entry

        vector_append(map, layermapping);
    }
    lua_pop(L, 1); // pop "tools" module table
    lua_close(L);
    TIMEPERF_STOP();
    return map;
}

void gdsparser_destroy_layermap(struct vector* layermap)
{
    if(layermap)
    {
        vector_destroy(layermap);
    }
}

static const char* _has_direct_mapping(int16_t layer, int16_t purpose, const struct vector* layermap)
{
    if(!layermap)
    {
        return NULL;
    }
    struct vector_const_iterator* it = vector_const_iterator_create(layermap);
    while(vector_const_iterator_is_valid(it))
    {
        const struct layermapping* mapping = vector_const_iterator_get(it);
        if(layer == mapping->layer && purpose == mapping->purpose && mapping->map)
        {
            vector_const_iterator_destroy(it);
            return mapping->map;
        }
        vector_const_iterator_next(it);
    }
    vector_const_iterator_destroy(it);
    return NULL;
}

static void _write_layers(FILE* cellfile, int16_t layer, int16_t purpose, const struct vector* layermap)
{
    const char* directmap = _has_direct_mapping(layer, purpose, layermap);
    if(directmap)
    {
        fputs(directmap, cellfile);
    }
    else
    {
        fputs("generics.premapped(nil, { ", cellfile);
        fputs("gds = { layer = ", cellfile);
        _print_int16(cellfile, layer);
        fputs(", purpose = ", cellfile);
        _print_int16(cellfile, purpose);
        fputs(" }", cellfile);
        if(layermap)
        {
            int foundmapping = 0;
            struct vector_const_iterator* it = vector_const_iterator_create(layermap);
            while(vector_const_iterator_is_valid(it))
            {
                const struct layermapping* mapping = vector_const_iterator_get(it);
                if(layer == mapping->layer && purpose == mapping->purpose)
                {
                    foundmapping = 1;
                    for(unsigned int i = 0; i < mapping->num; ++i)
                    {
                        fprintf(cellfile, ", %s", mapping->mappings[i]);
                    }
                }
                vector_const_iterator_next(it);
            }
            vector_const_iterator_destroy(it);
            if(!foundmapping)
            {
                fprintf(stderr, "read GDS: layermap is present, but no mapping was found for layer (%d, %d)\n", layer, purpose);
            }
        }
        fputs(" })", cellfile);
    }
}

int _check_lpp(int16_t layer, int16_t purpose, const struct vector* ignorelpp)
{
    if(ignorelpp)
    {
        struct vector_const_iterator* it = vector_const_iterator_create(ignorelpp);
        while(vector_const_iterator_is_valid(it))
        {
            const int16_t* lpp = vector_const_iterator_get(it);
            if(layer == lpp[0] && purpose == lpp[1])
            {
                vector_const_iterator_destroy(it);
                return 0;
            }
            vector_const_iterator_next(it);
        }
        vector_const_iterator_destroy(it);
    }
    return 1;
}

static int _read_TEXT(struct stream* stream, char** str, int16_t* layer, int16_t* purpose, struct point* origin, double* angle, int* reflected)
{
    int readlayer = 0;
    while(1)
    {
        struct record* record = _get_next_record(stream);
        if(!record)
        {
            puts("gdsparser: end of stream while reading TEXT");
            return 0;
        }
        else if(record->recordtype == ELFLAGS)
        {
            // FIXME: handle record
        }
        else if(record->recordtype == PLEX)
        {
            // FIXME: handle record
        }
        else if(record->recordtype == LAYER)
        {
            *layer = _parse_two_byte_integer(record->data);
            readlayer = 1;
        }
        else if(record->recordtype == TEXTTYPE)
        {
            *purpose = _parse_two_byte_integer(record->data);
        }
        else if(record->recordtype == PRESENTATION)
        {
            // FIXME: handle record
        }
        else if(record->recordtype == STRANS)
        {
            *reflected = _parse_bit(record->data, 0);
        }
        else if(record->recordtype == ANGLE)
        {
            *angle = _parse_eight_byte_real(record->data);
        }
        else if(record->recordtype == MAG)
        {
            // FIXME: handle record
        }
        else if(record->recordtype == XY)
        {
            _parse_single_point_i(record->data, 0, origin);
        }
        else if(record->recordtype == STRING)
        {
            free(*str);
            *str = _parse_string(record->data, record->length - 4);
        }
        else if(record->recordtype == PROPATTR)
        {
            // FIXME: handle record
        }
        else if(record->recordtype == PROPVALUE)
        {
            // FIXME: handle record
        }
        else if(record->recordtype == ENDEL)
        {
            break;
        }
        else // wrong record
        {
            fprintf(stderr, "malformed TEXT, got unexpected record '%s' (#%zd)\n", _recordname(record->recordtype), stream->index);
            return 0;
        }
    }
    return readlayer;
}

static void _destroy_cellref(struct cellref* cellref)
{
    free(cellref->name);
    point_destroy(cellref->origin);
    free(cellref);
}

static struct cellref* _read_SREF_AREF(struct stream* stream, int isAREF)
{
    struct cellref* cellref = malloc(sizeof(*cellref));
    cellref->name = NULL;
    cellref->origin = point_create(0, 0);
    cellref->xrep = 1;
    cellref->yrep = 1;
    cellref->angle = 0.0;
    cellref->reflected = 0;
    while(1)
    {
        struct record* record = _get_next_record(stream);
        if(!record)
        {
            _destroy_cellref(cellref);
            return NULL;
        }
        if(record->recordtype == ELFLAGS)
        {
            // FIXME: handle record
        }
        else if(record->recordtype == PLEX)
        {
            // FIXME: handle record
        }
        else if(record->recordtype == SNAME)
        {
            free(cellref->name);
            cellref->name = _parse_string(record->data, record->length - 4);
        }
        else if(record->recordtype == STRANS)
        {
            cellref->reflected = _parse_bit(record->data, 0);
        }
        else if(record->recordtype == ANGLE)
        {
            cellref->angle = _parse_eight_byte_real(record->data);
        }
        else if(record->recordtype == MAG)
        {
            // FIXME: handle record
        }
        else if(record->recordtype == COLROW)
        {
            cellref->xrep = _parse_two_byte_integer(record->data);
            cellref->yrep = _parse_two_byte_integer(record->data + 2);
        }
        else if(record->recordtype == XY)
        {
            _parse_single_point_i(record->data, 0, cellref->origin);
            if(isAREF)
            {
                coordinate_t x1, y1;
                coordinate_t x2, y2;
                coordinate_t x3, y3;
                // coordinate words memory locations:
                // pt1: x [0] y [1]
                // pt2: x [2] y [3]
                // pt3: x [4] y [5]
                // for pitch, only x2 and y3 are needed
                _parse_xy_i(record->data, 0, &x1);
                _parse_xy_i(record->data, 1, &y1);
                _parse_xy_i(record->data, 2, &x2);
                _parse_xy_i(record->data, 3, &y2);
                _parse_xy_i(record->data, 4, &x3);
                _parse_xy_i(record->data, 5, &y3);
                coordinate_t dxcolumn = x2 - x1;
                coordinate_t dycolumn = y2 - y1;
                coordinate_t dxrow = x3 - x1;
                coordinate_t dyrow = y3 - y1;
                if(!(((dxcolumn == 0) && (dyrow == 0)) || ((dxrow == 0) && (dycolumn == 0))))
                {
                    puts("array vectors are not orthogonal");
                }
                if(dxcolumn > 0)
                {
                    cellref->xpitch = dxcolumn / cellref->xrep;
                    cellref->ypitch = dyrow / cellref->yrep;
                }
                else
                {
                    // column vector points in y-direction, flip direction
                    int16_t tmp = cellref->xrep;
                    cellref->xrep = cellref->yrep;
                    cellref->yrep = tmp;
                    cellref->xpitch = dxrow / cellref->xrep;
                    cellref->ypitch = dycolumn / cellref->yrep;
                }
            }
        }
        else if(record->recordtype == ENDEL)
        {
            break;
        }
        else // wrong record
        {
            fprintf(stderr, "malformed SREF/AREF, got unexpected record '%s' (#%zd)\n", _recordname(record->recordtype), stream->index);
            _destroy_cellref(cellref);
            return NULL;
        }
    }
    if(!cellref->name)
    {
        fputs("malformed SREF/AREF, missing SNAME\n", stderr);
        _destroy_cellref(cellref);
        return NULL;
    }
    return cellref;
}
#define _read_SREF(stream) _read_SREF_AREF(stream, 0)
#define _read_AREF(stream) _read_SREF_AREF(stream, 1)

static void _write_cellref(FILE* cellfile, const struct cellref* cellref)
{
    fprintf(cellfile, "    ref = env.references[\"%s\"]\n", cellref->name);
    if(cellref->xrep > 1 || cellref->yrep > 1)
    {
        fprintf(cellfile, "    child = cell:add_child_array(ref, \"%s\", %d, %d, %lld, %lld)\n", cellref->name, cellref->xrep, cellref->yrep, cellref->xpitch, cellref->ypitch);
    }
    else
    {
        //fprintf(cellfile, "    child = cell:add_child(ref, \"%s\")\n", cellref->name);
        fputs("    child = cell:add_child(ref)\n", cellfile);
    }
    if(cellref->angle == 90)
    {
        fputs("    child:rotate_90_left()\n", cellfile);
    }
    else if(cellref->angle == 180)
    {
        fputs("    child:rotate_90_left()\n", cellfile);
        fputs("    child:rotate_90_left()\n", cellfile);
    }
    else if(cellref->angle == 270)
    {
        fputs("    child:rotate_90_left()\n", cellfile);
        fputs("    child:rotate_90_left()\n", cellfile);
        fputs("    child:rotate_90_left()\n", cellfile);
    }
    if(cellref->reflected)
    {
        fputs("    child:mirror_at_xaxis()\n", cellfile);
    }
    if(!(cellref->origin->x == 0 && cellref->origin->y == 0))
    {
        fprintf(cellfile, "    child:translate(%lld, %lld)\n", cellref->origin->x, cellref->origin->y);
    }
    free(cellref->name);
    point_destroy(cellref->origin);
}

static int _read_BOUNDARY(struct stream* stream, int16_t* layer, int16_t* purpose, coordinate_t** points, size_t* size)
{
    int readlayer = 0;
    while(1)
    {
        struct record* record = _get_next_record(stream);
        if(!record)
        {
            puts("gdsparser: end of stream while reading BOUNDARY");
            return 0;
        }
        if(record->recordtype == ELFLAGS)
        {
            // FIXME: handle record
        }
        else if(record->recordtype == PLEX)
        {
            // FIXME: handle record
        }
        else if(record->recordtype == LAYER)
        {
            *layer = _parse_two_byte_integer(record->data);
            readlayer = 1;
        }
        else if(record->recordtype == DATATYPE)
        {
            *purpose = _parse_two_byte_integer(record->data);
        }
        else if(record->recordtype == XY)
        {
            *points = _parse_points_xy(record->data, record->length - 4);
            *size = (record->length - 4) / 4;
        }
        else if(record->recordtype == PROPATTR)
        {
            // FIXME: handle record
        }
        else if(record->recordtype == PROPVALUE)
        {
            // FIXME: handle record
        }
        else if(record->recordtype == ENDEL)
        {
            break;
        }
        else // wrong record
        {
            fprintf(stderr, "malformed BOUNDARY, got unexpected record '%s' (#%zd)\n", _recordname(record->recordtype), stream->index);
            return 0;
        }
    }
    return readlayer;
}

//static void _write_BOUNDARY(FILE* cellfile, int16_t layer, int16_t purpose, const struct vector* points, const struct vector* gdslayermap)
static void _write_BOUNDARY(FILE* cellfile, int16_t layer, int16_t purpose, const coordinate_t* points, size_t numxy, const struct vector* gdslayermap)
{
    // check for rectangle
    // BOX is not used for rectangles, at least most tool suppliers seem to do it this way
    // therefor, we check if some "polygons" are actually rectangles and fix the shape types
    //if(vector_size(points) == 5 && _check_rectangle(points))
    if(numxy == 10 && _check_rectangle(points))
    {
        fputs("    geometry.rectanglebltr(cell, ", cellfile);
        _write_layers(cellfile, layer, purpose, gdslayermap);
        coordinate_t blx, bly, trx, try;
        _rectangle_coordinates(points, &blx, &bly, &trx, &try);
        fputs(", point.create(", cellfile);
        _print_int32(cellfile, blx);
        fputs(", ", cellfile);
        _print_int32(cellfile, bly);
        fputs("), point.create(", cellfile);
        _print_int32(cellfile, trx);
        fputs(", ", cellfile);
        _print_int32(cellfile, try);
        fputs("))\n", cellfile);
    }
    else
    {
        fputs("    geometry.polygon(cell, ", cellfile);
        _write_layers(cellfile, layer, purpose, gdslayermap);
        fputs(", { ", cellfile);
        for(unsigned int i = 0; i < numxy; i += 2)
        {
            fputs("point.create(", cellfile);
            _print_int32(cellfile, points[i]);
            fputs(", ", cellfile);
            _print_int32(cellfile, points[i + 1]);
            fputs("), ", cellfile);
        }
        fputs("})\n", cellfile);
    }
}

static int _read_PATH(struct stream* stream, int16_t* layer, int16_t* purpose, struct vector** points, coordinate_t* width, coordinate_t* bgnext, coordinate_t* endext, int16_t* type)
{
    int readlayer = 0;
    while(1)
    {
        struct record* record = _get_next_record(stream);
        if(!record)
        {
            puts("gdsparser: end of stream while reading PATH");
            return 0;
        }
        if(record->recordtype == ELFLAGS)
        {
            // FIXME: handle record
        }
        else if(record->recordtype == PLEX)
        {
            // FIXME: handle record
        }
        else if(record->recordtype == LAYER)
        {
            *layer = _parse_two_byte_integer(record->data);
            readlayer = 1;
        }
        else if(record->recordtype == DATATYPE)
        {
            *purpose = _parse_two_byte_integer(record->data);
        }
        else if(record->recordtype == PATHTYPE)
        {
            *type = _parse_two_byte_integer(record->data);
        }
        else if(record->recordtype == WIDTH)
        {
            *width = _parse_four_byte_integer(record->data);
        }
        else if(record->recordtype == BGNEXTN)
        {
            *bgnext = _parse_four_byte_integer(record->data);
        }
        else if(record->recordtype == ENDEXTN)
        {
            *endext = _parse_four_byte_integer(record->data);
        }
        else if(record->recordtype == XY)
        {
            *points = _parse_points(record->data, record->length - 4);
        }
        else if(record->recordtype == ENDEL)
        {
            break;
        }
        else // wrong record
        {
            fprintf(stderr, "malformed PATH, got unexpected record '%s' (#%zd)\n", _recordname(record->recordtype), stream->index);
            return 0;
        }
    }
    return readlayer;
}

static void _write_PATH(FILE* cellfile, int16_t layer, int16_t purpose, const struct vector* points, coordinate_t width, coordinate_t bgnext, coordinate_t endext, int16_t type, const struct vector* gdslayermap)
{
    fputs("    geometry.path(cell, ", cellfile);
    _write_layers(cellfile, layer, purpose, gdslayermap);
    fputs(", { ", cellfile);
    for(unsigned int i = 0; i < vector_size(points); ++i)
    {
        const struct point* pt = vector_get_const(points, i);
        fprintf(cellfile, "point.create(%lld, %lld), ", pt->x, pt->y);
    }
    if(type == 0)
    {
        fprintf(cellfile, "}, %lld)\n", width);
    }
    else if(type == 1)
    {
        // no support for round path endings, ignore
        fprintf(cellfile, "}, %lld)\n", width);
    }
    else if(type == 2)
    {
        fprintf(cellfile, "}, %lld, \"rect\")\n", width);
    }
    else if(type == 4)
    {
        if(bgnext > 0 || endext > 0)
        {
            if(bgnext == endext)
            {
                fprintf(cellfile, "}, %lld, %lld)\n", width, bgnext);
            }
            else
            {
                fprintf(cellfile, "}, %lld, { %lld, %lld })\n", width, bgnext, endext);
            }
        }
        else
        {
            fprintf(cellfile, "}, %lld)\n", width);
        }
    }
}

static int _is_toplevel(const char* name, const struct const_vector* toplevelcells)
{
    struct const_vector_iterator* it = const_vector_iterator_create(toplevelcells);
    while(const_vector_iterator_is_valid(it))
    {
        const struct hierarchy_cellref* toplevelcell = const_vector_iterator_get(it);
        const char* toplevelname = toplevelcell->name;
        if(strcmp(name, toplevelname) == 0)
        {
            const_vector_iterator_destroy(it);
            return 1;
        }
        const_vector_iterator_next(it);
    }
    const_vector_iterator_destroy(it);
    return 0;
}

static int _read_structure(
    const char* libname,
    const char* importname,
    struct stream* stream,
    const struct const_vector* toplevelcells,
    const struct const_vector* cellnames,
    const struct vector* gdslayermap,
    const struct vector* ignorelpp,
    int16_t* ablayer, int16_t* abpurpose
)
{
    TIMEPERF_START();
    FILE* cellfile = NULL;
    while(1)
    {
        struct record* record = _get_next_record(stream);
        if(!record)
        {
            puts("gdsparser: end of stream while reading structure");
            if(cellfile)
            {
                fclose(cellfile);
            }
            return 0;
        }
        if(record->recordtype == STRNAME)
        {
            if(cellfile)
            {
                puts("spurious STRNAME in structure (already read the structure name)");
                fclose(cellfile);
                return 0;
            }
            char* cellname = _parse_string(record->data, record->length - 4);
            if(!cellname)
            {
                puts("gdsparser: could not parse/create cell name string");
                return 0;
            }
            size_t len = strlen(libname) + strlen(importname) + strlen(cellname) + 6; // +2: 2 * '/' + ".lua"
            char* path = malloc(len + 1);
            snprintf(path, len + 1, "%s/%s/%s.lua", libname, importname, cellname);
            cellfile = fopen(path, "w");
            if(!cellfile)
            {
                printf("gdsparser: could not open cell file '%s'\n", path);
                free(path);
                free(cellname);
                return 0;
            }
            free(path);
            if(_is_toplevel(cellname, toplevelcells))
            {
                fputs("function layout(cell)\n", cellfile);
                fputs("    local env = { references = {} }\n", cellfile);
                struct const_vector_iterator* it = const_vector_iterator_create(cellnames);
                while(const_vector_iterator_is_valid(it))
                {
                    const char* cellrefname = const_vector_iterator_get(it);
                    fprintf(cellfile, "    env.references[\"%s\"] = cell:create_object_handle(pcell.create_layout_env(\"%s/%s\", \"%s\", nil, env))\n", cellrefname, importname, cellrefname, cellrefname); // FIXME: gds has no instance names, is this a problem?
                    const_vector_iterator_next(it);
                }
                const_vector_iterator_destroy(it);
            }
            else
            {
                fputs("function layout(cell, _P, env)\n", cellfile);
            }
            free(cellname);
            fputs("    local ref, child\n", cellfile);
        }
        else if(record->recordtype == STRCLASS)
        {
            // FIXME: handle record
        }
        else if(record->recordtype == ENDSTR)
        {
            break;
        }
        else if(record->recordtype == BOUNDARY)
        {
            if(!cellfile)
            {
                puts("gdsparser: found BOUNDARY, but outside of structure");
                return 0;
            }
            int16_t layer, purpose;
            //struct vector* points = NULL;
            coordinate_t* points = NULL;
            size_t numpoints = 0;
            if(!_read_BOUNDARY(stream, &layer, &purpose, &points, &numpoints))
            {
                free(points);
                fclose(cellfile);
                puts("gdsparser: errors while reading BOUNDARY");
                return 0;
            }
            if(_check_lpp(layer, purpose, ignorelpp))
            {
                _write_BOUNDARY(cellfile, layer, purpose, points, numpoints, gdslayermap);
            }
            // alignment box
            if(ablayer && abpurpose && layer == *ablayer && purpose == *abpurpose && numpoints >= 8)
            {
                coordinate_t abblx, abbly, abtrx, abtry;
                _rectangle_coordinates(points, &abblx, &abbly, &abtrx, &abtry);
                fprintf(cellfile, "    cell:set_alignment_box(point.create(%lld, %lld), point.create(%lld, %lld))\n", abblx, abbly, abtrx, abtry);
            }
            free(points);
        }
        else if(record->recordtype == BOX)
        {
            // FIXME: handle record
        }
        else if(record->recordtype == PATH)
        {
            if(!cellfile)
            {
                puts("gdsparser: found PATH, but outside of structure");
                return 0;
            }
            int16_t layer, purpose;
            struct vector* points = NULL;
            coordinate_t width;
            coordinate_t bgnext = 0;
            coordinate_t endext = 0;
            int16_t type = 0;
            if(!_read_PATH(stream, &layer, &purpose, &points, &width, &bgnext, &endext, &type))
            {
                fclose(cellfile);
                puts("gdsparser: errors while reading PATH");
                return 0;
            }
            if(_check_lpp(layer, purpose, ignorelpp))
            {
                _write_PATH(cellfile, layer, purpose, points, width, bgnext, endext, type, gdslayermap);
            }
            vector_destroy(points);
        }
        else if(record->recordtype == TEXT)
        {
            if(!cellfile)
            {
                puts("gdsparser: found TEXT, but outside of structure");
                return 0;
            }
            int16_t layer, purpose;
            struct point origin;
            char* str = NULL;
            double angle = 0.0;
            int reflected = 0;
            int success = _read_TEXT(stream, &str, &layer, &purpose, &origin, &angle, &reflected);
            if(!success || !str)
            {
                free(str);
                fclose(cellfile);
                puts("gdsparser: error while reading TEXT");
                return 0;
            }
            if(_check_lpp(layer, purpose, ignorelpp))
            {
                fprintf(cellfile, "    cell:add_port_with_anchor(\"%s\", ", str);
                _write_layers(cellfile, layer, purpose, gdslayermap);
                fprintf(cellfile, ", point.create(%lld, %lld))\n", origin.x, origin.y);
            }
            free(str);
            (void) angle; // port rotation is currently not supported
            (void) reflected; // port transformation is currently not supported
        }
        else if(record->recordtype == SREF)
        {
            if(!cellfile)
            {
                puts("gdsparser: found SREF, but outside of structure");
                return 0;
            }
            struct cellref* cellref = _read_SREF(stream);
            if(cellref)
            {
                _write_cellref(cellfile, cellref);
                free(cellref);
            }
            else
            {
                fclose(cellfile);
                puts("gdsparser: error while reading SREF");
                return 0;
            }
        }
        else if(record->recordtype == AREF)
        {
            if(!cellfile)
            {
                puts("gdsparser: found AREF, but outside of structure");
                return 0;
            }
            struct cellref* cellref = _read_AREF(stream);
            if(cellref)
            {
                _write_cellref(cellfile, cellref);
                free(cellref);
            }
            else
            {
                fclose(cellfile);
                puts("gdsparser: error while reading AREF");
                return 0;
            }
        }
        else if(record->recordtype == PROPATTR)
        {
            // FIXME: handle record
        }
        else if(record->recordtype == PROPVALUE)
        {
            // FIXME: handle record
        }
        else if(record->recordtype == ENDEL)
        {
            break;
        }
        else // wrong record
        {
            fprintf(stderr, "structure: unexpected record '%s' (#%zd)\n", _recordname(record->recordtype), stream->index - 2);
            if(cellfile)
            {
                fclose(cellfile);
            }
            return 0;
        }
    }
    if(!cellfile)
    {
        puts("gdsparser: malformed structure");
        return 0;
    }
    fputs("end", cellfile); // close layout function
    fclose(cellfile);
    TIMEPERF_STOP();
    return 1;
}

static void _create_libdir(const char* libname, const char* importname)
{
    size_t len = strlen(libname) + strlen(importname) + 1; // +1: '/'
    char* path = malloc(len + 1);
    snprintf(path, len + 1, "%s/%s", libname, importname);
    filesystem_mkdir(path, 0755);
    free(path);
}

int gdsparser_read_stream(const char* filename, const char* importname, const struct vector* gdslayermap, const struct vector* ignorelpp, int16_t* ablayer, int16_t* abpurpose)
{
    TIMEPERF_START();
    // read gds in two passes
    // first: find names of top-level cell and all sub-cells
    // second: parse file and translate all structures
    // There is probably a more efficient way to do this,
    // but currently this process is not too slow, so it's fine for now

    // pass 1
    // FIXME: error handling
    struct stream* stream = _open_stream(filename);
    if(!stream)
    {
        return 0;
    }
    struct vector* cells = _read_cells(stream);
    if(!cells)
    {
        _destroy_stream(stream);
        return 0;
    }
    struct const_vector* toplevelcells = _get_toplevel_cells(cells);
    /*
    if(const_vector_size(toplevelcells) > 1)
    {
        puts("there is more than one toplevel cell. Specify which one should be used with --read-gds-toplevel-cellname");
        vector_destroy(cells);
        const_vector_destroy(toplevelcells);
        return 0;
    }
    */
    struct vector_iterator* it = vector_iterator_create(cells);
    struct const_vector* cellnames = const_vector_create(vector_size(cells));
    while(vector_iterator_is_valid(it))
    {
        const struct hierarchy_cellref* cell = vector_iterator_get(it);
        if(!_is_toplevel(cell->name, toplevelcells))
        {
            const_vector_append(cellnames, cell->name);
        }
        vector_iterator_next(it);
    }
    vector_iterator_destroy(it);

    // pass 2
    _reset_stream(stream);
    char* libname = NULL;
    while(1)
    {
        struct record* record = _get_next_record(stream);
        if(!record)
        {
            puts("gdsparser: end of stream before ENDLIB");
            free(libname);
            _destroy_stream(stream);
            vector_destroy(cells);
            const_vector_destroy(cellnames);
            const_vector_destroy(toplevelcells);
            return 0;
        }
        if(record->recordtype == LIBNAME)
        {
            if(libname)
            {
                puts("gdsparser: more than one LIBNAME entry");
                free(libname);
                _destroy_stream(stream);
                vector_destroy(cells);
                const_vector_destroy(cellnames);
                const_vector_destroy(toplevelcells);
                return 0;
            }
            libname = _parse_string(record->data, record->length - 4);
            if(!importname)
            {
                importname = libname;
            }
            _create_libdir(libname, importname);
        }
        else if(record->recordtype == BGNSTR)
        {
            if(!libname)
            {
                puts("gdsparser: GDSII stream does not start with a LIBNAME entry");
                _destroy_stream(stream);
                vector_destroy(cells);
                const_vector_destroy(cellnames);
                const_vector_destroy(toplevelcells);
                return 0;
            }
            if(!_read_structure(libname, importname, stream, toplevelcells, cellnames, gdslayermap, ignorelpp, ablayer, abpurpose))
            {
                puts("gdsparser: error while reading structure");
                free(libname);
                _destroy_stream(stream);
                vector_destroy(cells);
                const_vector_destroy(cellnames);
                const_vector_destroy(toplevelcells);
                return 0;
            }
        }
        else if(record->recordtype == ENDLIB)
        {
            if(!libname)
            {
                puts("gdsparser: GDSII stream does not start with a LIBNAME entry");
                _destroy_stream(stream);
                vector_destroy(cells);
                const_vector_destroy(cellnames);
                const_vector_destroy(toplevelcells);
                return 0;
            }
            break;
        }
    }
    _destroy_stream(stream);
    if(libname)
    {
        free(libname);
    }
    vector_destroy(cells);
    const_vector_destroy(cellnames);
    const_vector_destroy(toplevelcells);
    TIMEPERF_STOP();
    return 1;
}


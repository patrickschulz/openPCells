#include "gdsparser.h"

#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <string.h>
#include <assert.h>
#include <pthread.h>

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
#include "cpu.h"

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

#define NUM_RECORDNAMES (sizeof(recordnames) / sizeof(recordnames[0]))

static const char* _recordname(enum recordtypes recordtype)
{
    if((size_t)recordtype < NUM_RECORDNAMES)
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

// handles refilling the buffer and all errors, see _get_next_record for the common case
static struct record* _get_next_record_slow(struct stream* stream)
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

static inline struct record* _get_next_record(struct stream* stream)
{
    // fast path: the complete record is already in the buffer and valid
    size_t available = stream->end - stream->pos;
    if(available >= 4)
    {
        uint8_t* recordstart = stream->buffer + stream->pos;
        uint16_t length = (recordstart[0] << 8) | recordstart[1];
        if(length >= 4 && length <= available)
        {
            stream->current.length = length;
            stream->current.recordtype = recordstart[2];
            stream->current.datatype = recordstart[3];
            stream->current.data = recordstart + 4;
            stream->pos += length;
            ++stream->index;
            return &stream->current;
        }
    }
    return _get_next_record_slow(stream);
}

// file offset of the next record
static long long _stream_position(const struct stream* stream)
{
    return stream->bufferoffset + (long long)stream->pos;
}

// continue reading at the given file offset, which must be the start of a record
static int _seek_stream(struct stream* stream, long long offset)
{
    // long is 64 bits on the supported (Linux) platforms
    if(fseek(stream->file, (long)offset, SEEK_SET) != 0)
    {
        return 0;
    }
    stream->pos = 0;
    stream->end = 0;
    stream->bufferoffset = offset;
    stream->index = 0;
    return 1;
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

static void _parse_xy_i(uint8_t* data, size_t i, coordinate_t* xy)
{
    *xy = (int32_t)(((uint32_t)data[i * 4] << 24) | ((uint32_t)data[i * 4 + 1] << 16) | ((uint32_t)data[i * 4 + 2] << 8) | data[i * 4 + 3]);
}

// maximum number of coordinates (x and y counted separately) in one XY record: (65535 - 4) / 4
#define MAX_XY_COORDINATES 16382

// points must hold at least MAX_XY_COORDINATES entries
static void _parse_points_xy(uint8_t* data, size_t length, coordinate_t* points)
{
    for(size_t i = 0; i < length >> 2; ++i)
    {
        _parse_xy_i(data, i, points + i);
    }
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
    long long offset; // file offset of the first record after BGNSTR
    long long size; // number of bytes from offset up to and including ENDSTR
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

// if libname is not NULL, the LIBNAME entry is stored there (the caller has to free it)
static struct vector* _read_cells(struct stream* stream, char** libname)
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
        else if(record->recordtype == LIBNAME)
        {
            if(libname)
            {
                if(*libname)
                {
                    puts("gdsparser: more than one LIBNAME entry");
                    break;
                }
                *libname = _parse_string(record->data, record->length - 4);
            }
        }
        else if(record->recordtype == BGNSTR)
        {
            if(cell)
            {
                puts("gdsparser: BGNSTR inside of structure");
                break;
            }
            if(libname && !*libname)
            {
                puts("gdsparser: GDSII stream does not start with a LIBNAME entry");
                break;
            }
            cell = _make_hierarchy_cellref();
            cell->offset = _stream_position(stream);
        }
        else if(record->recordtype == ENDSTR)
        {
            if(!cell || !cell->name)
            {
                puts("gdsparser: ENDSTR outside of structure or structure without STRNAME");
                break;
            }
            cell->size = _stream_position(stream) - cell->offset;
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
            else if(libname && !*libname)
            {
                puts("gdsparser: GDSII stream does not start with a LIBNAME entry");
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
        if(libname)
        {
            free(*libname);
            *libname = NULL;
        }
    }
    TIMEPERF_STOP();
    return cells;
}


static struct const_vector* _get_toplevel_cells(struct vector* cells)
{
    TIMEPERF_START();
    // set of all referenced cell names (the values are unused)
    struct hashmap* referenced = hashmap_create(NULL);
    for(size_t i = 0; i < vector_size(cells); ++i)
    {
        const struct hierarchy_cellref* cell = vector_get_const(cells, i);
        for(size_t j = 0; j < vector_size(cell->references); ++j)
        {
            const char* refname = vector_get_const(cell->references, j);
            hashmap_insert(referenced, refname, NULL);
        }
    }

    struct const_vector* toplevelcells = const_vector_create(1);
    for(size_t i = 0; i < vector_size(cells); ++i)
    {
        const struct hierarchy_cellref* cell = vector_get_const(cells, i);
        if(!hashmap_exists(referenced, cell->name))
        {
            const_vector_append(toplevelcells, cell);
        }
    }
    hashmap_destroy(referenced);

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

static void _assemble_tree_element(const struct hashmap* cellmap, struct vector* tree, const struct hierarchy_cellref* cell, size_t level)
{
    struct vector_iterator* it = vector_iterator_create(cell->references);
    while(vector_iterator_is_valid(it))
    {
        const char* refname = vector_iterator_get(it);
        const struct hierarchy_cellref* sub = hashmap_get_const(cellmap, refname);
        if(sub) // references to cells not defined in this library are skipped
        {
            vector_append(tree, _make_tree_element(sub, level + 1));
            _assemble_tree_element(cellmap, tree, sub, level + 1);
        }
        vector_iterator_next(it);
    }
    vector_iterator_destroy(it);
}

static struct vector* _resolve_hierarchy(struct vector* cells)
{
    // cell name -> cell, for duplicate names the first cell is used
    struct hashmap* cellmap = hashmap_create(NULL);
    for(size_t i = 0; i < vector_size(cells); ++i)
    {
        struct hierarchy_cellref* cell = vector_get(cells, i);
        if(!hashmap_exists(cellmap, cell->name))
        {
            hashmap_insert(cellmap, cell->name, cell);
        }
    }
    struct const_vector* toplevelcells = _get_toplevel_cells(cells);
    struct vector* tree = vector_create(1, _destroy_tree_element);
    struct const_vector_iterator* it = const_vector_iterator_create(toplevelcells);
    while(const_vector_iterator_is_valid(it))
    {
        const struct hierarchy_cellref* cell = const_vector_iterator_get(it);
        vector_append(tree, _make_tree_element(cell, 0));
        _assemble_tree_element(cellmap, tree, cell, 0);
        const_vector_iterator_next(it);
    }
    const_vector_iterator_destroy(it);
    const_vector_destroy(toplevelcells);
    hashmap_destroy(cellmap);
    return tree;
}

void gdsparser_show_cell_hierarchy(const char* filename, size_t depth)
{
    struct stream* stream = _open_stream(filename);
    if(!stream)
    {
        return;
    }
    struct vector* cells = _read_cells(stream, NULL);
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
// must hold the data text of one complete integer record, which is reserved at once:
// the largest is a two-byte integer record with 32765 values of at most 7 characters ("-32768 "), 229355 bytes
#define OUTBUFFER_SIZE (1 << 18)

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

// make sure that at least 'len' bytes can be written to out->data + out->pos without checks
static inline void _out_reserve(struct outbuffer* out, size_t len)
{
    if(out->pos + len > OUTBUFFER_SIZE)
    {
        _flush_outbuffer(out);
    }
}

// writes the digits to ptr without any bounds checks (at most 10 characters), returns the end of the written digits
static inline char* _write_uint32(char* ptr, uint32_t num)
{
    // digits are written from the back, two at a time
    char* end = ptr + _count_digits(num);
    ptr = end;
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
    return end;
}

// writes the number to ptr without any bounds checks (at most 11 characters), returns the end of the written characters
static inline char* _write_int32(char* ptr, int32_t num)
{
    if(num < 0)
    {
        *ptr = '-';
        ++ptr;
        // negate in unsigned arithmetic, -INT32_MIN is not representable as int32_t
        return _write_uint32(ptr, 0u - (uint32_t)num);
    }
    return _write_uint32(ptr, num);
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

// for string literals, the length is known at compile time
#define _out_literal(out, str) _out_bytes(out, str, sizeof(str) - 1)

static void _out_string(struct outbuffer* out, const char* str)
{
    _out_bytes(out, str, strlen(str));
}

static void _out_int32(struct outbuffer* out, int32_t num)
{
    _out_reserve(out, 11);
    char* end = _write_int32(out->data + out->pos, num);
    out->pos = end - out->data;
}

static void _out_coordinate(struct outbuffer* out, coordinate_t num)
{
    // values read from GDS fit into 32 bits, only derived values (e.g. array pitches) can be larger
    if(num >= INT32_MIN && num <= INT32_MAX)
    {
        _out_int32(out, (int32_t)num);
    }
    else
    {
        // "-9223372036854775808" plus terminating zero
        _out_reserve(out, 21);
        out->pos += snprintf(out->data + out->pos, 21, "%lld", num);
    }
}

// the buffer itself is reused for the next cell file
static void _close_cellfile(struct outbuffer* out)
{
    _flush_outbuffer(out);
    fclose(out->file);
    out->file = NULL;
}

// the record header ("<indent><name> (<length>)[ -> data: ]") is written with fixed-size copies,
// which the compiler turns into a few stores instead of library calls;
// the bytes written beyond the actual text are overwritten afterwards
struct recordprefix {
    char text[16]; // "<name> (", the longest one is "PRESENTATION (" with 14 characters
    size_t len;
};

static void _show_record(struct outbuffer* out, const struct record* record, unsigned int* indent, const struct recordprefix* prefixes, int raw)
{
    static const char spaces[] = "                "; // 16 spaces, indentation is at most 12 for valid streams
    static const char suffix[] = ") -> data:      "; // padded to 16 characters
    if(record->recordtype == ENDLIB || record->recordtype == ENDSTR || record->recordtype == ENDEL)
    {
        --(*indent);
    }
    if(*indent > 3) // only possible for malformed streams
    {
        _out_fill(out, ' ', 4 * *indent);
    }
    // 12 (indentation) + 16 (prefix copy) + 5 (length) + 16 (suffix copy) = 49
    _out_reserve(out, 64);
    char* ptr = out->data + out->pos;
    if(*indent <= 3)
    {
        memcpy(ptr, spaces, 16);
        ptr += 4 * *indent;
    }
    size_t prefixindex = (size_t)record->recordtype < NUM_RECORDNAMES ? (size_t)record->recordtype : NUM_RECORDNAMES;
    memcpy(ptr, prefixes[prefixindex].text, 16);
    ptr += prefixes[prefixindex].len;
    ptr = _write_uint32(ptr, record->length);
    memcpy(ptr, suffix, 16);
    ptr += record->length > 4 ? 11 : 1; // ") -> data: " or ")"
    out->pos = ptr - out->data;

    // print data
    if(record->length > 4)
    {
        // parsed data
        switch(record->datatype)
        {
            case TWO_BYTE_INTEGER:
            {
                // reserve space for the whole record at once: at most 7 characters per number ("-32768 ")
                int numvalues = (record->length - 4) / 2;
                _out_reserve(out, numvalues * 7);
                char* ptr = out->data + out->pos;
                for(int i = 0; i < numvalues; ++i)
                {
                    ptr = _write_int32(ptr, _parse_two_byte_integer(record->data + i * 2));
                    *ptr = ' ';
                    ++ptr;
                }
                out->pos = ptr - out->data;
                break;
            }
            case FOUR_BYTE_INTEGER:
            {
                // reserve space for the whole record at once: at most 12 characters per number ("-2147483648 ")
                int numvalues = (record->length - 4) / 4;
                _out_reserve(out, numvalues * 12);
                char* ptr = out->data + out->pos;
                for(int i = 0; i < numvalues; ++i)
                {
                    ptr = _write_int32(ptr, _parse_four_byte_integer(record->data + i * 4));
                    *ptr = ' ';
                    ++ptr;
                }
                out->pos = ptr - out->data;
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
        ++(*indent);
    }
}

// gdsparser_show_records runs as a two-stage pipeline: a reader thread reads the file into blocks
// that contain only complete records, the calling thread formats them
#define RECORDBLOCK_SIZE (1 << 20) // must be larger than the maximum record length (65535 bytes)
#define NUM_RECORDBLOCKS 4

struct recordblock {
    uint8_t* data;
    size_t size; // number of bytes of complete records in data
    int last; // no further blocks follow (ENDLIB, end of file or error)
    int error; // stream ended before ENDLIB or contained an invalid record
    long long errorbyte;
};

struct recordqueue {
    FILE* file;
    struct recordblock blocks[NUM_RECORDBLOCKS];
    size_t head; // next block to be formatted
    size_t count; // number of blocks that are ready to be formatted
    pthread_mutex_t mutex;
    pthread_cond_t filled;
    pthread_cond_t emptied;
};

static void* _read_record_blocks(void* arg)
{
    struct recordqueue* queue = arg;
    uint8_t* carry = malloc(65535); // incomplete record at the end of a block, moved to the next block
    size_t carrylen = 0;
    long long fileoffset = 0; // file offset of the start of the current block
    size_t tail = 0;
    while(1)
    {
        pthread_mutex_lock(&queue->mutex);
        while(queue->count == NUM_RECORDBLOCKS)
        {
            pthread_cond_wait(&queue->emptied, &queue->mutex);
        }
        pthread_mutex_unlock(&queue->mutex);

        // the block at tail is not used by the formatting thread until it is published below
        struct recordblock* block = &queue->blocks[tail];
        memcpy(block->data, carry, carrylen);
        size_t requested = RECORDBLOCK_SIZE - carrylen;
        size_t read = fread(block->data + carrylen, 1, requested, queue->file);
        size_t filled = carrylen + read;
        block->last = 0;
        block->error = 0;
        size_t pos = 0;
        while(pos + 4 <= filled)
        {
            const uint8_t* header = block->data + pos;
            uint16_t length = (header[0] << 8) | header[1];
            if(length < 4)
            {
                block->last = 1;
                block->error = 1;
                block->errorbyte = fileoffset + pos + 4;
                break;
            }
            if(pos + length > filled) // incomplete record
            {
                break;
            }
            pos += length;
            if(header[2] == ENDLIB) // don't read beyond ENDLIB, streams are often padded with zeros
            {
                block->last = 1;
                break;
            }
        }
        block->size = pos;
        if(!block->last && read < requested) // end of file (or read error) before ENDLIB
        {
            block->last = 1;
            block->error = 1;
            block->errorbyte = fileoffset + filled;
        }
        if(!block->last)
        {
            carrylen = filled - pos;
            memcpy(carry, block->data + pos, carrylen);
            fileoffset += pos;
        }

        pthread_mutex_lock(&queue->mutex);
        ++queue->count;
        pthread_cond_signal(&queue->filled);
        pthread_mutex_unlock(&queue->mutex);

        if(block->last)
        {
            break;
        }
        tail = (tail + 1) % NUM_RECORDBLOCKS;
    }
    free(carry);
    return NULL;
}

int gdsparser_show_records(const char* filename, int raw)
{
    TIMEPERF_START();
    FILE* file = fopen(filename, "rb");
    if(!file)
    {
        fprintf(stderr, "gdsparser: could not open file '%s'\n", filename);
        return 0;
    }

    struct recordqueue queue;
    queue.file = file;
    for(size_t i = 0; i < NUM_RECORDBLOCKS; ++i)
    {
        queue.blocks[i].data = malloc(RECORDBLOCK_SIZE);
    }
    queue.head = 0;
    queue.count = 0;
    pthread_mutex_init(&queue.mutex, NULL);
    pthread_cond_init(&queue.filled, NULL);
    pthread_cond_init(&queue.emptied, NULL);
    pthread_t reader;
    if(pthread_create(&reader, NULL, _read_record_blocks, &queue) != 0)
    {
        fputs("gdsparser: could not create reader thread\n", stderr);
        for(size_t i = 0; i < NUM_RECORDBLOCKS; ++i)
        {
            free(queue.blocks[i].data);
        }
        pthread_mutex_destroy(&queue.mutex);
        pthread_cond_destroy(&queue.filled);
        pthread_cond_destroy(&queue.emptied);
        fclose(file);
        return 0;
    }

    struct recordprefix prefixes[NUM_RECORDNAMES + 1]; // the last entry is for unknown record types
    for(size_t i = 0; i <= NUM_RECORDNAMES; ++i)
    {
        const char* name = i < NUM_RECORDNAMES ? recordnames[i] : "UNKNOWN";
        size_t len = strlen(name);
        memset(prefixes[i].text, 0, 16);
        memcpy(prefixes[i].text, name, len);
        memcpy(prefixes[i].text + len, " (", 2);
        prefixes[i].len = len + 2;
    }

    struct outbuffer* out = _create_outbuffer(stdout);
    unsigned int indent = 0;
    int success = 1;
    while(1)
    {
        pthread_mutex_lock(&queue.mutex);
        while(queue.count == 0)
        {
            pthread_cond_wait(&queue.filled, &queue.mutex);
        }
        pthread_mutex_unlock(&queue.mutex);

        struct recordblock* block = &queue.blocks[queue.head];
        size_t pos = 0;
        while(pos < block->size)
        {
            struct record record;
            const uint8_t* header = block->data + pos;
            record.length = (header[0] << 8) | header[1];
            record.recordtype = header[2];
            record.datatype = header[3];
            record.data = block->data + pos + 4;
            _show_record(out, &record, &indent, prefixes, raw);
            pos += record.length;
        }
        int last = block->last;
        if(block->error)
        {
            fprintf(stderr, "gdsparser: stream abort before ENDLIB (at byte %lld)\n", block->errorbyte);
            success = 0;
        }

        pthread_mutex_lock(&queue.mutex);
        queue.head = (queue.head + 1) % NUM_RECORDBLOCKS;
        --queue.count;
        pthread_cond_signal(&queue.emptied);
        pthread_mutex_unlock(&queue.mutex);

        if(last)
        {
            break;
        }
    }
    pthread_join(reader, NULL);

    _destroy_outbuffer(out);
    for(size_t i = 0; i < NUM_RECORDBLOCKS; ++i)
    {
        free(queue.blocks[i].data);
    }
    pthread_mutex_destroy(&queue.mutex);
    pthread_cond_destroy(&queue.filled);
    pthread_cond_destroy(&queue.emptied);
    fclose(file);
    if(success)
    {
        TIMEPERF_STOP();
    }
    return success;
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
    struct point origin;
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
    for(size_t i = 0; i < vector_size(layermap); ++i)
    {
        const struct layermapping* mapping = vector_get_const(layermap, i);
        if(layer == mapping->layer && purpose == mapping->purpose && mapping->map)
        {
            return mapping->map;
        }
    }
    return NULL;
}

int _check_lpp(int16_t layer, int16_t purpose, const struct vector* ignorelpp)
{
    if(ignorelpp)
    {
        for(size_t i = 0; i < vector_size(ignorelpp); ++i)
        {
            const int16_t* lpp = vector_get_const(ignorelpp, i);
            if(layer == lpp[0] && purpose == lpp[1])
            {
                return 0;
            }
        }
    }
    return 1;
}

// layer/purpose pairs for which a "no mapping" warning was already printed, shared by all threads
struct warnedpairs {
    pthread_mutex_t mutex;
    uint32_t* keys;
    size_t size;
    size_t capacity;
};

static void _init_warnedpairs(struct warnedpairs* warned)
{
    pthread_mutex_init(&warned->mutex, NULL);
    warned->keys = NULL;
    warned->size = 0;
    warned->capacity = 0;
}

static void _destroy_warnedpairs(struct warnedpairs* warned)
{
    pthread_mutex_destroy(&warned->mutex);
    free(warned->keys);
}

// returns 1 if the pair was not marked before (only called once per pair and thread, so a linear search is fine)
static int _mark_warned(struct warnedpairs* warned, uint32_t key)
{
    pthread_mutex_lock(&warned->mutex);
    int isnew = 1;
    for(size_t i = 0; i < warned->size; ++i)
    {
        if(warned->keys[i] == key)
        {
            isnew = 0;
            break;
        }
    }
    if(isnew)
    {
        if(warned->size == warned->capacity)
        {
            warned->capacity = warned->capacity ? 2 * warned->capacity : 16;
            warned->keys = realloc(warned->keys, warned->capacity * sizeof(*warned->keys));
        }
        warned->keys[warned->size] = key;
        ++warned->size;
    }
    pthread_mutex_unlock(&warned->mutex);
    return isnew;
}

// The layer expression written for a shape and whether the shape is ignored only depend on its layer/purpose pair.
// Both are computed once per pair and kept in a small hash table, as files usually have only a few hundred pairs.
struct layercacheentry {
    uint32_t key;
    int used;
    int ignored;
    char* text; // layer expression, NULL for ignored pairs
    size_t len;
};

struct layercache {
    struct layercacheentry* entries;
    size_t capacity; // power of two
    size_t size;
    const struct vector* layermap;
    const struct vector* ignorelpp;
    struct warnedpairs* warned; // can be NULL, then every missing mapping is reported by this cache
};

static struct layercache* _create_layercache(const struct vector* layermap, const struct vector* ignorelpp, struct warnedpairs* warned)
{
    struct layercache* cache = malloc(sizeof(*cache));
    cache->capacity = 64;
    cache->size = 0;
    cache->entries = calloc(cache->capacity, sizeof(*cache->entries));
    cache->layermap = layermap;
    cache->ignorelpp = ignorelpp;
    cache->warned = warned;
    return cache;
}

static void _destroy_layercache(struct layercache* cache)
{
    for(size_t i = 0; i < cache->capacity; ++i)
    {
        free(cache->entries[i].text);
    }
    free(cache->entries);
    free(cache);
}

static size_t _layercache_index(uint32_t key, size_t capacity)
{
    return (size_t)(((uint64_t)key * 0x9E3779B97F4A7C15ull) >> 32) & (capacity - 1);
}

static void _append_text(struct layercacheentry* entry, const char* text, size_t len)
{
    entry->text = realloc(entry->text, entry->len + len + 1);
    memcpy(entry->text + entry->len, text, len);
    entry->len += len;
    entry->text[entry->len] = 0;
}

static void _append_number(struct layercacheentry* entry, int32_t num)
{
    char str[11];
    char* end = _write_int32(str, num);
    _append_text(entry, str, end - str);
}

#define _append_literal(entry, str) _append_text(entry, str, sizeof(str) - 1)

static void _build_layercache_entry(struct layercacheentry* entry, int16_t layer, int16_t purpose, const struct layercache* cache)
{
    entry->ignored = !_check_lpp(layer, purpose, cache->ignorelpp);
    entry->text = NULL;
    entry->len = 0;
    if(entry->ignored)
    {
        return;
    }
    const char* directmap = _has_direct_mapping(layer, purpose, cache->layermap);
    if(directmap)
    {
        _append_text(entry, directmap, strlen(directmap));
        return;
    }
    _append_literal(entry, "generics.premapped(nil, { gds = { layer = ");
    _append_number(entry, layer);
    _append_literal(entry, ", purpose = ");
    _append_number(entry, purpose);
    _append_literal(entry, " }");
    if(cache->layermap)
    {
        int foundmapping = 0;
        for(size_t j = 0; j < vector_size(cache->layermap); ++j)
        {
            const struct layermapping* mapping = vector_get_const(cache->layermap, j);
            if(layer == mapping->layer && purpose == mapping->purpose)
            {
                foundmapping = 1;
                for(unsigned int i = 0; i < mapping->num; ++i)
                {
                    _append_literal(entry, ", ");
                    _append_text(entry, mapping->mappings[i], strlen(mapping->mappings[i]));
                }
            }
        }
        // reported once per layer/purpose pair
        if(!foundmapping && (!cache->warned || _mark_warned(cache->warned, entry->key)))
        {
            fprintf(stderr, "read GDS: layermap is present, but no mapping was found for layer (%d, %d)\n", layer, purpose);
        }
    }
    _append_literal(entry, " })");
}

static void _grow_layercache(struct layercache* cache)
{
    struct layercacheentry* old = cache->entries;
    size_t oldcapacity = cache->capacity;
    cache->capacity *= 2;
    cache->entries = calloc(cache->capacity, sizeof(*cache->entries));
    for(size_t i = 0; i < oldcapacity; ++i)
    {
        if(old[i].used)
        {
            size_t index = _layercache_index(old[i].key, cache->capacity);
            while(cache->entries[index].used)
            {
                index = (index + 1) & (cache->capacity - 1);
            }
            cache->entries[index] = old[i];
        }
    }
    free(old);
}

static const struct layercacheentry* _get_layer(struct layercache* cache, int16_t layer, int16_t purpose)
{
    uint32_t key = ((uint32_t)(uint16_t)layer << 16) | (uint16_t)purpose;
    size_t index = _layercache_index(key, cache->capacity);
    while(cache->entries[index].used)
    {
        if(cache->entries[index].key == key)
        {
            return &cache->entries[index];
        }
        index = (index + 1) & (cache->capacity - 1);
    }
    // new pair, keep the load factor below 1/2
    if(2 * (cache->size + 1) > cache->capacity)
    {
        _grow_layercache(cache);
        index = _layercache_index(key, cache->capacity);
        while(cache->entries[index].used)
        {
            index = (index + 1) & (cache->capacity - 1);
        }
    }
    struct layercacheentry* entry = &cache->entries[index];
    entry->used = 1;
    entry->key = key;
    _build_layercache_entry(entry, layer, purpose, cache);
    ++cache->size;
    return entry;
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

// fills cellref, on success the caller has to free cellref->name
static int _read_SREF_AREF(struct stream* stream, int isAREF, struct cellref* cellref)
{
    cellref->name = NULL;
    cellref->origin.x = 0;
    cellref->origin.y = 0;
    cellref->xrep = 1;
    cellref->yrep = 1;
    cellref->angle = 0.0;
    cellref->reflected = 0;
    while(1)
    {
        struct record* record = _get_next_record(stream);
        if(!record)
        {
            free(cellref->name);
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
            _parse_single_point_i(record->data, 0, &cellref->origin);
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
            free(cellref->name);
            return 0;
        }
    }
    if(!cellref->name)
    {
        fputs("malformed SREF/AREF, missing SNAME\n", stderr);
        return 0;
    }
    return 1;
}
#define _read_SREF(stream, cellref) _read_SREF_AREF(stream, 0, cellref)
#define _read_AREF(stream, cellref) _read_SREF_AREF(stream, 1, cellref)

static void _write_cellref(struct outbuffer* out, const struct cellref* cellref)
{
    _out_literal(out, "    ref = env.references[\"");
    _out_string(out, cellref->name);
    _out_literal(out, "\"]\n");
    if(cellref->xrep > 1 || cellref->yrep > 1)
    {
        _out_literal(out, "    child = cell:add_child_array(ref, \"");
        _out_string(out, cellref->name);
        _out_literal(out, "\", ");
        _out_int32(out, cellref->xrep);
        _out_literal(out, ", ");
        _out_int32(out, cellref->yrep);
        _out_literal(out, ", ");
        _out_coordinate(out, cellref->xpitch);
        _out_literal(out, ", ");
        _out_coordinate(out, cellref->ypitch);
        _out_literal(out, ")\n");
    }
    else
    {
        _out_literal(out, "    child = cell:add_child(ref)\n");
    }
    if(cellref->angle == 90)
    {
        _out_literal(out, "    child:rotate_90_left()\n");
    }
    else if(cellref->angle == 180)
    {
        _out_literal(out, "    child:rotate_90_left()\n");
        _out_literal(out, "    child:rotate_90_left()\n");
    }
    else if(cellref->angle == 270)
    {
        _out_literal(out, "    child:rotate_90_left()\n");
        _out_literal(out, "    child:rotate_90_left()\n");
        _out_literal(out, "    child:rotate_90_left()\n");
    }
    if(cellref->reflected)
    {
        _out_literal(out, "    child:mirror_at_xaxis()\n");
    }
    if(!(cellref->origin.x == 0 && cellref->origin.y == 0))
    {
        _out_literal(out, "    child:translate(");
        _out_coordinate(out, cellref->origin.x);
        _out_literal(out, ", ");
        _out_coordinate(out, cellref->origin.y);
        _out_literal(out, ")\n");
    }
    free(cellref->name);
}

// points must hold at least MAX_XY_COORDINATES entries
static int _read_BOUNDARY(struct stream* stream, int16_t* layer, int16_t* purpose, coordinate_t* points, size_t* size)
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
            _parse_points_xy(record->data, record->length - 4, points);
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

// for string literals, writes to ptr without bounds checks and returns the end of the written characters
#define _write_literal(ptr, str) (memcpy(ptr, str, sizeof(str) - 1), (ptr) + sizeof(str) - 1)

static void _write_BOUNDARY(struct outbuffer* out, const struct layercacheentry* layer, const coordinate_t* points, size_t numxy)
{
    // check for rectangle
    // BOX is not used for rectangles, at least most tool suppliers seem to do it this way
    // therefor, we check if some "polygons" are actually rectangles and fix the shape types
    if(numxy == 10 && _check_rectangle(points))
    {
        _out_literal(out, "    geometry.rectanglebltr(cell, ");
        _out_bytes(out, layer->text, layer->len);
        coordinate_t blx, bly, trx, try;
        _rectangle_coordinates(points, &blx, &bly, &trx, &try);
        // ", point.create(" (15) + 4 numbers (4 * 11) + ", " (2) + "), point.create(" (16) + ", " (2) + "))\n" (3) = 82
        _out_reserve(out, 82);
        char* ptr = out->data + out->pos;
        ptr = _write_literal(ptr, ", point.create(");
        ptr = _write_int32(ptr, blx);
        ptr = _write_literal(ptr, ", ");
        ptr = _write_int32(ptr, bly);
        ptr = _write_literal(ptr, "), point.create(");
        ptr = _write_int32(ptr, trx);
        ptr = _write_literal(ptr, ", ");
        ptr = _write_int32(ptr, try);
        ptr = _write_literal(ptr, "))\n");
        out->pos = ptr - out->data;
    }
    else
    {
        _out_literal(out, "    geometry.polygon(cell, ");
        _out_bytes(out, layer->text, layer->len);
        _out_literal(out, ", { ");
        for(size_t i = 0; i + 1 < numxy; i += 2)
        {
            // "point.create(" (13) + 2 numbers (2 * 11) + ", " (2) + "), " (3) = 40
            _out_reserve(out, 40);
            char* ptr = out->data + out->pos;
            ptr = _write_literal(ptr, "point.create(");
            ptr = _write_int32(ptr, points[i]);
            ptr = _write_literal(ptr, ", ");
            ptr = _write_int32(ptr, points[i + 1]);
            ptr = _write_literal(ptr, "), ");
            out->pos = ptr - out->data;
        }
        _out_literal(out, "})\n");
    }
}

// points must hold at least MAX_XY_COORDINATES entries
static int _read_PATH(struct stream* stream, int16_t* layer, int16_t* purpose, coordinate_t* points, size_t* size, coordinate_t* width, coordinate_t* bgnext, coordinate_t* endext, int16_t* type)
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
            _parse_points_xy(record->data, record->length - 4, points);
            *size = (record->length - 4) / 4;
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

static void _write_PATH(struct outbuffer* out, const struct layercacheentry* layer, const coordinate_t* points, size_t numxy, coordinate_t width, coordinate_t bgnext, coordinate_t endext, int16_t type)
{
    _out_literal(out, "    geometry.path(cell, ");
    _out_bytes(out, layer->text, layer->len);
    _out_literal(out, ", { ");
    for(size_t i = 0; i + 1 < numxy; i += 2)
    {
        _out_literal(out, "point.create(");
        _out_coordinate(out, points[i]);
        _out_literal(out, ", ");
        _out_coordinate(out, points[i + 1]);
        _out_literal(out, "), ");
    }
    if(type == 0)
    {
        _out_literal(out, "}, ");
        _out_coordinate(out, width);
        _out_literal(out, ")\n");
    }
    else if(type == 1)
    {
        // no support for round path endings, ignore
        _out_literal(out, "}, ");
        _out_coordinate(out, width);
        _out_literal(out, ")\n");
    }
    else if(type == 2)
    {
        _out_literal(out, "}, ");
        _out_coordinate(out, width);
        _out_literal(out, ", \"rect\")\n");
    }
    else if(type == 4)
    {
        if(bgnext > 0 || endext > 0)
        {
            if(bgnext == endext)
            {
                _out_literal(out, "}, ");
                _out_coordinate(out, width);
                _out_literal(out, ", ");
                _out_coordinate(out, bgnext);
                _out_literal(out, ")\n");
            }
            else
            {
                _out_literal(out, "}, ");
                _out_coordinate(out, width);
                _out_literal(out, ", { ");
                _out_coordinate(out, bgnext);
                _out_literal(out, ", ");
                _out_coordinate(out, endext);
                _out_literal(out, " })\n");
            }
        }
        else
        {
            _out_literal(out, "}, ");
            _out_coordinate(out, width);
            _out_literal(out, ")\n");
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
    struct layercache* layercache,
    int16_t* ablayer, int16_t* abpurpose,
    coordinate_t* xybuffer, // scratch buffer for XY records, at least MAX_XY_COORDINATES entries
    struct outbuffer* outbuffer // reused for every cell file
)
{
    struct outbuffer* out = NULL;
    while(1)
    {
        struct record* record = _get_next_record(stream);
        if(!record)
        {
            puts("gdsparser: end of stream while reading structure");
            if(out)
            {
                _close_cellfile(out);
            }
            return 0;
        }
        if(record->recordtype == STRNAME)
        {
            if(out)
            {
                puts("spurious STRNAME in structure (already read the structure name)");
                _close_cellfile(out);
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
            FILE* cellfile = fopen(path, "w");
            if(!cellfile)
            {
                printf("gdsparser: could not open cell file '%s'\n", path);
                free(path);
                free(cellname);
                return 0;
            }
            free(path);
            out = outbuffer;
            out->file = cellfile;
            out->pos = 0;
            if(_is_toplevel(cellname, toplevelcells))
            {
                _out_literal(out, "function layout(cell)\n");
                _out_literal(out, "    local env = { references = {} }\n");
                struct const_vector_iterator* it = const_vector_iterator_create(cellnames);
                while(const_vector_iterator_is_valid(it))
                {
                    const char* cellrefname = const_vector_iterator_get(it);
                    // FIXME: gds has no instance names, is this a problem?
                    _out_literal(out, "    env.references[\"");
                    _out_string(out, cellrefname);
                    _out_literal(out, "\"] = cell:create_object_handle(pcell.create_layout_env(\"");
                    _out_string(out, importname);
                    _out_literal(out, "/");
                    _out_string(out, cellrefname);
                    _out_literal(out, "\", \"");
                    _out_string(out, cellrefname);
                    _out_literal(out, "\", nil, env))\n");
                    const_vector_iterator_next(it);
                }
                const_vector_iterator_destroy(it);
            }
            else
            {
                _out_literal(out, "function layout(cell, _P, env)\n");
            }
            free(cellname);
            _out_literal(out, "    local ref, child\n");
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
            if(!out)
            {
                puts("gdsparser: found BOUNDARY, but outside of structure");
                return 0;
            }
            int16_t layer, purpose;
            coordinate_t* points = xybuffer;
            size_t numpoints = 0;
            if(!_read_BOUNDARY(stream, &layer, &purpose, points, &numpoints))
            {
                _close_cellfile(out);
                puts("gdsparser: errors while reading BOUNDARY");
                return 0;
            }
            const struct layercacheentry* layerentry = _get_layer(layercache, layer, purpose);
            if(!layerentry->ignored)
            {
                _write_BOUNDARY(out, layerentry, points, numpoints);
            }
            // alignment box
            if(ablayer && abpurpose && layer == *ablayer && purpose == *abpurpose && numpoints >= 8)
            {
                coordinate_t abblx, abbly, abtrx, abtry;
                _rectangle_coordinates(points, &abblx, &abbly, &abtrx, &abtry);
                _out_literal(out, "    cell:set_alignment_box(point.create(");
                _out_coordinate(out, abblx);
                _out_literal(out, ", ");
                _out_coordinate(out, abbly);
                _out_literal(out, "), point.create(");
                _out_coordinate(out, abtrx);
                _out_literal(out, ", ");
                _out_coordinate(out, abtry);
                _out_literal(out, "))\n");
            }
        }
        else if(record->recordtype == BOX)
        {
            // FIXME: handle record
        }
        else if(record->recordtype == PATH)
        {
            if(!out)
            {
                puts("gdsparser: found PATH, but outside of structure");
                return 0;
            }
            int16_t layer, purpose;
            coordinate_t* points = xybuffer;
            size_t numpoints = 0;
            coordinate_t width;
            coordinate_t bgnext = 0;
            coordinate_t endext = 0;
            int16_t type = 0;
            if(!_read_PATH(stream, &layer, &purpose, points, &numpoints, &width, &bgnext, &endext, &type))
            {
                _close_cellfile(out);
                puts("gdsparser: errors while reading PATH");
                return 0;
            }
            const struct layercacheentry* layerentry = _get_layer(layercache, layer, purpose);
            if(!layerentry->ignored)
            {
                _write_PATH(out, layerentry, points, numpoints, width, bgnext, endext, type);
            }
        }
        else if(record->recordtype == TEXT)
        {
            if(!out)
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
                _close_cellfile(out);
                puts("gdsparser: error while reading TEXT");
                return 0;
            }
            const struct layercacheentry* layerentry = _get_layer(layercache, layer, purpose);
            if(!layerentry->ignored)
            {
                _out_literal(out, "    cell:add_port_with_anchor(\"");
                _out_string(out, str);
                _out_literal(out, "\", ");
                _out_bytes(out, layerentry->text, layerentry->len);
                _out_literal(out, ", point.create(");
                _out_coordinate(out, origin.x);
                _out_literal(out, ", ");
                _out_coordinate(out, origin.y);
                _out_literal(out, "))\n");
            }
            free(str);
            (void) angle; // port rotation is currently not supported
            (void) reflected; // port transformation is currently not supported
        }
        else if(record->recordtype == SREF)
        {
            if(!out)
            {
                puts("gdsparser: found SREF, but outside of structure");
                return 0;
            }
            struct cellref cellref;
            if(_read_SREF(stream, &cellref))
            {
                _write_cellref(out, &cellref);
            }
            else
            {
                _close_cellfile(out);
                puts("gdsparser: error while reading SREF");
                return 0;
            }
        }
        else if(record->recordtype == AREF)
        {
            if(!out)
            {
                puts("gdsparser: found AREF, but outside of structure");
                return 0;
            }
            struct cellref cellref;
            if(_read_AREF(stream, &cellref))
            {
                _write_cellref(out, &cellref);
            }
            else
            {
                _close_cellfile(out);
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
            if(out)
            {
                _close_cellfile(out);
            }
            return 0;
        }
    }
    if(!out)
    {
        puts("gdsparser: malformed structure");
        return 0;
    }
    _out_literal(out, "end"); // close layout function
    _close_cellfile(out);
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

// the structures are translated by worker threads, each worker reads its structures with its own stream
#define THREADS_PER_CPU 1

struct structurejob {
    long long offset;
    long long size;
};

struct readcontext {
    // read-only for the workers
    const char* filename;
    const char* libname;
    const char* importname;
    const struct const_vector* toplevelcells;
    const struct const_vector* cellnames;
    const struct vector* gdslayermap;
    const struct vector* ignorelpp;
    int16_t* ablayer;
    int16_t* abpurpose;
    const struct structurejob* jobs;
    size_t numjobs;
    // shared, protected by mutex
    pthread_mutex_t mutex;
    size_t nextjob;
    int error;
    struct warnedpairs warned; // has its own mutex
};

static void _set_read_error(struct readcontext* context)
{
    pthread_mutex_lock(&context->mutex);
    context->error = 1;
    pthread_mutex_unlock(&context->mutex);
}

static void* _read_structures_thread(void* arg)
{
    struct readcontext* context = arg;
    struct stream* stream = _open_stream(context->filename);
    if(!stream)
    {
        _set_read_error(context);
        return NULL;
    }
    coordinate_t* xybuffer = malloc(MAX_XY_COORDINATES * sizeof(*xybuffer));
    struct outbuffer* outbuffer = _create_outbuffer(NULL);
    struct layercache* layercache = _create_layercache(context->gdslayermap, context->ignorelpp, &context->warned);
    while(1)
    {
        pthread_mutex_lock(&context->mutex);
        if(context->error || context->nextjob == context->numjobs)
        {
            pthread_mutex_unlock(&context->mutex);
            break;
        }
        const struct structurejob* job = &context->jobs[context->nextjob];
        ++context->nextjob;
        pthread_mutex_unlock(&context->mutex);

        if(!_seek_stream(stream, job->offset) ||
           !_read_structure(context->libname, context->importname, stream, context->toplevelcells, context->cellnames, layercache, context->ablayer, context->abpurpose, xybuffer, outbuffer))
        {
            puts("gdsparser: error while reading structure");
            _set_read_error(context);
            break;
        }
    }
    free(xybuffer);
    free(outbuffer); // all cell files are closed (and flushed) at this point
    _destroy_layercache(layercache);
    _destroy_stream(stream);
    return NULL;
}

static int _compare_jobs_by_size(const void* lhs, const void* rhs)
{
    long long l = ((const struct structurejob*)lhs)->size;
    long long r = ((const struct structurejob*)rhs)->size;
    // descending
    return (l < r) - (l > r);
}

int gdsparser_read_stream(const char* filename, const char* importname, const struct vector* gdslayermap, const struct vector* ignorelpp, int16_t* ablayer, int16_t* abpurpose)
{
    TIMEPERF_START();
    // read gds in two passes
    // first: find names, positions and sizes of all cells
    // second: translate all structures in parallel

    // pass 1
    struct stream* stream = _open_stream(filename);
    if(!stream)
    {
        return 0;
    }
    char* libname = NULL;
    struct vector* cells = _read_cells(stream, &libname);
    _destroy_stream(stream);
    if(!cells)
    {
        return 0;
    }
    struct const_vector* toplevelcells = _get_toplevel_cells(cells);
    struct const_vector* cellnames = const_vector_create(vector_size(cells));
    for(size_t i = 0; i < vector_size(cells); ++i)
    {
        const struct hierarchy_cellref* cell = vector_get_const(cells, i);
        if(!_is_toplevel(cell->name, toplevelcells))
        {
            const_vector_append(cellnames, cell->name);
        }
    }
    if(!importname)
    {
        importname = libname;
    }
    _create_libdir(libname, importname);

    // one job per structure, structures with the same name write the same file,
    // so only the last one is translated (as it would overwrite the others)
    struct hashmap* lastcell = hashmap_create(NULL);
    for(size_t i = 0; i < vector_size(cells); ++i)
    {
        struct hierarchy_cellref* cell = vector_get(cells, i);
        hashmap_insert(lastcell, cell->name, cell);
    }
    struct structurejob* jobs = malloc(vector_size(cells) * sizeof(*jobs) + 1);
    size_t numjobs = 0;
    for(size_t i = 0; i < vector_size(cells); ++i)
    {
        const struct hierarchy_cellref* cell = vector_get_const(cells, i);
        if(hashmap_get_const(lastcell, cell->name) == cell)
        {
            jobs[numjobs].offset = cell->offset;
            jobs[numjobs].size = cell->size;
            ++numjobs;
        }
    }
    hashmap_destroy(lastcell);
    // start with the largest structures, so that a large structure does not end up running alone at the end
    qsort(jobs, numjobs, sizeof(*jobs), _compare_jobs_by_size);

    // pass 2
    struct readcontext context;
    context.filename = filename;
    context.libname = libname;
    context.importname = importname;
    context.toplevelcells = toplevelcells;
    context.cellnames = cellnames;
    context.gdslayermap = gdslayermap;
    context.ignorelpp = ignorelpp;
    context.ablayer = ablayer;
    context.abpurpose = abpurpose;
    context.jobs = jobs;
    context.numjobs = numjobs;
    pthread_mutex_init(&context.mutex, NULL);
    context.nextjob = 0;
    context.error = 0;
    _init_warnedpairs(&context.warned);

    size_t numthreads = THREADS_PER_CPU * cpu_get_num_cpus();
    if(numthreads > numjobs)
    {
        numthreads = numjobs;
    }
    pthread_t* threads = malloc(numthreads * sizeof(*threads) + 1);
    size_t numstarted = 0;
    for(size_t i = 0; i < numthreads; ++i)
    {
        if(pthread_create(&threads[numstarted], NULL, _read_structures_thread, &context) != 0)
        {
            break; // continue with the threads that could be started
        }
        ++numstarted;
    }
    if(numstarted == 0 && numjobs > 0)
    {
        _read_structures_thread(&context);
    }
    for(size_t i = 0; i < numstarted; ++i)
    {
        pthread_join(threads[i], NULL);
    }
    int success = !context.error;

    free(threads);
    _destroy_warnedpairs(&context.warned);
    pthread_mutex_destroy(&context.mutex);
    free(jobs);
    free(libname);
    vector_destroy(cells);
    const_vector_destroy(cellnames);
    const_vector_destroy(toplevelcells);
    if(success)
    {
        TIMEPERF_STOP();
    }
    return success;
}


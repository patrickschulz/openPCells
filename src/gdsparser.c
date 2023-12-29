#include "gdsparser.h"

#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <string.h>
#include <assert.h>

#include "lua/lauxlib.h"

#include "math.h"
#include "filesystem.h"
#include "vector.h"
#include "point.h"
#include "hashmap.h"
#include "lua_util.h"
#include "util.h"

enum datatypes
{
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

struct record
{
    uint16_t length;
    enum recordtypes recordtype;
    uint8_t datatype;
    uint8_t* data;
};

int _read_record(FILE* file, struct record* record)
{
    uint8_t buf[4];
    size_t read;
    read = fread(buf, 1, 4, file);
    if(read != 4)
    {
        return 0;
    }
    record->length = (buf[0] << 8) + buf[1];
    record->recordtype = buf[2];
    record->datatype = buf[3];

    if(record->length >= 4)
    {
        size_t numbytes = record->length - 4;
        uint8_t* data = malloc(numbytes);
        read = fread(data, 1, numbytes, file);
        if(read != numbytes)
        {
            free(data);
            return 0;
        }
        record->data = data;
        return 1;
    }
    else
    {
        return 0;
    }
}

struct stream {
    struct record* records;
    size_t numrecords;
    size_t index;
};

static void _destroy_stream(struct stream* stream)
{
    for(unsigned int i = 0; i < stream->numrecords; ++i)
    {
        free(stream->records[i].data);
    }
    free(stream->records);
    free(stream);
}

static struct record* _get_next_record(struct stream* stream)
{
    if(stream->index >= stream->numrecords)
    {
        return NULL;
    }
    ++stream->index;
    return stream->records + stream->index - 1;
}

static int _read_raw_stream_noerror(const char* filename, struct stream** stream, long* errorbyte)
{
    FILE* file = fopen(filename, "r");
    if(!file)
    {
        return 0;
    }
    size_t numrecords = 0;
    size_t capacity = 10;
    struct record* records = calloc(capacity, sizeof(*records));
    int ret = 1;
    while(1)
    {
        if(numrecords + 1 > capacity)
        {
            capacity *= 2;
            struct record* tmp = realloc(records, capacity * sizeof(*tmp));
            records = tmp;
        }
        if(!_read_record(file, &records[numrecords]))
        {
            ret = 0;
            *errorbyte = ftell(file);
            break;
        }
        ++numrecords;
        if(records[numrecords - 1].recordtype == ENDLIB)
        {
            break;
        }
    }
    fclose(file);
    (*stream) = malloc(sizeof(struct stream));
    (*stream)->records = records;
    (*stream)->numrecords = numrecords;
    (*stream)->index = 0;
    return ret;
}

static struct stream* _read_raw_stream(const char* filename)
{
    struct stream* stream = NULL;
    long errorbyte = 0;
    int status = _read_raw_stream_noerror(filename, &stream, &errorbyte);
    if(!status)
    {
        fprintf(stderr, "gdsparser: stream abort before ENDLIB (at byte %ld)\n", errorbyte);
        _destroy_stream(stream);
        return NULL;
    }
    return stream;
}

static int* _parse_bit_array(uint8_t* data)
{
    int* pdata = calloc(16, sizeof(*pdata));
    for(int j = 0; j < 8; ++j)
    {
        pdata[j] = (data[0] & (1 << (8 - j - 1))) >> (8 - j - 1);
    }
    for(int j = 0; j < 8; ++j)
    {
        pdata[j + 8] = (data[1] & (1 << (8 - j - 1))) >> (8 - j - 1);
    }
    return pdata;
}

static int16_t* _parse_two_byte_integer(uint8_t* data, size_t length)
{
    int16_t* pdata = calloc(length / 2, sizeof(*pdata));
    for(size_t i = 0; i < length / 2; ++i)
    {
        pdata[i] = (data[i * 2] << 8) + data[i * 2 + 1];
    }
    return pdata;
}

static int32_t* _parse_four_byte_integer(uint8_t* data, size_t length)
{
    int32_t* pdata = calloc(length / 4, sizeof(*pdata));
    for(size_t i = 0; i < length / 4; ++i)
    {
        pdata[i] = (data[i * 4] << 24) + (data[i * 4 + 1] << 16) + (data[i * 4 + 2] << 8) + data[i * 4 + 3];
    }
    return pdata;
}

static inline void _parse_single_point_i(uint8_t* data, size_t i, point_t* pt)
{
    pt->x = (data[i * 8] << 24) + (data[i * 8 + 1] << 16) + (data[i * 8 + 2] << 8) + data[i * 8 + 3];
    pt->y = (data[i * 8 + 4] << 24) + (data[i * 8 + 5] << 16) + (data[i * 8 + 6] << 8) + data[i * 8 + 7];
}

static struct vector* _parse_points(uint8_t* data, size_t length)
{
    struct vector* points = vector_create(length >> 3, point_destroy);
    for(size_t i = 0; i < length >> 3; ++i)
    {
        point_t* pt = point_create(0, 0);
        _parse_single_point_i(data, i, pt);
        vector_append(points, pt);
    }
    return points;
}

static void _parse_xy_i(uint8_t* data, size_t i, coordinate_t* xy)
{
    *xy = (data[i * 4] << 24) + (data[i * 4 + 1] << 16) + (data[i * 4 + 2] << 8) + data[i * 4 + 3];
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

static double* _parse_four_byte_real(uint8_t* data, size_t length)
{
    double* pdata = calloc(length / 4, sizeof(*pdata));
    for(size_t i = 0; i < length / 4; ++i)
    {
        int sign = data[i * 4] & 0x80;
        int8_t exp = data[i * 4] & 0x7f;
        double mantissa = data[i * 4 + 1] / 256.0
            + data[i * 4 + 2] / 256.0 / 256.0
            + data[i * 4 + 3] / 256.0 / 256.0 / 256.0;
        if(sign)
        {
            pdata[i] = -mantissa * pow(16.0, exp - 64);
        }
        else
        {
            pdata[i] = mantissa * pow(16.0, exp - 64);
        }
    }
    return pdata;
}

static double* _parse_eight_byte_real(uint8_t* data, size_t length)
{
    double* pdata = calloc(length / 8, sizeof(*pdata));
    for(size_t i = 0; i < length / 8; ++i)
    {
        int sign = data[i * 8] & 0x80;
        int8_t exp = data[i * 8] & 0x7f;
        double mantissa = data[i * 8 + 1] / 256.0
                        + data[i * 8 + 2] / 256.0 / 256.0
                        + data[i * 8 + 3] / 256.0 / 256.0 / 256.0
                        + data[i * 8 + 4] / 256.0 / 256.0 / 256.0 / 256.0
                        + data[i * 8 + 5] / 256.0 / 256.0 / 256.0 / 256.0 / 256.0
                        + data[i * 8 + 6] / 256.0 / 256.0 / 256.0 / 256.0 / 256.0 / 256.0
                        + data[i * 8 + 7] / 256.0 / 256.0 / 256.0 / 256.0 / 256.0 / 256.0 / 256.0;
        if(sign)
        {
            pdata[i] = -mantissa * pow(16.0, exp - 64);
        }
        else
        {
            pdata[i] = mantissa * pow(16.0, exp - 64);
        }
    }
    return pdata;
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

static int lgdsparser_read_raw_stream(lua_State* L)
{
    const char* filename = lua_tostring(L, 1);
    struct stream* stream = _read_raw_stream(filename);
    if(!stream)
    {
        lua_pushnil(L);
        lua_pushstring(L, "could not read stream");
        return 2;
    }
    lua_newtable(L);
    for(size_t i = 0; i < stream->numrecords; ++i)
    {
        struct record* record = &stream->records[i];
        lua_newtable(L);

        // header
        lua_pushstring(L, "header");
        lua_newtable(L);

        lua_pushstring(L, "length");
        lua_pushinteger(L, record->length);
        lua_rawset(L, -3);

        lua_pushstring(L, "recordtype");
        lua_pushinteger(L, record->recordtype);
        lua_rawset(L, -3);

        lua_pushstring(L, "datatype");
        lua_pushinteger(L, record->datatype);
        lua_rawset(L, -3);

        lua_rawset(L, -3);

        // data
        // FIXME: use existing functions to parse gds data
        switch(record->datatype)
        {
            case BIT_ARRAY:
                lua_pushstring(L, "data");
                lua_newtable(L);
                for(int j = 0; j < 8; ++j)
                {
                    lua_pushinteger(L, (record->data[0] & (1 << j)) >> j);
                    lua_rawseti(L, -2, j + 1);
                }
                for(int j = 0; j < 8; ++j)
                {
                    lua_pushinteger(L, (record->data[1] & (1 << j)) >> j);
                    lua_rawseti(L, -2, j + 8 + 1);
                }
                lua_rawset(L, -3);
                break;
            case TWO_BYTE_INTEGER:
                if((record->length - 4) / 2 > 1)
                {
                    lua_pushstring(L, "data");
                    lua_newtable(L);
                    for(int j = 0; j < (record->length - 4) / 2; ++j)
                    {
                        int16_t num = (record->data[j * 2]     << 8) 
                                    + (record->data[j * 2 + 1] << 0);
                        lua_pushinteger(L, num);
                        lua_rawseti(L, -2, j + 1);
                    }
                    lua_rawset(L, -3);
                }
                else
                {
                    lua_pushstring(L, "data");
                    int16_t num = (record->data[0] << 8) 
                                + (record->data[1] << 0);
                    lua_pushinteger(L, num);
                    lua_rawset(L, -3);
                }
                break;
            case FOUR_BYTE_INTEGER:
                if((record->length - 4) / 4 > 1)
                {
                    lua_pushstring(L, "data");
                    lua_newtable(L);
                    for(int j = 0; j < (record->length - 4) / 4; ++j)
                    {
                        int32_t num = (record->data[j * 4]     << 24) 
                                    + (record->data[j * 4 + 1] << 16) 
                                    + (record->data[j * 4 + 2] <<  8) 
                                    + (record->data[j * 4 + 3] <<  0);
                        lua_pushinteger(L, num);
                        lua_rawseti(L, -2, j + 1);
                    }
                    lua_rawset(L, -3);
                }
                else
                {
                    lua_pushstring(L, "data");
                    int32_t num = (record->data[0] << 24) 
                                + (record->data[1] << 16) 
                                + (record->data[2] <<  8) 
                                + (record->data[3] <<  0);
                    lua_pushinteger(L, num);
                    lua_rawset(L, -3);
                }
                break;
            case FOUR_BYTE_REAL:
                lua_pushstring(L, "data");
                if((record->length - 4) / 4 > 1)
                {
                    lua_newtable(L);
                }
                for(int j = 0; j < (record->length - 4) / 4; ++j)
                {
                    int sign = record->data[j * 4] & 0x80;
                    int8_t exp = record->data[j * 4] & 0x7f;
                    double mantissa = record->data[j * 4 + 1] / 256.0
                                    + record->data[j * 4 + 2] / 256.0 / 256.0
                                    + record->data[j * 4 + 3] / 256.0 / 256.0 / 256.0;
                    if(sign)
                    {
                        lua_pushnumber(L, -mantissa * pow(16.0, exp - 64));
                    }
                    else
                    {
                        lua_pushnumber(L, mantissa * pow(16.0, exp - 64));
                    }
                    if((record->length - 4) / 4 > 1)
                    {
                        lua_rawseti(L, -2, j + 1);
                    }
                }
                lua_rawset(L, -3);
                break;
            case EIGHT_BYTE_REAL:
                lua_pushstring(L, "data");
                if((record->length - 4) / 8 > 1)
                {
                    lua_newtable(L);
                }
                for(int j = 0; j < (record->length - 4) / 8; ++j)
                {
                    int sign = record->data[j * 8] & 0x80;
                    int8_t exp = record->data[j * 8] & 0x7f;
                    double mantissa = record->data[j * 8 + 1] / 256.0
                                    + record->data[j * 8 + 2] / 256.0 / 256.0
                                    + record->data[j * 8 + 3] / 256.0 / 256.0 / 256.0
                                    + record->data[j * 8 + 4] / 256.0 / 256.0 / 256.0 / 256.0
                                    + record->data[j * 8 + 5] / 256.0 / 256.0 / 256.0 / 256.0 / 256.0
                                    + record->data[j * 8 + 6] / 256.0 / 256.0 / 256.0 / 256.0 / 256.0 / 256.0
                                    + record->data[j * 8 + 7] / 256.0 / 256.0 / 256.0 / 256.0 / 256.0 / 256.0 / 256.0;
                    if(sign)
                    {
                        lua_pushnumber(L, -mantissa * pow(16.0, exp - 64));
                    }
                    else
                    {
                        lua_pushnumber(L, mantissa * pow(16.0, exp - 64));
                    }
                    if((record->length - 4) / 8 > 1)
                    {
                        lua_rawseti(L, -2, j + 1);
                    }
                }
                lua_rawset(L, -3);
                break;
            case ASCII_STRING:
                if(((char*)record->data)[record->length - 4 - 1] == 0)
                {
                    lua_pushstring(L, "data");
                    lua_pushlstring(L, (char*)record->data, record->length - 4 - 1);
                    lua_rawset(L, -3);
                }
                else
                {
                    lua_pushstring(L, "data");
                    lua_pushlstring(L, (char*)record->data, record->length - 4);
                    lua_rawset(L, -3);
                }
                break;
        }

        lua_rawseti(L, -2, i + 1);
    }
    _destroy_stream(stream);
    return 1;
}

int gdsparser_show_records(const char* filename, int raw)
{
    struct stream* stream = NULL;
    long errorbyte = 0;
    int status = _read_raw_stream_noerror(filename, &stream, &errorbyte);
    if(!status)
    {
        printf("show GDSII records: stream abort before ENDLIB (at byte %ld)\n", errorbyte);
        return 0;
    }

    unsigned int indent = 0;
    while(1)
    {
        struct record* record = _get_next_record(stream);
        if(!record)
        {
            _destroy_stream(stream);
            return 0;
        }
        if(record->recordtype == ENDLIB || record->recordtype == ENDSTR || record->recordtype == ENDEL)
        {
            --indent;
        }
        for(size_t i = 0; i < 4 * indent; ++i)
        {
            putchar(' ');
        }
        printf("%s (%d)", recordnames[record->recordtype], record->length);

        // print data
        if(record->length > 4)
        {
            fputs(" -> data: ", stdout);
            // parsed data
            switch(record->datatype)
            {
                case TWO_BYTE_INTEGER:
                {
                    int16_t* pdata = _parse_two_byte_integer(record->data, record->length - 4);
                    for(int i = 0; i < (record->length - 4) / 2; ++i)
                    {
                        int16_t num = pdata[i];
                        printf("%d ", num);
                    }
                    free(pdata);
                    break;
                }
                case FOUR_BYTE_INTEGER:
                {
                    int32_t* pdata = _parse_four_byte_integer(record->data, record->length - 4);
                    for(int i = 0; i < (record->length - 4) / 4; ++i)
                    {
                        int32_t num = pdata[i];
                        printf("%d ", num);
                    }
                    free(pdata);
                    break;
                }
                case FOUR_BYTE_REAL:
                {
                    double* pdata = _parse_four_byte_real(record->data, record->length - 4);
                    for(int i = 0; i < (record->length - 4) / 4; ++i)
                    {
                        double num = pdata[i];
                        printf("%g ", num);
                    }
                    free(pdata);
                    break;
                }
                case EIGHT_BYTE_REAL:
                {
                    double* pdata = _parse_eight_byte_real(record->data, record->length - 4);
                    for(int i = 0; i < (record->length - 4) / 8; ++i)
                    {
                        double num = pdata[i];
                        printf("%g ", num);
                    }
                    free(pdata);
                    break;
                }
                case ASCII_STRING:
                    putchar('"');
                    for(int i = 0; i < record->length - 4; ++i)
                    {
                        char ch = ((char*)record->data)[i];
                        if(ch) // odd-length strings are zero padded, don't print that character
                        {
                            putchar(ch);
                        }
                    }
                    putchar('"');
                    break;
                case BIT_ARRAY:
                {
                    int* pdata = _parse_bit_array(record->data);
                    for(int i = 0; i < 16; ++i)
                    {
                        if(pdata[i])
                        {
                            putchar('1');
                        }
                        else
                        {
                            putchar('0');
                        }
                    }
                    free(pdata);
                    break;
                }
                default:
                    break;
            }
        }
        if(raw)
        {
            putchar(' ');
            putchar('(');
            for(int i = 0; i < record->length - 4; ++i)
            {
                printf("0x%02x", record->data[i]);
                if(i < record->length - 5)
                {
                    putchar(' ');
                }
            }
            putchar(')');
        }
        putchar('\n');

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
    _destroy_stream(stream);
    return 1;
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
        _print_int16(file, num / 10);
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

#define MAX2(a, b) ((a) > (b) ? (a) : (b))
#define MIN2(a, b) ((a) > (b) ? (b) : (a))
#define MAX4(a, b, c, d) MAX2(MAX2(a, b), MAX2(c, d))
#define MIN4(a, b, c, d) MIN2(MIN2(a, b), MIN2(c, d))

static void _rectangle_coordinates(const coordinate_t* points, coordinate_t* blx, coordinate_t* bly, coordinate_t* trx, coordinate_t* try)
{
    *blx = MIN4(points[0], points[2], points[4], points[6]);
    *bly = MIN4(points[1], points[3], points[5], points[7]);
    *trx = MAX4(points[0], points[2], points[4], points[6]);
    *try = MAX4(points[1], points[3], points[5], points[7]);
}

struct cellref {
    char* name;
    point_t* origin;
    int16_t xrep;
    int16_t yrep;
    int xpitch;
    int ypitch;
    int* transformation;
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

struct vector* gdsparser_create_layermap(const char* filename)
{
    if(!filename)
    {
        return NULL;
    }
    lua_State* L = util_create_minimal_lua_state();
    int ret = luaL_dofile(L, filename);
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
            layermapping->mappings = malloc(len * sizeof(*layermapping->mappings));
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
    lua_close(L);
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
                return 0;
            }
            vector_const_iterator_next(it);
        }
        vector_const_iterator_destroy(it);
    }
    return 1;
}

static int _read_TEXT(struct stream* stream, char** str, int16_t* layer, int16_t* purpose, point_t* origin, double* angle, int** transformation)
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
            int16_t* pdata = _parse_two_byte_integer(record->data, 2);
            *layer = *pdata;
            free(pdata);
            readlayer = 1;
        }
        else if(record->recordtype == TEXTTYPE)
        {
            int16_t* pdata = _parse_two_byte_integer(record->data, 2);
            *purpose = *pdata;
            free(pdata);
        }
        else if(record->recordtype == PRESENTATION)
        {
            // FIXME: handle record
        }
        else if(record->recordtype == STRANS)
        {
            *transformation = _parse_bit_array(record->data);
        }
        else if(record->recordtype == ANGLE)
        {
            double* pdata = _parse_eight_byte_real(record->data, record->length - 4);
            *angle = *pdata;
            free(pdata);
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
            *str = _parse_string(record->data, record->length - 4);
        }
        else if(record->recordtype == ENDEL)
        {
            break;
        }
        else // wrong record
        {
            fprintf(stderr, "malformed TEXT, got unexpected record '%s' (#%zd)\n", recordnames[record->recordtype], stream->index);
            return 0;
        }
    }
    return readlayer;
}

static struct cellref* _read_SREF_AREF(struct stream* stream, int isAREF)
{
    struct cellref* cellref = malloc(sizeof(*cellref));
    cellref->name = NULL;
    cellref->origin = point_create(0, 0);
    cellref->xrep = 1;
    cellref->yrep = 1;
    cellref->angle = 0.0;
    cellref->transformation = NULL;
    while(1)
    {
        struct record* record = _get_next_record(stream);
        if(!record)
        {
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
            cellref->name = _parse_string(record->data, record->length - 4);
        }
        else if(record->recordtype == STRANS)
        {
            cellref->transformation = _parse_bit_array(record->data);
        }
        else if(record->recordtype == ANGLE)
        {
            double* pdata = _parse_eight_byte_real(record->data, record->length - 4);
            cellref->angle = *pdata;
            free(pdata);
        }
        else if(record->recordtype == MAG)
        {
            // FIXME: handle record
        }
        else if(record->recordtype == COLROW)
        {
            int16_t* pdata = _parse_two_byte_integer(record->data, 4);
            cellref->xrep = pdata[0];
            cellref->yrep = pdata[1];
            free(pdata);
        }
        else if(record->recordtype == XY)
        {
            _parse_single_point_i(record->data, 0, cellref->origin);
            if(isAREF)
            {
                coordinate_t x1, y2;
                // coordinate words memory locations:
                // pt1: x [0] y [1]
                // pt2: x [2] y [3]
                // pt3: x [4] y [5]
                // for pitch, only x2 and y3 are needed
                _parse_xy_i(record->data, 2, &x1);
                _parse_xy_i(record->data, 5, &y2);
                cellref->xpitch = llabs(x1 - cellref->origin->x) / cellref->xrep;
                cellref->ypitch = llabs(y2 - cellref->origin->y) / cellref->yrep;
            }
        }
        else if(record->recordtype == ENDEL)
        {
            break;
        }
        else // wrong record
        {
            fprintf(stderr, "malformed SREF/AREF, got unexpected record '%s' (#%zd)\n", recordnames[record->recordtype], stream->index);
            return NULL;
        }
    }
    return cellref;
}
#define _read_SREF(stream) _read_SREF_AREF(stream, 0)
#define _read_AREF(stream) _read_SREF_AREF(stream, 1)

static void _write_cellref(FILE* cellfile, const char* importname, const struct cellref* cellref, struct hashmap* references)
{
    if(!hashmap_exists(references, cellref->name))
    {
        fprintf(cellfile, "    ref = pcell.create_layout(\"%s/%s\", \"%s\")\n", importname, cellref->name, cellref->name); // FIXME: gds has no instance names, is this a problem?
        hashmap_insert(references, cellref->name, NULL); // use hashmap as set (value == NULL)
    }
    if(cellref->xrep > 1 || cellref->yrep > 1)
    {
        fprintf(cellfile, "    child = cell:add_child_array(ref, \"%s\", %d, %d, %d, %d)\n", cellref->name, cellref->xrep, cellref->yrep, cellref->xpitch, cellref->ypitch);
    }
    else
    {
        fprintf(cellfile, "    child = cell:add_child(ref, \"%s\")\n", cellref->name);
    }
    if(cellref->transformation && cellref->transformation[0] == 1)
    {
        fputs("    child:mirror_at_xaxis()\n", cellfile);
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
    if(!(cellref->origin->x == 0 && cellref->origin->y == 0))
    {
        fprintf(cellfile, "    child:translate(%lld, %lld)\n", cellref->origin->x, cellref->origin->y);
    }
    free(cellref->name);
    point_destroy(cellref->origin);
    if(cellref->transformation)
    {
        free(cellref->transformation);
    }
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
            int16_t* pdata = _parse_two_byte_integer(record->data, 2);
            *layer = *pdata;
            free(pdata);
            readlayer = 1;
        }
        else if(record->recordtype == DATATYPE)
        {
            int16_t* pdata = _parse_two_byte_integer(record->data, 2);
            *purpose = *pdata;
            free(pdata);
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
            fprintf(stderr, "malformed BOUNDARY, got unexpected record '%s' (#%zd)\n", recordnames[record->recordtype], stream->index);
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

static int _read_PATH(struct stream* stream, int16_t* layer, int16_t* purpose, struct vector** points, coordinate_t* width)
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
            int16_t* pdata = _parse_two_byte_integer(record->data, 2);
            *layer = *pdata;
            free(pdata);
            readlayer = 1;
        }
        else if(record->recordtype == DATATYPE)
        {
            int16_t* pdata = _parse_two_byte_integer(record->data, 2);
            *purpose = *pdata;
            free(pdata);
        }
        else if(record->recordtype == PATHTYPE)
        {
            // FIXME: handle record
        }
        else if(record->recordtype == WIDTH)
        {
            int32_t* pdata = _parse_four_byte_integer(record->data, 4);
            *width = *pdata;
            free(pdata);
        }
        else if(record->recordtype == BGNEXTN)
        {
            // FIXME: handle record
        }
        else if(record->recordtype == ENDEXTN)
        {
            // FIXME: handle record
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
            fprintf(stderr, "malformed PATH, got unexpected record '%s' (#%zd)\n", recordnames[record->recordtype], stream->index);
            return 0;
        }
    }
    return readlayer;
}

static void _write_PATH(FILE* cellfile, int16_t layer, int16_t purpose, const struct vector* points, coordinate_t width, const struct vector* gdslayermap)
{
    fputs("    geometry.path(cell, ", cellfile);
    _write_layers(cellfile, layer, purpose, gdslayermap);
    fputs(", { ", cellfile);
    for(unsigned int i = 0; i < vector_size(points); ++i)
    {
        const point_t* pt = vector_get_const(points, i);
        fprintf(cellfile, "point.create(%lld, %lld), ", pt->x, pt->y);
    }
    fprintf(cellfile, "}, %lld)\n", width);
}

static int _read_structure(const char* libname, const char* importname, struct stream* stream, const struct vector* gdslayermap, const struct vector* ignorelpp, int16_t* ablayer, int16_t* abpurpose)
{
    FILE* cellfile = NULL;
    struct hashmap* references = hashmap_create();
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
                return 0;
            }
            size_t len = strlen(libname) + strlen(importname) + strlen(cellname) + 6; // +2: 2 * '/' + ".lua"
            char* path = malloc(len + 1);
            snprintf(path, len + 1, "%s/%s/%s.lua", libname, importname, cellname);
            cellfile = fopen(path, "w");
            free(cellname);
            free(path);
            if(!cellfile)
            {
                return 0;
            }
            fputs("function parameters() end\n", cellfile);
            fputs("function layout(cell)\n", cellfile);
            fputs("    local ref, name, child\n", cellfile);
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
                return 0;
            }
            if(_check_lpp(layer, purpose, ignorelpp))
            {
                _write_BOUNDARY(cellfile, layer, purpose, points, numpoints, gdslayermap);
            }
            // alignment box
            if(ablayer && abpurpose && layer == *ablayer && purpose == *abpurpose)
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
            if(!_read_PATH(stream, &layer, &purpose, &points, &width))
            {
                fclose(cellfile);
                return 0;
            }
            if(_check_lpp(layer, purpose, ignorelpp))
            {
                _write_PATH(cellfile, layer, purpose, points, width, gdslayermap);
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
            point_t origin;
            char* str;
            double angle = 0.0;
            int* transformation = NULL;
            int success = _read_TEXT(stream, &str, &layer, &purpose, &origin, &angle, &transformation);
            if(!success)
            {
                fclose(cellfile);
                return 0;
            }
            if(_check_lpp(layer, purpose, ignorelpp))
            {
                fprintf(cellfile, "    cell:add_port(\"%s\", ", str);
                _write_layers(cellfile, layer, purpose, gdslayermap);
                fprintf(cellfile, ", point.create(%lld, %lld))\n", origin.x, origin.y);
                free(str);
            }
            (void) transformation; // port transformation is currently not supported
            (void) angle; // port rotation is currently not supported
            if(transformation)
            {
                free(transformation);
            }
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
                _write_cellref(cellfile, importname, cellref, references);
                free(cellref);
            }
            else
            {
                fclose(cellfile);
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
                _write_cellref(cellfile, importname, cellref, references);
                free(cellref);
            }
            else
            {
                fclose(cellfile);
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
            printf("structure: unexpected record '%s' (#%zd)\n", recordnames[record->recordtype], stream->index - 2);
            if(cellfile)
            {
                fclose(cellfile);
            }
            return 0;
        }
    }
    hashmap_destroy(references, NULL);
    if(!cellfile)
    {
        puts("gdsparser: malformed structure");
        return 0;
    }
    fputs("end", cellfile); // close layout function
    fclose(cellfile);
    return 1;
}

static void _create_libdir(const char* libname, const char* importname)
{
    size_t len = strlen(libname) + strlen(importname) + 1; // +1: '/'
    char* path = malloc(len + 1);
    snprintf(path, len + 1, "%s/%s", libname, importname);
    filesystem_mkdir(path);
    free(path);
}

int gdsparser_read_stream(const char* filename, const char* importname, const struct vector* gdslayermap, const struct vector* ignorelpp, int16_t* ablayer, int16_t* abpurpose)
{
    const char* libname = NULL;
    struct stream* stream = _read_raw_stream(filename);
    if(!stream)
    {
        return 0;
    }

    while(1)
    {
        struct record* record = _get_next_record(stream);
        if(!record)
        {
            puts("gdsparser: end of stream before ENDLIB");
            _destroy_stream(stream);
            return 0;
        }
        if(record->recordtype == LIBNAME)
        {
            libname = (const char*)record->data;
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
                return 0;
            }
            if(!_read_structure(libname, importname, stream, gdslayermap, ignorelpp, ablayer, abpurpose))
            {
                puts("gdsparser: error while reading structure");
                _destroy_stream(stream);
                return 0;
            }
        }
        else if(record->recordtype == ENDLIB)
        {
            if(!libname)
            {
                puts("gdsparser: GDSII stream does not start with a LIBNAME entry");
                _destroy_stream(stream);
                return 0;
            }
            break;
        }
    }
    _destroy_stream(stream);
    return 1;
}

static int lgdsparser_show_records(lua_State* L)
{
    const char* filename = lua_tostring(L, 1);
    if(!gdsparser_show_records(filename, 0))
    {
        lua_pushnil(L);
        lua_pushstring(L, "could not read stream");
        return 2;
    }
    lua_pushboolean(L, 1);
    return 1;
}

int open_gdsparser_lib(lua_State* L)
{
    static const luaL_Reg modfuncs[] =
    {
        { "read_raw_stream", lgdsparser_read_raw_stream },
        { "show_records",    lgdsparser_show_records    },
        { NULL,              NULL                       }
    };
    lua_newtable(L);
    luaL_setfuncs(L, modfuncs, 0);
    lua_setglobal(L, "gdsparser");
    return 0;
}

#include "gdsparser.h"

#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <math.h>
#include <string.h>

#include "lua/lauxlib.h"

#include "filesystem.h"
#include "vector.h"
#include "point.h"
#include "hashmap.h"

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
    uint8_t recordtype;
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

    size_t numbytes = record->length - 4;
    uint8_t* data = malloc(numbytes);
    read = fread(data, 1, numbytes, file);
    if(read != numbytes)
    {
        return 0;
    }
    record->data = data;
    return 1;
}

struct stream
{
    struct record* records;
    size_t numrecords;
};

static struct stream* _read_raw_stream(const char* filename)
{
    FILE* file = fopen(filename, "r");
    if(!file)
    {
        return NULL;
    }
    size_t numrecords = 0;
    size_t capacity = 10;
    struct record* records = calloc(capacity, sizeof(*records));
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
            fprintf(stderr, "%s\n", "gdsparser: stream abort before ENDLIB");
            break;
        }
        ++numrecords;
        if(records[numrecords - 1].recordtype == ENDLIB)
        {
            break;
        }
    }
    fclose(file);
    struct stream* stream = malloc(sizeof(struct stream));
    stream->records = records;
    stream->numrecords = numrecords;
    return stream;
}

static void _destroy_stream(struct stream* stream)
{
    for(unsigned int i = 0; i < stream->numrecords; ++i)
    {
        free(stream->records[i].data);
    }
    free(stream->records);
    free(stream);
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
    return 1;
}

int gdsparser_show_records(const char* filename)
{
    struct stream* stream = _read_raw_stream(filename);
    if(!stream)
    {
        return 0;
    }
    unsigned int indent = 0;
    for(size_t i = 0; i < stream->numrecords; ++i)
    {
        struct record* record = &stream->records[i];
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

static void _print_int32(FILE* file, int32_t num)
{
    if(num < 0)
    {
        fputc('-', file);
        num *= -1;
    }
    if(num > 9)
    {
        _print_int32(file, num / 10);
    }
    fputc((num % 10) + '0', file);
}

#define MAX2(a, b) ((a) > (b) ? (a) : (b))
#define MIN2(a, b) ((a) > (b) ? (b) : (a))
#define MAX4(a, b, c, d) MAX2(MAX2(a, b), MAX2(c, d))
#define MIN4(a, b, c, d) MIN2(MIN2(a, b), MIN2(c, d))

struct _cellref
{
    char* name;
    point_t* origin;
    int16_t xrep;
    int16_t yrep;
    int xpitch;
    int ypitch;
    int* transformation;
    double angle;
};

int _check_rectangle(struct vector* points)
{
    return ((((point_t*)vector_get(points, 0))->y == ((point_t*)vector_get(points, 1))->y)  &&
            (((point_t*)vector_get(points, 1))->x == ((point_t*)vector_get(points, 2))->x)  &&
            (((point_t*)vector_get(points, 2))->y == ((point_t*)vector_get(points, 3))->y)  &&
            (((point_t*)vector_get(points, 3))->x == ((point_t*)vector_get(points, 4))->x)  &&
            (((point_t*)vector_get(points, 0))->x == ((point_t*)vector_get(points, 4))->x)  &&
            (((point_t*)vector_get(points, 0))->y == ((point_t*)vector_get(points, 4))->y)) ||
           ((((point_t*)vector_get(points, 0))->x == ((point_t*)vector_get(points, 1))->x)  &&
            (((point_t*)vector_get(points, 1))->y == ((point_t*)vector_get(points, 2))->y)  &&
            (((point_t*)vector_get(points, 2))->x == ((point_t*)vector_get(points, 3))->x)  &&
            (((point_t*)vector_get(points, 3))->y == ((point_t*)vector_get(points, 4))->y)  &&
            (((point_t*)vector_get(points, 0))->x == ((point_t*)vector_get(points, 4))->x)  &&
            (((point_t*)vector_get(points, 0))->y == ((point_t*)vector_get(points, 4))->y));
}

int gdsparser_read_stream(const char* filename, const char* importname)
{
    const char* libname;
    struct stream* stream = _read_raw_stream(filename);
    if(!stream)
    {
        return 0;
    }
    FILE* cellfile = NULL;
    int16_t layer;
    int16_t purpose;
    int32_t width;
    struct vector* points = NULL;
    uint8_t what;
    char* str;
    int16_t xrep, yrep;
    double angle = 0.0;
    struct vector* children = NULL;
    int* transformation = NULL;

    for(size_t i = 0; i < stream->numrecords; ++i)
    {
        struct record* record = &stream->records[i];
        if(record->recordtype == LIBNAME)
        {
            libname = (const char*)record->data;
            size_t len = strlen(importname) + strlen(importname) + 1; // +1: '/'
            char* path = malloc(len + 1);
            snprintf(path, len + 1, "%s/%s", importname, importname);
            filesystem_mkdir(path);
            free(path);
        }
        else if(record->recordtype == BGNSTR)
        {
            children = vector_create(32);
        }
        else if(record->recordtype == ENDSTR)
        {
            struct hashmap* references = hashmap_create();
            fputs("    local ref, name, child\n", cellfile);
            for(unsigned int i = 0; i < vector_size(children); ++i)
            {
                struct _cellref* cellref = vector_get(children, i);
                if(!hashmap_exists(references, cellref->name))
                {
                    fprintf(cellfile, "    ref = pcell.create_layout(\"%s/%s\")\n", importname, cellref->name);
                    fprintf(cellfile, "    name = pcell.add_cell_reference(ref, \"%s\")\n", cellref->name);
                    hashmap_insert(references, cellref->name, NULL); // use hashmap as set (value == NULL)
                }
                if(cellref->xrep > 1 || cellref->yrep > 1)
                {
                    fprintf(cellfile, "    child = cell:add_child_array(name, %d, %d, %d, %d)\n", cellref->xrep, cellref->yrep, cellref->xpitch, cellref->ypitch);
                }
                else
                {
                    fputs("    child = cell:add_child(name)\n", cellfile);
                }
                if(cellref->angle == 180)
                {
                    if(cellref->transformation && cellref->transformation[0] == 1)
                    {
                        fputs("    child:mirror_at_yaxis()\n", cellfile);
                    }
                    else
                    {
                        fputs("    child:mirror_at_yaxis()\n", cellfile);
                        fputs("    child:mirror_at_xaxis()\n", cellfile);
                    }
                }
                else if(cellref->angle == 90)
                {
                    fputs("    child:rotate_90_left()\n", cellfile);
                }
                else
                {
                    if(cellref->transformation && cellref->transformation[0] == 1)
                    {
                        fputs("    child:mirror_at_xaxis()\n", cellfile);
                    }
                }
                fprintf(cellfile, "    child:translate(%lld, %lld)\n", cellref->origin->x, cellref->origin->y);
                free(cellref->name);
                point_destroy(cellref->origin);
                if(cellref->transformation)
                {
                    free(cellref->transformation);
                }
            }
            hashmap_destroy(references, NULL);
            vector_destroy(children, NULL);
            children = NULL;
            fputs("end", cellfile); // close layout function
            fclose(cellfile);
        }
        else if(record->recordtype == STRNAME)
        {
            char* cellname = _parse_string(record->data, record->length - 4);
            size_t len = strlen(importname) + strlen(importname) + strlen(cellname) + 6; // +2: 2 * '/' + ".lua"
            char* path = malloc(len + 1);
            snprintf(path, len + 1, "%s/%s/%s.lua", importname, importname, cellname);
            cellfile = fopen(path, "w");
            fputs("function parameters() end\n", cellfile);
            fputs("function layout(cell)\n", cellfile);
            free(cellname);
            free(path);
        }
        else if(record->recordtype == BOUNDARY)
        {
            what = BOUNDARY;
            points = vector_create(32);
        }
        else if(record->recordtype == BOX)
        {
            // FIXME
        }
        else if(record->recordtype == PATH)
        {
            what = PATH;
            points = vector_create(32);
        }
        else if(record->recordtype == SREF)
        {
            what = SREF;
            points = vector_create(32);
        }
        else if(record->recordtype == AREF)
        {
            what = AREF;
            points = vector_create(32);
        }
        else if(record->recordtype == TEXT)
        {
            what = TEXT;
            points = vector_create(32);
        }
        else if(record->recordtype == ENDEL)
        {
            if(what == BOUNDARY)
            {
                // check for rectangles
                // BOX is not used for rectangles, at least most tool suppliers seem to do it this way
                // therefor, we check if some "polygons" are actually rectangles and fix the shape types
                if(vector_size(points) == 5 && _check_rectangle(points))
                {
                    // FIXME: the calls to MAX4 and MIN4 are terrible
                    fputs("    geometry.rectanglebltr(cell, generics.premapped(nil, { gds = { layer = ", cellfile);
                    _print_int16(cellfile, layer);
                    fputs(", purpose = ", cellfile);
                    _print_int16(cellfile, purpose);
                    fputs(" } }), point.create(", cellfile);
                    _print_int32(cellfile, MIN4(((point_t*)vector_get(points, 0))->x, ((point_t*)vector_get(points, 1))->x, ((point_t*)vector_get(points, 2))->x, ((point_t*)vector_get(points, 3))->x));
                    fputs(", ", cellfile);
                    _print_int32(cellfile, MIN4(((point_t*)vector_get(points, 0))->y, ((point_t*)vector_get(points, 1))->y, ((point_t*)vector_get(points, 2))->y, ((point_t*)vector_get(points, 3))->y));
                    fputs("), point.create(", cellfile);
                    _print_int32(cellfile, MAX4(((point_t*)vector_get(points, 0))->x, ((point_t*)vector_get(points, 1))->x, ((point_t*)vector_get(points, 2))->x, ((point_t*)vector_get(points, 3))->x));
                    fputs(", ", cellfile);
                    _print_int32(cellfile, MAX4(((point_t*)vector_get(points, 0))->y, ((point_t*)vector_get(points, 1))->y, ((point_t*)vector_get(points, 2))->y, ((point_t*)vector_get(points, 3))->y));
                    fputs("))\n", cellfile);
                }
                else
                {
                    fputs("geometry.polygon(cell, generics.premapped(nil, { gds = {", cellfile);
                    fputs("layer = ", cellfile);
                    _print_int16(cellfile, layer);
                    fputs(", purpose = ", cellfile);
                    _print_int16(cellfile, purpose);
                    fputs("} }), { ", cellfile);
                    for(unsigned int i = 0; i < vector_size(points); ++i)
                    {
                        point_t* pt = vector_get(points, i);
                        fputs("point.create(", cellfile);
                        _print_int32(cellfile, pt->x);
                        fputs(", ", cellfile);
                        _print_int32(cellfile, pt->y);
                        fputs("), ", cellfile);
                    }
                    fputs("})\n", cellfile);
                }
                vector_destroy(points, point_destroy);
            }
            if(what == PATH)
            {
                fprintf(cellfile, "    geometry.path(cell, generics.premapped(nil, { gds = { layer = %d, purpose = %d } }), { ", layer, purpose);
                for(unsigned int i = 0; i < vector_size(points); ++i)
                {
                    point_t* pt = vector_get(points, i);
                    fprintf(cellfile, "point.create(%lld, %lld), ", pt->x, pt->y);
                }
                fprintf(cellfile, "}, %d)\n", width);
                vector_destroy(points, point_destroy);
            }
            if(what == TEXT)
            {
                point_t* pt = vector_get(points, 0);
                fprintf(cellfile, "    cell:add_port(\"%s\", generics.premapped(nil, { gds = { layer = %d, purpose = %d } }), point.create(%lld, %lld))\n", str, layer, purpose, pt->x, pt->y);
                vector_destroy(points, point_destroy);
                free(str);
                if(transformation)
                {
                    free(transformation);
                }
                transformation = NULL;
            }
            if(what == SREF)
            {
                struct _cellref* cellref = malloc(sizeof(*cellref));
                // cellref takes ownership of str, point and transformation
                cellref->name = str;
                cellref->origin = vector_get(points, 0);
                cellref->xrep = 1;
                cellref->yrep = 1;
                cellref->angle = angle;
                cellref->transformation = transformation;
                vector_append(children, cellref);
                vector_destroy(points, NULL); // don't destroy point, it is now owned by cellref->origin
                transformation = NULL;
                angle = 0;
            }
            if(what == AREF)
            {
                struct _cellref* cellref = malloc(sizeof(*cellref));
                // cellref takes ownership of str, point and transformation
                cellref->name = str;
                cellref->origin = vector_get(points, 0);
                cellref->xrep = xrep;
                cellref->yrep = yrep;
                point_t* pt1 = vector_get(points, 1);
                point_t* pt2 = vector_get(points, 2);
                cellref->xpitch = llabs(pt1->x - cellref->origin->x) / cellref->xrep;
                cellref->ypitch = llabs(pt2->y - cellref->origin->y) / cellref->yrep;
                cellref->angle = angle;
                cellref->transformation = transformation;
                vector_append(children, cellref);
                vector_destroy(points, NULL); // don't destroy point, it is now owned by cellref->origin
                transformation = NULL;
                angle = 0;
            }
        }
        else if(record->recordtype == LAYER)
        {
            int16_t* pdata = _parse_two_byte_integer(record->data, 2);
            layer = *pdata;
            free(pdata);
        }
        else if(record->recordtype == DATATYPE)
        {
            int16_t* pdata = _parse_two_byte_integer(record->data, 2);
            purpose = *pdata;
            free(pdata);
        }
        else if(record->recordtype == TEXTTYPE)
        {
            int16_t* pdata = _parse_two_byte_integer(record->data, 2);
            purpose = *pdata;
            free(pdata);
        }
        else if(record->recordtype == XY)
        {
            int32_t* pdata = _parse_four_byte_integer(record->data, record->length - 4);
            for(int i = 0; i < (record->length - 4) / 4; i += 2)
            {
                int32_t x = pdata[i];
                int32_t y = pdata[i + 1];
                vector_append(points, point_create(x, y));
            }
            free(pdata);
        }
        else if(record->recordtype == WIDTH)
        {
            int32_t* pdata = _parse_four_byte_integer(record->data, 4);
            width = *pdata;
            free(pdata);
        }
        else if(record->recordtype == PATHTYPE)
        {
    //        if record.data == 0 then
    //            obj.pathtype = "butt"
    //        elseif record.data == 1 then
    //            obj.pathtype = "round"
    //        elseif record.data == 2 then
    //            obj.pathtype = "cap"
    //        elseif record.data == 4 then
    //            obj.pathtype = { 0, 0 }
    //        end
        }
        else if(record->recordtype == COLROW)
        {
            int16_t* pdata = _parse_two_byte_integer(record->data, 4);
            xrep = pdata[0];
            yrep = pdata[1];
            free(pdata);
        }
        else if(record->recordtype == SNAME)
        {
            str = _parse_string(record->data, record->length - 4);
        }
        else if(record->recordtype == STRING)
        {
            str = _parse_string(record->data, record->length - 4);
        }
        else if(record->recordtype == STRANS)
        {
            transformation = _parse_bit_array(record->data);
        }
        else if(record->recordtype == ANGLE)
        {
            double* pdata = _parse_eight_byte_real(record->data, record->length - 4);
            angle = *pdata;
            free(pdata);
        }
        else if(record->recordtype == BGNEXTN)
        {
    //        obj.pathtype[1] = record.data
        }
        else if(record->recordtype == ENDEXTN)
        {
    //        obj.pathtype[2] = record.data
        }
    }

    _destroy_stream(stream);

    //-- check for ignored layer-purpose pairs
    //if ignorelpp then
    //    for _, cell in ipairs(cells) do
    //        for i = #cell.shapes, 1, -1 do -- backwards for deletion
    //            local shape = cell.shapes[i]
    //            for _, lpp in ipairs(ignorelpp) do
    //                local layer, purpose = string.match(lpp, "(%w+):(%w+)")
    //                if shape.layer == tonumber(layer) and shape.purpose == tonumber(purpose) then
    //                    table.remove(cell.shapes, i)
    //                end
    //            end
    //        end
    //    end
    //end
    return 1;
}

static int lgdsparser_show_records(lua_State* L)
{
    const char* filename = lua_tostring(L, 1);
    if(!gdsparser_show_records(filename))
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

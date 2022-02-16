#include "gdsparser.h"

#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <math.h>
#include <string.h>

#include "lua/lauxlib.h"

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
    void* data;
};

struct record* _read_record(FILE* file)
{
    uint8_t buf[4];
    size_t read;
    read = fread(buf, 1, 4, file);
    if(read != 4)
    {
        return NULL;
    }
    struct record* record = malloc(sizeof(*record));
    record->length = (buf[0] << 8) + buf[1];
    record->recordtype = buf[2];
    record->datatype = buf[3];
    record->data = NULL;

    size_t numbytes = record->length - 4;
    uint8_t* data = malloc(numbytes);
    read = fread(data, 1, numbytes, file);
    if(read != numbytes)
    {
        free(record);
        return NULL;
    }

    if(record->length > 4)
    {
        // parsed data
        switch(record->datatype)
        {
            case BIT_ARRAY:
            {
                //printf("0x%02x 0x%02x\n", data[0], data[1]);
                int* rdata = calloc(16, sizeof(*rdata));
                rdata[ 0] = (data[0] & 0x80) >> 7;
                rdata[ 1] = (data[0] & 0x40) >> 6;
                rdata[ 2] = (data[0] & 0x20) >> 5;
                rdata[ 3] = (data[0] & 0x10) >> 4;
                rdata[ 4] = (data[0] & 0x08) >> 3;
                rdata[ 5] = (data[0] & 0x04) >> 2;
                rdata[ 6] = (data[0] & 0x02) >> 1;
                rdata[ 7] = (data[0] & 0x01) >> 0;
                rdata[ 8] = (data[1] & 0x80) >> 7;
                rdata[ 9] = (data[1] & 0x40) >> 6;
                rdata[10] = (data[1] & 0x20) >> 5;
                rdata[11] = (data[1] & 0x10) >> 4;
                rdata[12] = (data[1] & 0x08) >> 3;
                rdata[13] = (data[1] & 0x04) >> 2;
                rdata[14] = (data[1] & 0x02) >> 1;
                rdata[15] = (data[1] & 0x01) >> 0;
                record->data = rdata;
                break;
            }
            case TWO_BYTE_INTEGER:
            {
                int16_t* rdata = calloc((record->length - 4) / 2, 2);
                for(int i = 0; i < (record->length - 4) / 2; ++i)
                {
                    rdata[i] = (data[i * 2] << 8) + data[i * 2 + 1];
                }
                record->data = rdata;
                break;
            }
            case FOUR_BYTE_INTEGER:
            {
                int32_t* rdata = calloc((record->length - 4) / 4, 4);
                for(int i = 0; i < (record->length - 4) / 4; ++i)
                {
                    rdata[i] = (data[i * 4] << 24) + (data[i * 4 + 1] << 16) + (data[i * 4 + 2] << 8) + data[i * 4 + 3];
                }
                record->data = rdata;
                break;
            }
            case FOUR_BYTE_REAL:
            {
                double* rdata = calloc((record->length - 4) / 4, sizeof(double));
                for(int i = 0; i < (record->length - 4) / 4; ++i)
                {
                    int sign = data[i * 4] & 0x80;
                    int8_t exp = data[i * 4] & 0x7f;
                    double mantissa = data[i * 4 + 1] / 256.0
                                    + data[i * 4 + 2] / 256.0 / 256.0
                                    + data[i * 4 + 3] / 256.0 / 256.0 / 256.0;
                    if(sign)
                    {
                        rdata[i] = -mantissa * pow(16.0, exp - 64);
                    }
                    else
                    {
                        rdata[i] = mantissa * pow(16.0, exp - 64);
                    }
                }
                record->data = rdata;
                break;
            }
            case EIGHT_BYTE_REAL:
            {
                double* rdata = calloc((record->length - 4) / 8, sizeof(double));
                for(int i = 0; i < (record->length - 4) / 8; ++i)
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
                        rdata[i] = -mantissa * pow(16.0, exp - 64);
                    }
                    else
                    {
                        rdata[i] = mantissa * pow(16.0, exp - 64);
                    }
                }
                record->data = rdata;
                break;
            }
            case ASCII_STRING:
            {
                char* rdata = calloc(record->length - 4, 1);
                memcpy(rdata, data, record->length - 4);
                record->data = rdata;
                break;
            }
        }
    }

    free(data);

    return record;
}

struct stream
{
    struct record** records;
    size_t numrecords;
};

struct stream* _read_stream(const char* filename)
{
    FILE* file = fopen(filename, "r");
    if(!file)
    {
        return NULL;
    }
    size_t numrecords = 0;
    size_t capacity = 10;
    struct record** records = calloc(capacity, sizeof(struct record));
    while(1)
    {
        struct record* record = _read_record(file);
        if(!record)
        {
            fprintf(stderr, "%s\n", "gdsparser: stream abort before ENDLIB");
            break;
        }
        if(numrecords > capacity)
        {
            capacity *= 2;
            struct record** tmp = realloc(records, capacity * sizeof(struct record));
            records = tmp;
        }
        records[numrecords] = record;
        ++numrecords;
        if(record->recordtype == ENDLIB)
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

int lgdsparser_read_raw_stream(lua_State* L)
{
    const char* filename = lua_tostring(L, 1);
    struct stream* stream = _read_stream(filename);
    if(!stream)
    {
        lua_pushnil(L);
        lua_pushstring(L, "could not read stream");
        return 2;
    }
    lua_newtable(L);
    for(size_t i = 0; i < stream->numrecords; ++i)
    {
        struct record* record = stream->records[i];
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
                for(int j = 0; j < 16; ++j)
                {
                    lua_pushinteger(L, ((int*)record->data)[j]);
                    lua_rawseti(L, -2, j + 1);
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
                        lua_pushinteger(L, ((int16_t*)record->data)[j]);
                        lua_rawseti(L, -2, j + 1);
                    }
                    lua_rawset(L, -3);
                }
                else
                {
                    lua_pushstring(L, "data");
                    lua_pushinteger(L, ((int16_t*)record->data)[0]);
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
                        lua_pushinteger(L, ((int32_t*)record->data)[j]);
                        lua_rawseti(L, -2, j + 1);
                    }
                    lua_rawset(L, -3);
                }
                else
                {
                    lua_pushstring(L, "data");
                    lua_pushinteger(L, ((int32_t*)record->data)[0]);
                    lua_rawset(L, -3);
                }
                break;
            case FOUR_BYTE_REAL:
                if((record->length - 4) / 4 > 1)
                {
                    lua_pushstring(L, "data");
                    lua_newtable(L);
                    for(int j = 0; j < (record->length - 4) / 4; ++j)
                    {
                        lua_pushnumber(L, ((double*)record->data)[j]);
                        lua_rawseti(L, -2, j + 1);
                    }
                    lua_rawset(L, -3);
                }
                else
                {
                    lua_pushstring(L, "data");
                    lua_pushnumber(L, ((double*)record->data)[0]);
                    lua_rawset(L, -3);
                }
                break;
            case EIGHT_BYTE_REAL:
                if((record->length - 4) / 8 > 1)
                {
                    lua_pushstring(L, "data");
                    lua_newtable(L);
                    for(int j = 0; j < (record->length - 4) / 8; ++j)
                    {
                        lua_pushnumber(L, ((double*)record->data)[j]);
                        lua_rawseti(L, -2, j + 1);
                    }
                    lua_rawset(L, -3);
                }
                else
                {
                    lua_pushstring(L, "data");
                    lua_pushnumber(L, ((double*)record->data)[0]);
                    lua_rawset(L, -3);
                }
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

int lgdsparser_show_records(lua_State* L)
{
    const char* filename = lua_tostring(L, 1);
    struct stream* stream = _read_stream(filename);
    if(!stream)
    {
        lua_pushnil(L);
        lua_pushstring(L, "could not read stream");
        return 2;
    }
    unsigned int indent = 0;
    for(size_t i = 0; i < stream->numrecords; ++i)
    {
        struct record* record = stream->records[i];
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
                    for(int i = 0; i < (record->length - 4) / 2; ++i)
                    {
                        int16_t num = ((int16_t*)record->data)[i];
                        printf("%d ", num);
                    }
                    break;
                case FOUR_BYTE_INTEGER:
                    for(int i = 0; i < (record->length - 4) / 4; ++i)
                    {
                        int32_t num = ((int32_t*)record->data)[i];
                        printf("%d ", num);
                    }
                    break;
                case FOUR_BYTE_REAL:
                    for(int i = 0; i < (record->length - 4) / 4; ++i)
                    {
                        double num = ((double*)record->data)[i];
                        printf("%g ", num);
                    }
                    break;
                case EIGHT_BYTE_REAL:
                    for(int i = 0; i < (record->length - 4) / 8; ++i)
                    {
                        double num = ((double*)record->data)[i];
                        printf("%g ", num);
                    }
                    break;
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
    for(unsigned int i = 0; i < stream->numrecords; ++i)
    {
        free(stream->records[i]->data);
        free(stream->records[i]);
    }
    free(stream->records);
    free(stream);
    return 0;
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

#include "gdsparser.h"

#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <math.h>

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
    uint8_t* data;
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

    size_t numbytes = record->length - 4;
    record->data = malloc(numbytes);
    read = fread(record->data, 1, numbytes, file);
    if(read != numbytes)
    {
        free(record);
        return NULL;
    }
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

void show_records(const char* filename, int raw)
{
    struct stream* stream = _read_stream(filename);
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
                        int16_t num = (record->data[i * 2] << 8) + record->data[i * 2 + 1];
                        printf("%d ", num);
                    }
                    break;
                case FOUR_BYTE_INTEGER:
                    for(int i = 0; i < (record->length - 4) / 4; ++i)
                    {
                        int32_t num = (record->data[i * 4] << 24) + (record->data[i * 4 + 1] << 16) + (record->data[i * 4 + 2] << 8) + record->data[i * 4 + 3];
                        printf("%d ", num);
                    }
                    break;
                case FOUR_BYTE_REAL:
                    for(int i = 0; i < (record->length - 4) / 4; ++i)
                    {
                        int start = i * 4;
                        int sign = record->data[start] & 0x80;
                        int8_t exp = record->data[start] & 0x7f;
                        double mantissa = 0.0;
                        mantissa += record->data[start + 1] / 256.0;
                        mantissa += record->data[start + 2] / 256.0 / 256.0;
                        mantissa += record->data[start + 3] / 256.0 / 256.0 / 256.0;
                        if(sign)
                        {
                            printf("%g ", -mantissa * pow(16.0, exp - 64));
                        }
                        else
                        {
                            printf("%g ", mantissa * pow(16.0, exp - 64));
                        }
                    }
                    break;
                case EIGHT_BYTE_REAL:
                    for(int i = 0; i < (record->length - 4) / 8; ++i)
                    {
                        int start = i * 8;
                        int sign = record->data[start] & 0x80;
                        int8_t exp = record->data[start] & 0x7f;
                        double mantissa = 0.0;
                        mantissa += record->data[start + 1] / 256.0;
                        mantissa += record->data[start + 2] / 256.0 / 256.0;
                        mantissa += record->data[start + 3] / 256.0 / 256.0 / 256.0;
                        mantissa += record->data[start + 4] / 256.0 / 256.0 / 256.0 / 256.0;
                        mantissa += record->data[start + 5] / 256.0 / 256.0 / 256.0 / 256.0 / 256.0;
                        mantissa += record->data[start + 6] / 256.0 / 256.0 / 256.0 / 256.0 / 256.0 / 256.0;
                        mantissa += record->data[start + 7] / 256.0 / 256.0 / 256.0 / 256.0 / 256.0 / 256.0 / 256.0;
                        if(sign)
                        {
                            printf("%g ", -mantissa * pow(16.0, exp - 64));
                        }
                        else
                        {
                            printf("%g ", mantissa * pow(16.0, exp - 64));
                        }
                    }
                    break;
                case ASCII_STRING:
                    for(unsigned int i = 0; i < record->length - 4; ++i)
                    {
                        putchar(record->data[i]);
                    }
                    break;
                default:
            }

            // raw data
            if(raw)
            {
                putchar('{');
                putchar(' ');
                for(int i = 0; i < record->length - 4; ++i)
                {
                    printf("0x%02x ", record->data[i]);
                }
                putchar('}');
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
}

int lgdsparser_show_records(lua_State* L)
{
    const char* filename = lua_tostring(L, 1);
    int printraw = lua_toboolean(L, 3);
    show_records(filename, printraw);
    return 0;
}

int open_gdsparser_lib(lua_State* L)
{
    static const luaL_Reg modfuncs[] =
    {
        { "show_records", lgdsparser_show_records },
        { NULL,            NULL                }
    };
    lua_newtable(L);
    luaL_setfuncs(L, modfuncs, 0);
    lua_setglobal(L, "gdsparser");
    return 0;
}

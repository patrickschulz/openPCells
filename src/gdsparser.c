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

struct stream* _read_raw_stream(const char* filename)
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
                case BIT_ARRAY:
                    for(int i = 0; i < (record->length - 4) / 2; ++i)
                    {
                        int16_t num = ((int16_t*)record->data)[i];
                        for(unsigned int j = 0; j < 16; ++j)
                        {
                            int val = num & (1 << (15 - j));
                            if(val)
                            {
                                putchar('1');
                            }
                            else
                            {
                                putchar('0');
                            }
                        }
                    }
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
    return 1;
}

void _print_int16(FILE* file, int16_t num)
{
    if(num < 0)
    {
        fputc('-', file);
        num *= -1;
    }
    while(num > 0)
    {
        fputc((num % 10) + '0', file);
        num /= 10;
    }
}

void _print_int32(FILE* file, int32_t num)
{
    if(num < 0)
    {
        fputc('-', file);
        num *= -1;
    }
    while(num > 0)
    {
        fputc((num % 10) + '0', file);
        num /= 10;
    }
}

void gdsparser_read_stream(const char* filename)
{
    const char* libname;
    struct stream* stream = _read_raw_stream(filename);
    FILE* cellfile = NULL;
    int16_t layer;
    int16_t purpose;
    int32_t width;
    struct vector* points = NULL;
    uint8_t what;
    const char* str;
    int16_t xrep, yrep;
    for(size_t i = 0; i < stream->numrecords; ++i)
    {
        struct record* record = stream->records[i];
        if(record->recordtype == LIBNAME)
        {
            libname = (const char*)record->data;
            size_t len = 2 * strlen(libname) + 1; // +1: '/'
            char* path = malloc(len + 1);
            snprintf(path, len + 1, "%s/%s", libname, libname);
            filesystem_mkdir(path);
            free(path);
        }
        else if(record->recordtype == BGNSTR)
        {
    //        cell = {
    //            shapes = {},
    //            references = {},
    //            labels = {}
    //        }
        }
        else if(record->recordtype == ENDSTR)
        {
            fputs("end", cellfile); // close layout function
            fclose(cellfile);
        }
        else if(record->recordtype == STRNAME)
        {
            const char* cellname = (const char*) record->data;
            size_t len = 2 * strlen(libname) + strlen(cellname) + 6; // +2: 2 * '/' + ".lua"
            char* path = malloc(len + 1);
            snprintf(path, len + 1, "%s/%s/%s.lua", libname, libname, cellname);
            cellfile = fopen(path, "w");
            fputs("function parameter() end\n", cellfile);
            fputs("function layout(cell)\n", cellfile);
            free(path);
        }
        else if(record->recordtype == BOUNDARY)
        {
            what = BOUNDARY;
            points = vector_create();
    //           is_record(record, "BOX") or
    //           is_record(record, "PATH") then
    //        obj = { 
    //            what = "shape",
    //            shapetype = (is_record(record, "BOUNDARY") and "polygon") or
    //                   (is_record(record, "BOX") and "rectangle") or
    //                   (is_record(record, "PATH") and "path")
    //        }
        }
        else if(record->recordtype == PATH)
        {
            what = PATH;
            points = vector_create();
        }
        else if(record->recordtype == SREF)
        {
            what = SREF;
        }
        else if(record->recordtype == AREF)
        {
            what = AREF;
        }
        else if(record->recordtype == TEXT)
        {
            what = TEXT;
        }
        else if(record->recordtype == ENDEL)
        {
            fputs("    ", cellfile);
            if(what == BOUNDARY)
            {
                /*
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
                */
                fprintf(cellfile, "geometry.polygon(cell, generics.premapped(nil, { gds = { layer = %d, purpose = %d } }), { ", layer, purpose);
                for(unsigned int i = 0; i < vector_size(points); ++i)
                {
                    point_t* pt = vector_get(points, i);
                    fprintf(cellfile, "point.create(%lld, %lld), ", pt->x, pt->y);
                }
                fputs("})\n", cellfile);
            }
            if(what == PATH)
            {
                fprintf(cellfile, "geometry.path(cell, generics.premapped(nil, { gds = { layer = %d, purpose = %d } }), { ", layer, purpose);
                for(unsigned int i = 0; i < vector_size(points); ++i)
                {
                    point_t* pt = vector_get(points, i);
                    fprintf(cellfile, "point.create(%lld, %lld), ", pt->x, pt->y);
                }
                fprintf(cellfile, "}, %d)\n", width);
            }
            if(what == TEXT)
            {
                point_t* pt = vector_get(points, 0);
                fprintf(cellfile, "cell:add_port(\"%s\", generics.premapped(nil, { gds = { layer = %d, purpose = %d } }), point.create(%lld, %lld))\n", str, layer, purpose, pt->x, pt->y);
            }
            if(what == SREF)
            {
                fprintf(cellfile, "cell:add_child(\"%s\")\n", str);
            }
    //        if obj.what == "shape" then
    //            table.insert(cell.shapes, obj)
    //        elseif obj.what == "sref" then
    //            table.insert(cell.references, obj)
    //        elseif obj.what == "aref" then
    //            table.insert(cell.references, obj)
    //        elseif obj.what == "text" then
    //            table.insert(cell.labels, obj)
    //        end
    //        obj = nil
        }
        else if(record->recordtype == LAYER)
        {
            layer = *(int16_t*)record->data;
        }
        else if(record->recordtype == DATATYPE)
        {
            purpose = *(int16_t*)record->data;
        }
        else if(record->recordtype == TEXTTYPE)
        {
            purpose = *(int16_t*)record->data;
        }
        else if(record->recordtype == XY)
        {
            for(int i = 0; i < (record->length - 4) / 4; i += 2)
            {
                int32_t x = ((int32_t*)record->data)[i];
                int32_t y = ((int32_t*)record->data)[i + 1];
                vector_append(points, point_create(x, y));
            }
        }
        else if(record->recordtype == WIDTH)
        {
            width = *(int32_t*)record->data;
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
            xrep = ((int16_t*)record->data)[0];
            yrep = ((int16_t*)record->data)[1];
        }
        else if(record->recordtype == SNAME)
        {
            str = (const char*)record->data;
        }
        else if(record->recordtype == STRING)
        {
            str = (const char*)record->data;
        }
        else if(record->recordtype == STRANS)
        {
    //        obj.transformation = record.data
        }
        else if(record->recordtype == ANGLE)
        {
    //        obj.angle = record.data
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
    //-- post-process cells
    //-- -> BOX is not used for rectangles, at least most tool suppliers seem to do it this way
    //--    therefor, we check if some "polygons" are actually rectangles and fix the shape types
    //for _, cell in ipairs(cells) do
    //    for _, shape in ipairs(cell.shapes) do
    //        if shape.shapetype == "polygon" then
    //            if #shape.pts == 10 then -- rectangles in GDS have five points (xy -> * 2)
    //                if (shape.pts[1] == shape.pts[3]   and
    //                    shape.pts[4] == shape.pts[6]   and
    //                    shape.pts[5] == shape.pts[7]   and
    //                    shape.pts[8] == shape.pts[10]  and
    //                    shape.pts[9] == shape.pts[1]   and
    //                    shape.pts[10] == shape.pts[2]) or
    //                   (shape.pts[2] == shape.pts[4]   and
    //                    shape.pts[3] == shape.pts[5]   and
    //                    shape.pts[6] == shape.pts[8]   and
    //                    shape.pts[7] == shape.pts[9]   and
    //                    shape.pts[9] == shape.pts[1]   and
    //                    shape.pts[10] == shape.pts[2])  then

    //                    shape.shapetype = "rectangle"
    //                    shape.pts = { 
    //                        math.min(shape.pts[1], shape.pts[3], shape.pts[5], shape.pts[7], shape.pts[9]),
    //                        math.min(shape.pts[2], shape.pts[4], shape.pts[6], shape.pts[8], shape.pts[10]),
    //                        math.max(shape.pts[1], shape.pts[3], shape.pts[5], shape.pts[7], shape.pts[9]),
    //                        math.max(shape.pts[2], shape.pts[4], shape.pts[6], shape.pts[8], shape.pts[10])
    //                    }
    //                end
    //            end
    //        end

    //        if shape.shapetype == "path" then
    //            shape.pathtype = shape.pathtype or "butt"
    //        end
    //    end
    //end
    //return { libname = libname, cells = cells }
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

#include "gdsexport.h"

#include <stdint.h>
#include <stdlib.h>
#include <string.h>

#include "math.h" // modf
#include "tagged_value.h"
#include "geometry.h"
#include "util.h"

#define RECORDTYPE_HEADER       0x00
#define RECORDTYPE_BGNLIB       0x01
#define RECORDTYPE_LIBNAME      0x02
#define RECORDTYPE_UNITS        0x03
#define RECORDTYPE_ENDLIB       0x04
#define RECORDTYPE_BGNSTR       0x05
#define RECORDTYPE_STRNAME      0x06
#define RECORDTYPE_ENDSTR       0x07
#define RECORDTYPE_BOUNDARY     0x08
#define RECORDTYPE_PATH         0x09
#define RECORDTYPE_SREF         0x0a
#define RECORDTYPE_AREF         0x0b
#define RECORDTYPE_TEXT         0x0c
#define RECORDTYPE_LAYER        0x0d
#define RECORDTYPE_DATATYPE     0x0e
#define RECORDTYPE_WIDTH        0x0f
#define RECORDTYPE_XY           0x10
#define RECORDTYPE_ENDEL        0x11
#define RECORDTYPE_SNAME        0x12
#define RECORDTYPE_COLROW       0x13
#define RECORDTYPE_TEXTNODE     0x14
#define RECORDTYPE_NODE         0x15
#define RECORDTYPE_TEXTTYPE     0x16
#define RECORDTYPE_PRESENTATION 0x17
#define RECORDTYPE_SPACING      0x18
#define RECORDTYPE_STRING       0x19
#define RECORDTYPE_STRANS       0x1a
#define RECORDTYPE_MAG          0x1b
#define RECORDTYPE_ANGLE        0x1c
#define RECORDTYPE_UINTEGER     0x1d
#define RECORDTYPE_USTRING      0x1e
#define RECORDTYPE_REFLIBS      0x1f
#define RECORDTYPE_FONTS        0x20
#define RECORDTYPE_PATHTYPE     0x21
#define RECORDTYPE_GENERATIONS  0x22
#define RECORDTYPE_ATTRTABLE    0x23
#define RECORDTYPE_STYPTABLE    0x24
#define RECORDTYPE_STRTYPE      0x25
#define RECORDTYPE_ELFLAGS      0x26
#define RECORDTYPE_ELKEY        0x27
#define RECORDTYPE_LINKTYPE     0x28
#define RECORDTYPE_LINKKEYS     0x29
#define RECORDTYPE_NODETYPE     0x2a
#define RECORDTYPE_PROPATTR     0x2b
#define RECORDTYPE_PROPVALUE    0x2c
#define RECORDTYPE_BOX          0x2d
#define RECORDTYPE_BOXTYPE      0x2e
#define RECORDTYPE_PLEX         0x2f
#define RECORDTYPE_BGNEXTN      0x30
#define RECORDTYPE_ENDEXTN      0x31
#define RECORDTYPE_TAPENUM      0x32
#define RECORDTYPE_TAPECODE     0x33
#define RECORDTYPE_STRCLASS     0x34
#define RECORDTYPE_RESERVED     0x35
#define RECORDTYPE_FORMAT       0x36
#define RECORDTYPE_MASK         0x37
#define RECORDTYPE_ENDMASKS     0x38
#define RECORDTYPE_LIBDIRSIZE   0x39
#define RECORDTYPE_SRFNAME      0x3a
#define RECORDTYPE_LIBSECUR     0x3b

#define DATATYPE_NONE                0x00
#define DATATYPE_BIT_ARRAY           0x01
#define DATATYPE_TWO_BYTE_INTEGER    0x02
#define DATATYPE_FOUR_BYTE_INTEGER   0x03
#define DATATYPE_FOUR_BYTE_REAL      0x04
#define DATATYPE_EIGHT_BYTE_REAL     0x05
#define DATATYPE_ASCII_STRING        0x06

static unsigned int __userunit = 1000; // default: user unit is 1000 * 1 nm = 1 um
static double __databaseunit = 1e-9; // default: data base unit is 1 nm
static char* __libname = NULL;

static int _set_options(const struct vector* vopt)
{
    size_t i = 0;
    while(i < vector_size(vopt))
    {
        const char* arg = vector_get_const(vopt, i);
        if(strcmp(arg, "--library-name") == 0)
        {
            if(i < vector_size(vopt) - 1)
            {
                __libname = util_strdup(vector_get_const(vopt, i + 1));
            }
            else
            {
                fputs("gds export: --library-name: argument expected\n", stderr);
                return 0;
            }
            ++i;
        }
        else if(strcmp(arg, "--user-unit") == 0)
        {
            if(i < vector_size(vopt) - 1)
            {
                __userunit = atoi(vector_get_const(vopt, i + 1));;
            }
            else
            {
                fputs("gds export: --user-unit: argument expected\n", stderr);
                return 0;
            }
            ++i;
        }
        else if(strcmp(arg, "--database-unit") == 0)
        {
            if(i < vector_size(vopt) - 1)
            {
                __databaseunit = atof(vector_get_const(vopt, i + 1));;
            }
            else
            {
                fputs("gds export: --database-unit: argument expected\n", stderr);
                return 0;
            }
            ++i;
        }
        else
        {
            fprintf(stderr, "SKILL export: unknown option '%s'\n", arg);
            return 0;
        }
        ++i;
    }
    return 1;
}

static void _finalize(void)
{
    if(__libname)
    {
        free(__libname);
    }
}

static void _number_to_gdsfloat(double num, unsigned int width, char* data)
{
    if(num == 0)
    {
        memset(data, 0, width);
        return;
    }
    int sign = 0;
    if(num < 0.0)
    {
        sign = 1;
        num = -num;
    }
    int exp = 0;
    while(num >= 1)
    {
        num = num / 16;
        exp = exp + 1;
    }
    while(num < 0.0625)
    {
        num = num * 16;
        exp = exp - 1;
    }
    if(sign)
    {
        data[0] = 0x80 + ((exp + 64) & 0x7f);
    }
    else
    {
        data[0] = 0x00 + ((exp + 64) & 0x7f);
    }
    for(unsigned int i = 1; i < width; ++i)
    {
        double integer;
        double frac = modf(num * 256, &integer);
        num = frac;
        data[i] = integer;
    }
}

static inline void _write_length(struct export_data* data, uint8_t length)
{
    export_data_append_byte(data, 0);
    export_data_append_byte(data, length);
}

static inline void _write_length_unchecked(struct export_data* data, uint8_t length)
{
    export_data_append_byte_unchecked(data, 0);
    export_data_append_byte_unchecked(data, length);
}

static inline void _write_ENDEL(struct export_data* data)
{
    export_data_append_two_bytes(data, 4);
    export_data_append_byte(data, RECORDTYPE_ENDEL);
    export_data_append_byte(data, DATATYPE_NONE);
}

static inline void _write_ENDEL_unchecked(struct export_data* data)
{
    export_data_append_two_bytes_unchecked(data, 4);
    export_data_append_byte_unchecked(data, RECORDTYPE_ENDEL);
    export_data_append_byte_unchecked(data, DATATYPE_NONE);
}

static inline void _write_layer(struct export_data* data, uint8_t type, uint8_t datatype, const struct hashmap* layer)
{
    // BOUNDARY (4 bytes)
    _write_length(data, 4);
    export_data_append_byte(data, type);
    export_data_append_byte(data, DATATYPE_NONE);

    // LAYER (6 bytes)
    _write_length(data, 6);
    export_data_append_byte(data, RECORDTYPE_LAYER);
    export_data_append_byte(data, DATATYPE_TWO_BYTE_INTEGER);
    const struct tagged_value* vl = hashmap_get_const(layer, "layer");
    int layernum = tagged_value_get_integer(vl);
    export_data_append_two_bytes(data, layernum);

    // DATATYPE (6 bytes)
    _write_length(data, 6);
    export_data_append_byte(data, datatype);
    export_data_append_byte(data, DATATYPE_TWO_BYTE_INTEGER);
    const struct tagged_value* vp = hashmap_get_const(layer, "purpose");
    int layerpurpose = tagged_value_get_integer(vp);
    export_data_append_two_bytes(data, layerpurpose);
}

static inline void _write_layer_unchecked(struct export_data* data, uint8_t type, const struct hashmap* layer)
{
    // BOUNDARY (4 bytes)
    _write_length_unchecked(data, 4);
    export_data_append_byte_unchecked(data, type);
    export_data_append_byte_unchecked(data, DATATYPE_NONE);

    // LAYER (6 bytes)
    _write_length_unchecked(data, 6);
    export_data_append_byte_unchecked(data, RECORDTYPE_LAYER);
    export_data_append_byte_unchecked(data, DATATYPE_TWO_BYTE_INTEGER);
    const struct tagged_value* vl = hashmap_get_const(layer, "layer");
    int layernum = tagged_value_get_integer(vl);
    export_data_append_two_bytes_unchecked(data, (int16_t)layernum);

    // DATATYPE (6 bytes)
    _write_length_unchecked(data, 6);
    export_data_append_byte_unchecked(data, RECORDTYPE_DATATYPE);
    export_data_append_byte_unchecked(data, DATATYPE_TWO_BYTE_INTEGER);
    const struct tagged_value* vp = hashmap_get_const(layer, "purpose");
    int layerpurpose = tagged_value_get_integer(vp);
    export_data_append_two_bytes_unchecked(data, (int16_t)layerpurpose);
}

static inline void _write_string(struct export_data* data, const char* str, uint8_t recordtype)
{
    size_t len = strlen(str);
    if(len % 2 == 0)
    {
        export_data_append_two_bytes(data, len + 4);
    }
    else
    {
        export_data_append_two_bytes(data, len + 5);
    }
    export_data_append_byte(data, recordtype);
    export_data_append_byte(data, DATATYPE_ASCII_STRING);
    export_data_append_string_len(data, str, len);
    if(len % 2 == 1)
    {
        export_data_append_nullbyte(data);
    }
}

static void _at_begin(struct export_data* data)
{
    // HEADER (Version 600)
    _write_length(data, 6);
    export_data_append_byte(data, RECORDTYPE_HEADER);
    export_data_append_byte(data, DATATYPE_TWO_BYTE_INTEGER);
    export_data_append_byte(data, 0x02);
    export_data_append_byte(data, 0x58);
    // BGNLIB
    // FIXME: put in real data, not fixed
    _write_length(data, 0x1c);
    export_data_append_byte(data, RECORDTYPE_BGNLIB);
    export_data_append_byte(data, DATATYPE_TWO_BYTE_INTEGER);
    export_data_append_byte(data, 0x07);
    export_data_append_byte(data, 0xe6);
    export_data_append_byte(data, 0x00);
    export_data_append_byte(data, 0x03);
    export_data_append_byte(data, 0x00);
    export_data_append_byte(data, 0x0f);
    export_data_append_byte(data, 0x00);
    export_data_append_byte(data, 0x0d);
    export_data_append_byte(data, 0x00);
    export_data_append_byte(data, 0x3b);
    export_data_append_byte(data, 0x00);
    export_data_append_byte(data, 0x35);
    export_data_append_byte(data, 0x07);
    export_data_append_byte(data, 0xe6);
    export_data_append_byte(data, 0x00);
    export_data_append_byte(data, 0x03);
    export_data_append_byte(data, 0x00);
    export_data_append_byte(data, 0x0f);
    export_data_append_byte(data, 0x00);
    export_data_append_byte(data, 0x0d);
    export_data_append_byte(data, 0x00);
    export_data_append_byte(data, 0x3b);
    export_data_append_byte(data, 0x00);
    export_data_append_byte(data, 0x35);
    // LIBNAME
    if(__libname)
    {
        _write_string(data, __libname, RECORDTYPE_LIBNAME);
    }
    else
    {
        _write_string(data, "opclib", RECORDTYPE_LIBNAME);
    }
    // UNITS
    _write_length(data, 20);
    export_data_append_byte(data, RECORDTYPE_UNITS);
    export_data_append_byte(data, DATATYPE_EIGHT_BYTE_REAL);
    char unitdata[8];
    _number_to_gdsfloat(1.0 / __userunit, 8, unitdata);
    for(unsigned int i = 0; i < 8; ++i)
    {
        export_data_append_byte(data, unitdata[i]);
    }
    _number_to_gdsfloat(__databaseunit, 8, unitdata);
    for(unsigned int i = 0; i < 8; ++i)
    {
        export_data_append_byte(data, unitdata[i]);
    }
}

static void _at_end(struct export_data* data)
{
    _write_length(data, 4);
    export_data_append_byte(data, RECORDTYPE_ENDLIB);
    export_data_append_byte(data, DATATYPE_NONE);
}

static void _at_begin_cell(struct export_data* data, const char* name, int istoplevel)
{
    (void) istoplevel;
    // BGNSTR
    _write_length(data, 28);
    export_data_append_byte(data, RECORDTYPE_BGNSTR);
    export_data_append_byte(data, DATATYPE_TWO_BYTE_INTEGER);
    export_data_append_byte(data, 0x07);
    export_data_append_byte(data, 0xe6);
    export_data_append_byte(data, 0x00);
    export_data_append_byte(data, 0x03);
    export_data_append_byte(data, 0x00);
    export_data_append_byte(data, 0x0f);
    export_data_append_byte(data, 0x00);
    export_data_append_byte(data, 0x0d);
    export_data_append_byte(data, 0x00);
    export_data_append_byte(data, 0x3b);
    export_data_append_byte(data, 0x00);
    export_data_append_byte(data, 0x35);
    export_data_append_byte(data, 0x07);
    export_data_append_byte(data, 0xe6);
    export_data_append_byte(data, 0x00);
    export_data_append_byte(data, 0x03);
    export_data_append_byte(data, 0x00);
    export_data_append_byte(data, 0x0f);
    export_data_append_byte(data, 0x00);
    export_data_append_byte(data, 0x0d);
    export_data_append_byte(data, 0x00);
    export_data_append_byte(data, 0x3b);
    export_data_append_byte(data, 0x00);
    export_data_append_byte(data, 0x35);

    // STRNAME
    _write_string(data, name, RECORDTYPE_STRNAME);
}

static void _at_end_cell(struct export_data* data, int istoplevel)
{
    (void) istoplevel;
    _write_length(data, 4);
    export_data_append_byte(data, RECORDTYPE_ENDSTR);
    export_data_append_byte(data, DATATYPE_NONE);
}

static void _write_rectangle(struct export_data* data, const struct hashmap* layer, const struct point* bl, const struct point* tr)
{
    export_data_ensure_additional_capacity(data, 64); // a rectangle has exactly 64 bytes
    _write_layer_unchecked(data, RECORDTYPE_BOUNDARY, layer);

    // XY (44 bytes)
    _write_length_unchecked(data, 44);
    export_data_append_byte_unchecked(data, RECORDTYPE_XY);
    export_data_append_byte_unchecked(data, DATATYPE_FOUR_BYTE_INTEGER);
    export_data_append_four_bytes_unchecked(data, bl->x);
    export_data_append_four_bytes_unchecked(data, bl->y);
    export_data_append_four_bytes_unchecked(data, tr->x);
    export_data_append_four_bytes_unchecked(data, bl->y);
    export_data_append_four_bytes_unchecked(data, tr->x);
    export_data_append_four_bytes_unchecked(data, tr->y);
    export_data_append_four_bytes_unchecked(data, bl->x);
    export_data_append_four_bytes_unchecked(data, tr->y);
    export_data_append_four_bytes_unchecked(data, bl->x);
    export_data_append_four_bytes_unchecked(data, bl->y);

    _write_ENDEL_unchecked(data); // 4 bytes
}

static void _write_polygon(struct export_data* data, const struct hashmap* layer, const struct vector* points)
{
    _write_layer(data, RECORDTYPE_BOUNDARY, RECORDTYPE_DATATYPE, layer);

    // XY
    export_data_append_two_bytes(data, 4 + 4 * 2 * vector_size(points));
    export_data_append_byte(data, RECORDTYPE_XY);
    export_data_append_byte(data, DATATYPE_FOUR_BYTE_INTEGER); // FOUR_BYTE_INTEGER
    for(unsigned int i = 0; i < vector_size(points); ++i)
    {
        const struct point* pt = vector_get_const(points, i);
        export_data_append_four_bytes(data, pt->x);
        export_data_append_four_bytes(data, pt->y);
    }

    _write_ENDEL(data);
}

static void _write_polygon_wrapper(struct export_data* data, const struct hashmap* layer, const struct vector* points)
{
    if(4 + 4 * 2 * vector_size(points) > 65536)
    //if(vector_size(points) > 200) // GDSII specification only allows 200 points for a polygon at maximum
    {
        struct vector* triangulated_points = geometry_triangulate_polygon(points);
        for(unsigned int i = 0; i < vector_size(triangulated_points) - 2; i += 3)
        {
            struct vector* tripts = vector_create(3, NULL);
            vector_append(tripts, vector_get(triangulated_points, i));
            vector_append(tripts, vector_get(triangulated_points, i + 1));
            vector_append(tripts, vector_get(triangulated_points, i + 2));
            _write_polygon(data, layer, tripts);
            vector_destroy(tripts);
        }
        vector_destroy(triangulated_points);
    }
    else
    {
        _write_polygon(data, layer, points);
    }
}

static void _write_path(struct export_data* data, const struct hashmap* layer, const struct vector* points, ucoordinate_t width, const coordinate_t* extension)
{
    _write_layer(data, RECORDTYPE_PATH, RECORDTYPE_DATATYPE, layer);

    // PATHTYPE
    _write_length(data, 6);
    export_data_append_byte(data, RECORDTYPE_PATHTYPE);
    export_data_append_byte(data, DATATYPE_TWO_BYTE_INTEGER);
    export_data_append_byte(data, 0x00);
    //if extension == "round" then
    //    export_data_append_byte(data, 0x01);
    //elseif extension == "cap" then
    //    export_data_append_byte(data, 0x02);
    //elseif type(extension) == "table" then
        export_data_append_byte(data, 0x04);
    //else
    //    export_data_append_byte(data, 0x00);
    //end

    // WIDTH
    _write_length(data, 8);
    export_data_append_byte(data, RECORDTYPE_WIDTH);
    export_data_append_byte(data, DATATYPE_FOUR_BYTE_INTEGER);
    export_data_append_four_bytes(data, width);

    // these records have to come after WIDTH (at least for klayout, but they also are in this order in the GDS manual)
    // BGNEXTN
    _write_length(data, 8);
    export_data_append_byte(data, RECORDTYPE_BGNEXTN);
    export_data_append_byte(data, DATATYPE_FOUR_BYTE_INTEGER);
    export_data_append_four_bytes(data, extension[0]);
    // ENDEXTN
    _write_length(data, 8);
    export_data_append_byte(data, RECORDTYPE_ENDEXTN);
    export_data_append_byte(data, DATATYPE_FOUR_BYTE_INTEGER);
    export_data_append_four_bytes(data, extension[1]);

    // XY
    export_data_append_two_bytes(data, 4 + 4 * 2 * vector_size(points));
    export_data_append_byte(data, RECORDTYPE_XY);
    export_data_append_byte(data, DATATYPE_FOUR_BYTE_INTEGER); // FOUR_BYTE_INTEGER
    for(unsigned int i = 0; i < vector_size(points); ++i)
    {
        const struct point* pt = vector_get_const(points, i);
        export_data_append_four_bytes(data, pt->x);
        export_data_append_four_bytes(data, pt->y);
    }

    _write_ENDEL(data);
}

static void _write_reflection(struct export_data* data)
{
    _write_length(data, 6);
    export_data_append_byte(data, RECORDTYPE_STRANS);
    export_data_append_byte(data, DATATYPE_BIT_ARRAY);
    export_data_append_byte(data, 0x80);
    export_data_append_byte(data, 0x00);
}

static void _write_angle_90(struct export_data* data)
{
    _write_length(data, 12);
    export_data_append_byte(data, RECORDTYPE_ANGLE);
    export_data_append_byte(data, DATATYPE_EIGHT_BYTE_REAL);
    export_data_append_byte(data, 0x42);
    export_data_append_byte(data, 0x5a);
    export_data_append_byte(data, 0x00);
    export_data_append_byte(data, 0x00);
    export_data_append_byte(data, 0x00);
    export_data_append_byte(data, 0x00);
    export_data_append_byte(data, 0x00);
    export_data_append_byte(data, 0x00);
}

static void _write_angle_180(struct export_data* data)
{
    _write_length(data, 12);
    export_data_append_byte(data, RECORDTYPE_ANGLE);
    export_data_append_byte(data, DATATYPE_EIGHT_BYTE_REAL);
    export_data_append_byte(data, 0x42);
    export_data_append_byte(data, 0xb4);
    export_data_append_byte(data, 0x00);
    export_data_append_byte(data, 0x00);
    export_data_append_byte(data, 0x00);
    export_data_append_byte(data, 0x00);
    export_data_append_byte(data, 0x00);
    export_data_append_byte(data, 0x00);
}

static void _write_angle_270(struct export_data* data)
{
    _write_length(data, 12);
    export_data_append_byte(data, RECORDTYPE_ANGLE);
    export_data_append_byte(data, DATATYPE_EIGHT_BYTE_REAL);
    export_data_append_byte(data, 0x43);
    export_data_append_byte(data, 0x10);
    export_data_append_byte(data, 0xe0);
    export_data_append_byte(data, 0x00);
    export_data_append_byte(data, 0x00);
    export_data_append_byte(data, 0x00);
    export_data_append_byte(data, 0x00);
    export_data_append_byte(data, 0x00);
}

static void _rotate_vector(coordinate_t* x, coordinate_t* y, const struct transformationmatrix* trans)
{
    coordinate_t xx = *x;
    coordinate_t yy = *y;
    enum orientation orientation = export_get_matrix_orientation(trans);
    /*
    *x = cos(alpha) * xx -sin(alpha) * yy;
    *y = sin(alpha) * xx cos(alpha) * yy;
    */
    switch(orientation)
    {
        case R0:
            break;
        case R90:
            *x =  0 * xx + -1 * yy;
            *y =  1 * xx +  0 * yy;
            break;
        case R180:
            *x = -1 * xx +  0 * yy;
            *y =  0 * xx + -1 * yy;
            break;
        case R270:
            *x =  0 * xx +  1 * yy;
            *y = -1 * xx +  0 * yy;
            break;
        default:
            break;
            /* FIXME
        case MX:
            _write_reflection(data);
            break;
        case MY:
            _write_reflection(data);
            _write_angle_180(data);
            break;
        case MXR90:
            _write_reflection(data);
            _write_angle_90(data);
            break;
        case MYR90:
            _write_reflection(data);
            _write_angle_270(data);
            break;
            */
    }
}

static void _write_strans_angle(struct export_data* data, const struct transformationmatrix* trans)
{
    enum orientation orientation = export_get_matrix_orientation(trans);
    switch(orientation)
    {
        case R0:
            break;
        case R90:
            _write_angle_90(data);
            break;
        case R180:
            _write_angle_180(data);
            break;
        case R270:
            _write_angle_270(data);
            break;
        case MX:
            _write_reflection(data);
            break;
        case MY:
            _write_reflection(data);
            _write_angle_180(data);
            break;
        case MXR90:
            _write_reflection(data);
            _write_angle_90(data);
            break;
        case MYR90:
            _write_reflection(data);
            _write_angle_270(data);
            break;
    }
}

static void _write_cell_reference(struct export_data* data, const char* identifier, const char* instname, const struct point* where, const struct transformationmatrix* trans)
{
    (void) instname; // GDSII does not support instance names
    // SREF
    _write_length(data, 4);
    export_data_append_byte(data, RECORDTYPE_SREF);
    export_data_append_byte(data, DATATYPE_NONE);

    // SNAME
    _write_string(data, identifier, RECORDTYPE_SNAME);

    // transformation
    _write_strans_angle(data, trans);

    _write_length(data, 12);
    export_data_append_byte(data, RECORDTYPE_XY); // XY
    export_data_append_byte(data, DATATYPE_FOUR_BYTE_INTEGER); // FOUR_BYTE_INTEGER
    export_data_append_four_bytes(data, point_getx(where));
    export_data_append_four_bytes(data, point_gety(where));

    _write_ENDEL(data);
}

static void _write_cell_array(struct export_data* data, const char* identifier, const char* instbasename, const struct point* where, const struct transformationmatrix* trans, const struct transformationmatrix* array_trans, unsigned int xrep, unsigned int yrep, coordinate_t xpitch, coordinate_t ypitch)
{
    (void) instbasename; // GDSII does not support instance names
    // AREF
    _write_length(data, 4);
    export_data_append_byte(data, RECORDTYPE_AREF);
    export_data_append_nullbyte(data);

    // SNAME
    _write_string(data, identifier, RECORDTYPE_SNAME);

    // cell transformation
    _write_strans_angle(data, trans);

    // array transformation
    _write_strans_angle(data, array_trans);

    // COLROW
    _write_length(data, 8);
    export_data_append_byte(data, RECORDTYPE_COLROW);
    export_data_append_byte(data, DATATYPE_TWO_BYTE_INTEGER);
    export_data_append_two_bytes(data, xrep);
    export_data_append_two_bytes(data, yrep);

    // XY
    _write_length(data, 28);
    export_data_append_byte(data, RECORDTYPE_XY); // XY
    export_data_append_byte(data, DATATYPE_FOUR_BYTE_INTEGER); // FOUR_BYTE_INTEGER
    export_data_append_four_bytes(data, point_getx(where));
    export_data_append_four_bytes(data, point_gety(where));
    // column vector
    coordinate_t xcol = xrep * xpitch;
    coordinate_t ycol = 0;
    _rotate_vector(&xcol, &ycol, array_trans);
    export_data_append_four_bytes(data, (point_getx(where) + xcol));
    export_data_append_four_bytes(data, (point_gety(where) + ycol));
    // row vector
    coordinate_t xrow = 0;
    coordinate_t yrow = yrep * ypitch;
    _rotate_vector(&xrow, &yrow, array_trans);
    export_data_append_four_bytes(data, (point_getx(where) + xrow));
    export_data_append_four_bytes(data, (point_gety(where) + yrow));

    _write_ENDEL(data);
}

static void _write_port(struct export_data* data, const char* name, const struct hashmap* layer, const struct point* where, unsigned int sizehint)
{
    _write_layer(data, RECORDTYPE_TEXT, RECORDTYPE_TEXTTYPE, layer);

    // PRESENTATION
    _write_length(data, 6);
    export_data_append_byte(data, RECORDTYPE_PRESENTATION);
    export_data_append_byte(data, DATATYPE_BIT_ARRAY);
    export_data_append_byte(data, 0x00);
    export_data_append_byte(data, 0x05);

    _write_length(data, 12);
    export_data_append_byte(data, RECORDTYPE_MAG);
    export_data_append_byte(data, DATATYPE_EIGHT_BYTE_REAL);
    char sizedata[8];
    if(sizehint > 0)
    {
        double value = (double)sizehint / __userunit;
        _number_to_gdsfloat(value, 8, sizedata);
    }
    else
    {
        _number_to_gdsfloat(0.1, 8, sizedata);
    }
    for(unsigned int i = 0; i < 8; ++i)
    {
        export_data_append_byte(data, sizedata[i]);
    }

    // XY
    _write_length(data, 12);
    export_data_append_byte(data, RECORDTYPE_XY); // XY
    export_data_append_byte(data, DATATYPE_FOUR_BYTE_INTEGER); // FOUR_BYTE_INTEGER
    export_data_append_four_bytes(data, point_getx(where));
    export_data_append_four_bytes(data, point_gety(where));

    // NAME
    _write_string(data, name, RECORDTYPE_STRING);

    _write_ENDEL(data);
}

static const char* _get_extension(void)
{
    return "gds";
}

struct export_functions* gdsexport_get_export_functions(void)
{
    struct export_functions* funcs = export_create_functions();
    funcs->set_options = _set_options;
    funcs->finalize = _finalize;
    funcs->at_begin = _at_begin;
    funcs->at_end = _at_end;
    funcs->at_begin_cell = _at_begin_cell;
    funcs->at_end_cell = _at_end_cell;
    funcs->write_rectangle = _write_rectangle;
    funcs->write_polygon = _write_polygon_wrapper;
    funcs->write_path_extension = _write_path;
    funcs->write_path = NULL;
    funcs->write_cell_reference = _write_cell_reference;
    funcs->write_cell_array = _write_cell_array;
    funcs->write_port = _write_port;
    funcs->write_label = _write_port;
    funcs->get_extension = _get_extension;
    funcs->write_netshape = NULL;
    return funcs;
}


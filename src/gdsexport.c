#include "gdsexport.h"

#include <string.h>
#include <stdint.h>

#include "math.h" // modf
#include "tagged_value.h"

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

static inline void _write_length_short(struct export_data* data, uint8_t length)
{
    export_data_append_byte(data, 0);
    export_data_append_byte(data, length);
}

static inline void _write_length_short_unchecked(struct export_data* data, uint8_t length)
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
    _write_length_short(data, 4);
    export_data_append_byte(data, type);
    export_data_append_byte(data, DATATYPE_NONE);

    // LAYER (6 bytes)
    _write_length_short(data, 6);
    export_data_append_byte(data, RECORDTYPE_LAYER);
    export_data_append_byte(data, DATATYPE_TWO_BYTE_INTEGER);
    const struct tagged_value* vl = hashmap_get_const(layer, "layer");
    int layernum = tagged_value_get_integer(vl);
    export_data_append_two_bytes(data, layernum);

    // DATATYPE (6 bytes)
    _write_length_short(data, 6);
    export_data_append_byte(data, datatype);
    export_data_append_byte(data, DATATYPE_TWO_BYTE_INTEGER);
    const struct tagged_value* vp = hashmap_get_const(layer, "purpose");
    int layerpurpose = tagged_value_get_integer(vp);
    export_data_append_two_bytes(data, layerpurpose);
}

static inline void _write_layer_unchecked(struct export_data* data, uint8_t type, const struct hashmap* layer)
{
    // BOUNDARY (4 bytes)
    _write_length_short(data, 4);
    export_data_append_byte_unchecked(data, type);
    export_data_append_byte_unchecked(data, DATATYPE_NONE);

    // LAYER (6 bytes)
    _write_length_short_unchecked(data, 6);
    export_data_append_byte_unchecked(data, RECORDTYPE_LAYER);
    export_data_append_byte_unchecked(data, DATATYPE_TWO_BYTE_INTEGER);
    const struct tagged_value* vl = hashmap_get_const(layer, "layer");
    int layernum = tagged_value_get_integer(vl);
    export_data_append_two_bytes_unchecked(data, (int16_t)layernum);

    // DATATYPE (6 bytes)
    _write_length_short_unchecked(data, 6);
    export_data_append_byte_unchecked(data, RECORDTYPE_DATATYPE);
    export_data_append_byte_unchecked(data, DATATYPE_TWO_BYTE_INTEGER);
    const struct tagged_value* vp = hashmap_get_const(layer, "purpose");
    int layerpurpose = tagged_value_get_integer(vp);
    export_data_append_two_bytes_unchecked(data, (int16_t)layerpurpose);
}

static void _at_begin(struct export_data* data)
{
    // FIXME: put in real data, not fixed
    // HEADER
    _write_length_short(data, 6);
    export_data_append_byte(data, RECORDTYPE_HEADER);
    export_data_append_byte(data, DATATYPE_TWO_BYTE_INTEGER);
    export_data_append_byte(data, 0x02);
    export_data_append_byte(data, 0x58);
    // BGNLIB
    _write_length_short(data, 0x1c);
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
    _write_length_short(data, 10);
    export_data_append_byte(data, RECORDTYPE_LIBNAME);
    export_data_append_byte(data, DATATYPE_ASCII_STRING);
    export_data_append_byte(data, 0x6f);
    export_data_append_byte(data, 0x70);
    export_data_append_byte(data, 0x63);
    export_data_append_byte(data, 0x6c);
    export_data_append_byte(data, 0x69);
    export_data_append_byte(data, 0x62);
    // UNITS
    _write_length_short(data, 0x14);
    export_data_append_byte(data, RECORDTYPE_UNITS);
    export_data_append_byte(data, DATATYPE_EIGHT_BYTE_REAL);
    export_data_append_byte(data, 0x3e);
    export_data_append_byte(data, 0x41);
    export_data_append_byte(data, 0x89);
    export_data_append_byte(data, 0x37);
    export_data_append_byte(data, 0x4b);
    export_data_append_byte(data, 0xc6);
    export_data_append_byte(data, 0xa7);
    export_data_append_byte(data, 0xf0);
    export_data_append_byte(data, 0x39);
    export_data_append_byte(data, 0x44);
    export_data_append_byte(data, 0xb8);
    export_data_append_byte(data, 0x2f);
    export_data_append_byte(data, 0xa0);
    export_data_append_byte(data, 0x9b);
    export_data_append_byte(data, 0x5a);
    export_data_append_byte(data, 0x54);
}

static void _at_end(struct export_data* data)
{
    _write_length_short(data, 4);
    export_data_append_byte(data, RECORDTYPE_ENDLIB);
    export_data_append_byte(data, DATATYPE_NONE);
}

static void _at_begin_cell(struct export_data* data, const char* name)
{
    // BGNSTR
    _write_length_short(data, 28);
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
    size_t len = strlen(name);
    export_data_append_two_bytes(data, len % 2 ? len + 5 : len + 4);
    export_data_append_byte(data, RECORDTYPE_STRNAME);
    export_data_append_byte(data, DATATYPE_ASCII_STRING);
    export_data_append_string(data, name, len);
    if(len % 2)
    {
        export_data_append_nullbyte(data);
    }
}

static void _at_end_cell(struct export_data* data)
{
    _write_length_short(data, 4);
    export_data_append_byte(data, RECORDTYPE_ENDSTR);
    export_data_append_byte(data, DATATYPE_NONE);
}

static void _write_rectangle(struct export_data* data, const struct hashmap* layer, const point_t* bl, const point_t* tr)
{
    export_data_ensure_additional_capacity(data, 64); // a rectangle has exactly 64 bytes
    _write_layer_unchecked(data, RECORDTYPE_BOUNDARY, layer);

    // XY (44 bytes)
    unsigned int multiplier = 1; // FIXME: make proper use of units
    _write_length_short_unchecked(data, 44);
    export_data_append_byte_unchecked(data, RECORDTYPE_XY);
    export_data_append_byte_unchecked(data, DATATYPE_FOUR_BYTE_INTEGER);
    export_data_append_four_bytes_unchecked(data, multiplier * bl->x);
    export_data_append_four_bytes_unchecked(data, multiplier * bl->y);
    export_data_append_four_bytes_unchecked(data, multiplier * tr->x);
    export_data_append_four_bytes_unchecked(data, multiplier * bl->y);
    export_data_append_four_bytes_unchecked(data, multiplier * tr->x);
    export_data_append_four_bytes_unchecked(data, multiplier * tr->y);
    export_data_append_four_bytes_unchecked(data, multiplier * bl->x);
    export_data_append_four_bytes_unchecked(data, multiplier * tr->y);
    export_data_append_four_bytes_unchecked(data, multiplier * bl->x);
    export_data_append_four_bytes_unchecked(data, multiplier * bl->y);

    _write_ENDEL_unchecked(data); // 4 bytes
}

static void _write_polygon(struct export_data* data, const struct hashmap* layer, const struct vector* points)
{
    _write_layer(data, RECORDTYPE_BOUNDARY, RECORDTYPE_DATATYPE, layer);

    // XY
    unsigned int multiplier = 1; // FIXME: make proper use of units
    export_data_append_two_bytes(data, 4 + 4 * 2 * vector_size(points));
    export_data_append_byte(data, RECORDTYPE_XY);
    export_data_append_byte(data, DATATYPE_FOUR_BYTE_INTEGER); // FOUR_BYTE_INTEGER
    for(unsigned int i = 0; i < vector_size(points); ++i)
    {
        const point_t* pt = vector_get_const(points, i);
        export_data_append_four_bytes(data, multiplier * pt->x);
        export_data_append_four_bytes(data, multiplier * pt->y);
    }

    _write_ENDEL(data);
}

static void _write_path(struct export_data* data, const struct hashmap* layer, const struct vector* points, ucoordinate_t width, const coordinate_t* extension)
{
    _write_layer(data, RECORDTYPE_PATH, RECORDTYPE_DATATYPE, layer);

    // PATHTYPE
    _write_length_short(data, 6);
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
    _write_length_short(data, 8);
    export_data_append_byte(data, RECORDTYPE_WIDTH);
    export_data_append_byte(data, DATATYPE_FOUR_BYTE_INTEGER);
    export_data_append_four_bytes(data, width);

    // these records have to come after WIDTH (at least for klayout, but they also are in this order in the GDS manual)
    // BGNEXTN
    _write_length_short(data, 8);
    export_data_append_byte(data, RECORDTYPE_BGNEXTN);
    export_data_append_byte(data, DATATYPE_FOUR_BYTE_INTEGER);
    export_data_append_four_bytes(data, extension[0]);
    // ENDEXTN
    _write_length_short(data, 8);
    export_data_append_byte(data, RECORDTYPE_ENDEXTN);
    export_data_append_byte(data, DATATYPE_FOUR_BYTE_INTEGER);
    export_data_append_four_bytes(data, extension[1]);

    // XY
    unsigned int multiplier = 1; // FIXME: make proper use of units
    export_data_append_two_bytes(data, 4 + 4 * 2 * vector_size(points));
    export_data_append_byte(data, RECORDTYPE_XY);
    export_data_append_byte(data, DATATYPE_FOUR_BYTE_INTEGER); // FOUR_BYTE_INTEGER
    for(unsigned int i = 0; i < vector_size(points); ++i)
    {
        const point_t* pt = vector_get_const(points, i);
        export_data_append_four_bytes(data, multiplier * pt->x);
        export_data_append_four_bytes(data, multiplier * pt->y);
    }

    _write_ENDEL(data);
}

enum orientation
{
    R0,
    R90,
    R180,
    R270,
    MX,
    MY,
    MXR90,
    MYR90
};

static enum orientation _get_matrix_orientation(const struct transformationmatrix* matrix)
{
    point_t pt1 = { .x = 1, .y = 0 };
    point_t pt2 = { .x = 3, .y = 0 };
    point_t pt3 = { .x = 2, .y = 1 };
    transformationmatrix_apply_transformation_rot_mirr(matrix, &pt1);
    transformationmatrix_apply_transformation_rot_mirr(matrix, &pt2);
    transformationmatrix_apply_transformation_rot_mirr(matrix, &pt3);
    if((pt1.x < pt2.x) && (pt3.y > pt1.y))
    {
        return R0;
    }
    else if((pt1.x == pt2.x) && (pt3.x < pt1.x) && (pt3.y > pt1.y))
    {
        return R90;
    }
    else if((pt1.x > pt2.x) && (pt3.y < pt1.y))
    {
        return R180;
    }
    else if((pt1.x == pt2.x) && pt3.x > 0 && pt3.y < 0)
    {
        return R270;
    }
    else if((pt1.x < pt2.x) && (pt3.y < pt1.y))
    {
        return MX;
    }
    else if((pt1.x > pt2.x) && (pt3.y > pt1.y))
    {
        return MY;
    }
    else if((pt1.x == pt2.x) && (pt3.x < pt1.x))
    {
        return MXR90;
    }
    //else if((pt1.x == pt2.x) && (pt3.x > pt1.x))
    else
    {
        return MYR90;
    }
}

static void _write_reflection(struct export_data* data)
{
    _write_length_short(data, 6);
    export_data_append_byte(data, RECORDTYPE_STRANS);
    export_data_append_byte(data, DATATYPE_BIT_ARRAY);
    export_data_append_byte(data, 0x80);
    export_data_append_byte(data, 0x00);
}

static void _write_angle_90(struct export_data* data)
{
    _write_length_short(data, 12);
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
    _write_length_short(data, 12);
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
    _write_length_short(data, 12);
    export_data_append_byte(data, RECORDTYPE_ANGLE);
    export_data_append_byte(data, DATATYPE_EIGHT_BYTE_REAL);
    export_data_append_byte(data, 0x43);
    export_data_append_byte(data, 0x10);
    export_data_append_byte(data, 0x00);
    export_data_append_byte(data, 0x00);
    export_data_append_byte(data, 0x00);
    export_data_append_byte(data, 0x00);
    export_data_append_byte(data, 0x00);
    export_data_append_byte(data, 0x00);
}

static void _write_strans_angle(struct export_data* data, const struct transformationmatrix* trans)
{
    enum orientation orientation = _get_matrix_orientation(trans);
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

static void _write_cell_reference(struct export_data* data, const char* identifier, const char* instname, coordinate_t x, coordinate_t y, const struct transformationmatrix* trans)
{
    (void) instname; // GDSII does not support instance names
    // SREF
    _write_length_short(data, 4);
    export_data_append_byte(data, RECORDTYPE_SREF);
    export_data_append_byte(data, DATATYPE_NONE);

    // SNAME
    size_t len = 4 + strlen(identifier);
    if(len % 2 == 0)
    {
        export_data_append_two_bytes(data, len);
    }
    else
    {
        export_data_append_two_bytes(data, len + 1);
    }
    export_data_append_byte(data, RECORDTYPE_SNAME);
    export_data_append_byte(data, DATATYPE_ASCII_STRING);
    export_data_append_string(data, identifier, strlen(identifier));
    if(len % 2 == 1)
    {
        export_data_append_byte(data, 0x00);
    }

    _write_strans_angle(data, trans);

    unsigned int multiplier = 1; // FIXME: make proper use of units
    _write_length_short(data, 12);
    export_data_append_byte(data, RECORDTYPE_XY); // XY
    export_data_append_byte(data, DATATYPE_FOUR_BYTE_INTEGER); // FOUR_BYTE_INTEGER
    export_data_append_four_bytes(data, x * multiplier);
    export_data_append_four_bytes(data, y * multiplier);

    _write_ENDEL(data);
}

static void _write_cell_array(struct export_data* data, const char* identifier, const char* instbasename, coordinate_t x, coordinate_t y, const struct transformationmatrix* trans, unsigned int xrep, unsigned int yrep, unsigned int xpitch, unsigned int ypitch)
{
    (void) instbasename; // GDSII does not support instance names
    // AREF
    _write_length_short(data, 4);
    export_data_append_byte(data, RECORDTYPE_AREF);
    export_data_append_nullbyte(data);

    // SNAME
    size_t len = 4 + strlen(identifier);
    if(len % 2 == 0)
    {
        export_data_append_two_bytes(data, len);
    }
    else
    {
        export_data_append_two_bytes(data, len + 1);
    }
    export_data_append_byte(data, RECORDTYPE_SNAME);
    export_data_append_byte(data, DATATYPE_ASCII_STRING);
    export_data_append_string(data, identifier, strlen(identifier));
    if(len % 2 == 1)
    {
        export_data_append_nullbyte(data);
    }

    _write_strans_angle(data, trans);

    // COLROW
    _write_length_short(data, 8);
    export_data_append_byte(data, RECORDTYPE_COLROW);
    export_data_append_byte(data, DATATYPE_TWO_BYTE_INTEGER);
    export_data_append_two_bytes(data, xrep);
    export_data_append_two_bytes(data, yrep);

    // XY
    unsigned int multiplier = 1; // FIXME: make proper use of units
    _write_length_short(data, 28);
    export_data_append_byte(data, RECORDTYPE_XY); // XY
    export_data_append_byte(data, DATATYPE_FOUR_BYTE_INTEGER); // FOUR_BYTE_INTEGER
    export_data_append_four_bytes(data, x * multiplier);
    export_data_append_four_bytes(data, y * multiplier);
    export_data_append_four_bytes(data, (x + xrep * xpitch) * multiplier);
    export_data_append_four_bytes(data, y * multiplier);
    export_data_append_four_bytes(data, x * multiplier);
    export_data_append_four_bytes(data, (y + yrep * ypitch) * multiplier);

    _write_ENDEL(data);
}

static void _write_port(struct export_data* data, const char* name, const struct hashmap* layer, coordinate_t x, coordinate_t y, unsigned int sizehint)
{
    _write_layer(data, RECORDTYPE_TEXT, RECORDTYPE_TEXTTYPE, layer);

    // PRESENTATION
    _write_length_short(data, 6);
    export_data_append_byte(data, RECORDTYPE_PRESENTATION);
    export_data_append_byte(data, DATATYPE_BIT_ARRAY);
    export_data_append_byte(data, 0x00);
    export_data_append_byte(data, 0x05);

    _write_length_short(data, 12);
    export_data_append_byte(data, RECORDTYPE_MAG);
    export_data_append_byte(data, DATATYPE_EIGHT_BYTE_REAL);
    char sizedata[8];
    if(sizehint > 0)
    {
        double value = sizehint / 1000;
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
    unsigned int multiplier = 1; // FIXME: make proper use of units
    _write_length_short(data, 12);
    export_data_append_byte(data, RECORDTYPE_XY); // XY
    export_data_append_byte(data, DATATYPE_FOUR_BYTE_INTEGER); // FOUR_BYTE_INTEGER
    export_data_append_four_bytes(data, x * multiplier);
    export_data_append_four_bytes(data, y * multiplier);

    // NAME
    size_t len = strlen(name);
    export_data_append_two_bytes(data, len % 2 ? len + 5 : len + 4);
    export_data_append_byte(data, RECORDTYPE_STRING);
    export_data_append_byte(data, DATATYPE_ASCII_STRING);
    export_data_append_string(data, name, len);
    if(len % 2)
    {
        export_data_append_nullbyte(data);
    }

    _write_ENDEL(data);
}

static const char* _get_extension(void)
{
    return "gds";
}

struct export_functions* gdsexport_get_export_functions(void)
{
    struct export_functions* funcs = export_create_functions();
    funcs->at_begin = _at_begin;
    funcs->at_end = _at_end;
    funcs->at_begin_cell = _at_begin_cell;
    funcs->at_end_cell = _at_end_cell;
    funcs->write_rectangle = _write_rectangle;
    funcs->write_polygon = _write_polygon;
    funcs->write_path = _write_path;
    funcs->write_cell_reference = _write_cell_reference;
    funcs->write_cell_array = _write_cell_array;
    funcs->write_port = _write_port;
    funcs->get_extension = _get_extension;
    return funcs;
}


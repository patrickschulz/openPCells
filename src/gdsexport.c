#include "gdsexport.h"

#include <string.h>

static void _at_begin(struct export_data* data)
{
    // HEADER
    export_data_append_byte(data, 0x00);
    export_data_append_byte(data, 0x06);
    export_data_append_byte(data, 0x00);
    export_data_append_byte(data, 0x02);
    export_data_append_byte(data, 0x02);
    export_data_append_byte(data, 0x58);
    // BGNLIB
    export_data_append_byte(data, 0x00);
    export_data_append_byte(data, 0x1c);
    export_data_append_byte(data, 0x01);
    export_data_append_byte(data, 0x02);
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
    export_data_append_byte(data, 0x00);
    export_data_append_byte(data, 0x0a);
    export_data_append_byte(data, 0x02);
    export_data_append_byte(data, 0x06);
    export_data_append_byte(data, 0x6f);
    export_data_append_byte(data, 0x70);
    export_data_append_byte(data, 0x63);
    export_data_append_byte(data, 0x6c);
    export_data_append_byte(data, 0x69);
    export_data_append_byte(data, 0x62);
    // UNITS
    export_data_append_byte(data, 0x00);
    export_data_append_byte(data, 0x14);
    export_data_append_byte(data, 0x03);
    export_data_append_byte(data, 0x05);
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
    export_data_append_byte(data, 0x00);
    export_data_append_byte(data, 0x04);
    export_data_append_byte(data, 0x04);
    export_data_append_byte(data, 0x00);
}

static void _at_begin_cell(struct export_data* data, const char* name)
{
    // BGNSTR
    export_data_append_byte(data, 0x00);
    export_data_append_byte(data, 0x1c);
    export_data_append_byte(data, 0x05);
    export_data_append_byte(data, 0x02);
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
    export_data_append_byte(data, 0x06);
    export_data_append_byte(data, 0x06);
    export_data_append_string(data, name, len);
    if(len % 2)
    {
        export_data_append_byte(data, 0x00);
    }
}

static void _at_end_cell(struct export_data* data)
{
    export_data_append_byte(data, 0x00);
    export_data_append_byte(data, 0x04);
    export_data_append_byte(data, 0x07);
    export_data_append_byte(data, 0x00);
}

static void _write_rectangle(struct export_data* data, const struct keyvaluearray* layer, point_t* bl, point_t* tr)
{
    // BOUNDARY
    export_data_append_byte(data, 0x00);
    export_data_append_byte(data, 0x04);
    export_data_append_byte(data, 0x08);
    export_data_append_byte(data, 0x00);


    // LAYER
    export_data_append_byte(data, 0x00);
    export_data_append_byte(data, 0x06);
    export_data_append_byte(data, 0x0d);
    export_data_append_byte(data, 0x02);
    int layernum;
    keyvaluearray_get_int(layer, "layer", &layernum);
    export_data_append_two_bytes(data, layernum);

    // DATATYPE
    export_data_append_byte(data, 0x00);
    export_data_append_byte(data, 0x06);
    export_data_append_byte(data, 0x0e);
    export_data_append_byte(data, 0x02);
    int layerpurpose;
    keyvaluearray_get_int(layer, "purpose", &layerpurpose);
    export_data_append_two_bytes(data, layerpurpose);

    // XY
    unsigned int multiplier = 1; // FIXME: make proper use of units
    export_data_append_byte(data, 0x00);
    export_data_append_byte(data, 0x2c); // 44 bytes
    export_data_append_byte(data, 0x10); // XY
    export_data_append_byte(data, 0x03); // FOUR_BYTE_INTEGER
    export_data_append_four_bytes(data, multiplier * bl->x);
    export_data_append_four_bytes(data, multiplier * bl->y);
    export_data_append_four_bytes(data, multiplier * tr->x);
    export_data_append_four_bytes(data, multiplier * bl->y);
    export_data_append_four_bytes(data, multiplier * tr->x);
    export_data_append_four_bytes(data, multiplier * tr->y);
    export_data_append_four_bytes(data, multiplier * bl->x);
    export_data_append_four_bytes(data, multiplier * tr->y);
    export_data_append_four_bytes(data, multiplier * bl->x);
    export_data_append_four_bytes(data, multiplier * bl->y);

    // ENDEL
    export_data_append_byte(data, 0x00);
    export_data_append_byte(data, 0x04);
    export_data_append_byte(data, 0x11);
    export_data_append_byte(data, 0x00);
}

static void _write_polygon(struct export_data* data, const struct keyvaluearray* layer, point_t** points, size_t len)
{
    // BOUNDARY
    export_data_append_byte(data, 0x00);
    export_data_append_byte(data, 0x04);
    export_data_append_byte(data, 0x08);
    export_data_append_byte(data, 0x00);

    // LAYER
    export_data_append_byte(data, 0x00);
    export_data_append_byte(data, 0x06);
    export_data_append_byte(data, 0x0d);
    export_data_append_byte(data, 0x02);
    int layernum;
    keyvaluearray_get_int(layer, "layer", &layernum);
    export_data_append_two_bytes(data, layernum);

    // DATATYPE
    export_data_append_byte(data, 0x00);
    export_data_append_byte(data, 0x06);
    export_data_append_byte(data, 0x0e);
    export_data_append_byte(data, 0x02);
    int layerpurpose;
    keyvaluearray_get_int(layer, "purpose", &layerpurpose);
    export_data_append_two_bytes(data, layerpurpose);

    // XY
    unsigned int multiplier = 1; // FIXME: make proper use of units
    export_data_append_two_bytes(data, 4 + 4 * 2 * len);
    export_data_append_byte(data, 0x10); // XY
    export_data_append_byte(data, 0x03); // FOUR_BYTE_INTEGER
    for(unsigned int i = 0; i < len; ++i)
    {
        export_data_append_four_bytes(data, multiplier * points[i]->x);
        export_data_append_four_bytes(data, multiplier * points[i]->y);
    }

    // ENDEL
    export_data_append_byte(data, 0x00);
    export_data_append_byte(data, 0x04);
    export_data_append_byte(data, 0x11);
    export_data_append_byte(data, 0x00);
}

static void _write_path(struct export_data* data, const struct keyvaluearray* layer, point_t** points, size_t len, ucoordinate_t width, coordinate_t* extension)
{
    // PATH
    export_data_append_byte(data, 0x00);
    export_data_append_byte(data, 0x04);
    export_data_append_byte(data, 0x09);
    export_data_append_byte(data, 0x00);

    // LAYER
    export_data_append_byte(data, 0x00);
    export_data_append_byte(data, 0x06);
    export_data_append_byte(data, 0x0d);
    export_data_append_byte(data, 0x02);
    int layernum;
    keyvaluearray_get_int(layer, "layer", &layernum);
    export_data_append_two_bytes(data, layernum);

    // DATATYPE
    export_data_append_byte(data, 0x00);
    export_data_append_byte(data, 0x06);
    export_data_append_byte(data, 0x0e);
    export_data_append_byte(data, 0x02);
    int layerpurpose;
    keyvaluearray_get_int(layer, "purpose", &layerpurpose);
    export_data_append_two_bytes(data, layerpurpose);

    // PATHTYPE
    export_data_append_byte(data, 0x00);
    export_data_append_byte(data, 0x06);
    export_data_append_byte(data, 0x21);
    export_data_append_byte(data, 0x02);
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
    export_data_append_byte(data, 0x00);
    export_data_append_byte(data, 0x08);
    export_data_append_byte(data, 0x0f);
    export_data_append_byte(data, 0x03);
    export_data_append_four_bytes(data, width);

    // these records have to come after WIDTH (at least for klayout, but they also are in this order in the GDS manual)
    // BGNEXTN
    export_data_append_byte(data, 0x00);
    export_data_append_byte(data, 0x08);
    export_data_append_byte(data, 0x30);
    export_data_append_byte(data, 0x03);
    export_data_append_four_bytes(data, extension[0]);
    // ENDEXTN
    export_data_append_byte(data, 0x00);
    export_data_append_byte(data, 0x08);
    export_data_append_byte(data, 0x31);
    export_data_append_byte(data, 0x03);
    export_data_append_four_bytes(data, extension[1]);

    // XY
    unsigned int multiplier = 1; // FIXME: make proper use of units
    export_data_append_two_bytes(data, 4 + 4 * 2 * len);
    export_data_append_byte(data, 0x10); // XY
    export_data_append_byte(data, 0x03); // FOUR_BYTE_INTEGER
    for(unsigned int i = 0; i < len; ++i)
    {
        export_data_append_four_bytes(data, multiplier * points[i]->x);
        export_data_append_four_bytes(data, multiplier * points[i]->y);
    }

    // ENDEL
    export_data_append_byte(data, 0x00);
    export_data_append_byte(data, 0x04);
    export_data_append_byte(data, 0x11);
    export_data_append_byte(data, 0x00);
}

enum orientation
{
    R0,
    R90,
    R180,
    R270,
    MX,
    MY
};

static enum orientation _get_matrix_orientation(transformationmatrix_t* matrix)
{
    if(matrix->coefficients[0] >= 0 && matrix->coefficients[4] >= 0)
    {
        if(matrix->coefficients[1] < 0)
        {
            return R90;
        }
        else
        {
            return R0;
        }
    }
    else if(matrix->coefficients[0] <  0 && matrix->coefficients[4] >= 0)
    {
        return MY;
    }
    else if(matrix->coefficients[0] >= 0 && matrix->coefficients[4] <  0)
    {
        return MX;
    }
    else//if(matrix->coefficients[0] <  0 && matrix->coefficients[4] <  0)
    {
        return R180;
    }
    // FIXME: R270?
}

static void _write_cell_reference(struct export_data* data, const char* identifier, coordinate_t x, coordinate_t y, transformationmatrix_t* trans)
{
    // SREF
    export_data_append_byte(data, 0x00);
    export_data_append_byte(data, 0x04);
    export_data_append_byte(data, 0x0a);
    export_data_append_byte(data, 0x00);

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
    export_data_append_byte(data, 0x12);
    export_data_append_byte(data, 0x06);
    export_data_append_string(data, identifier, strlen(identifier));
    if(len % 2 == 1)
    {
        export_data_append_byte(data, 0x00);
    }

    // STRANS/ANGLE
    enum orientation orientation = _get_matrix_orientation(trans);
    switch(orientation)
    {
        case R0:
            break;
        case MX:
            // STRANS
            export_data_append_byte(data, 0x00);
            export_data_append_byte(data, 0x06);
            export_data_append_byte(data, 0x1a);
            export_data_append_byte(data, 0x01);
            export_data_append_byte(data, 0x80);
            export_data_append_byte(data, 0x00);
            break;
        case MY:
            // STRANS
            export_data_append_byte(data, 0x00);
            export_data_append_byte(data, 0x06);
            export_data_append_byte(data, 0x1a);
            export_data_append_byte(data, 0x01);
            export_data_append_byte(data, 0x80);
            export_data_append_byte(data, 0x00);
            // ANGLE (180 degrees)
            export_data_append_byte(data, 0x00);
            export_data_append_byte(data, 0x0c);
            export_data_append_byte(data, 0x1c);
            export_data_append_byte(data, 0x05);
            export_data_append_byte(data, 0x42);
            export_data_append_byte(data, 0xb4);
            export_data_append_byte(data, 0x00);
            export_data_append_byte(data, 0x00);
            export_data_append_byte(data, 0x00);
            export_data_append_byte(data, 0x00);
            export_data_append_byte(data, 0x00);
            export_data_append_byte(data, 0x00);
            break;
        case R90:
            // STRANS
            export_data_append_byte(data, 0x00);
            export_data_append_byte(data, 0x06);
            export_data_append_byte(data, 0x1a);
            export_data_append_byte(data, 0x01);
            export_data_append_byte(data, 0x00);
            export_data_append_byte(data, 0x00);
            // ANGLE (90 degrees)
            export_data_append_byte(data, 0x00);
            export_data_append_byte(data, 0x0c);
            export_data_append_byte(data, 0x1c);
            export_data_append_byte(data, 0x05);
            export_data_append_byte(data, 0x42);
            export_data_append_byte(data, 0x5a);
            export_data_append_byte(data, 0x00);
            export_data_append_byte(data, 0x00);
            export_data_append_byte(data, 0x00);
            export_data_append_byte(data, 0x00);
            export_data_append_byte(data, 0x00);
            export_data_append_byte(data, 0x00);
            break;
        case R180:
            // STRANS
            export_data_append_byte(data, 0x00);
            export_data_append_byte(data, 0x06);
            export_data_append_byte(data, 0x1a);
            export_data_append_byte(data, 0x01);
            export_data_append_byte(data, 0x00);
            export_data_append_byte(data, 0x00);
            // ANGLE (180 degrees)
            export_data_append_byte(data, 0x00);
            export_data_append_byte(data, 0x0c);
            export_data_append_byte(data, 0x1c);
            export_data_append_byte(data, 0x05);
            export_data_append_byte(data, 0x42);
            export_data_append_byte(data, 0xb4);
            export_data_append_byte(data, 0x00);
            export_data_append_byte(data, 0x00);
            export_data_append_byte(data, 0x00);
            export_data_append_byte(data, 0x00);
            export_data_append_byte(data, 0x00);
            export_data_append_byte(data, 0x00);
            break;
        case R270: //FIXME
            break;
    }

    unsigned int multiplier = 1; // FIXME: make proper use of units
    export_data_append_byte(data, 0x00);
    export_data_append_byte(data, 0x0c);
    export_data_append_byte(data, 0x10); // XY
    export_data_append_byte(data, 0x03); // FOUR_BYTE_INTEGER
    export_data_append_four_bytes(data, x * multiplier);
    export_data_append_four_bytes(data, y * multiplier);

    // ENDEL
    export_data_append_byte(data, 0x00);
    export_data_append_byte(data, 0x04);
    export_data_append_byte(data, 0x11);
    export_data_append_byte(data, 0x00);
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
    return funcs;
}

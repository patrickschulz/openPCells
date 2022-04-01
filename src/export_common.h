#ifndef OPC_LEXPORT_COMMON_H
#define OPC_LEXPORT_COMMON_H

#include <stdlib.h>
#include <string.h>
#include <math.h>

#include "generics.h"
#include "point.h"
#include "transformationmatrix.h"

struct export_data
{
    unsigned char* data;
    size_t length;
    size_t capacity;
};

struct export_data* export_create_data(void);
void export_destroy_data(struct export_data* data);
void export_data_append_byte(struct export_data* data, unsigned char byte);
void export_data_append_two_bytes(struct export_data* data, int16_t datum);
void export_data_append_four_bytes(struct export_data* data, int32_t datum);
void export_data_append_string(struct export_data* data, const char* str, size_t length);

struct export_functions
{
    void (*at_begin)(struct export_data*);
    void (*at_end)(struct export_data*);
    void (*at_begin_cell)(struct export_data*, const char*);
    void (*at_end_cell)(struct export_data*);
    void (*write_rectangle)(struct export_data*, const struct keyvaluearray*, point_t*, point_t*);
    void (*write_polygon)(struct export_data*, const struct keyvaluearray*, point_t**, size_t);
    void (*write_path)(struct export_data*, const struct keyvaluearray*, point_t**, size_t, ucoordinate_t, coordinate_t*);
    void (*write_cell_reference)(struct export_data*, const char*, coordinate_t, coordinate_t, transformationmatrix_t*);
    void (*write_cell_array)(struct export_data*, const char*, coordinate_t, coordinate_t, transformationmatrix_t*, unsigned int, unsigned int, unsigned int, unsigned int);
    void (*write_port)(struct export_data*, const char* name, const struct keyvaluearray*, coordinate_t x, coordinate_t y);
    const char* (*get_extension)(void);
};

struct export_functions* export_create_functions(void);
void export_destroy_functions(struct export_functions* funcs);

#endif // OPC_LEXPORT_COMMON_H

#ifndef OPC_LEXPORT_COMMON_H
#define OPC_LEXPORT_COMMON_H

#include <stdio.h> // FILE

#include "object.h"
#include "transformationmatrix.h"
#include "hashmap.h"

struct export_data;

struct export_data* export_create_data(void);
void export_destroy_data(struct export_data* data);

// checked functions
void export_data_append_nullbyte(struct export_data* data);
void export_data_append_byte(struct export_data* data, unsigned char byte);
void export_data_append_two_bytes(struct export_data* data, int16_t datum);
void export_data_append_four_bytes(struct export_data* data, int32_t datum);
void export_data_append_string(struct export_data* data, const char* str, size_t length);

// unchecked functions
void export_data_ensure_additional_capacity(struct export_data* data, size_t num);
void export_data_append_nullbyte_unchecked(struct export_data* data);
void export_data_append_byte_unchecked(struct export_data* data, unsigned char byte);
void export_data_append_two_bytes_unchecked(struct export_data* data, int16_t datum);
void export_data_append_four_bytes_unchecked(struct export_data* data, int32_t datum);
void export_data_append_string_unchecked(struct export_data* data, const char* str, size_t length);

// output
void export_data_write_to_file(struct export_data* data, FILE* file);

struct export_functions
{
    // initialization
    const char* (*get_extension)(void);
    const char* (*get_techexport)(void);
    void (*initialize)(const struct object*);
    // at begin/end
    void (*at_begin)(struct export_data*);
    void (*at_end)(struct export_data*);
    void (*at_begin_cell)(struct export_data*, const char*);
    void (*at_end_cell)(struct export_data*);
    // write basic shapes
    void (*write_rectangle)(struct export_data*, const struct hashmap*, const point_t*, const point_t*);
    void (*write_triangle)(struct export_data*, const struct hashmap*, const point_t*, const point_t*, const point_t*);
    void (*write_polygon)(struct export_data*, const struct hashmap*, const struct vector*);
    void (*write_path)(struct export_data*, const struct hashmap*, const struct vector*, ucoordinate_t, const coordinate_t*);
    // write curves
    void (*setup_curve)(struct export_data*, const struct hashmap);
    void (*curve_add_line_segment)(struct export_data*, const point_t*, const point_t*);
    void (*close_curve)(struct export_data*, const struct hashmap);
    // write references
    void (*write_cell_reference)(struct export_data*, const char*, coordinate_t, coordinate_t, const struct transformationmatrix*);
    void (*write_cell_array)(struct export_data*, const char*, coordinate_t, coordinate_t, const struct transformationmatrix*, unsigned int, unsigned int, unsigned int, unsigned int);
    // write ports
    void (*write_port)(struct export_data*, const char* name, const struct hashmap*, coordinate_t x, coordinate_t y);
};

struct export_functions* export_create_functions(void);
void export_destroy_functions(struct export_functions* funcs);

#endif // OPC_LEXPORT_COMMON_H

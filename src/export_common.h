#ifndef OPC_EXPORT_COMMON_H
#define OPC_EXPORT_COMMON_H

#include <stdio.h> // FILE

#include "object.h"
#include "transformationmatrix.h"
#include "hashmap.h"

struct export_data;

struct export_data* export_create_data(void);
void export_destroy_data(struct export_data* data);

// 'checked' functions
void export_data_append_nullbyte(struct export_data* data);
void export_data_append_byte(struct export_data* data, unsigned char byte);
void export_data_append_two_bytes(struct export_data* data, uint16_t datum);
void export_data_append_four_bytes(struct export_data* data, uint32_t datum);
void export_data_append_char(struct export_data* data, char ch);
void export_data_append_string_len(struct export_data* data, const char* str, size_t length);
void export_data_append_string(struct export_data* data, const char* str);

// 'unchecked' functions
void export_data_ensure_additional_capacity(struct export_data* data, size_t num);
void export_data_append_nullbyte_unchecked(struct export_data* data);
void export_data_append_byte_unchecked(struct export_data* data, unsigned char byte);
void export_data_append_two_bytes_unchecked(struct export_data* data, uint16_t datum);
void export_data_append_four_bytes_unchecked(struct export_data* data, uint32_t datum);
void export_data_append_string_unchecked(struct export_data* data, const char* str, size_t length);

// output
void export_data_write_to_file(struct export_data* data, FILE* file);

struct export_functions {
    // initialization/cleanup
    const char* (*get_extension)(void);
    const char* (*get_techexport)(void);
    void (*initialize)(const struct object*);
    int (*set_options)(const struct vector* vopt);
    void (*finalize)(void);
    // at begin/end
    void (*at_begin)(struct export_data*);
    void (*at_end)(struct export_data*);
    void (*at_begin_cell)(struct export_data*, const char*, int);
    void (*at_end_cell)(struct export_data*, int);
    // write basic shapes
    void (*write_rectangle)(struct export_data*, const struct hashmap*, const struct point*, const struct point*);
    void (*write_triangle)(struct export_data*, const struct hashmap*, const struct point*, const struct point*, const struct point*);
    void (*write_polygon)(struct export_data*, const struct hashmap*, const struct vector*);
    void (*write_path_extension)(struct export_data*, const struct hashmap*, const struct vector*, ucoordinate_t, const coordinate_t*);
    void (*write_path)(struct export_data*, const struct hashmap*, const struct vector*, ucoordinate_t);
    // write curves
    void (*setup_curve)(struct export_data*, const struct hashmap);
    void (*curve_add_line_segment)(struct export_data*, const struct point*, const struct point*);
    void (*close_curve)(struct export_data*, const struct hashmap);
    // write references
    void (*write_cell_reference)(struct export_data*, const char*, const char*, const struct point*, const struct transformationmatrix*);
    void (*write_cell_array)(struct export_data*, const char*, const char*, const struct point*, const struct transformationmatrix*, const struct transformationmatrix*, unsigned int, unsigned int, coordinate_t, coordinate_t);
    // write ports
    void (*write_port)(struct export_data*, const char* name, const struct hashmap*, const struct point* where, unsigned int sizehint);
    // write labels
    void (*write_label)(struct export_data*, const char* name, const struct hashmap*, const struct point* where, unsigned int sizehint);
};

struct export_functions* export_create_functions(void);
void export_destroy_functions(struct export_functions* funcs);

enum orientation {
    R0,
    R90,
    R180,
    R270,
    MX,
    MY,
    MXR90,
    MYR90
};
enum orientation export_get_matrix_orientation(const struct transformationmatrix* matrix);

#endif // OPC_EXPORT_COMMON_H

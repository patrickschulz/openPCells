#ifndef OPC_OBJECT_H
#define OPC_OBJECT_H

#include "transformationmatrix.h"
#include "shape.h"
#include "pcell.h"
#include "vector.h"
#include "hashmap.h"

struct object;

struct object* object_create(void);
struct object* object_copy(const struct object*);
void object_destroy(void* cell);

void object_add_raw_shape(struct object* cell, struct shape* S);
void object_add_shape(struct object* cell, struct shape* S);
struct shape* object_disown_shape(struct object* cell, size_t i);
void object_remove_shape(struct object* cell, size_t i);
struct object* object_add_child(struct object* cell, struct pcell_state* pcell_state, const char* identifier, const char* name);
struct object* object_add_child_array(struct object* cell, struct pcell_state* pcell_state, const char* identifier, unsigned int xrep, unsigned int yrep, unsigned int xpitch, unsigned int ypitch, const char* name);
void object_merge_into_shallow(struct object* cell, const struct object* other);
void object_add_anchor(struct object* cell, const char* name, coordinate_t x, coordinate_t y);
void object_add_anchor_area(struct object* cell, const char* base, coordinate_t width, coordinate_t height, coordinate_t xshift, coordinate_t yshift);
void object_add_anchor_area_bltr(struct object* cell, const char* base, const point_t* bl, const point_t* tr);
point_t* object_get_anchor(const struct object* cell, const char* name);
const struct hashmap* object_get_all_regular_anchors(const struct object* cell);
void object_add_port(struct object* cell, const char* name, const struct generics* layer, const point_t* where, int storeanchor);
void object_add_bus_port(struct object* cell, const char* name, const struct generics* layer, const point_t* where, int startindex, int endindex, unsigned int xpitch, unsigned int ypitch, int storeanchor);
struct vector* object_get_ports(struct object* cell);
void object_set_alignment_box(struct object* cell, coordinate_t blx, coordinate_t bly, coordinate_t trx, coordinate_t try);
void object_inherit_alignment_box(struct object* cell, const struct object* other);
void object_get_minmax_xy(const struct object* cell, coordinate_t* minxp, coordinate_t* minyp, coordinate_t* maxxp, coordinate_t* maxyp);
void object_foreach_shapes(struct object* cell, void (*func)(struct shape*));

size_t object_get_shapes_size(const struct object* cell);
struct shape* object_get_shape(struct object* cell, size_t idx);
struct shape* object_get_transformed_shape(struct object* cell, size_t idx);

const struct transformationmatrix* object_get_transformation_matrix(const struct object* cell);

// transformations
void object_move_to(struct object* cell, coordinate_t x, coordinate_t y);
void object_translate(struct object* cell, coordinate_t x, coordinate_t y);
void object_mirror_at_xaxis(struct object* cell);
void object_mirror_at_yaxis(struct object* cell);
void object_mirror_at_origin(struct object* cell);
void object_rotate_90_left(struct object* cell);
void object_rotate_90_right(struct object* cell);
void object_flipx(struct object* cell);
void object_flipy(struct object* cell);
int object_move_anchor(struct object* cell, const char* name, coordinate_t x, coordinate_t y);
int object_move_anchor_x(struct object* cell, const char* name, coordinate_t x);
int object_move_anchor_y(struct object* cell, const char* name, coordinate_t y);
void object_scale(struct object* cell, double factor);

void object_apply_transformation(struct object* cell);
void object_transform_point(const struct object* cell, point_t* pt);
int object_has_shapes(const struct object* cell);
int object_has_children(const struct object* cell);
int object_has_ports(const struct object* cell);
int object_is_empty(const struct object* cell);
void object_flatten_inline(struct object* cell, struct pcell_state* pcell_state, int flattenports);
struct object* object_flatten(const struct object* cell, struct pcell_state* pcell_state, int flattenports);

int object_is_child_array(const struct object* cell);
unsigned int object_get_child_xrep(const struct object* cell);
unsigned int object_get_child_yrep(const struct object* cell);
unsigned int object_get_child_xpitch(const struct object* cell);
unsigned int object_get_child_ypitch(const struct object* cell);
const char* object_get_identifier(const struct object* cell);

// shape iterator
struct shape_iterator;
struct shape_iterator* object_create_shape_iterator(const struct object*);
int shape_iterator_is_valid(struct shape_iterator* it);
void shape_iterator_next(struct shape_iterator* it);
const struct shape* shape_iterator_get(struct shape_iterator* it);
void shape_iterator_destroy(struct shape_iterator* it);;

// child iterator
struct child_iterator;
struct child_iterator* object_create_child_iterator(const struct object* cell);
int child_iterator_is_valid(struct child_iterator* it);
void child_iterator_next(struct child_iterator* it);
const struct object* child_iterator_get(struct child_iterator* it);
void child_iterator_destroy(struct child_iterator* it);

// port iterator
struct port_iterator;
struct port_iterator* object_create_port_iterator(const struct object* cell);
int port_iterator_is_valid(struct port_iterator* it);
void port_iterator_next(struct port_iterator* it);
void port_iterator_get(struct port_iterator* it, const char** portname, const point_t** portwhere, const struct generics** portlayer, int* portisbusport, int* portbusindex);
void port_iterator_destroy(struct port_iterator* it);

#endif // OPC_OBJECT_H

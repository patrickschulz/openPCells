#ifndef OPC_OBJECT_H
#define OPC_OBJECT_H

#include "hashmap.h"
#include "polygon.h"
#include "shape.h"
#include "transformationmatrix.h"
#include "vector.h"

struct object;

// object construction/destruction
struct object* object_create(const char* name);
struct object* object_create_pseudo(void);
struct object* object_copy(const struct object*);
void object_destroy(void* cell);
const char* object_get_name(const struct object* cell);
void object_set_name(struct object* cell, const char* name);

// shape handling
void object_add_raw_shape(struct object* cell, struct shape* S);
void object_add_shape(struct object* cell, struct shape* S);
struct shape* object_disown_shape(struct object* cell, size_t i);
void object_remove_shape(struct object* cell, size_t i);
void object_merge_into(struct object* cell, const struct object* other);
void object_merge_into_with_ports(struct object* cell, const struct object* other);
void object_foreach_shapes(struct object* cell, void (*func)(struct shape*));
size_t object_get_shapes_size(const struct object* cell);
struct shape* object_get_shape(struct object* cell, size_t idx);
struct shape* object_get_transformed_shape(struct object* cell, size_t idx);
void object_rasterize_curves(struct object* cell);

// children
struct object* object_create_handle(struct object* cell, struct object* reference);
struct object* object_add_child(struct object* cell, struct object* child, const char* name);
struct object* object_add_child_array(struct object* cell, struct object* child, const char* name, unsigned int xrep, unsigned int yrep, coordinate_t xpitch, coordinate_t ypitch);

// anchors
int object_add_anchor(struct object* cell, const char* name, coordinate_t x, coordinate_t y);
int object_add_area_anchor_bltr(struct object* cell, const char* base, const point_t* bl, const point_t* tr);
int object_inherit_anchor(struct object* cell, const struct object* other, const char* name);
int object_inherit_anchor_as(struct object* cell, const struct object* other, const char* name, const char* newname);
int object_inherit_area_anchor(struct object* cell, const struct object* other, const char* name);
int object_inherit_area_anchor_as(struct object* cell, const struct object* other, const char* name, const char* newname);
void object_inherit_all_anchors_with_prefix(struct object* cell, const struct object* other, const char* prefix);
point_t* object_get_anchor(const struct object* cell, const char* name);
point_t* object_get_alignment_anchor(const struct object* cell, const char* name);
point_t* object_get_area_anchor(const struct object* cell, const char* base);
point_t* object_get_array_anchor(const struct object* cell, int xindex, int yindex, const char* name);
point_t* object_get_array_area_anchor(const struct object* cell, int xindex, int yindex, const char* name);
point_t* object_get_alignmentbox_anchor_outerbl(const struct object* cell);
point_t* object_get_alignmentbox_anchor_outertr(const struct object* cell);
point_t* object_get_alignmentbox_anchor_innerbl(const struct object* cell);
point_t* object_get_alignmentbox_anchor_innertr(const struct object* cell);
const struct hashmap* object_get_all_regular_anchors(const struct object* cell);

// abutment and alignment
int object_abut_right(struct object* cell, const struct object* other);
int object_abut_left(struct object* cell, const struct object* other);
int object_abut_top(struct object* cell, const struct object* other);
int object_abut_bottom(struct object* cell, const struct object* other);
int object_abut_right_origin(struct object* cell);
int object_abut_left_origin(struct object* cell);
int object_abut_top_origin(struct object* cell);
int object_abut_bottom_origin(struct object* cell);
int object_align_right(struct object* cell, const struct object* other);
int object_align_left(struct object* cell, const struct object* other);
int object_align_top(struct object* cell, const struct object* other);
int object_align_bottom(struct object* cell, const struct object* other);
int object_align_right_origin(struct object* cell);
int object_align_left_origin(struct object* cell);
int object_align_top_origin(struct object* cell);
int object_align_bottom_origin(struct object* cell);

// anchor alignment
int object_abut_area_anchor_right(struct object* cell, const char* anchorname, const struct object* other, const char* otheranchorname);
int object_abut_area_anchor_left(struct object* cell, const char* anchorname, const struct object* other, const char* otheranchorname);
int object_abut_area_anchor_top(struct object* cell, const char* anchorname, const struct object* other, const char* otheranchorname);
int object_abut_area_anchor_bottom(struct object* cell, const char* anchorname, const struct object* other, const char* otheranchorname);
int object_area_anchors_fit(const struct object* cell, const char* anchorname, const struct object* other, const char* otheranchorname);
int object_align_area_anchor(struct object* cell, const char* anchorname, const struct object* other, const char* otheranchorname);
int object_align_area_anchor_x(struct object* cell, const char* anchorname, const struct object* other, const char* otheranchorname);
int object_align_area_anchor_left(struct object* cell, const char* anchorname, const struct object* other, const char* otheranchorname);
int object_align_area_anchor_right(struct object* cell, const char* anchorname, const struct object* other, const char* otheranchorname);
int object_align_area_anchor_y(struct object* cell, const char* anchorname, const struct object* other, const char* otheranchorname);
int object_align_area_anchor_top(struct object* cell, const char* anchorname, const struct object* other, const char* otheranchorname);
int object_align_area_anchor_bottom(struct object* cell, const char* anchorname, const struct object* other, const char* otheranchorname);

// boundary
int object_has_boundary(const struct object* cell);
void object_set_boundary(struct object* cell, struct vector* boundary);
void object_set_empty_layer_boundary(struct object* cell, const struct generics* layer);
void object_add_layer_boundary(struct object* cell, const struct generics* layer, struct simple_polygon* new);
void object_inherit_boundary(struct object* cell, const struct object* othercell);
int object_has_boundary(const struct object* cell);
struct vector* object_get_boundary(const struct object* cell);
int object_has_layer_boundary(const struct object* cell, const struct generics* layer);
struct polygon* object_get_layer_boundary(const struct object* cell, const struct generics* layer);
void object_inherit_layer_boundary(struct object* cell, const struct object* othercell, const struct generics* layer);

// ports
void object_add_port(struct object* cell, const char* name, const struct generics* layer, const point_t* where, unsigned int sizehint);
void object_add_bus_port(struct object* cell, const char* name, const struct generics* layer, const point_t* where, int startindex, int endindex, coordinate_t xpitch, coordinate_t ypitch, unsigned int sizehint);
const struct vector* object_get_ports(const struct object* cell);

// labels
void object_add_label(struct object* cell, const char* name, const struct generics* layer, const point_t* where, unsigned int sizehint);

// alignment box and bounding box
void object_clear_alignment_box(struct object* cell);
void object_set_alignment_box(
    struct object* cell,
    coordinate_t outerblx, coordinate_t outerbly,
    coordinate_t outertrx, coordinate_t outertry,
    coordinate_t innerblx, coordinate_t innerbly,
    coordinate_t innertrx, coordinate_t innertry
);
void object_inherit_alignment_box(struct object* cell, const struct object* other);
void object_alignment_box_include_point(struct object* cell, const point_t* pt);
void object_alignment_box_include_x(struct object* cell, coordinate_t x);
void object_alignment_box_include_y(struct object* cell, coordinate_t y);
int object_extend_alignment_box(
    struct object* cell,
    coordinate_t extouterblx, coordinate_t extouterbly,
    coordinate_t extoutertrx, coordinate_t extoutertry,
    coordinate_t extinnerblx, coordinate_t extinnerbly,
    coordinate_t extinnertrx, coordinate_t extinnertry);
int object_get_alignment_box_corners(
    const struct object* cell,
    coordinate_t* outerblx, coordinate_t* outerbly, coordinate_t* outertrx, coordinate_t* outertry,
    coordinate_t* innerblx, coordinate_t* innerbly, coordinate_t* innertrx, coordinate_t* innertry
);
void object_get_minmax_xy(const struct object* cell, coordinate_t* minxp, coordinate_t* minyp, coordinate_t* maxxp, coordinate_t* maxyp, const struct transformationmatrix* extratrans);
void object_width_height_alignmentbox(const struct object* cell, ucoordinate_t* width, ucoordinate_t* height);

// transformations
const struct transformationmatrix* object_get_transformation_matrix(const struct object* cell);
void object_move_to(struct object* cell, coordinate_t x, coordinate_t y);
void object_reset_translation(struct object* cell);
void object_translate(struct object* cell, coordinate_t x, coordinate_t y);
void object_translate_x(struct object* cell, coordinate_t x);
void object_translate_y(struct object* cell, coordinate_t y);
void object_mirror_at_xaxis(struct object* cell);
void object_mirror_at_yaxis(struct object* cell);
void object_mirror_at_origin(struct object* cell);
void object_rotate_90_left(struct object* cell);
void object_rotate_90_right(struct object* cell);
void object_flipx(struct object* cell);
void object_flipy(struct object* cell);
int object_move_point(struct object* cell, const point_t* source, const point_t* target);
int object_move_point_to_origin(struct object* cell, const point_t* target);
int object_move_point_to_origin_xy(struct object* cell, coordinate_t x, coordinate_t y);
int object_move_point_x(struct object* cell, const point_t* source, const point_t* target);
int object_move_point_y(struct object* cell, const point_t* source, const point_t* target);
void object_scale(struct object* cell, double factor);
void object_apply_transformation(struct object* cell);
void object_transform_point(const struct object* cell, point_t* pt);
void object_apply_other_transformation(struct object* cell, const struct transformationmatrix* trans);

// object info
int object_is_proxy(const struct object* cell);
int object_is_pseudo(const struct object* cell);
int object_has_shapes(const struct object* cell);
int object_has_children(const struct object* cell);
int object_has_ports(const struct object* cell);
int object_is_empty(const struct object* cell);
int object_is_used(const struct object* cell);
int object_is_child_array(const struct object* cell);
int object_has_anchor(const struct object* cell, const char* anchorname);
int object_has_area_anchor(const struct object* cell, const char* anchorname);
int object_has_alignmentbox(const struct object* cell);
const char* object_get_name(const struct object* cell);
const char* object_get_child_reference_name(const struct object* child);

coordinate_t object_get_area_anchor_width(const struct object* cell, const char* anchorname);
coordinate_t object_get_area_anchor_height(const struct object* cell, const char* anchorname);

void object_flatten_inline(struct object* cell, int flattenports);
struct object* object_flatten(const struct object* cell, int flattenports);

unsigned int object_get_child_xrep(const struct object* cell);
unsigned int object_get_child_yrep(const struct object* cell);
coordinate_t object_get_child_xpitch(const struct object* cell);
coordinate_t object_get_child_ypitch(const struct object* cell);

struct const_vector* object_collect_references(const struct object* cell);
struct vector* object_collect_references_mutable(struct object* cell);

// shape iterator
struct shape_iterator;
struct shape_iterator* object_create_shape_iterator(const struct object*);
int shape_iterator_is_valid(struct shape_iterator* it);
void shape_iterator_next(struct shape_iterator* it);
const struct shape* shape_iterator_get(struct shape_iterator* it);
void shape_iterator_destroy(struct shape_iterator* it);

// child iterator
struct child_iterator;
struct child_iterator* object_create_child_iterator(const struct object* cell);
int child_iterator_is_valid(struct child_iterator* it);
void child_iterator_next(struct child_iterator* it);
const struct object* child_iterator_get(struct child_iterator* it);
void child_iterator_destroy(struct child_iterator* it);

// reference iterator
struct reference_iterator;
struct reference_iterator* object_create_reference_iterator(const struct object* cell);
int reference_iterator_is_valid(struct reference_iterator* it);
void reference_iterator_next(struct reference_iterator* it);
const struct object* reference_iterator_get(struct reference_iterator* it);
void reference_iterator_destroy(struct reference_iterator* it);

// mutable reference iterator
struct mutable_reference_iterator;
struct mutable_reference_iterator* object_create_mutable_reference_iterator(struct object* cell);
int mutable_reference_iterator_is_valid(struct mutable_reference_iterator* it);
void mutable_reference_iterator_next(struct mutable_reference_iterator* it);
struct object* mutable_reference_iterator_get(struct mutable_reference_iterator* it);
void mutable_reference_iterator_destroy(struct mutable_reference_iterator* it);

// anchor iterator
struct anchor_iterator;
struct anchor_iterator* object_create_anchor_iterator(const struct object* cell);
int anchor_iterator_is_valid(struct anchor_iterator* it);
void anchor_iterator_next(struct anchor_iterator* it);
int anchor_iterator_is_area(struct anchor_iterator* it);
const point_t* anchor_iterator_anchor(struct anchor_iterator* it);
const char* anchor_iterator_name(struct anchor_iterator* it);
void anchor_iterator_destroy(struct anchor_iterator* it);

// port iterator
struct port_iterator;
struct port_iterator* object_create_port_iterator(const struct object* cell);
int port_iterator_is_valid(struct port_iterator* it);
void port_iterator_next(struct port_iterator* it);
void port_iterator_get(struct port_iterator* it, const char** portname, const point_t** portwhere, const struct generics** portlayer, int* portisbusport, int* portbusindex, unsigned int* sizehint);
void port_iterator_destroy(struct port_iterator* it);

// label iterator
struct label_iterator;
struct label_iterator* object_create_label_iterator(const struct object* cell);
int label_iterator_is_valid(struct label_iterator* it);
void label_iterator_next(struct label_iterator* it);
void label_iterator_get(struct label_iterator* it, const char** labelname, const point_t** labelwhere, const struct generics** labellayer, unsigned int* sizehint);
void label_iterator_destroy(struct label_iterator* it);

#endif // OPC_OBJECT_H

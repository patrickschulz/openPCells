/*
 * This header is solely used by object.public.c.
 * It declares the lower-level access interface to objects,
 * which are used by the object.public functions.
 * Essentially, there should be a counterpart in this file
 * for every public object function.
 * The public interface merely defines what an object can do
 * and passes dealing with the details to the 'base' functions.
 */

#ifndef OPC_OBJECT_IMPLEMENTATION
#error "This header must only be included in the implementation files of the object module. It is not intended for external use."
#endif

#ifndef OPC_OBJECT_BASE_H
#define OPC_OBJECT_BASE_H

// alignmentbox access macros
#define objectbase_alignmentbox_get_outerblx(b) b[0]
#define objectbase_alignmentbox_get_outerbly(b) b[1]
#define objectbase_alignmentbox_get_outertrx(b) b[2]
#define objectbase_alignmentbox_get_outertry(b) b[3]
#define objectbase_alignmentbox_get_innerblx(b) b[4]
#define objectbase_alignmentbox_get_innerbly(b) b[5]
#define objectbase_alignmentbox_get_innertrx(b) b[6]
#define objectbase_alignmentbox_get_innertry(b) b[7]

// bounding box access macros
#define objectbase_boundingbox_get_blx(b) b[0]
#define objectbase_boundingbox_get_bly(b) b[1]
#define objectbase_boundingbox_get_trx(b) b[2]
#define objectbase_boundingbox_get_try(b) b[3]

// area anchor access macros
#define objectbase_area_anchor_get_blx(pts) pts[0].x
#define objectbase_area_anchor_get_bly(pts) pts[0].y
#define objectbase_area_anchor_get_trx(pts) pts[1].x
#define objectbase_area_anchor_get_try(pts) pts[1].y

struct object* objectbase_create(
    const char* name
);
struct object* objectbase_create_pseudo(void);
struct object* objectbase_create_proxy(
    const char* name,
    struct object* reference
);
struct object* objectbase_copy(
    const struct object* cell
);
void objectbase_destroy(
    void* cellv
);
void objectbase_set_name(
    struct object* cell,
    const char* name
);
void objectbase_add_raw_shape(
    struct object* cell,
    struct shape* S
);
void objectbase_add_shape(
    struct object* cell,
    struct shape* S
);
void objectbase_remove_shape(
    struct object* cell,
    size_t idx
);
struct shape* objectbase_disown_shape(
    struct object* cell,
    size_t idx
);
void objectbase_set_managed(
    struct object* reference
);
void objectbase_set_unused(
    struct object* reference
);
void objectbase_set_used(
    struct object* reference
);
void objectbase_add_reference(
    struct object* cell,
    struct object* reference
);
void objectbase_add_proxy(
    struct object* cell,
    struct object* proxy
);
const struct object* objectbase_get_reference(const struct object* cell);
struct object* objectbase_get_reference_mutable(struct object* cell);
const struct transformationmatrix* objectbase_get_tmatrix(
    const struct object* cell
);
const struct transformationmatrix* objectbase_get_array_tmatrix(
    const struct object* cell
);
struct transformationmatrix* objectbase_get_inverted_tmatrix(
    const struct object* cell
);
void objectbase_set_tmatrix(
    struct object* cell,
    struct transformationmatrix* trans
);
void objectbase_set_array(
    struct object* cell,
    unsigned int xrep, unsigned int yrep,
    coordinate_t xpitch, coordinate_t ypitch
);
void objectbase_merge_into(
    struct object* cell,
    const struct object* other,
    int merge_ports
);
int objectbase_add_anchor(
    struct object* cell,
    const char* name,
    coordinate_t x, coordinate_t y
);
int objectbase_add_area_anchor_bltr(
    struct object* cell,
    const char* name,
    coordinate_t blx, coordinate_t bly,
    coordinate_t trx, coordinate_t try
);
void objectbase_inherit_all_anchors_with_prefix(
    struct object* cell,
    const struct object* other,
    const char* prefix
);
int objectbase_add_anchor_line_x(
    struct object* cell,
    const char* name,
    coordinate_t c
);
int objectbase_add_anchor_line_y(
    struct object* cell,
    const char* name,
    coordinate_t c
);
void objectbase_transform_to_local_coordinates_xy(
    const struct object* cell,
    coordinate_t* x,
    coordinate_t* y
);
void objectbase_transform_to_local_coordinates(
    const struct object* cell,
    struct point* pt
);
void objectbase_transform_to_local_coordinates_shape(
    const struct object* cell,
    struct shape* shape
);
void objectbase_transform_to_global_coordinates_xy(
    const struct object* cell,
    coordinate_t* x, coordinate_t* y
);
void objectbase_transform_to_global_coordinates(
    const struct object* cell,
    struct point* pt
);
void objectbase_transform_to_global_coordinates_shape(
    const struct object* cell,
    struct shape* shape
);
void objectbase_transform_to_local_coordinates_pts(
    const struct object* cell,
    struct vector* pts
);
void objectbase_transform_to_global_coordinates_vector(
    const struct object* cell,
    struct vector* pts
);
void objectbase_transform_to_global_coordinates_polygon_container(
    const struct object* cell,
    struct polygon_container* polygon
);
coordinate_t* objectbase_get_untransformed_alignment_box(
    const struct object* cell
);
coordinate_t* objectbase_get_transformed_alignment_box(
    const struct object* cell
);
coordinate_t* objectbase_get_untransformed_minmax_xy(
    const struct object* cell
);
coordinate_t* objectbase_get_minmax_xy(
    const struct object* cell
);
coordinate_t* objectbase_get_transformed_bounding_box(
    const struct object* cell
);
int objectbase_has_anchor(
    const struct object* cell,
    const char* name
);
int objectbase_has_area_anchor(
    const struct object* cell,
    const char* name
);
struct point* objectbase_get_anchor(
    const struct object* cell,
    const char* name
);
struct point* objectbase_get_array_anchor(
    const struct object* cell,
    int xindex, int yindex,
    const char* name
);
struct point* objectbase_get_area_anchor(
    const struct object* cell,
    const char* name
);
struct point* objectbase_get_array_area_anchor(
    const struct object* cell,
    int xindex, int yindex,
    const char* base
);
coordinate_t* objectbase_get_anchor_line(
    const struct object* cell,
    const char* name
);
void objectbase_set_boundary(
    struct object* cell,
    struct vector* boundary
);
struct vector* objectbase_get_boundary(
    const struct object* cell
);
void objectbase_inherit_boundary(
    struct object* cell,
    const struct object* othercell
);
int objectbase_has_boundary(
    const struct object* cell
);
void objectbase_set_empty_layer_boundary(
    struct object* cell,
    const struct generics* layer
);
void objectbase_add_layer_boundary(
    struct object* cell,
    const struct generics* layer,
    struct simple_polygon* new
);
void objectbase_inherit_layer_boundary(
    struct object* cell,
    const struct object* othercell,
    const struct generics* layer
);
int objectbase_has_layer_boundary(
    const struct object* cell,
    const struct generics* layer
);
struct polygon_container* objectbase_get_layer_boundary(
    const struct object* cell,
    const struct generics* layer
);
void objectbase_add_port(
    struct object* cell,
    const char* name,
    const struct generics* layer,
    const struct point* where,
    unsigned int sizehint
);
void objectbase_add_bus_port(
    struct object* cell,
    const char* name,
    const struct generics* layer,
    const struct point* where,
    int startindex,
    int endindex,
    coordinate_t xpitch,
    coordinate_t ypitch,
    unsigned int sizehint
);
void objectbase_add_label(
    struct object* cell,
    const char* name,
    const struct generics* layer,
    const struct point* where,
    unsigned int sizehint
);
void objectbase_add_net_shape(
    struct object* cell,
    const char* netname,
    const struct point* bl,
    const struct point* tr,
    const struct generics* layer
);
struct vector* objectbase_get_net_shapes(
    const struct object* cell,
    const char* netname,
    const struct generics* layer
);
struct vector* objectbase_get_array_net_shapes(
    const struct object* cell,
    int xindex,
    int yindex,
    const char* netname,
    const struct generics* layer
);
void objectbase_clear_alignment_box(
    struct object* cell
);
void objectbase_set_alignment_box(
    struct object* cell,
    coordinate_t outerblx, coordinate_t outerbly,
    coordinate_t outertrx, coordinate_t outertry,
    coordinate_t innerblx, coordinate_t innerbly,
    coordinate_t innertrx, coordinate_t innertry
);
void objectbase_inherit_alignment_box(
    struct object* cell,
    const struct object* other
);
void objectbase_alignment_box_include_point(
    struct object* cell,
    const struct point* pt
);
void objectbase_alignment_box_include_x(
    struct object* cell,
    coordinate_t x
);
void objectbase_alignment_box_include_y(
    struct object* cell,
    coordinate_t y
);
int objectbase_extend_alignment_box(
    struct object* cell,
    coordinate_t extouterblx, coordinate_t extouterbly,
    coordinate_t extoutertrx, coordinate_t extoutertry,
    coordinate_t extinnerblx, coordinate_t extinnerbly,
    coordinate_t extinnertrx, coordinate_t extinnertry
);
int objectbase_get_alignment_box_corners(
    const struct object* cell,
    coordinate_t* outerblx, coordinate_t* outerbly, coordinate_t* outertrx, coordinate_t* outertry,
    coordinate_t* innerblx, coordinate_t* innerbly, coordinate_t* innertrx, coordinate_t* innertry
);
void objectbase_move_to(
    struct object* cell,
    coordinate_t x, coordinate_t y
);
void objectbase_translate(
    struct object* cell,
    coordinate_t x, coordinate_t y
);
void objectbase_reset_translation(
    struct object* cell
);
void objectbase_mirror_at_xaxis(
    struct object* cell
);
void objectbase_mirror_at_yaxis(
    struct object* cell
);
void objectbase_mirror_at_origin(
    struct object* cell
);
void objectbase_rotate_90_left(
    struct object* cell
);
void objectbase_rotate_90_right(
    struct object* cell
);
void objectbase_array_rotate_90_left(
    struct object* cell
);
void objectbase_array_rotate_90_right(
    struct object* cell
);
int objectbase_move_x(
    struct object* cell,
    coordinate_t source,
    coordinate_t target
);
int objectbase_move_y(
    struct object* cell,
    coordinate_t source,
    coordinate_t target
);
int objectbase_move_point(
    struct object* cell,
    const struct point* source,
    const struct point* target
);
int objectbase_move_point_to_origin(
    struct object* cell,
    const struct point* target
);
int objectbase_move_point_to_origin_xy(
    struct object* cell,
    coordinate_t x, coordinate_t y
);
int objectbase_move_point_x(
    struct object* cell,
    const struct point* source,
    const struct point* target
);
int objectbase_move_point_y(
    struct object* cell,
    const struct point* source,
    const struct point* target
);
int objectbase_center(
    struct object* cell,
    const struct point* target
);
int objectbase_center_x(
    struct object* cell,
    const struct point* target
);
int objectbase_center_y(
    struct object* cell,
    const struct point* target
);
void objectbase_scale(
    struct object* cell,
    double factor
);
void objectbase_foreach_shapes(
    struct object* cell,
    void (*func)(struct shape*)
);
size_t objectbase_get_shapes_size(
    const struct object* cell
);
struct shape* objectbase_get_shape(
    struct object* cell,
    size_t idx
);
const struct shape* objectbase_get_shape_const(
    const struct object* cell,
    size_t idx
);
struct shape* objectbase_get_transformed_shape(
    const struct object* cell,
    size_t idx
);
void objectbase_rasterize_curves(
    struct object* cell
);
struct polygon_container* objectbase_get_shape_outlines(
    const struct object* cell,
    const struct generics* layer
);
const struct transformationmatrix* objectbase_get_transformation_matrix(
    const struct object* cell
);
const struct transformationmatrix* objectbase_get_array_transformation_matrix(
    const struct object* cell
);
void objectbase_flipx(
    struct object* cell
);
void objectbase_flipy(
    struct object* cell
);
void objectbase_transform_point(
    const struct object* cell,
    struct point* pt
);
int objectbase_is_pseudo(
    const struct object* cell
);
int objectbase_is_proxy(
    const struct object* cell
);
int objectbase_has_shapes(
    const struct object* cell
);
int objectbase_has_layer_flat(
    const struct object* cell,
    const struct generics* layer
);
int objectbase_has_layer(
    const struct object* cell,
    const struct generics* layer
);
int objectbase_has_children(
    const struct object* cell
);
int objectbase_has_ports(
    const struct object* cell
);
const struct vector* objectbase_get_ports(
    const struct object* cell
);
int objectbase_is_empty(
    const struct object* cell
);
int objectbase_is_used(
    const struct object* cell
);
int objectbase_is_array(
    const struct object* cell
);
int objectbase_has_alignmentbox(
    const struct object* cell
);
const char* objectbase_get_name(
    const struct object* cell
);
const char* objectbase_get_child_reference_name(
    const struct object* child
);
void objectbase_flatten_inline(
    struct object* cell,
    int flattenports
);
struct object* objectbase_flatten(
    const struct object* cell,
    int flattenports
);
unsigned int objectbase_get_child_xrep(
    const struct object* cell
);
unsigned int objectbase_get_child_yrep(
    const struct object* cell
);
coordinate_t objectbase_get_child_xpitch(
    const struct object* cell
);
coordinate_t objectbase_get_child_ypitch(
    const struct object* cell
);
struct const_vector* objectbase_collect_references(
    const struct object* cell
);
struct vector* objectbase_collect_references_mutable(
    struct object* cell
);
// for iterator access
const struct vector* objectbase_get_full_shapes_const(
    const struct object* cell
);
const struct vector* objectbase_get_full_children_const(
    const struct object* cell
);
const struct vector* objectbase_get_full_references_const(
    const struct object* cell
);
struct vector* objectbase_get_full_references(
    struct object* cell
);
int objectbase_foreach_anchor(
    const struct object* cell,
    anchor_action action,
    struct generic_arg* extraargs
);
int objectbase_foreach_port(
    const struct object* cell,
    port_action action,
    struct generic_arg* extraargs
);
int objectbase_foreach_label(
    const struct object* cell,
    label_action action,
    struct generic_arg* extraargs
);

#endif /* OPC_OBJECT_BASE_H */

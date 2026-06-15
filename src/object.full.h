#ifndef OPC_OBJECT_IMPLEMENTATION
#error "This header must only be included in the implementation files of the object module. It is not intended for external use."
#endif

#ifndef OPC_OBJECT_FULL_H
#define OPC_OBJECT_FULL_H

#include "bltrshape.h"
#include "object.actions.h"
#include "object.anchors.h"
#include "object.ports.h"

// the struct is exposed so that composition is possible, but all content is hidden behind 'private'
struct object_full {
    struct {
        struct vector* shapes; // stores struct shape*
        struct vector* ports; // stores struct port*
        struct vector* labels; // like a port, but always drawn; stores struct port*
        struct hashmap* anchors; // stores struct anchor*
        struct hashmap* anchorlines; // stores coordinate_t*
        struct vector* children; // stores struct object*
        struct vector* references; // stores struct object*
        coordinate_t* alignmentbox; // NULL or contains eight coordinates: blx, blx, trx, try for both outer (first) and inner (second)
        struct vector* boundary; // a polygon, stores struct point*
        struct vector* layer_boundaries; // contains polygons that store struct point*, together with generics* in a tuple
        struct hashmap* nets; // stores struct vector*
        int ismanaged; // poor-mans shared pointer, required to avoid double-free when using object handles
    } private;
};

// initialization, copying, destruction
void objectfull_copy_to(
    const struct object_full* full,
    struct object_full* new
);
void objectfull_destroy(
    struct object_full* full
);

// shape manipulation
void objectfull_add_shape(
    struct object_full* full,
    struct shape* S
);
void objectfull_remove_shape(
    struct object_full* full,
    size_t idx
);
struct shape* objectfull_disown_shape(
    struct object_full* full,
    size_t idx
);
int objectfull_foreach_shapes_const(
    const struct object_full* full,
    const_shape_action action,
    struct generic_arg* extraargs
);
int objectfull_foreach_shapes(
    struct object_full* full,
    shape_action action,
    struct generic_arg* extraargs
);
struct shape* objectfull_get_shape(
    struct object_full* full,
    size_t idx
);
const struct shape* objectfull_get_shape_const(
    const struct object_full* full,
    size_t idx
);
size_t objectfull_get_shapes_size(
    const struct object_full* full
);
struct vector* objectfull_get_shapes(
    struct object_full* full
);
const struct vector* objectfull_get_shapes_const(
    const struct object_full* full
);
const struct vector* objectfull_get_shapes_const(
    const struct object_full* full
);
int objectfull_has_layer_flat(
    const struct object_full* full,
    const struct generics* layer
);
int objectfull_has_layer(
    const struct object_full* full,
    const struct generics* layer
);

// children/references
void objectfull_set_managed(
    struct object_full* full,
    int ismanaged
);
int objectfull_is_managed(
    const struct object_full* full
);
int objectfull_add_reference(
    struct object_full* full,
    struct object* reference
);
void objectfull_add_proxy(
    struct object_full* full,
    struct object* proxy
);
int objectfull_foreach_children_const(
    const struct object_full* full,
    const_object_action,
    struct generic_arg* extraargs
);
int objectfull_foreach_children(
    struct object_full* full,
    object_action,
    struct generic_arg* extraargs
);
int objectfull_foreach_references_const(
    const struct object_full* full,
    const_object_action,
    struct generic_arg* extraargs
);
int objectfull_foreach_references(
    struct object_full* full,
    object_action,
    struct generic_arg* extraargs
);
int objectfull_has_children(
    const struct object_full* full
);
struct vector* objectfull_get_children(
    const struct object_full* full
);
const struct vector* objectfull_get_children_const(
    const struct object_full* full
);
struct vector* objectfull_get_references(
    const struct object_full* full
);
const struct vector* objectfull_get_references_const(
    const struct object_full* full
);

// merging
void objectfull_merge_into(
    struct object_full* fulltarget,
    const struct object_full* fullsource,
    const struct transformationmatrix* trans,
    int merge_ports
);

// anchors and anchorlines
int objectfull_add_anchor(
    struct object_full* full,
    const struct transformationmatrix* trans,
    const char* name,
    struct anchor* anchor
);
void objectfull_inherit_all_anchors_with_prefix(
    struct object_full* full,
    const struct object_full* other,
    const struct transformationmatrix* targettrans,
    const struct transformationmatrix* sourcetrans,
    const char* prefix
);
int objectfull_add_anchor_line_xy(
    struct object_full* full,
    const struct transformationmatrix* trans,
    const char* name,
    coordinate_t c,
    int xory
);
struct anchor* objectfull_get_anchor(
    const struct object_full* full,
    const char* name
);
coordinate_t* objectfull_get_anchor_line(const struct object_full* full,
    const char* name
);
const struct hashmap* objectfull_get_anchors(
    const struct object_full* full
);
int objectfull_foreach_anchor(
    const struct object_full* full,
    const struct transformationmatrix* trans,
    anchor_action action,
    struct generic_arg* extraargs
);

// alignment box
void objectfull_clear_alignment_box(
    struct object_full* full
);
coordinate_t* objectfull_get_alignment_box(
    const struct object_full* full
);
void objectfull_set_alignment_box(
    struct object_full* full,
    coordinate_t outerblx, coordinate_t outerbly,
    coordinate_t outertrx, coordinate_t outertry,
    coordinate_t innerblx, coordinate_t innerbly,
    coordinate_t innertrx, coordinate_t innertry
);
void objectfull_extend_alignment_box(
    struct object_full* full,
    coordinate_t outerblx, coordinate_t outerbly,
    coordinate_t outertrx, coordinate_t outertry,
    coordinate_t innerblx, coordinate_t innerbly,
    coordinate_t innertrx, coordinate_t innertry
);
int objectfull_has_alignment_box(
    const struct object_full* full
);

// boundaries
struct vector* objectfull_set_boundary(
    struct object_full* full,
    struct vector* boundary
);
struct vector* objectfull_get_boundary(
    const struct object_full* full
);
int objectfull_has_boundary(
    const struct object_full* full
);
void objectfull_set_empty_layer_boundary(
    struct object_full* full,
    const struct generics* layer
);
void objectfull_add_layer_boundary(
    struct object_full* full,
    const struct generics* layer,
    struct simple_polygon* new
);
int objectfull_has_layer_boundary(
    const struct object_full* full,
    const struct generics* layer
);
struct polygon_container* objectfull_get_layer_boundary(
    const struct object_full* full,
    const struct generics* layer
);

// ports and labels
void objectfull_add_port(
    struct object_full* full,
    struct port* port
);
void objectfull_add_label(
    struct object_full* full,
    struct port* port
);
size_t objectfull_get_labels_size(
    const struct object_full* full
);
struct port* objectfull_get_label(
    struct object_full* full,
    size_t idx
);
const struct generics* objectfull_get_label_layer(
    const struct object_full* full,
    size_t idx
);
void objectfull_remove_label(
    struct object_full* full,
    size_t idx
);
const struct vector* objectfull_get_labels(
    const struct object_full* full
);
int objectfull_has_ports(
    const struct object_full* full
);
size_t objectfull_get_ports_size(
    const struct object_full* full
);
struct port* objectfull_get_port(
    struct object_full* full,
    size_t idx
);
const struct generics* objectfull_get_port_layer(
    const struct object_full* full,
    size_t idx
);
void objectfull_remove_port(
    struct object_full* full,
    size_t idx
);
const struct vector* objectfull_get_ports(
    const struct object_full* full
);
int objectfull_foreach_port(
    const struct object_full* full,
    const struct transformationmatrix* trans,
    port_action action,
    struct generic_arg* extraargs
);
int objectfull_foreach_label(
    const struct object_full* full,
    const struct transformationmatrix* trans,
    label_action action,
    struct generic_arg* extraargs
);

// net shapes
struct bltrshape* objectfull_add_net_shape(
    struct object_full* full,
    const char* netname,
    const struct point* bl,
    const struct point* tr,
    const struct generics* layer
);
const struct hashmap* objectfull_get_all_net_shapes(
    const struct object_full* full
);
struct vector* objectfull_get_net_shapes(
    const struct object_full* full,
    const char* netname,
    const struct generics* layer
);
void objectfull_inherit_net_shapes(
    struct object_full* cell,
    const struct object_full* other,
    const struct transformationmatrix* targettrans,
    const struct transformationmatrix* sourcetrans,
    const struct generics* layer
);
int objectfull_has_net(
    const struct object_full* full,
    const char* netname
);

// miscellaneous helper functions
coordinate_t* objectfull_get_minmax_xy(
    const struct object_full* full,
    const struct transformationmatrix* trans
);
void objectfull_flatten_inline(
    struct object_full* full,
    int flattenports
);
struct const_vector* objectfull_collect_references(
    const struct object_full* full
);
struct vector* objectfull_collect_references_mutable(
    struct object_full* full
);

#endif /* OPC_OBJECT_FULL_H */

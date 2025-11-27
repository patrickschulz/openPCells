#ifndef OPC_OBJECT_IMPLEMENTATION
#error "This header must only be included in the implementation files of the object module. It is not intended for external use."
#endif

#ifndef OPC_OBJECT_FULL_H
#define OPC_OBJECT_FULL_H

#include "bltrshape.h"
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
        struct hashmap* layer_boundaries; // contains polygons that store struct point*
        struct hashmap* nets; // stores struct vector*
    } private;
};

// initialization, copying, destruction
void objectfull_copy_to(const struct object_full* full, struct object_full* new);
void objectfull_destroy(struct object_full* full);

// shape manipulation
void objectfull_add_shape(struct object_full* full, struct shape* S);
void objectfull_remove_shape(struct object_full* full, size_t idx);
struct shape* objectfull_disown_shape(struct object_full* full, size_t idx);

// children/references
int objectfull_add_reference(struct object_full* full, struct object* reference);
void objectfull_add_proxy(struct object_full* full, struct object* proxy);

// merging
void objectfull_merge_into(struct object_full* cell, const struct object_full* other, int merge_ports);

// anchors and anchorlines
int objectfull_add_anchor(struct object_full* full, const char* name, struct anchor* anchor);
void objectfull_inherit_all_anchors_with_prefix(struct object_full* cell, const struct object_full* other, const char* prefix);
int objectfull_add_anchor_line_xy(struct object_full* full, const char* name, coordinate_t c, int xory);
struct anchor* objectfull_get_anchor(const struct object_full* cell, const char* name);
coordinate_t* objectfull_get_anchor_line(const struct object_full* cell, const char* name);

// alignment box
void objectfull_clear_alignment_box(struct object_full* full);
coordinate_t* objectfull_get_alignment_box(const struct object_full* full);
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

// boundaries
struct vector* objectfull_set_boundary(struct object_full* full, struct vector* boundary);
struct vector* objectfull_get_boundary(const struct object_full* full);
int objectfull_has_boundary(const struct object_full* full);
void objectfull_set_empty_layer_boundary(struct object_full* full, const struct generics* layer);
void objectfull_add_layer_boundary(struct object_full* full, const struct generics* layer, struct simple_polygon* new);
int objectfull_has_layer_boundary(const struct object_full* full, const struct generics* layer);
struct polygon_container* objectfull_get_layer_boundary(const struct object_full* full, const struct generics* layer);

// ports and labels
void objectfull_add_port(struct object_full* cell, struct port* port);
void objectfull_add_label(struct object_full* cell, struct port* port);

// net shapes
struct bltrshape* objectfull_add_net_shape(struct object_full* cell, const char* netname, const struct point* bl, const struct point* tr, const struct generics* layer);
struct vector* objectfull_get_net_shapes(const struct object_full* full, const char* netname, const struct generics* layer);

#endif /* OPC_OBJECT_FULL_H */

#ifndef OPC_OBJECT_IMPLEMENTATION
#error "This header must only be included in the implementation files of the object module. It is not intended for external use."
#endif

#ifndef OPC_OBJECT_BASE_H
#define OPC_OBJECT_BASE_H

#include "object.anchors.h"

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

struct object* objectbase_create_proxy(const char* name, struct object* reference);
char* objectbase_get_unique_name(struct object* reference);
void objectbase_set_managed(struct object* reference);
void objectbase_set_unused(struct object* reference);
void objectbase_set_used(struct object* reference);
void objectbase_add_reference(struct object* cell, struct object* reference);
void objectbase_add_proxy(struct object* cell, struct object* proxy);
void objectbase_set_array(struct object* cell, unsigned int xrep, unsigned int yrep, coordinate_t xpitch, coordinate_t ypitch);
int objectbase_add_anchor(struct object* cell, const char* name, struct anchor* anchor);
coordinate_t* objectbase_get_transformed_alignment_box(const struct object* cell);
coordinate_t* objectbase_get_transformed_bounding_box(const struct object* cell);
struct anchor* objectbase_get_anchor(const struct object* cell, const char* name);
struct point* objectbase_get_array_area_anchor(const struct object* cell, int xindex, int yindex, const char* base);
struct point* objectbase_get_array_anchor(const struct object* cell, int xindex, int yindex, const char* name);
coordinate_t* objectbase_get_anchor_line(const struct object* cell, const char* name);
const struct transformationmatrix* objectbase_get_tmatrix(const struct object* cell);
void objectbase_set_tmatrix(struct object* cell, struct transformationmatrix* matrix);
void objectbase_transform_to_local_coordinates_xy(const struct object* cell, coordinate_t* x, coordinate_t* y);
void objectbase_transform_to_local_coordinates(const struct object* cell, struct point* pt);
void objectbase_transform_to_global_coordinates_xy(const struct object* cell, coordinate_t* x, coordinate_t* y);
void objectbase_transform_to_global_coordinates(const struct object* cell, struct point* pt);

#endif /* OPC_OBJECT_BASE_H */

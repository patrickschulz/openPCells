#ifndef OPC_OBJECT_IMPLEMENTATION
#error "This header must only be included in the implementation files of the object module. It is not intended for external use."
#endif

#ifndef OPC_OBJECT_ANCHORS_H
#define OPC_OBJECT_ANCHORS_H

#include "object.h"
#include "point.h"

struct anchor;

struct anchor* objectanchor_create_regular(coordinate_t x, coordinate_t y);
struct anchor* objectanchor_create_area_bltr(coordinate_t blx, coordinate_t bly, coordinate_t trx, coordinate_t try);
struct anchor* objectanchor_create_area_points(coordinate_t x1, coordinate_t y1, coordinate_t x2, coordinate_t y2);
struct anchor* objectanchor_copy(const struct anchor* anchor);
void objectanchor_destroy(void* v);
int objectanchor_is_area(const struct anchor* anchor);
void objectanchor_apply_tmatrix(struct anchor* anchor, const struct transformationmatrix* trans);
void objectanchor_get_point(const struct anchor* anchor, struct point* pt);
void objectanchor_get_area_points(const struct anchor* anchor, struct point pts[2]);
int objectanchor_call(const struct anchor* anchor, const char* name, const struct transformationmatrix* matrix, anchor_action action, struct generic_arg* extraargs);

#endif /* OPC_OBJECT_ANCHORS_H */

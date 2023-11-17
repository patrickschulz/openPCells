#ifndef OPC_PLACEMENT_H
#define OPC_PLACEMENT_H

#include "object.h"
#include "polygon.h"
#include "vector.h"

struct vector* placement_calculate_origins(
    ucoordinate_t width, ucoordinate_t height,
    ucoordinate_t xpitch, ucoordinate_t ypitch,
    coordinate_t xstartshift, coordinate_t ystartshift,
    const struct simple_polygon* targetarea,
    const struct polygon* excludes
);

struct vector* placement_place_at_origins(
    struct object* toplevel,
    struct object* cell,
    const struct vector* origins,
    const char* basename
);

struct vector* placement_place_within_boundary(
    struct object* toplevel,
    struct object* cell,
    const char* basename,
    const struct simple_polygon* targetarea,
    const struct polygon* excludes
);

void placement_place_within_boundary_merge(
    struct object* toplevel,
    struct object* cell,
    const struct simple_polygon* targetarea,
    const struct polygon* excludes
);

struct object* placement_place_within_rectangular_boundary(
    struct object* toplevel,
    struct object* cell,
    const char* basename,
    const point_t* targetbl, const point_t* targettr
);

#endif /* OPC_PLACEMENT_H */

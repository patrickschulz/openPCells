#ifndef OPC_PLACEMENT_H
#define OPC_PLACEMENT_H

#include "object.h"
#include "polygon.h"
#include "vector.h"

struct boundary_celltable {
    struct object* center;
    struct object* top;
    struct object* bottom;
    struct object* left;
    struct object* right;
    struct object* topleft;
    struct object* topright;
    struct object* topbottom;
    struct object* bottomleft;
    struct object* bottomright;
    struct object* leftright;
    struct object* topleftright;
    struct object* topbottomleft;
    struct object* topbottomright;
    struct object* bottomleftright;
    struct object* topbottomleftright;
};

struct vector* placement_calculate_grid(
    const struct point* bl,
    const struct point* tr,
    coordinate_t xpitch,
    coordinate_t ypitch,
    const struct polygon* excludes
);

struct vector* placement_place_boundary_grid(
    struct object* toplevel,
    struct boundary_celltable* boundary_celltable,
    const struct point* basept,
    struct vector* grid,
    coordinate_t xpitch,
    coordinate_t ypitch,
    const char* basename
);

struct vector* placement_calculate_origins(
    ucoordinate_t width, ucoordinate_t height,
    ucoordinate_t xpitch, ucoordinate_t ypitch,
    coordinate_t xstartshift, coordinate_t ystartshift,
    const struct simple_polygon* targetarea,
    const struct polygon* excludes
);

struct vector* placement_calculate_origins_centered(
    ucoordinate_t width, ucoordinate_t height,
    ucoordinate_t xpitch, ucoordinate_t ypitch,
    coordinate_t xstartshift, coordinate_t ystartshift,
    const struct simple_polygon* targetarea,
    const struct polygon* excludes
);

struct vector* placement_place_on_grid(
    struct object* toplevel,
    struct object* cell,
    const char* basename,
    const struct point* basept,
    coordinate_t xpitch,
    coordinate_t ypitch,
    const struct vector* grid
);

void placement_place_at_origins(
    struct object* toplevel,
    struct object* cell,
    const struct vector* origins,
    const char* basename,
    struct vector* children
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
    const struct point* targetbl, const struct point* targettr
);

struct placement_celllookup {
    struct object* cell;
    struct const_vector* layers;
};

struct placement_layerexclude {
    struct polygon* excludes;
    struct const_vector* layers;
};

void destroy_placement_layerexclude(void* v);

struct vector* placement_place_within_layer_boundaries(
    struct object* toplevel,
    struct vector* celllookup, // contains entries of struct placement_celllookup*
    const char* basename,
    const struct simple_polygon* targetarea,
    coordinate_t xpitch, coordinate_t ypitch,
    struct vector* layerexcludes, // contains entries of struct placement_layerexclude*
    const struct generics* ignorelayer // ignored layer for extra excludes
);

struct vector* placement_place_gridlines(
    struct object* toplevel,
    const struct generics* layer,
    coordinate_t size, coordinate_t space,
    const struct point* targetbl,
    const struct point* targettr,
    const struct polygon* excludes
);

#endif /* OPC_PLACEMENT_H */


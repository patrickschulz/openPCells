#ifndef OPC_GEOMETRY_H
#define OPC_GEOMETRY_H

#include <stddef.h>

#include "technology.h"
#include "object.h"
#include "shape.h"
#include "generics.h"
#include "point.h"

void geometry_rectanglebltr(
    object_t* cell,
    generics_t* layer,
    point_t* bl, point_t* tr,
    ucoordinate_t xrep, ucoordinate_t yrep,
    ucoordinate_t xpitch, ucoordinate_t ypitch
);

void geometry_rectanglepoints(
    object_t* cell,
    generics_t* layer,
    point_t* bl, point_t* tr,
    ucoordinate_t xrep, ucoordinate_t yrep,
    ucoordinate_t xpitch, ucoordinate_t ypitch
);

void geometry_rectangle(
    object_t* cell,
    generics_t* layer,
    coordinate_t width, coordinate_t height,
    coordinate_t xshift, coordinate_t yshift,
    ucoordinate_t xrep, ucoordinate_t yrep,
    ucoordinate_t xpitch, ucoordinate_t ypitch
);

void geometry_polygon(object_t* cell, generics_t* layer, point_t** points, size_t len);

void geometry_path(
    object_t* cell,
    generics_t* layer,
    point_t** points, size_t len,
    ucoordinate_t width,
    ucoordinate_t bgnext, ucoordinate_t endext
);

void geometry_viabltr(
    object_t* cell, struct layermap* layermap, struct technology_state* techstate, int metal1, int metal2, point_t* bl, point_t* tr, ucoordinate_t xrep, ucoordinate_t yrep, ucoordinate_t xpitch, ucoordinate_t ypitch);

void geometry_via(
    object_t* cell,
    struct layermap* layermap, struct technology_state* techstate,
    int metal1, int metal2,
    ucoordinate_t width, ucoordinate_t height,
    coordinate_t xshift, coordinate_t yshift,
    ucoordinate_t xrep, ucoordinate_t yrep,
    ucoordinate_t xpitch, ucoordinate_t ypitch
);

void geometry_contactbltr(
    object_t* cell,
    struct layermap* layermap, struct technology_state* techstate,
    const char* region,
    point_t* bl, point_t* tr,
    ucoordinate_t xrep, ucoordinate_t yrep,
    ucoordinate_t xpitch, ucoordinate_t ypitch,
    int xcont, int ycont
);

void geometry_contact(
    object_t* cell,
    struct layermap* layermap, struct technology_state* techstate,
    const char* region,
    ucoordinate_t width, ucoordinate_t height,
    coordinate_t xshift, coordinate_t yshift,
    ucoordinate_t xrep, ucoordinate_t yrep,
    ucoordinate_t xpitch, ucoordinate_t ypitch,
    int xcont, int ycont
);

void geometry_cross(object_t* cell, generics_t* layer, ucoordinate_t width, ucoordinate_t height, ucoordinate_t crosssize);

void geometry_ring(object_t* cell, generics_t* layer, ucoordinate_t width, ucoordinate_t height, ucoordinate_t ringwidth);

void geometry_unequal_ring(
    object_t* cell,
    generics_t* layer,
    ucoordinate_t width, ucoordinate_t height,
    ucoordinate_t ringwidth, ucoordinate_t ringheight
);

shape_t* geometry_path_to_polygon(generics_t* layer, point_t** points, size_t numpoints, ucoordinate_t width, int miterjoin);

struct vector* geometry_triangulate_polygon(struct vector* points);

#endif /* OPC_GEOMETRY_H */

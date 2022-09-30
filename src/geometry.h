#ifndef OPC_GEOMETRY_H
#define OPC_GEOMETRY_H

#include <stddef.h>

#include "technology.h"
#include "object.h"
#include "shape.h"
#include "generics.h"
#include "point.h"

void geometry_rectanglebltr(
    struct object* cell,
    const struct generics* layer,
    const point_t* bl, const point_t* tr,
    ucoordinate_t xrep, ucoordinate_t yrep,
    ucoordinate_t xpitch, ucoordinate_t ypitch
);

void geometry_rectanglepoints(
    struct object* cell,
    const struct generics* layer,
    const point_t* bl, const point_t* tr,
    ucoordinate_t xrep, ucoordinate_t yrep,
    ucoordinate_t xpitch, ucoordinate_t ypitch
);

void geometry_rectangle(
    struct object* cell,
    const struct generics* layer,
    coordinate_t width, coordinate_t height,
    coordinate_t xshift, coordinate_t yshift,
    ucoordinate_t xrep, ucoordinate_t yrep,
    ucoordinate_t xpitch, ucoordinate_t ypitch
);

void geometry_polygon(
    struct object* cell,
    const struct generics* layer,
    const point_t** points, size_t len
);

void geometry_path(
    struct object* cell,
    const struct generics* layer,
    const point_t** points, size_t len,
    ucoordinate_t width,
    ucoordinate_t bgnext, ucoordinate_t endext
);

int geometry_viabltr(
    struct object* cell,
    struct layermap* layermap,
    struct technology_state* techstate,
    int metal1, int metal2,
    const point_t* bl, const point_t* tr,
    ucoordinate_t xrep, ucoordinate_t yrep, ucoordinate_t xpitch, ucoordinate_t ypitch,
    int xcont, int ycont
);

int geometry_via(
    struct object* cell,
    struct layermap* layermap, struct technology_state* techstate,
    int metal1, int metal2,
    ucoordinate_t width, ucoordinate_t height,
    coordinate_t xshift, coordinate_t yshift,
    ucoordinate_t xrep, ucoordinate_t yrep,
    ucoordinate_t xpitch, ucoordinate_t ypitch,
    int xcont, int ycont
);

int geometry_contactbltr(
    struct object* cell,
    struct layermap* layermap, struct technology_state* techstate,
    const char* region,
    const point_t* bl, const point_t* tr,
    ucoordinate_t xrep, ucoordinate_t yrep,
    ucoordinate_t xpitch, ucoordinate_t ypitch,
    int xcont, int ycont
);

int geometry_contact(
    struct object* cell,
    struct layermap* layermap, struct technology_state* techstate,
    const char* region,
    ucoordinate_t width, ucoordinate_t height,
    coordinate_t xshift, coordinate_t yshift,
    ucoordinate_t xrep, ucoordinate_t yrep,
    ucoordinate_t xpitch, ucoordinate_t ypitch,
    int xcont, int ycont
);

int geometry_contactbarebltr(
    struct object* cell,
    struct layermap* layermap, struct technology_state* techstate,
    const char* region,
    const point_t* bl, const point_t* tr,
    ucoordinate_t xrep, ucoordinate_t yrep,
    ucoordinate_t xpitch, ucoordinate_t ypitch,
    int xcont, int ycont
);

int geometry_contactbare(
    struct object* cell,
    struct layermap* layermap, struct technology_state* techstate,
    const char* region,
    ucoordinate_t width, ucoordinate_t height,
    coordinate_t xshift, coordinate_t yshift,
    ucoordinate_t xrep, ucoordinate_t yrep,
    ucoordinate_t xpitch, ucoordinate_t ypitch,
    int xcont, int ycont
);

void geometry_cross(struct object* cell, const struct generics* layer, ucoordinate_t width, ucoordinate_t height, ucoordinate_t crosssize);

void geometry_ring(struct object* cell, const struct generics* layer, ucoordinate_t width, ucoordinate_t height, ucoordinate_t ringwidth);

void geometry_unequal_ring(
    struct object* cell,
    const struct generics* layer,
    ucoordinate_t width, ucoordinate_t height,
    ucoordinate_t leftwidth, ucoordinate_t rightwidth,
    ucoordinate_t topwidth, ucoordinate_t bottomwidth
);

struct shape* geometry_path_to_polygon(const struct generics* layer, point_t** points, size_t numpoints, ucoordinate_t width, int miterjoin);

struct vector* geometry_triangulate_polygon(const struct vector* points);

#endif /* OPC_GEOMETRY_H */

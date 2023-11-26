#ifndef OPC_GEOMETRY_H
#define OPC_GEOMETRY_H

#include <stddef.h>

#include "technology.h"
#include "object.h"
#include "shape.h"
#include "point.h"

void geometry_rectanglebltrxy(
    struct object* cell,
    const struct generics* layer,
    coordinate_t blx, coordinate_t bly,
    coordinate_t trx, coordinate_t try
);

void geometry_rectanglebltr(
    struct object* cell,
    const struct generics* layer,
    const point_t* bl, const point_t* tr
);

void geometry_rectangleblwh(
    struct object* cell,
    const struct generics* layer,
    const point_t* bl,
    coordinate_t width, coordinate_t height
);

void geometry_rectanglepointsxy(
    struct object* cell,
    const struct generics* layer,
    coordinate_t x1, coordinate_t y1,
    coordinate_t x2, coordinate_t y2
);

void geometry_rectanglepoints(
    struct object* cell,
    const struct generics* layer,
    const point_t* bl, const point_t* tr
);

void geometry_rectanglearray(
    struct object* cell,
    const struct generics* layer,
    coordinate_t width, coordinate_t height,
    coordinate_t xshift, coordinate_t yshift,
    unsigned int xrep, unsigned int yrep,
    ucoordinate_t xpitch, ucoordinate_t ypitch
);

void geometry_slotted_rectangle(
    struct object* cell,
    const struct generics* layer,
    const point_t* bl, const point_t* tr,
    coordinate_t slotwidth, coordinate_t slotheight,
    coordinate_t slotxspace, coordinate_t slotyspace,
    coordinate_t slotminedgexspace, coordinate_t slotminedgeyspace
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

void geometry_path_polygon(
    struct object* cell,
    const struct generics* layer,
    const point_t** points, size_t len,
    ucoordinate_t width,
    ucoordinate_t bgnext, ucoordinate_t endext
);

int geometry_viabltr(
    struct object* cell,
    struct technology_state* techstate,
    int metal1, int metal2,
    const point_t* bl, const point_t* tr,
    int xcont, int ycont,
    int equal_pitch,
    coordinate_t widthclass
);

int geometry_viabarebltr(
    struct object* cell,
    struct technology_state* techstate,
    int metal1, int metal2,
    const point_t* bl, const point_t* tr,
    int xcont, int ycont,
    int equal_pitch,
    coordinate_t widthclass
);

int geometry_contactbltr(
    struct object* cell,
    struct technology_state* techstate,
    const char* region,
    const point_t* bl, const point_t* tr,
    int xcont, int ycont,
    int equal_pitch,
    coordinate_t widthclass
);

int geometry_contactbarebltr(
    struct object* cell,
    struct technology_state* techstate,
    const char* region,
    const point_t* bl, const point_t* tr,
    int xcont, int ycont,
    int equal_pitch,
    coordinate_t widthclass
);

void geometry_cross(struct object* cell, const struct generics* layer, ucoordinate_t width, ucoordinate_t height, ucoordinate_t crosssize);

void geometry_ring(struct object* cell, const struct generics* layer, coordinate_t x0, coordinate_t y0, ucoordinate_t width, ucoordinate_t height, ucoordinate_t ringwidth);

void geometry_unequal_ring(
    struct object* cell,
    const struct generics* layer,
    coordinate_t x0, coordinate_t y0,
    ucoordinate_t width, ucoordinate_t height,
    ucoordinate_t leftwidth, ucoordinate_t rightwidth,
    ucoordinate_t topwidth, ucoordinate_t bottomwidth
);

void geometry_unequal_ring_pts(
    struct object* cell,
    const struct generics* layer,
    const point_t* outerbl, const point_t* outertr,
    const point_t* innerbl, const point_t* innertr
);

struct shape* geometry_path_to_polygon(const struct generics* layer, point_t** points, size_t numpoints, ucoordinate_t width, int miterjoin);

struct vector* geometry_get_side_path_points(struct vector* points, coordinate_t width);

struct vector* geometry_triangulate_polygon(const struct vector* points);

#endif /* OPC_GEOMETRY_H */

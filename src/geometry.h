#ifndef OPC_GEOMETRY_H
#define OPC_GEOMETRY_H

#include <stddef.h>

#include "object.h"
#include "shape.h"
#include "generics.h"
#include "point.h"

void geometry_rectanglebltr(object_t* cell, generics_t* layer, point_t* bl, point_t* tr);
void geometry_rectangle(object_t* cell, generics_t* layer, coordinate_t width, coordinate_t height, coordinate_t xshift, coordinate_t yshift);
void geometry_rectanglepoints(object_t* cell, generics_t* layer, point_t* pt1, point_t* pt2);
void geometry_polygon(object_t* cell, generics_t* layer, point_t** points, size_t len);
void geometry_path(object_t* cell, generics_t* layer, point_t** points, size_t len, ucoordinate_t width, ucoordinate_t bgnext, ucoordinate_t endext);

shape_t* geometry_path_to_polygon(point_t** points, size_t numpoints, ucoordinate_t width, int miterjoin);

#endif /* OPC_GEOMETRY_H */

#ifndef OPC_SHAPE_H
#define OPC_SHAPE_H

#include <stddef.h>

#include "point.h"

typedef enum
{
    RECTANGLE,
    POLYGON,
    PATH
} shapetype;

typedef struct
{
    point_t bl;
    point_t tr;
} rectangle_t;

typedef struct
{
    point_t* points;
    size_t size;
} polygon_t;

typedef struct
{
    point_t* points;
    ucoordinate_t width;
    size_t size;
} path_t;

typedef struct
{
    void* geo;
    shapetype type;
} shape_t;

shape_t* create_rectangle();
shape_t* create_polygon();

#endif /* OPC_SHAPE_H */

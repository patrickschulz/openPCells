#ifndef POINT_H
#define POINT_H

#include <stdint.h>

typedef long long int coordinate_t;
typedef unsigned long long int ucoordinate_t;

typedef struct
{
    coordinate_t x;
    coordinate_t y;
} point_t;

point_t* point_create(coordinate_t x, coordinate_t y);
void point_destroy(point_t* pt);

#endif // POINT_H

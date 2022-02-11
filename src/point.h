#ifndef POINT_H
#define POINT_H

#include <stdint.h>
#include <limits.h>

typedef long long int coordinate_t;
typedef unsigned long long int ucoordinate_t;
#define COORDINATE_MAX LLONG_MAX
#define COORDINATE_MIN LLONG_MIN
#define UCOORDINATE_MAX ULLONG_MAX
#define UCOORDINATE_MIN LLONG_MIN // ?

typedef struct
{
    coordinate_t x;
    coordinate_t y;
} point_t;

point_t* point_create(coordinate_t x, coordinate_t y);
void point_destroy(point_t* pt);
point_t* point_copy(point_t* pt);

void point_translate(point_t* pt, coordinate_t x, coordinate_t y);

#endif // POINT_H

#ifndef OPC_POINT_H
#define OPC_POINT_H

#include <stdint.h>
#include <limits.h>

typedef long long int coordinate_t;
typedef unsigned long long int ucoordinate_t;
#define COORDINATE_MAX LLONG_MAX
#define COORDINATE_MIN LLONG_MIN
#define UCOORDINATE_MAX ULLONG_MAX
#define UCOORDINATE_MIN 0

typedef struct
{
    coordinate_t x;
    coordinate_t y;
} point_t;

point_t* point_create(coordinate_t x, coordinate_t y);
void point_destroy(void* pt); // void*, otherwise we get a warning while destroying vectors
point_t* point_copy(const point_t* pt);

void point_translate(point_t* pt, coordinate_t x, coordinate_t y);

// min/max calculations
point_t* point_create_minimum(void);
point_t* point_create_maximum(void);
void point_update_minimum(point_t** min, const point_t* pt);
void point_update_maximum(point_t** max, const point_t* pt);

coordinate_t point_xdifference(const point_t* pt1, const point_t* pt2);
coordinate_t point_ydifference(const point_t* pt1, const point_t* pt2);

#define pointarray vector
#define pointarray_get(p, i) ((point_t*)vector_get(p, i))

#endif // OPC_POINT_H

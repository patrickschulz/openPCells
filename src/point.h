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
#define coordinate_abs llabs

struct point {
    coordinate_t x;
    coordinate_t y;
};

struct point* point_create(coordinate_t x, coordinate_t y);
void point_destroy(void* pt); // void*, otherwise we get a warning while destroying vectors
void* point_copy(const void* pt);

coordinate_t point_getx(const struct point* pt);
coordinate_t point_gety(const struct point* pt);

void point_translate(struct point* pt, coordinate_t x, coordinate_t y);

// min/max calculations
struct point* point_create_minimum(void);
struct point* point_create_maximum(void);
void point_update_minimum(struct point** min, const struct point* pt);
void point_update_maximum(struct point** max, const struct point* pt);

coordinate_t point_xdifference(const struct point* pt1, const struct point* pt2);
coordinate_t point_ydifference(const struct point* pt1, const struct point* pt2);

#endif // OPC_POINT_H

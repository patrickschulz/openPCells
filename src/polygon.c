#include "polygon.h"

#include <stdlib.h>

#include "point.h"
#include "vector.h"

struct simple_polygon {
    struct vector* points;
};

struct polygon {
    struct vector* simple_polygons;
};

struct simple_polygon* simple_polygon_create(void)
{
    struct simple_polygon* simple_polygon = malloc(sizeof(*simple_polygon));
    simple_polygon->points = vector_create(32, point_destroy);
    return simple_polygon;
}

struct simple_polygon* simple_polygon_copy(const struct simple_polygon* old)
{
    struct simple_polygon* new = malloc(sizeof(*new));
    new->points = vector_create(vector_size(old->points), point_destroy);
    struct vector_const_iterator* it = vector_const_iterator_create(old->points);
    while(vector_const_iterator_is_valid(it))
    {
        const point_t* pt = vector_const_iterator_get(it);
        vector_append(new->points, point_copy(pt));
        vector_const_iterator_next(it);
    }
    vector_const_iterator_destroy(it);
    return new;
}

struct polygon* polygon_create(void)
{
    struct polygon* polygon = malloc(sizeof(*polygon));
    polygon->simple_polygons = vector_create(32, simple_polygon_destroy);
    return polygon;
}

struct polygon* polygon_create_empty(void)
{
    struct polygon* polygon = malloc(sizeof(*polygon));
    polygon->simple_polygons = NULL;
    return polygon;
}

void simple_polygon_destroy(void* sp)
{
    struct simple_polygon* simple_polygon = sp;
    vector_destroy(simple_polygon->points);
    free(simple_polygon);
}

void polygon_destroy(void* p)
{
    struct polygon* polygon = p;
    if(polygon->simple_polygons)
    {
        vector_destroy(polygon->simple_polygons);
    }
    free(polygon);
}

void polygon_add(struct polygon* polygon, struct simple_polygon* simple_polygon)
{
    vector_append(polygon->simple_polygons, simple_polygon);
}

int polygon_is_empty(const struct polygon* polygon)
{
    return polygon->simple_polygons == NULL;
}

static int _between(coordinate_t p, coordinate_t a, coordinate_t b)
{
    return (p >= a && p <= b) || (p <= a && p >= b);
}

int polygon_is_point_in_simple_polygon(const struct simple_polygon* polygon, coordinate_t x, coordinate_t y)
{
    int inside = 0;
    size_t i = vector_size(polygon->points) - 1;
    size_t j = 0;
    while(j < vector_size(polygon->points))
    {
        const point_t* A = vector_get(polygon->points, i);
        const point_t* B = vector_get(polygon->points, j);
        // corner cases
        if(((x == point_getx(A) && y == point_gety(A)) || (x == point_getx(B) && y == point_gety(B))))
        {
            return 0;
        }
        if((point_gety(A) == point_gety(B) && y == point_gety(A) && _between(x, point_getx(A), point_getx(B))))
        {
            return 0;
        }
        if((_between(y, point_gety(A), point_gety(B)))) // if P inside the vertical range
        {
            // filter out "ray pass vertex" problem by treating the line a little lower
            if(((y == point_gety(A) && point_gety(B) >= point_gety(A)) || (y == point_gety(B) && point_gety(A) >= point_gety(B))))
            {
                goto POINT_IN_POLYGON_CONTINUE;
            }
            // calc cross product `PA X PB`, P lays on left side of AB if c > 0
            coordinate_t c = (point_getx(A) - x) * (point_gety(B) - y) - (point_getx(B) - x) * (point_gety(A) - y);
            if(c == 0)
            {
                return 0;
            }
            if((point_gety(A) < point_gety(B)) == (c > 0))
            {
                inside = !inside;
            }
        }
POINT_IN_POLYGON_CONTINUE:
        i = j;
        j = j + 1;
    }
    return inside ? 1 : -1;
}

int polygon_is_point_in_polygon(const struct polygon* polygon, coordinate_t x, coordinate_t y)
{
    if(polygon_is_empty(polygon))
    {
        return -1;
    }
    int is_in_polygon = -1;
    struct polygon_const_iterator* it = polygon_const_iterator_create(polygon);
    while(polygon_const_iterator_is_valid(it))
    {
        const struct simple_polygon* simple_polygon = polygon_const_iterator_get(it);
        int _isp = polygon_is_point_in_simple_polygon(simple_polygon, x, y);
        if(_isp == 1)
        {
            is_in_polygon = 1;
            break;
        }
        else if(_isp == 0)
        {
            is_in_polygon = 0;
        }
        polygon_const_iterator_next(it);
    }
    polygon_const_iterator_destroy(it);
    return is_in_polygon;
}

void simple_polygon_append(struct simple_polygon* simple_polygon, point_t* pt)
{
    vector_append(simple_polygon->points, pt);
}

struct simple_polygon_iterator {
    struct vector_iterator* iterator;
};

struct simple_polygon_iterator* simple_polygon_iterator_create(struct simple_polygon* simple_polygon)
{
    struct simple_polygon_iterator* it = malloc(sizeof(*it));
    it->iterator = vector_iterator_create(simple_polygon->points);
    return it;
}

int simple_polygon_iterator_is_valid(struct simple_polygon_iterator* iterator)
{
    return vector_iterator_is_valid(iterator->iterator);
}

point_t* simple_polygon_iterator_get(struct simple_polygon_iterator* iterator)
{
    return vector_iterator_get(iterator->iterator);
}

void simple_polygon_iterator_next(struct simple_polygon_iterator* iterator)
{
    vector_iterator_next(iterator->iterator);
}

void simple_polygon_iterator_destroy(struct simple_polygon_iterator* iterator)
{
    vector_iterator_destroy(iterator->iterator);
    free(iterator);
}

struct simple_polygon_const_iterator {
    struct vector_const_iterator* iterator;
};

struct simple_polygon_const_iterator* simple_polygon_const_iterator_create(const struct simple_polygon* simple_polygon)
{
    struct simple_polygon_const_iterator* it = malloc(sizeof(*it));
    it->iterator = vector_const_iterator_create(simple_polygon->points);
    return it;
}

int simple_polygon_const_iterator_is_valid(struct simple_polygon_const_iterator* iterator)
{
    return vector_const_iterator_is_valid(iterator->iterator);
}

const point_t* simple_polygon_const_iterator_get(struct simple_polygon_const_iterator* iterator)
{
    return vector_const_iterator_get(iterator->iterator);
}

void simple_polygon_const_iterator_next(struct simple_polygon_const_iterator* iterator)
{
    vector_const_iterator_next(iterator->iterator);
}

void simple_polygon_const_iterator_destroy(struct simple_polygon_const_iterator* iterator)
{
    vector_const_iterator_destroy(iterator->iterator);
    free(iterator);
}

struct polygon_iterator {
    struct vector_iterator* iterator;
};

struct polygon_iterator* polygon_iterator_create(struct polygon* polygon)
{
    struct polygon_iterator* it = malloc(sizeof(*it));
    it->iterator = vector_iterator_create(polygon->simple_polygons);
    return it;
}

int polygon_iterator_is_valid(struct polygon_iterator* iterator)
{
    return vector_iterator_is_valid(iterator->iterator);
}

struct simple_polygon* polygon_iterator_get(struct polygon_iterator* iterator)
{
    return vector_iterator_get(iterator->iterator);
}

void polygon_iterator_next(struct polygon_iterator* iterator)
{
    vector_iterator_next(iterator->iterator);
}

void polygon_iterator_destroy(struct polygon_iterator* iterator)
{
    vector_iterator_destroy(iterator->iterator);
    free(iterator);
}

struct polygon_const_iterator {
    struct vector_const_iterator* iterator;
};

struct polygon_const_iterator* polygon_const_iterator_create(const struct polygon* polygon)
{
    struct polygon_const_iterator* it = malloc(sizeof(*it));
    it->iterator = vector_const_iterator_create(polygon->simple_polygons);
    return it;
}

int polygon_const_iterator_is_valid(struct polygon_const_iterator* iterator)
{
    return vector_const_iterator_is_valid(iterator->iterator);
}

const struct simple_polygon* polygon_const_iterator_get(struct polygon_const_iterator* iterator)
{
    return vector_const_iterator_get(iterator->iterator);
}

void polygon_const_iterator_next(struct polygon_const_iterator* iterator)
{
    vector_const_iterator_next(iterator->iterator);
}

void polygon_const_iterator_destroy(struct polygon_const_iterator* iterator)
{
    vector_const_iterator_destroy(iterator->iterator);
    free(iterator);
}

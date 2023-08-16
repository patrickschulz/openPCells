#include "polygon.h"

#include <stdlib.h>

#include "point.h"
#include "vector.h"

struct polygon {
    struct vector* simple_polygons;
};

struct polygon* polygon_create(void)
{
    struct polygon* polygon = malloc(sizeof(*polygon));
    polygon->simple_polygons = vector_create(32, vector_destroy);
    return polygon;
}

void polygon_destroy(void* p)
{
    struct polygon* polygon = p;
    vector_destroy(polygon->simple_polygons);
    free(polygon);
}

void polygon_add(struct polygon* polygon, struct vector* simple_polygon)
{
    vector_append(polygon->simple_polygons, simple_polygon);
}

void polygon_add(struct polygon* polygon, struct vector* simple_polygon);

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

struct vector* polygon_iterator_get(struct polygon_iterator* iterator)
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

struct polygon_const_iterator* polygon_const_iterator_create(struct polygon* polygon)
{
    struct polygon_const_iterator* it = malloc(sizeof(*it));
    it->iterator = vector_const_iterator_create(polygon->simple_polygons);
    return it;
}

int polygon_const_iterator_is_valid(struct polygon_const_iterator* iterator)
{
    return vector_const_iterator_is_valid(iterator->iterator);
}

const struct vector* polygon_const_iterator_get(struct polygon_const_iterator* iterator)
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

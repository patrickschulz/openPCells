#ifndef OPC_POLYGON_H
#define OPC_POLYGON_H

#include "vector.h"

struct polygon;

struct polygon* polygon_create(void);
void polygon_destroy(void* p);
void polygon_add(struct polygon* polygon, struct vector* simple_polygon);

struct polygon_iterator;
struct polygon_iterator* polygon_iterator_create(struct polygon* polygon);
int polygon_iterator_is_valid(struct polygon_iterator* iterator);
struct vector* polygon_iterator_get(struct polygon_iterator* iterator);
void polygon_iterator_next(struct polygon_iterator* iterator);
void polygon_iterator_destroy(struct polygon_iterator* iterator);

struct polygon_const_iterator;
struct polygon_const_iterator* polygon_const_iterator_create(struct polygon* polygon);
int polygon_const_iterator_is_valid(struct polygon_const_iterator* iterator);
const struct vector* polygon_const_iterator_get(struct polygon_const_iterator* iterator);
void polygon_const_iterator_next(struct polygon_const_iterator* iterator);
void polygon_const_iterator_destroy(struct polygon_const_iterator* iterator);

#endif /* OPC_POLYGON_H */

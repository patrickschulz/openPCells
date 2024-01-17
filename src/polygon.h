#ifndef OPC_POLYGON_H
#define OPC_POLYGON_H

#include "point.h"

struct simple_polygon;
struct polygon;

struct simple_polygon* simple_polygon_create(void);
struct simple_polygon* simple_polygon_create_from_rectangle(coordinate_t blx, coordinate_t bly, coordinate_t trx, coordinate_t try);
struct simple_polygon* simple_polygon_copy(const struct simple_polygon* old);
struct polygon* polygon_create(void);
struct polygon* polygon_create_empty(void);
struct polygon* polygon_copy(const struct polygon* polygon);
void simple_polygon_destroy(void* p);
void polygon_destroy(void* p);
void polygon_add(struct polygon* polygon, struct simple_polygon* simple_polygon);
int simple_polygon_is_rectangle(const struct simple_polygon* simple_polygon);
int polygon_is_empty(const struct polygon* polygon);
int polygon_is_point_in_simple_polygon(const struct simple_polygon* polygon, coordinate_t x, coordinate_t y);
int polygon_is_point_in_polygon(const struct polygon* polygon, coordinate_t x, coordinate_t y);
int simple_polygon_intersects_rectangle(const struct simple_polygon* simple_polygon, coordinate_t blx, coordinate_t bly, coordinate_t trx, coordinate_t try);
int polygon_intersects_rectangle(const struct polygon* polygon, coordinate_t blx, coordinate_t bly, coordinate_t trx, coordinate_t try);
void simple_polygon_append(struct simple_polygon* simple_polygon, point_t* pt);

struct simple_polygon_iterator;
struct simple_polygon_iterator* simple_polygon_iterator_create(struct simple_polygon* simple_polygon);
int simple_polygon_iterator_is_valid(struct simple_polygon_iterator* iterator);
point_t* simple_polygon_iterator_get(struct simple_polygon_iterator* iterator);
void simple_polygon_iterator_next(struct simple_polygon_iterator* iterator);
void simple_polygon_iterator_destroy(struct simple_polygon_iterator* iterator);

struct simple_polygon_const_iterator;
struct simple_polygon_const_iterator* simple_polygon_const_iterator_create(const struct simple_polygon* simple_polygon);
int simple_polygon_const_iterator_is_valid(struct simple_polygon_const_iterator* iterator);
const point_t* simple_polygon_const_iterator_get(struct simple_polygon_const_iterator* iterator);
void simple_polygon_const_iterator_next(struct simple_polygon_const_iterator* iterator);
void simple_polygon_const_iterator_destroy(struct simple_polygon_const_iterator* iterator);

struct polygon_iterator;
struct polygon_iterator* polygon_iterator_create(struct polygon* polygon);
int polygon_iterator_is_valid(struct polygon_iterator* iterator);
struct simple_polygon* polygon_iterator_get(struct polygon_iterator* iterator);
void polygon_iterator_next(struct polygon_iterator* iterator);
void polygon_iterator_destroy(struct polygon_iterator* iterator);

struct polygon_const_iterator;
struct polygon_const_iterator* polygon_const_iterator_create(const struct polygon* polygon);
int polygon_const_iterator_is_valid(struct polygon_const_iterator* iterator);
const struct simple_polygon* polygon_const_iterator_get(struct polygon_const_iterator* iterator);
void polygon_const_iterator_next(struct polygon_const_iterator* iterator);
void polygon_const_iterator_destroy(struct polygon_const_iterator* iterator);

#endif /* OPC_POLYGON_H */

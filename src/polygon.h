#ifndef OPC_POLYGON_H
#define OPC_POLYGON_H

#include "point.h"

struct simple_polygon;
struct polygon_container;

struct simple_polygon* simple_polygon_create(void);
struct simple_polygon* simple_polygon_create_from_rectangle(coordinate_t blx, coordinate_t bly, coordinate_t trx, coordinate_t try);
struct simple_polygon* simple_polygon_copy(const struct simple_polygon* old);
struct polygon_container* polygon_container_create(void);
struct polygon_container* polygon_container_create_empty(void);
struct polygon_container* polygon_container_copy(const struct polygon_container* polygon_container);
void simple_polygon_destroy(void* p);
void polygon_container_destroy(void* p);
void polygon_container_add(struct polygon_container* polygon_container, struct simple_polygon* simple_polygon);
int simple_polygon_is_rectangle(const struct simple_polygon* simple_polygon);
int polygon_container_is_empty(const struct polygon_container* polygon_container);
int polygon_is_point_in_simple_polygon(const struct simple_polygon* polygon, coordinate_t x, coordinate_t y);
int polygon_is_point_in_polygon_container(const struct polygon_container* polygon_container, coordinate_t x, coordinate_t y);
struct vector* simple_polygon_line_intersections(const struct simple_polygon* simple_polygon, coordinate_t x1, coordinate_t y1, coordinate_t x2, coordinate_t y2);
struct vector* polygon_container_line_intersections(const struct polygon_container* polygon_container, coordinate_t x1, coordinate_t y1, coordinate_t x2, coordinate_t y2);
int simple_polygon_intersects_rectangle(const struct simple_polygon* simple_polygon, coordinate_t blx, coordinate_t bly, coordinate_t trx, coordinate_t try);
int polygon_container_intersects_rectangle(const struct polygon_container* polygon_container, coordinate_t blx, coordinate_t bly, coordinate_t trx, coordinate_t try);
void simple_polygon_append(struct simple_polygon* simple_polygon, struct point* pt);
coordinate_t polygon_container_get_minx(const struct polygon_container* polygon_container);
coordinate_t polygon_container_get_maxx(const struct polygon_container* polygon_container);
coordinate_t polygon_container_get_miny(const struct polygon_container* polygon_container);
coordinate_t polygon_container_get_maxy(const struct polygon_container* polygon_container);

struct simple_polygon_iterator;
struct simple_polygon_iterator* simple_polygon_iterator_create(struct simple_polygon* simple_polygon);
int simple_polygon_iterator_is_valid(struct simple_polygon_iterator* iterator);
struct point* simple_polygon_iterator_get(struct simple_polygon_iterator* iterator);
void simple_polygon_iterator_next(struct simple_polygon_iterator* iterator);
void simple_polygon_iterator_destroy(struct simple_polygon_iterator* iterator);

struct simple_polygon_const_iterator;
struct simple_polygon_const_iterator* simple_polygon_const_iterator_create(const struct simple_polygon* simple_polygon);
int simple_polygon_const_iterator_is_valid(struct simple_polygon_const_iterator* iterator);
const struct point* simple_polygon_const_iterator_get(struct simple_polygon_const_iterator* iterator);
void simple_polygon_const_iterator_next(struct simple_polygon_const_iterator* iterator);
void simple_polygon_const_iterator_destroy(struct simple_polygon_const_iterator* iterator);

struct polygon_container_iterator;
struct polygon_container_iterator* polygon_container_iterator_create(struct polygon_container* polygon_container);
int polygon_container_iterator_is_valid(struct polygon_container_iterator* iterator);
struct simple_polygon* polygon_container_iterator_get(struct polygon_container_iterator* iterator);
void polygon_container_iterator_next(struct polygon_container_iterator* iterator);
void polygon_container_iterator_destroy(struct polygon_container_iterator* iterator);

struct polygon_container_const_iterator;
struct polygon_container_const_iterator* polygon_container_const_iterator_create(const struct polygon_container* polygon_container);
int polygon_container_const_iterator_is_valid(struct polygon_container_const_iterator* iterator);
const struct simple_polygon* polygon_container_const_iterator_get(struct polygon_container_const_iterator* iterator);
void polygon_container_const_iterator_next(struct polygon_container_const_iterator* iterator);
void polygon_container_const_iterator_destroy(struct polygon_container_const_iterator* iterator);

#endif /* OPC_POLYGON_H */

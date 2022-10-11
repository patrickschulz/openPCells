#ifndef LROUTER_FIELD_H
#define LROUTER_FIELD_H

/* special values for a point in one layer */
#define UNVISITED -1
#define PATH -2
#define PORT -3
#define VIA -4
#define BLOCKAGE -5

#include <stddef.h>

/* point of the field struct */
struct rpoint {
    unsigned int x, y, z;
    int score;
};

struct field;
struct field* field_init(size_t width, size_t height, size_t num_layers);
void field_destroy(struct field* field);
void field_print(struct field* field, int layer);
void field_unprint(size_t size);
void field_create_blockage(struct field* field, struct rpoint* start, struct rpoint* end);
struct rpoint *point_new(int x, int y, int z, unsigned int score);

size_t field_get_width(struct field* field);
size_t field_get_height(struct field* field);
size_t field_get_num_layers(struct field* field);

int field_is_field_point(const struct field* field, size_t x, size_t y, size_t z);
int field_is_visitable(const struct field* field, size_t x, size_t y, size_t z);

void field_set(struct field* field, size_t x, size_t y, size_t z, int what);
int field_get(struct field* field, size_t x, size_t y, size_t z);
struct net *field_get_net(struct field* field, size_t x, size_t y, size_t z);
void field_set_net(struct field* field, size_t x, size_t y, size_t z,
		   struct net *what);

/* resets the values in the field for a next iteration (keeps special values) */
void field_reset(struct field* field);

#endif /* LROUTER_FIELD_H */

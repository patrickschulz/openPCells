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
typedef struct {
	int x, y, z;
	unsigned int score;
} point_t;

int*** field_init(size_t width, size_t height, size_t num_layers);
void field_destroy(int*** field, size_t width, size_t height, size_t num_layers);
void field_print(int*** field, size_t width, size_t height, unsigned int layer);
void field_unprint(size_t size);
void field_create_blockage(int ***field, point_t start, point_t end);
point_t *point_new(int x, int y, int z, unsigned int score);

/*
 * resets the values in the field for a next iteration
 * (keeps ports and paths)
 */
void field_reset(int*** field, size_t width, size_t height, size_t num_layers);

#endif

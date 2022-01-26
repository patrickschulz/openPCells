#ifndef LROUTER_FIELD_H
#define LROUTER_FIELD_H

/* special values for a point in one layer */
#define UNVISITED -1
#define PATH -2
#define PORT -3
#define VIA -4

#include <stddef.h>

/* point of the field struct */
typedef struct {
	unsigned int x, y, z;
	unsigned int score;
} point_t;

int*** init_field(size_t size, size_t num_layers);
void destroy_field(int** field, size_t size);
void print_field(int** field, size_t size);
void unprint_field(size_t size);

/*
 * resets the values in the field for a next iteration
 * (keeps ports and paths)
 */
void reset_field(int*** field, size_t size, size_t num_layers);

#endif

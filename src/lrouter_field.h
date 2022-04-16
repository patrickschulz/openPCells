#ifndef OPC_LROUTER_FIELD_H
#define OPC_LROUTER_FIELD_H

#define UNVISITED -1
#define PATH -2
#define PORT -3

#include <stddef.h>

/* point of the field struct */
typedef struct {
	int x, y;
} point_t;

int** init_field(size_t size);
void destroy_field(int** field, size_t size);

/*
 * resets the values in the field for a next iteration
 * (keeps ports and paths)
 */
void reset_field(int** field, size_t size);

#endif // OPC_LROUTER_FIELD_H

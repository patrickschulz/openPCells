#include "lrouter_field.h"

#include <stdio.h>
#include <string.h>
#include <stdlib.h>

void reset_field(int** field, size_t size)
{
	for(size_t i = 0; i < size; i++) {
		for(size_t j = 0; j < size; j++) {
			if(field[j][i] != PATH && field[j][i] != PORT)
				field[j][i] = UNVISITED;
		}
	}
}

int** init_field(size_t size)
{
    int** field = calloc(size, sizeof(*field));
    for(size_t i = 0; i < size; ++i)
    {
        field[i] = calloc(size, sizeof(**field));
    }
    return field;
    // calloc zeroes it's contents
	//memset(&field, UNVISITED, sizeof(field[0][0]) *
	//       FIELD_SIZE * FIELD_SIZE);
}

void destroy_field(int** field, size_t size)
{
    for(size_t i = 0; i < size; ++i)
    {
        free(field[i]);
    }
    free(field);
}

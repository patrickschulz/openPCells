#include "lrouter_field.h"

#include <stdio.h>
#include <string.h>
#include <stdlib.h>

void black()
{
	printf("\033[0;30m");
}

void red()
{
	printf("\033[0;31m");
}

void green()
{
	printf("\033[0;32m");
}

void yellow()
{
	printf("\033[0;33m");
}

void blue()
{
	printf("\033[0;34m");
}

void purple()
{
	printf("\033[0;35m");
}

void cyan()
{
	printf("\033[0;36m");
}

void white()
{
	printf("\033[0;37m");
}

static void reset_layer(int** layer, size_t size)
{
	for(size_t i = 0; i < size; i++) {
		for(size_t j = 0; j < size; j++) {
			if(layer[j][i] != PATH && layer[j][i] != PORT
			   && layer[j][i] != VIA)
				layer[j][i] = UNVISITED;
		}
	}
}

void reset_field(int*** field, size_t size, size_t num_layers)
{
	for(size_t l = 0; l < num_layers; l++) {
		reset_layer(field[l], size);
	}
}

int*** init_field(size_t size, size_t num_layers)
{
    int*** field = calloc(num_layers, sizeof(**field));
    for(size_t i = 0; i < num_layers; i++)
    {
	field[i] = calloc(size, sizeof(*field));
	for(size_t j = 0; j < size; j++)
	{
		field[i][j] = calloc(size, sizeof(**field));
		memset(field[i][j], UNVISITED, size * sizeof(**field));
	}
    }
    return field;
}

void destroy_field(int*** field, size_t size, size_t num_layers)
{
	for(size_t i = 0; i < num_layers; i++)
	{
	    for(size_t j = 0; j < size; j++)
	    {
		free(field[i][j]);
	    }
		free(field[i]);
	}
    free(field);
}

void print_field(int*** field, size_t size, unsigned int layer)
{
	for(size_t i = 0; i < size - 1; i++) {
		if(i == 0) {
			printf("%u", layer);
		} else {
			printf("=");
		}
	}
	printf("=\n");
	for(size_t i = 0; i < size; i++) {
		for(size_t j = 0; j < size; j++) {
			if(field[layer][j][i] == PATH)
				green();
			else if(field[layer][j][i] == PORT)
				red();
			else if(field[layer][j][i] == VIA)
				blue();
			else
				white();
			printf("%2i  ", field[layer][j][i]);
		}
		printf("\n");
	}
}

void unprint_field(size_t size)
{
	for(size_t i = 0; i <= size; i++) {
		/* VT100 excape code to move cursor to start of prev line */
		printf("\33[F");
		/* VT100 excape code to clear a line */
		printf("\33[2K");
	}
}


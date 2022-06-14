#include "lrouter_field.h"

#include <stdio.h>
#include <string.h>
#include <stdlib.h>

#define LOWEST_ROUTING_METAL 2

void black(void)
{
	printf("\033[0;30m");
}

void red(void)
{
	printf("\033[0;31m");
}

void green(void)
{
	printf("\033[0;32m");
}

void yellow(void)
{
	printf("\033[0;33m");
}

void blue(void)
{
	printf("\033[0;34m");
}

void purple(void)
{
	printf("\033[0;35m");
}

void cyan(void)
{
	printf("\033[0;36m");
}

void white(void)
{
	printf("\033[0;37m");
}

void normal(void)
{
	printf("\033[0m");
}

static void reset_layer(int** layer, size_t width, size_t height)
{
	for(size_t i = 0; i < height; i++) {
		for(size_t j = 0; j < width; j++) {
			if(layer[j][i] != PATH && layer[j][i] != PORT
			   && layer[j][i] != VIA && layer[j][i] != BLOCKAGE)
				layer[j][i] = UNVISITED;
		}
	}
}

void field_reset(int*** field, size_t width, size_t height, size_t num_layers)
{
	for(size_t l = 0; l < num_layers; l++) {
		reset_layer(field[l], width, height);
	}
}

int*** field_init(size_t width, size_t height, size_t num_layers)
{
    width++;
    int*** field = calloc(num_layers, sizeof(**field));
    for(size_t i = 0; i < num_layers; i++)
    {
	field[i] = calloc(width, sizeof(*field));
	for(size_t j = 0; j < width; j++)
	{
		field[i][j] = calloc(height, sizeof(field));
		memset(field[i][j], UNVISITED, height * sizeof(field));
	}
    }
    return field;
}

void field_destroy(int*** field, size_t width, size_t height, size_t num_layers)
{
	for(size_t i = 0; i < num_layers; i++)
	{
	    for(size_t j = 0; j < height; j++)
	    {
		    free(field[i][j]);
	    }
		free(field[i]);
	}
    free(field);
}

void field_print(int*** field, size_t width, size_t height, unsigned int layer)
{
	for(int i = (int)width + 1; i >= 0; i--) {
		if(i == 0) {
			printf("%u", layer);
		} else {
			printf("==");
		}
	}
	printf("=\n");
	for(int i = (int)height - 1; i >= 0; i--) {
		normal();
		printf("%02i ", i);
		for(size_t j = 0; j < width; j++) {
			if(field[layer][j][i] == PATH)
				green();
			else if(field[layer][j][i] == PORT)
				red();
			else if(field[layer][j][i] == VIA)
				blue();
			else if(field[layer][j][i] == BLOCKAGE)
				purple();
			else
				normal();
			printf("%4i", field[layer][j][i]);
		}
		printf("\n");
	}
}

point_t *point_new(int x, int y, int z, unsigned int score)
{
    point_t *new_point = calloc(1, sizeof(point_t));
    if(new_point == NULL)
        return NULL;

    new_point->x = x;
    new_point->y = y;
    new_point->z = z;
    new_point->score = score;

    return new_point;
}

void field_unprint(size_t size)
{
	for(size_t i = 0; i <= size; i++) {
		/* VT100 excape code to move cursor to start of prev line */
		printf("\33[F");
		/* VT100 excape code to clear a line */
		printf("\33[2K");
	}
}

void field_create_blockage(int ***field, point_t start, point_t end)
{
	int len = 0;
	int xincr = 0;
	int yincr = 0;

	printf("creating blockage from %i, %i to %i, %i\n", start.x, start.y,
	       end.x, end.y);

	if(start.x != end.x)
	{
		len = abs(start.x - end.x);
		xincr = (end.x < start.x) ? -1 : 1;
	}
	else
	{
		len = abs(start.y - end.y);
		yincr = (end.y < start.y) ? -1 : 1;
	}

	for(int i = 0; i < len; i++)
	{
		field[start.z - LOWEST_ROUTING_METAL][start.x + i * xincr][start.y + i * yincr] =
			BLOCKAGE;
	}
}


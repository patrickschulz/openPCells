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
    for(size_t i = 0; i < size; i++)
    {
        field[i] = calloc(size, sizeof(**field));
	memset(field[i], UNVISITED, size * sizeof(**field));
    }
    return field;
}

void destroy_field(int** field, size_t size)
{
    for(size_t i = 0; i < size; ++i)
    {
        free(field[i]);
    }
    free(field);
}

void print_field(int** field, size_t size)
{
	for(size_t i = 0; i < size; i++) {
		for(size_t j = 0; j < size; j++) {
			if(field[j][i] == PATH)
				green();
			else if(field[j][i] == PORT)
				red();
			else
				white();
			printf("%2i  ", field[j][i]);
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


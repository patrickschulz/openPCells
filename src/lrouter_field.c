#include "lrouter_field.h"

#include <stdio.h>
#include <string.h>
#include <stdlib.h>

#define LOWEST_ROUTING_METAL 2

struct field {
    size_t width;
    size_t height;
    size_t num_layers;
    int* content;
};

void black(void)
{
    fputs("\033[0;30m", stdout);
}

void red(void)
{
    fputs("\033[0;31m", stdout);
}

void green(void)
{
    fputs("\033[0;32m", stdout);
}

void yellow(void)
{
    fputs("\033[0;33m", stdout);
}

void blue(void)
{
    fputs("\033[0;34m", stdout);
}

void purple(void)
{
    fputs("\033[0;35m", stdout);
}

void cyan(void)
{
    fputs("\033[0;36m", stdout);
}

void white(void)
{
    fputs("\033[0;37m", stdout);
}

void normal(void)
{
    fputs("\033[0m", stdout);
}

void field_reset(struct field* field)
{
    for(size_t i = 0; i < field->width * field->height * field->num_layers; i++)
    {
        if(field->content[i] != PATH && field->content[i] != PORT && field->content[i] != VIA && field->content[i] != BLOCKAGE)
        {
            field->content[i] = UNVISITED;
        }
    }
}

struct field* field_init(size_t width, size_t height, size_t num_layers)
{
    struct field* field = malloc(sizeof(*field));
    field->width = width;
    field->height = height;
    field->num_layers = num_layers;
    field->content = calloc(width * height * num_layers, sizeof(*field->content));
    memset(field->content, UNVISITED, width * height * num_layers * sizeof(*field->content));
    return field;
}

void field_destroy(struct field* field)
{
    free(field->content);
    free(field);
}

static int* _get(struct field* field, size_t x, size_t y, size_t z)
{
    return &field->content[x + y * field->width + z * field->width * field->height];
}

static int _get_const(const struct field* field, size_t x, size_t y, size_t z)
{
    return field->content[x + y * field->width + z * field->width * field->height];
}

void field_print(struct field* field, int layer)
{
    for(size_t i = 0; i < field->width + 1; ++i)
    {
        if(i == field->width)
        {
            printf("%u", layer);
        }
        else
        {
            fputs("==", stdout);
        }
    }
    fputs("=\n", stdout);
    for(int i = (int)field->height - 1; i >= 0; i--)
    {
        normal();
        printf("%04i ", i);
        for(size_t j = 0; j < field->width; j++)
        {
            switch(*_get(field, j, i, layer))
            {
                case(PATH):
                    green();
                    break;
                case(PORT):
                    red();
                    break;
                case(VIA):
                    blue();
                    break;
                case(BLOCKAGE):
                    purple();
                    break;
                default:
                    normal();
                    break;
            }
            printf("%4i", *_get(field, j, i, layer));
        }
        putchar('\n');
    }
}

struct rpoint *point_new(int x, int y, int z, unsigned int score)
{
    struct rpoint* new_point = malloc(sizeof(*new_point));
    if(new_point == NULL)
    {
        return NULL;
    }

    new_point->x = x;
    new_point->y = y;
    new_point->z = z;
    new_point->score = score;

    return new_point;
}

size_t field_get_width(struct field* field)
{
    return field->width;
}

size_t field_get_height(struct field* field)
{
    return field->height;
}

size_t field_get_num_layers(struct field* field)
{
    return field->num_layers;
}

int field_is_field_point(const struct field* field, size_t x, size_t y, size_t z)
{
    return (x < field->width && y < field->height && z < field->num_layers);
}

int field_is_visitable(const struct field* field, size_t x, size_t y, size_t z)
{
    int value = _get_const(field, x, y, z);
    return value >= 0;
}


void field_set(struct field* field, size_t x, size_t y, size_t z, int what)
{
    *_get(field, x, y, z) = what;
}

int field_get(struct field* field, size_t x, size_t y, size_t z)
{
    return *_get(field, x, y, z);
}

void field_unprint(size_t size)
{
    for(size_t i = 0; i <= size; i++)
    {
        /* VT100 excape code to move cursor to start of prev line */
        fputs("\33[F", stdout);
        /* VT100 excape code to clear a line */
        fputs("\33[2K", stdout);
    }
}

void field_create_blockage(struct field* field, struct rpoint* start, struct rpoint* end)
{
    int len = 0;
    int xincr = 0;
    int yincr = 0;

    if(start->x != end->x)
    {
        if(start->x > end->x)
        {
            len = start->x - end->x;
            xincr = -1;
        }
        else
        {
            len = end->x - start->x;
            xincr = 1;
        }
    }
    else
    {
        if(start->y > end->y)
        {
            len = start->y - end->y;
            yincr = -1;
        }
        else
        {
            len = end->y - start->y;
            yincr = 1;
        }
    }

    for(int i = 0; i < len; i++)
    {
        *_get(field, start->x + i * xincr, start->y + i * yincr, start->z - LOWEST_ROUTING_METAL) = BLOCKAGE;
    }
}


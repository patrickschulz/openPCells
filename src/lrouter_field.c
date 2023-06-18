#include "lrouter_field.h"

#include <stdio.h>
#include <string.h>
#include <stdlib.h>

#define LOWEST_ROUTING_METAL 2

struct field {
    size_t width;
    size_t height;
    size_t num_layers;
    int *content;
};

struct field *field_copy(struct field *field)
{
    struct field *new = field_init(field->width, field->height, field->num_layers);
    memcpy(new->content, field->content, field->width * field->height * field->num_layers * sizeof(*field->content));
    return new;
}

void field_restore(struct field *original, struct field *copy)
{
    memcpy(original->content, copy->content, original->width * original->height * original->num_layers * sizeof(*original->content));
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
    return &field-> content[x + y * field->width + z * field->width * field->height];
}

static int _get_const(const struct field* field, size_t x, size_t y, size_t z)
{
    return field-> content[x + y * field->width + z * field->width * field->height];
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

int field_is_field_point(const struct field* field, struct rpoint pt)
{
    return pt.x < field->width && pt.y < field->height && pt.z < field->num_layers;
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
    return _get_const(field, x, y, z);
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

    int i;
    for(i = 0; i < len + 1; i++)
    {
        *_get(field, start->x + i * xincr, start->y + i * yincr,
	      start->z - LOWEST_ROUTING_METAL) = BLOCKAGE;
    }
}

int point_get_score(const struct rpoint *point)
{
    return point->score;
}


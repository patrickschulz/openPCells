#include "lrouter_net.h"

#include "util.h"
#include "vector.h"

#include <stdlib.h>
#include <stdio.h>
#include <stdbool.h>
#include <time.h>

struct net {
    char *name;
    unsigned int ranking;
    struct vector *positions;
    int routed;
    struct vector *deltas;
};

struct position* net_create_position(const char *instance, const char *port, unsigned int x, unsigned int y, unsigned int z)
{
    struct position* pos = malloc(sizeof(*pos));
    pos->instance = malloc(strlen(instance) + 1);
    strcpy(pos->instance, instance);
    pos->port = malloc(strlen(port) + 1);
    strcpy(pos->port, port);

    pos->x = x;
    pos->y = y;
    pos->z = z;

    return pos;
}

void* net_copy_position(const void* vp)
{
    const struct position* pos = vp;
    struct position* new = net_create_position(pos->instance, pos->port, pos->x, pos->y, pos->z);
    return new;
}

void net_destroy_position(void *pp)
{
    struct position* pos = pp;
    free(pos->instance);
    free(pos->port);
    free(pos);
}

static int cmp_func(void const *av, void const *bv)
{
    const struct net* a = av;
    const struct net* b = bv;
    int numa = vector_size(a->positions);
    int numb = vector_size(b->positions);
    return numb - numa;
}

void net_sort_nets(struct vector *nets)
{
    vector_sort(nets, cmp_func);
}

struct net *net_copy(const struct net *net)
{
    struct vector *copy_positions = vector_copy(net->positions, net_copy_position);
    struct net *copy = net_create(net->name, NO_SUFFIX, copy_positions);
    copy->routed = net->routed;
    return copy;
}

void net_restore_positions(struct net *original, struct net *copy)
{
    vector_destroy(original->positions);
    struct vector *restoredpos = vector_copy(copy->positions, net_copy_position);

    original->positions = restoredpos;
}

struct net* net_create(const char* name, int suffixnum, struct vector *positions)
{
    struct net* net = malloc(sizeof(*net));
    memset(net, 0, sizeof(*net));
    if(suffixnum != NO_SUFFIX)
    {
        unsigned int dlen = util_num_digits(suffixnum);
        /* + 3: _(), + 1 for terminating zero */
        net->name = malloc(strlen(name) + dlen + 3 + 1);
    }
    else
    {
        net->name = malloc(strlen(name) + 1);
        strcpy(net->name, name);
    }
    net->deltas = vector_create(1, free);
    net->positions = positions;
    net->routed = 0;
    return net;
}

int net_get_size(const struct net *net)
{
    return vector_size(net->positions);
}

int net_get_num_deltas(const struct net *net)
{
    return vector_size(net->deltas);
}

void net_destroy(void* np)
{
    struct net* net = np;
    free(net->name);
    vector_destroy(net->positions);
    vector_destroy(net->deltas);
    free(net);
}

void net_mark_as_routed(struct net* net)
{
    net->routed = 1;
}

int net_is_routed(const struct net* net)
{
    return net->routed;
}

const char* net_get_name(const struct net* net)
{
    return net->name;
}

void nets_fill_ports(struct vector* nets, struct field* field)
{
    for(unsigned int i = 0; i < vector_size(nets); i++)
    {
        struct net* net = vector_get(nets, i);
        for(int j = 0; j < net_get_size(net); j++)
        {
            struct position *pos = vector_get(net->positions, j);
            field_set(field, pos->x, pos->y, pos->z, PORT);
        }
    }
}

void net_append_position(struct net *net, struct position *position)
{
    vector_append(net->positions, position);
}

void net_append_delta(struct net *net, struct rpoint *delta)
{
    vector_append(net->deltas, delta);
}

struct rpoint *net_copy_delta(struct net *net, int i)
{
    struct rpoint *point = malloc(sizeof(*point));
    *point = *net_get_delta(net, i);
    return point;
}

void net_remove_position(struct net *net, unsigned int i)
{
    vector_remove(net->positions, i, net_destroy_position);
}

const struct position *net_get_position(const struct net *net, size_t i)
{
    if(i > vector_size(net->positions))
    {
        return NULL;
    }
    return vector_get_const(net->positions, i);
}

void net_print_deltas(struct net *net)
{
    if(net->deltas == NULL)
    {
        return;
    }

    for(unsigned int i = 0; i < vector_size(net->deltas); i++)
    {
        struct rpoint *point = net_get_delta(net, i);
        if(point->score == PORT)
        {
            printf("delta %i: %i %i %i PORT\n", i, point->x, point->y,
                    point->z);
        }
        else
        {
            printf("delta %i: %i %i %i PATH\n", i, point->x, point->y,
                    point->z);
        }
    }
}

void net_make_deltas(struct net *net)
{
    unsigned int delta_size = vector_size(net->deltas);
    int xsteps = 0, ysteps = 0, zsteps = 0;

    struct rpoint *current;
    struct rpoint *next;

    struct vector *new_deltas = vector_create(1, free);

    /* get the port were starting from */
    vector_append(new_deltas, net_copy_delta(net, 0));

    for(unsigned int i = 1; i < (delta_size - 1); i++)
    {
        current = net_copy_delta(net, i);
        next = net_copy_delta(net, i + 1);

        xsteps += current->x;
        ysteps += current->y;
        zsteps += current->z;

        if(current->score == PORT)
        {
            struct rpoint *point = point_new(xsteps - current->x,
                    ysteps - current->y,
                    zsteps - current->z, PATH);
            if(!(point->x == 0 && point->y == 0 && point->z == 0))
            {
                vector_append(new_deltas, point);
            }

            struct rpoint *port = point_new(current->x, current->y,
                    current->z, PORT);
            vector_append(new_deltas, port);
            xsteps = 0;
            ysteps = 0;
            zsteps = 0;

        }
        else if(current->x && !next->x)
        {
            struct rpoint *point = point_new(xsteps, 0, 0, PATH);
            vector_append(new_deltas, point);
            xsteps = 0;

        }
        else if (current->y && !next->y)
        {
            struct rpoint *point = point_new(0, ysteps, 0, PATH);
            vector_append(new_deltas, point);
            ysteps = 0;

        }
        else if (current->z)
        {
            struct rpoint *point = point_new(0, 0, zsteps, PATH);
            vector_append(new_deltas, point);
            zsteps = 0;

        }

        free(current);
        free(next);
    }

    /* after loop next pointer is at end of vector */
    next = net_copy_delta(net, delta_size - 1);
    struct rpoint *point;
    if(next->x)
    {
        point = point_new(xsteps + next->x, 0, 0, PATH);
    }
    else if(next->y)
    {
        point = point_new(0, ysteps + next->y, 0, PATH);
    }
    else if(next->z)
    {
        point = point_new(0, 0, zsteps + next->z, PATH);
    }
    vector_append(new_deltas, point);

    vector_destroy(net->deltas);
    net->deltas = new_deltas;
    free(next);
}

void net_reverse_deltas(struct net *net)
{
    unsigned int delta_size = vector_size(net->deltas);
    for(unsigned int i = 0, j = (delta_size - 1);
            i < (delta_size / 2); i++, j--)
    {
        vector_swap(net->deltas, i, j);
    }
}

struct rpoint *net_get_delta(struct net *net, unsigned int i)
{
    return vector_get(net->deltas, i);
}

struct position *net_point_to_position(struct rpoint *point)
{
    struct position *pos = net_create_position("NOINST", "NOPORT", point->x, point->y, point->z);
    return pos;
}

const struct position *net_get_position_at_point(const struct net *net, struct rpoint *point)
{
    const struct position *pos = NULL;
    for(size_t i = 0; i < vector_size(net->positions); i++)
    {
        const struct position *temppos = net_get_position(net, i);

        //if(temppos->x == point->x && temppos->y == point->y && temppos->y == point->y) // <- used to be this, but this does not make any sense
        if(temppos->x == point->x && temppos->y == point->y && temppos->z == point->z)
        {
            pos = temppos;
        }
    }
    return pos;
}

const char *net_position_get_inst(const struct position *pos)
{
    return pos->instance;
}

const char *net_position_get_port(const struct position *pos)
{
    return pos->port;
}

struct rpoint *net_position_to_point(const struct position *pos)
{
    struct rpoint *point = point_new(pos->x, pos->y, pos->z, UNVISITED);
    return point;
}

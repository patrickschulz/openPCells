#include "lrouter_net.h"
#include "lrouter_queue.h"

#include "util.h"

#include <stdlib.h>
#include <stdio.h>
#include <stdbool.h>
#include <time.h>

#define BETWEEN(value, min, max) (value < max && value > min)

struct net {
    char *name;
    unsigned int ranking;
    struct position* startpos;
    struct position* endpos;
    int routed;
    /* queue to save the path in the end */
    struct queue* path;
};

struct position* net_create_position(const char *instance, const char *port, unsigned int x, unsigned int y)
{
    struct position* pos = malloc(sizeof(*pos));

    pos->instance = malloc(strlen(instance) + 1);
    strcpy(pos->instance, instance);
    pos->port = malloc(strlen(port) + 1);
    strcpy(pos->port, port);

    pos->x = x;
    pos->y = y;
    /* all ports are on metal 1 */
    pos->z = 0;

    return pos;
}

struct position* net_copy_position(struct position* pos)
{
    struct position* new = net_create_position(pos->instance, pos->port, pos->x, pos->y);
    return new;
}

void net_destroy_position(void *pp)
{
    struct position* pos = pp;
    free(pos->instance);
    free(pos->port);
    free(pos);
}

struct net* net_create(const char* name, int suffixnum, struct position* startpos, struct position* endpos)
{
    struct net* net = malloc(sizeof(*net));
    memset(net, 0, sizeof(*net));
    unsigned int dlen = util_num_digits(suffixnum);
    net->name = malloc(strlen(name) + dlen + 3 + 1); /* + 3: _(), + 1 for terminating zero */
    sprintf(net->name, "%s_(%d)", name, suffixnum);
    net->path = queue_new();
    net->startpos = startpos;
    net->endpos = endpos;
    net->routed = 0;
    return net;
}

void net_destroy(void* np)
{
    struct net* net = np;
    free(net->name);
    net_destroy_position(net->startpos);
    net_destroy_position(net->endpos);
    queue_destroy(net->path);
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

const struct position* net_get_startpos(const struct net* net)
{
    return net->startpos;
}

const struct position* net_get_endpos(const struct net* net)
{
    return net->endpos;
}

void net_enqueue_point(struct net* net, point_t* pt)
{
	queue_enqueue(net->path, pt);
}

point_t* net_dequeue_point(struct net* net)
{
    return queue_dequeue(net->path);
}

void net_reverse_points(struct net* net)
{
    queue_reverse(net->path);
}

/* creates deltas out of a nets routed path */
void net_create_deltas(struct net *net)
{
    /* dont need to create deltas if the net has too few points */
    int net_len;
    if((net_len = queue_len(net->path)) < 3)
    {
        return;
    }

    point_t *points;
    if((points = queue_as_array(net->path)) == NULL)
    {
        return;
    }

    queue_clear(net->path);

    int xsteps = 0;
    int ysteps = 0;
    int zsteps = 0;

    for(int i = 0; i < net_len - 1; i++)
    {
        /*
         * a delta is there when it was running in some direction and gets
         * to a corner e.g. x != 0 and the next x == 0, valid for x, y or z
         * so in c booleans: current x: true and next x false
         */
        xsteps += points[i].x;
        ysteps += points[i].y;
        zsteps += points[i].z;

        if(points[i].x && !points[i+1].x)
        {
            point_t *point = point_new(xsteps, 0, 0, 0);
            queue_enqueue(net->path, point);
            xsteps = 0;
        }
        else if(points[i].y && !points[i+1].y)
        {
            point_t *point = point_new(0, ysteps, 0, 0);
            queue_enqueue(net->path, point);
            ysteps = 0;
        }
        else if(points[i].z && !points[i+1].z)
        {
            point_t *point = point_new(0, 0, zsteps, 0);
            queue_enqueue(net->path, point);
            zsteps = 0;
        }
    }

    /* put last connection to end port into queue (no corner here) */
    point_t *point;
    xsteps += points[net_len - 1].x;
    ysteps += points[net_len - 1].y;
    zsteps += points[net_len - 1].z;

    if(points[net_len - 1].x)
    {
        point = point_new(xsteps, 0, 0, 0);
    }
    else if(points[net_len - 1].y)
    {
        point = point_new(0, ysteps, 0, 0);
    }
    else if(points[net_len - 1].z)
    {
        point = point_new(0, 0, zsteps, 0);
    }
    queue_enqueue(net->path, point);

    free(points);
}

static int cmp_func(void const *a, void const *b)
{
    return (*((struct net**)a))->ranking - ((*(struct net**)b))->ranking;
}

void net_sort_nets(struct vector* nets)
{
    unsigned int xlo, xhi, ylo, yhi;
    for(size_t i = 0; i < vector_size(nets); i++)
    {
        struct net* neti = vector_get(nets, i);
        unsigned int ranking = 0;

        /* create rectangle */
        struct position* posi0 = neti->startpos;
        struct position* posi1 = neti->endpos;
        xlo = (posi0->x <= posi1->x) ? posi0->y : posi1->y;
        xhi = (posi0->x >  posi1->x) ? posi0->x : posi1->x;
        ylo = (posi0->y <= posi1->y) ? posi0->y : posi1->y;
        yhi = (posi0->y >  posi1->y) ? posi0->y : posi1->y;

        for(size_t j = 0; j < vector_size(nets); j++)
        {
            struct net* netj = vector_get(nets, j);
            /* how many ports of other nets are inside rect */
            if(j != i)
            {
                struct position* posj0 = netj->startpos;
                struct position* posj1 = netj->endpos;
                if(BETWEEN(posj0->x, xlo, xhi) && BETWEEN(posj0->y, ylo, yhi))
                {
                    ranking++;
                }

                if(BETWEEN(posj1->x, xlo, xhi) && BETWEEN(posj1->y, ylo, yhi))
                {
                    ranking++;
                }
            }
        }
        neti->ranking = ranking;
    }
    vector_sort(nets, cmp_func);
}


void net_fill_ports(struct vector* nets, struct field* field)
{
    for(unsigned int i = 0; i < vector_size(nets); i++)
    {
        struct net* net = vector_get(nets, i);
        field_set(field, net->startpos->x, net->startpos->y, net->startpos->z, PORT);
        field_set(field, net->endpos->x, net->endpos->y, net->endpos->z, PORT);
    }
}


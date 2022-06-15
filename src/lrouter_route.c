#include "lrouter_net.h"
#include "lrouter_queue.h"
#include "lrouter_min_heap.h"
#include "lrouter_field.h"
#include "lrouter_route.h"

#include <unistd.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <limits.h>

#define EVEN(val) ((val % 2) == 0)
#define POSITIVE(val) (val > 0)

#define NUM_DIRECTIONS 6
const int xincr[NUM_DIRECTIONS] = {-1, 0, 1, 0, 0, 0};
const int yincr[NUM_DIRECTIONS] = {0, 1, 0, -1, 0, 0};
const int zincr[NUM_DIRECTIONS] = {0, 0, 0, 0, -1, 1};

static int _next_field_position(int i, const struct rpoint* current, struct rpoint* next)
{
    next->x = current->x + xincr[i];
    next->y = current->y + yincr[i];
    next->z = current->z + zincr[i];
    return 1;
}

void route(struct net *net, struct field* field, size_t wrong_dir_cost, size_t via_cost)
{
    const struct position* startpos = net_get_startpos(net);
    const struct position* endpos = net_get_endpos(net);

    printf("calling route with net '%s' from x:%u, y:%u, z:%u to x:%u, y:%u, z:%u\n", net_get_name(net), startpos->x, startpos->y, startpos->z, endpos->x, endpos->y, endpos->z);

    /* put starting point in min_heap */
    struct minheap* min_heap = heap_init();
    heap_insert_point(min_heap, startpos->x, startpos->y, startpos->z, 0);

    struct rpoint current = { .x = 0, .y = 0, .z = 0 };

    field_set(field, startpos->x, startpos->y, startpos->z, 0);

    /*
     * do as long as there are points
     * to be marked or
     * endpoint is reached
     */
    do {
        /* get next point from heap */
        struct rpoint* point_ptr = heap_get_point(min_heap);

        current.x = point_ptr->x;
        current.y = point_ptr->y;
        current.z = point_ptr->z;

        free(point_ptr);

        int score = field_get(field, current.x, current.y, current.z);

        /* circle around every point */
        for(int i = 0; i < NUM_DIRECTIONS; i++)
        {
            struct rpoint next;
            if(!_next_field_position(i, &current, &next))
            {
                continue;
            }

            if(!field_is_field_point(field, next.x, next.y, next.z))
            {
                continue;
            }

            /* decide the val of the score incrementer */
            int score_incr = 1;
            if(next.z != current.z) /* via */
            {
                score_incr = via_cost;
            }
            else if(next.y != current.y && EVEN(current.z)) /* wrong y direction */
            {
                score_incr = wrong_dir_cost;
            }
            else if (next.x != current.x && !EVEN(current.z)) /* wrong x direction */
            {
                score_incr = wrong_dir_cost;
            }

            /* check if point is visitable */
            int nextfield = field_get(field, next.x, next.y, next.z);
            if((nextfield == PORT &&
                next.x == endpos->x &&
                next.y == endpos->y &&
                next.z == endpos->z) ||
               nextfield == UNVISITED ||
               (score + score_incr < nextfield))
            {
                if(next.x == endpos->x && next.y == endpos->y && next.z == endpos->z)
                {
                    /*
                     * if next point is endpoint
                     * put it into front of heap
                     * so empty the heap (not nice way)
                     */
                    struct rpoint* pt;
                    while((pt = heap_get_point(min_heap)))
                    {
                        free(pt);
                    }
                }

                field_set(field, next.x, next.y, next.z, score + score_incr);

                /* put the point in the to be visited queue */
                heap_insert_point(min_heap, next.x, next.y, next.z, score + score_incr);
            }
        }

        /* router is stuck */
        if(heap_empty(min_heap))
        {
            /* clean up */
            field_reset(field);
            heap_destroy(min_heap);
            return;
        }
    } while(!(current.x == endpos->x && current.y == endpos->y && current.z == endpos->z));

    heap_destroy(min_heap);

    int xdiff = 0;
    int ydiff = 0;
    int zdiff = 0;

    /* backtrace */
    do {
        int score = field_get(field, current.x, current.y, current.z);

        struct rpoint nextpoint = { .x = INT_MAX, .y = INT_MAX, .z = INT_MAX, .score = INT_MAX };

        /* circle around every point + check layer above and below store possible points in array */
        for(int i = 0; i < NUM_DIRECTIONS; i++)
        {
            struct rpoint next;
            next.x = current.x + xincr[i];
            next.y = current.y + yincr[i];
            next.z = current.z + zincr[i];

            if(!field_is_field_point(field, next.x, next.y, next.z))
            {
                continue;
            }

            /* check if point is visitable if yes store it in array */
            int nextfield = field_get(field, next.x, next.y, next.z);
            if(!field_is_visitable(field, next.x, next.y, next.z))
            {
                continue;
            }

            if(nextfield < score && nextfield < nextpoint.score)
            {
                nextpoint = next;
                nextpoint.score = nextfield;
            }
        }

        printf("nextpoint = (%d, %d, %d)\n", nextpoint.x, nextpoint.y, nextpoint.z);
        if(nextpoint.z != current.z)
        {
            field_set(field, current.x, current.y, current.z, VIA);
        }
        else
        {
            field_set(field, current.x, current.y, current.z, PATH);
        }

        xdiff = nextpoint.x - (int)current.x;
        ydiff = nextpoint.y - (int)current.y;
        zdiff = nextpoint.z - (int)current.z;

        struct rpoint* path_point = point_new(xdiff, ydiff, zdiff, 0);
        net_enqueue_point(net, path_point);

        current.x = nextpoint.x;
        current.y = nextpoint.y;
        current.z = nextpoint.z;

    } while (!(current.x == startpos->x && current.y == startpos->y && current.z == startpos->z));

    net_reverse_points(net);

    /* mark start and end of net as ports */
    field_set(field, startpos->x, startpos->y, startpos->z, PORT);
    field_set(field, endpos->x, endpos->y, endpos->z, PORT);
    field_reset(field);
    net_mark_as_routed(net);
}


#include "lrouter_route.h"

#include "lrouter_net.h"
#include "lrouter_queue.h"
#include "lrouter_min_heap.h"
#include "lrouter_field.h"

#include <stdlib.h>
#include <stdio.h>
#include <limits.h>

#define EVEN(val) ((val % 2) == 0)
#define POSITIVE(val) (val > 0)
#define NUM_DIRECTIONS 6

#define STEP_COST 2
#define VIA_COST 63
#define WRONG_DIR_COST 11

const int xincr[NUM_DIRECTIONS] = {-1,  0,  1,  0,  0,  0};
const int yincr[NUM_DIRECTIONS] = { 0,  1,  0, -1,  0,  0};
const int zincr[NUM_DIRECTIONS] = { 0,  0,  0,  0, -1,  1};

static inline struct rpoint _min_next_point(const struct rpoint *nextpoints)
{
    struct rpoint min_point = { .score = INT_MAX };
    for(int i = 0; i < NUM_DIRECTIONS; i++)
    {
        min_point = (nextpoints[i].score < min_point.score) ?
                nextpoints[i] : min_point;
    }
    return min_point;
}

static int _next_field_position(int i, const struct rpoint* current,
				struct rpoint* next)
{
    next->x = current->x + xincr[i];
    next->y = current->y + yincr[i];
    next->z = current->z + zincr[i];
    return 1;
}

static int _get_cost_increment(struct rpoint current, struct rpoint next)
{
    if(next.z != current.z) /* via */
    {
        return VIA_COST;
    }
    else if(next.y != current.y && EVEN(current.z)) /* wrong y direction */
    {
        return WRONG_DIR_COST;
    }
    else if (next.x != current.x && !EVEN(current.z)) /* wrong x direction */
    {
        return WRONG_DIR_COST;
    }
    return STEP_COST;
}

static int _is_unvisited(int nextfield)
{
    return nextfield == UNVISITED;
}

static int _is_final_port(int nextfield, struct rpoint next,
			  const struct position* endpos)
{
    return nextfield == PORT && next.x == endpos->x && next.y == endpos->y &&
	    next.z == endpos->z;
}

static int _is_smaller_score(int score, int score_incr, int nextfield)
{
    return (score + score_incr) < nextfield;
}

static int _find_path(struct field *field, const struct position *startpos,
		      const struct position *endpos)
{
//    printf("finding path from %s:%s (%u,%u,%u) to %s:%s (%u,%u,%u)\n",
//	   startpos->instance, startpos->port, startpos->x, startpos->y,
//	   startpos->z, endpos->instance, endpos->port, endpos->x, endpos->y,
//	   endpos->z);
    /* put starting point in min_heap */
    int routing_cost = INT_MAX;
    struct minheap* min_heap = heap_init();
    heap_insert_point(min_heap, startpos->x, startpos->y, startpos->z, 0);

    struct rpoint current = { .x = startpos->x, .y = startpos->y,
	.z = startpos->z };

    field_set(field, startpos->x, startpos->y, startpos->z, 0);

    /* do as long as there are points to be marked or endpoint is reached */
    while(!(current.x == endpos->x && current.y == endpos->y &&
	current.z == endpos->z))
    {
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

            int score_incr = _get_cost_increment(current, next);

            /* check if point is visitable */
            int nextfield = field_get(field, next.x, next.y, next.z);
            if( _is_unvisited(nextfield) ||
                _is_final_port(nextfield, next, endpos) ||
                _is_smaller_score(score, score_incr, nextfield)
            )
            {
                routing_cost = score + score_incr;
                field_set(field, next.x, next.y, next.z, routing_cost);
                heap_insert_point(min_heap, next.x, next.y, next.z,
			      routing_cost);
            }
        }

        /* router is stuck */
        if(heap_empty(min_heap))
        {
            /* clean up */
	        puts("STUCK");
            heap_destroy(min_heap);
	        return INT_MAX;
        }
    }
    heap_destroy(min_heap);
    //printf("finished finding path with %i cost\n", routing_cost);
    return routing_cost;
}

static void _backtrace(struct field *field, struct net *net,
		      struct position *startpos, struct position *endpos,
		      struct vector *pathpoints)
{
    struct rpoint current = { .x = endpos->x, .y = endpos->y, .z = endpos->z };

    int xdiff = 0;
    int ydiff = 0;
    int zdiff = 0;

    struct rpoint oldpoint = {.x = UINT_MAX, .y = UINT_MAX, .z = UINT_MAX,
	    .score = INT_MAX};

    /* backtrace */
    while(!(current.x == startpos->x &&
	    current.y == startpos->y &&
	    current.z == startpos->z))
    {
        int score = field_get(field, current.x, current.y, current.z);
        struct rpoint nextpoints[] = { [0  ... NUM_DIRECTIONS - 1] =
                {.x = UINT_MAX, .y = UINT_MAX, .z = UINT_MAX,
			.score = INT_MAX}};

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

            int is_wrong_dir = (yincr[i] && EVEN(current.z)) ||
		    (xincr[i] && !EVEN(current.z));
            int is_reachable =
                ((score - nextfield) == VIA_COST) ||
                (((score - nextfield) == WRONG_DIR_COST) && is_wrong_dir) ||
                (((score - nextfield) == STEP_COST) && !is_wrong_dir);

            if(is_reachable && nextfield < score &&
	       nextfield < nextpoints[i].score)
            {
                nextpoints[i] = next;
                nextpoints[i].score = nextfield;

                /*
                 * check if the point before the current point has been initialized
                 * and a corner is ocurring
                 * if yes store the point, and modify its score gets ranked lower than another
                 * reachable point with the same score without a corner
                 */
                if(oldpoint.x != UINT_MAX &&
                                ((oldpoint.x != current.x &&
				  current.x == next.x) ||
                                (oldpoint.y != current.y &&
				 current.y == next.y)))
                {
                    nextpoints[i].score += WRONG_DIR_COST;
                    nextpoints[i].score += STEP_COST;
                }
            }
        }

        struct rpoint nextpoint = _min_next_point(nextpoints);

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

	vector_unique_append(pathpoints,
			     point_new(current.x, current.y, current.z,
				       UNVISITED));

        oldpoint.x = current.x;
        oldpoint.y = current.y;
        oldpoint.z = current.z;

        current.x = nextpoint.x;
        current.y = nextpoint.y;
        current.z = nextpoint.z;
    }
    field_set(field, startpos->x, startpos->y, startpos->z, PATH);
    field_set(field, endpos->x, endpos->y, endpos->z, PORT);
}

int route(struct net *net, struct field* field)
{
    printf("routing %s\n", net_get_name(net));
    int routing_cost = INT_MAX;
    int closest_index = INT_MAX;

    struct position startpos;
    struct position minimum_endpos;
    struct position minimum_startpos;

    struct vector *pathpoints = vector_create(1);

    vector_append(pathpoints, net_position_to_point(net_get_position(net, 0)));

    /*
     * for every possible point do a route search,
     * get the next point with the lowest routing cost,
     * backtrace and add the new backtrace points to the
     * possible points vector
     * repeat until all ports are reached
     */
    while(net_get_size(net) >= 1)
    {
	int min_routing_cost = INT_MAX;
        for(unsigned int i = 0; i < vector_size(pathpoints); i++)
        {
            /*
             * get the next starting point from the list and check for the closest
             * guys
             */
            startpos = *net_point_to_position(vector_get(pathpoints, i));

            for(int j = 1; j < net_get_size(net); j++)
            {
                struct position endpos = *net_get_position(net, j);
                routing_cost = _find_path(field, &startpos, &endpos);

                if(routing_cost < min_routing_cost)
                {
                    closest_index = j;
                    min_routing_cost = routing_cost;
                    minimum_endpos = endpos;
                    minimum_startpos = startpos;
                }
                field_reset(field);
            }
        }

        /* look for path again to prepare the field for the backtrace */
        _find_path(field, &minimum_startpos, &minimum_endpos);

        //printf("backtracing from %s:%s (%u,%u,%u) to %s:%s (%u,%u,%u)\n",
        //       minimum_startpos.instance, minimum_startpos.port,
	//       minimum_startpos.x, minimum_startpos.y,
        //       minimum_startpos.z, minimum_endpos.instance,
	//       minimum_endpos.port, minimum_endpos.x, minimum_endpos.y,
	//       minimum_endpos.z);

        //field_print(field, 0);
        //field_print(field, 1);
        //printf("net: %s\n", net_get_name(net));
        ////////////////getchar();

        _backtrace(field, net, &minimum_startpos, &minimum_endpos, pathpoints);
        printf("removing position %s:%s (%u,%u,%u)\n",
               net_get_position(net, closest_index)->instance,
	       net_get_position(net, closest_index)->port,
	       net_get_position(net, closest_index)->x,
	       net_get_position(net, closest_index)->y,
               net_get_position(net, closest_index)->z);

        net_remove_position(net, closest_index);

        field_reset(field);
    }
    /*
     * find path in between all possible
     * new positions and closest next position
     */

    net_reverse_points(net);

    /* mark start and end of net as ports */
    field_reset(field);
    net_mark_as_routed(net);
    return routing_cost;
}


#include "lrouter_net.h"
#include "lrouter_queue.h"
#include "lrouter_min_heap.h"
#include "lrouter_field.h"
#include "lrouter_route.h"

#include <unistd.h>
#include <stdlib.h>
#include <stdbool.h>
#include <stdio.h>
#include <string.h>
#include <limits.h>

#define EVEN(val) ((val % 2) == 0)
#define POSITIVE(val) (val > 0)

#define NUM_DIRECTIONS 6
const int xincr[NUM_DIRECTIONS] = {-1, 0, 1, 0, 0, 0};
const int yincr[NUM_DIRECTIONS] = {0, 1, 0, -1, 0, 0};
const int zincr[NUM_DIRECTIONS] = {0, 0, 0, 0, -1, 1};

/* returns the minimum score point from a NUM_DIRECTIONS large point_t array */
static point_t *get_min_point(point_t *arr)
{
	point_t *point = arr;
	for(int i = 0; i < NUM_DIRECTIONS; i++)
	{
		point = (arr[i].score < point->score) ? &arr[i] : point;
	}
	return point;
}

void route(struct net *net, struct field* field, size_t wrong_dir_cost, size_t via_cost)
{
    const struct position* pos0 = net_get_startpos(net);
	unsigned int startx = pos0->x;
	unsigned int starty = pos0->y;
	unsigned int startz = pos0->z;
    const struct position* pos1 = net_get_endpos(net);
	unsigned int endx = pos1->x;
	unsigned int endy = pos1->y;
	unsigned int endz = pos1->z;

	printf("calling route with net from x:%u, y:%u, z:%u to\
	       x:%u, y:%u, z:%u\n", startx, starty, startz, endx, endy, endz);

	/* put starting point in min_heap */
	struct minheap* min_heap = heap_init();
	heap_insert_point(min_heap, startx, starty, startz, 0);

	int score = 0;
	unsigned int x, y, z, nextx, nexty, nextz = 0;
	point_t *point_ptr;
	field_set(field, startx, starty, startz, 0);

	/*
	 * do as long as there are points
	 * to be marked or
	 * endpoint is reached
	 */
	do {
		/* get next point from heap */
		point_ptr = heap_get_point(min_heap);

		x = point_ptr->x;
		y = point_ptr->y;
		z = point_ptr->z;

        free(point_ptr);

		score = field_get(field, x, y, z);

		/* circle around every point */
		for(int i = 0; i < NUM_DIRECTIONS; i++)
		{
			nextx = x + xincr[i];
			nexty = y + yincr[i];
			nextz = z + zincr[i];

			if(nextx >= field_get_width(field) || nexty >= field_get_height(field) || nextz >= field_get_num_layers(field))
            {
				continue;
            }

			/* decide the val of the score incrementer */
			unsigned int score_incr = 1;
			if(nextz != z)
			{
				/* got a via */
				score_incr = via_cost;
			}
			else if (nexty != y && EVEN(z))
			{
				/* route in y direction preferred on uneven layers */
				score_incr = wrong_dir_cost;
			}
			else if (nextx != x && !EVEN(z))
			{
				score_incr = wrong_dir_cost;
			}

			/* check if point is visitable */
		    int nextfield = field_get(field, nextx, nexty, nextz);
			if((nextfield == PORT &&
			    nextx == endx &&
			    nexty == endy &&
			    nextz == endz) ||
			   nextfield == UNVISITED ||
			   (score + (int)score_incr < nextfield))
			{
				if(nextx == endx && nexty == endy && nextz == endz)
				{
					/*
					 * if next point is endpoint
					 * put it into front of heap
					 * so empty the heap (not nice way)
					 */
                    point_t* pt;
					while((pt = heap_get_point(min_heap)))
                    {
                        free(pt);
                    }
				}

				field_set(field, nextx, nexty, nextz, score + score_incr);

				/* put the point in the to be visited queue */
				heap_insert_point(min_heap, nextx, nexty, nextz, score + score_incr);
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
	} while(!(x == endx && y == endy && z == endz));

    heap_destroy(min_heap);

	/* 
    * backtrace
    * go to end point 
    */
	x = endx;
	y = endy;
    
    int xdiff = 0;
    int ydiff = 0;
    int zdiff = 0;

	do {
		score = field_get(field, x, y, z);

		/* array to look for the least costing neighboring point */
		point_t nextpoints[NUM_DIRECTIONS];
		memset(nextpoints, UINT_MAX, sizeof(point_t) * NUM_DIRECTIONS);

		/*
		 * circle around every point + check layer above and below
		 * store possible points in array
		 */
		for(int i = 0; i < NUM_DIRECTIONS; i++)
		{
			nextx = x + xincr[i];
			nexty = y + yincr[i];
			nextz = z + zincr[i];

			if(nextx >= field_get_width(field) || nexty >= field_get_height(field) || nextz >= field_get_num_layers(field))
			{
				continue;
			}

			/* check if point is visitable if yes store it in array */
			int nextfield = field_get(field, nextx, nexty, nextz);
			if(nextfield == UNVISITED || nextfield == PATH || nextfield == VIA)
			{
                continue;
			}

            if(nextfield < score)
            {
                nextpoints[i].x = nextx;
                nextpoints[i].y = nexty;
                nextpoints[i].z = nextz;
                nextpoints[i].score = nextfield;
            }
		}

		bool next_is_via = false;

		point_t *npoint = get_min_point(nextpoints);
		if(next_is_via)
		{
            field_set(field, x, y, z, VIA);
			next_is_via = true;
		}
		else if(npoint->z != (int)z)
		{
            field_set(field, x, y, z, VIA);
			next_is_via = true;
		}
		else
		{
            field_set(field, x, y, z, PATH);
		}

		xdiff = npoint->x - (int)x;
		ydiff = npoint->y - (int)y;
		zdiff = npoint->z - (int)z;

		point_t* path_point = point_new(xdiff, ydiff, zdiff, 0);
		net_enqueue_point(net, path_point);

		x = npoint->x;
		y = npoint->y;
		z = npoint->z;

	} while (!(x == startx && y == starty && z == startz));

	net_reverse_points(net);

	/* mark start and end of net as ports */
    field_set(field, startx, starty, startz, PORT);
    field_set(field, endx, endy, endz, PORT);
	field_reset(field);
    net_mark_as_routed(net);
}


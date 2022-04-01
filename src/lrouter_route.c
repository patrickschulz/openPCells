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

#define EVEN(val) ((val % 2 ) == 0)
#define POSITIVE(val) (val > 0)
#define NUM_DIRECTIONS 6

/* helps to traverse the field */
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

int route(net_t *net, int*** field, size_t width, size_t height,
	  size_t num_layers, size_t wrong_dir_cost, size_t via_cost)
{

	unsigned int startx = net->xs[0];
	unsigned int starty = net->ys[0];
	unsigned int startz = net->zs[0];
	unsigned int endx = net->xs[1];
	unsigned int endy = net->ys[1];
	unsigned int endz = net->zs[1];

	/* prepare starting point */
	point_t start;
	start.x = startx;
	start.y = starty;
	start.z = startz;
	start.score = 0;

	/* put starting point in min_heap */
	min_heap_t *min_heap = heap_init();
	heap_insert_point(min_heap, &start);

	net->path = queue_new();

	int score = 0;
	unsigned int x, y, z, nextx, nexty, nextz;
	point_t *point_ptr;
	field[startz][startx][starty] = 0;

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

		score = field[z][x][y];

		/* circle around every point */
		for(int i = 0; i < NUM_DIRECTIONS; i++)
		{
			nextx = x + xincr[i];
			nexty = y + yincr[i];
			nextz = z + zincr[i];

			if(nextx >= width || nexty >= height ||
			   nextz >= num_layers)
				continue;

			/* check if point is visitable */
			int nextfield = field[nextz][nextx][nexty];

			/* decide the val of the score incrementer */
			unsigned int score_incr = 1;
			if(nextz != z)
			{
				/* got a via */
				score_incr = via_cost;
			}
			else if (nexty != y && EVEN(z))
			{
				/*
				 * route in y direction preferred on
				 * uneven layers
				 */
				score_incr = wrong_dir_cost;
			}
			else if (nextx != x && !EVEN(z))
			{
				score_incr = wrong_dir_cost;
			}

			if((nextfield == PORT &&
			    nextx == endx &&
			    nexty == endy &&
			    nextz == endz) ||
			   nextfield == UNVISITED ||
			   (score + (int)score_incr < nextfield))
			{
				if(nextx == endx &&
				   nexty == endy &&
				   nextz == endz)
				{
					/*
					 * if next point is endpoint
					 * put it into front of heap
					 * so empty the heap (not nice way)
					 */
					while(heap_get_point(min_heap));
				}


				field[nextz][nextx][nexty] = score + score_incr;

				/* put the point in the to be visited queue */
				point_t *next = malloc(sizeof(point_t));
				next->x = nextx;
				next->y = nexty;
				next->z = nextz;
				next->score = score + score_incr;
				heap_insert_point(min_heap, next);
			}


		}

	/* router is stuck */
	if(!min_heap->size)
	{
		/* clean up */
		//field[startz][startx][starty] = PORT;
		//field[endz][endx][endy] = PORT;
		reset_field(field, width, height, num_layers);
		return STUCK;
	}
	} while(!(x == endx && y == endy && z == endz));

	/* backtrace */
	/* go to end point */
	x = endx;
	y = endy;

	do {
		score = field[z][x][y];

		/* array to look for the least costing neighboring point */
		point_t nextpoints[NUM_DIRECTIONS];
		memset(nextpoints, UINT_MAX, sizeof(point_t) * NUM_DIRECTIONS);
		bool next_is_via = false;

		/*
		 * circle around every point + check layer above and below
		 * store possible points in array
		 */
		for(int i = 0; i < NUM_DIRECTIONS; i++)
		{
			nextx = x + xincr[i];
			nexty = y + yincr[i];
			nextz = z + zincr[i];

			if(nextx >= width ||
			   nexty >= height ||
			   nextz >= num_layers)
			{
				continue;
			}

			/* check if point is visitable if yes store it in array */
			int nextfield = field[nextz][nextx][nexty];

			switch(nextfield)
			{
				case UNVISITED:
				case PATH:
				case VIA:
					continue;
			}

				if(nextfield < score)
				{
				    point_t point;
				    point.x = nextx;
				    point.y = nexty;
				    point.z = nextz;
				    point.score = nextfield;
				    nextpoints[i] = point;
				}
		}

		point_t *npoint = get_min_point(nextpoints);
		if(next_is_via)
		{
			field[z][x][y] = VIA;
			next_is_via = FALSE;
		}
		else if(npoint->z != (int)z)
		{
			field[z][x][y] = VIA;
			next_is_via = TRUE;
		}
		else
		{
			field[z][x][y] = PATH;
		}

		int xdiff, ydiff, zdiff;
		xdiff = npoint->x - x;
		ydiff = npoint->y - y;
		zdiff = npoint->z - z;

		x = npoint->x;
		y = npoint->y;
		z = npoint->z;

		/* put the point diffs in the nets path queue */
		point_t *path_point = malloc(sizeof(point_t));
		path_point->x = xdiff;
		path_point->y = ydiff;
		path_point->z = zdiff;
		queue_enqueue(net->path, path_point);


	} while (!(x == startx && y == starty && z == startz));

	queue_reverse(net->path);
	/* mark start and end of net as ports */

	field[startz][startx][starty] = PORT;
	field[endz][endx][endy] = PORT;
	reset_field(field, width, height, num_layers);
	return ROUTED;
}

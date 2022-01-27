#include "lrouter_net.h"
#include "lrouter_queue.h"
#include "lrouter_min_heap.h"
#include "lrouter_field.h"
#include "lrouter_route.h"

#include <unistd.h>
#include <stdlib.h>
#include <stdio.h>

#define EVEN(val) ((val % 2 ) == 0)
#define NUM_DIRECTIONS 6

/* helps to traverse the field */
const int xincr[NUM_DIRECTIONS] = {-1, 0, 1, 0, 0, 0};
const int yincr[NUM_DIRECTIONS] = {0, 1, 0, -1, 0, 0};
const int zincr[NUM_DIRECTIONS] = {0, 0, 0, 0, -1, 1};

int route(net_t net, int*** field, size_t fieldsize, size_t num_layers,
	  size_t wrong_dir_cost, size_t via_cost)
{
	unsigned int startx = net.x1;
	unsigned int starty = net.y1;
	unsigned int startz = net.z1;
	unsigned int endx = net.x2;
	unsigned int endy = net.y2;
	unsigned int endz = net.z2;

	/* prepare starting point */
	point_t start;
	start.x = startx;
	start.y = starty;
	start.z = startz;
	start.score = 0;

	/* put starting point in min_heap */
	min_heap_t *min_heap = heap_init();
	heap_insert_point(min_heap, &start);

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
		printf("route %u %u to %u %u\n", startx, starty, endx, endy);
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
			printf("next coords %u, %u, %u\n", nextx, nexty, nextz);

			if(nextx >= fieldsize || nexty >= fieldsize ||
			   nextz >= num_layers)
				continue;

			/* check if point is visitable */
			int nextfield = field[nextz][nextx][nexty];
			if((nextfield == PORT &&
			    nextx == endx &&
			    nexty == endy &&
			    nextz == endz) ||
			   nextfield == UNVISITED)
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
		field[startz][startx][starty] = PORT;
		field[endz][endx][endy] = PORT;
		reset_field(field, fieldsize, num_layers);
		return STUCK;
	}

	} while(!(x == endx && y == endy && z == endz));
	/* backtrace */
	/* go to end point */
	x = endx;
	y = endy;
	printf("backtrace route %u %u to %u %u\n", startx, starty, endx, endy);
	do {
		score = field[z][x][y];
		field[z][x][y] = PATH;
	printf("backtrace %u %u %u, score: %i\n", x, y, z, score);

		/* circle around every point + check layer above and below */
		for(int i = 0; i < NUM_DIRECTIONS; i++)
		{
			nextx = x + xincr[i];
			nexty = y + yincr[i];
			nextz = z + zincr[i];

			if(nextx >= fieldsize ||
			   nexty >= fieldsize ||
			   nextz >= num_layers)
			{
				continue;
			}

			if(nextx == startx && nexty == starty && nextz == startz)
			{
				x = nextx;
				y = nexty;
				z = nextz;
				break;
			}

			/* check if point is visitable */
			int nextfield = field[nextz][nextx][nexty];
			printf("nextfield: %i\n", nextfield);
			if(nextfield == (PORT || PATH || VIA))
			{
				continue;
			}

			/* go to the one with val = lowest currentval */
			if(nextfield < score)
			{
			    x = nextx;
			    y = nexty;
			    y = nextz;

			    /* put the point in the nets path queue */
			    point_t *path_point = malloc(sizeof(point_t));
			    path_point->x = x;
			    path_point->y = y;
			    path_point->z = z;
			    queue_enqueue(net.path, path_point);
			    break;
			}
		}
	} while (!(x == startx && y == starty && z == startz));

	/* mark start and end of net as ports */
	field[startz][startx][starty] = PORT;
	field[startz][endx][endy] = PORT;
	reset_field(field, fieldsize, num_layers);
	return ROUTED;
}

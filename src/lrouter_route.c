#include "lrouter_net.h"
#include "lrouter_queue.h"
#include "lrouter_field.h"
#include "lrouter_route.h"

#include <unistd.h>
#include <stdlib.h>
#include <stdio.h>

#define EVEN(val) ((val % 2 ) == 0)

#define NUM_DIRECTIONS 6

/* pointer to queue to save the to be visited points */
queue_t *queue;

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
	start.score = 0;

	/* put starting point in queue */
	queue = queue_new();
	queue_enqueue(queue, &start);

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
		/* get next point from queue */
		point_ptr = (point_t*)queue_dequeue(queue);

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
					 * put it into front of queue
					 * so empty the queue (not nice way)
					 */
					while(!queue_empty(queue))
					{
						queue_dequeue(queue);
					}
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
				next->score = score;
				queue_enqueue(queue, next);
			}


		}

	/* router is stuck */
	if(queue_empty(queue))
	{
		/* clean up */
		field[startz][startx][starty] = PORT;
		field[endz][endx][endy] = PORT;
		reset_field(field, fieldsize, num_layers);
		return STUCK;
	}

	} while(!(x == endx && y == endy));

	/* backtrace */
	/* go to end point */
	x = endx;
	y = endy;
	do {
		printf("backtrace route %u %u to %u %u\n", startx, starty, endx, endy);
		score = field[z][x][y];
		field[z][x][y] = PATH;

		/* circle around every point + check layer above and below */
		for(int i = 0; i < NUM_DIRECTIONS; i++)
		{
			nextx = x + xincr[i];
			nexty = y + yincr[i];

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
			if(nextfield == (PORT || PATH || VIA))
			{
				continue;
			}

			/* go to the one with val = lower than currentval */
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
	} while (!(x == startx && y == starty));

	/* mark start and end of net as ports */
	field[startz][startx][starty] = PORT;
	field[startz][endx][endy] = PORT;
	reset_field(field, fieldsize, num_layers);
	return ROUTED;
}

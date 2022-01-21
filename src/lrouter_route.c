#include "lrouter_net.h"
#include "lrouter_queue.h"
#include "lrouter_field.h"
#include "lrouter_route.h"

#include <unistd.h>
#include <stdlib.h>
#include <stdio.h>

/* pointer to queue to save the to be visited points */
queue_t *queue;

/* helps to traverse the field */
const int xincr[4] = { -1, 0, 1,  0 };
const int yincr[4] = {  0, 1, 0, -1 };

int route(net_t net, int** field, size_t fieldsize)
{
	unsigned int startx = net.x1;
	unsigned int starty = net.y1;
	unsigned int endx = net.x2;
	unsigned int endy = net.y2;


	/* prepare starting point */
	point_t start;
	start.x = startx;
	start.y = starty;

	/* put starting point in queue */
	queue = queue_new();
	queue_enqueue(queue, &start);

	int counter = 0;
	unsigned int x, y, nextx, nexty;
	point_t *point_ptr;
	field[startx][starty] = 0;

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

		counter = field[x][y];

		/* circle around every point */
		for(int i = 0; i < 4; i++)
		{
			nextx = x + xincr[i];
			nexty = y + yincr[i];

			if(nextx >= fieldsize || nexty >= fieldsize)
				continue;

			/* check if point is visitable */
			int nextfield = field[nextx][nexty];
			if((nextfield == PORT && nextx == endx && nexty == endy) ||
			   nextfield == UNVISITED)
			{
				if(nextx == endx && nexty == endy)
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

				field[nextx][nexty] = counter + 1;

				/* put the point in the to be visited queue */
				point_t *next = malloc(sizeof(point_t));
				next->x = nextx;
				next->y = nexty;
				queue_enqueue(queue, next);
			}


		}

		counter++;
		usleep(2*1000);
		print_field(field, fieldsize);

	/* router is stuck */
	if(queue_empty(queue))
	{
		/* clean up */
		field[startx][starty] = PORT;
		field[endx][endy] = PORT;
		reset_field(field, fieldsize);
		return STUCK;
	}

	} while(!(x == endx && y == endy));

	/* backtrace */
	/* go to end point */
	x = endx;
	y = endy;
	do {
		printf("backtrace route %u %u to %u %u\n", startx, starty, endx, endy);
		counter = field[x][y];
		field[x][y] = PATH;

		/* circle around every point */
		for(int i = 0; i < 4; i++)
		{
			nextx = x + xincr[i];
			nexty = y + yincr[i];

			if(nextx >= fieldsize || nexty >= fieldsize)
				continue;

			if(nextx == startx && nexty == starty)
			{
				x = nextx;
				y = nexty;
				break;
			}

			/* check if point is visitable */
			int nextfield = field[nextx][nexty];

			/* go to the one with val = currval - 1 */
			if(nextfield == (counter - 1))
			{
			    x = nextx;
			    y = nexty;

			    /* put the point in the nets path queue */
			    point_t *path_point = malloc(sizeof(point_t));
			    path_point->x = x;
			    path_point->y = y;
			    queue_enqueue(net.path, path_point);

			    break;
			}
		}
		usleep(2*1000);
		print_field(field, fieldsize);
	} while (!(x == startx && y == starty));

	/* mark start and end of net as ports */
	field[startx][starty] = PORT;
	field[endx][endy] = PORT;
		usleep(50*1000);
		print_field(field, fieldsize);
	reset_field(field, fieldsize);
	return ROUTED;
}

#include "lrouter_net.h"
#include "lrouter_field.h"
#include "lrouter_queue.h"

#include <stdlib.h>
#include <stdio.h>
#include <stdbool.h>
#include <time.h>

#define DEFAULT_POINT_SCORE 0

#define BETWEEN(value, min, max) (value < max && value > min)

void net_print_nets(net_t* nets, size_t num_nets)
{
    for (unsigned int i = 0; i < num_nets; i++)
    {
        printf("Net %s, size: %u\n", nets[i].name, nets[i].size);
	for (size_t j = 0; j < nets[i].size; j++)
	{
		printf("\t(%u, %u, %u, inst: %s, port: %s) ->\n",
		       nets[i].positions[j].x,
		       nets[i].positions[j].y,
		       nets[i].positions[j].z,
		       nets[i].positions[j].instance,
		       nets[i].positions[j].port);
	}
	printf("rank: %u, routed?: %i\n", nets[i].ranking, nets[i].routed);
    }
}

void net_print_path(net_t *net)
{
	printf("Printing path of %s:\n", net->name);
	point_t *point;
	for(int i = 0; i < queue_len(net->path); i++)
	{
		point = (point_t *)queue_peek_nth_elem(net->path, i);
		printf("P %i, x:%i, y:%i, z:%i\n", i, point->x, point->y,
		       point->z);
	}
}

int cmp_func(void const *a, void const *b)
{
	return (((net_t *)a)->ranking - ((net_t *)b)->ranking);
}

position_t *net_create_position(const char *instance, const char *port,
			       unsigned int x, unsigned int y)
{
	position_t *pos = calloc(1, sizeof(position_t));

	pos->instance = calloc(strlen(instance) + 1, 1);
	strcpy(pos->instance, instance);
	pos->port = calloc(strlen(port) + 1, 1);
	strcpy(pos->port, port);

	pos->x = x;
	pos->y = y;
	/* all ports are on metal 1 */
	pos->z = 0;

	return pos;
}

void net_del_nth_el_arr(position_t *arr, size_t n, size_t arr_size)
{
    if(arr == NULL || n >= arr_size)
        return;

    for(size_t i = n; i < arr_size - 1; i++)
    {
        arr[i] = arr[i+1];
    }
    position_t *new_arr = realloc(arr, sizeof(position_t) * (arr_size - 1));

    if (!new_arr)
    {
        printf("couldnt realloc in del_nth_el_arr\n");
        return;
    }
    else
    {
        arr = new_arr;
    }

}

/* creates deltas out of a nets routed path */
void net_create_deltas(net_t *net)
{
    /* dont need to create deltas if the net has too few points */
    int net_len;
    if((net_len = queue_len(net->path)) < 3)
        return;

    point_t *points;
    if((points = queue_as_array(net->path)) == NULL)
        return;

    queue_t *queue = queue_new();

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
            point_t *point = point_new(xsteps, 0, 0, DEFAULT_POINT_SCORE);
            queue_enqueue(queue, point);
        }
        else if(points[i].y && !points[i+1].y)
        {
            point_t *point = point_new(0, ysteps, 0, DEFAULT_POINT_SCORE);
            queue_enqueue(queue, point);
        }
        else if(points[i].z && !points[i+1].z)
        {
            point_t *point = point_new(0, 0, zsteps, DEFAULT_POINT_SCORE);
            queue_enqueue(queue, point);
        }
    }

    /* put last connection to end port into queue (no corner here) */
    point_t *point;
    xsteps += points[net_len - 1].x;
    ysteps += points[net_len - 1].y;
    zsteps += points[net_len - 1].z;

    if(points[net_len - 1].x)
    {
	    point = point_new(xsteps, 0, 0, DEFAULT_POINT_SCORE);
    }
    else if(points[net_len - 1].y)
    {
	    point = point_new(0, ysteps, 0, DEFAULT_POINT_SCORE);
    }
    else if(points[net_len - 1].z)
    {
	    point = point_new(0, 0, zsteps, DEFAULT_POINT_SCORE);
    }
    queue_enqueue(queue, point);

    /* delete the old path */
    free(net->path);
    net->path = queue;
}

void net_sort_nets(net_t* nets, size_t num_nets)
{
	unsigned int xlo, xhi, ylo, yhi;
	for(size_t i = 0; i < num_nets; i++)
	{
		unsigned int ranking = 0;

		/* create rectangle */
		xlo = (nets[i].positions[0].x <= nets[i].positions[1].x) ?
			nets[i].positions[0].y : nets[i].positions[1].y;
		xhi = (nets[i].positions[0].x > nets[i].positions[1].x) ?
			nets[i].positions[0].x : nets[i].positions[1].x;
		ylo = (nets[i].positions[0].y <= nets[i].positions[1].y) ?
			nets[i].positions[0].y : nets[i].positions[1].y;
		yhi = (nets[i].positions[0].y > nets[i].positions[1].y) ?
			nets[i].positions[0].y : nets[i].positions[1].y;

		for(size_t j = 0; j < num_nets; j++)
		{
			/* how many ports of other nets are inside rect */
			if(j != i)
			{
				if(BETWEEN(nets[j].positions[0].x, xlo, xhi) &&
				   BETWEEN(nets[j].positions[0].y, ylo, yhi))
					ranking++;

				if(BETWEEN(nets[j].positions[1].x, xlo, xhi) &&
				   BETWEEN(nets[j].positions[1].y, ylo, yhi))
					ranking++;
			}
		}
		nets[i].ranking = ranking;
	}
	/* sort rankings */
	qsort(nets, num_nets, sizeof(net_t), cmp_func);
}

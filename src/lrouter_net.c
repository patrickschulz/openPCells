#include "lrouter_net.h"
#include "lrouter_field.h"
#include "lrouter_queue.h"

#include <stdlib.h>
#include <stdio.h>
#include <time.h>

#define BETWEEN(value, min, max) (value < max && value > min)

void print_nets(net_t* nets, size_t num_nets)
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

void print_path(net_t net)
{
	printf("Found path:\n");
	point_t *point;
	int i = 0;
	while((point = (point_t *)queue_dequeue(net.path)) != NULL)
	{
		printf("P %i, x:%i, y:%i\n", i, point->x, point->y);
		i++;
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
	pos->z = 1;

	return pos;
}

void sort_nets(net_t* nets, size_t num_nets)
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

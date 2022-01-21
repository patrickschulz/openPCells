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
        printf("Net %u: (%u, %u) -> (%u, %u), rank: %u, routed?: %i\n", i, 
	       nets[i].x1, nets[i].y1, nets[i].x2, nets[i].y2, nets[i].ranking, 
	       nets[i].routed);
    }
}

void fill_ports(net_t* nets, size_t num_nets, int** field)
{
	int x1, y1, x2, y2;
	for (unsigned int i = 0; i < num_nets; i++)
	{
		x1 = nets[i].x1;
		y1 = nets[i].y1;
		x2 = nets[i].x2;
		y2 = nets[i].y2;
		field[x1][y1] = PORT;
		field[x2][y2] = PORT;
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

void sort_nets(net_t* nets, size_t num_nets)
{
	unsigned int xlo, xhi, ylo, yhi;
	for(size_t i = 0; i < num_nets; i++)
	{
		unsigned int ranking = 0;

		/* create rectangle */
		xlo = (nets[i].x1 <= nets[i].x2) ? nets[i].x1 : nets[i].x2;
		xhi = (nets[i].x1 > nets[i].x2) ? nets[i].x1 : nets[i].x2;
		ylo = (nets[i].y1 <= nets[i].y2) ? nets[i].y1 : nets[i].y2;
		yhi = (nets[i].y1 > nets[i].y2) ? nets[i].y1 : nets[i].y2;

		for(size_t j = 0; j < num_nets; j++)
		{
			/* how many ports of other nets are inside rect */
			if(j != i)
			{
				if(BETWEEN(nets[j].x1, xlo, xhi) &&
				   BETWEEN(nets[j].y1, ylo, yhi))
					ranking++;
				if(BETWEEN(nets[j].x2, xlo, xhi) &&
				   BETWEEN(nets[j].y2, ylo, yhi))
					ranking++;
			}

		}
		nets[i].ranking = ranking;
	}
	/* sort rankings */
	qsort(nets, num_nets, sizeof(net_t), cmp_func);
}

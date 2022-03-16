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
        printf("Net %s:", nets[i].name);
	for (size_t j = 0; j < nets[i].size; j++)
	{
		printf(" (%u, %u, %u) -> ",
		       nets[i].xs[j], nets[i].ys[j], nets[i].zs[j]);
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

void sort_nets(net_t* nets, size_t num_nets)
{
	unsigned int xlo, xhi, ylo, yhi;
	for(size_t i = 0; i < num_nets; i++)
	{
		unsigned int ranking = 0;

		/* create rectangle */
		xlo = (nets[i].xs[0] <= nets[i].xs[1]) ? nets[i].xs[0] :
			nets[i].xs[1];
		xhi = (nets[i].xs[0] > nets[i].xs[1]) ? nets[i].xs[0] :
			nets[i].xs[1];
		ylo = (nets[i].ys[0] <= nets[i].ys[1]) ? nets[i].ys[0] :
			nets[i].ys[1];
		yhi = (nets[i].ys[0] > nets[i].ys[1]) ? nets[i].ys[0] :
			nets[i].ys[1];

		for(size_t j = 0; j < num_nets; j++)
		{
			/* how many ports of other nets are inside rect */
			if(j != i)
			{
				if(BETWEEN(nets[j].xs[0], xlo, xhi) &&
				   BETWEEN(nets[j].ys[0], ylo, yhi))
					ranking++;
				if(BETWEEN(nets[j].xs[1], xlo, xhi) &&
				   BETWEEN(nets[j].ys[1], ylo, yhi))
					ranking++;
			}

		}
		nets[i].ranking = ranking;
	}
	/* sort rankings */
	qsort(nets, num_nets, sizeof(net_t), cmp_func);
}

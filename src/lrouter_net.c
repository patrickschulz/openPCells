#include "lrouter_net.h"
#include "lrouter_field.h"
#include "lrouter_queue.h"
#include <stdlib.h>
#include <stdio.h>
#include <time.h>

void print_nets(net_t* nets, size_t num_nets)
{
    for (unsigned int i = 0; i < num_nets; i++)
    {
        printf("Net %i: (%i, %i) -> (%i, %i)\n", i, nets[i].x1,
            nets[i].y1, nets[i].x2, nets[i].y2);
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

#ifndef OPC_LROUTER_NET_H
#define OPC_LROUTER_NET_H

#include <stddef.h>

#include "lrouter_queue.h"

/* net struct */
typedef struct {
    int x1, x2;
    int y1, y2;
	/* queue to save the path in the end */
	queue_t *path;
} net_t;

void print_nets(net_t* nets, size_t num_nets);
/* fill ports of nets into field */
void fill_ports(net_t* nets, size_t num_nets, int** field);

/* prints the path of a given net */
void print_path(net_t net);

#endif // OPC_LROUTER_NET_H

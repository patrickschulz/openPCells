#ifndef LROUTER_NET_H
#define LROUTER_NET_H

#include <stddef.h>

#include "lrouter_queue.h"

/* net struct */
typedef struct {
    char *name;
    char *firstport;
    char *firstinstance;
    unsigned int size;
    unsigned int *xs;
    unsigned int *ys;
    unsigned int *zs;
    unsigned int ranking;
    int routed;
    /* queue to save the path in the end */
    queue_t *path;
} net_t;

/*
 * sorts the nets in ascending order of number of
 * pins within their bounding boxes
 */
void sort_nets(net_t *nets, size_t num_nets);

void print_nets(net_t* nets, size_t num_nets);
/* fill ports of nets into field */
void fill_ports(net_t* nets, size_t num_nets, int*** field);

/* prints the path of a given net */
void print_path(net_t net);

#endif

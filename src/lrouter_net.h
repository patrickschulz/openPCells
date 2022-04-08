#ifndef LROUTER_NET_H
#define LROUTER_NET_H

#include <stddef.h>

#include "lrouter_queue.h"

typedef struct {
    char *instance;
    char *port;
    unsigned int x;
    unsigned int y;
    unsigned int z;
} position_t;

/* net struct */
typedef struct {
    char *name;
    unsigned int size;
    unsigned int ranking;
    position_t *positions;
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

/* constructor for position_t */
position_t *net_create_position(const char *instance, const char *port,
			       unsigned int x, unsigned int y);

#endif

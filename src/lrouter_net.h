#ifndef LROUTER_NET_H
#define LROUTER_NET_H

#include <stddef.h>
#include <string.h>

typedef struct position_s position_t;

#include "lrouter_queue.h"

struct position_s {
    char *instance;
    char *port;
    unsigned int x;
    unsigned int y;
    unsigned int z;
};

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
void net_sort_nets(net_t *nets, size_t num_nets);

void net_print_nets(net_t* nets, size_t num_nets);

/* fill ports of nets into field */
void net_fill_ports(net_t* nets, size_t num_nets, int*** field);

/* prints the path of a given net */
void net_print_path(net_t *net);

void net_create_deltas(net_t *net);

/* deletes the nth element of an position_t array and resizes it */
void net_del_nth_el_arr(position_t *arr, size_t n, size_t arr_size);

/* constructor for position_t */
position_t *net_create_position(const char *instance, const char *port,
			       unsigned int x, unsigned int y);

#endif

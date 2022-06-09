#ifndef LROUTER_NET_H
#define LROUTER_NET_H

#include <stddef.h>
#include <string.h>

#include "vector.h"

struct position {
    char* instance;
    char* port;
    unsigned int x;
    unsigned int y;
    unsigned int z;
};

#include "lrouter_queue.h"

/* net struct */
struct net {
    char *name;
    unsigned int ranking;
    struct vector* positions;
    int routed;
    /* queue to save the path in the end */
    struct queue* path;
};

struct net* net_create(const char* name, size_t size);
void net_destroy_position(void *pp);
void net_destroy(void* np);

/*
 * sorts the nets in ascending order of number of
 * pins within their bounding boxes
 */
void net_sort_nets(struct vector* nets);

/* fill ports of nets into field */
void net_fill_ports(struct vector* nets, struct field* field);

void net_create_deltas(struct net *net);

struct position* net_create_position(const char *instance, const char *port, unsigned int x, unsigned int y);
struct position* net_copy_position(struct net* net, size_t index);

#endif

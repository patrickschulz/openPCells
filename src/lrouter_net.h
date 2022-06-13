#ifndef LROUTER_NET_H
#define LROUTER_NET_H

#include <stddef.h>
#include <string.h>

#include "lrouter_field.h"

#include "vector.h"

struct position {
    char* instance;
    char* port;
    unsigned int x;
    unsigned int y;
    unsigned int z;
};

struct net;

struct net* net_create(const char* name, int suffixnum, struct position* startpos, struct position* endpos);
void net_destroy_position(void *pp);
void net_destroy(void* np);

void net_mark_as_routed(struct net* net);
int net_is_routed(const struct net* net);

const char* net_get_name(const struct net* net);

const struct position* net_get_startpos(const struct net* net);
const struct position* net_get_endpos(const struct net* net);

void net_enqueue_point(struct net* net, point_t* pt);
point_t* net_dequeue_point(struct net* net);
void net_reverse_points(struct net* net);

/*
 * sorts the nets in ascending order of number of
 * pins within their bounding boxes
 */
void net_sort_nets(struct vector* nets);

/* fill ports of nets into field */
void net_fill_ports(struct vector* nets, struct field* field);

void net_create_deltas(struct net *net);

struct position* net_create_position(const char *instance, const char *port, unsigned int x, unsigned int y);
struct position* net_copy_position(struct position* pos);

#endif

#ifndef LROUTER_NET_H
#define LROUTER_NET_H

#include "lrouter_field.h"
#include "vector.h"

#include <stddef.h>
#include <string.h>

#define NO_SUFFIX -1

struct position {
    char* instance;
    char* port;
    unsigned int x;
    unsigned int y;
    unsigned int z;
};

struct net;

struct net* net_create(const char* name, int suffixnum, struct vector *positions);
void net_destroy_position(void *pp);
void net_destroy(void* np);
void net_restore_positions(struct net *original, struct net *copy);
struct net *net_copy(const struct net *net);

void net_mark_as_routed(struct net* net);
int net_is_routed(const struct net* net);

const char* net_get_name(const struct net* net);
int net_get_size(const struct net* net);
size_t net_get_endpoints_size(const struct net* net);
const struct position *net_get_position(const struct net *net, size_t i);
const struct position *net_get_endpoint(const struct net *net, size_t i);
struct vector* net_make_deltas(struct vector* deltas);

/*
 * sorts the nets in ascending order of number of
 * pins within their bounding boxes
 */
void net_sort_nets(struct vector* nets);

/* fill ports of nets into field */
void nets_fill_ports(struct vector* nets, struct field* field);
void net_fill_ports(struct net* net, struct field* field);

void net_append_position(struct net *net, struct position *position);
void net_remove_position(struct net *net, unsigned int i);

struct position* net_create_position(const char *instance, const char *port, unsigned int x, unsigned int y, unsigned int z);
const char *net_position_get_inst(const struct position *pos);
const char *net_position_get_port(const struct position *pos);
void* net_copy_position(const void* pos);
struct rpoint *net_position_to_point(const struct position *pos);
struct position *net_point_to_position(const struct rpoint *point);
const struct position *net_get_position_at_point(const struct net *net, const struct rpoint *point);

#endif

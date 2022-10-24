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
struct net* net_create(const char* name, int suffixnum,
		       struct vector *positions);
void net_destroy_position(void *pp);
void net_destroy(void* np);
void net_restore_positions(struct net *original, struct net *copy);
struct net *net_copy(struct net *net);
void net_reverse_deltas(struct net *net);

void net_mark_as_routed(struct net* net);
int net_is_routed(const struct net* net);

const char* net_get_name(const struct net* net);
int net_get_size(const struct net* net);
struct position *net_get_position(struct net *net, unsigned int i);
struct rpoint *net_get_delta(struct net *net, unsigned int i);
void net_print_deltas(struct net *net);
void net_make_deltas(struct net *net);
int net_get_num_deltas(const struct net *net);

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

void net_append_delta(struct net *net, struct rpoint *delta);

struct position* net_create_position(const char *instance, const char *port,
				     unsigned int x, unsigned int y,
				     unsigned int z);
const char *net_position_get_inst(const struct position *pos);
const char *net_position_get_port(const struct position *pos);
struct position* net_copy_position(struct position* pos);
struct rpoint *net_position_to_point(struct position *pos);
struct position *net_point_to_position(struct rpoint *point);
struct position *net_get_position_at_point(struct net *net,
					   struct rpoint *point);

#endif

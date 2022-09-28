#ifndef LROUTER_ROUTE_H
#define LROUTER_ROUTE_H

#include "lrouter_net.h"
#include "lrouter_field.h"

/*
 * use lee algorithm for routing, does backtrace & marks the path as blocked
 * when has_backtrace flag is set
 * returns the length of the route it found
 * -1 if it couldnt find a route
 */
int route(struct net *net, struct field* field);

#endif // LROUTER_ROUTE_H

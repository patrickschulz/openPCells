#ifndef LROUTER_ROUTE_H
#define LROUTER_ROUTE_H

#include "lrouter_net.h"
#include "lrouter_field.h"

#define STUCK 0
#define ROUTED 1

/* use lee algorithm for routing, returns 1 on possible routing, 0 on stuck */
int route(struct net *net, struct field* field, size_t wrong_dir_cost, size_t via_cost);

#endif

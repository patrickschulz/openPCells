#ifndef LROUTER_ROUTE_H
#define LROUTER_ROUTE_H

#include "lrouter_net.h"
#include "lrouter_field.h"

/* use lee algorithm for routing, returns 1 on possible routing, 0 on stuck */
void route(struct net *net, struct field* field, int step_cost, int wrong_dir_cost, int via_cost);

#endif // LROUTER_ROUTE_H

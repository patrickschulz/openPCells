#ifndef LROUTER_ROUTE_H
#define LROUTER_ROUTE_H

#include "lrouter_net.h"

#define STUCK 0
#define ROUTED 1

/* use lee algorithm for routing, returns 1 on possible routing, 0 on stuck */
int route(net_t net, int*** field, size_t fieldsize, size_t num_layers,
	  size_t wrong_dir_cost, size_t via_cost);

#endif

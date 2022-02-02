#ifndef LROUTER_ROUTE_H
#define LROUTER_ROUTE_H

#include "lrouter_net.h"

#define STUCK 0
#define ROUTED 1

/* use lee algorithm for routing, returns 1 on possible routing, 0 on stuck */
int route(net_t net, int*** field, const size_t fieldsize, const size_t num_layers,
	  const size_t wrong_dir_cost, const size_t via_cost);

#endif

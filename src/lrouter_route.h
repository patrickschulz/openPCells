#ifndef OPC_LROUTER_ROUTE_H
#define OPC_LROUTER_ROUTE_H

#include "lrouter_net.h"

/* use lee algorithm for routing */
void route(net_t net, int** field, size_t fieldsize);

#endif // OPC_LROUTER_ROUTE_H

#ifndef OPC_LUTIL_H
#define OPC_LUTIL_H

#include "lua/lua.h"

#include "polygon.h"

struct simple_polygon* lutil_create_simple_polygon(lua_State* L, int idx);

#endif /* OPC_LUTIL_H */

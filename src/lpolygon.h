#ifndef OPC_LPOLYGON_H
#define OPC_LPOLYGON_H

#include "lua/lua.h"

#include "polygon.h"

struct simple_polygon* lutil_create_simple_polygon(lua_State* L, int idx);
int open_lpolygon_lib(lua_State* L);

#endif /* OPC_LPOLYGON_H */

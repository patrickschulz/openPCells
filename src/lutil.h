#ifndef OPC_LUTIL_H
#define OPC_LUTIL_H

#include "lua/lua.h"

#include "polygon.h"
#include "vector.h"

size_t lutil_len(lua_State* L, int idx);
struct vector* lutil_get_string_table(lua_State* L, int idx);
struct simple_polygon* lutil_create_simple_polygon(lua_State* L, int idx);

#endif /* OPC_LUTIL_H */

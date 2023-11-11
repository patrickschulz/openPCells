#ifndef OPC_LPOINT_H
#define OPC_LPOINT_H

#include "lua/lua.h"

#include "point.h"

#define LPOINTMODULE "point"

struct lpoint;

struct lpoint* lpoint_create_internal(lua_State* L, coordinate_t x, coordinate_t y);
struct lpoint* lpoint_adapt_point(lua_State* L, point_t* pt);
struct lpoint* lpoint_takeover_point(lua_State* L, point_t* pt);
int lpoint_create(lua_State* L);
int lpoint_copy(lua_State* L);
const point_t* lpoint_get(const struct lpoint* pt);
coordinate_t lpoint_checkcoordinate(lua_State* L, int idx, const char* coordinate);
struct lpoint* lpoint_checkpoint(lua_State* L, int idx);
int lpoint_is_point(lua_State* L, int idx);

int open_lpoint_lib(lua_State* L);

#endif // OPC_LPOINT_H

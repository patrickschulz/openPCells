#ifndef OPC_LPOINT_H
#define OPC_LPOINT_H

#include "lua/lua.h"

#include "point.h"

#define LPOINTMETA "lpoint"
#define LPOINTMODULE "point"

typedef struct
{
    point_t* point;
    int destroy;
} lpoint_t;

lpoint_t* lpoint_create_internal(lua_State* L, coordinate_t x, coordinate_t y);
lpoint_t* lpoint_adapt_point(lua_State* L, point_t* pt);
lpoint_t* lpoint_takeover_point(lua_State* L, point_t* pt);
int lpoint_create(lua_State* L);
int lpoint_copy(lua_State* L);
lpoint_t* lpoint_checkpoint(lua_State* L, int idx);

int open_lpoint_lib(lua_State* L);

#endif // OPC_LPOINT_H

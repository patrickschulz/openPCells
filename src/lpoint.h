#ifndef LPOINT_H
#define LPOINT_H

#include "lua/lua.h"

#include "point.h"

#define LPOINTMETA "lpoint"
#define LPOINTMODULE "point"

typedef struct
{
    point_t* point;
} lpoint_t;


lpoint_t* lpoint_create_internal(lua_State* L, coordinate_t x, coordinate_t y);
int lpoint_create(lua_State* L);
int lpoint_copy(lua_State* L);
int open_lpoint_lib(lua_State* L);
int lpoint_register_cfunctions(lua_State* L);

#endif // LPOINT_H

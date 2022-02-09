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


int lpoint_create(lua_State* L);
int open_lpoint_lib(lua_State* L);
int lpoint_register_cfunctions(lua_State* L);

#endif // LPOINT_H

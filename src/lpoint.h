#ifndef LPOINT_H
#define LPOINT_H

#include <stdint.h>

#include "lua/lua.h"

#define LPOINTMETA "lpoint"
#define LPOINTMODULE "point"

typedef long long int lpoint_coordinate_t;

typedef struct
{
    lpoint_coordinate_t x;
    lpoint_coordinate_t y;
} lpoint_t;

int lpoint_create(lua_State* L);

int open_lpoint_lib(lua_State* L);
int lpoint_register_cfunctions(lua_State* L);

#endif // LPOINT_H

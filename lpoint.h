#ifndef LPOINT_H
#define LPOINT_H

//#define MAXDIGITS 80
#define LPOINTMETA "lpoint"
#define LPOINTMODULE "point"

//typedef uint64_t lpoint_coordinate_t;
//#define lpoint_check_coordinate luaL_checkinteger

typedef double lpoint_coordinate_t;
#define lpoint_check_coordinate luaL_checknumber

typedef struct _point
{
    lpoint_coordinate_t x;
    lpoint_coordinate_t y;
} lpoint_t;

int open_lpoint_lib(lua_State* L);

#endif // LPOINT_H

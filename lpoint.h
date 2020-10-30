#ifndef LPOINT_H
#define LPOINT_H

#include <stdint.h>

//#define MAXDIGITS 80
#define LPOINTMETA "lpoint"
#define LPOINTMODULE "point"

typedef int64_t lpoint_coordinate_t;

typedef struct _point
{
    lpoint_coordinate_t x;
    lpoint_coordinate_t y;
} lpoint_t;

int open_lpoint_lib(lua_State* L);

#endif // LPOINT_H

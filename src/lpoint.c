#include "lpoint.h"

#include <math.h>
#include <string.h>

#include "lua/lua.h"
#include "lua/lauxlib.h"

#include "point.h"

static coordinate_t checkcoordinate(lua_State* L, int idx)
{
    int isnum;
    lua_Integer d = lua_tointegerx(L, idx, &isnum);
    if(!isnum) 
    {
        lua_Number num = lua_tonumber(L, idx);
        lua_pushfstring(L, "non-integer number (%f) generated", num);
        lua_error(L);
    }
    return d;
}

lpoint_t* lpoint_create_internal(lua_State* L, coordinate_t x, coordinate_t y)
{
    lpoint_t* p = lua_newuserdata(L, sizeof(lpoint_t));
    luaL_setmetatable(L, LPOINTMETA);
    p->point = point_create(x, y);
    p->destroy = 1;
    return p;
}

lpoint_t* lpoint_adapt_point(lua_State* L, point_t* pt)
{
    lpoint_t* p = lua_newuserdata(L, sizeof(lpoint_t));
    luaL_setmetatable(L, LPOINTMETA);
    p->point = pt;
    p->destroy = 0;
    return p;
}

lpoint_t* lpoint_takeover_point(lua_State* L, point_t* pt)
{
    lpoint_t* p = lua_newuserdata(L, sizeof(lpoint_t));
    luaL_setmetatable(L, LPOINTMETA);
    p->point = pt;
    p->destroy = 1;
    return p;
}

int lpoint_create(lua_State* L)
{
    coordinate_t x = checkcoordinate(L, -2);
    coordinate_t y = checkcoordinate(L, -1);
    lua_pop(L, 2);
    lpoint_create_internal(L, x, y);
    return 1;
}

static int lpoint_destroy(lua_State* L)
{
    lpoint_t* p = luaL_checkudata(L, -1, LPOINTMETA);
    if(p->destroy)
    {
        point_destroy(p->point);
    }
    return 0;
}

int lpoint_copy(lua_State* L)
{
    lpoint_t* p = luaL_checkudata(L, -1, LPOINTMETA);
    lpoint_t* new = lua_newuserdata(L, sizeof(lpoint_t));
    luaL_setmetatable(L, LPOINTMETA);
    new->point = point_create(p->point->x, p->point->y);
    return 1;
}

static int lpoint_update(lua_State* L)
{
    lpoint_t* p = luaL_checkudata(L, -3, LPOINTMETA);
    coordinate_t x = checkcoordinate(L, -2);
    coordinate_t y = checkcoordinate(L, -1);
    p->point->x = x;
    p->point->y = y;
    return 0;
}

static int lpoint_unwrap(lua_State* L)
{
    lpoint_t* p = luaL_checkudata(L, -1, LPOINTMETA);
    lua_pushinteger(L, p->point->x);
    lua_pushinteger(L, p->point->y);
    return 2;
}

static int lpoint_getx(lua_State* L)
{
    lpoint_t* p = luaL_checkudata(L, -1, LPOINTMETA);
    lua_pushinteger(L, p->point->x);
    return 1;
}

static int lpoint_gety(lua_State* L)
{
    lpoint_t* p = luaL_checkudata(L, -1, LPOINTMETA);
    lua_pushinteger(L, p->point->y);
    return 1;
}

static int lpoint_translate(lua_State* L)
{
    lpoint_t* p = luaL_checkudata(L, -3, LPOINTMETA);
    coordinate_t x = checkcoordinate(L, -2);
    coordinate_t y = checkcoordinate(L, -1);
    p->point->x += x;
    p->point->y += y;
    lua_rotate(L, -3, 2);
    return 1;
}

static int lpoint_equal(lua_State* L)
{
    lpoint_t* lhs = luaL_checkudata(L, -2, LPOINTMETA);
    lpoint_t* rhs = luaL_checkudata(L, -1, LPOINTMETA);
    lua_pushboolean(L, lhs->point->x == rhs->point->x && lhs->point->y == rhs->point->y);
    return 1;
}

static int lpoint_getmetatable(lua_State* L)
{
    luaL_getmetatable(L, LPOINTMETA);
    return 1;
}

lpoint_t* lpoint_checkpoint(lua_State* L, int idx)
{
    return luaL_checkudata(L, idx, LPOINTMETA);
}

int open_lpoint_lib(lua_State* L)
{
    static const luaL_Reg metafuncs[] =
    {
        { "copy",      lpoint_copy      },
        { "unwrap",    lpoint_unwrap    },
        { "getx",      lpoint_getx      },
        { "gety",      lpoint_gety      },
        { "translate", lpoint_translate },
        { "__eq",      lpoint_equal     },
        { "__gc",      lpoint_destroy   },
        { NULL,     NULL          }
    };
    // create metatable for points
    luaL_newmetatable(L, LPOINTMETA);
    // add __index
    lua_pushstring(L, "__index");
    lua_pushvalue(L, -2); 
    lua_rawset(L, -3);

    // set meta functions
    luaL_setfuncs(L, metafuncs, 0);

    // remove metatable from stack
    lua_pop(L, 1);

    static const luaL_Reg modfuncs[] =
    {
        { "create",        lpoint_create       },
        { "_update",       lpoint_update       },
        { "_getmetatable", lpoint_getmetatable },
        { NULL,            NULL                }
    };
    lua_newtable(L);
    luaL_setfuncs(L, modfuncs, 0);
    lua_setglobal(L, LPOINTMODULE);
    return 0;
}


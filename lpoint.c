#include "lua/lua.h"
#include "lua/lauxlib.h"

#include <math.h>
#include <string.h>

#include "lpoint.h"

static lpoint_coordinate_t checkcoordinate(lua_State* L, int idx)
{
    int isnum;
    lua_Integer d = lua_tointegerx(L, idx, &isnum);
    if(!isnum) 
    {
        /*
        lua_Debug debug;
        int level = 1;
        while(1)
        {
            lua_getstack(L, level, &debug);
            lua_getinfo(L, "Snlt", &debug);
            if(strncmp("cell", debug.short_src, 4) == 0)
            {
                break;
            }
            ++level;
        }
        lua_pushfstring(L, "non-integer number (%f) generated in %s: line %d", num, debug.short_src, debug.currentline);
        */
        lua_Number num = lua_tonumber(L, idx);
        lua_pushfstring(L, "non-integer number (%f) generated", num);
        lua_error(L);
    }
    return d;
}

int lpoint_create(lua_State* L)
{
    lpoint_coordinate_t x = checkcoordinate(L, -2);
    lpoint_coordinate_t y = checkcoordinate(L, -1);
    lua_pop(L, 2);
    lpoint_t* p = lua_newuserdata(L, sizeof(lpoint_t));
    luaL_setmetatable(L, LPOINTMETA);
    p->x = x;
    p->y = y;
    return 1;
}

int lpoint_copy(lua_State* L)
{
    lpoint_t* p = luaL_checkudata(L, -1, LPOINTMETA);
    lpoint_t* new = lua_newuserdata(L, sizeof(lpoint_t));
    luaL_setmetatable(L, LPOINTMETA);
    new->x = p->x;
    new->y = p->y;
    return 1;
}

static int lpoint_update(lua_State* L)
{
    lpoint_t* p = luaL_checkudata(L, -3, LPOINTMETA);
    lpoint_coordinate_t x = checkcoordinate(L, -2);
    lpoint_coordinate_t y = checkcoordinate(L, -1);
    p->x = x;
    p->y = y;
    return 0;
}

static int lpoint_unwrap(lua_State* L)
{
    lpoint_t* p = luaL_checkudata(L, -1, LPOINTMETA);
    lua_pushinteger(L, p->x);
    lua_pushinteger(L, p->y);
    return 2;
}

static int lpoint_getx(lua_State* L)
{
    lpoint_t* p = luaL_checkudata(L, -1, LPOINTMETA);
    lua_pushinteger(L, p->x);
    return 1;
}

static int lpoint_gety(lua_State* L)
{
    lpoint_t* p = luaL_checkudata(L, -1, LPOINTMETA);
    lua_pushinteger(L, p->y);
    return 1;
}

static int lpoint_translate(lua_State* L)
{
    lpoint_t* p = luaL_checkudata(L, -3, LPOINTMETA);
    lpoint_coordinate_t x = checkcoordinate(L, -2);
    lpoint_coordinate_t y = checkcoordinate(L, -1);
    p->x = p->x + x;
    p->y = p->y + y;
    lua_rotate(L, -3, 2);
    return 1;
}

static int lpoint_equal(lua_State* L)
{
    lpoint_t* lhs = luaL_checkudata(L, -2, LPOINTMETA);
    lpoint_t* rhs = luaL_checkudata(L, -1, LPOINTMETA);
    lua_pushboolean(L, lhs->x == rhs->x && lhs->y == rhs->y);
    return 1;
}

static int lpoint_getmetatable(lua_State* L)
{
    luaL_getmetatable(L, LPOINTMETA);
    return 1;
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


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

static int lpoint_create(lua_State* L)
{
    lpoint_coordinate_t x = checkcoordinate(L, -2);
    lpoint_coordinate_t y = checkcoordinate(L, -1);
    lpoint_t* p = lua_newuserdata(L, sizeof(lpoint_t));
    luaL_setmetatable(L, LPOINTMETA);
    p->x = x;
    p->y = y;
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
    lpoint_coordinate_t mul = 1;
    unsigned int index = -1;
    if(lua_gettop(L) > 1)
    {
        mul = lua_tointeger(L, -1);
        index = -2;
    }
    lpoint_t* p = luaL_checkudata(L, index, LPOINTMETA);
    lua_pushinteger(L, p->x * mul);
    lua_pushinteger(L, p->y * mul);
    return 2;
}

static int lpoint_getmetatable(lua_State* L)
{
    luaL_getmetatable(L, LPOINTMETA);
    return 1;
}

int open_lpoint_lib(lua_State* L)
{
    // create metatable for points
    luaL_newmetatable(L, LPOINTMETA);
    // add __index
    lua_pushstring(L, "__index");
    lua_pushvalue(L, -2); 
    lua_rawset(L, -3);
    // remove metatable from stack
    lua_pop(L, 1);

    static const luaL_Reg modfuncs[] =
    {
        { "create",        lpoint_create       },
        { "_unwrap",       lpoint_unwrap       },
        { "_update",       lpoint_update       },
        { "_getmetatable", lpoint_getmetatable },
        { NULL,            NULL                }
    };
    lua_newtable(L);
    luaL_setfuncs(L, modfuncs, 0);
    lua_setglobal(L, LPOINTMODULE);
    return 0;
}


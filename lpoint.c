#include "lua/lua.h"
#include "lua/lauxlib.h"

#include <stdio.h>
#include <stdint.h>
#include <math.h>
#include <string.h>

#include "lpoint.h"

static lpoint_coordinate_t checkcoordinate(lua_State* L, int idx)
{
    return lpoint_check_coordinate(L, idx);
}

/*
static int lpoint_tostring(lua_State* L)
{
    lpoint_t* data = lua_touserdata(L, -1);
    char buf[MAXDIGITS + 1];
    snprintf(buf, MAXDIGITS + 1, "(%ld, %ld)", data->x, data->y);
    lua_pushstring(L, buf);
    return 1;
}
*/

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

static int lpoint_copy(lua_State* L)
{
    lpoint_t* p = lua_touserdata(L, -1);
    lpoint_t* new = lua_newuserdata(L, sizeof(lpoint_t));
    luaL_setmetatable(L, LPOINTMETA);
    new->x = p->x;
    new->y = p->y;
    return 1;
}

static int lpoint_translate(lua_State* L)
{
    lpoint_t* p = lua_touserdata(L, -3);
    lpoint_coordinate_t dx = checkcoordinate(L, -2);
    lpoint_coordinate_t dy = checkcoordinate(L, -1);
    p->x += dx;
    p->y += dy;
    return 1;
}

static int lpoint_scale(lua_State* L)
{
    lpoint_t* p = lua_touserdata(L, -2);
    lpoint_coordinate_t factor = checkcoordinate(L, -1);
    p->x *= factor;
    p->y *= factor;
    return 1;
}

static int lpoint_rotate(lua_State* L)
{
    lpoint_t* p = lua_touserdata(L, -2);
    lpoint_coordinate_t angle = checkcoordinate(L, -1);
    lpoint_coordinate_t x = p->x;
    lpoint_coordinate_t y = p->y;
    p->x = x * cos(angle) - y * sin(angle);
    p->y = x * sin(angle) + y * cos(angle);
    return 1;
}

static int lpoint_unwrap(lua_State* L)
{
    lpoint_coordinate_t mul = 1;
    unsigned int index = -1;
    if(lua_gettop(L) > 1)
    {
        mul = lua_tonumber(L, -1);
        index = -2;
    }
    lpoint_t* p = lua_touserdata(L, index);
    lua_pushnumber(L, p->x * mul);
    lua_pushnumber(L, p->y * mul);
    return 2;
}

static int lpoint_getx(lua_State* L)
{
    lpoint_t* p = lua_touserdata(L, -1);
    lua_pushnumber(L, p->x);
    return 1;
}

static int lpoint_gety(lua_State* L)
{
    lpoint_t* p = lua_touserdata(L, -1);
    lua_pushnumber(L, p->y);
    return 1;
}

static int lpoint_fix(lua_State* L)
{
    lpoint_t* pt = lua_touserdata(L, -2);
    lpoint_coordinate_t grid = checkcoordinate(L, -1);
    pt->x = grid * round(pt->x / grid);
    pt->y = grid * round(pt->y / grid);
    return 0;
}

static uint32_t intlog10(uint32_t num)
{
    if (num == 0) return UINT_MAX;
    if (num == 1) return 0;
    uint32_t ret = 0;
    while (num > 1) 
    {
        num /= 10;
        ret++;
    }
    return ret;
}

static void _format_number(lpoint_coordinate_t num, uint32_t baseunit, luaL_Buffer* buf)
{
    char fmt[LUAL_BUFFERSIZE];
    if(baseunit == 1)
    {
        strncpy(fmt, "%d", LUAL_BUFFERSIZE);
    }
    else
    {
        snprintf(fmt, LUAL_BUFFERSIZE, "%%s%%u.%%0%uu", intlog10(baseunit));
    }
    const char* sign = "";
    if(num < 0)
    {
        sign = "-";
        num = -num;
    }
    uint32_t ipart = num / baseunit;
    uint32_t fpart = num - baseunit * ipart;
    char* ptr = luaL_prepbuffer(buf);
    int size = snprintf(ptr, LUAL_BUFFERSIZE, fmt, sign, ipart, fpart);
    luaL_addsize(buf, size);
}

static int lpoint_format(lua_State* L)
{
    lpoint_t* pt = luaL_checkudata(L, -3, LPOINTMETA);
    uint32_t baseunit = luaL_checkinteger(L, -2);
    const char* sep = luaL_checkstring(L, -1);
    luaL_Buffer buf;
    luaL_buffinit(L, &buf);
    _format_number(pt->x, baseunit, &buf);
    luaL_addstring(&buf, sep);
    _format_number(pt->y, baseunit, &buf);
    luaL_pushresult(&buf);
    return 1;
}

int open_lpoint_lib(lua_State* L)
{
    static const luaL_Reg metafuncs[] =
    {
        //{ "__tostring",     lpoint_tostring   },
        { "getx",           lpoint_getx       },
        { "gety",           lpoint_gety       },
        { "copy",           lpoint_copy       },
        { "translate",      lpoint_translate  },
        { "rotate",         lpoint_rotate     },
        { "scale",          lpoint_scale      },
        { "unwrap",         lpoint_unwrap     },
        { "fix",            lpoint_fix        },
        { "format",         lpoint_format     },
        { NULL,             NULL             }
    };
    luaL_newmetatable(L, LPOINTMETA);
    luaL_setfuncs(L, metafuncs, 0);
    // add __index
    lua_pushstring(L, "__index");
    lua_pushvalue(L, -2); 
    lua_rawset(L, -3);
    // remove metatable from stack
    lua_pop(L, 1);

    static const luaL_Reg modfuncs[] =
    {
        { "create",         lpoint_create   },
        { NULL,             NULL            }
    };
    lua_newtable(L);
    luaL_setfuncs(L, modfuncs, 0);
    lua_setglobal(L, LPOINTMODULE);
    return 0;
}


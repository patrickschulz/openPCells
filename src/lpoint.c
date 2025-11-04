#include "lpoint.h"

#include <string.h>

#include "lua/lua.h"
#include "lua/lauxlib.h"

#include "math.h"
#include "point.h"

#define LPOINTMETA "lpoint"

struct lpoint {
    struct point* point;
    int destroy;
};

#define _x(pt) point_getx(lpoint_get(pt))
#define _y(pt) point_gety(lpoint_get(pt))

coordinate_t lpoint_checkcoordinate(lua_State* L, int idx, const char* coordinate)
{
    if(idx < 0)
    {
        if(lua_gettop(L) < -idx)
        {
            lua_pushfstring(L, "point module: no argument received for %s", coordinate);
            lua_error(L);
        }
    }
    else
    {
        if(lua_gettop(L) < idx)
        {
            lua_pushfstring(L, "point module: no argument received for %s", coordinate);
            lua_error(L);
        }
    }
    if(lua_isnil(L, idx))
    {
        lua_pushfstring(L, "point module: nil number received for %s", coordinate);
        lua_error(L);
    }
    if(lua_type(L, idx) != LUA_TNUMBER)
    {
        lua_pushfstring(L, "point module: non-number parameter (%s) received for %s", lua_typename(L, lua_type(L, idx)), coordinate);
        lua_error(L);
    }
    int isnum;
    lua_Integer d = lua_tointegerx(L, idx, &isnum);
    if(!isnum) 
    {
        lua_Number num = lua_tonumber(L, idx);
        lua_pushfstring(L, "point module: non-integer number (%f) received for %s", num, coordinate);
        lua_error(L);
    }
    return d;
}

struct lpoint* lpoint_create_internal_xy(lua_State* L, coordinate_t x, coordinate_t y)
{
    struct lpoint* p = lua_newuserdata(L, sizeof(*p));
    luaL_setmetatable(L, LPOINTMETA);
    p->point = point_create(x, y);
    p->destroy = 1;
    return p;
}

struct lpoint* lpoint_create_internal_pt(lua_State* L, const struct point* pt)
{
    struct lpoint* p = lua_newuserdata(L, sizeof(*p));
    luaL_setmetatable(L, LPOINTMETA);
    p->point = point_copy(pt);
    p->destroy = 1;
    return p;
}

struct lpoint* lpoint_adapt_point(lua_State* L, struct point* pt)
{
    struct lpoint* p = lua_newuserdata(L, sizeof(*p));
    luaL_setmetatable(L, LPOINTMETA);
    p->point = pt;
    p->destroy = 0;
    return p;
}

struct lpoint* lpoint_takeover_point(lua_State* L, struct point* pt)
{
    struct lpoint* p = lua_newuserdata(L, sizeof(*p));
    luaL_setmetatable(L, LPOINTMETA);
    p->point = pt;
    p->destroy = 1;
    return p;
}

int lpoint_create(lua_State* L)
{
    if(lua_gettop(L) < 2)
    {
        lua_pushfstring(L, "point.create(): expected two arguments (x and y), got %d", lua_gettop(L));
        lua_error(L);
    }
    coordinate_t x = lpoint_checkcoordinate(L, -2, "x");
    coordinate_t y = lpoint_checkcoordinate(L, -1, "y");
    lua_pop(L, 2);
    lpoint_create_internal_xy(L, x, y);
    return 1;
}

static int lpoint_destroy(lua_State* L)
{
    struct lpoint* p = lpoint_checkpoint(L, -1);
    if(p->destroy)
    {
        point_destroy(p->point);
    }
    return 0;
}

int lpoint_copy(lua_State* L)
{
    struct lpoint* p = lpoint_checkpoint(L, -1);
    struct lpoint* new = lua_newuserdata(L, sizeof(*new));
    luaL_setmetatable(L, LPOINTMETA);
    new->point = point_create(p->point->x, p->point->y);
    new->destroy = 1;
    return 1;
}

const struct point* lpoint_get(const struct lpoint* pt)
{
    return pt->point;
}

static int lpoint_unwrap(lua_State* L)
{
    struct lpoint* p = lpoint_checkpoint(L, -1);
    lua_pushinteger(L, p->point->x);
    lua_pushinteger(L, p->point->y);
    return 2;
}

static int lpoint_getx(lua_State* L)
{
    struct lpoint* p = lpoint_checkpoint(L, -1);
    lua_pushinteger(L, p->point->x);
    return 1;
}

static int lpoint_gety(lua_State* L)
{
    struct lpoint* p = lpoint_checkpoint(L, -1);
    lua_pushinteger(L, p->point->y);
    return 1;
}

static int lpoint_translate(lua_State* L)
{
    struct lpoint* p = lpoint_checkpoint(L, 1);
    coordinate_t x = lpoint_checkcoordinate(L, 2, "x");
    coordinate_t y = lpoint_checkcoordinate(L, 3, "y");
    p->point->x += x;
    p->point->y += y;
    lua_rotate(L, -3, 2);
    return 1;
}

static int lpoint_translate_x(lua_State* L)
{
    struct lpoint* p = lpoint_checkpoint(L, 1);
    coordinate_t x = lpoint_checkcoordinate(L, 2, "x");
    p->point->x += x;
    lua_rotate(L, 1, 1);
    return 1;
}

static int lpoint_translate_y(lua_State* L)
{
    struct lpoint* p = lpoint_checkpoint(L, 1);
    coordinate_t y = lpoint_checkcoordinate(L, 2, "y");
    p->point->y += y;
    lua_rotate(L, 1, 1);
    return 1;
}

static int lpoint_fix(lua_State* L)
{
    struct lpoint* self = lpoint_checkpoint(L, 1);
    int grid = luaL_checkinteger(L, 2);
    struct point* pt = self->point;
    pt->x = grid * (pt->x / grid);
    pt->y = grid * (pt->y / grid);
    return 0;
}

static int lpoint_combine_12(lua_State* L)
{
    struct lpoint* lhs = lpoint_checkpoint(L, 1);
    struct lpoint* rhs = lpoint_checkpoint(L, 2);
    lpoint_create_internal_xy(L,
        _x(lhs),
        _y(rhs)
    );
    return 1;
}

static int lpoint_combine_21(lua_State* L)
{
    struct lpoint* lhs = lpoint_checkpoint(L, 1);
    struct lpoint* rhs = lpoint_checkpoint(L, 2);
    lpoint_create_internal_xy(L,
        _x(rhs),
        _y(lhs)
    );
    return 1;
}

static int lpoint_combine(lua_State* L)
{
    struct lpoint* lhs = lpoint_checkpoint(L, 1);
    struct lpoint* rhs = lpoint_checkpoint(L, 2);
    lpoint_create_internal_xy(L,
        (_x(lhs) + _x(rhs)) / 2,
        (_y(lhs) + _y(rhs)) / 2
    );
    return 1;
}

static int lpoint_xaverage(lua_State* L)
{
    struct lpoint* lhs = lpoint_checkpoint(L, 1);
    struct lpoint* rhs = lpoint_checkpoint(L, 2);
    lua_pushinteger(L, (_x(lhs) + _x(rhs)) / 2);
    return 1;
}

static int lpoint_yaverage(lua_State* L)
{
    struct lpoint* lhs = lpoint_checkpoint(L, 1);
    struct lpoint* rhs = lpoint_checkpoint(L, 2);
    lua_pushinteger(L, (_y(lhs) + _y(rhs)) / 2);
    return 1;
}

static int lpoint_xdistance(lua_State* L)
{
    struct lpoint* lhs = lpoint_checkpoint(L, 1);
    struct lpoint* rhs = lpoint_checkpoint(L, 2);
    lua_pushinteger(L, (_x(lhs) - _x(rhs)));
    return 1;
}

static int lpoint_ydistance(lua_State* L)
{
    struct lpoint* lhs = lpoint_checkpoint(L, 1);
    struct lpoint* rhs = lpoint_checkpoint(L, 2);
    lua_pushinteger(L, (_y(lhs) - _y(rhs)));
    return 1;
}

static int lpoint_xdistance_abs(lua_State* L)
{
    struct lpoint* lhs = lpoint_checkpoint(L, 1);
    struct lpoint* rhs = lpoint_checkpoint(L, 2);
    if(_x(lhs) < _x(rhs))
    {
        lua_pushinteger(L, (_x(rhs) - _x(lhs)));
    }
    else
    {
        lua_pushinteger(L, (_x(lhs) - _x(rhs)));
    }
    return 1;
}

static int lpoint_ydistance_abs(lua_State* L)
{
    struct lpoint* lhs = lpoint_checkpoint(L, 1);
    struct lpoint* rhs = lpoint_checkpoint(L, 2);
    if(_y(lhs) < _y(rhs))
    {
        lua_pushinteger(L, (_y(rhs) - _y(lhs)));
    }
    else
    {
        lua_pushinteger(L, (_y(lhs) - _y(rhs)));
    }
    return 1;
}


static int lpoint_equal(lua_State* L)
{
    struct lpoint* lhs = lpoint_checkpoint(L, -2);
    struct lpoint* rhs = lpoint_checkpoint(L, -1);
    lua_pushboolean(L, lhs->point->x == rhs->point->x && lhs->point->y == rhs->point->y);
    return 1;
}

static int lpoint_sub(lua_State* L)
{
    struct lpoint* lhs = lpoint_checkpoint(L, 1);
    struct lpoint* rhs = lpoint_checkpoint(L, 2);
    lpoint_create_internal_xy(L,
        point_getx(lpoint_get(lhs)) - point_getx(lpoint_get(rhs)),
        point_gety(lpoint_get(lhs)) - point_gety(lpoint_get(rhs))
    );
    return 1;
}

static int lpoint_unary_minus(lua_State* L)
{
    struct lpoint* self = lpoint_checkpoint(L, 1);
    lpoint_create_internal_xy(L,
        -point_getx(lpoint_get(self)),
        -point_gety(lpoint_get(self))
    );
    return 1;
}

static int lpoint_concat(lua_State* L)
{
    struct lpoint* lhs = lpoint_checkpoint(L, 1);
    struct lpoint* rhs = lpoint_checkpoint(L, 2);
    lpoint_create_internal_xy(L,
        point_getx(lpoint_get(lhs)),
        point_gety(lpoint_get(rhs))
    );
    return 1;
}

struct lpoint* lpoint_checkpoint(lua_State* L, int idx)
{
    return luaL_checkudata(L, idx, LPOINTMETA);
}

static int lpoint_tostring(lua_State* L)
{
    struct lpoint* self = lpoint_checkpoint(L, 1);
    const struct point* pt = lpoint_get(self);
    char buf[256];
    //char* buf = malloc(len + 1);
    sprintf(buf, "point: (%lld, %lld)", point_getx(pt), point_gety(pt));
    lua_pushstring(L, buf);
    //free(buf);
    return 1;
}

int lpoint_is_point(lua_State* L, int idx)
{
    if(lua_type(L, idx) != LUA_TUSERDATA)
    {
        return 0;
    }
    lua_getmetatable(L, idx);
    if(lua_isnil(L, -1))
    {
        lua_pop(L, 1);
        return 0;
    }
    luaL_getmetatable(L, LPOINTMETA);
    int equal = lua_compare(L, -1, -2, LUA_OPEQ);
    lua_pop(L, 2);
    if(equal)
    {
        return 1;
    }
    return 0;
}

static int lpoint_is_point_lua(lua_State* L)
{
    if(lua_gettop(L) != 1)
    {
        lua_pushstring(L, "point.is_point expects expects one argument");
        lua_error(L);
    }
    int islpoint = lpoint_is_point(L, 1);
    lua_pushboolean(L, islpoint);
    return 1;
}

int lpoint_xmirror(lua_State* L)
{
    struct lpoint* pt = lpoint_checkpoint(L, 1);
    pt->point->x = -pt->point->x;
    return 1;
}

int lpoint_ymirror(lua_State* L)
{
    struct lpoint* pt = lpoint_checkpoint(L, 1);
    pt->point->y = -pt->point->y;
    return 1;
}

int open_lpoint_lib(lua_State* L)
{
    static const luaL_Reg metafuncs[] =
    {
        { "copy",        lpoint_copy        },
        { "unwrap",      lpoint_unwrap      },
        { "getx",        lpoint_getx        },
        { "gety",        lpoint_gety        },
        { "translate",   lpoint_translate   },
        { "translate_x", lpoint_translate_x },
        { "translate_y", lpoint_translate_y },
        { "fix",         lpoint_fix         },
        { "xmirror",     lpoint_xmirror     },
        { "ymirror",     lpoint_ymirror     },
        { "__eq",        lpoint_equal       },
        { "__gc",        lpoint_destroy     },
        { "__tostring",  lpoint_tostring    },
        { "__sub",       lpoint_sub         },
        { "__unm",       lpoint_unary_minus },
        { "__concat",    lpoint_concat      },
        { NULL,          NULL               }
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
        { "create",         lpoint_create           },
        { "is_point",       lpoint_is_point_lua     },
        { "combine_12",     lpoint_combine_12       },
        { "combine_21",     lpoint_combine_21       },
        { "combine",        lpoint_combine          },
        { "xaverage",       lpoint_xaverage         },
        { "yaverage",       lpoint_yaverage         },
        { "xdistance",      lpoint_xdistance        },
        { "ydistance",      lpoint_ydistance        },
        { "xdistance_abs",  lpoint_xdistance_abs    },
        { "ydistance_abs",  lpoint_ydistance_abs    },
        { NULL,             NULL                    }
    };
    lua_newtable(L);
    luaL_setfuncs(L, modfuncs, 0);
    lua_setglobal(L, LPOINTMODULE);
    return 0;
}


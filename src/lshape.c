#include "lshape.h"

#include <string.h>

#include "lua/lauxlib.h"

#include "shape.h"
#include "lpoint.h"

typedef struct
{
    shape_t* shape;
} lshape_t;

static void _set_lpp(lua_State* L)
{
    // set lpp
    lua_pushstring(L, "lpp");
    lua_pushvalue(L, 1); 
    lua_rawset(L, -3);
}

static void _set_type(lua_State* L, const char* type)
{
    // set type
    lua_pushstring(L, "typ");
    lua_pushstring(L, type); 
    lua_rawset(L, -3);
}

static int lshape_create_rectangle_bltr(lua_State* L)
{
    lua_newtable(L);

    _set_lpp(L);
    _set_type(L, "rectangle");

    // set points
    lua_pushstring(L, "points");
    lua_newtable(L);
    // bl
    lua_pushstring(L, "bl");
    lua_pushvalue(L, 2);
    lua_rawset(L, -3);
    // tr
    lua_pushstring(L, "tr");
    lua_pushvalue(L, 3);
    lua_rawset(L, -3);
    // store
    lua_rawset(L, -3);

    // setmetatable
    luaL_setmetatable(L, LSHAPEMODULE);

    return 1;
}

static int lshape_create_polygon(lua_State* L)
{
    if(lua_gettop(L) < 2)
    {
        lua_newtable(L);
    }
    lua_newtable(L);

    _set_lpp(L);
    _set_type(L, "polygon"); 

    // set points
    lua_pushstring(L, "points");
    lua_pushvalue(L, 2);
    lua_rawset(L, -3);
    // setmetatable
    luaL_setmetatable(L, LSHAPEMODULE);
    return 1;
}

static int lshape_create_path(lua_State* L)
{
    lua_newtable(L);

    _set_lpp(L);
    _set_type(L, "path"); 

    // set points
    lua_pushstring(L, "points");
    lua_pushvalue(L, 2);
    lua_rawset(L, -3);
    // set width
    lua_pushstring(L, "width");
    lua_pushvalue(L, 3);
    lua_rawset(L, -3);
    // set ending
    if(lua_gettop(L) > (3 + 1)) // ending type is present (table was pushed on the stack, therefor + 1)
    {
        /*
        if(lua_type(L, 4) == LUA_TSTRING)
        {
        }
        else // LUA_TTABLE, variable start and end extensions
        {
        }
        */
        lua_pushstring(L, "extension");
        lua_pushvalue(L, 4);
        lua_rawset(L, -3);
    }
    // setmetatable
    luaL_setmetatable(L, LSHAPEMODULE);
    return 1;
}

static int apply_transformation(lua_State* L)
{
    lua_pushstring(L, "typ");
    lua_rawget(L, 1);
    const char* type = lua_tostring(L, -1);
    if(strcmp(type, "polygon") == 0 ||
       strcmp(type, "path") == 0)
    {
        lua_pushstring(L, "points");
        lua_rawget(L, 1);
        lua_len(L, -1);
        unsigned int size = lua_tointeger(L, -1);
        lua_pop(L, 1); /* pop length */
        for(unsigned int i = 0; i < size; ++i)
        {
            lua_pushvalue(L, 3);
            lua_pushvalue(L, 2);
            lua_rawgeti(L, -3, i + 1);
            lua_call(L, 2, 0);
        }
        lua_pop(L, 1); /* pop points */
    }
    else /* rectangle */
    {
        lua_pushstring(L, "points");
        lua_rawget(L, 1);

        lua_pushvalue(L, 3);
        lua_pushvalue(L, 2);
        lua_pushstring(L, "bl");
        lua_rawget(L, 1);
        lua_call(L, 2, 0);

        lua_pushvalue(L, 3);
        lua_pushvalue(L, 2);
        lua_pushstring(L, "tr");
        lua_rawget(L, 1);
        lua_call(L, 2, 0);

        lua_pushstring(L, "bl");
        lua_rawget(L, 1);
        lpoint_t* bl = lua_touserdata(L, -1);
        lua_pushstring(L, "tr");
        lua_rawget(L, 1);
        lpoint_t* tr = lua_touserdata(L, -1);
        if(bl->point->x > tr->point->x)
        {
            coordinate_t tmp = bl->point->x;
            bl->point->x = tr->point->x;
            tr->point->x = tmp;
        }
        if(bl->point->y > tr->point->y)
        {
            coordinate_t tmp = bl->point->y;
            bl->point->y = tr->point->y;
            tr->point->y = tmp;
        }
        lua_pop(L, 1); /* pop points */
    }
    lua_pop(L, 1); /* pop type */
    lua_pop(L, 2);
    return 1;
}

int open_lshape_lib(lua_State* L)
{
    // create metatable for shapes
    luaL_newmetatable(L, LSHAPEMODULE);

    // set methods
    static const luaL_Reg metafuncs[] =
    {
        { "apply_transformation", apply_transformation },
        { NULL,                   NULL                 }
    };
    luaL_setfuncs(L, metafuncs, 0);

    // add __index
    lua_pushstring(L, "__index");
    lua_pushvalue(L, -2); 
    lua_rawset(L, -3);

    static const luaL_Reg modfuncs[] =
    {
        { "create_rectangle_bltr", lshape_create_rectangle_bltr },
        { "create_polygon",        lshape_create_polygon        },
        { "create_path",           lshape_create_path           },
        { NULL,                    NULL                         }
    };
    luaL_setfuncs(L, modfuncs, 0);

    lua_setglobal(L, LSHAPEMODULE);

    return 0;
}

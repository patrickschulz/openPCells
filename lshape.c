#include "lshape.h"

#include "lua/lauxlib.h"

#define LSHAPEMODULE "shape"

int lshape_create_rectangle(lua_State* L)
{
    lua_newtable(L);
    // set lpp
    lua_pushstring(L, "lpp");
    lua_pushvalue(L, 1); 
    lua_rawset(L, -3);
    // set type
    lua_pushstring(L, "typ");
    lua_pushstring(L, "rectangle"); 
    lua_rawset(L, -3);

    // set points
    lua_pushstring(L, "points");
    lua_newtable(L);
    lua_Number width = lua_tointeger(L, 2);
    lua_Number height = lua_tointeger(L, 3);
    // bl
    lua_pushstring(L, "bl");
    lua_pushnumber(L, -width / 2);
    lua_pushnumber(L, -height / 2);
    lpoint_create(L);
    lua_rawset(L, -3);
    // tr
    lua_pushstring(L, "tr");
    lua_pushnumber(L, width / 2);
    lua_pushnumber(L, height / 2);
    lpoint_create(L);
    lua_rawset(L, -3);
    // store
    lua_rawset(L, -3);

    // setmetatable
    luaL_setmetatable(L, LSHAPEMODULE);

    return 1;
}

int lshape_create_rectangle_bltr(lua_State* L)
{
    lua_newtable(L);
    // set lpp
    lua_pushstring(L, "lpp");
    lua_pushvalue(L, 1); 
    lua_rawset(L, -3);
    // set type
    lua_pushstring(L, "typ");
    lua_pushstring(L, "rectangle"); 
    lua_rawset(L, -3);

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

int lshape_create_polygon(lua_State* L)
{
    if(lua_gettop(L) < 2)
    {
        lua_newtable(L);
    }
    lua_newtable(L);
    // set lpp
    lua_pushstring(L, "lpp");
    lua_pushvalue(L, 1); 
    lua_rawset(L, -3);
    // set type
    lua_pushstring(L, "typ");
    lua_pushstring(L, "polygon"); 
    lua_rawset(L, -3);
    // set points
    lua_pushstring(L, "points");
    lua_pushvalue(L, 2);
    lua_rawset(L, -3);
    // setmetatable
    luaL_setmetatable(L, LSHAPEMODULE);
    return 1;
}

int open_lshape_lib(lua_State* L)
{
    // create metatable for shapes
    luaL_newmetatable(L, LSHAPEMODULE);
    // add __index
    lua_pushstring(L, "__index");
    lua_pushvalue(L, -2); 
    lua_rawset(L, -3);

    static const luaL_Reg modfuncs[] =
    {
        { "create_rectangle",      lshape_create_rectangle      },
        { "create_rectangle_bltr", lshape_create_rectangle_bltr },
        { "create_polygon",        lshape_create_polygon        },
        { NULL,                    NULL                         }
    };
    luaL_setfuncs(L, modfuncs, 0);

    lua_setglobal(L, LSHAPEMODULE);

    return 0;
}

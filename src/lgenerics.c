#include "lgenerics.h"

#include "lua/lauxlib.h"

static lgenerics_t* _create(lua_State* L)
{
    lgenerics_t* layer = lua_newuserdata(L, sizeof(*layer));
    luaL_setmetatable(L, LGENERICSMODULE);
    return layer;
}

static int lgenerics_create_metal(lua_State* L)
{
    int num = luaL_checkinteger(L, 1);
    lgenerics_t* layer = _create(L);
    layer->layer = generics_create_metal(num);
    return 1;
}

static int lgenerics_copy(lua_State* L)
{
    lgenerics_t* old = lua_touserdata(L, 1);
    lgenerics_t* new = _create(L);
    new->layer = generics_copy(old->layer);
    return 1;
}

static int lgenerics_tostring(lua_State* L)
{
    lgenerics_t* layer = lua_touserdata(L, 1);
    if(layer->layer->type == METAL)
    {
        lua_pushfstring(L, "layer: metal (%d)", ((struct generic_metal_t*)layer->layer->layer)->metal);
    }
    else
    {
        lua_pushstring(L, "layer");
    }
    return 1;
}

static int lgenerics_destroy(lua_State* L)
{
    lgenerics_t* layer = lua_touserdata(L, 1);
    generics_destroy(layer->layer);
    return 0;
}

int open_lgenerics_lib(lua_State* L)
{
    // create metatable for generics
    luaL_newmetatable(L, LGENERICSMODULE);

    // set methods
    static const luaL_Reg metafuncs[] =
    {
        { "copy",       lgenerics_copy     },
        { "__tostring", lgenerics_tostring },
        { "__gc",       lgenerics_destroy  },
        { NULL,         NULL               }
    };
    luaL_setfuncs(L, metafuncs, 0);

    static const luaL_Reg modfuncs[] =
    {
        { "metal", lgenerics_create_metal },
        { NULL,    NULL                   }
    };
    luaL_setfuncs(L, modfuncs, 0);
    lua_setglobal(L, LGENERICSMODULE);

    return 0;
}

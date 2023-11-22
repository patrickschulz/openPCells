#include "lpostprocess.h"

#include "lua/lauxlib.h"

#include "postprocess.h"
#include "lobject.h"

int lpostprocess_remove_layer_shapes_flat(lua_State* L)
{
    struct lobject* cell = lobject_check(L, 1);
    const struct generics* layer = lua_touserdata(L, 2);
    postprocess_remove_layer_shapes_flat(lobject_get(L, cell), layer);
    return 0;
}

int lpostprocess_remove_layer_shapes(lua_State* L)
{
    struct lobject* cell = lobject_check(L, 1);
    const struct generics* layer = lua_touserdata(L, 2);
    postprocess_remove_layer_shapes(lobject_get(L, cell), layer);
    return 0;
}

int open_lpostprocess(lua_State* L)
{
    lua_newtable(L);
    static const luaL_Reg modfuncs[] =
    {
        { "remove_layer_shapes_flat", lpostprocess_remove_layer_shapes_flat },
        { "remove_layer_shapes",      lpostprocess_remove_layer_shapes      },
        { NULL,                       NULL                                  }
    };
    luaL_setfuncs(L, modfuncs, 0);
    lua_setglobal(L, "postprocess");
    return 0;
}

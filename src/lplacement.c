#include "lplacement.h"

#include "lua/lauxlib.h"

#include "ldebug.h"
#include "lobject.h"
#include "lpoint.h"

#include "placement.h"

int lplacement_place_within_boundary_merge(lua_State* L)
{
    struct lobject* toplevel = lobject_check(L, 1);
    struct lobject* cell = lobject_check(L, 2);
    lua_len(L, 3);
    size_t len = lua_tointeger(L, -1);
    lua_pop(L, 1);
    struct vector* targetarea = vector_create(32, point_destroy);
    for(size_t i = 1; i <= len; ++i)
    {
        lua_rawgeti(L, 3, i);
        struct lpoint* pt = lpoint_checkpoint(L, -1);
        vector_append(targetarea, point_copy(lpoint_get(pt)));
        lua_pop(L, 1);
    }

    struct vector* excludes = NULL;
    if(lua_gettop(L) > 3)
    {
        lua_len(L, 4);
        size_t excludes_len = lua_tointeger(L, -1);
        lua_pop(L, 1);
        excludes = vector_create(32, vector_destroy);
        for(size_t i = 1; i <= excludes_len; ++i)
        {
            lua_rawgeti(L, 4, i);
            lua_len(L, -1);
            size_t exclude_len = lua_tointeger(L, -1);
            lua_pop(L, 1);
            struct vector* exclude = vector_create(32, point_destroy);
            for(size_t j = 1; j <= exclude_len; ++j)
            {
                lua_rawgeti(L, -1, j);
                struct lpoint* pt = lpoint_checkpoint(L, -1);
                vector_append(exclude, point_copy(lpoint_get(pt)));
                lua_pop(L, 1);
            }
            vector_append(excludes, exclude);
            lua_pop(L, 1);
        }
    }
    placement_place_within_boundary_merge(lobject_get(toplevel), lobject_get(cell), targetarea, excludes);
    return 0;
}

int open_lplacement_lib(lua_State* L)
{
    // create metatable for placement module
    luaL_newmetatable(L, LPLACEMENTMODULE);

    // set methods
    static const luaL_Reg metafuncs[] =
    {
        { "place_within_boundary_merge",    lplacement_place_within_boundary_merge },
        { NULL,                             NULL                                   }
    };
    luaL_setfuncs(L, metafuncs, 0);

    lua_setglobal(L, LPLACEMENTMODULE);

    return 0;
}

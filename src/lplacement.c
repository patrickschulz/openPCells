#include "lplacement.h"

#include "lua/lauxlib.h"

#include "lcheck.h"
#include "lobject.h"
#include "lpoint.h"
#include "lutil.h"

#include "placement.h"

void lplacement_create_target_exclude_vectors(lua_State* L, struct simple_polygon** targetarea, struct polygon** excludes, int idx)
{
    *targetarea = lutil_create_simple_polygon(L, idx);
    *excludes = NULL;
    if(lua_istable(L, idx + 1))
    {
        lua_len(L, idx + 1);
        size_t excludes_len = lua_tointeger(L, -1);
        lua_pop(L, 1);
        *excludes = polygon_create();
        for(size_t i = 1; i <= excludes_len; ++i)
        {
            lua_rawgeti(L, idx + 1, i);
            struct simple_polygon* exclude = lutil_create_simple_polygon(L, -1);
            polygon_add(*excludes, exclude);
            lua_pop(L, 1);
        }
    }
}

static void _cleanup_target_exclude_vector(struct simple_polygon* targetarea, struct polygon* excludes)
{
    simple_polygon_destroy(targetarea);
    if(excludes)
    {
        polygon_destroy(excludes);
    }
}

int lplacement_place_within_boundary(lua_State* L)
{
    lcheck_check_numargs_set(L, 4, 5, "placement.place_within_boundary");
    struct lobject* toplevel = lobject_check(L, 1);
    struct lobject* cell = lobject_check(L, 2);
    const char* basename = luaL_checkstring(L, 3);

    struct simple_polygon* targetarea;
    struct polygon* excludes;
    lplacement_create_target_exclude_vectors(L, &targetarea, &excludes, 4);

    struct vector* children = placement_place_within_boundary(lobject_get(toplevel), lobject_get(cell), basename, targetarea, excludes);
    _cleanup_target_exclude_vector(targetarea, excludes);
    lobject_disown(cell); // memory is now handled by cell
    lua_newtable(L);
    for(size_t i = 0; i < vector_size(children); ++i)
    {
        struct object* child = vector_get(children, i);
        lobject_adapt_non_owning(L, child);
        lua_rawseti(L, -2, i + 1);
    }
    vector_destroy(children);
    return 1;
}

int lplacement_place_within_boundary_merge(lua_State* L)
{
    lcheck_check_numargs_set(L, 3, 4, "placement.place_within_boundary_merge");
    struct lobject* toplevel = lobject_check(L, 1);
    struct lobject* cell = lobject_check(L, 2);

    struct simple_polygon* targetarea;
    struct polygon* excludes;
    lplacement_create_target_exclude_vectors(L, &targetarea, &excludes, 3);

    placement_place_within_boundary_merge(lobject_get(toplevel), lobject_get(cell), targetarea, excludes);
    _cleanup_target_exclude_vector(targetarea, excludes);
    return 0;
}

int lplacement_place_within_rectangular_boundary(lua_State* L)
{
    lcheck_check_numargs(L, 5, "placement.place_within_rectangular_boundary");
    struct lobject* toplevel = lobject_check(L, 1);
    struct lobject* cell = lobject_check(L, 2);
    const char* basename = luaL_checkstring(L, 3);
    struct lpoint* bl = lpoint_checkpoint(L, 4);
    struct lpoint* tr = lpoint_checkpoint(L, 5);

    struct object* children = placement_place_within_rectangular_boundary(
        lobject_get(toplevel),
        lobject_get(cell),
        basename,
        lpoint_get(bl), lpoint_get(tr)
    );
    lobject_disown(cell); // memory is now handled by cell
    lobject_adapt_non_owning(L, children);
    return 1;
}

int open_lplacement_lib(lua_State* L)
{
    // create metatable for placement module
    luaL_newmetatable(L, LPLACEMENTMODULE);

    // set methods
    static const luaL_Reg metafuncs[] =
    {
        { "place_within_boundary",                  lplacement_place_within_boundary             },
        { "place_within_boundary_merge",            lplacement_place_within_boundary_merge       },
        { "place_within_rectangular_boundary",      lplacement_place_within_rectangular_boundary },
        { NULL,                                     NULL                                         }
    };
    luaL_setfuncs(L, metafuncs, 0);

    lua_setglobal(L, LPLACEMENTMODULE);

    return 0;
}


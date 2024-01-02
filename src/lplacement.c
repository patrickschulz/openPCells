#include "lplacement.h"

#include "lua/lauxlib.h"

#include <stdlib.h>

#include "lcheck.h"
#include "lobject.h"
#include "lpoint.h"
#include "lutil.h"

#include "placement.h"

static void _destroy_placement_celllookup(void* v)
{
    struct placement_layerexclude* celllookup = v;
    const_vector_destroy(celllookup->layers);
    free(celllookup);
}

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

int lplacement_place_on_grid(lua_State* L)
{
    lcheck_check_numargs1(L, 7, "placement.place_on_grid");
    struct lobject* toplevel = lobject_check(L, 1);
    struct lobject* cell = lobject_check(L, 2);
    const char* basename = luaL_checkstring(L, 3);
    struct lpoint* basept = lpoint_checkpoint(L, 4);
    coordinate_t xpitch = luaL_checkinteger(L, 5);
    coordinate_t ypitch = luaL_checkinteger(L, 6);
    lua_len(L, 7);
    size_t len = lua_tointeger(L, -1);
    lua_pop(L, 1);
    struct vector* grid = vector_create(32, vector_destroy);
    for(size_t i = len; i >= 1; --i)
    {
        lua_rawgeti(L, 7, i);
        lua_len(L, -1);
        size_t xlen = lua_tointeger(L, -1);
        lua_pop(L, 1);
        struct vector* xvec = vector_create(32, free);
        for(size_t j = 1; j <= xlen; ++j)
        {
            lua_rawgeti(L, -1, j);
            int* toinsert = malloc(sizeof(*toinsert));
            *toinsert = luaL_checkinteger(L, -1);
            vector_append(xvec, toinsert);
            lua_pop(L, 1);
        }
        vector_append(grid, xvec);
        lua_pop(L, 1);
    }

    struct vector* children = placement_place_on_grid(lobject_get(L, toplevel), lobject_get_unchecked(cell), basename, lpoint_get(basept), xpitch, ypitch, grid);
    vector_destroy(grid);
    lobject_disown(cell); // memory is now handled by cell
    lobject_mark_as_unusable(cell);
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

int lplacement_place_at_origins(lua_State* L)
{
    lcheck_check_numargs1(L, 4, "placement.place_at_origins");
    struct lobject* toplevel = lobject_check(L, 1);
    struct lobject* cell = lobject_check(L, 2);
    const char* basename = luaL_checkstring(L, 3);
    lua_len(L, 4);
    size_t len = lua_tointeger(L, -1);
    lua_pop(L, 1);
    struct vector* origins = vector_create(32, NULL);
    for(size_t i = 1; i <= len; ++i)
    {
        lua_rawgeti(L, 4, i);
        struct lpoint* pt = lpoint_checkpoint(L, -1);
        vector_append(origins, (void*)lpoint_get(pt)); // vector is non-const, but points are not mutated
        lua_pop(L, 1);
    }

    struct vector* children = vector_create(1, NULL);
    placement_place_at_origins(lobject_get(L, toplevel), lobject_get_unchecked(cell), origins, basename, children);
    lobject_disown(cell); // memory is now handled by cell
    lobject_mark_as_unusable(cell);
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

int lplacement_place_within_boundary(lua_State* L)
{
    lcheck_check_numargs2(L, 4, 5, "placement.place_within_boundary");
    struct lobject* toplevel = lobject_check(L, 1);
    struct lobject* cell = lobject_check(L, 2);
    const char* basename = luaL_checkstring(L, 3);

    struct simple_polygon* targetarea;
    struct polygon* excludes;
    lplacement_create_target_exclude_vectors(L, &targetarea, &excludes, 4);

    struct vector* children = placement_place_within_boundary(lobject_get(L, toplevel), lobject_get_unchecked(cell), basename, targetarea, excludes);
    _cleanup_target_exclude_vector(targetarea, excludes);
    lobject_disown(cell); // memory is now handled by cell
    lobject_mark_as_unusable(cell);
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
    lcheck_check_numargs2(L, 3, 4, "placement.place_within_boundary_merge");
    struct lobject* toplevel = lobject_check(L, 1);
    struct lobject* cell = lobject_check(L, 2);
    if(lua_type(L, 3) != LUA_TTABLE)
    {
        lua_pushstring(L, "placement.place_within_boundary_merge: expected a table (a polygon) as third argument");
        lua_error(L);
    }
    if(lua_gettop(L) > 3 && lua_type(L, 3) != LUA_TTABLE)
    {
        lua_pushstring(L, "placement.place_within_boundary_merge: expected a table (a polygon) as fourth argument");
        lua_error(L);
    }
    struct simple_polygon* targetarea;
    struct polygon* excludes;
    lplacement_create_target_exclude_vectors(L, &targetarea, &excludes, 3);

    placement_place_within_boundary_merge(lobject_get(L, toplevel), lobject_get_unchecked(cell), targetarea, excludes);
    _cleanup_target_exclude_vector(targetarea, excludes);
    return 0;
}

int lplacement_place_within_rectangular_boundary(lua_State* L)
{
    lcheck_check_numargs1(L, 5, "placement.place_within_rectangular_boundary");
    struct lobject* toplevel = lobject_check(L, 1);
    struct lobject* cell = lobject_check(L, 2);
    const char* basename = luaL_checkstring(L, 3);
    struct lpoint* bl = lpoint_checkpoint(L, 4);
    struct lpoint* tr = lpoint_checkpoint(L, 5);

    struct object* children = placement_place_within_rectangular_boundary(
        lobject_get(L, toplevel),
        lobject_get_unchecked(cell),
        basename,
        lpoint_get(bl), lpoint_get(tr)
    );
    lobject_disown(cell); // memory is now handled by cell
    lobject_mark_as_unusable(cell);
    lobject_adapt_non_owning(L, children);
    return 1;
}

int lplacement_place_within_layer_boundaries(lua_State* L)
{
    lcheck_check_numargs1(L, 5, "placement.place_within_layer_boundaries");
    struct lobject* toplevel = lobject_check(L, 1);

    // get cell look-up
    lua_len(L, 2);
    size_t num_cells = lua_tointeger(L, -1);
    lua_pop(L, 1);
    struct vector* celllut = vector_create(num_cells, _destroy_placement_celllookup);
    for(size_t i = 0; i < num_cells; ++i)
    {
        struct placement_celllookup* lookup = malloc(sizeof(*lookup));
        lua_rawgeti(L, 2, i + 1); // get entry table

        // get cell
        lua_pushstring(L, "cell");
        int celltype = lua_rawget(L, -2);
        if(celltype != LUA_TUSERDATA)
        {
            lua_pushstring(L, "placement.placement_place_within_layer_boundaries: every entry cell look-up table must contain an object as 'cell' entry");
            lua_error(L);
        }
        lookup->cell = lobject_get(L, lobject_check(L, -1));
        lua_pop(L, 1); // pop object

        // get layer table
        lua_pushstring(L, "layers");
        int layertype = lua_rawget(L, -2);
        lookup->layers = NULL;
        if(layertype != LUA_TNIL)
        {
            lua_len(L, -1);
            size_t num_layers = lua_tointeger(L, -1);
            lua_pop(L, 1);
            lookup->layers = const_vector_create(num_layers);
            for(size_t i = 0; i < num_layers; ++i)
            {
                lua_rawgeti(L, -1, i + 1);
                const_vector_append(lookup->layers, lua_touserdata(L, -1));
                lua_pop(L, 1);
            }
        }
        lua_pop(L, 1); // pop layers table

        lua_pop(L, 1); // pop entry table

        vector_append(celllut, lookup);
    }

    const char* basename = luaL_checkstring(L, 3);

    // get target area and layer excludes
    struct simple_polygon* targetarea = lutil_create_simple_polygon(L, 4);

    // get layer excludes
    lua_len(L, 5);
    size_t num_excludes = lua_tointeger(L, -1);
    lua_pop(L, 1);
    struct vector* layerexcludes = vector_create(num_excludes, destroy_placement_layerexclude);
    for(size_t i = 0; i < num_excludes; ++i)
    {
        struct placement_layerexclude* layerexclude = malloc(sizeof(*layerexclude));
        lua_rawgeti(L, 5, i + 1); // get entry table

        // get polygon
        lua_pushstring(L, "excludes");
        lua_rawget(L, -2);
        layerexclude->excludes = NULL;
        if(lua_istable(L, -1))
        {
            lua_len(L, -1);
            size_t excludes_len = lua_tointeger(L, -1);
            lua_pop(L, 1);
            layerexclude->excludes = polygon_create();
            for(size_t i = 1; i <= excludes_len; ++i)
            {
                lua_rawgeti(L, -1, i);
                struct simple_polygon* exclude = lutil_create_simple_polygon(L, -1);
                polygon_add(layerexclude->excludes, exclude);
                lua_pop(L, 1);
            }
        }
        lua_pop(L, 1); // pop polygon table

        // get layer table
        lua_pushstring(L, "layers");
        int layertype = lua_rawget(L, -2);
        layerexclude->layers = NULL;
        if(layertype != LUA_TNIL)
        {
            lua_len(L, -1);
            size_t num_layers = lua_tointeger(L, -1);
            lua_pop(L, 1);
            layerexclude->layers = const_vector_create(num_layers);
            for(size_t i = 0; i < num_layers; ++i)
            {
                lua_rawgeti(L, -1, i + 1);
                const_vector_append(layerexclude->layers, lua_touserdata(L, -1));
                lua_pop(L, 1);
            }
        }
        lua_pop(L, 1); // pop layers table

        lua_pop(L, 1); // pop entry table

        vector_append(layerexcludes, layerexclude);
    }

    struct vector* children = placement_place_within_layer_boundaries(lobject_get(L, toplevel), celllut, basename, targetarea, layerexcludes);
    simple_polygon_destroy(targetarea);
    vector_destroy(celllut);
    vector_destroy(layerexcludes);

    // disown objects
    for(size_t i = 0; i < num_cells; ++i)
    {
        lua_rawgeti(L, 2, i + 1); // get entry table

        lua_pushstring(L, "cell");
        lua_rawget(L, -2);
        struct lobject* cell = lobject_check(L, -1);
        lobject_disown(cell); // memory is now handled by cell
        //lobject_mark_as_unusable(cell);
        lua_pop(L, 1); // pop object

        lua_pop(L, 1); // pop entry table
    }

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

int open_lplacement_lib(lua_State* L)
{
    // create metatable for placement module
    luaL_newmetatable(L, LPLACEMENTMODULE);

    // set methods
    static const luaL_Reg metafuncs[] =
    {
        { "place_at_origins",                       lplacement_place_at_origins                  },
        { "place_on_grid",                          lplacement_place_on_grid                     },
        { "place_within_boundary",                  lplacement_place_within_boundary             },
        { "place_within_boundary_merge",            lplacement_place_within_boundary_merge       },
        { "place_within_rectangular_boundary",      lplacement_place_within_rectangular_boundary },
        { "place_within_layer_boundaries",          lplacement_place_within_layer_boundaries     },
        { NULL,                                     NULL                                         }
    };
    luaL_setfuncs(L, metafuncs, 0);

    lua_setglobal(L, LPLACEMENTMODULE);

    return 0;
}


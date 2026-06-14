#include "lplacement.h"

#include "lua/lauxlib.h"

#include <stdlib.h>

#include "lcheck.h"
#include "lgenerics.h"
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

void lplacement_create_exclude_vectors(lua_State* L, struct polygon_container** excludes, int idx)
{
    *excludes = NULL;
    if(lua_istable(L, idx))
    {
        lua_len(L, idx);
        size_t excludes_len = lua_tointeger(L, -1);
        lua_pop(L, 1);
        *excludes = polygon_container_create();
        for(size_t i = 1; i <= excludes_len; ++i)
        {
            lua_rawgeti(L, idx, i);
            struct simple_polygon* exclude = lutil_create_simple_polygon(L, -1);
            polygon_container_add(*excludes, exclude);
            lua_pop(L, 1);
        }
    }
}

static void _cleanup_target_exclude_vector(struct simple_polygon* targetarea, struct polygon_container* excludes)
{
    simple_polygon_destroy(targetarea);
    if(excludes)
    {
        polygon_container_destroy(excludes);
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

    struct vector* children = placement_place_on_grid(lobject_get_full(L, toplevel), lobject_get_unchecked(cell), basename, lpoint_get(basept), xpitch, ypitch, grid);
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

int lplacement_calculate_grid(lua_State* L)
{
    lcheck_check_numargs2(L, 4, 5, "placement.calculate_grid");
    struct lpoint* bl = lpoint_checkpoint(L, 1);
    struct lpoint* tr = lpoint_checkpoint(L, 2);
    coordinate_t xpitch = luaL_checkinteger(L, 3);
    coordinate_t ypitch = luaL_checkinteger(L, 4);
    struct polygon_container* excludes;
    lplacement_create_exclude_vectors(L, &excludes, 5);
    struct vector* grid = placement_calculate_grid(lpoint_get(bl), lpoint_get(tr), xpitch, ypitch, excludes);
    if(excludes)
    {
        polygon_container_destroy(excludes);
    }
    lua_newtable(L);
    for(size_t i = 0; i < vector_size(grid); ++i)
    {
        struct vector* row = vector_get(grid, i);
        lua_newtable(L);
        for(size_t j = 0; j < vector_size(row); ++j)
        {
            int* value = vector_get(row, j);
            lua_pushinteger(L, *value);
            lua_rawseti(L, -2, j + 1);
        }
        lua_rawseti(L, -2, i + 1);
    }
    vector_destroy(grid);
    return 1;
}

int lplacement_place_boundary_grid(lua_State* L)
{
    lcheck_check_numargs1(L, 7, "placement.place_boundary_grid");
    struct lobject* toplevel = lobject_check(L, 1);
    struct lpoint* basept = lpoint_checkpoint(L, 3);
    coordinate_t xpitch = luaL_checkinteger(L, 5);
    coordinate_t ypitch = luaL_checkinteger(L, 6);
    const char* basename = luaL_checkstring(L, 7);

    // read boundary cell table
    struct boundary_celltable* boundarycells = malloc(sizeof(*boundarycells));
    // center
    lua_getfield(L, 2, "center");
    if(lua_isnil(L, -1))
    {
        boundarycells->center = NULL;
    }
    else
    {
        struct lobject* center = lobject_check(L, -1);
        boundarycells->center = lobject_get_unchecked(center);
    }
    lua_pop(L, 1);
    // top
    lua_getfield(L, 2, "top");
    if(lua_isnil(L, -1))
    {
        boundarycells->top = NULL;
    }
    else
    {
        struct lobject* top = lobject_check(L, -1);
        boundarycells->top = lobject_get_unchecked(top);
    }
    lua_pop(L, 1);
    // bottom
    lua_getfield(L, 2, "bottom");
    if(lua_isnil(L, -1))
    {
        boundarycells->bottom = NULL;
    }
    else
    {
        struct lobject* bottom = lobject_check(L, -1);
        boundarycells->bottom = lobject_get_unchecked(bottom);
    }
    lua_pop(L, 1);
    // left
    lua_getfield(L, 2, "left");
    if(lua_isnil(L, -1))
    {
        boundarycells->left = NULL;
    }
    else
    {
        struct lobject* left = lobject_check(L, -1);
        boundarycells->left = lobject_get_unchecked(left);
    }
    lua_pop(L, 1);
    // right
    lua_getfield(L, 2, "right");
    if(lua_isnil(L, -1))
    {
        boundarycells->right = NULL;
    }
    else
    {
        struct lobject* right = lobject_check(L, -1);
        boundarycells->right = lobject_get_unchecked(right);
    }
    lua_pop(L, 1);
    // topleft
    lua_getfield(L, 2, "topleft");
    if(lua_isnil(L, -1))
    {
        boundarycells->topleft = NULL;
    }
    else
    {
        struct lobject* topleft = lobject_check(L, -1);
        boundarycells->topleft = lobject_get_unchecked(topleft);
    }
    lua_pop(L, 1);
    // topright
    lua_getfield(L, 2, "topright");
    if(lua_isnil(L, -1))
    {
        boundarycells->topright = NULL;
    }
    else
    {
        struct lobject* topright = lobject_check(L, -1);
        boundarycells->topright = lobject_get_unchecked(topright);
    }
    lua_pop(L, 1);
    // topbottom
    lua_getfield(L, 2, "topbottom");
    if(lua_isnil(L, -1))
    {
        boundarycells->topbottom = NULL;
    }
    else
    {
        struct lobject* topbottom = lobject_check(L, -1);
        boundarycells->topbottom = lobject_get_unchecked(topbottom);
    }
    lua_pop(L, 1);
    // bottomleft
    lua_getfield(L, 2, "bottomleft");
    if(lua_isnil(L, -1))
    {
        boundarycells->bottomleft = NULL;
    }
    else
    {
        struct lobject* bottomleft = lobject_check(L, -1);
        boundarycells->bottomleft = lobject_get_unchecked(bottomleft);
    }
    lua_pop(L, 1);
    // bottomright
    lua_getfield(L, 2, "bottomright");
    if(lua_isnil(L, -1))
    {
        boundarycells->bottomright = NULL;
    }
    else
    {
        struct lobject* bottomright = lobject_check(L, -1);
        boundarycells->bottomright = lobject_get_unchecked(bottomright);
    }
    lua_pop(L, 1);
    // leftright
    lua_getfield(L, 2, "leftright");
    if(lua_isnil(L, -1))
    {
        boundarycells->leftright = NULL;
    }
    else
    {
        struct lobject* leftright = lobject_check(L, -1);
        boundarycells->leftright = lobject_get_unchecked(leftright);
    }
    lua_pop(L, 1);
    // topleftright
    lua_getfield(L, 2, "topleftright");
    if(lua_isnil(L, -1))
    {
        boundarycells->topleftright = NULL;
    }
    else
    {
        struct lobject* topleftright = lobject_check(L, -1);
        boundarycells->topleftright = lobject_get_unchecked(topleftright);
    }
    lua_pop(L, 1);
    // topbottomleft
    lua_getfield(L, 2, "topbottomleft");
    if(lua_isnil(L, -1))
    {
        boundarycells->topbottomleft = NULL;
    }
    else
    {
        struct lobject* topbottomleft = lobject_check(L, -1);
        boundarycells->topbottomleft = lobject_get_unchecked(topbottomleft);
    }
    lua_pop(L, 1);
    // topbottomright
    lua_getfield(L, 2, "topbottomright");
    if(lua_isnil(L, -1))
    {
        boundarycells->topbottomright = NULL;
    }
    else
    {
        struct lobject* topbottomright = lobject_check(L, -1);
        boundarycells->topbottomright = lobject_get_unchecked(topbottomright);
    }
    lua_pop(L, 1);
    // bottomleftright
    lua_getfield(L, 2, "bottomleftright");
    if(lua_isnil(L, -1))
    {
        boundarycells->bottomleftright = NULL;
    }
    else
    {
        struct lobject* bottomleftright = lobject_check(L, -1);
        boundarycells->bottomleftright = lobject_get_unchecked(bottomleftright);
    }
    lua_pop(L, 1);
    // topbottomleftright
    lua_getfield(L, 2, "topbottomleftright");
    if(lua_isnil(L, -1))
    {
        boundarycells->topbottomleftright = NULL;
    }
    else
    {
        struct lobject* topbottomleftright = lobject_check(L, -1);
        boundarycells->topbottomleftright = lobject_get_unchecked(topbottomleftright);
    }
    lua_pop(L, 1);

    // read grid
    lua_len(L, 4);
    size_t gridlen = lua_tointeger(L, -1);
    lua_pop(L, 1);
    struct vector* grid = vector_create(32, vector_destroy);
    for(size_t i = 1; i <= gridlen; ++i)
    {
        lua_rawgeti(L, 4, i);
        lua_len(L, -1);
        size_t rowlen = lua_tointeger(L, -1);
        lua_pop(L, 1);
        struct vector* row = vector_create(rowlen, free);
        for(size_t j = 1; j <= rowlen; ++j)
        {
            lua_rawgeti(L, -1, j);
            int* value = malloc(sizeof(*value));
            *value = luaL_checkinteger(L, -1);
            lua_pop(L, 1);
            vector_append(row, value);
        }
        lua_pop(L, 1);
        vector_append(grid, row);
    }

    struct vector* children = placement_place_boundary_grid(
        lobject_get_full(L, toplevel),
        boundarycells,
        lpoint_get(basept),
        grid,
        xpitch, ypitch,
        basename
    );
    free(boundarycells);
    vector_destroy(grid);
    if(!children)
    {
        lua_pushstring(L, "placement.place_boundary_grid: missing boundary cell (unfortunately the detection logic is very simple, so is no information on which cell is missing)");
        lua_error(L);
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
    placement_place_at_origins(lobject_get_full(L, toplevel), lobject_get_unchecked(cell), origins, basename, children);
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
    if(!object_has_alignmentbox(lobject_get_const(cell)))
    {
        lua_pushstring(L, "placement.place_within_boundary: to-be-placed object has no alignment box");
        lua_error(L);
    }
    const char* basename = luaL_checkstring(L, 3);

    struct simple_polygon* targetarea;
    struct polygon_container* excludes;
    targetarea = lutil_create_simple_polygon(L, 4);
    lplacement_create_exclude_vectors(L, &excludes, 5);

    struct vector* children = placement_place_within_boundary(lobject_get_full(L, toplevel), lobject_get_unchecked(cell), basename, targetarea, excludes);
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
    struct polygon_container* excludes;
    targetarea = lutil_create_simple_polygon(L, 3);
    lplacement_create_exclude_vectors(L, &excludes, 4);

    placement_place_within_boundary_merge(lobject_get_full(L, toplevel), lobject_get_unchecked(cell), targetarea, excludes);
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
        lobject_get_full(L, toplevel),
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
    lcheck_check_numargs2(L, 7, 8, "placement.place_within_layer_boundaries");
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
        lookup->cell = lobject_get_unchecked(lobject_check(L, -1));
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
            for(size_t j = 0; j < num_layers; ++j)
            {
                lua_rawgeti(L, -1, j + 1);
                const_vector_append(lookup->layers, lua_touserdata(L, -1));
                lua_pop(L, 1);
            }
        }
        lua_pop(L, 1); // pop layers table

        lua_pop(L, 1); // pop entry table

        vector_append(celllut, lookup);
    }

    // basename
    const char* basename = luaL_checkstring(L, 3);

    // get target area and layer excludes
    struct simple_polygon* targetarea = lutil_create_simple_polygon(L, 4);

    // xpitch and ypitch
    coordinate_t xpitch = luaL_checkinteger(L, 5);
    coordinate_t ypitch = luaL_checkinteger(L, 6);

    // get layer excludes
    lua_len(L, 7);
    size_t num_excludes = lua_tointeger(L, -1);
    lua_pop(L, 1);
    struct vector* layerexcludes = vector_create(num_excludes, destroy_placement_layerexclude);
    for(size_t i = 0; i < num_excludes; ++i)
    {
        struct placement_layerexclude* layerexclude = malloc(sizeof(*layerexclude));
        lua_rawgeti(L, 7, i + 1); // get entry table

        // get polygon
        lua_pushstring(L, "excludes");
        lua_rawget(L, -2);
        layerexclude->excludes = NULL;
        if(lua_istable(L, -1))
        {
            lua_len(L, -1);
            size_t excludes_len = lua_tointeger(L, -1);
            lua_pop(L, 1);
            layerexclude->excludes = polygon_container_create();
            for(size_t j = 1; j <= excludes_len; ++j)
            {
                lua_rawgeti(L, -1, j);
                struct simple_polygon* exclude = lutil_create_simple_polygon(L, -1);
                polygon_container_add(layerexclude->excludes, exclude);
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
            for(size_t j = 0; j < num_layers; ++j)
            {
                lua_rawgeti(L, -1, j + 1);
                const_vector_append(layerexclude->layers, lua_touserdata(L, -1));
                lua_pop(L, 1);
            }
        }
        lua_pop(L, 1); // pop layers table

        lua_pop(L, 1); // pop entry table

        vector_append(layerexcludes, layerexclude);
    }

    // get ignore layer
    const struct generics* ignorelayer = NULL;
    if(lua_gettop(L) > 7)
    {
        ignorelayer = generics_check_generics(L, 8);
    }

    // perform placement
    struct vector* children = placement_place_within_layer_boundaries(
        lobject_get_full(L, toplevel),
        celllut,
        basename,
        targetarea,
        xpitch, ypitch,
        layerexcludes,
        ignorelayer
    );
    simple_polygon_destroy(targetarea);
    vector_destroy(celllut);
    vector_destroy(layerexcludes);
    if(!children)
    {
        lua_pushstring(L, "placement.placement_place_within_layer_boundaries: the input arguments contain an error (see previous messages)");
        lua_error(L);
    }

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

int lplacement_place_gridlines(lua_State* L)
{
    lcheck_check_numargs1(L, 7, "placement.place_gridlines");
    struct lobject* toplevel = lobject_check(L, 1);
    const struct generics* layer = generics_check_generics(L, 2);
    coordinate_t size = luaL_checkinteger(L, 3);
    coordinate_t space = luaL_checkinteger(L, 4);

    struct polygon_container* excludes;
    struct lpoint* targetbl = lpoint_checkpoint(L, 5);
    struct lpoint* targettr = lpoint_checkpoint(L, 6);
    lplacement_create_exclude_vectors(L, &excludes, 7);

    placement_place_gridlines(lobject_get_full(L, toplevel), layer, size, space, lpoint_get(targetbl), lpoint_get(targettr), excludes);

    //struct vector* children = placement_place_within_boundary(lobject_get_full(L, toplevel), lobject_get_unchecked(cell), basename, targetarea, excludes);
    //_cleanup_target_exclude_vector(targetarea, excludes);
    //lobject_disown(cell); // memory is now handled by cell
    //lobject_mark_as_unusable(cell);
    //lua_newtable(L);
    //for(size_t i = 0; i < vector_size(children); ++i)
    //{
    //    struct object* child = vector_get(children, i);
    //    lobject_adapt_non_owning(L, child);
    //    lua_rawseti(L, -2, i + 1);
    //}
    //vector_destroy(children);
    return 0;
}

int open_lplacement_lib(lua_State* L)
{
    // create metatable for placement module
    luaL_newmetatable(L, LPLACEMENTMODULE);

    // set methods
    static const luaL_Reg metafuncs[] =
    {
        { "calculate_grid",                         lplacement_calculate_grid                    },
        { "place_boundary_grid",                    lplacement_place_boundary_grid               },
        { "place_at_origins",                       lplacement_place_at_origins                  },
        { "place_on_grid",                          lplacement_place_on_grid                     },
        { "place_within_boundary",                  lplacement_place_within_boundary             },
        { "place_within_boundary_merge",            lplacement_place_within_boundary_merge       },
        { "place_within_rectangular_boundary",      lplacement_place_within_rectangular_boundary },
        { "place_within_layer_boundaries",          lplacement_place_within_layer_boundaries     },
        { "place_gridlines",                        lplacement_place_gridlines                   },
        { NULL,                                     NULL                                         }
    };
    luaL_setfuncs(L, metafuncs, 0);

    lua_setglobal(L, LPLACEMENTMODULE);

    return 0;
}


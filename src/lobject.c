#include "lobject.h"

#include "lua/lauxlib.h"

#include "lpoint.h"

static lobject_t* _create(lua_State* L)
{
    lobject_t* cell = lua_newuserdata(L, sizeof(*cell));
    luaL_setmetatable(L, LOBJECTMODULE);
    cell->destroy = 0;
    return cell;
}

int lobject_create(lua_State* L)
{
    lobject_t* cell = _create(L);
    cell->object = object_create();
    cell->destroy = 1;
    return 1;
}

lobject_t* lobject_check(lua_State* L, int idx)
{
    return luaL_checkudata(L, idx, LOBJECTMODULE);
}

lobject_t* lobject_check_soft(lua_State* L, int idx)
{
  return luaL_testudata(L, idx, LOBJECTMODULE);
}

lobject_t* lobject_adapt(lua_State* L, struct object* object)
{
    lobject_t* cell = _create(L);
    cell->object = object;
    return cell;
}

void lobject_disown(lobject_t* lobject)
{
    lobject->destroy = 0;
}

static int lobject_copy(lua_State* L)
{
    lobject_t* cell = lobject_check(L, 1);
    lobject_t* new = _create(L);
    new->object = object_copy(cell->object);
    new->destroy = 1;
    return 1;
}

static int lobject_exchange(lua_State* L)
{
    lobject_t* cell = lobject_check(L, 1);
    lobject_t* other = lobject_check(L, 2);
    struct object* old = cell->object;
    cell->object = other->object;
    other->destroy = 0;
    object_destroy(old);
    return 1;
}

static int lobject_destroy(lua_State* L)
{
    lobject_t* cell = lobject_check(L, 1);
    if(cell->destroy)
    {
        object_destroy(cell->object);
    }
    return 0;
}

static int lobject_move_to(lua_State* L)
{
    lobject_t* cell = lobject_check(L, 1);
    coordinate_t x = lua_tointeger(L, 2);
    coordinate_t y = lua_tointeger(L, 3);
    object_move_to(cell->object, x, y);
    return 1;
}

static int lobject_translate(lua_State* L)
{
    lobject_t* cell = lobject_check(L, 1);
    coordinate_t x = lua_tointeger(L, 2);
    coordinate_t y = lua_tointeger(L, 3);
    object_translate(cell->object, x, y);
    lua_rotate(L, 1, 2);
    return 1;
}

int lobject_mirror_at_xaxis(lua_State* L)
{
    lobject_t* cell = lobject_check(L, 1);
    object_mirror_at_xaxis(cell->object);
    return 1;
}

int lobject_mirror_at_yaxis(lua_State* L)
{
    lobject_t* cell = lobject_check(L, 1);
    object_mirror_at_yaxis(cell->object);
    return 1;
}

int lobject_mirror_at_origin(lua_State* L)
{
    lobject_t* cell = lobject_check(L, 1);
    object_mirror_at_origin(cell->object);
    return 1;
}

int lobject_rotate_90_left(lua_State* L)
{
    lobject_t* cell = lobject_check(L, 1);
    object_rotate_90_left(cell->object);
    return 1;
}

int lobject_rotate_90_right(lua_State* L)
{
    lobject_t* cell = lobject_check(L, 1);
    object_rotate_90_right(cell->object);
    return 1;
}

int lobject_flipx(lua_State* L)
{
    lobject_t* cell = lobject_check(L, 1);
    object_flipx(cell->object);
    return 1;
}

int lobject_flipy(lua_State* L)
{
    lobject_t* cell = lobject_check(L, 1);
    object_flipy(cell->object);
    return 1;
}

int lobject_move_anchor(lua_State* L)
{
    int numstack = lua_gettop(L);
    lobject_t* cell = lobject_check(L, 1);
    const char* name = lua_tostring(L, 2);
    coordinate_t x = 0;
    coordinate_t y = 0;
    if(lua_gettop(L) > 2 && !lua_isnil(L, 3))
    {
        lpoint_t* lpoint = lpoint_checkpoint(L, 3);
        x = lpoint->point->x;
        y = lpoint->point->y;
    }
    object_move_anchor(cell->object, name, x, y);
    lua_rotate(L, 1, numstack - 1);
    return 1;
}

int lobject_move_anchor_x(lua_State* L)
{
    int numstack = lua_gettop(L);
    lobject_t* cell = lobject_check(L, 1);
    const char* name = lua_tostring(L, 2);
    coordinate_t x = 0;
    if(lua_gettop(L) > 2 && !lua_isnil(L, 3))
    {
        lpoint_t* lpoint = lpoint_checkpoint(L, 3);
        x = lpoint->point->x;
    }
    object_move_anchor_x(cell->object, name, x);
    lua_rotate(L, 1, numstack - 1);
    return 1;
}

int lobject_move_anchor_y(lua_State* L)
{
    int numstack = lua_gettop(L);
    lobject_t* cell = lobject_check(L, 1);
    const char* name = lua_tostring(L, 2);
    coordinate_t y = 0;
    if(lua_gettop(L) > 2 && !lua_isnil(L, 3))
    {
        lpoint_t* lpoint = lpoint_checkpoint(L, 3);
        y = lpoint->point->y;
    }
    object_move_anchor_y(cell->object, name, y);
    lua_rotate(L, 1, numstack - 1);
    return 1;
}

int lobject_apply_transformation(lua_State* L)
{
    lobject_t* cell = lobject_check(L, 1);
    object_apply_transformation(cell->object);
    return 0;
}

int lobject_add_child(lua_State* L)
{
    lobject_t* cell = lobject_check(L, 1);
    const char* identifier = lua_tostring(L, 2);
    const char* name = lua_tostring(L, 3);
    lua_getfield(L, LUA_REGISTRYINDEX, "pcellstate");
    struct pcell_state* pcell_state = lua_touserdata(L, -1);
    lua_pop(L, 1); // pop pcell state
    struct object* child = object_add_child(cell->object, pcell_state, identifier, name);
    lobject_adapt(L, child);
    return 1;
}

int lobject_add_child_array(lua_State* L)
{
    lobject_t* cell = lobject_check(L, 1);
    const char* identifier = lua_tostring(L, 2);
    unsigned int xrep = lua_tointeger(L, 3);
    unsigned int yrep = lua_tointeger(L, 4);
    unsigned int xpitch = lua_tointeger(L, 5);
    unsigned int ypitch = lua_tointeger(L, 6);
    const char* name = lua_tostring(L, 7);
    lua_getfield(L, LUA_REGISTRYINDEX, "pcellstate");
    struct pcell_state* pcell_state = lua_touserdata(L, -1);
    lua_pop(L, 1); // pop pcell state
    struct object* child = object_add_child_array(cell->object, pcell_state, identifier, xrep, yrep, xpitch, ypitch, name);
    lobject_adapt(L, child);
    return 1;
}

static int lobject_merge_into_shallow(lua_State* L)
{
    lobject_t* cell = lobject_check(L, 1);
    lobject_t* other = lobject_check(L, 2);
    object_merge_into_shallow(cell->object, other->object);
    return 0;
}

int lobject_add_anchor(lua_State* L)
{
    lobject_t* cell = lobject_check(L, 1);
    const char* name = lua_tostring(L, 2);
    lpoint_t* lpoint = lpoint_checkpoint(L, 3);
    object_add_anchor(cell->object, name, lpoint->point->x, lpoint->point->y);
    return 0;
}

int lobject_get_anchor(lua_State* L)
{
    lobject_t* cell = lobject_check(L, 1);
    const char* name = lua_tostring(L, 2);
    point_t* point = object_get_anchor(cell->object, name);
    if(point)
    {
        lpoint_adapt_point(L, point);
    }
    else
    {
        lua_pushfstring(L, "trying to access undefined anchor '%s'", name);
        lua_error(L);
    }
    return 1;
}

int lobject_add_port(lua_State* L)
{
    lobject_t* cell = lobject_check(L, 1);
    const char* name = luaL_checkstring(L, 2);
    struct generics* layer = lua_touserdata(L, 3);
    lpoint_t* lpoint = lpoint_checkpoint(L, 4);
    object_add_port(cell->object, name, layer, lpoint->point);
    return 0;
}

int lobject_add_bus_port(lua_State* L)
{
    lobject_t* cell = lobject_check(L, 1);
    const char* name = luaL_checkstring(L, 2);
    struct generics* layer = lua_touserdata(L, 3);
    lpoint_t* lpoint = lpoint_checkpoint(L, 4);
    int startindex = lua_tointeger(L, 5);
    int endindex = lua_tointeger(L, 6);
    unsigned int xpitch = lua_tointeger(L, 7);
    unsigned int ypitch = lua_tointeger(L, 8);
    object_add_bus_port(cell->object, name, layer, lpoint->point, startindex, endindex, xpitch, ypitch);
    return 0;
}

int lobject_set_alignment_box(lua_State* L)
{
    lobject_t* cell = lobject_check(L, 1);
    lpoint_t* bl = lpoint_checkpoint(L, 2);
    lpoint_t* tr = lpoint_checkpoint(L, 3);
    object_set_alignment_box(cell->object, bl->point->x, bl->point->y, tr->point->x, tr->point->y);
    return 0;
}

int lobject_inherit_alignment_box(lua_State* L)
{
    lobject_t* cell = lobject_check(L, 1);
    lobject_t* other = lobject_check(L, 2);
    object_inherit_alignment_box(cell->object, other->object);
    return 0;
}

int lobject_is_empty(lua_State* L)
{
    lobject_t* cell = lobject_check(L, 1);
    lua_pushboolean(L, object_is_empty(cell->object));
    return 1;
}

int lobject_flatten(lua_State* L)
{
    lobject_t* cell = lobject_check(L, 1);
    lua_getfield(L, LUA_REGISTRYINDEX, "pcellstate");
    struct pcell_state* pcell_state = lua_touserdata(L, -1);
    lua_pop(L, 1); // pop pcell state
    object_flatten(cell->object, pcell_state, 0);
    return 1;
}

int open_lobject_lib(lua_State* L)
{
    // create metatable for objects
    luaL_newmetatable(L, LOBJECTMODULE);

    // set methods
    static const luaL_Reg metafuncs[] =
    {
        { "create",                lobject_create                },
        { "copy",                  lobject_copy                  },
        { "exchange",              lobject_exchange              },
        { "add_anchor",            lobject_add_anchor            },
        { "get_anchor",            lobject_get_anchor            },
        { "add_port",              lobject_add_port              },
        { "add_bus_port",          lobject_add_bus_port          },
        { "set_alignment_box",     lobject_set_alignment_box     },
        { "inherit_alignment_box", lobject_inherit_alignment_box },
        { "move_to",               lobject_move_to               },
        { "translate",             lobject_translate             },
        { "mirror_at_xaxis",       lobject_mirror_at_xaxis       },
        { "mirror_at_yaxis",       lobject_mirror_at_yaxis       },
        { "mirror_at_origin",      lobject_mirror_at_origin      },
        { "rotate_90_left",        lobject_rotate_90_left        },
        { "rotate_90_right",       lobject_rotate_90_right       },
        { "flipx",                 lobject_flipx                 },
        { "flipy",                 lobject_flipy                 },
        { "move_anchor",           lobject_move_anchor           },
        { "move_anchor_x",         lobject_move_anchor_x         },
        { "move_anchor_y",         lobject_move_anchor_y         },
        { "apply_transformation",  lobject_apply_transformation  },
        { "add_child",             lobject_add_child             },
        { "add_child_array",       lobject_add_child_array       },
        { "merge_into_shallow",    lobject_merge_into_shallow    },
        { "is_empty",              lobject_is_empty              },
        { "flatten",               lobject_flatten               },
        { "__gc",                  lobject_destroy               },
        { NULL,                    NULL                          }
    };
    luaL_setfuncs(L, metafuncs, 0);

    // add __index
    lua_pushstring(L, "__index");
    lua_pushvalue(L, -2); 
    lua_rawset(L, -3);

    lua_setglobal(L, LOBJECTMODULE);

    return 0;
}

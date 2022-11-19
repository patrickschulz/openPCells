#include "lobject.h"

#include "lua/lauxlib.h"

#include "lpoint.h"

struct lobject {
    struct object* object;
    int destroy;
};

static struct lobject* _create(lua_State* L)
{
    struct lobject* cell = lua_newuserdata(L, sizeof(*cell));
    luaL_setmetatable(L, LOBJECTMODULE);
    cell->destroy = 0;
    return cell;
}

int lobject_create(lua_State* L)
{
    if(!lua_isstring(L, 1))
    {
        lua_pushstring(L, "object.create: expected object name as first argument");
        lua_error(L);
    }
    const char* name = lua_tostring(L, 1);
    struct lobject* cell = _create(L);
    cell->object = object_create(name);
    cell->destroy = 1;
    return 1;
}

struct lobject* lobject_check(lua_State* L, int idx)
{
    return luaL_checkudata(L, idx, LOBJECTMODULE);
}

struct lobject* lobject_check_soft(lua_State* L, int idx)
{
  return luaL_testudata(L, idx, LOBJECTMODULE);
}

struct lobject* lobject_adapt(lua_State* L, struct object* object)
{
    struct lobject* cell = _create(L);
    cell->object = object;
    return cell;
}

struct object* lobject_get(struct lobject* lobject)
{
    return lobject->object;
}

struct object* lobject_disown(struct lobject* lobject)
{
    lobject->destroy = 0;
    return lobject->object;
}

static int lobject_copy(lua_State* L)
{
    struct lobject* cell = lobject_check(L, 1);
    struct lobject* new = _create(L);
    new->object = object_copy(cell->object);
    new->destroy = 1;
    return 1;
}

static int lobject_exchange(lua_State* L)
{
    struct lobject* cell = lobject_check(L, 1);
    struct lobject* other = lobject_check(L, 2);
    struct object* old = cell->object;
    cell->object = other->object;
    other->destroy = 0;
    object_destroy(old);
    return 1;
}

static int lobject_destroy(lua_State* L)
{
    struct lobject* cell = lobject_check(L, 1);
    if(cell->destroy)
    {
        object_destroy(cell->object);
    }
    return 0;
}

static int lobject_move_to(lua_State* L)
{
    struct lobject* cell = lobject_check(L, 1);
    coordinate_t x = lua_tointeger(L, 2);
    coordinate_t y = lua_tointeger(L, 3);
    object_move_to(cell->object, x, y);
    lua_rotate(L, 1, 2);
    return 1;
}

static int lobject_reset_translation(lua_State* L)
{
    struct lobject* cell = lobject_check(L, 1);
    object_reset_translation(cell->object);
    return 1;
}

static int lobject_translate(lua_State* L)
{
    struct lobject* cell = lobject_check(L, 1);
    coordinate_t x = lua_tointeger(L, 2);
    coordinate_t y = lua_tointeger(L, 3);
    object_translate(cell->object, x, y);
    lua_rotate(L, 1, 2);
    return 1;
}

int lobject_mirror_at_xaxis(lua_State* L)
{
    struct lobject* cell = lobject_check(L, 1);
    object_mirror_at_xaxis(cell->object);
    return 1;
}

int lobject_mirror_at_yaxis(lua_State* L)
{
    struct lobject* cell = lobject_check(L, 1);
    object_mirror_at_yaxis(cell->object);
    return 1;
}

int lobject_mirror_at_origin(lua_State* L)
{
    struct lobject* cell = lobject_check(L, 1);
    object_mirror_at_origin(cell->object);
    return 1;
}

int lobject_rotate_90_left(lua_State* L)
{
    struct lobject* cell = lobject_check(L, 1);
    object_rotate_90_left(cell->object);
    return 1;
}

int lobject_rotate_90_right(lua_State* L)
{
    struct lobject* cell = lobject_check(L, 1);
    object_rotate_90_right(cell->object);
    return 1;
}

int lobject_flipx(lua_State* L)
{
    struct lobject* cell = lobject_check(L, 1);
    object_flipx(cell->object);
    return 1;
}

int lobject_flipy(lua_State* L)
{
    struct lobject* cell = lobject_check(L, 1);
    object_flipy(cell->object);
    return 1;
}

int lobject_move_anchor(lua_State* L)
{
    int numstack = lua_gettop(L);
    struct lobject* cell = lobject_check(L, 1);
    const char* name = lua_tostring(L, 2);
    coordinate_t x = 0;
    coordinate_t y = 0;
    if(lua_gettop(L) > 2 && !lua_isnil(L, 3))
    {
        struct lpoint* lpoint = lpoint_checkpoint(L, 3);
        x = lpoint_get(lpoint)->x;
        y = lpoint_get(lpoint)->y;
    }
    int ret = object_move_anchor(cell->object, name, x, y);
    if(!ret)
    {
        lua_pushfstring(L, "move_anchor: could not access anchor '%s'", name);
        lua_error(L);
    }
    lua_rotate(L, 1, numstack - 1);
    return 1;
}

int lobject_move_anchor_x(lua_State* L)
{
    int numstack = lua_gettop(L);
    struct lobject* cell = lobject_check(L, 1);
    const char* name = lua_tostring(L, 2);
    coordinate_t x = 0;
    if(lua_gettop(L) > 2 && !lua_isnil(L, 3))
    {
        struct lpoint* lpoint = lpoint_checkpoint(L, 3);
        x = lpoint_get(lpoint)->x;
    }
    int ret = object_move_anchor_x(cell->object, name, x);
    if(!ret)
    {
        lua_pushfstring(L, "move_anchor_x: could not access anchor '%s'", name);
        lua_error(L);
    }
    lua_rotate(L, 1, numstack - 1);
    return 1;
}

int lobject_move_anchor_y(lua_State* L)
{
    int numstack = lua_gettop(L);
    struct lobject* cell = lobject_check(L, 1);
    const char* name = lua_tostring(L, 2);
    coordinate_t y = 0;
    if(lua_gettop(L) > 2 && !lua_isnil(L, 3))
    {
        struct lpoint* lpoint = lpoint_checkpoint(L, 3);
        y = lpoint_get(lpoint)->y;
    }
    int ret = object_move_anchor_y(cell->object, name, y);
    if(!ret)
    {
        lua_pushfstring(L, "move_anchor_y: could not access anchor '%s'", name);
        lua_error(L);
    }
    lua_rotate(L, 1, numstack - 1);
    return 1;
}

int lobject_add_child(lua_State* L)
{
    struct lobject* cell = lobject_check(L, 1);
    struct lobject* child = lobject_check(L, 2);
    const char* name = luaL_checkstring(L, 3);
    struct object* proxy = object_add_child(cell->object, child->object, name);
    lobject_adapt(L, proxy);
    lobject_disown(child); // memory is now handled by cell
    return 1;
}

int lobject_add_child_array(lua_State* L)
{
    struct lobject* cell = lobject_check(L, 1);
    struct lobject* child = lobject_check(L, 2);
    const char* name = luaL_checkstring(L, 3);
    unsigned xrep = luaL_checkinteger(L, 4);
    unsigned yrep = luaL_checkinteger(L, 5);
    unsigned int xpitch;
    unsigned int ypitch;
    if(lua_gettop(L) < 7) // no-pitch mode
    {
        coordinate_t blx, bly, trx, try;
        if(!object_get_alignment_box_corners(child->object, &blx, &bly, &trx, &try))
        {
            lua_pushfstring(L, "add_child_array: no-pitch mode, but object '%s' has no alignmentbox", object_get_name(child->object));
            lua_error(L);
        }
        xpitch = trx - blx;
        ypitch = try - bly;
    }
    else
    {
        xpitch = luaL_checkinteger(L, 6);
        ypitch = luaL_checkinteger(L, 7);
    }
    struct object* proxy = object_add_child_array(cell->object, child->object, name, xrep, yrep, xpitch, ypitch);
    lobject_adapt(L, proxy);
    lobject_disown(child); // memory is now handled by cell
    return 1;
}

int lobject_width_height_alignmentbox(lua_State* L)
{
    struct lobject* cell = lobject_check(L, 1);
    point_t* bl = object_get_anchor(cell->object, "bottomleft");
    point_t* tr = object_get_anchor(cell->object, "topright");
    if(!bl || !tr)
    {
        lua_pushstring(L, "object.width_height_alignmentbox: cell has no alignmentbox");
        lua_error(L);
    }
    unsigned int width = tr->x - bl->x;
    unsigned int height = tr->y - bl->y;
    lua_pushinteger(L, width);
    lua_pushinteger(L, height);
    point_destroy(bl);
    point_destroy(tr);
    return 2;
}

static int lobject_merge_into_shallow(lua_State* L)
{
    struct lobject* cell = lobject_check(L, 1);
    struct lobject* other = lobject_check(L, 2);
    object_merge_into_shallow(cell->object, other->object);
    return 0;
}

int lobject_add_anchor(lua_State* L)
{
    struct lobject* cell = lobject_check(L, 1);
    const char* name = lua_tostring(L, 2);
    struct lpoint* lpoint = lpoint_checkpoint(L, 3);
    object_add_anchor(cell->object, name, lpoint_get(lpoint)->x, lpoint_get(lpoint)->y);
    return 0;
}

int lobject_add_anchor_area(lua_State* L)
{
    struct lobject* cell = lobject_check(L, 1);
    const char* base = luaL_checkstring(L, 2);
    coordinate_t width = luaL_checkinteger(L, 3);
    coordinate_t height = luaL_checkinteger(L, 4);
    coordinate_t xshift = luaL_checkinteger(L, 5);
    coordinate_t yshift = luaL_checkinteger(L, 6);
    object_add_anchor_area(cell->object, base, width, height, xshift, yshift);
    return 0;
}

int lobject_add_anchor_area_bltr(lua_State* L)
{
    struct lobject* cell = lobject_check(L, 1);
    const char* base = luaL_checkstring(L, 2);
    struct lpoint* bl = lpoint_checkpoint(L, 3);
    struct lpoint* tr = lpoint_checkpoint(L, 4);
    object_add_anchor_area_bltr(cell->object, base, lpoint_get(bl), lpoint_get(tr));
    return 0;
}

int lobject_get_anchor(lua_State* L)
{
    struct lobject* cell = lobject_check(L, 1);
    const char* name = lua_tostring(L, 2);
    point_t* point = object_get_anchor(cell->object, name);
    if(point)
    {
        lpoint_takeover_point(L, point);
    }
    else
    {
        lua_pushfstring(L, "trying to access undefined anchor '%s'", name);
        lua_error(L);
    }
    return 1;
}

int lobject_get_array_anchor(lua_State* L)
{
    struct lobject* cell = lobject_check(L, 1);
    int xindex = luaL_checkinteger(L, 2);
    int yindex = luaL_checkinteger(L, 3);
    const char* name = lua_tostring(L, 4);
    point_t* point = object_get_array_anchor(cell->object, xindex, yindex, name);
    if(point)
    {
        lpoint_takeover_point(L, point);
    }
    else
    {
        lua_pushfstring(L, "trying to access undefined anchor '%s'", name);
        lua_error(L);
    }
    return 1;
}

int lobject_get_all_regular_anchors(lua_State* L)
{
    struct lobject* cell = lobject_check(L, 1);
    const struct hashmap* anchors = object_get_all_regular_anchors(cell->object);
    struct hashmap_const_iterator* iterator = hashmap_const_iterator_create(anchors);
    lua_newtable(L);
    while(hashmap_const_iterator_is_valid(iterator))
    {
        const char* key = hashmap_const_iterator_key(iterator);
        const point_t* anchor = hashmap_const_iterator_value(iterator);
        point_t* pt = point_copy(anchor);
        lpoint_adapt_point(L, pt);
        lua_setfield(L, -2, key);
        hashmap_const_iterator_next(iterator);
    }
    hashmap_const_iterator_destroy(iterator);
    return 1;
}

int lobject_add_port(lua_State* L)
{
    struct lobject* cell = lobject_check(L, 1);
    const char* name = luaL_checkstring(L, 2);
    struct generics* layer = lua_touserdata(L, 3);
    struct lpoint* lpoint = lpoint_checkpoint(L, 4);
    object_add_port(cell->object, name, layer, lpoint_get(lpoint), 1); // 1: store anchor
    return 0;
}

int lobject_add_bus_port(lua_State* L)
{
    struct lobject* cell = lobject_check(L, 1);
    const char* name = luaL_checkstring(L, 2);
    struct generics* layer = lua_touserdata(L, 3);
    struct lpoint* lpoint = lpoint_checkpoint(L, 4);
    int startindex = lua_tointeger(L, 5);
    int endindex = lua_tointeger(L, 6);
    unsigned int xpitch = lua_tointeger(L, 7);
    unsigned int ypitch = lua_tointeger(L, 8);
    object_add_bus_port(cell->object, name, layer, lpoint_get(lpoint), startindex, endindex, xpitch, ypitch, 1); // 1: store anchor
    return 0;
}

int lobject_get_ports(lua_State* L)
{
    struct lobject* cell = lobject_check(L, 1);
    lua_newtable(L);
    struct port_iterator* it = object_create_port_iterator(cell->object);
    int i = 1;
    while(port_iterator_is_valid(it))
    {
        const char* portname;
        const point_t* portwhere;
        port_iterator_get(it, &portname, &portwhere, NULL, NULL, NULL);
        lua_newtable(L);
        lua_pushstring(L, portname);
        lua_setfield(L, -2, "name");
        lpoint_create_internal(L, portwhere->x, portwhere->y);
        lua_setfield(L, -2, "where");
        lua_rawseti(L, -2, i);
        port_iterator_next(it);
        ++i;
    }
    port_iterator_destroy(it);
    return 1;
}

int lobject_set_alignment_box(lua_State* L)
{
    struct lobject* cell = lobject_check(L, 1);
    struct lpoint* bl = lpoint_checkpoint(L, 2);
    struct lpoint* tr = lpoint_checkpoint(L, 3);
    object_set_alignment_box(cell->object, lpoint_get(bl)->x, lpoint_get(bl)->y, lpoint_get(tr)->x, lpoint_get(tr)->y);
    return 0;
}

int lobject_inherit_alignment_box(lua_State* L)
{
    struct lobject* cell = lobject_check(L, 1);
    struct lobject* other = lobject_check(L, 2);
    object_inherit_alignment_box(cell->object, other->object);
    return 0;
}

int lobject_flatten(lua_State* L)
{
    struct lobject* cell = lobject_check(L, 1);
    struct object* obj = object_flatten(cell->object, 0); // 0: !flattenports
    lobject_adapt(L, obj);
    return 1;
}

int lobject_rasterize_curves(lua_State* L)
{
    struct lobject* cell = lobject_check(L, 1);
    object_rasterize_curves(cell->object);
    return 0;
}

int open_lobject_lib(lua_State* L)
{
    // create metatable for objects
    luaL_newmetatable(L, LOBJECTMODULE);

    // set methods
    static const luaL_Reg metafuncs[] =
    {
        { "create",                     lobject_create                      },
        { "copy",                       lobject_copy                        },
        { "exchange",                   lobject_exchange                    },
        { "add_anchor",                 lobject_add_anchor                  },
        { "add_anchor_area",            lobject_add_anchor_area             },
        { "add_anchor_area_bltr",       lobject_add_anchor_area_bltr        },
        { "get_anchor",                 lobject_get_anchor                  },
        { "get_array_anchor",           lobject_get_array_anchor            },
        { "get_all_regular_anchors",    lobject_get_all_regular_anchors     },
        { "add_port",                   lobject_add_port                    },
        { "add_bus_port",               lobject_add_bus_port                },
        { "get_ports",                  lobject_get_ports                   },
        { "set_alignment_box",          lobject_set_alignment_box           },
        { "inherit_alignment_box",      lobject_inherit_alignment_box       },
        { "width_height_alignmentbox",  lobject_width_height_alignmentbox   },
        { "move_to",                    lobject_move_to                     },
        { "reset_translation",          lobject_reset_translation           },
        { "translate",                  lobject_translate                   },
        { "mirror_at_xaxis",            lobject_mirror_at_xaxis             },
        { "mirror_at_yaxis",            lobject_mirror_at_yaxis             },
        { "mirror_at_origin",           lobject_mirror_at_origin            },
        { "rotate_90_left",             lobject_rotate_90_left              },
        { "rotate_90_right",            lobject_rotate_90_right             },
        { "flipx",                      lobject_flipx                       },
        { "flipy",                      lobject_flipy                       },
        { "move_anchor",                lobject_move_anchor                 },
        { "move_anchor_x",              lobject_move_anchor_x               },
        { "move_anchor_y",              lobject_move_anchor_y               },
        { "add_child",                  lobject_add_child                   },
        { "add_child_array",            lobject_add_child_array             },
        { "merge_into_shallow",         lobject_merge_into_shallow          },
        { "flatten",                    lobject_flatten                     },
        { "rasterize_curves",           lobject_rasterize_curves            },
        { "__gc",                       lobject_destroy                     },
        { NULL,                         NULL                                }
    };
    luaL_setfuncs(L, metafuncs, 0);

    // add __index
    lua_pushstring(L, "__index");
    lua_pushvalue(L, -2); 
    lua_rawset(L, -3);

    lua_setglobal(L, LOBJECTMODULE);

    return 0;
}

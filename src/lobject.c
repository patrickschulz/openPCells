#include "lobject.h"

#include <stdlib.h>

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

int lobject_create_pseudo(lua_State* L)
{
    struct lobject* cell = _create(L);
    cell->object = object_create_pseudo();
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

struct lobject* lobject_adapt_owning(lua_State* L, struct object* object)
{
    struct lobject* cell = _create(L);
    cell->object = object;
    cell->destroy = 1;
    return cell;
}

struct lobject* lobject_adapt_non_owning(lua_State* L, struct object* object)
{
    struct lobject* cell = _create(L);
    cell->object = object;
    cell->destroy = 0;
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

static int lobject_get_name(lua_State* L)
{
    struct lobject* cell = lobject_check(L, 1);
    const char* name = object_get_name(cell->object);
    lua_pushstring(L, name);
    return 1;
}

static int lobject_set_name(lua_State* L)
{
    struct lobject* cell = lobject_check(L, 1);
    const char* name = luaL_checkstring(L, 2);
    object_set_name(cell->object, name);
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
    int n = lua_gettop(L);
    if(n != 2 && n != 3)
    {
        lua_pushfstring(L, "object.translate: expected two or three arguments, got %d", n);
        lua_error(L);
    }
    struct lobject* cell = lobject_check(L, 1);
    if(n == 2)
    {
        struct lpoint* pt = lpoint_checkpoint(L, 2);
        coordinate_t x = lpoint_get(pt)->x;
        coordinate_t y = lpoint_get(pt)->y;
        object_translate(cell->object, x, y);
        lua_rotate(L, 1, 1);
    }
    else
    {
        coordinate_t x = lua_tointeger(L, 2);
        coordinate_t y = lua_tointeger(L, 3);
        object_translate(cell->object, x, y);
        lua_rotate(L, 1, 2);
    }
    return 1;
}

static int lobject_translate_x(lua_State* L)
{
    struct lobject* cell = lobject_check(L, 1);
    coordinate_t x = lua_tointeger(L, 2);
    object_translate_x(cell->object, x);
    lua_rotate(L, 1, 1);
    return 1;
}

static int lobject_translate_y(lua_State* L)
{
    struct lobject* cell = lobject_check(L, 1);
    coordinate_t y = lua_tointeger(L, 2);
    object_translate_y(cell->object, y);
    lua_rotate(L, 1, 1);
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

#define _gen_fun_abut_align(what) \
int lobject_ ##what (lua_State* L) \
{ \
    struct lobject* cell = lobject_check(L, 1); \
    if(!object_has_alignmentbox(cell->object)) \
    { \
        lua_pushstring(L, "object." #what ": first object does not have an alignment box"); \
        lua_error(L); \
    } \
    struct lobject* other = lobject_check(L, 2); \
    if(!object_has_alignmentbox(other->object)) \
    { \
        lua_pushstring(L, "object." #what ": second object does not have an alignment box"); \
        lua_error(L); \
    } \
    object_ ##what (cell->object, other->object); \
    return 1; \
} \

_gen_fun_abut_align(abut_left)
_gen_fun_abut_align(abut_right)
_gen_fun_abut_align(abut_top)
_gen_fun_abut_align(abut_bottom)
_gen_fun_abut_align(align_left)
_gen_fun_abut_align(align_right)
_gen_fun_abut_align(align_top)
_gen_fun_abut_align(align_bottom)
_gen_fun_abut_align(overlap_left)
_gen_fun_abut_align(overlap_right)
_gen_fun_abut_align(overlap_top)
_gen_fun_abut_align(overlap_bottom)

#define _gen_fun_abut_align_area_anchor(what) \
int lobject_ ##what (lua_State* L) \
{ \
    struct lobject* cell = lobject_check(L, 1); \
    const char* anchorname = luaL_checkstring(L, 2); \
    if(!object_has_area_anchor(cell->object, anchorname)) \
    { \
        lua_pushfstring(L, "object." #what ": first object does not have an anchor '%s'", anchorname); \
        lua_error(L); \
    } \
    struct lobject* other = lobject_check(L, 3); \
    const char* otheranchorname = luaL_checkstring(L, 4); \
    if(!object_has_area_anchor(other->object, otheranchorname)) \
    { \
        lua_pushfstring(L, "object." #what ": second object does not have an anchor '%s'", otheranchorname); \
        lua_error(L); \
    } \
    object_ ##what (cell->object, anchorname, other->object, otheranchorname); \
    return 1; \
}

_gen_fun_abut_align_area_anchor(abut_area_anchor_left)
_gen_fun_abut_align_area_anchor(abut_area_anchor_right)
_gen_fun_abut_align_area_anchor(abut_area_anchor_top)
_gen_fun_abut_align_area_anchor(abut_area_anchor_bottom)
_gen_fun_abut_align_area_anchor(align_area_anchor)
_gen_fun_abut_align_area_anchor(align_area_anchor_left)
_gen_fun_abut_align_area_anchor(align_area_anchor_right)
_gen_fun_abut_align_area_anchor(align_area_anchor_top)
_gen_fun_abut_align_area_anchor(align_area_anchor_bottom)

int lobject_add_child(lua_State* L)
{
    if(lua_gettop(L) > 3)
    {
        lua_pushstring(L, "object.add_child: called with more than three arguments. Did you mean to call object.add_child_array instead?");
        lua_error(L);
    }
    struct lobject* cell = lobject_check(L, 1);
    struct lobject* child = lobject_check(L, 2);
    const char* name = luaL_checkstring(L, 3);
    struct object* proxy = object_add_child(cell->object, child->object, name);
    if(!proxy)
    {
        lua_pushstring(L, "object.add_child: can't add pseudo objects");
        lua_error(L);
    }
    lobject_adapt_non_owning(L, proxy);
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
    ucoordinate_t xpitch;
    ucoordinate_t ypitch;
    if(lua_gettop(L) < 7) // no-pitch mode
    {
        if(!object_has_alignmentbox(child->object))
        {
            lua_pushfstring(L, "add_child_array: no-pitch mode, but object '%s' has no alignmentbox", object_get_name(child->object));
            lua_error(L);
        }
        object_width_height_alignmentbox(child->object, &xpitch, &ypitch);
    }
    else
    {
        xpitch = luaL_checkinteger(L, 6);
        ypitch = luaL_checkinteger(L, 7);
    }
    struct object* proxy = object_add_child_array(cell->object, child->object, name, xrep, yrep, xpitch, ypitch);
    if(!proxy)
    {
        lua_pushstring(L, "object.add_child_array: can't add pseudo objects");
        lua_error(L);
    }
    lobject_adapt_non_owning(L, proxy);
    lobject_disown(child); // memory is now handled by cell
    return 1;
}

int lobject_width_height_alignmentbox(lua_State* L)
{
    struct lobject* cell = lobject_check(L, 1);
    if(!object_has_alignmentbox(cell->object))
    {
        lua_pushstring(L, "object.width_height_alignmentbox: cell has no alignmentbox");
        lua_error(L);
    }
    ucoordinate_t width;
    ucoordinate_t height;
    object_width_height_alignmentbox(cell->object, &width, &height);
    lua_pushinteger(L, width);
    lua_pushinteger(L, height);
    return 2;
}

static int lobject_merge_into(lua_State* L)
{
    struct lobject* cell = lobject_check(L, 1);
    struct lobject* other = lobject_check(L, 2);
    object_merge_into(cell->object, other->object);
    return 0;
}

int lobject_add_anchor(lua_State* L)
{
    struct lobject* cell = lobject_check(L, 1);
    const char* name = lua_tostring(L, 2);
    struct lpoint* lpoint = lpoint_checkpoint(L, 3);
    int ret = object_add_anchor(cell->object, name, lpoint_get(lpoint)->x, lpoint_get(lpoint)->y);
    if(!ret)
    {
        lua_pushstring(L, "object.add_anchor: could not add anchor as it already exists");
        lua_error(L);
    }
    return 0;
}

int lobject_add_area_anchor(lua_State* L)
{
    struct lobject* cell = lobject_check(L, 1);
    const char* base = luaL_checkstring(L, 2);
    coordinate_t width = luaL_checkinteger(L, 3);
    coordinate_t height = luaL_checkinteger(L, 4);
    coordinate_t xshift = luaL_checkinteger(L, 5);
    coordinate_t yshift = luaL_checkinteger(L, 6);
    object_add_area_anchor(cell->object, base, width, height, xshift, yshift);
    return 0;
}

int lobject_add_area_anchor_bltr(lua_State* L)
{
    struct lobject* cell = lobject_check(L, 1);
    const char* base = luaL_checkstring(L, 2);
    struct lpoint* bl = lpoint_checkpoint(L, 3);
    struct lpoint* tr = lpoint_checkpoint(L, 4);
    object_add_area_anchor_bltr(cell->object, base, lpoint_get(bl), lpoint_get(tr));
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

int lobject_get_area_anchor(lua_State* L)
{
    struct lobject* cell = lobject_check(L, 1);
    const char* base = lua_tostring(L, 2);
    point_t* pts = object_get_area_anchor(cell->object, base);
    if(pts)
    {
        lua_newtable(L);
        lpoint_create_internal(L, pts[0].x, pts[0].y);
        lua_setfield(L, -2, "bl");
        lpoint_create_internal(L, pts[1].x, pts[0].y);
        lua_setfield(L, -2, "br");
        lpoint_create_internal(L, pts[1].x, pts[1].y);
        lua_setfield(L, -2, "tr");
        lpoint_create_internal(L, pts[0].x, pts[1].y);
        lua_setfield(L, -2, "tl");
        free(pts);
    }
    else
    {
        lua_pushfstring(L, "trying to access undefined area anchor '%s'", base);
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
    double sizehint = luaL_optnumber(L, 5, 0.0);
    object_add_port(cell->object, name, layer, lpoint_get(lpoint), 1, sizehint); // 1: store anchor
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
    double sizehint = luaL_optnumber(L, 9, 0.0);
    object_add_bus_port(cell->object, name, layer, lpoint_get(lpoint), startindex, endindex, xpitch, ypitch, 1, sizehint); // 1: store anchor
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
        port_iterator_get(it, &portname, &portwhere, NULL, NULL, NULL, NULL);
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
    if(lua_gettop(L) == 3)
    {
        struct lpoint* bl = lpoint_checkpoint(L, 2);
        struct lpoint* tr = lpoint_checkpoint(L, 3);
        object_set_alignment_box(
            cell->object,
            lpoint_get(bl)->x, lpoint_get(bl)->y,
            lpoint_get(tr)->x, lpoint_get(tr)->y,
            lpoint_get(bl)->x, lpoint_get(bl)->y,
            lpoint_get(tr)->x, lpoint_get(tr)->y
        );
    }
    else if(lua_gettop(L) == 5)
    {
        struct lpoint* outerbl = lpoint_checkpoint(L, 2);
        struct lpoint* outertr = lpoint_checkpoint(L, 3);
        struct lpoint* innerbl = lpoint_checkpoint(L, 4);
        struct lpoint* innertr = lpoint_checkpoint(L, 5);
        object_set_alignment_box(
            cell->object,
            lpoint_get(outerbl)->x, lpoint_get(outerbl)->y,
            lpoint_get(outertr)->x, lpoint_get(outertr)->y,
            lpoint_get(innerbl)->x, lpoint_get(innerbl)->y,
            lpoint_get(innertr)->x, lpoint_get(innertr)->y
        );
    }
    else
    {
        lua_pushfstring(L, "object.set_alignment_box: expected 2 points or 4 points, got %d", lua_gettop(L) - 1);
        lua_error(L);
    }
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
    lobject_adapt_owning(L, obj);
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
        { "create_pseudo",              lobject_create_pseudo               },
        { "copy",                       lobject_copy                        },
        { "exchange",                   lobject_exchange                    },
        { "get_name",                   lobject_get_name                    },
        { "set_name",                   lobject_set_name                    },
        { "add_anchor",                 lobject_add_anchor                  },
        { "add_area_anchor",            lobject_add_area_anchor             },
        { "add_area_anchor_bltr",       lobject_add_area_anchor_bltr        },
        { "get_anchor",                 lobject_get_anchor                  },
        { "get_area_anchor",            lobject_get_area_anchor             },
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
        { "translate_x",                lobject_translate_x                 },
        { "translate_y",                lobject_translate_y                 },
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
        { "abut_left",                  lobject_abut_left                   },
        { "abut_right",                 lobject_abut_right                  },
        { "abut_top",                   lobject_abut_top                    },
        { "abut_bottom",                lobject_abut_bottom                 },
        { "align_left",                 lobject_align_left                  },
        { "align_right",                lobject_align_right                 },
        { "align_top",                  lobject_align_top                   },
        { "align_bottom",               lobject_align_bottom                },
        { "overlap_left",               lobject_overlap_left                },
        { "overlap_right",              lobject_overlap_right               },
        { "overlap_top",                lobject_overlap_top                 },
        { "overlap_bottom",             lobject_overlap_bottom              },
        { "abut_area_anchor_left",      lobject_abut_area_anchor_left       },
        { "abut_area_anchor_right",     lobject_abut_area_anchor_right      },
        { "abut_area_anchor_top",       lobject_abut_area_anchor_top        },
        { "abut_area_anchor_bottom",    lobject_abut_area_anchor_bottom     },
        { "align_area_anchor",          lobject_align_area_anchor           },
        { "align_area_anchor_left",     lobject_align_area_anchor_left      },
        { "align_area_anchor_right",    lobject_align_area_anchor_right     },
        { "align_area_anchor_top",      lobject_align_area_anchor_top       },
        { "align_area_anchor_bottom",   lobject_align_area_anchor_bottom    },
        { "add_child",                  lobject_add_child                   },
        { "add_child_array",            lobject_add_child_array             },
        { "merge_into",                 lobject_merge_into                  },
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


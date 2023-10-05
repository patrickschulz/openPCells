#include "lobject.h"

#include <stdlib.h>

#include "lua/lauxlib.h"

#include "lpoint.h"
#include "lcheck.h"

struct lobject {
    struct object* object;
    int destroy;
};

static int lobject_tostring(lua_State* L)
{
    struct lobject* cell = lobject_check(L, 1);
    lua_pushfstring(L, "object: '%s' (%p)", object_get_name(cell->object), cell->object);
    return 1;
}

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

static int lobject_create_pseudo(lua_State* L)
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
    new->object = object_copy(lobject_get(cell));
    new->destroy = 1;
    return 1;
}

static int lobject_exchange(lua_State* L)
{
    struct lobject* cell = lobject_check(L, 1);
    struct lobject* other = lobject_check(L, 2);
    struct object* old = cell->object;
    cell->object = other->object;
    object_set_name(cell->object, object_get_name(old));
    other->destroy = 0;
    object_destroy(old);
    return 1;
}

static int lobject_get_name(lua_State* L)
{
    struct lobject* cell = lobject_check(L, 1);
    const char* name = object_get_name(lobject_get(cell));
    lua_pushstring(L, name);
    return 1;
}

static int lobject_set_name(lua_State* L)
{
    struct lobject* cell = lobject_check(L, 1);
    const char* name = luaL_checkstring(L, 2);
    object_set_name(lobject_get(cell), name);
    return 1;
}

static int lobject_destroy(lua_State* L)
{
    struct lobject* cell = lobject_check(L, 1);
    if(cell->destroy)
    {
        object_destroy(lobject_get(cell));
    }
    return 0;
}

static int lobject_move_to(lua_State* L)
{
    int n = lua_gettop(L);
    if(n != 2 && n != 3)
    {
        lua_pushfstring(L, "object.move_to: expected two or three arguments, got %d", n);
        lua_error(L);
    }
    struct lobject* cell = lobject_check(L, 1);
    if(n == 2)
    {
        struct lpoint* pt = lpoint_checkpoint(L, 2);
        coordinate_t x = lpoint_get(pt)->x;
        coordinate_t y = lpoint_get(pt)->y;
        object_move_to(lobject_get(cell), x, y);
        lua_rotate(L, 1, 1);
    }
    else
    {
        coordinate_t x = lua_tointeger(L, 2);
        coordinate_t y = lua_tointeger(L, 3);
        object_move_to(lobject_get(cell), x, y);
        lua_rotate(L, 1, 2);
    }
    return 1;
}

static int lobject_reset_translation(lua_State* L)
{
    struct lobject* cell = lobject_check(L, 1);
    object_reset_translation(lobject_get(cell));
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
        object_translate(lobject_get(cell), x, y);
        lua_rotate(L, 1, 1);
    }
    else
    {
        coordinate_t x = luaL_checkinteger(L, 2);
        coordinate_t y = luaL_checkinteger(L, 3);
        object_translate(lobject_get(cell), x, y);
        lua_rotate(L, 1, 2);
    }
    return 1;
}

static int lobject_translate_x(lua_State* L)
{
    struct lobject* cell = lobject_check(L, 1);
    coordinate_t x = lua_tointeger(L, 2);
    object_translate_x(lobject_get(cell), x);
    lua_rotate(L, 1, 1);
    return 1;
}

static int lobject_translate_y(lua_State* L)
{
    struct lobject* cell = lobject_check(L, 1);
    coordinate_t y = lua_tointeger(L, 2);
    object_translate_y(lobject_get(cell), y);
    lua_rotate(L, 1, 1);
    return 1;
}

static int lobject_mirror_at_xaxis(lua_State* L)
{
    struct lobject* cell = lobject_check(L, 1);
    object_mirror_at_xaxis(lobject_get(cell));
    return 1;
}

static int lobject_mirror_at_yaxis(lua_State* L)
{
    struct lobject* cell = lobject_check(L, 1);
    object_mirror_at_yaxis(lobject_get(cell));
    return 1;
}

static int lobject_mirror_at_origin(lua_State* L)
{
    struct lobject* cell = lobject_check(L, 1);
    object_mirror_at_origin(lobject_get(cell));
    return 1;
}

static int lobject_rotate_90_left(lua_State* L)
{
    struct lobject* cell = lobject_check(L, 1);
    object_rotate_90_left(lobject_get(cell));
    return 1;
}

static int lobject_rotate_90_right(lua_State* L)
{
    struct lobject* cell = lobject_check(L, 1);
    object_rotate_90_right(lobject_get(cell));
    return 1;
}

static int lobject_flipx(lua_State* L)
{
    struct lobject* cell = lobject_check(L, 1);
    object_flipx(lobject_get(cell));
    return 1;
}

static int lobject_flipy(lua_State* L)
{
    struct lobject* cell = lobject_check(L, 1);
    object_flipy(lobject_get(cell));
    return 1;
}

static int lobject_move_point(lua_State* L)
{
    struct lobject* cell = lobject_check(L, 1);
    struct lpoint* source = lpoint_checkpoint(L, 2);
    struct lpoint* target = lpoint_checkpoint(L, 3);
    object_move_point(lobject_get(cell), lpoint_get(source), lpoint_get(target));
    lua_rotate(L, 1, 2);
    return 1;
}

static int lobject_move_point_x(lua_State* L)
{
    struct lobject* cell = lobject_check(L, 1);
    struct lpoint* source = lpoint_checkpoint(L, 2);
    struct lpoint* target = lpoint_checkpoint(L, 3);
    object_move_point_x(lobject_get(cell), lpoint_get(source), lpoint_get(target));
    lua_rotate(L, 1, 2);
    return 1;
}

static int lobject_move_point_y(lua_State* L)
{
    struct lobject* cell = lobject_check(L, 1);
    struct lpoint* source = lpoint_checkpoint(L, 2);
    struct lpoint* target = lpoint_checkpoint(L, 3);
    object_move_point_y(lobject_get(cell), lpoint_get(source), lpoint_get(target));
    lua_rotate(L, 1, 2);
    return 1;
}

#define _gen_fun_abut_align(what) \
static int lobject_ ##what (lua_State* L) \
{ \
    struct lobject* cell = lobject_check(L, 1); \
    if(!object_has_alignmentbox(lobject_get(cell))) \
    { \
        const char* name = object_get_name(lobject_get(cell)); \
        if(name) \
        { \
            lua_pushfstring(L, "object." #what ": first object ('%s') does not have an alignment box", name); \
        } \
        else \
        { \
            lua_pushstring(L, "object." #what ": first object does not have an alignment box"); \
        } \
        lua_error(L); \
    } \
    struct lobject* other = lobject_check(L, 2); \
    if(!object_has_alignmentbox(lobject_get(other))) \
    { \
        lua_pushstring(L, "object." #what ": second object does not have an alignment box"); \
        lua_error(L); \
    } \
    object_ ##what (lobject_get(cell), lobject_get(other)); \
    return 1; \
}

_gen_fun_abut_align(abut_left)
_gen_fun_abut_align(abut_right)
_gen_fun_abut_align(abut_top)
_gen_fun_abut_align(abut_bottom)
_gen_fun_abut_align(align_left)
_gen_fun_abut_align(align_right)
_gen_fun_abut_align(align_top)
_gen_fun_abut_align(align_bottom)

#define _gen_fun_align_origin(what) \
static int lobject_ ##what (lua_State* L) \
{ \
    struct lobject* cell = lobject_check(L, 1); \
    if(!object_has_alignmentbox(lobject_get(cell))) \
    { \
        const char* name = object_get_name(lobject_get(cell)); \
        if(name) \
        { \
            lua_pushfstring(L, "object." #what ": first object ('%s') does not have an alignment box", name); \
        } \
        else \
        { \
            lua_pushstring(L, "object." #what ": first object does not have an alignment box"); \
        } \
        lua_error(L); \
    } \
    object_ ##what (lobject_get(cell)); \
    return 1; \
}

_gen_fun_align_origin(abut_left_origin)
_gen_fun_align_origin(abut_right_origin)
_gen_fun_align_origin(abut_top_origin)
_gen_fun_align_origin(abut_bottom_origin)
_gen_fun_align_origin(align_left_origin)
_gen_fun_align_origin(align_right_origin)
_gen_fun_align_origin(align_top_origin)
_gen_fun_align_origin(align_bottom_origin)

#define _gen_fun_abut_align_area_anchor(what) \
static int lobject_ ##what (lua_State* L) \
{ \
    struct lobject* cell = lobject_check(L, 1); \
    const char* anchorname = luaL_checkstring(L, 2); \
    if(!object_has_area_anchor(lobject_get(cell), anchorname)) \
    { \
        const char* name = object_get_name(lobject_get(cell)); \
        if(name) \
        { \
            lua_pushfstring(L, "object." #what ": first object ('%s') does not have an anchor '%s'", name, anchorname); \
        } \
        else \
        { \
            lua_pushfstring(L, "object." #what ": first object does not have an anchor '%s'", anchorname); \
        } \
        lua_error(L); \
    } \
    struct lobject* other = lobject_check(L, 3); \
    const char* otheranchorname = luaL_checkstring(L, 4); \
    if(!object_has_area_anchor(lobject_get(other), otheranchorname)) \
    { \
        lua_pushfstring(L, "object." #what ": second object does not have an anchor '%s'", otheranchorname); \
        lua_error(L); \
    } \
    object_ ##what (lobject_get(cell), anchorname, lobject_get(other), otheranchorname); \
    return 1; \
}

_gen_fun_abut_align_area_anchor(abut_area_anchor_left)
_gen_fun_abut_align_area_anchor(abut_area_anchor_right)
_gen_fun_abut_align_area_anchor(abut_area_anchor_top)
_gen_fun_abut_align_area_anchor(abut_area_anchor_bottom)
_gen_fun_abut_align_area_anchor(align_area_anchor_x)
_gen_fun_abut_align_area_anchor(align_area_anchor_left)
_gen_fun_abut_align_area_anchor(align_area_anchor_right)
_gen_fun_abut_align_area_anchor(align_area_anchor_y)
_gen_fun_abut_align_area_anchor(align_area_anchor_top)
_gen_fun_abut_align_area_anchor(align_area_anchor_bottom)

static int lobject_align_area_anchor(lua_State* L)
{
    struct lobject* cell = lobject_check(L, 1);
    const char* anchorname = luaL_checkstring(L, 2);
    if(!object_has_area_anchor(lobject_get(cell), anchorname))
    {
        const char* name = object_get_name(lobject_get(cell));
        if(name)
        {
            lua_pushfstring(L, "object.align_area_anchor: first object ('%s') does not have an anchor '%s'", name, anchorname);
        }
        else
        {
            lua_pushfstring(L, "object.align_area_anchor: first object does not have an anchor '%s'", anchorname);
        }
        lua_error(L);
    }
    struct lobject* other = lobject_check(L, 3);
    const char* otheranchorname = luaL_checkstring(L, 4);
    if(!object_has_area_anchor(lobject_get(other), otheranchorname))
    {
        lua_pushfstring(L, "object.align_area_anchor: second object does not have an anchor '%s'", otheranchorname);
        lua_error(L);
    }
    if(!object_area_anchors_fit(lobject_get(cell), anchorname, lobject_get(other), otheranchorname))
    {
        lua_pushstring(L, "object.align_area_anchor: area anchors do not fit (have the same size)");
        lua_error(L);
    }
    object_align_area_anchor(lobject_get(cell), anchorname, lobject_get(other), otheranchorname);
    return 1;
}

static int lobject_add_child(lua_State* L)
{
    if(lua_gettop(L) > 3)
    {
        lua_pushstring(L, "object.add_child: called with more than three arguments. Did you mean to call object.add_child_array instead?");
        lua_error(L);
    }
    struct lobject* cell = lobject_check(L, 1);
    struct lobject* child = lobject_check(L, 2);
    const char* name = luaL_checkstring(L, 3);
    struct object* proxy = object_add_child(lobject_get(cell), lobject_get(child), name);
    if(!proxy)
    {
        lua_pushstring(L, "object.add_child: can't add pseudo objects");
        lua_error(L);
    }
    lobject_adapt_non_owning(L, proxy);
    lobject_disown(child); // memory is now handled by cell
    return 1;
}

static int lobject_add_child_array(lua_State* L)
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
        if(!object_has_alignmentbox(lobject_get(child)))
        {
            lua_pushfstring(L, "add_child_array: no-pitch mode, but object '%s' has no alignmentbox", object_get_name(lobject_get(child)));
            lua_error(L);
        }
        object_width_height_alignmentbox(lobject_get(child), &xpitch, &ypitch);
    }
    else
    {
        xpitch = luaL_checkinteger(L, 6);
        ypitch = luaL_checkinteger(L, 7);
    }
    struct object* proxy = object_add_child_array(lobject_get(cell), lobject_get(child), name, xrep, yrep, xpitch, ypitch);
    if(!proxy)
    {
        lua_pushstring(L, "object.add_child_array: can't add pseudo objects");
        lua_error(L);
    }
    lobject_adapt_non_owning(L, proxy);
    lobject_disown(child); // memory is now handled by cell
    return 1;
}

static int lobject_width_height_alignmentbox(lua_State* L)
{
    struct lobject* cell = lobject_check(L, 1);
    if(!object_has_alignmentbox(lobject_get(cell)))
    {
        lua_pushstring(L, "object.width_height_alignmentbox: cell has no alignmentbox");
        lua_error(L);
    }
    ucoordinate_t width;
    ucoordinate_t height;
    object_width_height_alignmentbox(lobject_get(cell), &width, &height);
    lua_pushinteger(L, width);
    lua_pushinteger(L, height);
    return 2;
}

static int lobject_merge_into(lua_State* L)
{
    struct lobject* cell = lobject_check(L, 1);
    struct lobject* other = lobject_check(L, 2);
    object_merge_into(lobject_get(cell), lobject_get(other));
    return 0;
}

static int lobject_add_anchor(lua_State* L)
{
    struct lobject* cell = lobject_check(L, 1);
    const char* name = lua_tostring(L, 2);
    struct lpoint* lpoint = lpoint_checkpoint(L, 3);
    int ret = object_add_anchor(lobject_get(cell), name, lpoint_get(lpoint)->x, lpoint_get(lpoint)->y);
    if(!ret)
    {
        lua_pushstring(L, "object.add_anchor: could not add anchor as it already exists");
        lua_error(L);
    }
    return 0;
}

static void _check_rectangle_points(lua_State* L, struct lpoint* bl, struct lpoint* tr, const char* context)
{
    if(lpoint_get(bl)->x > lpoint_get(tr)->x || lpoint_get(bl)->y > lpoint_get(tr)->y)
    {
        if(context)
        {
            lua_pushfstring(L, "%s: rectangle points are not in order: (%d, %d) and (%d, %d)", context, lpoint_get(bl)->x, lpoint_get(bl)->y, lpoint_get(tr)->x, lpoint_get(tr)->y);
        }
        else
        {
            lua_pushfstring(L, "rectangle points are not in order: (%d, %d) and (%d, %d)", lpoint_get(bl)->x, lpoint_get(bl)->y, lpoint_get(tr)->x, lpoint_get(tr)->y);
        }
        lua_error(L);
    }
}

static int lobject_add_area_anchor_bltr(lua_State* L)
{
    if(lua_gettop(L) != 4)
    {
        lua_pushfstring(L, "object.add_area_anchor_bltr: expected four arguments, got %d", lua_gettop(L));
        lua_error(L);
    }
    struct lobject* cell = lobject_check(L, 1);
    const char* base = luaL_checkstring(L, 2);
    struct lpoint* bl = lpoint_checkpoint(L, 3);
    struct lpoint* tr = lpoint_checkpoint(L, 4);
    _check_rectangle_points(L, bl, tr, "object.add_area_anchor_bltr");
    object_add_area_anchor_bltr(lobject_get(cell), base, lpoint_get(bl), lpoint_get(tr));
    return 0;
}

static int lobject_inherit_area_anchor(lua_State* L)
{
    struct lobject* cell = lobject_check(L, 1);
    struct lobject* other = lobject_check(L, 2);
    const char* anchorname = luaL_checkstring(L, 3);
    if(!object_has_area_anchor(lobject_get(other), anchorname))
    {
        lua_pushfstring(L, "object.inherit_area_anchor: object does not have an area anchor '%s'", anchorname);
        lua_error(L);
    }
    object_inherit_area_anchor(lobject_get(cell), lobject_get(other), anchorname);
    return 0;
}

static int lobject_inherit_area_anchor_as(lua_State* L)
{
    struct lobject* cell = lobject_check(L, 1);
    struct lobject* other = lobject_check(L, 2);
    const char* anchorname = luaL_checkstring(L, 3);
    const char* newanchorname = luaL_checkstring(L, 4);
    if(!object_has_area_anchor(lobject_get(other), anchorname))
    {
        lua_pushfstring(L, "object.inherit_area_anchor_as: object does not have an area anchor '%s'", anchorname);
        lua_error(L);
    }
    object_inherit_area_anchor_as(lobject_get(cell), lobject_get(other), anchorname, newanchorname);
    return 0;
}

static int lobject_inherit_all_anchors_with_prefix(lua_State* L)
{
    struct lobject* cell = lobject_check(L, 1);
    struct lobject* other = lobject_check(L, 2);
    const char* prefix = luaL_checkstring(L, 3);
    object_inherit_all_anchors_with_prefix(lobject_get(cell), lobject_get(other), prefix);
    return 0;
}

static int lobject_get_anchor(lua_State* L)
{
    struct lobject* cell = lobject_check(L, 1);
    const char* name = lua_tostring(L, 2);
    point_t* point = object_get_anchor(lobject_get(cell), name);
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

static int lobject_get_alignment_anchor(lua_State* L)
{
    struct lobject* cell = lobject_check(L, 1);
    if(!object_has_alignmentbox(lobject_get(cell)))
    {
        lua_pushstring(L, "object.get_alignment_anchor: object has no alignment box");
        lua_error(L);
    }
    const char* name = lua_tostring(L, 2);
    // FIXME: check that name is a valid identifier
    point_t* point = object_get_alignment_anchor(lobject_get(cell), name);
    if(point)
    {
        lpoint_takeover_point(L, point);
    }
    else
    {
        lua_pushfstring(L, "trying to access undefined alignment anchor '%s'", name);
        lua_error(L);
    }
    return 1;
}

static int _area_anchor_index_func(lua_State* L)
{
    lua_getfield(L, 1, "_name");
    const char* name = lua_tostring(L, -1);
    lua_pop(L, 1);
    const char* key = lua_tostring(L, 2);
    if(name)
    {
        lua_pushfstring(L, "area anchor '%s': trying to access undefined sub-anchor '%s'. Possible sub-anchors are bl, br, tl and tr", name, key);
    }
    else
    {
        lua_pushfstring(L, "area anchor: trying to access undefined sub-anchor '%s'. Possible sub-anchors are bl, br, tl and tr", key);
    }
    lua_error(L);
    return 0;
}

static int lobject_get_area_anchor(lua_State* L)
{
    if(luaL_newmetatable(L, "areaanchor"))
    {
        lua_pushcfunction(L, _area_anchor_index_func);
        lua_setfield(L, -2, "__index");
    }
    lua_pop(L, 1); // pop meta table
    struct lobject* cell = lobject_check(L, 1);
    const char* base = lua_tostring(L, 2);
    point_t* pts = object_get_area_anchor(lobject_get(cell), base);
    if(pts)
    {
        lua_newtable(L);
        lua_pushstring(L, base);
        lua_setfield(L, -2, "_name");
        lpoint_create_internal(L, pts[0].x, pts[0].y);
        lua_setfield(L, -2, "bl");
        lpoint_create_internal(L, pts[1].x, pts[0].y);
        lua_setfield(L, -2, "br");
        lpoint_create_internal(L, pts[1].x, pts[1].y);
        lua_setfield(L, -2, "tr");
        lpoint_create_internal(L, pts[0].x, pts[1].y);
        lua_setfield(L, -2, "tl");
        free(pts);
        luaL_setmetatable(L, "areaanchor");
    }
    else
    {
        const char* name = object_get_name(lobject_get(cell));
        if(name)
        {
            const char* name = object_get_name(lobject_get(cell));
            lua_pushfstring(L, "trying to access undefined area anchor '%s' in object '%s'", base, name);
            lua_error(L);
        }
        else
        {
            lua_pushfstring(L, "trying to access undefined area anchor '%s'", base);
            lua_error(L);
        }
    }
    return 1;
}

static int lobject_get_array_anchor(lua_State* L)
{
    struct lobject* cell = lobject_check(L, 1);
    int xindex = luaL_checkinteger(L, 2);
    int yindex = luaL_checkinteger(L, 3);
    const char* name = lua_tostring(L, 4);
    point_t* point = object_get_array_anchor(lobject_get(cell), xindex, yindex, name);
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

static int lobject_get_array_area_anchor(lua_State* L)
{
    lcheck_check_numargs(L, 4, "object.get_array_area_anchor");
    struct lobject* cell = lobject_check(L, 1);
    int xindex = luaL_checkinteger(L, 2);
    int yindex = luaL_checkinteger(L, 3);
    const char* base = luaL_checkstring(L, 4);
    point_t* pts = object_get_array_area_anchor(lobject_get(cell), xindex - 1, yindex - 1, base);
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
        luaL_setmetatable(L, "areaanchor");
    }
    else
    {
        lua_pushfstring(L, "trying to access undefined area anchor '%s'", base);
        lua_error(L);
    }
    return 1;
}

static int lobject_get_all_regular_anchors(lua_State* L)
{
    struct lobject* cell = lobject_check(L, 1);
    const struct hashmap* anchors = object_get_all_regular_anchors(lobject_get(cell));
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

static int lobject_add_port(lua_State* L)
{
    lcheck_check_numargs_set(L, 4, 5, "object.add_port");
    struct lobject* cell = lobject_check(L, 1);
    const char* name = luaL_checkstring(L, 2);
    const struct generics* layer = lua_touserdata(L, 3);
    struct lpoint* lpoint = lpoint_checkpoint(L, 4);
    double sizehint = luaL_optnumber(L, 5, 0.0);
    object_add_port(lobject_get(cell), name, layer, lpoint_get(lpoint), 1, sizehint); // 1: store anchor
    return 0;
}

static int lobject_add_bus_port(lua_State* L)
{
    struct lobject* cell = lobject_check(L, 1);
    const char* name = luaL_checkstring(L, 2);
    const struct generics* layer = lua_touserdata(L, 3);
    struct lpoint* lpoint = lpoint_checkpoint(L, 4);
    int startindex = lua_tointeger(L, 5);
    int endindex = lua_tointeger(L, 6);
    unsigned int xpitch = lua_tointeger(L, 7);
    unsigned int ypitch = lua_tointeger(L, 8);
    double sizehint = luaL_optnumber(L, 9, 0.0);
    object_add_bus_port(lobject_get(cell), name, layer, lpoint_get(lpoint), startindex, endindex, xpitch, ypitch, 1, sizehint); // 1: store anchor
    return 0;
}

static int lobject_get_ports(lua_State* L)
{
    struct lobject* cell = lobject_check(L, 1);
    lua_newtable(L);
    struct port_iterator* it = object_create_port_iterator(lobject_get(cell));
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

static int lobject_clear_alignment_box(lua_State* L)
{
    struct lobject* cell = lobject_check(L, 1);
    if(!object_has_alignmentbox(lobject_get(cell)))
    {
        lua_pushstring(L, "object.clear_alignment_box: object has no alignment box");
        lua_error(L);
    }
    object_clear_alignment_box(lobject_get(cell));
    return 0;
}

static int lobject_set_alignment_box(lua_State* L)
{
    struct lobject* cell = lobject_check(L, 1);
    if(object_has_alignmentbox(lobject_get(cell)))
    {
        lua_pushstring(L, "object.set_alignment_box: object already has an alignment box");
        lua_error(L);
    }
    if(lua_gettop(L) == 3)
    {
        struct lpoint* bl = lpoint_checkpoint(L, 2);
        struct lpoint* tr = lpoint_checkpoint(L, 3);
        object_set_alignment_box(
            lobject_get(cell),
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
            lobject_get(cell),
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

static int lobject_inherit_alignment_box(lua_State* L)
{
    struct lobject* cell = lobject_check(L, 1);
    struct lobject* other = lobject_check(L, 2);
    if(!object_has_alignmentbox(lobject_get(other)))
    {
        lua_pushstring(L, "object.inherit_alignment_box: othercell has no alignmentbox");
        lua_error(L);
    }
    object_inherit_alignment_box(lobject_get(cell), lobject_get(other));
    return 0;
}

static int lobject_extend_alignment_box(lua_State* L)
{
    struct lobject* cell = lobject_check(L, 1);
    coordinate_t extouterblx = 0;
    coordinate_t extouterbly = 0;
    coordinate_t extoutertrx = 0;
    coordinate_t extoutertry = 0;
    coordinate_t extinnerblx = 0;
    coordinate_t extinnerbly = 0;
    coordinate_t extinnertrx = 0;
    coordinate_t extinnertry = 0;
    if(lua_gettop(L) == 9)
    {
        extouterblx = lua_tointeger(L, 2);
        extouterbly = lua_tointeger(L, 3);
        extoutertrx = lua_tointeger(L, 4);
        extoutertry = lua_tointeger(L, 5);
        extinnerblx = lua_tointeger(L, 6);
        extinnerbly = lua_tointeger(L, 7);
        extinnertrx = lua_tointeger(L, 8);
        extinnertry = lua_tointeger(L, 9);
    }
    else
    {
        lua_pushfstring(L, "object.extend_alignment_box: expected nine arguments, got %d", lua_gettop(L));
        lua_error(L);
    }
    if(!object_has_alignmentbox(lobject_get(cell)))
    {
        lua_pushstring(L, "object.extend_alignment_box: cell has no alignmentbox");
        lua_error(L);
    }
    object_extend_alignment_box(
        lobject_get(cell),
        extouterblx,
        extouterbly,
        extoutertrx,
        extoutertry,
        extinnerblx,
        extinnerbly,
        extinnertrx,
        extinnertry
    );
    return 0;
}

static int lobject_extend_alignment_box_x_symmetrical(lua_State* L)
{
    struct lobject* cell = lobject_check(L, 1);
    coordinate_t extouterblx = 0;
    coordinate_t extouterbly = 0;
    coordinate_t extoutertrx = 0;
    coordinate_t extoutertry = 0;
    coordinate_t extinnerblx = 0;
    coordinate_t extinnerbly = 0;
    coordinate_t extinnertrx = 0;
    coordinate_t extinnertry = 0;
    if(lua_gettop(L) == 9)
    {
        extouterblx = lua_tointeger(L, 2);
        extouterbly = lua_tointeger(L, 3);
        extoutertrx = lua_tointeger(L, 4);
        extoutertry = lua_tointeger(L, 5);
        extinnerblx = lua_tointeger(L, 6);
        extinnerbly = lua_tointeger(L, 7);
        extinnertrx = lua_tointeger(L, 8);
        extinnertry = lua_tointeger(L, 9);
    }
    else
    {
        lua_pushfstring(L, "object.extend_alignment_box: expected nine arguments, got %d", lua_gettop(L));
        lua_error(L);
    }
    if(!object_has_alignmentbox(lobject_get(cell)))
    {
        lua_pushstring(L, "object.extend_alignment_box: cell has no alignmentbox");
        lua_error(L);
    }
    object_extend_alignment_box(
        lobject_get(cell),
        extouterblx,
        extouterbly,
        extoutertrx,
        extoutertry,
        extinnerblx,
        extinnerbly,
        extinnertrx,
        extinnertry
    );
    return 0;
}

static int lobject_flatten(lua_State* L)
{
    struct lobject* cell = lobject_check(L, 1);
    struct object* obj = object_flatten(lobject_get(cell), 0); // 0: !flattenports
    lobject_adapt_owning(L, obj);
    return 1;
}

static int lobject_flatten_inline(lua_State* L)
{
    struct lobject* cell = lobject_check(L, 1);
    object_flatten_inline(lobject_get(cell), 0);
    return 1;
}

static int lobject_rasterize_curves(lua_State* L)
{
    struct lobject* cell = lobject_check(L, 1);
    object_rasterize_curves(lobject_get(cell));
    return 0;
}

static int lobject_get_area_anchor_width(lua_State* L)
{
    struct lobject* cell = lobject_check(L, 1);
    const char* anchorname = luaL_checkstring(L, 2);
    if(!object_has_area_anchor(lobject_get(cell), anchorname))
    {
        lua_pushfstring(L, "object.get_area_anchor_width: object does not have an area anchor '%s'", anchorname);
        lua_error(L);
    }
    coordinate_t width = object_get_area_anchor_width(lobject_get(cell), anchorname);
    lua_pushinteger(L, width);
    return 1;
}

static int lobject_get_area_anchor_height(lua_State* L)
{
    struct lobject* cell = lobject_check(L, 1);
    const char* anchorname = luaL_checkstring(L, 2);
    if(!object_has_area_anchor(lobject_get(cell), anchorname))
    {
        lua_pushfstring(L, "object.get_area_anchor_height: object does not have an area anchor '%s'", anchorname);
        lua_error(L);
    }
    coordinate_t height = object_get_area_anchor_height(lobject_get(cell), anchorname);
    lua_pushinteger(L, height);
    return 1;
}

static int lobject_set_boundary(lua_State* L)
{
    struct lobject* cell = lobject_check(L, 1);
    lua_len(L, 2);
    size_t len = lua_tointeger(L, -1);
    lua_pop(L, 1);
    struct vector* boundary = vector_create(4, point_destroy);
    for(unsigned int i = 1; i <= len; ++i)
    {
        lua_rawgeti(L, 2, i);
        struct lpoint* pt = lpoint_checkpoint(L, -1);
        vector_append(boundary, point_copy(lpoint_get(pt)));
        lua_pop(L, 1);
    }
    object_set_boundary(lobject_get(cell), boundary);
    return 0;
}

static int lobject_set_boundary_rectangular(lua_State* L)
{
    struct lobject* cell = lobject_check(L, 1);
    if(lua_gettop(L) == 3)
    {
        struct vector* boundary = vector_create(4, point_destroy);
        struct lpoint* bl = lpoint_checkpoint(L, 2);
        struct lpoint* tr = lpoint_checkpoint(L, 3);
        vector_append(boundary, point_create(lpoint_get(bl)->x, lpoint_get(bl)->y));
        vector_append(boundary, point_create(lpoint_get(tr)->x, lpoint_get(bl)->y));
        vector_append(boundary, point_create(lpoint_get(tr)->x, lpoint_get(tr)->y));
        vector_append(boundary, point_create(lpoint_get(bl)->x, lpoint_get(tr)->y));
        object_set_boundary(lobject_get(cell), boundary);
    }
    else
    {
        lua_pushfstring(L, "object.set_boundary_rectangular: expected 2 points or 4 points, got %d", lua_gettop(L) - 1);
        lua_error(L);
    }
    return 0;
}

static int lobject_set_empty_layer_boundary(lua_State* L)
{
    struct lobject* cell = lobject_check(L, 1);
    const struct generics* layer = lua_touserdata(L, 2);
    object_set_empty_layer_boundary(lobject_get(cell), layer);
    return 0;
}

static int lobject_add_layer_boundary(lua_State* L)
{
    struct lobject* cell = lobject_check(L, 1);
    const struct generics* layer = lua_touserdata(L, 2);
    lua_len(L, 3);
    size_t len = lua_tointeger(L, -1);
    lua_pop(L, 1);
    struct simple_polygon* boundary = simple_polygon_create();
    for(unsigned int i = 1; i <= len; ++i)
    {
        lua_rawgeti(L, 3, i);
        struct lpoint* pt = lpoint_checkpoint(L, -1);
        simple_polygon_append(boundary, point_copy(lpoint_get(pt)));
        lua_pop(L, 1);
    }
    object_add_layer_boundary(lobject_get(cell), layer, boundary);
    return 0;
}

static int lobject_add_layer_boundary_rectangular(lua_State* L)
{
    struct lobject* cell = lobject_check(L, 1);
    const struct generics* layer = lua_touserdata(L, 2);
    if(lua_gettop(L) == 4)
    {
        struct simple_polygon* boundary = simple_polygon_create();
        struct lpoint* bl = lpoint_checkpoint(L, 3);
        struct lpoint* tr = lpoint_checkpoint(L, 4);
        simple_polygon_append(boundary, point_create(lpoint_get(bl)->x, lpoint_get(bl)->y));
        simple_polygon_append(boundary, point_create(lpoint_get(tr)->x, lpoint_get(bl)->y));
        simple_polygon_append(boundary, point_create(lpoint_get(tr)->x, lpoint_get(tr)->y));
        simple_polygon_append(boundary, point_create(lpoint_get(bl)->x, lpoint_get(tr)->y));
        object_add_layer_boundary(lobject_get(cell), layer, boundary);
    }
    else
    {
        lua_pushfstring(L, "object.set_boundary_rectangular: expected 2 points or 4 points, got %d", lua_gettop(L) - 1);
        lua_error(L);
    }
    return 0;
}

static int lobject_inherit_boundary(lua_State* L)
{
    struct lobject* cell = lobject_check(L, 1);
    struct lobject* other = lobject_check(L, 2);
    object_inherit_boundary(lobject_get(cell), lobject_get(other));
    return 0;
}

static int lobject_has_boundary(lua_State* L)
{
    struct lobject* cell = lobject_check(L, 1);
    lua_pushboolean(L, object_has_boundary(lobject_get(cell)));
    return 1;
}

static int lobject_get_boundary(lua_State* L)
{
    struct lobject* cell = lobject_check(L, 1);
    struct vector* boundary = object_get_boundary(lobject_get(cell));
    lua_newtable(L);
    int i = 1;
    struct vector_iterator* it = vector_iterator_create(boundary);
    while(vector_iterator_is_valid(it))
    {
        const point_t* pt = vector_iterator_get(it);
        lpoint_create_internal(L, pt->x, pt->y);
        lua_rawseti(L, -2, i);
        vector_iterator_next(it);
        ++i;
    }
    vector_iterator_destroy(it);
    vector_destroy(boundary);
    return 1;
}

static int lobject_has_layer_boundary(lua_State* L)
{
    struct lobject* cell = lobject_check(L, 1);
    const struct generics* layer = lua_touserdata(L, 2);
    lua_pushboolean(L, object_has_layer_boundary(lobject_get(cell), layer));
    return 1;
}

static int lobject_get_layer_boundary(lua_State* L)
{
    struct lobject* cell = lobject_check(L, 1);
    const struct generics* layer = lua_touserdata(L, 2);
    struct polygon* boundary = object_get_layer_boundary(lobject_get(cell), layer);
    lua_newtable(L);
    if(polygon_is_empty(boundary))
    {
        polygon_destroy(boundary);
        return 1; // return empty table
    }
    struct polygon_iterator* pit = polygon_iterator_create(boundary);
    int i = 1;
    while(polygon_iterator_is_valid(pit))
    {
        struct simple_polygon* single_boundary = polygon_iterator_get(pit);
        struct simple_polygon_iterator* it = simple_polygon_iterator_create(single_boundary);
        lua_newtable(L);
        int j = 1;
        while(simple_polygon_iterator_is_valid(it))
        {
            const point_t* pt = simple_polygon_iterator_get(it);
            lpoint_create_internal(L, pt->x, pt->y);
            lua_rawseti(L, -2, j);
            simple_polygon_iterator_next(it);
            ++j;
        }
        simple_polygon_iterator_destroy(it);
        lua_rawseti(L, -2, i);
        ++i;
        polygon_iterator_next(pit);
    }
    polygon_iterator_destroy(pit);
    polygon_destroy(boundary);
    return 1;
}

int open_lobject_lib(lua_State* L)
{
    // create metatable for objects
    luaL_newmetatable(L, LOBJECTMODULE);

    // set methods
    static const luaL_Reg metafuncs[] =
    {
        { "create",                                 lobject_create                              },
        { "create_pseudo",                          lobject_create_pseudo                       },
        { "copy",                                   lobject_copy                                },
        { "exchange",                               lobject_exchange                            },
        { "get_name",                               lobject_get_name                            },
        { "set_name",                               lobject_set_name                            },
        { "add_anchor",                             lobject_add_anchor                          },
        { "add_area_anchor_bltr",                   lobject_add_area_anchor_bltr                },
        { "inherit_area_anchor",                    lobject_inherit_area_anchor                 },
        { "inherit_area_anchor_as",                 lobject_inherit_area_anchor_as              },
        { "inherit_all_anchors_with_prefix",        lobject_inherit_all_anchors_with_prefix     },
        { "get_anchor",                             lobject_get_anchor                          },
        { "get_alignment_anchor",                   lobject_get_alignment_anchor                },
        { "get_area_anchor",                        lobject_get_area_anchor                     },
        { "get_array_anchor",                       lobject_get_array_anchor                    },
        { "get_array_area_anchor",                  lobject_get_array_area_anchor               },
        { "get_all_regular_anchors",                lobject_get_all_regular_anchors             },
        { "add_port",                               lobject_add_port                            },
        { "add_bus_port",                           lobject_add_bus_port                        },
        { "get_ports",                              lobject_get_ports                           },
        { "clear_alignment_box",                    lobject_clear_alignment_box                 },
        { "set_alignment_box",                      lobject_set_alignment_box                   },
        { "inherit_alignment_box",                  lobject_inherit_alignment_box               },
        { "extend_alignment_box",                   lobject_extend_alignment_box                },
        { "width_height_alignmentbox",              lobject_width_height_alignmentbox           },
        { "move_to",                                lobject_move_to                             },
        { "reset_translation",                      lobject_reset_translation                   },
        { "translate",                              lobject_translate                           },
        { "translate_x",                            lobject_translate_x                         },
        { "translate_y",                            lobject_translate_y                         },
        { "mirror_at_xaxis",                        lobject_mirror_at_xaxis                     },
        { "mirror_at_yaxis",                        lobject_mirror_at_yaxis                     },
        { "mirror_at_origin",                       lobject_mirror_at_origin                    },
        { "rotate_90_left",                         lobject_rotate_90_left                      },
        { "rotate_90_right",                        lobject_rotate_90_right                     },
        { "flipx",                                  lobject_flipx                               },
        { "flipy",                                  lobject_flipy                               },
        { "move_point",                             lobject_move_point                          },
        { "move_point_x",                           lobject_move_point_x                        },
        { "move_point_y",                           lobject_move_point_y                        },
        { "abut_left",                              lobject_abut_left                           },
        { "abut_right",                             lobject_abut_right                          },
        { "abut_top",                               lobject_abut_top                            },
        { "abut_bottom",                            lobject_abut_bottom                         },
        { "abut_left_origin",                       lobject_abut_left_origin                    },
        { "abut_right_origin",                      lobject_abut_right_origin                   },
        { "abut_top_origin",                        lobject_abut_top_origin                     },
        { "abut_bottom_origin",                     lobject_abut_bottom_origin                  },
        { "align_left",                             lobject_align_left                          },
        { "align_right",                            lobject_align_right                         },
        { "align_top",                              lobject_align_top                           },
        { "align_bottom",                           lobject_align_bottom                        },
        { "align_left_origin",                      lobject_align_left_origin                   },
        { "align_right_origin",                     lobject_align_right_origin                  },
        { "align_top_origin",                       lobject_align_top_origin                    },
        { "align_bottom_origin",                    lobject_align_bottom_origin                 },
        { "abut_area_anchor_left",                  lobject_abut_area_anchor_left               },
        { "abut_area_anchor_right",                 lobject_abut_area_anchor_right              },
        { "abut_area_anchor_top",                   lobject_abut_area_anchor_top                },
        { "abut_area_anchor_bottom",                lobject_abut_area_anchor_bottom             },
        { "align_area_anchor",                      lobject_align_area_anchor                   },
        { "align_area_anchor_x",                    lobject_align_area_anchor_x                 },
        { "align_area_anchor_left",                 lobject_align_area_anchor_left              },
        { "align_area_anchor_right",                lobject_align_area_anchor_right             },
        { "align_area_anchor_y",                    lobject_align_area_anchor_y                 },
        { "align_area_anchor_top",                  lobject_align_area_anchor_top               },
        { "align_area_anchor_bottom",               lobject_align_area_anchor_bottom            },
        { "add_child",                              lobject_add_child                           },
        { "add_child_array",                        lobject_add_child_array                     },
        { "merge_into",                             lobject_merge_into                          },
        { "flatten",                                lobject_flatten                             },
        { "flatten_inline",                         lobject_flatten_inline                      },
        { "rasterize_curves",                       lobject_rasterize_curves                    },
        { "get_area_anchor_width",                  lobject_get_area_anchor_width               },
        { "get_area_anchor_height",                 lobject_get_area_anchor_height              },
        { "set_boundary",                           lobject_set_boundary                        },
        { "set_boundary_rectangular",               lobject_set_boundary_rectangular            },
        { "set_empty_layer_boundary",               lobject_set_empty_layer_boundary            },
        { "add_layer_boundary",                     lobject_add_layer_boundary                  },
        { "add_layer_boundary_rectangular",         lobject_add_layer_boundary_rectangular      },
        { "inherit_boundary",                       lobject_inherit_boundary                    },
        { "has_boundary",                           lobject_has_boundary                        },
        { "get_boundary",                           lobject_get_boundary                        },
        { "has_layer_boundary",                     lobject_has_layer_boundary                  },
        { "get_layer_boundary",                     lobject_get_layer_boundary                  },
        { "__gc",                                   lobject_destroy                             },
        { "__tostring",                             lobject_tostring                            },
        { NULL,                                     NULL                                        }
    };
    luaL_setfuncs(L, metafuncs, 0);

    // add __index
    lua_pushstring(L, "__index");
    lua_pushvalue(L, -2); 
    lua_rawset(L, -3);

    lua_setglobal(L, LOBJECTMODULE);

    return 0;
}


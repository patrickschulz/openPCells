#include "lobject.h"

#include <stdlib.h>

#include "lua/lauxlib.h"

#include "bltrshape.h"
#include "geometry.h"
#include "lcheck.h"
#include "lpoint.h"
#include "technology.h"

struct lobject {
    struct object* object;
    // FIXME: is usable the same as destroy?
    int destroy;
    int usable;
};

static int lobject_tostring(lua_State* L)
{
    lcheck_check_numargs1(L, 1, "object.tostring");
    struct lobject* cell = lobject_check(L, 1);
    lua_pushfstring(L, "object: '%s' (%p)", object_get_name(cell->object), cell->object);
    return 1;
}

static struct lobject* _create(lua_State* L)
{
    struct lobject* cell = lua_newuserdata(L, sizeof(*cell));
    luaL_setmetatable(L, LOBJECTMODULE);
    cell->destroy = 0;
    cell->usable = 1;
    return cell;
}

int lobject_create(lua_State* L)
{
    lcheck_check_numargs1(L, 1, "object.create");
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
    lcheck_check_numargs1(L, 0, "object.create_pseudo");
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

struct object* lobject_get_unchecked(struct lobject* lobject)
{
    return lobject->object;
}

struct object* lobject_get(lua_State* L, struct lobject* lobject)
{
    if(!lobject->usable)
    {
        lua_pushstring(L, "trying to access unusable object (objects become inmutable after adding them as children)");
        lua_error(L);
    }
    return lobject_get_unchecked(lobject);
}

struct object* lobject_get_full(lua_State* L, struct lobject* lobject)
{
    if(!lobject->usable)
    {
        lua_pushstring(L, "trying to access unusable object (objects become inmutable after adding them as children)");
        lua_error(L);
    }
    lobject_check_proxy(L, lobject);
    return lobject_get_unchecked(lobject);
}

const struct object* lobject_get_const(struct lobject* lobject)
{
    return lobject_get_unchecked(lobject);
}

void lobject_check_proxy(lua_State* L, struct lobject* lobject)
{
    if(object_is_proxy(lobject->object))
    {
        lua_pushstring(L, "got a proxy object where a full object is required");
        lua_error(L);
    }
}

void lobject_disown(struct lobject* lobject)
{
    lobject->destroy = 0;
}

void lobject_mark_as_unusable(struct lobject* lobject)
{
    lobject->usable = 0;
}

static int lobject_copy(lua_State* L)
{
    lcheck_check_numargs1(L, 1, "object.copy");
    struct lobject* cell = lobject_check(L, 1);
    struct lobject* new = _create(L);
    new->object = object_copy(lobject_get_const(cell));
    new->destroy = 1;
    return 1;
}

static int lobject_exchange(lua_State* L)
{
    lcheck_check_numargs1(L, 2, "object.exchange");
    struct lobject* cell = lobject_check(L, 1);
    struct lobject* other = lobject_check(L, 2);
    struct object* old = cell->object;
    cell->object = other->object;
    object_set_name(cell->object, object_get_name(old));
    other->destroy = 0;
    object_destroy(old);
    return 1;
}

int lobject_is_object(lua_State* L, int idx)
{
    lcheck_check_numargs1(L, 1, "object.is_object");
    if(lua_type(L, idx) != LUA_TUSERDATA)
    {
        return 0;
    }
    lua_getmetatable(L, idx);
    if(lua_isnil(L, -1))
    {
        lua_pop(L, 1);
        return 0;
    }
    luaL_getmetatable(L, LOBJECTMODULE);
    int equal = lua_compare(L, -1, -2, LUA_OPEQ);
    lua_pop(L, 2);
    if(equal)
    {
        return 1;
    }
    return 0;
}

static int lobject_is_object_lua(lua_State* L)
{
    if(lua_gettop(L) != 1)
    {
        lua_pushstring(L, "object.is_object expects expects one argument");
        lua_error(L);
    }
    int islobject = lobject_is_object(L, 1);
    lua_pushboolean(L, islobject);
    return 1;
}

static int lobject_destroy(lua_State* L)
{
    struct lobject* cell = lobject_check(L, 1);
    if(cell->destroy)
    {
        object_destroy(lobject_get_unchecked(cell));
    }
    return 0;
}

static int lobject_get_name(lua_State* L)
{
    lcheck_check_numargs1(L, 1, "object.get_name");
    struct lobject* cell = lobject_check(L, 1);
    const char* name = object_get_name(lobject_get_const(cell));
    lua_pushstring(L, name);
    return 1;
}

static int lobject_set_name(lua_State* L)
{
    lcheck_check_numargs1(L, 2, "object.set_name");
    struct lobject* cell = lobject_check(L, 1);
    const char* newname = luaL_checkstring(L, 2);
    object_set_name(lobject_get(L, cell), newname);
    return 0;
}

static int lobject_move_to(lua_State* L)
{
    lcheck_check_numargs2(L, 2, 3, "object.move_to");
    int n = lua_gettop(L);
    struct lobject* cell = lobject_check(L, 1);
    if(n == 2)
    {
        struct lpoint* pt = lpoint_checkpoint(L, 2);
        coordinate_t x = lpoint_get(pt)->x;
        coordinate_t y = lpoint_get(pt)->y;
        object_move_to(lobject_get(L, cell), x, y);
        lua_rotate(L, 1, 1);
    }
    else
    {
        coordinate_t x = lpoint_checkcoordinate(L, 2, "x");
        coordinate_t y = lpoint_checkcoordinate(L, 3, "y");
        object_move_to(lobject_get(L, cell), x, y);
        lua_rotate(L, 1, 2);
    }
    return 1;
}

static int lobject_set_origin(lua_State* L)
{
    lcheck_check_numargs2(L, 2, 3, "object.set_origin");
    int n = lua_gettop(L);
    struct lobject* cell = lobject_check(L, 1);
    if(n == 2)
    {
        struct lpoint* pt = lpoint_checkpoint(L, 2);
        coordinate_t x = lpoint_get(pt)->x;
        coordinate_t y = lpoint_get(pt)->y;
        object_set_origin(lobject_get(L, cell), x, y);
        lua_rotate(L, 1, 1);
    }
    else
    {
        coordinate_t x = lpoint_checkcoordinate(L, 2, "x");
        coordinate_t y = lpoint_checkcoordinate(L, 3, "y");
        object_set_origin(lobject_get(L, cell), x, y);
        lua_rotate(L, 1, 2);
    }
    return 1;
}

static int lobject_reset_translation(lua_State* L)
{
    lcheck_check_numargs1(L, 1, "object.reset_translation");
    struct lobject* cell = lobject_check(L, 1);
    object_reset_translation(lobject_get(L, cell));
    return 1;
}

static int lobject_translate(lua_State* L)
{
    lcheck_check_numargs2(L, 2, 3, "object.translate");
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
        object_translate(lobject_get(L, cell), x, y);
        lua_rotate(L, 1, 1);
    }
    else
    {
        coordinate_t x = lpoint_checkcoordinate(L, 2, "x");
        coordinate_t y = lpoint_checkcoordinate(L, 3, "y");
        object_translate(lobject_get(L, cell), x, y);
        lua_rotate(L, 1, 2);
    }
    return 1;
}

static int lobject_translate_x(lua_State* L)
{
    lcheck_check_numargs1(L, 2, "object.translate_x");
    struct lobject* cell = lobject_check(L, 1);
    coordinate_t x = lpoint_checkcoordinate(L, 2, "x");
    object_translate_x(lobject_get(L, cell), x);
    lua_rotate(L, 1, 1);
    return 1;
}

static int lobject_translate_y(lua_State* L)
{
    lcheck_check_numargs1(L, 2, "object.translate_y");
    struct lobject* cell = lobject_check(L, 1);
    coordinate_t y = lpoint_checkcoordinate(L, 2, "y");
    object_translate_y(lobject_get(L, cell), y);
    lua_rotate(L, 1, 1);
    return 1;
}

static int lobject_mirror_at_xaxis(lua_State* L)
{
    lcheck_check_numargs1(L, 1, "object.mirror_at_xaxis");
    struct lobject* cell = lobject_check(L, 1);
    object_mirror_at_xaxis(lobject_get(L, cell));
    return 1;
}

static int lobject_mirror_at_yaxis(lua_State* L)
{
    lcheck_check_numargs1(L, 1, "object.mirror_at_yaxis");
    struct lobject* cell = lobject_check(L, 1);
    object_mirror_at_yaxis(lobject_get(L, cell));
    return 1;
}

static int lobject_mirror_at_origin(lua_State* L)
{
    lcheck_check_numargs1(L, 1, "object.mirror_at_origin");
    struct lobject* cell = lobject_check(L, 1);
    object_mirror_at_origin(lobject_get(L, cell));
    return 1;
}

static int lobject_rotate_90_left(lua_State* L)
{
    lcheck_check_numargs1(L, 1, "object.rotate_90_left");
    struct lobject* cell = lobject_check(L, 1);
    object_rotate_90_left(lobject_get(L, cell));
    return 1;
}

static int lobject_rotate_90_right(lua_State* L)
{
    lcheck_check_numargs1(L, 1, "object.rotate_90_right");
    struct lobject* cell = lobject_check(L, 1);
    object_rotate_90_right(lobject_get(L, cell));
    return 1;
}

static int lobject_array_rotate_90_left(lua_State* L)
{
    lcheck_check_numargs1(L, 1, "object.array_rotate_90_left");
    struct lobject* cell = lobject_check(L, 1);
    object_array_rotate_90_left(lobject_get(L, cell));
    return 1;
}

static int lobject_array_rotate_90_right(lua_State* L)
{
    lcheck_check_numargs1(L, 1, "object.array_rotate_90_right");
    struct lobject* cell = lobject_check(L, 1);
    object_array_rotate_90_right(lobject_get(L, cell));
    return 1;
}

static int lobject_flipx(lua_State* L)
{
    lcheck_check_numargs1(L, 1, "object.flipx");
    struct lobject* cell = lobject_check(L, 1);
    object_flipx(lobject_get(L, cell));
    return 1;
}

static int lobject_flipy(lua_State* L)
{
    lcheck_check_numargs1(L, 1, "object.flipy");
    struct lobject* cell = lobject_check(L, 1);
    object_flipy(lobject_get(L, cell));
    return 1;
}

static int lobject_move_x(lua_State* L)
{
    lcheck_check_numargs1(L, 3, "object.move_x");
    struct lobject* cell = lobject_check(L, 1);
    coordinate_t source = lpoint_checkcoordinate(L, 2, "source");
    coordinate_t target = lpoint_checkcoordinate(L, 3, "target");
    object_move_x(lobject_get(L, cell), source, target);
    lua_rotate(L, 1, 2);
    return 1;
}

static int lobject_move_y(lua_State* L)
{
    lcheck_check_numargs1(L, 3, "object.move_y");
    struct lobject* cell = lobject_check(L, 1);
    coordinate_t source = lpoint_checkcoordinate(L, 2, "source");
    coordinate_t target = lpoint_checkcoordinate(L, 3, "target");
    object_move_y(lobject_get(L, cell), source, target);
    lua_rotate(L, 1, 2);
    return 1;
}

static int lobject_move_point(lua_State* L)
{
    lcheck_check_numargs1(L, 3, "object.move_point");
    struct lobject* cell = lobject_check(L, 1);
    struct lpoint* source = lpoint_checkpoint(L, 2);
    struct lpoint* target = lpoint_checkpoint(L, 3);
    object_move_point(lobject_get(L, cell), lpoint_get(source), lpoint_get(target));
    lua_rotate(L, 1, 2);
    return 1;
}

static int lobject_move_point_x(lua_State* L)
{
    lcheck_check_numargs1(L, 3, "object.move_point_x");
    struct lobject* cell = lobject_check(L, 1);
    struct lpoint* source = lpoint_checkpoint(L, 2);
    struct lpoint* target = lpoint_checkpoint(L, 3);
    object_move_point_x(lobject_get(L, cell), lpoint_get(source), lpoint_get(target));
    lua_rotate(L, 1, 2);
    return 1;
}

static int lobject_move_point_y(lua_State* L)
{
    lcheck_check_numargs1(L, 3, "object.move_point_y");
    struct lobject* cell = lobject_check(L, 1);
    struct lpoint* source = lpoint_checkpoint(L, 2);
    struct lpoint* target = lpoint_checkpoint(L, 3);
    object_move_point_y(lobject_get(L, cell), lpoint_get(source), lpoint_get(target));
    lua_rotate(L, 1, 2);
    return 1;
}

static int lobject_center(lua_State* L)
{
    lcheck_check_numargs2(L, 1, 2, "object.center");
    struct lobject* cell = lobject_check(L, 1);
    const struct point* origin = NULL;
    if(lua_gettop(L) == 2)
    {
        struct lpoint* pt = lpoint_checkpoint(L, 2);
        origin = lpoint_get(pt);
        lua_rotate(L, 1, 1);
    }
    object_center(lobject_get(L, cell), origin);
    return 1;
}

static int lobject_center_x(lua_State* L)
{
    lcheck_check_numargs2(L, 1, 2, "object.center_x");
    struct lobject* cell = lobject_check(L, 1);
    const struct point* origin = NULL;
    if(lua_gettop(L) == 2)
    {
        struct lpoint* pt = lpoint_checkpoint(L, 2);
        origin = lpoint_get(pt);
        lua_rotate(L, 1, 1);
    }
    object_center_x(lobject_get(L, cell), origin);
    return 1;
}

static int lobject_center_y(lua_State* L)
{
    lcheck_check_numargs2(L, 1, 2, "object.center_y");
    struct lobject* cell = lobject_check(L, 1);
    const struct point* origin = NULL;
    if(lua_gettop(L) == 2)
    {
        struct lpoint* pt = lpoint_checkpoint(L, 2);
        origin = lpoint_get(pt);
        lua_rotate(L, 1, 1);
    }
    object_center_y(lobject_get(L, cell), origin);
    return 1;
}

#define _gen_fun_abut_align(what) \
static int lobject_ ##what (lua_State* L) \
{ \
    lcheck_check_numargs1(L, 2, "object." #what); \
    struct lobject* cell = lobject_check(L, 1); \
    if(!object_has_alignmentbox(lobject_get(L, cell))) \
    { \
        const char* name = object_get_name(lobject_get(L, cell)); \
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
    if(lua_type(L, 2) == LUA_TTABLE) \
    { \
        lua_getfield(L, 2, "bl"); \
        struct lpoint* bl = lpoint_checkpoint(L, -1); \
        lua_pop(L, 1); \
        lua_getfield(L, 2, "tr"); \
        struct lpoint* tr = lpoint_checkpoint(L, -1); \
        lua_pop(L, 1); \
        object_ ## what ## _bltr (lobject_get(L, cell), lpoint_get(bl), lpoint_get(tr)); \
    } \
    else \
    { \
        struct lobject* other = lobject_check(L, 2); \
        if(!object_has_alignmentbox(lobject_get_const(other))) \
        { \
            lua_pushstring(L, "object." #what ": second object does not have an alignment box"); \
            lua_error(L); \
        } \
        object_ ##what (lobject_get(L, cell), lobject_get_const(other)); \
    } \
    return 1; \
}

#define _gen_fun_place(what) \
static int lobject_ ##what (lua_State* L) \
{ \
    lcheck_check_numargs1(L, 2, "object." #what); \
    struct lobject* cell = lobject_check(L, 1); \
    if(lua_type(L, 2) == LUA_TTABLE) \
    { \
        lua_getfield(L, 2, "bl"); \
        struct lpoint* bl = lpoint_checkpoint(L, -1); \
        lua_pop(L, 1); \
        lua_getfield(L, 2, "tr"); \
        struct lpoint* tr = lpoint_checkpoint(L, -1); \
        lua_pop(L, 1); \
        object_ ## what ## _bltr (lobject_get(L, cell), lpoint_get(bl), lpoint_get(tr)); \
    } \
    else \
    { \
        struct lobject* other = lobject_check(L, 2); \
        object_ ##what (lobject_get(L, cell), lobject_get_const(other)); \
    } \
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
_gen_fun_abut_align(align_center_x)
_gen_fun_abut_align(align_center_y)
_gen_fun_place(place_left)
_gen_fun_place(place_right)
_gen_fun_place(place_top)
_gen_fun_place(place_bottom)

#define _gen_fun_align_origin(what) \
static int lobject_ ##what (lua_State* L) \
{ \
    lcheck_check_numargs1(L, 1, "object." #what); \
    struct lobject* cell = lobject_check(L, 1); \
    if(!object_has_alignmentbox(lobject_get(L, cell))) \
    { \
        const char* name = object_get_name(lobject_get(L, cell)); \
        if(name) \
        { \
            lua_pushfstring(L, "object." #what ": object ('%s') does not have an alignment box", name); \
        } \
        else \
        { \
            lua_pushstring(L, "object." #what ": object does not have an alignment box"); \
        } \
        lua_error(L); \
    } \
    object_ ##what (lobject_get(L, cell)); \
    return 1; \
}

#define _gen_fun_place_origin(what) \
static int lobject_ ##what (lua_State* L) \
{ \
    lcheck_check_numargs1(L, 1, "object." #what); \
    struct lobject* cell = lobject_check(L, 1); \
    object_ ##what (lobject_get(L, cell)); \
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
_gen_fun_place_origin(place_left_origin)
_gen_fun_place_origin(place_right_origin)
_gen_fun_place_origin(place_top_origin)
_gen_fun_place_origin(place_bottom_origin)

#define _gen_fun_abut_align_area_anchor(what) \
static int lobject_ ##what (lua_State* L) \
{ \
    lcheck_check_numargs1(L, 4, "object." #what); \
    struct lobject* cell = lobject_check(L, 1); \
    const char* anchorname = luaL_checkstring(L, 2); \
    if(!object_has_area_anchor(lobject_get(L, cell), anchorname)) \
    { \
        const char* name = object_get_name(lobject_get(L, cell)); \
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
    if(!object_has_area_anchor(lobject_get_const(other), otheranchorname)) \
    { \
        lua_pushfstring(L, "object." #what ": second object does not have an anchor '%s'", otheranchorname); \
        lua_error(L); \
    } \
    object_ ##what (lobject_get(L, cell), anchorname, lobject_get_const(other), otheranchorname); \
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
    lcheck_check_numargs1(L, 4, "object.align_area_anchor");
    struct lobject* cell = lobject_check(L, 1);
    const char* anchorname = luaL_checkstring(L, 2);
    if(!object_has_area_anchor(lobject_get(L, cell), anchorname))
    {
        const char* name = object_get_name(lobject_get(L, cell));
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
    if(!object_has_area_anchor(lobject_get_const(other), otheranchorname))
    {
        lua_pushfstring(L, "object.align_area_anchor: second object does not have an anchor '%s'", otheranchorname);
        lua_error(L);
    }
    if(!object_area_anchors_fit(lobject_get(L, cell), anchorname, lobject_get_const(other), otheranchorname))
    {
        coordinate_t w1 = object_get_area_anchor_width(lobject_get(L, cell), anchorname);
        coordinate_t h1 = object_get_area_anchor_height(lobject_get(L, cell), anchorname);
        coordinate_t w2 = object_get_area_anchor_width(lobject_get(L, other), otheranchorname);
        coordinate_t h2 = object_get_area_anchor_height(lobject_get(L, other), otheranchorname);
        lua_pushfstring(L, "object.align_area_anchor: area anchors do not fit (have the same size): (%d x %d) vs. (%d x %d)", w1, h1, w2, h2);
        lua_error(L);
    }
    object_align_area_anchor(lobject_get(L, cell), anchorname, lobject_get_const(other), otheranchorname);
    return 1;
}

static int lobject_create_object_handle(lua_State* L)
{
    lcheck_check_numargs1(L, 2, "object.create_object_handle");
    struct lobject* cell = lobject_check(L, 1);
    struct lobject* reference = lobject_check(L, 2);
    // use lobject_get_unchecked for reference instead of lobject_get, as this function needs non-constant objects but can be called on objects there were already added as children
    struct object* o_reference = lobject_get_unchecked(reference);
    if(object_is_proxy(o_reference))
    {
        lua_pushstring(L, "object.create_object_handle: can't add proxy objects, only full objects");
        lua_error(L);
    }
    struct object* handle = object_create_handle(lobject_get(L, cell), lobject_get(L, reference));
    lobject_adapt_non_owning(L, handle);
    lobject_disown(reference); // memory is now handled by cell
    lobject_mark_as_unusable(reference);
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
    // use lobject_get_unchecked for child instead of lobject_get, as this function needs non-constant objects but can be called on objects there were already added as children
    struct object* o_child = lobject_get_unchecked(child);
    if(object_is_proxy(o_child))
    {
        lua_pushstring(L, "object.add_child: can't add proxy objects, only full objects");
        lua_error(L);
    }
    const char* name = NULL;
    if(lua_isstring(L, 3))
    {
        name = lua_tostring(L, 3);
    }
    struct object* proxy = object_add_child(lobject_get(L, cell), lobject_get_unchecked(child), name);
    if(!proxy)
    {
        lua_pushstring(L, "object.add_child: can't add pseudo objects");
        lua_error(L);
    }
    lobject_adapt_non_owning(L, proxy);
    lobject_disown(child); // memory is now handled by cell
    lobject_mark_as_unusable(child);
    return 1;
}

static int lobject_add_child_array(lua_State* L)
{
    struct lobject* cell = lobject_check(L, 1);
    struct lobject* child = lobject_check(L, 2);
    // use lobject_get_unchecked for child instead of lobject_get, as this function needs non-constant objects but can be called on objects there were already added as children
    struct object* o_child = lobject_get_unchecked(child);
    if(object_is_proxy(o_child))
    {
        lua_pushstring(L, "object.add_child_array: can't add proxy objects, only full objects");
        lua_error(L);
    }
    const char* name = luaL_checkstring(L, 3);
    unsigned xrep = luaL_checkinteger(L, 4);
    unsigned yrep = luaL_checkinteger(L, 5);
    ucoordinate_t xpitch;
    ucoordinate_t ypitch;
    if(lua_gettop(L) < 7) // no-pitch mode
    {
        if(!object_has_alignmentbox(lobject_get_const(child)))
        {
            lua_pushfstring(L, "add_child_array: no-pitch mode, but object '%s' has no alignmentbox", object_get_name(lobject_get_const(child)));
            lua_error(L);
        }
        object_width_height_alignmentbox(lobject_get_const(child), &xpitch, &ypitch);
    }
    else
    {
        xpitch = luaL_checkinteger(L, 6);
        ypitch = luaL_checkinteger(L, 7);
    }
    // use lobject_get_unchecked for child instead of lobject_get, as this function needs non-constant objects but can be called on objects there were already added as children
    struct object* proxy = object_add_child_array(lobject_get(L, cell), lobject_get_unchecked(child), name, xrep, yrep, xpitch, ypitch);
    if(!proxy)
    {
        lua_pushstring(L, "object.add_child_array: can't add pseudo objects");
        lua_error(L);
    }
    lobject_adapt_non_owning(L, proxy);
    lobject_disown(child); // memory is now handled by cell
    lobject_mark_as_unusable(child);
    return 1;
}

static int lobject_width_height_alignmentbox(lua_State* L)
{
    lcheck_check_numargs1(L, 1, "object.width_height_alignmentbox");
    struct lobject* cell = lobject_check(L, 1);
    if(!object_has_alignmentbox(lobject_get_const(cell)))
    {
        lua_pushstring(L, "object.width_height_alignmentbox: cell has no alignmentbox");
        lua_error(L);
    }
    ucoordinate_t width;
    ucoordinate_t height;
    object_width_height_alignmentbox(lobject_get_const(cell), &width, &height);
    lua_pushinteger(L, width);
    lua_pushinteger(L, height);
    return 2;
}

static int lobject_merge_into(lua_State* L)
{
    lcheck_check_numargs1(L, 2, "object.merge_into");
    struct lobject* cell = lobject_check(L, 1);
    struct lobject* other = lobject_check(L, 2);
    object_merge_into(lobject_get(L, cell), lobject_get_const(other));
    return 0;
}

static int lobject_merge_into_with_ports(lua_State* L)
{
    lcheck_check_numargs1(L, 2, "object.merge_into_with_ports");
    struct lobject* cell = lobject_check(L, 1);
    struct lobject* other = lobject_check(L, 2);
    object_merge_into_with_ports(lobject_get(L, cell), lobject_get_const(other));
    return 0;
}

static int lobject_add_anchor(lua_State* L)
{
    lcheck_check_numargs1(L, 3, "object.add_anchor");
    struct lobject* cell = lobject_check(L, 1);
    const char* name = luaL_checkstring(L, 2);
    struct lpoint* lpoint = lpoint_checkpoint(L, 3);
    int ret = object_add_anchor(lobject_get(L, cell), name, lpoint_get(lpoint)->x, lpoint_get(lpoint)->y);
    if(!ret)
    {
        lua_pushfstring(L, "object.add_anchor: could not add anchor '%s' as it already exists", name);
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

static int lobject_inherit_anchor(lua_State* L)
{
    lcheck_check_numargs1(L, 3, "object.inherit_anchor");
    struct lobject* cell = lobject_check(L, 1);
    struct lobject* other = lobject_check(L, 2);
    const char* anchorname = luaL_checkstring(L, 3);
    if(!object_has_anchor(lobject_get_const(other), anchorname))
    {
        lua_pushfstring(L, "object.inherit_anchor: object does not have an anchor '%s'", anchorname);
        lua_error(L);
    }
    object_inherit_anchor(lobject_get(L, cell), lobject_get_const(other), anchorname);
    return 0;
}

static int lobject_inherit_anchor_as(lua_State* L)
{
    lcheck_check_numargs1(L, 4, "object.inherit_anchor_as");
    struct lobject* cell = lobject_check(L, 1);
    struct lobject* other = lobject_check(L, 2);
    const char* anchorname = luaL_checkstring(L, 3);
    const char* newanchorname = luaL_checkstring(L, 4);
    if(!object_has_anchor(lobject_get_const(other), anchorname))
    {
        lua_pushfstring(L, "object.inherit_anchor_as: object does not have an anchor '%s'", anchorname);
        lua_error(L);
    }
    int ret = object_inherit_anchor_as(lobject_get(L, cell), lobject_get_const(other), anchorname, newanchorname);
    if(!ret)
    {
        lua_pushfstring(L, "object.inherit_anchor_as: could not inherit anchor '%s'", anchorname);
        lua_error(L);
    }
    return 0;
}

static int lobject_add_area_anchor_bltr(lua_State* L)
{
    lcheck_check_numargs1(L, 4, "object.add_area_anchor_bltr");
    struct lobject* cell = lobject_check(L, 1);
    const char* base = luaL_checkstring(L, 2);
    struct lpoint* bl = lpoint_checkpoint(L, 3);
    struct lpoint* tr = lpoint_checkpoint(L, 4);
    _check_rectangle_points(L, bl, tr, "object.add_area_anchor_bltr");
    object_add_area_anchor_bltr(lobject_get(L, cell), base, lpoint_get(bl), lpoint_get(tr));
    return 0;
}

static int lobject_add_area_anchor_points(lua_State* L)
{
    lcheck_check_numargs1(L, 4, "object.add_area_anchor_points");
    struct lobject* cell = lobject_check(L, 1);
    const char* base = luaL_checkstring(L, 2);
    struct lpoint* pt1 = lpoint_checkpoint(L, 3);
    struct lpoint* pt2 = lpoint_checkpoint(L, 4);
    object_add_area_anchor_points(lobject_get(L, cell), base, lpoint_get(pt1), lpoint_get(pt2));
    return 0;
}

static int lobject_add_area_anchor_blwh(lua_State* L)
{
    lcheck_check_numargs1(L, 5, "object.add_area_anchor_blwh");
    struct lobject* cell = lobject_check(L, 1);
    const char* base = luaL_checkstring(L, 2);
    struct lpoint* pt1 = lpoint_checkpoint(L, 3);
    coordinate_t width = lpoint_checkcoordinate(L, 4, "width");
    coordinate_t height = lpoint_checkcoordinate(L, 5, "height");
    object_add_area_anchor_blwh(lobject_get(L, cell), base, lpoint_get(pt1), width, height);
    return 0;
}

static int lobject_add_anchor_line_x(lua_State* L)
{
    lcheck_check_numargs1(L, 3, "object.add_anchor_line_x");
    struct lobject* cell = lobject_check(L, 1);
    const char* name = luaL_checkstring(L, 2);
    coordinate_t x = lpoint_checkcoordinate(L, 3, "x");
    object_add_anchor_line_x(lobject_get(L, cell), name, x);
    return 0;
}

static int lobject_add_anchor_line_y(lua_State* L)
{
    lcheck_check_numargs1(L, 3, "object.add_anchor_line_y");
    struct lobject* cell = lobject_check(L, 1);
    const char* name = luaL_checkstring(L, 2);
    coordinate_t y = lpoint_checkcoordinate(L, 3, "y");
    object_add_anchor_line_y(lobject_get(L, cell), name, y);
    return 0;
}

static int lobject_inherit_area_anchor(lua_State* L)
{
    lcheck_check_numargs1(L, 3, "object.inherit_area_anchor");
    struct lobject* cell = lobject_check(L, 1);
    struct lobject* other = lobject_check(L, 2);
    const char* anchorname = luaL_checkstring(L, 3);
    if(!object_has_area_anchor(lobject_get_const(other), anchorname))
    {
        lua_pushfstring(L, "object.inherit_area_anchor: object does not have an area anchor '%s'", anchorname);
        lua_error(L);
    }
    object_inherit_area_anchor(lobject_get(L, cell), lobject_get_const(other), anchorname);
    return 0;
}

static int lobject_inherit_area_anchor_as(lua_State* L)
{
    lcheck_check_numargs1(L, 4, "object.inherit_area_anchor_as");
    struct lobject* cell = lobject_check(L, 1);
    struct lobject* other = lobject_check(L, 2);
    const char* anchorname = luaL_checkstring(L, 3);
    const char* newanchorname = luaL_checkstring(L, 4);
    if(!object_has_area_anchor(lobject_get_const(other), anchorname))
    {
        lua_pushfstring(L, "object.inherit_area_anchor_as: object does not have an area anchor '%s'", anchorname);
        lua_error(L);
    }
    object_inherit_area_anchor_as(lobject_get(L, cell), lobject_get_const(other), anchorname, newanchorname);
    return 0;
}

static int lobject_inherit_all_anchors(lua_State* L)
{
    lcheck_check_numargs1(L, 2, "object.inherit_all_anchors");
    struct lobject* cell = lobject_check(L, 1);
    struct lobject* other = lobject_check(L, 2);
    object_inherit_all_anchors(lobject_get(L, cell), lobject_get_const(other));
    return 0;
}

static int lobject_inherit_all_anchors_with_prefix(lua_State* L)
{
    lcheck_check_numargs1(L, 3, "object.inherit_all_anchors_with_prefix");
    struct lobject* cell = lobject_check(L, 1);
    struct lobject* other = lobject_check(L, 2);
    const char* prefix = luaL_checkstring(L, 3);
    object_inherit_all_anchors_with_prefix(lobject_get(L, cell), lobject_get_const(other), prefix);
    return 0;
}

static int lobject_get_anchor(lua_State* L)
{
    lcheck_check_numargs1(L, 2, "object.get_anchor");
    struct lobject* cell = lobject_check(L, 1);
    const char* name = luaL_checkstring(L, 2);
    struct point* point = object_get_anchor(lobject_get_const(cell), name);
    if(point)
    {
        lpoint_takeover_point(L, point);
    }
    else
    {
        lua_pushfstring(L, "trying to access undefined anchor '%s' (object: '%s')", name, object_get_name(lobject_get_const(cell)));
        lua_error(L);
    }
    return 1;
}

static int lobject_get_alignment_anchor(lua_State* L)
{
    lcheck_check_numargs1(L, 2, "object.get_alignment_anchor");
    struct lobject* cell = lobject_check(L, 1);
    if(!object_has_alignmentbox(lobject_get_const(cell)))
    {
        lua_pushfstring(L, "object.get_alignment_anchor: object '%s' has no alignment box", object_get_name(lobject_get_const(cell)));
        lua_error(L);
    }
    const char* name = luaL_checkstring(L, 2);
    // FIXME: check that name is a valid identifier
    struct point* point = object_get_alignment_anchor(lobject_get_const(cell), name);
    if(point)
    {
        lpoint_takeover_point(L, point);
    }
    else
    {
        lua_pushfstring(L, "trying to access undefined alignment anchor '%s' (object: '%s')", name, object_get_name(lobject_get_const(cell)));
        lua_error(L);
    }
    return 1;
}

static int _area_anchor_index_func(lua_State* L)
{
    lua_pushstring(L, "_name");
    lua_rawget(L, 1);
    const char* name = luaL_checkstring(L, -1);
    lua_pop(L, 1);
    const char* key = luaL_checkstring(L, 2);
    if(name)
    {
        lua_pushfstring(L, "area anchor '%s': trying to access undefined sub-anchor '%s'. Possible sub-anchors are 'bl', 'br', 'tl' and 'tr' as well as scalar values 'b', 't', 'l' and 'r'", name, key);
    }
    else
    {
        lua_pushfstring(L, "area anchor: trying to access undefined sub-anchor '%s'. Possible sub-anchors are 'bl', 'br', 'tl' and 'tr' as well as scalar values 'b', 't', 'l' and 'r'", key);
    }
    lua_error(L);
    return 0;
}

static void _get_area_anchor(lua_State* L, const struct object* cell, const char* base)
{
    if(luaL_newmetatable(L, "areaanchor"))
    {
        lua_pushcfunction(L, _area_anchor_index_func);
        lua_setfield(L, -2, "__index");
    }
    lua_pop(L, 1); // pop meta table
    struct point* pts = object_get_area_anchor(cell, base);
    if(pts)
    {
        lua_newtable(L);
        lua_pushstring(L, base);
        lua_setfield(L, -2, "_name");
        lpoint_create_internal_xy(L, pts[0].x, pts[0].y);
        lua_setfield(L, -2, "bl");
        lpoint_create_internal_xy(L, pts[1].x, pts[0].y);
        lua_setfield(L, -2, "br");
        lpoint_create_internal_xy(L, pts[1].x, pts[1].y);
        lua_setfield(L, -2, "tr");
        lpoint_create_internal_xy(L, pts[0].x, pts[1].y);
        lua_setfield(L, -2, "tl");
        // skalar values
        lua_pushinteger(L, pts[0].x);
        lua_setfield(L, -2, "l");
        lua_pushinteger(L, pts[0].y);
        lua_setfield(L, -2, "b");
        lua_pushinteger(L, pts[1].x);
        lua_setfield(L, -2, "r");
        lua_pushinteger(L, pts[1].y);
        lua_setfield(L, -2, "t");
        free(pts);
        luaL_setmetatable(L, "areaanchor");
    }
    else
    {
        const char* name = object_get_name(cell);
        if(name)
        {
            lua_pushfstring(L, "trying to access undefined area anchor '%s' (object: '%s')", base, name);
            lua_error(L);
        }
        else
        {
            lua_pushfstring(L, "trying to access undefined area anchor '%s'", base);
            lua_error(L);
        }
    }
}

static int lobject_get_area_anchor(lua_State* L)
{
    lcheck_check_numargs1(L, 2, "object.get_area_anchor");
    struct lobject* cell = lobject_check(L, 1);
    const char* base = luaL_checkstring(L, 2);
    _get_area_anchor(L, lobject_get_const(cell), base);
    return 1;
}

static int lobject_get_area_anchor_fmt(lua_State* L)
{
    int num_args = lua_gettop(L) - 1;
    struct lobject* cell = lobject_check(L, 1);
    lua_getglobal(L, "string");
    lua_getfield(L, -1, "format");
    for(int n = 1; n <= num_args; ++n)
    {
        lua_pushvalue(L, n + 1);
    }
    lua_call(L, num_args, 1);
    const char* base = luaL_checkstring(L, -1);
    _get_area_anchor(L, lobject_get_const(cell), base);
    return 1;
}

static int lobject_get_array_anchor(lua_State* L)
{
    lcheck_check_numargs1(L, 4, "object.get_array_anchor");
    struct lobject* cell = lobject_check(L, 1);
    int xindex = luaL_checkinteger(L, 2);
    int yindex = luaL_checkinteger(L, 3);
    const char* name = luaL_checkstring(L, 4);
    struct point* point = object_get_array_anchor(lobject_get_const(cell), xindex, yindex, name);
    if(point)
    {
        lpoint_takeover_point(L, point);
    }
    else
    {
        lua_pushfstring(L, "trying to access undefined anchor '%s' (object: '%s')", name, object_get_name(lobject_get_const(cell)));
        lua_error(L);
    }
    return 1;
}

static int lobject_get_array_area_anchor(lua_State* L)
{
    lcheck_check_numargs1(L, 4, "object.get_array_area_anchor");
    lcheck_check_numargs1(L, 4, "object.get_array_area_anchor");
    struct lobject* cell = lobject_check(L, 1);
    int xindex = luaL_checkinteger(L, 2);
    int yindex = luaL_checkinteger(L, 3);
    const char* base = luaL_checkstring(L, 4);
    struct point* pts = object_get_array_area_anchor(lobject_get_const(cell), xindex - 1, yindex - 1, base);
    if(pts)
    {
        lua_newtable(L);
        lua_pushstring(L, base);
        lua_setfield(L, -2, "_name");
        lpoint_create_internal_xy(L, pts[0].x, pts[0].y);
        lua_setfield(L, -2, "bl");
        lpoint_create_internal_xy(L, pts[1].x, pts[0].y);
        lua_setfield(L, -2, "br");
        lpoint_create_internal_xy(L, pts[1].x, pts[1].y);
        lua_setfield(L, -2, "tr");
        lpoint_create_internal_xy(L, pts[0].x, pts[1].y);
        lua_setfield(L, -2, "tl");
        // skalar values
        lua_pushinteger(L, pts[0].x);
        lua_setfield(L, -2, "l");
        lua_pushinteger(L, pts[0].y);
        lua_setfield(L, -2, "b");
        lua_pushinteger(L, pts[1].x);
        lua_setfield(L, -2, "r");
        lua_pushinteger(L, pts[1].y);
        lua_setfield(L, -2, "t");
        free(pts);
        luaL_setmetatable(L, "areaanchor");
    }
    else
    {
        lua_pushfstring(L, "trying to access undefined array area anchor '%s (%d, %d)' (object: '%s')", base, xindex, yindex, object_get_name(lobject_get_const(cell)));
        lua_error(L);
    }
    return 1;
}

static int lobject_get_all_regular_anchors(lua_State* L)
{
    lcheck_check_numargs1(L, 1, "object.get_all_regular_anchors");
    struct lobject* cell = lobject_check(L, 1);
    const struct hashmap* anchors = object_get_all_regular_anchors(lobject_get_const(cell));
    struct hashmap_const_iterator* iterator = hashmap_const_iterator_create(anchors);
    lua_newtable(L);
    while(hashmap_const_iterator_is_valid(iterator))
    {
        const char* key = hashmap_const_iterator_key(iterator);
        const struct point* anchor = hashmap_const_iterator_value(iterator);
        struct point* pt = point_copy(anchor);
        lpoint_adapt_point(L, pt);
        lua_setfield(L, -2, key);
        hashmap_const_iterator_next(iterator);
    }
    hashmap_const_iterator_destroy(iterator);
    return 1;
}

static int lobject_get_anchor_line_x(lua_State* L)
{
    lcheck_check_numargs1(L, 2, "object.get_anchor_line_x");
    struct lobject* cell = lobject_check(L, 1);
    const char* name = luaL_checkstring(L, 2);
    coordinate_t* c = object_get_anchor_line_x(lobject_get(L, cell), name);
    if(c)
    {
        lua_pushinteger(L, *c);
    }
    else
    {
        lua_pushfstring(L, "trying to access an undefined anchor line '%s' (object: '%s')", name, object_get_name(lobject_get_const(cell)));
        lua_error(L);
    }
    return 1;
}

static int lobject_get_anchor_line_y(lua_State* L)
{
    lcheck_check_numargs1(L, 2, "object.get_anchor_line_y");
    struct lobject* cell = lobject_check(L, 1);
    const char* name = luaL_checkstring(L, 2);
    coordinate_t* c = object_get_anchor_line_y(lobject_get(L, cell), name);
    if(c)
    {
        lua_pushinteger(L, *c);
    }
    else
    {
        lua_pushfstring(L, "trying to access an undefined anchor line '%s' (object: '%s')", name, object_get_name(lobject_get_const(cell)));
        lua_error(L);
    }
    return 1;
}

static unsigned int _get_sizehint(lua_State* L, int index)
{
    lua_getfield(L, LUA_REGISTRYINDEX, "techstate");
    struct technology_state* techstate = lua_touserdata(L, -1);
    lua_pop(L, 1); // pop techstate
    unsigned int sizehint;
    if(lua_gettop(L) != index)
    {
        struct tagged_value* value = technology_get_dimension(techstate, "Default Label Size");
        if(value)
        {
            sizehint = tagged_value_get_integer(value);
        }
        else
        {
            sizehint = 0;
        }
    }
    else
    {
        sizehint = luaL_checkinteger(L, index);
    }
    return sizehint;
}

static int lobject_add_port(lua_State* L)
{
    lcheck_check_numargs2(L, 4, 5, "object.add_port");
    struct lobject* cell = lobject_check(L, 1);
    lobject_check_proxy(L, cell);
    const char* name = luaL_checkstring(L, 2);
    const struct generics* layer = lua_touserdata(L, 3);
    struct lpoint* lpoint = lpoint_checkpoint(L, 4);
    unsigned int sizehint = _get_sizehint(L, 5);
    object_add_port(lobject_get(L, cell), name, layer, lpoint_get(lpoint), sizehint);
    return 0;
}

static int lobject_add_port_with_anchor(lua_State* L)
{
    lcheck_check_numargs2(L, 4, 5, "object.add_port_with_anchor");
    struct lobject* cell = lobject_check(L, 1);
    lobject_check_proxy(L, cell);
    const char* name = luaL_checkstring(L, 2);
    const struct generics* layer = lua_touserdata(L, 3);
    struct lpoint* lpoint = lpoint_checkpoint(L, 4);
    unsigned int sizehint = _get_sizehint(L, 5);
    object_add_port(lobject_get(L, cell), name, layer, lpoint_get(lpoint), sizehint);
    object_add_anchor(lobject_get(L, cell), name, point_getx(lpoint_get(lpoint)), point_gety(lpoint_get(lpoint)));
    return 0;
}

static int lobject_add_bus_port(lua_State* L)
{
    lcheck_check_numargs2(L, 8, 9, "object.add_bus_port");
    struct lobject* cell = lobject_check(L, 1);
    const char* name = luaL_checkstring(L, 2);
    const struct generics* layer = lua_touserdata(L, 3);
    struct lpoint* lpoint = lpoint_checkpoint(L, 4);
    int startindex = luaL_checkinteger(L, 5);
    int endindex = luaL_checkinteger(L, 6);
    coordinate_t xpitch = lpoint_checkcoordinate(L, 7, "xpitch");
    coordinate_t ypitch = lpoint_checkcoordinate(L, 8, "ypitch");
    unsigned int sizehint = _get_sizehint(L, 9);
    object_add_bus_port(lobject_get(L, cell), name, layer, lpoint_get(lpoint), startindex, endindex, xpitch, ypitch, sizehint);
    return 0;
}

static int lobject_add_label(lua_State* L)
{
    lcheck_check_numargs2(L, 4, 5, "object.add_label");
    struct lobject* cell = lobject_check(L, 1);
    lobject_check_proxy(L, cell);
    const char* name = luaL_checkstring(L, 2);
    const struct generics* layer = lua_touserdata(L, 3);
    struct lpoint* lpoint = lpoint_checkpoint(L, 4);
    unsigned int sizehint = _get_sizehint(L, 5);
    object_add_label(lobject_get(L, cell), name, layer, lpoint_get(lpoint), sizehint);
    return 0;
}

static int lobject_get_ports(lua_State* L)
{
    lcheck_check_numargs1(L, 1, "object.get_ports");
    struct lobject* cell = lobject_check(L, 1);
    lua_newtable(L);
    struct port_iterator* it = object_create_port_iterator(lobject_get_const(cell));
    int i = 1;
    while(port_iterator_is_valid(it))
    {
        const char* portname;
        const struct point* portwhere;
        port_iterator_get(it, &portname, &portwhere, NULL, NULL, NULL, NULL);
        lua_newtable(L);
        lua_pushstring(L, portname);
        lua_setfield(L, -2, "name");
        lpoint_create_internal_xy(L, portwhere->x, portwhere->y);
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
    lcheck_check_numargs1(L, 1, "object.clear_alignment_box");
    struct lobject* cell = lobject_check(L, 1);
    if(!object_has_alignmentbox(lobject_get_const(cell)))
    {
        lua_pushfstring(L, "object.clear_alignment_box: object has no alignment box (object: '%s')", object_get_name(lobject_get_const(cell)));
        lua_error(L);
    }
    object_clear_alignment_box(lobject_get(L, cell));
    return 0;
}

static int lobject_set_alignment_box(lua_State* L)
{
    lcheck_check_numargs2(L, 3, 5, "object.set_alignment_box");
    struct lobject* cell = lobject_check(L, 1);
    if(object_has_alignmentbox(lobject_get_const(cell)))
    {
        lua_pushfstring(L, "object.set_alignment_box: object already has an alignment box (object: '%s')", object_get_name(lobject_get_const(cell)));
        lua_error(L);
    }
    if(lua_gettop(L) == 3)
    {
        struct lpoint* bl = lpoint_checkpoint(L, 2);
        struct lpoint* tr = lpoint_checkpoint(L, 3);
        object_set_alignment_box(
            lobject_get(L, cell),
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
            lobject_get(L, cell),
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
    lcheck_check_numargs1(L, 2, "object.inherit_alignment_box");
    struct lobject* cell = lobject_check(L, 1);
    struct lobject* other = lobject_check(L, 2);
    if(!object_has_alignmentbox(lobject_get_const(other)))
    {
        lua_pushfstring(L, "object.inherit_alignment_box: othercell has no alignmentbox (other object: '%s')", object_get_name(lobject_get_const(other)));
        lua_error(L);
    }
    object_inherit_alignment_box(lobject_get(L, cell), lobject_get_const(other));
    return 0;
}

static int lobject_alignment_box_include_point(lua_State* L)
{
    lcheck_check_numargs1(L, 2, "object.alignment_box_include_point");
    struct lobject* cell = lobject_check(L, 1);
    struct lpoint* pt = lpoint_checkpoint(L, 2);
    object_alignment_box_include_point(lobject_get(L, cell), lpoint_get(pt));
    return 0;
}

static int lobject_alignment_box_include_x(lua_State* L)
{
    lcheck_check_numargs1(L, 2, "object.alignment_box_include_x");
    struct lobject* cell = lobject_check(L, 1);
    struct lpoint* pt = lpoint_checkpoint(L, 2);
    object_alignment_box_include_x(lobject_get(L, cell), point_getx(lpoint_get(pt)));
    return 0;
}

static int lobject_alignment_box_include_y(lua_State* L)
{
    lcheck_check_numargs1(L, 2, "object.alignment_box_include_y");
    struct lobject* cell = lobject_check(L, 1);
    struct lpoint* pt = lpoint_checkpoint(L, 2);
    object_alignment_box_include_y(lobject_get(L, cell), point_gety(lpoint_get(pt)));
    return 0;
}

static int lobject_extend_alignment_box(lua_State* L)
{
    lcheck_check_numargs1(L, 9, "object.extend_alignment_box");
    struct lobject* cell = lobject_check(L, 1);
    coordinate_t extouterblx = lpoint_checkcoordinate(L, 2, "extouterblx");
    coordinate_t extouterbly = lpoint_checkcoordinate(L, 3, "extouterbly");
    coordinate_t extoutertrx = lpoint_checkcoordinate(L, 4, "extoutertrx");
    coordinate_t extoutertry = lpoint_checkcoordinate(L, 5, "extoutertry");
    coordinate_t extinnerblx = lpoint_checkcoordinate(L, 6, "extinnerblx");
    coordinate_t extinnerbly = lpoint_checkcoordinate(L, 7, "extinnerbly");
    coordinate_t extinnertrx = lpoint_checkcoordinate(L, 8, "extinnertrx");
    coordinate_t extinnertry = lpoint_checkcoordinate(L, 9, "extinnertry");
    if(!object_has_alignmentbox(lobject_get_const(cell)))
    {
        lua_pushfstring(L, "object.extend_alignment_box: cell has no alignmentbox (object: '%s')", object_get_name(lobject_get_const(cell)));
        lua_error(L);
    }
    object_extend_alignment_box(
        lobject_get(L, cell),
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
    lcheck_check_numargs1(L, 2, "object.extend_alignment_box_x_symmetrical");
    struct lobject* cell = lobject_check(L, 1);
    coordinate_t extx = lpoint_checkcoordinate(L, 2, "extx");
    if(!object_has_alignmentbox(lobject_get_const(cell)))
    {
        lua_pushfstring(L, "object.extend_alignment_box_x_symmetrical: cell has no alignmentbox (object: '%s')", object_get_name(lobject_get_const(cell)));
        lua_error(L);
    }
    object_extend_alignment_box(
        lobject_get(L, cell),
        -extx,
        0,
        extx,
        0,
        -extx,
        0,
        extx,
        0
    );
    return 0;
}

static int lobject_extend_alignment_box_y_symmetrical(lua_State* L)
{
    lcheck_check_numargs1(L, 2, "object.extend_alignment_box_y_symmetrical");
    struct lobject* cell = lobject_check(L, 1);
    coordinate_t exty = lpoint_checkcoordinate(L, 2, "exty");
    if(!object_has_alignmentbox(lobject_get_const(cell)))
    {
        lua_pushfstring(L, "object.extend_alignment_box_y_symmetrical: cell has no alignmentbox (object: '%s')", object_get_name(lobject_get_const(cell)));
        lua_error(L);
    }
    object_extend_alignment_box(
        lobject_get(L, cell),
        -exty,
        0,
        exty,
        0,
        -exty,
        0,
        exty,
        0
    );
    return 0;
}

static int lobject_extend_alignment_box_xy_symmetrical(lua_State* L)
{
    lcheck_check_numargs1(L, 3, "object.extend_alignment_box_xy_symmetrical");
    struct lobject* cell = lobject_check(L, 1);
    coordinate_t extx = lpoint_checkcoordinate(L, 2, "extx");
    coordinate_t exty = lpoint_checkcoordinate(L, 3, "exty");
    if(!object_has_alignmentbox(lobject_get_const(cell)))
    {
        lua_pushfstring(L, "object.extend_alignment_box_xy_symmetrical: cell has no alignmentbox (object: '%s')", object_get_name(lobject_get_const(cell)));
        lua_error(L);
    }
    object_extend_alignment_box(
        lobject_get(L, cell),
        -extx,
        -exty,
        extx,
        exty,
        -extx,
        -exty,
        extx,
        exty
    );
    return 0;
}

static int lobject_flatten(lua_State* L)
{
    lcheck_check_numargs2(L, 1, 2, "object.flatten");
    struct lobject* cell = lobject_check(L, 1);
    int flattenports = lua_toboolean(L, 2);
    struct object* obj = object_flatten(lobject_get(L, cell), flattenports);
    lobject_adapt_owning(L, obj);
    return 1;
}

static int lobject_flatten_inline(lua_State* L)
{
    lcheck_check_numargs2(L, 1, 2, "object.flatten_inline");
    struct lobject* cell = lobject_check(L, 1);
    int flattenports = lua_toboolean(L, 2);
    object_flatten_inline(lobject_get(L, cell), flattenports);
    return 1;
}

static int lobject_rasterize_curves(lua_State* L)
{
    lcheck_check_numargs1(L, 1, "object.rasterize_curves");
    struct lobject* cell = lobject_check(L, 1);
    object_rasterize_curves(lobject_get(L, cell));
    return 0;
}

static int lobject_get_area_anchor_width(lua_State* L)
{
    lcheck_check_numargs1(L, 2, "object.get_area_anchor_width");
    struct lobject* cell = lobject_check(L, 1);
    const char* anchorname = luaL_checkstring(L, 2);
    if(!object_has_area_anchor(lobject_get_const(cell), anchorname))
    {
        lua_pushfstring(L, "object.get_area_anchor_width: object does not have an area anchor '%s' (object: '%s')", anchorname, object_get_name(lobject_get_const(cell)));
        lua_error(L);
    }
    coordinate_t width = object_get_area_anchor_width(lobject_get_const(cell), anchorname);
    lua_pushinteger(L, width);
    return 1;
}

static int lobject_get_area_anchor_height(lua_State* L)
{
    lcheck_check_numargs1(L, 2, "object.get_area_anchor_height");
    struct lobject* cell = lobject_check(L, 1);
    const char* anchorname = luaL_checkstring(L, 2);
    if(!object_has_area_anchor(lobject_get_const(cell), anchorname))
    {
        lua_pushfstring(L, "object.get_area_anchor_height: object does not have an area anchor '%s' (object: '%s')", anchorname, object_get_name(lobject_get_const(cell)));
        lua_error(L);
    }
    coordinate_t height = object_get_area_anchor_height(lobject_get_const(cell), anchorname);
    lua_pushinteger(L, height);
    return 1;
}

static int lobject_set_boundary(lua_State* L)
{
    lcheck_check_numargs1(L, 2, "object.set_boundary");
    struct lobject* cell = lobject_check(L, 1);
    lua_len(L, 2);
    size_t len = luaL_checkinteger(L, -1);
    lua_pop(L, 1);
    struct vector* boundary = vector_create(4, point_destroy);
    for(unsigned int i = 1; i <= len; ++i)
    {
        lua_rawgeti(L, 2, i);
        struct lpoint* pt = lpoint_checkpoint(L, -1);
        vector_append(boundary, point_copy(lpoint_get(pt)));
        lua_pop(L, 1);
    }
    object_set_boundary(lobject_get(L, cell), boundary);
    vector_destroy(boundary);
    return 0;
}

static int lobject_set_boundary_rectangular(lua_State* L)
{
    lcheck_check_numargs1(L, 3, "object.set_boundary_rectangular");
    struct lobject* cell = lobject_check(L, 1);
    struct lpoint* bl = lpoint_checkpoint(L, 2);
    struct lpoint* tr = lpoint_checkpoint(L, 3);
    struct vector* boundary = vector_create(4, point_destroy);
    vector_append(boundary, point_create(lpoint_get(bl)->x, lpoint_get(bl)->y));
    vector_append(boundary, point_create(lpoint_get(tr)->x, lpoint_get(bl)->y));
    vector_append(boundary, point_create(lpoint_get(tr)->x, lpoint_get(tr)->y));
    vector_append(boundary, point_create(lpoint_get(bl)->x, lpoint_get(tr)->y));
    object_set_boundary(lobject_get(L, cell), boundary);
    vector_destroy(boundary);
    return 0;
}

static int lobject_set_empty_layer_boundary(lua_State* L)
{
    lcheck_check_numargs1(L, 2, "object.set_empty_layer_boundary");
    struct lobject* cell = lobject_check(L, 1);
    const struct generics* layer = lua_touserdata(L, 2);
    object_set_empty_layer_boundary(lobject_get(L, cell), layer);
    return 0;
}

static int lobject_add_layer_boundary(lua_State* L)
{
    lcheck_check_numargs1(L, 3, "object.add_layer_boundary");
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
    object_add_layer_boundary(lobject_get(L, cell), layer, boundary);
    return 0;
}

static int lobject_add_layer_boundary_rectangular(lua_State* L)
{
    lcheck_check_numargs1(L, 4, "object.add_layer_boundary_rectangular");
    struct lobject* cell = lobject_check(L, 1);
    const struct generics* layer = lua_touserdata(L, 2);
    struct simple_polygon* boundary = simple_polygon_create();
    struct lpoint* bl = lpoint_checkpoint(L, 3);
    struct lpoint* tr = lpoint_checkpoint(L, 4);
    simple_polygon_append(boundary, point_create(lpoint_get(bl)->x, lpoint_get(bl)->y));
    simple_polygon_append(boundary, point_create(lpoint_get(tr)->x, lpoint_get(bl)->y));
    simple_polygon_append(boundary, point_create(lpoint_get(tr)->x, lpoint_get(tr)->y));
    simple_polygon_append(boundary, point_create(lpoint_get(bl)->x, lpoint_get(tr)->y));
    object_add_layer_boundary(lobject_get(L, cell), layer, boundary);
    return 0;
}

static int lobject_inherit_boundary(lua_State* L)
{
    lcheck_check_numargs1(L, 2, "object.inherit_boundary");
    struct lobject* cell = lobject_check(L, 1);
    struct lobject* other = lobject_check(L, 2);
    object_inherit_boundary(lobject_get(L, cell), lobject_get_const(other));
    return 0;
}

static int lobject_inherit_layer_boundary(lua_State* L)
{
    lcheck_check_numargs1(L, 3, "object.inherit_layer_boundary");
    struct lobject* cell = lobject_check(L, 1);
    struct lobject* other = lobject_check(L, 2);
    const struct generics* layer = lua_touserdata(L, 3);
    object_inherit_layer_boundary(lobject_get(L, cell), lobject_get_const(other), layer);
    return 0;
}

static int lobject_has_layer(lua_State* L)
{
    lcheck_check_numargs1(L, 2, "object.has_layer");
    struct lobject* cell = lobject_check(L, 1);
    const struct generics* layer = lua_touserdata(L, 2);
    int result = object_has_layer(lobject_get(L, cell), layer);
    lua_pushboolean(L, result);
    return 1;
}

static int lobject_has_boundary(lua_State* L)
{
    lcheck_check_numargs1(L, 1, "object.has_boundary");
    struct lobject* cell = lobject_check(L, 1);
    lua_pushboolean(L, object_has_boundary(lobject_get_const(cell)));
    return 1;
}

static int lobject_get_boundary(lua_State* L)
{
    lcheck_check_numargs1(L, 1, "object.get_boundary");
    struct lobject* cell = lobject_check(L, 1);
    struct vector* boundary = object_get_boundary(lobject_get(L, cell));
    lua_newtable(L);
    int i = 1;
    struct vector_iterator* it = vector_iterator_create(boundary);
    while(vector_iterator_is_valid(it))
    {
        const struct point* pt = vector_iterator_get(it);
        lpoint_create_internal_xy(L, pt->x, pt->y);
        lua_rawseti(L, -2, i);
        vector_iterator_next(it);
        ++i;
    }
    vector_iterator_destroy(it);
    vector_destroy(boundary);
    return 1;
}

static int lobject_get_bounding_box(lua_State* L)
{
    lcheck_check_numargs1(L, 1, "object.get_bounding_box");
    struct lobject* cell = lobject_check(L, 1);
    struct point** boundary = object_get_bounding_box(lobject_get(L, cell));
    lua_newtable(L);
    lpoint_create_internal_pt(L, boundary[0]);
    lua_setfield(L, -2, "bl");
    lpoint_create_internal_pt(L, boundary[1]);
    lua_setfield(L, -2, "tr");
    point_destroy(boundary[0]);
    point_destroy(boundary[1]);
    free(boundary);
    return 1;
}

static int lobject_has_layer_boundary(lua_State* L)
{
    lcheck_check_numargs1(L, 2, "object.has_layer_boundary");
    struct lobject* cell = lobject_check(L, 1);
    const struct generics* layer = lua_touserdata(L, 2);
    lua_pushboolean(L, object_has_layer_boundary(lobject_get_const(cell), layer));
    return 1;
}

static int lobject_get_layer_boundary(lua_State* L)
{
    lcheck_check_numargs1(L, 2, "object.get_layer_boundary");
    struct lobject* cell = lobject_check(L, 1);
    const struct generics* layer = lua_touserdata(L, 2);
    struct polygon_container* boundary = object_get_layer_boundary(lobject_get(L, cell), layer);
    lua_newtable(L);
    if(polygon_container_is_empty(boundary))
    {
        polygon_container_destroy(boundary);
        return 1; /* return empty table */
    }
    struct polygon_container_iterator* pit = polygon_container_iterator_create(boundary);
    int i = 1;
    while(polygon_container_iterator_is_valid(pit))
    {
        struct simple_polygon* single_boundary = polygon_container_iterator_get(pit);
        struct simple_polygon_iterator* it = simple_polygon_iterator_create(single_boundary);
        lua_newtable(L);
        int j = 1;
        while(simple_polygon_iterator_is_valid(it))
        {
            const struct point* pt = simple_polygon_iterator_get(it);
            lpoint_create_internal_xy(L, pt->x, pt->y);
            lua_rawseti(L, -2, j);
            simple_polygon_iterator_next(it);
            ++j;
        }
        simple_polygon_iterator_destroy(it);
        lua_rawseti(L, -2, i);
        ++i;
        polygon_container_iterator_next(pit);
    }
    polygon_container_iterator_destroy(pit);
    polygon_container_destroy(boundary);
    return 1;
}

static int lobject_get_layer_occupation(lua_State* L)
{
    lcheck_check_numargs2(L, 1, 2, "object.get_layer_boundary");
    struct lobject* cell = lobject_check(L, 1);
    size_t numlayers = 0;
    const struct generics** layers = NULL;
    if(lua_istable(L, 2))
    {
        lua_len(L, 2);
        int len = lua_tointeger(L, -1);
        lua_pop(L, 1);
        layers = malloc(len * sizeof(*layers));
        numlayers = len;
        for(size_t i = 0; i < numlayers; ++i)
        {
            lua_rawgeti(L, 2, i + 1);
            layers[i] = lua_touserdata(L, -1);
            lua_pop(L, 1);
        }
    }
    else if(lua_isuserdata(L, 2))
    {
        layers = malloc(1 * sizeof(*layers));
        numlayers = 1;
        layers[0] = lua_touserdata(L, 2);
    }

    struct bltrshape* bltrshape = object_get_layer_occupation(lobject_get(L, cell), layers, numlayers);
    lua_newtable(L);
    /* bl */
    lpoint_create_internal_pt(L, bltrshape_get_bl(bltrshape));
    lua_setfield(L, -2, "bl");
    /* tr */
    lpoint_create_internal_pt(L, bltrshape_get_tr(bltrshape));
    lua_setfield(L, -2, "tr");
    return 1;
}

static int lobject_get_shape_outlines(lua_State* L)
{
    lcheck_check_numargs2(L, 2, 3, "object.get_shape_outlines");
    struct lobject* cell = lobject_check(L, 1);
    size_t numlayers = 0;
    const struct generics** layers = NULL;
    if(lua_istable(L, 2))
    {
        lua_len(L, 2);
        int len = lua_tointeger(L, -1);
        lua_pop(L, 1);
        layers = malloc(len * sizeof(*layers));
        numlayers = len;
        for(size_t i = 0; i < numlayers; ++i)
        {
            lua_rawgeti(L, 2, i + 1);
            layers[i] = lua_touserdata(L, -1);
            lua_pop(L, 1);
        }
    }
    else if(lua_isuserdata(L, 2))
    {
        layers = malloc(1 * sizeof(*layers));
        numlayers = 1;
        layers[0] = lua_touserdata(L, 2);
    }
    coordinate_t offset = luaL_optinteger(L, 3, 0);
    struct polygon_container* outlines = object_get_shape_outlines(lobject_get(L, cell), layers, numlayers);
    lua_newtable(L);
    if(polygon_container_is_empty(outlines))
    {
        polygon_container_destroy(outlines);
        return 1; /* return empty table */
    }
    struct polygon_container_iterator* pit = polygon_container_iterator_create(outlines);
    int i = 1;
    while(polygon_container_iterator_is_valid(pit))
    {
        lua_newtable(L);
        struct simple_polygon* single_boundary = polygon_container_iterator_get(pit);
        if(offset != 0)
        {
            // gather points
            struct vector* pts = vector_create(8, point_destroy);
            struct simple_polygon_iterator* spit = simple_polygon_iterator_create(single_boundary);
            while(simple_polygon_iterator_is_valid(spit))
            {
                const struct point* pt = simple_polygon_iterator_get(spit);
                vector_append(pts, point_copy(pt));
                simple_polygon_iterator_next(spit);
            }
            simple_polygon_iterator_destroy(spit);
            // add offset
            // FIXME: this should be done in the object C interface
            struct vector* offsetpoly = geometry_offset_polygon_points(pts, offset);
            // store points in table
            int j = 1;
            struct vector_iterator* vit = vector_iterator_create(offsetpoly);
            while(vector_iterator_is_valid(vit))
            {
                const struct point* pt = vector_iterator_get(vit);
                lpoint_create_internal_xy(L, pt->x, pt->y);
                lua_rawseti(L, -2, j);
                vector_iterator_next(vit);
                ++j;
            }
            vector_iterator_destroy(vit);
            vector_destroy(pts);
            vector_destroy(offsetpoly);
        }
        else
        {
            struct simple_polygon_iterator* it = simple_polygon_iterator_create(single_boundary);
            int j = 1;
            while(simple_polygon_iterator_is_valid(it))
            {
                const struct point* pt = simple_polygon_iterator_get(it);
                lpoint_create_internal_xy(L, pt->x, pt->y);
                lua_rawseti(L, -2, j);
                simple_polygon_iterator_next(it);
                ++j;
            }
            simple_polygon_iterator_destroy(it);
        }
        lua_rawseti(L, -2, i);
        ++i;
        polygon_container_iterator_next(pit);
    }
    polygon_container_iterator_destroy(pit);
    polygon_container_destroy(outlines);
    return 1;
}

static int lobject_add_net_shape(lua_State* L)
{
    lcheck_check_numargs1(L, 5, "object.add_net_shape");
    struct lobject* cell = lobject_check(L, 1);
    const char* netname = luaL_checkstring(L, 2);
    struct lpoint* bl = lpoint_checkpoint(L, 3);
    struct lpoint* tr = lpoint_checkpoint(L, 4);
    const struct generics* layer = lua_touserdata(L, 5);
    _check_rectangle_points(L, bl, tr, "object.add_net_shape");
    object_add_net_shape(lobject_get(L, cell), netname, lpoint_get(bl), lpoint_get(tr), layer);
    return 0;
}

static int lobject_mark_area_anchor_as_net(lua_State* L)
{
    lcheck_check_numargs1(L, 4, "object.mark_area_anchor_as_net");
    struct lobject* cell = lobject_check(L, 1);
    const char* anchorname = luaL_checkstring(L, 2);
    const char* netname = luaL_checkstring(L, 3);
    const struct generics* layer = lua_touserdata(L, 4);
    struct point* pts = object_get_area_anchor(lobject_get(L, cell), anchorname);
    if(!object_has_area_anchor(lobject_get(L, cell), anchorname))
    {
        const char* name = object_get_name(lobject_get(L, cell));
        if(name)
        {
            lua_pushfstring(L, "object.mark_area_anchor_as_net: first object ('%s') does not have an anchor '%s'", name, anchorname);
        }
        else
        {
            lua_pushfstring(L, "object.mark_area_anchor_as_net: first object does not have an anchor '%s'", anchorname);
        }
        lua_error(L);
    }
    object_add_net_shape(lobject_get(L, cell), netname, pts + 0, pts + 1, layer);
    free(pts);
    return 0;
}

static void _fill_netshape_table(lua_State* L, const char* netname, struct bltrshape* netshape, int i)
{
    lua_newtable(L);
    /* net */
    lua_pushstring(L, netname);
    lua_setfield(L, -2, "net");
    /* net */
    lua_pushlightuserdata(L, (void*) bltrshape_get_layer(netshape));
    lua_setfield(L, -2, "layer");
    /* bl */
    lpoint_create_internal_pt(L, bltrshape_get_bl(netshape));
    lua_setfield(L, -2, "bl");
    /* tr */
    lpoint_create_internal_pt(L, bltrshape_get_tr(netshape));
    lua_setfield(L, -2, "tr");
    /* add to array */
    lua_rawseti(L, -2, i + 1);
}

static int lobject_get_net_shapes(lua_State* L)
{
    lcheck_check_numargs2(L, 2, 3, "object.get_net_shapes");
    struct lobject* cell = lobject_check(L, 1);
    const char* netname = luaL_checkstring(L, 2);
    const struct generics* layer = NULL;
    if(lua_gettop(L) == 3)
    {
        layer = lua_touserdata(L, 3);
    }
    struct vector* netshapes = object_get_net_shapes(lobject_get_const(cell), netname, layer);
    lua_newtable(L);
    if(netshapes)
    {
        for(size_t i = 0; i < vector_size(netshapes); ++i)
        {
            struct bltrshape* netshape = vector_get(netshapes, i);
            _fill_netshape_table(L, netname, netshape, i);
        }
        vector_destroy(netshapes);
    }
    return 1;
}

static int lobject_get_array_net_shapes(lua_State* L)
{
    lcheck_check_numargs1(L, 5, "object.get_array_net_shapes");
    struct lobject* cell = lobject_check(L, 1);
    int xindex = luaL_checkinteger(L, 2);
    int yindex = luaL_checkinteger(L, 3);
    const char* netname = luaL_checkstring(L, 4);
    const struct generics* layer = lua_touserdata(L, 5);
    struct vector* netshapes = object_get_array_net_shapes(lobject_get_const(cell), xindex, yindex, netname, layer);
    lua_newtable(L);
    if(netshapes)
    {
        for(size_t i = 0; i < vector_size(netshapes); ++i)
        {
            struct bltrshape* netshape = vector_get(netshapes, i);
            _fill_netshape_table(L, netname, netshape, i);
        }
        vector_destroy(netshapes);
    }
    return 1;
}

int open_lobject_lib(lua_State* L)
{
    // create metatable for objects
    luaL_newmetatable(L, LOBJECTMODULE);

    // add __index
    lua_pushstring(L, "__index");
    lua_pushvalue(L, -2);
    lua_rawset(L, -3);

    // set methods
    static const luaL_Reg metafuncs[] = {
        { "create",                                 lobject_create                              },
        { "create_pseudo",                          lobject_create_pseudo                       },
        { "copy",                                   lobject_copy                                },
        { "get_name",                               lobject_get_name                            },
        { "set_name",                               lobject_set_name                            },
        { "exchange",                               lobject_exchange                            },
        { "is_object",                              lobject_is_object_lua                       },
        { "add_anchor",                             lobject_add_anchor                          },
        { "inherit_anchor",                         lobject_inherit_anchor                      },
        { "inherit_anchor_as",                      lobject_inherit_anchor_as                   },
        { "add_area_anchor_bltr",                   lobject_add_area_anchor_bltr                },
        { "add_area_anchor_points",                 lobject_add_area_anchor_points              },
        { "add_area_anchor_blwh",                   lobject_add_area_anchor_blwh                },
        { "add_anchor_line_x",                      lobject_add_anchor_line_x                   },
        { "add_anchor_line_y",                      lobject_add_anchor_line_y                   },
        { "inherit_area_anchor",                    lobject_inherit_area_anchor                 },
        { "inherit_area_anchor_as",                 lobject_inherit_area_anchor_as              },
        { "inherit_all_anchors",                    lobject_inherit_all_anchors                 },
        { "inherit_all_anchors_with_prefix",        lobject_inherit_all_anchors_with_prefix     },
        { "get_anchor",                             lobject_get_anchor                          },
        { "get_alignment_anchor",                   lobject_get_alignment_anchor                },
        { "get_area_anchor",                        lobject_get_area_anchor                     },
        { "get_area_anchor_fmt",                    lobject_get_area_anchor_fmt                 },
        { "get_array_anchor",                       lobject_get_array_anchor                    },
        { "get_array_area_anchor",                  lobject_get_array_area_anchor               },
        { "get_all_regular_anchors",                lobject_get_all_regular_anchors             },
        { "get_anchor_line_x",                      lobject_get_anchor_line_x                   },
        { "get_anchor_line_y",                      lobject_get_anchor_line_y                   },
        { "add_port",                               lobject_add_port                            },
        { "add_port_with_anchor",                   lobject_add_port_with_anchor                },
        { "add_bus_port",                           lobject_add_bus_port                        },
        { "add_label",                              lobject_add_label                           },
        { "get_ports",                              lobject_get_ports                           },
        { "clear_alignment_box",                    lobject_clear_alignment_box                 },
        { "set_alignment_box",                      lobject_set_alignment_box                   },
        { "inherit_alignment_box",                  lobject_inherit_alignment_box               },
        { "alignment_box_include_point",            lobject_alignment_box_include_point         },
        { "alignment_box_include_x",                lobject_alignment_box_include_x             },
        { "alignment_box_include_y",                lobject_alignment_box_include_y             },
        { "extend_alignment_box",                   lobject_extend_alignment_box                },
        { "extend_alignment_box_x_symmetrical",     lobject_extend_alignment_box_x_symmetrical  },
        { "extend_alignment_box_y_symmetrical",     lobject_extend_alignment_box_y_symmetrical  },
        { "extend_alignment_box_xy_symmetrical",    lobject_extend_alignment_box_xy_symmetrical },
        { "width_height_alignmentbox",              lobject_width_height_alignmentbox           },
        { "move_to",                                lobject_move_to                             },
        { "set_origin",                             lobject_set_origin                          },
        { "reset_translation",                      lobject_reset_translation                   },
        { "translate",                              lobject_translate                           },
        { "translate_x",                            lobject_translate_x                         },
        { "translate_y",                            lobject_translate_y                         },
        { "mirror_at_xaxis",                        lobject_mirror_at_xaxis                     },
        { "mirror_at_yaxis",                        lobject_mirror_at_yaxis                     },
        { "mirror_at_origin",                       lobject_mirror_at_origin                    },
        { "rotate_90_left",                         lobject_rotate_90_left                      },
        { "rotate_90_right",                        lobject_rotate_90_right                     },
        { "array_rotate_90_left",                   lobject_array_rotate_90_left                },
        { "array_rotate_90_right",                  lobject_array_rotate_90_right               },
        { "flipx",                                  lobject_flipx                               },
        { "flipy",                                  lobject_flipy                               },
        { "move_x",                                 lobject_move_x                              },
        { "move_y",                                 lobject_move_y                              },
        { "move_point",                             lobject_move_point                          },
        { "move_point_x",                           lobject_move_point_x                        },
        { "move_point_y",                           lobject_move_point_y                        },
        { "center",                                 lobject_center                              },
        { "center_x",                               lobject_center_x                            },
        { "center_y",                               lobject_center_y                            },
        { "abut_left",                              lobject_abut_left                           },
        { "abut_right",                             lobject_abut_right                          },
        { "abut_top",                               lobject_abut_top                            },
        { "abut_bottom",                            lobject_abut_bottom                         },
        { "abut_left_origin",                       lobject_abut_left_origin                    },
        { "abut_right_origin",                      lobject_abut_right_origin                   },
        { "abut_top_origin",                        lobject_abut_top_origin                     },
        { "abut_bottom_origin",                     lobject_abut_bottom_origin                  },
        { "place_left",                             lobject_place_left                          },
        { "place_right",                            lobject_place_right                         },
        { "place_top",                              lobject_place_top                           },
        { "place_bottom",                           lobject_place_bottom                        },
        { "place_left_origin",                      lobject_place_left_origin                   },
        { "place_right_origin",                     lobject_place_right_origin                  },
        { "place_top_origin",                       lobject_place_top_origin                    },
        { "place_bottom_origin",                    lobject_place_bottom_origin                 },
        { "align_left",                             lobject_align_left                          },
        { "align_right",                            lobject_align_right                         },
        { "align_top",                              lobject_align_top                           },
        { "align_bottom",                           lobject_align_bottom                        },
        { "align_center_x",                         lobject_align_center_x                      },
        { "align_center_y",                         lobject_align_center_y                      },
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
        { "create_object_handle",                   lobject_create_object_handle                },
        { "add_child",                              lobject_add_child                           },
        { "add_child_array",                        lobject_add_child_array                     },
        { "merge_into",                             lobject_merge_into                          },
        { "merge_into_with_ports",                  lobject_merge_into_with_ports               },
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
        { "inherit_layer_boundary",                 lobject_inherit_layer_boundary              },
        { "has_layer",                              lobject_has_layer                           },
        { "has_boundary",                           lobject_has_boundary                        },
        { "get_boundary",                           lobject_get_boundary                        },
        { "get_bounding_box",                       lobject_get_bounding_box                    },
        { "has_layer_boundary",                     lobject_has_layer_boundary                  },
        { "get_layer_boundary",                     lobject_get_layer_boundary                  },
        { "get_layer_occupation",                   lobject_get_layer_occupation                },
        { "get_shape_outlines",                     lobject_get_shape_outlines                  },
        { "add_net_shape",                          lobject_add_net_shape                       },
        { "mark_area_anchor_as_net",                lobject_mark_area_anchor_as_net             },
        { "get_net_shapes",                         lobject_get_net_shapes                      },
        { "get_array_net_shapes",                   lobject_get_array_net_shapes                },
        { "__gc",                                   lobject_destroy                             },
        { "__tostring",                             lobject_tostring                            },
        { NULL,                                     NULL                                        }
    };
    luaL_setfuncs(L, metafuncs, 0);

    lua_setglobal(L, LOBJECTMODULE);

    return 0;
}


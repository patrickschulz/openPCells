#include "lutil.h"

#include "lua/lauxlib.h"

#include "lpoint.h"
#include "util.h"

size_t lutil_len(lua_State* L, int idx)
{
    lua_len(L, idx);
    size_t len = lua_tointeger(L, -1);
    lua_pop(L, 1);
    return len;
}

struct vector* lutil_get_string_table(lua_State* L, int idx)
{
    if(!lua_istable(L, idx))
    {
        return NULL;
    }
    size_t len = lutil_len(L, idx);
    struct vector* strings = vector_create(len, free);
    for(size_t i = 1; i <= len; ++i)
    {
        lua_rawgeti(L, idx, i);
        const char* str = luaL_checkstring(L, -1);
        vector_append(strings, util_strdup(str));
        lua_pop(L, 1);
    }
    return strings;
}

struct simple_polygon* lutil_create_simple_polygon(lua_State* L, int idx)
{
    size_t len = lutil_len(L, idx);
    struct simple_polygon* result = simple_polygon_create();
    for(size_t i = 1; i <= len; ++i)
    {
        lua_rawgeti(L, idx, i);
        struct lpoint* pt = lpoint_checkpoint(L, -1);
        simple_polygon_append(result, point_copy(lpoint_get(pt)));
        lua_pop(L, 1);
    }
    return result;
}


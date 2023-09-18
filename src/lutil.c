#include "lutil.h"

#include "lpoint.h"

struct simple_polygon* lutil_create_simple_polygon(lua_State* L, int idx)
{
    lua_len(L, idx);
    size_t len = lua_tointeger(L, -1);
    lua_pop(L, 1);
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


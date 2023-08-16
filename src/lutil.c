#include "lutil.h"

#include "lpoint.h"

struct const_vector* lutil_create_const_point_vector(lua_State* L, int idx)
{
    lua_len(L, idx);
    size_t len = lua_tointeger(L, -1);
    lua_pop(L, 1);
    struct const_vector* result = const_vector_create(32);
    for(size_t i = 1; i <= len; ++i)
    {
        lua_rawgeti(L, idx, i);
        struct lpoint* pt = lpoint_checkpoint(L, -1);
        const_vector_append(result, lpoint_get(pt));
        lua_pop(L, 1);
    }
    return result;
}


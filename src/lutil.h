#ifndef OPC_LUTIL_H
#define OPC_LUTIL_H

#include "lua/lua.h"

#include "vector.h"

struct const_vector* lutil_create_const_point_vector(lua_State* L, int idx);

#endif /* OPC_LUTIL_H */

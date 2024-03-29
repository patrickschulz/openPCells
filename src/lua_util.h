#ifndef OPC_LUA_UTIL_H
#define OPC_LUA_UTIL_H

#include "lua/lua.h"

int util_msghandler(lua_State *L);
lua_State* util_create_minimal_lua_state(void);
lua_State* util_create_basic_lua_state(void);

#endif // OPC_LUA_UTIL_H

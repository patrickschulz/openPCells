#ifndef OPC_MAIN_FUNCTIONS_H
#define OPC_MAIN_FUNCTIONS_H

#include "lua/lua.h"

int main_call_lua_program(lua_State* L, const char* filename);
int main_call_lua_program_from_buffer(lua_State* L, const char* data, size_t len, const char* name);

#endif // OPC_MAIN_FUNCTIONS_H

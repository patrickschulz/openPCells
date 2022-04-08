#ifndef OPC_MAIN_FUNCTIONS_H
#define OPC_MAIN_FUNCTIONS_H

#include "lua/lua.h"

int main_call_lua_program(lua_State* L, const char* filename);

void main_load_lua_module(lua_State* L, const char* modname);

#endif // OPC_MAIN_FUNCTIONS_H

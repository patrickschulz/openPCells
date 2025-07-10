#ifndef OPC_MAIN_FUNCTIONS_H
#define OPC_MAIN_FUNCTIONS_H

#include "lua/lua.h"

#include "technology.h"
#include "vector.h"

lua_State* main_create_and_initialize_lua(void);
int main_lua_pcall(lua_State* L, int nargs, int nresults);
int main_call_lua_program(lua_State* L, const char* filename);
int main_call_lua_program_from_buffer(lua_State* L, const unsigned char* data, size_t len, const char* name);
int main_load_module(lua_State* L, const unsigned char* data, size_t len, const char* name, const char* chunkname);
struct technology_state* main_create_techstate(struct vector* techpaths, const char* techname, const struct const_vector* ignoredlayers);

#endif // OPC_MAIN_FUNCTIONS_H

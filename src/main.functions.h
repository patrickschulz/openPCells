#ifndef OPC_MAIN_FUNCTIONS_H
#define OPC_MAIN_FUNCTIONS_H

#include "lua/lua.h"

#include "technology.h"
#include "vector.h"

void main_load_opc_libraries(lua_State* L);
struct technology_state* main_create_techstate(const struct vector* techpaths, const char* techname, const struct const_vector* ignoredlayers);

#endif // OPC_MAIN_FUNCTIONS_H

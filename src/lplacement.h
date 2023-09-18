#ifndef OPC_LPLACEMENT_H
#define OPC_LPLACEMENT_H

#include "lua/lua.h"

#include "polygon.h"

#define LPLACEMENTMODULE "placement"

void lplacement_create_target_exclude_vectors(lua_State* L, struct simple_polygon** targetarea, struct polygon** excludes, int idx);
int open_lplacement_lib(lua_State* L);

#endif // OPC_LPLACEMENT_H

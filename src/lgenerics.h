#ifndef OPC_LGENERICS_H
#define OPC_LGENERICS_H

#include "lua/lua.h"

#define LGENERICSMODULE "generics"

int open_lgenerics_lib(lua_State* L);
void* generics_check_generics(lua_State* L, int idx);

#endif /* OPC_LGENERICS_H */

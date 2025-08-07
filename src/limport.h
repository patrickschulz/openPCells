#ifndef OPC_LIMPORT_H
#define OPC_LIMPORT_H

#include "lua/lua.h"

#define LIMPORTMODULE "import"

int open_limport_lib(lua_State* L);

#endif // OPC_LIMPORT_H

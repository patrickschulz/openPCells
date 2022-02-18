#ifndef OPC_LGENERICS_H
#define OPC_LGENERICS_H

#include "lua/lua.h"

#include "generics.h"

#define LGENERICSMODULE "generics"

typedef struct
{
    generics_t* layer;
} lgenerics_t;

int open_lgenerics_lib(lua_State* L);

#endif /* OPC_LGENERICS_H */

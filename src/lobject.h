#ifndef OPC_LOBJECT_H
#define OPC_LOBJECT_H

#include "lua/lua.h"
#include "object.h"

#define LOBJECTMODULE "object"

typedef struct
{
    object_t* object;
    int destroy;
} lobject_t;

int lobject_create(lua_State* L);
lobject_t* lobject_adapt(lua_State* L, object_t* cell);

int open_lobject_lib(lua_State* L);

#endif // OPC_LOBJECT_H

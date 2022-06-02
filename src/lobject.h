#ifndef OPC_LOBJECT_H
#define OPC_LOBJECT_H

#include "lua/lua.h"
#include "object.h"

#define LOBJECTMODULE "object"

typedef struct
{
    struct object* object;
    int destroy;
} lobject_t;

int lobject_create(lua_State* L);
lobject_t* lobject_check(lua_State* L, int idx);
lobject_t* lobject_check_soft(lua_State* L, int idx);
lobject_t* lobject_adapt(lua_State* L, struct object* cell);
void lobject_disown(lobject_t* lobject);

int open_lobject_lib(lua_State* L);

#endif // OPC_LOBJECT_H

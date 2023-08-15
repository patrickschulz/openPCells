#ifndef OPC_LOBJECT_H
#define OPC_LOBJECT_H

#include "lua/lua.h"
#include "object.h"

#define LOBJECTMODULE "object"

struct lobject;

int lobject_create(lua_State* L);
struct lobject* lobject_check(lua_State* L, int idx);
struct lobject* lobject_check_soft(lua_State* L, int idx);
struct lobject* lobject_adapt_owning(lua_State* L, struct object* cell);
struct lobject* lobject_adapt_non_owning(lua_State* L, struct object* cell);
struct object* lobject_get(struct lobject* lobject);
struct object* lobject_disown(struct lobject* lobject);

int open_lobject_lib(lua_State* L);

#endif // OPC_LOBJECT_H

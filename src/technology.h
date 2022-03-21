#ifndef OPC_TECHNOLOGY_H
#define OPC_TECHNOLOGY_H

#include "lua/lua.h"

#include "generics.h"

generics_t* technology_get_layer(const char* layername);

void technology_initialize_layertable(void);
void technology_destroy_layertable(void);

generics_t* technology_make_layer(lua_State* L);

int open_ltechnology_lib(lua_State* L);

#endif // OPC_TECHNOLOGY_H

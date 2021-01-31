#ifndef LSTRINGBUFFER_H
#define LSTRINGBUFFER_H

#include "lua/lua.h"

#define LSTRINGBUFFERMETA "LSTRINGBUFFER"
#define LSTRINGBUFFERMODULE "stringbuffer"

int open_lstringbuffer_lib(lua_State* L);

#endif // LSTRINGBUFFER_H

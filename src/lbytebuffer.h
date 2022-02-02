#ifndef LBYTEBUFFER_H
#define LBYTEBUFFER_H

#include <stddef.h>

#include "lua/lua.h"

struct bytebuffer
{
    char* data;
    size_t capacity;
    size_t size;
};

#define LBYTEBUFFERMETA "lbytebuffer"
#define LBYTEBUFFERMODULE "bytebuffer"

int open_lbytebuffer_lib(lua_State* L);

#endif // LBYTEBUFFER_H

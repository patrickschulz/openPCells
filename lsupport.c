#include "lsupport.h"

#include <stdlib.h>

void lexit(lua_State* L, int code)
{
    lua_close(L);
    exit(code);
}

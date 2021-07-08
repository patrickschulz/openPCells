#include "lfilesystem.h"

#include "lua/lauxlib.h"

#include <sys/stat.h>

static int lfilesystem_mkdir(lua_State* L)
{
    const char* path = lua_tostring(L, 1);
    mode_t mode = 0777;
    if(mkdir(path, mode) == -1)
    {
        lua_pushboolean(L, 0);
    }
    else
    {
        lua_pushboolean(L, 1);
    }
    return 1;
}

int open_lfilesystem_lib(lua_State* L)
{
    static const luaL_Reg modfuncs[] =
    {
        { "mkdir", lfilesystem_mkdir },
        { NULL,    NULL              }
    };
    luaL_newlib(L, modfuncs);
    lua_setglobal(L, LFILESYSTEMMODULE);

    return 0;
}

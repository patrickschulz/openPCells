#include "filesystem.h"

#include "lua/lauxlib.h"

#include <errno.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/stat.h>
#include <sys/types.h>
#include <unistd.h>

int filesystem_mkdir(const char* path, mode_t mode)
{
    /* 
     Code by Yaroslav Stavnichiy, taken from https://stackoverflow.com/questions/2336242/recursive-mkdir-system-call-on-unix
     Slightly modified for use in lua
     >> 
     */
    char* copy = malloc(strlen(path) + 1);
    strcpy(copy, path);
    for(char* p = strchr(copy + 1, '/'); p; p = strchr(p + 1, '/'))
    {
        *p = '\0';
        if(mkdir(copy, mode) == -1)
        {
            if (errno != EEXIST)
            {
                *p = '/';
                free(copy);
                return 0;
            }
        }
        *p = '/';
    }
    /* << */
    /* create last part of path */
    if (mkdir(copy, mode) == -1)
    {
        if (errno != EEXIST)
        {
            free(copy);
            return 0;
        }
    }

    free(copy);
    return 1;
}

int filesystem_exists(const char* path)
{
    return access(path, F_OK) == 0;
}

static int lfilesystem_mkdir(lua_State* L)
{
    const char* path = lua_tostring(L, 1);
    int ret = filesystem_mkdir(path, 0777); // FIXME: make mode accessible from lua
    lua_pushboolean(L, ret);
    return 1;
}

static int lfilesystem_exists(lua_State* L)
{
    const char* path = lua_tostring(L, 1);
    if(access(path, F_OK) == 0)
    {
        lua_pushboolean(L, 1);
    }
    else
    {
        lua_pushboolean(L, 0);
    }
    return 1;
}

int open_lfilesystem_lib(lua_State* L)
{
    static const luaL_Reg modfuncs[] =
    {
        { "mkdir",  lfilesystem_mkdir  },
        { "exists", lfilesystem_exists },
        { NULL,     NULL               }
    };
    luaL_newlib(L, modfuncs);
    lua_setglobal(L, LFILESYSTEMMODULE);

    return 0;
}

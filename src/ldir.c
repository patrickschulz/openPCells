#include "ldir.h"
#include "lua/lauxlib.h"

#include <dirent.h>
#include <sys/stat.h>
#include <stdlib.h>

#include "util.h"

int ldir_walk(lua_State* L)
{
    const char* basepath = lua_tostring(L, -1);
    if(!basepath)
    {
        lua_pushstring(L, "walkdir: path is nil");
        lua_error(L);
    }
    lua_newtable(L);
    DIR* dir = opendir(basepath);
    if(!dir)
    {
        lua_pushfstring(L, "walkdir: could not open directory '%s'", basepath);
        lua_error(L);
    }
    int i = 1;
    while(1)
    {
        struct dirent* entry = readdir(dir);
        if(!entry)
        {
            break;
        }

        // get type of file, ignore everything except regular files and directories
        char* fullpath = util_concat_path(basepath, entry->d_name);
        struct stat statbuf;
        int ret = stat(fullpath, &statbuf);
        if(ret == -1)
        {
            printf("ldir error with '%s'\n", fullpath);
            perror("");
        }
        const char* type = NULL;
        if(S_ISREG(statbuf.st_mode))
        {
            if(util_match_string(fullpath, ".lua")) // ignore non-lua files
            {
                type = "regular";
            }
        }
        else if(S_ISDIR(statbuf.st_mode))
        {
            type = "directory";
        }

        if(type)
        {
            lua_newtable(L);
            lua_pushliteral(L, "name");
            lua_pushstring(L, entry->d_name);
            lua_settable(L, -3);
            lua_pushliteral(L, "type");
            lua_pushstring(L, type);
            lua_settable(L, -3);
            lua_rawseti(L, -2, i);
            ++i;
        }
        free(fullpath);
    }
    closedir(dir);
    return 1;
}

static int ldir_exists(lua_State* L)
{
    const char* path = lua_tostring(L, -1);
    if(!path)
    {
        lua_pushstring(L, "exists: path is nil");
        lua_error(L);
    }
    struct stat buf;
    if(stat(path, &buf))
    {
        lua_pushboolean(L, 0);
    }
    else
    {
        lua_pushboolean(L, 1);
    }
    return 1;
}

int open_ldir_lib(lua_State* L)
{
    static const luaL_Reg modfuncs[] =
    {
        { "walk",   ldir_walk   },
        { "exists", ldir_exists },
        { NULL,     NULL        }
    };
    lua_newtable(L);
    luaL_setfuncs(L, modfuncs, 0);
    lua_setglobal(L, "dir");
    return 0;
}

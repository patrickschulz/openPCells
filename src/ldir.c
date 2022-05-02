#include "ldir.h"
#include "lua/lauxlib.h"

#include <dirent.h>
#include <sys/stat.h>

int ldir_walk(lua_State* L)
{
    const char* path = lua_tostring(L, -1);
    if(!path)
    {
        lua_pushstring(L, "walkdir: path is nil");
        lua_error(L);
    }
    lua_newtable(L);
    DIR* dir = opendir(path);
    if(!dir)
    {
        lua_pushfstring(L, "walkdir: could not open directory '%s'", path);
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
        lua_newtable(L);
        lua_pushliteral(L, "name");
        lua_pushstring(L, entry->d_name);
        lua_settable(L, -3);
        lua_pushliteral(L, "type");
        switch(entry->d_type)
        {
            case DT_BLK:
                lua_pushliteral(L, "blockdev");
                break;
            case DT_CHR:
                lua_pushliteral(L, "characterdev");
                break;
            case DT_DIR:
                lua_pushliteral(L, "directory");
                break;
            case DT_FIFO:
                lua_pushliteral(L, "fifo");
                break;
            case DT_LNK:
                lua_pushliteral(L, "link");
                break;
            case DT_REG:
                lua_pushliteral(L, "regular");
                break;
            case DT_SOCK:
                lua_pushliteral(L, "sock");
                break;
            case DT_UNKNOWN:
                lua_pushliteral(L, "unknown");
                break;
        }
        lua_settable(L, -3);

        lua_rawseti(L, -2, i);
        ++i;
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

#include "lua_util.h"

#include <stdlib.h>

#include "lua/lauxlib.h"
#include "lua/lualib.h"

lua_State* util_create_minimal_lua_state(void)
{
    lua_State* L = luaL_newstate();
    if (L == NULL) 
    {
        fprintf(stderr, "%s\n", "cannot create state: not enough memory");
        exit(EXIT_FAILURE);
    }
    return L;
}

/* this is taken from lua/init.c, but the list of modules is modified, we don't need package for instance */
void _load_lualibs(lua_State *L)
{
    static const luaL_Reg loadedlibs[] = {
        {LUA_GNAME, luaopen_base},
        //{LUA_LOADLIBNAME, luaopen_package},
        //{LUA_COLIBNAME, luaopen_coroutine},
        {LUA_TABLIBNAME, luaopen_table},
        {LUA_IOLIBNAME, luaopen_io},
        {LUA_OSLIBNAME, luaopen_os}, // replace os.exit and os.time, then this 'dependency' can also be removed
        {LUA_STRLIBNAME, luaopen_string},
        {LUA_MATHLIBNAME, luaopen_math},
        //{LUA_UTF8LIBNAME, luaopen_utf8},
        {LUA_DBLIBNAME, luaopen_debug},
        {NULL, NULL}
    };

    const luaL_Reg *lib;
    /* "require" functions from 'loadedlibs' and set results to global table */
    for (lib = loadedlibs; lib->func; lib++) {
        luaL_requiref(L, lib->name, lib->func, 1);
        lua_pop(L, 1);  /* remove lib */
    }
}


lua_State* util_create_basic_lua_state(void)
{
    lua_State* L = util_create_minimal_lua_state();
    _load_lualibs(L);
    return L;
}


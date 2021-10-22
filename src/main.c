/*
** $Id: lua.c $
** Lua stand-alone interpreter
** See Copyright Notice in lua.h
*/

#include "lua/lprefix.h"

#include <stdio.h>
#include <stdlib.h>
#include <sys/types.h>
#include <unistd.h>

#include <signal.h>

#include "lua/lua.h"
#include "lua/lauxlib.h"
#include "lua/lualib.h"

#include <math.h>
#include <ctype.h>
#include <string.h>

#include "lpoint.h"
#include "lload.h"
#include "lbind.h"
#include "ldir.h"
#include "lbinary.h"
#include "lshape.h"
//#include "lunion.h"
#include "lfilesystem.h"

#include "config.h"

//static lua_State* globalL = NULL;

/*
** Hook set by signal function to stop the interpreter.
*/
//static void lstop (lua_State* L, lua_Debug* ar) {
//  (void)ar;  /* unused arg. */
//  lua_sethook(L, NULL, 0, 0);  /* reset hook */
//  luaL_error(L, "interrupted!");
//}


/*
** Function to be called at a C signal. Because a C signal cannot
** just change a Lua state (as there is no proper synchronization),
** this function only sets a hook that, when called, will stop the
** interpreter.
*/
//static void laction (int i) {
//  int flag = LUA_MASKCALL | LUA_MASKRET | LUA_MASKLINE | LUA_MASKCOUNT;
//  signal(i, SIG_DFL); /* if another SIGINT happens, terminate process */
//  lua_sethook(globalL, lstop, flag, 1);
//}


/*
** Message handler used to run all chunks
*/
static int msghandler(lua_State* L)
{
    const char* msg = lua_tostring(L, 1);
    /*
    if (msg == NULL) // is error object not a string?
    {
        msg = lua_pushfstring(L, "(error object is a %s value)", luaL_typename(L, 1));
    }
    */
    int traceback = 1;
    lua_getglobal(L, "envlib");
    lua_pushstring(L, "get");
    lua_gettable(L, -2);
    lua_pushstring(L, "debug");
    int ret = lua_pcall(L, 1, 1, 0);
    if(ret != LUA_OK)
    {
        printf("%s\n", "error in msghandler (while calling envlib.get('debug'). A traceback will be printed");
    }
    else
    {
        traceback = lua_toboolean(L, -1);
    }
    lua_pop(L, 1); // pop envlib

    if(traceback)
    {
        luaL_traceback(L, L, msg, 2);
    }
    else
    {
        lua_pushstring(L, msg);
    }
    return 1;
}

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

/* this is taken from lua/init.c, but the list of modules is modified, we don't need package for instance */
void load_lualibs(lua_State *L)
{
    const luaL_Reg *lib;
    /* "require" functions from 'loadedlibs' and set results to global table */
    for (lib = loadedlibs; lib->func; lib++) {
        luaL_requiref(L, lib->name, lib->func, 1);
        lua_pop(L, 1);  /* remove lib */
    }
}

static void create_argument_table(lua_State* L, int argc, char** argv)
{
    lua_newtable(L);
    int i;
    for(i = 1; i < argc; ++i)
    {
        lua_pushstring(L, argv[i]);
        lua_rawseti(L, -2, i);
    }
    lua_setglobal(L, "arg");
}

static int call_main_program(lua_State* L, const char* filename)
{
    int status = luaL_loadfile(L, filename);
    if (status == LUA_OK) {
        lua_pushcfunction(L, msghandler);
        lua_insert(L, 1);
        status = lua_pcall(L, 0, 1, 1);
    }
    if(status != LUA_OK) 
    {
        const char* msg = lua_tostring(L, -1);
        fprintf(stderr, "%s\n", msg);
        lua_pop(L, 1);
        return LUA_ERRRUN;
    }
    return LUA_OK;
}

lua_State* create_and_initialize_lua()
{
    lua_State* L = luaL_newstate();
    if (L == NULL) 
    {
        fprintf(stderr, "%s\n", "cannot create state: not enough memory");
        exit(EXIT_FAILURE);
    }

    // lua libraries
    load_lualibs(L);

    // opc libraries
    open_ldir_lib(L);
    open_lpoint_lib(L); // must be called before 'load_api'
    open_lload_lib(L);
    open_lbind_lib(L);
    open_lbinary_lib(L);
    open_lshape_lib(L);
    //open_lunion_lib(L);
    open_lfilesystem_lib(L);

    //lpoint_register_cfunctions(L);

    return L;
}

int main (int argc, char** argv)
{
    lua_State* L = create_and_initialize_lua();
    create_argument_table(L, argc, argv);
    int retval = call_main_program(L, OPC_HOME "/src/main.lua");
    lua_close(L);
    return retval;
}


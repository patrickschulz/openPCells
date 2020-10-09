/*
** $Id: lua.c $
** Lua stand-alone interpreter
** See Copyright Notice in lua.h
*/

#include "lua/lprefix.h"

#include <stdio.h>
#include <stdlib.h>

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
#include "lsupport.h"

#include "config.h"

#define MAINPROGNAME "main.lua"
#define TESTPROGNAME "testsuite/main.lua"

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
static int msghandler (lua_State* L)
{
    const char* msg = lua_tostring(L, 1);
    if (msg == NULL) /* is error object not a string? */
    {
        if (luaL_callmeta(L, 1, "__tostring") &&  /* does it have a metamethod */
                lua_type(L, -1) == LUA_TSTRING)  /* that produces a string? */
        {
            return 1;  /* that is the message */
        }
        else
        {
            msg = lua_pushfstring(L, "(error object is a %s value)",
                    luaL_typename(L, 1));
        }
    }
    luaL_traceback(L, L, msg, 1);
    return 1;
}

static void load_api(lua_State* L)
{
    char* modules[] = {
        "object",
        "shape",
        "geometry",
        "graphics",
        "pcell",
        "generics",
        "stringfile",
        "util",
        "aux",
        "exitcodes",
        "funcobject",
        "reduce",
        NULL
    };
    char** ptr = modules;
    lua_getglobal(L, "_load_module");
    while(*ptr)
    {
        lua_pushvalue(L, -1); // copy _load_module
        lua_pushstring(L, *ptr);
        lua_call(L, 1, 1); // unprotected call since errors are handled in _load_module
        lua_setglobal(L, *ptr);
        ++ptr;
    }
    lua_pop(L, 1); // remove _load_module
}

static void create_argument_table(lua_State* L, int argc, char** argv)
{
    lua_newtable(L);
    for(int i = 1; i < argc; ++i)
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
        status = lua_pcall(L, 0, 0, 1);
    }
    if(status != LUA_OK) 
    {
        const char* msg = lua_tostring(L, -1);
        fprintf(stderr, "%s\n", msg);
        lua_pop(L, 1);
        return 0;
    }
    return status;
}

int main (int argc, char** argv)
{
    lua_State* L = luaL_newstate();
    if (L == NULL) 
    {
        fprintf(stderr, "%s\n", "cannot create state: not enough memory");
        return EXIT_FAILURE;
    }

    // lua libraries
    luaL_openlibs(L);

    // opc libraries
    open_lpoint_lib(L);
    open_lload_lib(L);
    open_lbind_lib(L);
    load_api(L);

    if(argc > 1 && (strcmp(argv[1], "test") == 0))
    {
        create_argument_table(L, argc - 1, argv + 1); // remove 'test' from arguments
        call_main_program(L, OPC_HOME "/" TESTPROGNAME);
    }
    else if(argc > 1 && (strcmp(argv[1], "watch") == 0))
    {
        puts("you called opc with 'watch', but this is currently not implemented. Ignoring and moving on.");
        create_argument_table(L, argc - 1, argv + 1); // remove 'watch' from arguments
        call_main_program(L, OPC_HOME "/" MAINPROGNAME);
    }
    else
    {
        create_argument_table(L, argc, argv);
        call_main_program(L, OPC_HOME "/" MAINPROGNAME);
    }
    lexit(L, 0);
    return 0; // never reached
}


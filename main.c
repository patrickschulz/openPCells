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
    luaL_traceback(L, L, msg, 2);
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
    {LUA_UTF8LIBNAME, luaopen_utf8},
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

static void load_api(lua_State* L)
{
    const char* const modules[] = {
        "lpoint", // lua part of lpoint module
        "technology",
        "interface",
        "config",
        "object",
        "shape",
        "geometry",
        "graphics",
        "generics",
        "stringfile",
        "util",
        "aux",
        "funcobject",
        "reduce",
        "stack",
        "support",
        "profiler",
        "pcell", // load as last module
        NULL
    };
    const char* const * ptr = modules;
    lua_getglobal(L, "_load_module");
    while(*ptr)
    {
        lua_pushvalue(L, -1); // copy _load_module
        lua_pushstring(L, *ptr);
        if(lua_pcall(L, 1, 1, 0) == LUA_OK)
        {
            lua_setglobal(L, *ptr);
        }
        else
        {
            fprintf(stderr, "%s\n", lua_tostring(L, -1));
            lua_close(L);
            exit(1);
        }
        ++ptr;
    }
    lua_pop(L, 1); // remove _load_module
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
        status = lua_pcall(L, 0, 0, 1);
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
    load_api(L); // could fail
    return L;
}

int main (int argc, char** argv)
{
    lua_State* L = create_and_initialize_lua();

    int status = LUA_OK;
    if(argc > 1 && (strcmp(argv[1], "test") == 0))
    {
        create_argument_table(L, argc - 1, argv + 1); // remove 'test' from arguments
        status = call_main_program(L, OPC_HOME "/" TESTPROGNAME);
    }
    else if(argc > 1 && (strcmp(argv[1], "watch") == 0))
    { 
        // remove 'watch' from arguments
        argc = argc - 1;
        argv = argv + 1;

        pid_t pid = fork();
        if(pid == 0) // child
        {
            while(1)
            {
                create_argument_table(L, argc, argv);
                status = call_main_program(L, OPC_HOME "/" MAINPROGNAME);
                if(status != LUA_OK)
                {
                    fprintf(stderr, "%s\n", "opc encountered an error, watch mode will be aborted");
                    break;
                }

                // now reinitialize the program
                // this works as if the program had beed started again, which is what we want
                sleep(1);
                lua_close(L);
                L = create_and_initialize_lua();
            }
                
        }
        else // parent
        {
            printf("created child process (pid: %d)\nyou have to kill it manually once you're done\n", pid);
        }
    }
    else if(argc > 2 && (strcmp(argv[1], "run") == 0))
    {
        const char* filename = argv[2];

        // remove 'watch' from arguments
        argc = argc - 2;
        argv = argv + 2;

        create_argument_table(L, argc, argv);
        char path[200];
        snprintf(path, 200, "%s/%s", OPC_HOME, filename);
        status = call_main_program(L, path);
    }
    else
    {
        create_argument_table(L, argc, argv);
        status = call_main_program(L, OPC_HOME "/" MAINPROGNAME);
    }
    lua_close(L);
    return status == LUA_OK ? 0 : 1;
}


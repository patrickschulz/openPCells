#include "lload.h"
#include "config.h"

#include "lua/lauxlib.h"

#include <stdio.h>
#include <stdlib.h>
#include <errno.h>
#include <string.h>

#include "lsupport.h"

#define LLOAD_BUFSIZE 200

/*
static int msghandler (lua_State* L)
{
    const char* msg = lua_tostring(L, 1);
    if (msg == NULL) // is error object not a string?
    {
        if (luaL_callmeta(L, 1, "__tostring") &&  // does it have a metamethod 
                lua_type(L, -1) == LUA_TSTRING)  // that produces a string? 
        {
            return 1;  // that is the message 
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
*/

static int opc_get_home(lua_State* L)
{
    lua_pushstring(L, OPC_HOME);
    return 1;
}

/*
typedef struct LoadF 
{
    FILE* f;  // file being read
    char buff[LLOAD_BUFSIZE];  // area for reading file
} LoadF;


static const char* getF (lua_State *L, void *ud, size_t *size) {
    LoadF* lf = (LoadF*) ud;
    (void)L;  // not used
    // 'fread' can return > 0 *and* set the EOF flag. If next call to
    // 'getF' called 'fread', it might still wait for user input.
    // The next check avoids this problem.
    if (feof(lf->f)) return NULL;
    *size = fread(lf->buff, 1, sizeof(lf->buff), lf->f);  // read block
    return lf->buff;
}

static int errfile (lua_State *L, const char *what, int fnameindex)
{
    const char *serr = strerror(errno);
    const char *filename = lua_tostring(L, fnameindex) + 1;
    lua_pushfstring(L, "cannot %s %s: %s", what, filename, serr);
    lua_remove(L, fnameindex);
    return LUA_ERRFILE;
}

static int _load(lua_State* L)
{
    const char* modname = lua_tostring(L, -1);
    char filename[LLOAD_BUFSIZE];
    snprintf(filename, LLOAD_BUFSIZE, "%s/%s.lua", OPC_HOME, modname);
    LoadF lf;
    int status, readstatus;
    int fnameindex = lua_gettop(L) + 1;  // index of filename on the stack

    lua_pushfstring(L, "@%s", modname);
    lf.f = fopen(filename, "r");
    if (lf.f == NULL) return errfile(L, "open", fnameindex);

    status = lua_load(L, getF, &lf, lua_tostring(L, -1), NULL);
    readstatus = ferror(lf.f);
    fclose(lf.f);  // close file (even in case of errors)
    if (readstatus)
    {
        lua_settop(L, fnameindex);  // ignore results from 'lua_load'
        return errfile(L, "read", fnameindex);
    }
    lua_remove(L, fnameindex);
    return status;
}

static int opc_load_module(lua_State* L)
{
    // _load expects the module name on the top position of the stack
    int status = _load(L);
    if(status == LUA_OK)
    {
        lua_pushcfunction(L, msghandler);
        lua_insert(L, 1);
        status = lua_pcall(L, 0, 1, 1);
    }
    else
    {
        //fprintf(stderr, "syntax error while loading module '%s'\n", name);
        const char* msg = lua_tostring(L, -1);
        fprintf(stderr, "%s\n", msg);
        lexit(L, 1);
    }
    return 1;
}
*/

int open_lload_lib(lua_State* L)
{
    //lua_pushcfunction(L, opc_load_module);
    //lua_setglobal(L, "_load_module");
    lua_pushcfunction(L, opc_get_home);
    lua_setglobal(L, "_get_opc_home");
    // _load_module is written in lua
    // no error checks, we know what we are doing
    (luaL_dofile(L, OPC_HOME "/" "load.lua"));
    return 0;
}

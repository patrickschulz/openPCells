#include "pcell.common.h"

#include <stdlib.h>
#include <string.h>

#include "lua/lauxlib.h"

#include "_modulemanager.h"
#include "main.lua.h"
#include "main.functions.h"
#include "util.h"
#include "lua_util.h"

#define OPC_PCELL_IMPLEMENTATION
#include "pcell.def.h"
#undef OPC_PCELL_IMPLEMENTATION

// lua bridge
struct lpcell {
    struct pcell_state* pcell_state;
};

static int lpcell_get_cell_filename(lua_State* L)
{
    struct lpcell* lpcell = luaL_checkudata(L, 1, "LPCELL");
    struct pcell_state* pcell_state = lpcell->pcell_state;
    const char* cellname = luaL_checkstring(L, 2);
    for(unsigned int i = 0; i < vector_size(pcell_state->cellpaths); ++i)
    {
        const char* path = vector_get_const(pcell_state->cellpaths, i);
        size_t len = strlen(path) + strlen(cellname) + 5; // '/' + ".lua"
        char* filename = malloc(len + 1);
        snprintf(filename, len + 1, "%s/%s.lua", path, cellname);
        if(util_file_exists(filename))
        {
            // first found matching cell is used
            lua_pushstring(L, filename);
            free(filename);
            return 1;
        }
        free(filename);
    }
    lua_pushfstring(L, "could not find cell '%s' in:\n", cellname);
    unsigned int num = 0;
    for(unsigned int i = 0; i < vector_size(pcell_state->cellpaths); ++i)
    {
        lua_pushstring(L, "  ");
        ++num;
        const char* path = vector_get_const(pcell_state->cellpaths, i);
        lua_pushstring(L, path);
        ++num;
        if(i < vector_size(pcell_state->cellpaths) - 1)
        {
            lua_pushstring(L, "\n");
            ++num;
        }
    }
    lua_concat(L, num + 1);
    lua_error(L);
    return 0;
}

static int lpcell_dprint(lua_State* L)
{
    struct lpcell* lpcell = luaL_checkudata(L, 1, "LPCELL");
    struct pcell_state* pcell_state = lpcell->pcell_state;
    FILE* outfile = stdout;
    if(pcell_state->dprint_target)
    {
        outfile = pcell_state->dprint_target;
    }
    if(pcell_state->enable_dprint)
    {
        // taken from lbaselib.c:
        int n = lua_gettop(L);  /* number of arguments */
        // skip pcell state (first argument)
        for(int i = 2; i <= n; i++) 
        {  /* for each argument */
            size_t l;
            const char *s = luaL_tolstring(L, i, &l);  /* convert it to string */
            if (i > 2)  /* not the first element? */
                fwrite("\t", sizeof(char), 1, outfile); /* add a tab before it */
            fwrite(s, sizeof(char), l, outfile); /* print it */
            lua_pop(L, 1);  /* pop result */
        }
        fwrite("\n", sizeof(char), 1, outfile); /* add a tab before it */
        fflush(outfile);
    }
    return 0;
}

static int _open_lpcell_lib(lua_State* L)
{
    static const luaL_Reg modfuncs[] = {
        { "get_cell_filename",       lpcell_get_cell_filename       },
        { "dprint",                  lpcell_dprint                  },
        { NULL,                      NULL                           }
    };
    luaL_newmetatable(L, "LPCELL");
    // add __index
    lua_pushstring(L, "__index");
    lua_pushvalue(L, -2);
    lua_rawset(L, -3);
    // register functions
    luaL_setfuncs(L, modfuncs, 0);
    lua_pop(L, 1);
    return 0;
}

static void _create_lua_state(lua_State* L, struct pcell_state* pcell_state)
{
    struct lpcell* lpcell = lua_newuserdata(L, sizeof(*lpcell));
    lpcell->pcell_state = pcell_state;
    luaL_setmetatable(L, "LPCELL");
    // no return value, as the value on the stack is used
}

int pcellcommon_load_pcell_library(lua_State* L, struct pcell_state* pcell_state)
{
    module_load_pcell(L);
    _open_lpcell_lib(L);

    lua_getglobal(L, "pcell");
    lua_getfield(L, -1, "register_pcell_state");
    _create_lua_state(L, pcell_state);
    int retval = main_lua_pcall(L, 1, 0);
    if(retval != LUA_OK)
    {
        fputs("could not initialize pcell state\n", stderr);
        lua_close(L);
        return 0;
    }

    if(pcell_state->verbose)
    {
        lua_getglobal(L, "pcell");
        lua_getfield(L, -1, "set_verbose");
        retval = main_lua_pcall(L, 0, 0);
        if(retval != LUA_OK)
        {
            fputs("error while calling pcell.set_verbose()", stderr);
            lua_close(L);
            return 0;
        }
    }

    if(!pcell_state->run_parameter_checks)
    {
        lua_getglobal(L, "pcell");
        lua_getfield(L, -1, "disable_parameter_checks");
        retval = main_lua_pcall(L, 0, 0);
        if(retval != LUA_OK)
        {
            fputs("error while calling pcell.disable_parameter_checks()", stderr);
            lua_close(L);
            return 0;
        }
    }
    return 1;
}

static int _read_table_from_file(lua_State* L, const char* filename)
{
    // call adapted from macro for luaL_dofile (only one return value as a fail-safe)
    if((luaL_loadfile(L, filename) || lua_pcall(L, 0, 1, 0)) != LUA_OK)
    {
        const char* msg = lua_tostring(L, -1);
        fprintf(stderr, "error while loading cell environment file: %s\n", msg);
        return 0;
    }
    return 1;
}

int pcellcommon_load_pfiles(struct pcell_state* pcell_state, lua_State* L)
{
    for(unsigned int i = 0; i < const_vector_size(pcell_state->pfilenames); ++i)
    {
        const char* pfilename = const_vector_get(pcell_state->pfilenames, i);
        int ret = _read_table_from_file(L, pfilename); // don't stop on error
        if(!ret)
        {
            return 0;
        }
        if(lua_type(L, -1) != LUA_TTABLE)
        {
            fprintf(stderr, "pfile '%s' did not return a table, but a %s\n", pfilename, lua_typename(L, lua_type(L, -1)));
            return 0;
        }
        lua_pushnil(L);
        while(lua_next(L, -2) != 0)
        {
            /*
             * FIXME: this was here, but some cells have table parameters,
             *        this would make the use of those in pfiles impossible
            if(lua_type(L, -1) == LUA_TTABLE)
            {
                puts("no nested tables are allowed in parameter files");
                return 0;
            }
            */
            if(lua_type(L, -2) != LUA_TSTRING)
            {
                puts("non-string keys in parameter files are prohibited");
                return 0;
            }
            lua_pushvalue(L, -2);
            lua_pushvalue(L, -2);
            lua_rawset(L, -6);
            lua_pop(L, 1);
        }
        lua_pop(L, 1);
    }
    return 1;
}

int pcellcommon_load_cellenv(lua_State* L, const char* cellenvfilename)
{
    // cell environment
    if(cellenvfilename)
    {
        if(!_read_table_from_file(L, cellenvfilename))
        {
            return 0;
        }
    }
    else
    {
        lua_newtable(L);
    }
    return 1;
}

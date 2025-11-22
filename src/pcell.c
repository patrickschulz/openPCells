#include "pcell.h"

#include "lua/lauxlib.h"

#include <ctype.h>
#include <stdlib.h>
#include <string.h>

#include "cells.h"

#include "main.functions.h"
#include "util.h"
#include "lua_util.h"
#include "ldir.h"
#include "lobject.h"
#include "ldebug.h"

#include "_scriptmanager.h"
#include "_modulemanager.h"

struct pcell_state {
    struct vector* cellpaths;
    struct const_vector* pfilenames;
    FILE* dprint_target;
    int enable_dprint;
    int enable_debug;
    int verbose;
};

struct pcell_state* pcell_initialize_state(void)
{
    struct pcell_state* pcell_state = malloc(sizeof(*pcell_state));
    pcell_state->cellpaths = vector_create(64, free);
    pcell_state->pfilenames = const_vector_create(4);
    pcell_state->dprint_target = NULL;
    pcell_state->enable_dprint = 0;
    pcell_state->enable_debug = 0;
    pcell_state->verbose = 0;
    return pcell_state;
}

void pcell_destroy_state(struct pcell_state* pcell_state)
{
    if(pcell_state->dprint_target)
    {
        fclose(pcell_state->dprint_target);
    }
    vector_destroy(pcell_state->cellpaths);
    const_vector_destroy(pcell_state->pfilenames);
    free(pcell_state);
}

void pcell_append_pfile(struct pcell_state* pcell_state, const char* pfile)
{
    const_vector_append(pcell_state->pfilenames, pfile);
}

void pcell_enable_debug(struct pcell_state* pcell_state)
{
    pcell_state->enable_debug = 1;
}

void pcell_set_dprint_target(struct pcell_state* pcell_state, const char* filename)
{
    pcell_state->dprint_target = fopen(filename, "w");
}

void pcell_enable_dprint(struct pcell_state* pcell_state)
{
    pcell_state->enable_dprint = 1;
}

void pcell_set_verbose(struct pcell_state* pcell_state)
{
    pcell_state->verbose = 1;
}

// lua bridge
struct lpcell {
    struct pcell_state* pcell_state;
};

static void _create_lua_state(lua_State* L, struct pcell_state* pcell_state);
static int _open_lpcell_lib(lua_State* L);

static lua_State* _prepare_layout_generation(struct pcell_state* pcell_state, struct technology_state* techstate)
{
    lua_State* L = main_create_and_initialize_lua();

    // register techstate
    if(techstate)
    {
        lua_pushlightuserdata(L, techstate);
        lua_setfield(L, LUA_REGISTRYINDEX, "techstate");
    }

    // load main modules
    module_load_alignmentgroup(L);
    module_load_aux(L);
    module_load_check(L);
    module_load_globals(L);
    module_load_graphics(L);
    module_load_load(L);
    module_load_stack(L); // must be loaded before pcell (FIXME: explicitly create the lua pcell state)
    module_load_pcell(L);
    module_load_placement(L);
    module_load_routing(L);
    module_load_util(L);
    module_load_layouthelpers(L);

    _open_lpcell_lib(L);

    lua_getglobal(L, "pcell");
    lua_getfield(L, -1, "register_pcell_state");
    _create_lua_state(L, pcell_state);
    int retval = main_lua_pcall(L, 1, 0);
    if(retval != LUA_OK)
    {
        fputs("could not initialize pcell state\n", stderr);
        lua_close(L);
        return NULL;
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
            return NULL;
        }
    }
    return L;
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

static int _load_pfiles(struct pcell_state* pcell_state, lua_State* L)
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

static int _load_cellenv(lua_State* L, const char* cellenvfilename)
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

static struct object* _process_object(lua_State* L, int retval)
{
    if(retval != LUA_OK)
    {
        return NULL;
    }
    struct lobject* lobject = lobject_check_soft(L, -1);
    if(!lobject)
    {
        fputs("cell/cellscript did not return an object\n", stderr);
        return NULL;
    }
    struct object* toplevel = lobject_get_unchecked(lobject);
    lobject_disown(lobject);
    return toplevel;
}

static int _find_key_value(const char* str, char** key, char** value)
{
    const char* ptr = str;
    const char* key_startptr = NULL;
    const char* key_endptr = NULL;
    const char* value_startptr = NULL;
    const char* value_endptr = NULL;
    int found_separator = 0;
    while(*ptr)
    {
        if(!key_startptr && !isspace(*ptr))
        {
            key_startptr = ptr;
        }
        if(found_separator && !isspace(*ptr))
        {
            value_startptr = ptr;
        }
        if(*ptr == '=')
        {
            found_separator = 1;
        }
        if(key_startptr && (isspace(*ptr) || found_separator) && !key_endptr)
        {
            key_endptr = ptr;
        }
        ++ptr;
        value_endptr = ptr;
    }
    if(!found_separator) // not a key-value pair
    {
        return 0;
    }
    if((value_endptr - key_startptr) == 1) // malformed string
    {
        return 0;
    }
    *key = malloc(key_endptr - key_startptr + 1);
    strncpy(*key, key_startptr, key_endptr - key_startptr);
    (*key)[key_endptr - key_startptr] = 0;
    *value = malloc(value_endptr - value_startptr + 1);
    strncpy(*value, value_startptr, value_endptr - value_startptr);
    (*value)[value_endptr - value_startptr] = 0;
    return 1;
}

/*
static void _process_input_arguments(lua_State* L, struct const_vector* cellargs)
{
    for(unsigned int i = 0; i < const_vector_size(cellargs); ++i)
    {
        const char* str = const_vector_get(cellargs, i);
        char* key;
        char* value;
        int result = _find_key_value(str, &key, &value);
        if(result) // key-value pair
        {
            // check if key is already present
            lua_pushstring(L, key);
            lua_gettable(L, -2);
            if(!lua_isnil(L, -1))
            {
                fprintf(stdout, "the parameters '%s' is defined by a pfile but overwritten on the commandline\n", key);
            }
            lua_pop(L, 1);
            // write key-value pair
            lua_pushstring(L, key);
            lua_pushstring(L, value);
            lua_settable(L, -3);
        }
        else // additional argument
        {
            // FIXME: do something with this
        }
    }
}
*/

struct object* pcell_create_layout_from_script(struct pcell_state* pcell_state, struct technology_state* techstate, const char* scriptname, const char* toplevelname, struct const_vector* cellargs, const char *cellenvfilename)
{
    (void)toplevelname;
    lua_State* L = _prepare_layout_generation(pcell_state, techstate);
    struct object* toplevel = NULL;
    if(!L)
    {
        return NULL;
    }
    lua_getglobal(L, "pcell");
    lua_getfield(L, -1, "create_layout_from_script");
    lua_pushstring(L, scriptname);
    // cell arguments
    lua_newtable(L);
    for(unsigned int i = 0; i < const_vector_size(cellargs); ++i)
    {
        const char* str = const_vector_get(cellargs, i);
        lua_pushstring(L, str);
        lua_rawseti(L, -2, i + 1);
    }
    // load cell environment
    if(!_load_cellenv(L, cellenvfilename))
    {
        fprintf(stderr, "could not load cell environment in '%s'\n", cellenvfilename);
        goto create_layout_from_script_finish;
    }
    // arguments:
    // (1) scriptpath
    // (2) args
    // (3) cellenv
    int retval = main_lua_pcall(L, 3, 1);
    toplevel = _process_object(L, retval);
create_layout_from_script_finish:
    lua_close(L);
    return toplevel;
}

struct object* pcell_create_layout_env(struct pcell_state* pcell_state, struct technology_state* techstate, const char* cellname, const char* toplevelname, const char* cellenvfilename)
{
    lua_State* L = _prepare_layout_generation(pcell_state, techstate);
    if(!L)
    {
        return NULL;
    }
    struct object* toplevel = NULL;
    // get function
    lua_getglobal(L, "pcell");
    lua_getfield(L, -1, "create_layout_env");
    // push arguments: cellname and object name
    lua_pushstring(L, cellname);
    lua_pushstring(L, toplevelname);
    // assemble cell arguments
    lua_newtable(L);
    if(!_load_pfiles(pcell_state, L))
    {
        fputs("could not load pfiles\n", stderr);
        goto create_layout_finish;
    }
    // load cell environment
    if(!_load_cellenv(L, cellenvfilename))
    {
        fprintf(stderr, "could not load cell environment in '%s'\n", cellenvfilename);
        goto create_layout_finish;
    }
    // call layout generation function
    int retval = main_lua_pcall(L, 4, 1);
    // check for errors and retrieve object in C
    toplevel = _process_object(L, retval);
create_layout_finish:
    lua_close(L);
    return toplevel;
}

void pcell_prepend_cellpath(struct pcell_state* pcell_state, const char* path)
{
    vector_prepend(pcell_state->cellpaths, util_strdup(path));
}

void pcell_append_cellpath(struct pcell_state* pcell_state, const char* path)
{
    vector_append(pcell_state->cellpaths, util_strdup(path));
}

void pcell_list_cellpaths(const struct pcell_state* pcell_state)
{
    for(unsigned int i = 0; i < vector_size(pcell_state->cellpaths); ++i)
    {
        puts(vector_get(pcell_state->cellpaths, i));
    }
}

void pcell_list_cells(struct pcell_state* pcell_state, const char* listformat)
{
    lua_State* L = util_create_basic_lua_state();
    module_load_aux(L);
    if(!lua_isnil(L, -1))
    {
        lua_setglobal(L, "aux");
    }
    open_ldir_lib(L);

    lua_newtable(L);
    lua_newtable(L);
    for(unsigned int i = 0; i < vector_size(pcell_state->cellpaths); ++i)
    {
        lua_pushstring(L, vector_get_const(pcell_state->cellpaths, i));
        lua_rawseti(L, -2, i + 1);
    }
    lua_setfield(L, -2, "cellpaths");
    if(listformat)
    {
        lua_pushstring(L, listformat);
        lua_setfield(L, -2, "listformat");
    }
    lua_setglobal(L, "args");
    script_call_list_cells(L);
    lua_close(L);
}

static cell_layout_func _get_layout_function(struct pcell_state* pcell_state, const char* cellname)
{
    // FIXME
    (void)pcell_state;
    (void)cellname;
    return cell_powergrid_layout;
}

struct object* pcell_create_layout(const char* cellname, struct technology_state* techstate, struct pcell_state* pcell_state)
{
    cell_layout_func layout_func = _get_layout_function(pcell_state, cellname);
    struct object* cell = object_create("__EMPTY__");
    int ret = layout_func(pcell_state, techstate, cell);
    if(!ret)
    {
        // FIXME: error message, clean up
        object_destroy(cell);
        return NULL;
    }
    return cell;
}

void pcell_list_parameters(struct pcell_state* pcell_state, struct technology_state* techstate, const char* cellname, const char* parametersformat, struct const_vector* parameternames)
{
    lua_State* L = _prepare_layout_generation(pcell_state, techstate);

    // assemble cell arguments
    lua_newtable(L);
    // cell name
    lua_pushstring(L, cellname);
    lua_setfield(L, -2, "cell");
    // format
    if(parametersformat)
    {
        lua_pushstring(L, parametersformat);
        lua_setfield(L, -2, "parametersformat");
    }
    lua_pushboolean(L, techstate ? 0 : 1);
    lua_setfield(L, -2, "generictech");
    // parameter names
    size_t numposargs = 0;
    lua_newtable(L);
    for(size_t i = 0; i < const_vector_size(parameternames); ++i)
    {
        lua_pushstring(L, const_vector_get(parameternames, i));
        lua_rawseti(L, -2, numposargs + 1);
        ++numposargs;
    }
    if(numposargs > 0)
    {
        lua_setfield(L, -2, "parameternames");
    }
    else
    {
        lua_pop(L, 1);
    }
    lua_setglobal(L, "args");

    int retval = script_call_list_parameters(L);
    if(retval != LUA_OK)
    {
        puts("error while running list_parameters.lua");
    }
    lua_close(L);
}

void pcell_list_anchors(struct pcell_state* pcell_state, const char* cellname, const char* anchorsformat, struct const_vector* anchornames)
{
    lua_State* L = _prepare_layout_generation(pcell_state, NULL); // don't need technology

    // assemble cell arguments
    lua_newtable(L);
    // cell name
    lua_pushstring(L, cellname);
    lua_setfield(L, -2, "cell");
    // format
    if(anchorsformat)
    {
        lua_pushstring(L, anchorsformat);
        lua_setfield(L, -2, "anchorsformat");
    }
    // anchor names
    size_t numposargs = 0;
    lua_newtable(L);
    for(size_t i = 0; i < const_vector_size(anchornames); ++i)
    {
        lua_pushstring(L, const_vector_get(anchornames, i));
        lua_rawseti(L, -2, numposargs + 1);
        ++numposargs;
    }
    if(numposargs > 0)
    {
        lua_setfield(L, -2, "anchornames");
    }
    else
    {
        lua_pop(L, 1);
    }
    lua_setglobal(L, "args");

    int retval = script_call_list_anchors(L);
    if(retval != LUA_OK)
    {
        puts("error while running list_anchors.lua");
    }
    lua_close(L);
}

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

static void _create_lua_state(lua_State* L, struct pcell_state* pcell_state)
{
    struct lpcell* lpcell = lua_newuserdata(L, sizeof(*lpcell));
    lpcell->pcell_state = pcell_state;
    luaL_setmetatable(L, "LPCELL");
    // no return value, as the value on the stack is used
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

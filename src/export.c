#include "export.h"

#include "lua/lua.h"
#include "lua/lauxlib.h"

#include <stdlib.h>
#include <stdio.h>
#include <string.h>

#include "export_common.h"
#include "export_writer.h"
#include "filesystem.h"
#include "gdsexport.h"
#include "lua_util.h"
#include "skillexport.h"
#include "util.h"

#define EXPORT_STATUS_SUCCESS 0
#define EXPORT_STATUS_NOTFOUND 1
#define EXPORT_STATUS_LOADERROR 2

struct export_state {
    struct const_vector* searchpaths;
    char* exportname;
    char* exportlayername;
    const char* basename;
    char leftdelim, rightdelim;
    const char* const * exportoptions;
    int expand_namecontext;
    int writeports;
    int writechildrenports;
};

struct export_state* export_create_state(void)
{
    struct export_state* state = malloc(sizeof(*state));
    if(!state)
    {
        return NULL;
    }
    memset(state, 0, sizeof(*state));
    state->searchpaths = const_vector_create(1);
    state->expand_namecontext = 1;
    state->writeports = 1;
    return state;
}

void export_destroy_state(struct export_state* state)
{
    const_vector_destroy(state->searchpaths);
    if(state->exportname)
    {
        free(state->exportname);
    }
    if(state->exportlayername)
    {
        free(state->exportlayername);
    }
    free(state);
}

void export_add_searchpath(struct export_state* state, const char* path)
{
    const_vector_append(state->searchpaths, path);
}

void export_set_basename(struct export_state* state, const char* basename)
{
    state->basename = basename;
}

void export_set_export_options(struct export_state* state, const char* const* exportoptions)
{
    state->exportoptions = exportoptions;
}

void export_set_namecontext_expansion(struct export_state* state, int expand)
{
    state->expand_namecontext = expand;
}

void export_disable_ports(struct export_state* state)
{
    state->writeports = 0;
}

void export_set_write_children_ports(struct export_state* state, int writechildrenports)
{
    state->writechildrenports = writechildrenports;
}

void export_set_bus_delimiters(struct export_state* state, char leftdelim, char rightdelim)
{
    state->leftdelim = leftdelim;
    state->rightdelim = rightdelim;
}

static void _get_exportname(const char* exportname, struct const_vector* searchpaths, char** exportname_ptr, char** exportlayername_ptr)
{
    if(!util_split_string(exportname, ':', exportlayername_ptr, exportname_ptr)) // export layers were not specified
    {
        *exportname_ptr = util_strdup(exportname);
        char* exportlayername_from_function = export_get_export_layername(searchpaths, *exportname_ptr);
        if(exportlayername_from_function)
        {
            *exportlayername_ptr = exportlayername_from_function;
        }
        else
        {
            *exportlayername_ptr = util_strdup(exportname);
        }
    }
}

void export_set_exportname(struct export_state* state, const char* str)
{
    char *exportname, *exportlayername;
    _get_exportname(str, state->searchpaths, &exportname, &exportlayername);
    state->exportname = exportname;
    state->exportlayername = exportlayername;
}

const char* export_get_layername(const struct export_state* state)
{
    return state->exportlayername;
}

static struct export_functions* _get_export_functions(const char* exportname)
{
    struct export_functions* funcs = NULL;
    if(strcmp(exportname, "gds") == 0)
    {
        funcs = gdsexport_get_export_functions();
    }
    else if(strcmp(exportname, "SKILL") == 0)
    {
        funcs = skillexport_get_export_functions();
    }
    else
    {

    }
    return funcs;
}

char* export_get_export_layername(struct const_vector* searchpaths, const char* exportname)
{
    struct export_functions* funcs = _get_export_functions(exportname);
    if(funcs) // C-defined exports
    {
        char* techexport = NULL;
        if(funcs->get_techexport)
        {
            techexport = util_strdup(funcs->get_techexport());
        }
        export_destroy_functions(funcs);
        return techexport;
    }
    else // lua-defined exports
    {
        if(searchpaths)
        {
            for(unsigned int i = 0; i < const_vector_size(searchpaths); ++i)
            {
                const char* searchpath = const_vector_get(searchpaths, i);
                size_t len = strlen(searchpath) + strlen(exportname) + 11; // + 11: "init.lua" + 2 * '/' + terminating zero
                char* exportfilename = malloc(len);
                snprintf(exportfilename, len, "%s/%s/init.lua", searchpath, exportname);
                if(!filesystem_exists(exportfilename))
                {
                    continue;
                }
                lua_State* L = util_create_basic_lua_state();
                int ret = luaL_dofile(L, exportfilename);
                free(exportfilename);
                if(ret != LUA_OK)
                {
                    fprintf(stderr, "error while loading export '%s': %s\n", exportname, lua_tostring(L, -1));
                    lua_close(L);
                    break;
                }
                if(lua_type(L, -1) == LUA_TTABLE)
                {
                    lua_getfield(L, -1, "get_techexport");
                    if(!lua_isnil(L, -1))
                    {
                        int ret = lua_pcall(L, 0, 1, 0);
                        if(ret != LUA_OK)
                        {
                            fprintf(stderr, "error while calling get_techexport: %s\n", lua_tostring(L, -1));
                            lua_close(L);
                            return NULL;
                        }
                        else
                        {
                            char* s = util_strdup(lua_tostring(L, -1));
                            lua_close(L);
                            return s;
                        }
                    }
                    else
                    {
                        lua_close(L);
                        return NULL;
                    }
                }
                lua_close(L);
            }
        }
    }
    return NULL;
}

static int _check_function(lua_State* L, const char* funcname)
{
    lua_getfield(L, -1, funcname);
    if(lua_isnil(L, -1))
    {
        lua_pop(L, 1);
        return 0;
    }
    if(lua_type(L, -1) != LUA_TFUNCTION)
    {
        lua_pop(L, 1);
        return 0;
    }
    lua_pop(L, 1);
    return 1;
}

static int _call_or_pop_nil(lua_State* L, int numargs)
{
    if(!lua_isnil(L, -1 - numargs))
    {
        int ret = lua_pcall(L, numargs, 0, 0);
        if(ret != LUA_OK)
        {
            return ret;
        }
    }
    else
    {
        lua_pop(L, 1 + numargs);
    }
    return LUA_OK;
}

static int _check_lua_export(lua_State* L)
{
    if(!_check_function(L, "get_extension"))
    {
        return 0;
    }
    if(!_check_function(L, "write_rectangle"))
    {
        return 0;
    }
    if(!_check_function(L, "write_polygon"))
    {
        if(!_check_function(L, "write_triangle"))
        {
            return 0;
        }
    }
    if(!_check_function(L, "write_label"))
    {
        if(!_check_function(L, "write_port"))
        {
            return 0;
        }
    }
    if(!_check_function(L, "finalize"))
    {
        return 0;
    }
    return 1;
}

static char* _find_lua_export(const struct const_vector* searchpaths, const char* exportname)
{
    if(searchpaths)
    {
        for(unsigned int i = 0; i < const_vector_size(searchpaths); ++i)
        {
            const char* searchpath = const_vector_get(searchpaths, i);
            size_t len = strlen(searchpath) + strlen(exportname) + 11; // + 11: "init.lua" + 2 * '/' + terminating zero
            char* exportfilename = malloc(len);
            snprintf(exportfilename, len, "%s/%s/init.lua", searchpath, exportname);
            if(filesystem_exists(exportfilename))
            {
                return exportfilename;
            }
            free(exportfilename);
        }
    }
    return NULL;
}

int export_write_toplevel(struct object* toplevel, struct export_state* state)
{
    if(object_is_pseudo(toplevel))
    {
        // FIXME: why can't the toplevel object be pseudo?
        puts("export: toplevel is a pseudo object");
        return 0;
    }

    if(object_is_empty(toplevel))
    {
        puts("export: toplevel is empty");
        return 0;
    }

    struct export_data* data = export_create_data();
    char* extension;
    int status = EXPORT_STATUS_NOTFOUND;

    int ret = 1;

    struct export_functions* funcs = _get_export_functions(state->exportname);
    if(funcs) // C-defined exports
    {
        struct export_writer* writer = export_writer_create_C(funcs, data);
        export_writer_write_toplevel(writer, toplevel, state->expand_namecontext, state->writeports, state->writechildrenports, state->leftdelim, state->rightdelim);
        export_writer_destroy(writer);
        extension = util_strdup(funcs->get_extension());
        status = EXPORT_STATUS_SUCCESS;
    }
    else // lua-defined exports
    {
        char* exportfilename = _find_lua_export(state->searchpaths, state->exportname);
        lua_State* L = util_create_basic_lua_state();
        ret = luaL_dofile(L, exportfilename);
        free(exportfilename);
        if(ret != LUA_OK)
        {
            status = EXPORT_STATUS_LOADERROR;
            lua_close(L);
            ret = 0;
            goto EXPORT_CLEANUP;
        }
        if(lua_type(L, -1) == LUA_TTABLE)
        {
            // check minimal function support
            if(!_check_lua_export(L))
            {
                fprintf(stderr, "export '%s' must define at least the functions 'get_extension', 'write_rectangle', 'write_polygon' (or 'write_triangle'), 'write_port'/'write_label' and 'finalize'\n", state->exportname);
                status = EXPORT_STATUS_LOADERROR;
                lua_close(L);
                ret = 0;
                goto EXPORT_CLEANUP;
            }

            // parse and set export cmd options
            if(state->exportoptions)
            {
                lua_getfield(L, -1, "set_options");
                lua_newtable(L);
                const char* const * opt = state->exportoptions;
                int numopts = 1;
                while(*opt)
                {
                    // split string at whitespace
                    const char* str = *opt;
                    while(*str)
                    {
                        const char* end = str;
                        while(*end && *end != ' ')
                        {
                            ++end;
                        }
                        lua_pushlstring(L, str, end - str);
                        lua_rawseti(L, -2, numopts);
                        ++numopts;
                        if(*end)
                        {
                            str = end + 1;
                        }
                        else
                        {
                            str = end;
                        }
                    }
                    ++opt;
                }
                ret = _call_or_pop_nil(L, 1);
                if(ret != LUA_OK)
                {
                    const char* msg = lua_tostring(L, -1);
                    fprintf(stderr, "error while setting up options for lua export: %s\n", msg);
                    lua_close(L);
                    ret = 0;
                    goto EXPORT_CLEANUP;
                }
            }

            struct export_writer* writer = export_writer_create_lua(L, data);
            ret = export_writer_write_toplevel(writer, toplevel, state->expand_namecontext, state->writeports, state->writechildrenports, state->leftdelim, state->rightdelim);
            export_writer_destroy(writer);
            if(!ret)
            {
                const char* msg = lua_tostring(L, -1);
                fprintf(stderr, "error while calling lua export: %s\n", msg);
                lua_close(L);
                ret = 0;
                goto EXPORT_CLEANUP;
            }

            lua_getfield(L, -1, "get_extension");
            ret = lua_pcall(L, 0, 1, 0);
            if(ret != LUA_OK)
            {
                const char* msg = lua_tostring(L, -1);
                fprintf(stderr, "error while calling lua export: %s\n", msg);
                lua_close(L);
                ret = 0;
                goto EXPORT_CLEANUP;
            }
            extension = util_strdup(lua_tostring(L, -1));
            lua_pop(L, 1); // pop extension
            status = EXPORT_STATUS_SUCCESS;
            lua_close(L);
        }
        else
        {
            lua_close(L);
        }
    }

    if(status == EXPORT_STATUS_SUCCESS)
    {
        if(*state->basename == '-' && !*(state->basename + 1)) // send to standard output
        {
            export_data_write_to_file(data, stdout);
        }
        else
        {
            size_t len = strlen(state->basename) + strlen(extension) + 2; // + 2: '.' and the terminating zero
            char* filename = malloc(len);
            snprintf(filename, len + 2, "%s.%s", state->basename, extension);
            FILE* file = fopen(filename, "w");
            export_data_write_to_file(data, file);
            fclose(file);
            free(extension);
            free(filename);
        }
        export_destroy_functions(funcs);
        ret = 1;
        goto EXPORT_CLEANUP;
    }
    else if(status == EXPORT_STATUS_NOTFOUND)
    {
        printf("could not find export '%s'\n", state->exportname);
        ret = 0;
        goto EXPORT_CLEANUP;
    }
    else // EXPORT_STATUS_LOADERROR
    {
        puts("error while loading export");
        ret = 0;
        goto EXPORT_CLEANUP;
    }
EXPORT_CLEANUP:
    export_destroy_data(data);
    return ret;
}


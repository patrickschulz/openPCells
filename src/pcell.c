#include "pcell.h"

#include "lua/lauxlib.h"
#include <stdlib.h>
#include <string.h>

#include "util.h"
#include "lobject.h"

struct pcell_state* pcell_initialize_state(void)
{
    struct pcell_state* pcell_state = malloc(sizeof(*pcell_state));
    pcell_state->used_names = vector_create();
    pcell_state->references = vector_create();
    pcell_state->cellpaths = vector_create();
    return pcell_state;
}

static void _destroy_cellref(void* ptr)
{
    struct cellreference* cref = ptr;
    object_destroy(cref->cell);
    free(cref->identifier);
    free(cref);
}

static void _destroy_used_name(void* ptr)
{
    struct used_name* entry = ptr;
    free(entry->identifier);
    free(entry);
}

void pcell_destroy_state(struct pcell_state* pcell_state)
{
    vector_destroy(pcell_state->used_names, _destroy_used_name);
    vector_destroy(pcell_state->references, _destroy_cellref);
    vector_destroy(pcell_state->cellpaths, free);
    free(pcell_state);
}

static char* _unique_name(struct pcell_state* pcell_state, const char* identifier)
{
    unsigned int* ptr = NULL;
    for(unsigned int i = 0; i < vector_size(pcell_state->used_names); ++i)
    {
        struct used_name* entry = vector_get(pcell_state->used_names, i);
        if(strcmp(entry->identifier, identifier) == 0)
        {
            ptr = &entry->numused;
            break;
        }
    }
    if(!ptr)
    {
        struct used_name* entry = malloc(sizeof(*entry));
        entry->identifier = util_copy_string(identifier);
        entry->numused = 0;
        ptr = &entry->numused;
        vector_append(pcell_state->used_names, entry);
    }
    *ptr += 1;
    unsigned int digits = util_num_digits(*ptr);
    unsigned int len = strlen(identifier) + 1 + digits; // + 1 for underscore
    char* str = malloc(len + 1);
    snprintf(str, len + 1, "%s_%*d", identifier, digits, *ptr);
    return str;
}

const char* pcell_add_cell_reference(struct pcell_state* pcell_state, object_t* cell, const char* identifier)
{
    struct cellreference* cref = malloc(sizeof(*cref));
    cref->cell = cell;
    cref->identifier = _unique_name(pcell_state, identifier);
    cref->numused = 0;
    vector_append(pcell_state->references, cref);
    return cref->identifier;
}

object_t* pcell_use_cell_reference(struct pcell_state* pcell_state, const char* identifier)
{
    for(unsigned int i = 0; i < vector_size(pcell_state->references); ++i)
    {
        struct cellreference* cref = vector_get(pcell_state->references, i);
        if(strcmp(cref->identifier, identifier) == 0)
        {
            cref->numused += 1;
            return cref->cell;
        }
    }
    return NULL;
}

void pcell_unlink_cell_reference(struct pcell_state* pcell_state, const char* identifier)
{
    for(unsigned int i = 0; i < vector_size(pcell_state->references); ++i)
    {
        struct cellreference* cref = vector_get(pcell_state->references, i);
        if(strcmp(cref->identifier, identifier) == 0)
        {
            if(cref->numused > 0)
            {
                cref->numused -= 1;
            }
            // FIXME: error otherwise?
        }
    }
    // FIXME: error if not found?
}

size_t pcell_get_reference_count(struct pcell_state* pcell_state)
{
    return vector_size(pcell_state->references);
}

struct cellreference* pcell_get_indexed_cell_reference(struct pcell_state* pcell_state, unsigned int i)
{
    return vector_get(pcell_state->references, i);
}

//////////////// lua bridge
static int lpcell_add_cell_reference(lua_State* L)
{
    lua_getfield(L, LUA_REGISTRYINDEX, "pcellstate");
    struct pcell_state* pcell_state = lua_touserdata(L, -1);
    lua_pop(L, 1); // pop pcell state
    lobject_t* lobject = lua_touserdata(L, 1);
    const char* identifier = lua_tostring(L, 2);
    const char* new_identifier = pcell_add_cell_reference(pcell_state, lobject->object, identifier);
    lua_pushstring(L, new_identifier);
    lobject->destroy = 0; // memory is not managed by lua
    return 1;
}

static int lpcell_append_cellpath(lua_State* L)
{
    lua_getfield(L, LUA_REGISTRYINDEX, "pcellstate");
    struct pcell_state* pcell_state = lua_touserdata(L, -1);
    lua_pop(L, 1); // pop pcell state
    const char* path = lua_tostring(L, 1);
    vector_append(pcell_state->cellpaths, util_copy_string(path));
    return 0;
}

static int lpcell_prepend_cellpath(lua_State* L)
{
    lua_getfield(L, LUA_REGISTRYINDEX, "pcellstate");
    struct pcell_state* pcell_state = lua_touserdata(L, -1);
    lua_pop(L, 1); // pop pcell state
    const char* path = lua_tostring(L, 1);
    vector_prepend(pcell_state->cellpaths, util_copy_string(path));
    return 0;
}

static int lpcell_list_cellpaths(lua_State* L)
{
    lua_getfield(L, LUA_REGISTRYINDEX, "pcellstate");
    struct pcell_state* pcell_state = lua_touserdata(L, -1);
    lua_pop(L, 1); // pop pcell state
    for(unsigned int i = 0; i < vector_size(pcell_state->cellpaths); ++i)
    {
        puts(vector_get(pcell_state->cellpaths, i));
    }
    return 0;
}

static int lpcell_get_cell_filename(lua_State* L)
{
    lua_getfield(L, LUA_REGISTRYINDEX, "pcellstate");
    struct pcell_state* pcell_state = lua_touserdata(L, -1);
    lua_pop(L, 1); // pop pcell state
    const char* cellname = lua_tostring(L, 1);
    for(unsigned int i = 0; i < vector_size(pcell_state->cellpaths); ++i)
    {
        const char* path = vector_get(pcell_state->cellpaths, i);
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
    }
    /*
    local str = {
        string.format("could not find cell '%s' in:", cellname),
    }
    for _, path in ipairs(state.cellpaths) do
        table.insert(str, string.format("  %s", path))
    end
    error(table.concat(str, "\n"))
    */
    lua_pushfstring(L, "could not find cell '%s'", cellname);
    lua_error(L);
    return 0;
}

int open_lpcell_lib(lua_State* L)
{
    lua_newtable(L);
    static const luaL_Reg modfuncs[] =
    {
        { "add_cell_reference",      lpcell_add_cell_reference      },
        { "append_cellpath",         lpcell_append_cellpath         },
        { "prepend_cellpath",        lpcell_prepend_cellpath        },
        { "list_cellpaths",          lpcell_list_cellpaths          },
        { "get_cell_filename",       lpcell_get_cell_filename       },
        { NULL,                      NULL                           }
    };
    luaL_setfuncs(L, modfuncs, 0);
    lua_setglobal(L, "pcell");
    return 0;
}


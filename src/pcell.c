#include "pcell.h"

#include "lua/lauxlib.h"
#include <stdlib.h>
#include <string.h>

#include "util.h"
#include "lua_util.h"
#include "lobject.h"
#include "ldir.h"

#include "scriptmanager.h"
#include "modulemanager.h"

struct used_name {
    char* identifier;
    unsigned int numused;
};

struct cellreference {
    char* identifier;
    struct object* cell;
    unsigned int numused;
};

struct pcell_state {
    struct vector* used_names;
    struct vector* references;
    struct vector* cellpaths;
};

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

struct pcell_state* pcell_initialize_state(struct vector* cellpaths_to_prepend, struct vector* cellpaths_to_append)
{
    struct pcell_state* pcell_state = malloc(sizeof(*pcell_state));
    pcell_state->used_names = vector_create(64, _destroy_used_name);
    pcell_state->references = vector_create(64, _destroy_cellref);
    pcell_state->cellpaths = vector_create(64, free);
    if(cellpaths_to_prepend)
    {
        for(unsigned int i = 0; i < vector_size(cellpaths_to_prepend); ++i)
        {
            pcell_prepend_cellpath(pcell_state, vector_get(cellpaths_to_prepend, i));
        }
    }
    if(cellpaths_to_append)
    {
        for(unsigned int i = 0; i < vector_size(cellpaths_to_append); ++i)
        {
            pcell_append_cellpath(pcell_state, vector_get(cellpaths_to_append, i));
        }
    }
    return pcell_state;
}

void pcell_destroy_state(struct pcell_state* pcell_state)
{
    vector_destroy(pcell_state->used_names);
    vector_destroy(pcell_state->references);
    vector_destroy(pcell_state->cellpaths);
    free(pcell_state);
}

void pcell_prepend_cellpath(struct pcell_state* pcell_state, const char* path)
{
    vector_prepend(pcell_state->cellpaths, strdup(path));
}

void pcell_append_cellpath(struct pcell_state* pcell_state, const char* path)
{
    vector_append(pcell_state->cellpaths, strdup(path));
}

// FIXME: the cell reference system is partly broken.
// currently, the user passes a name that they want as name for that cell
// the pcell module resolves that into a unique name, even if the same is exactly the same
// the second issue is the unique naming system. Currently, using ascii characters a layout
// hierarchy could have a naming scheme that messes up the name system in the pcell module
// a better way has to be found
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
        entry->identifier = strdup(identifier);
        entry->numused = 0;
        ptr = &entry->numused;
        vector_append(pcell_state->used_names, entry);
    }
    *ptr += 1;
    char* str;
    unsigned int len = strlen(identifier);
    if(*ptr == 1) // handle names that are only used once specially
    {
        str = malloc(len + 1);
        snprintf(str, len + 1, "%s", identifier);
    }
    else
    {
        unsigned int digits = util_num_digits(*ptr);
        str = malloc(len + 7 + digits + 1); // + 7: _~OPC~_
        snprintf(str, len + 7 + digits + 1, "%s_~OPC~_%*d", identifier, digits, *ptr);
    }
    return str;
}

const char* pcell_add_cell_reference(struct pcell_state* pcell_state, struct object* cell, const char* identifier)
{
    struct cellreference* cref = malloc(sizeof(*cref));
    cref->cell = cell;
    cref->identifier = _unique_name(pcell_state, identifier);
    cref->numused = 0;
    vector_append(pcell_state->references, cref);
    return cref->identifier;
}

struct object* pcell_use_cell_reference(struct pcell_state* pcell_state, const char* identifier)
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

struct object* pcell_get_cell_reference_by_name(struct pcell_state* pcell_state, const char* identifier)
{
    for(unsigned int i = 0; i < vector_size(pcell_state->references); ++i)
    {
        struct cellreference* cref = vector_get(pcell_state->references, i);
        if(strcmp(cref->identifier, identifier) == 0)
        {
            return cref->cell;
        }
    }
    return NULL;
}

//////////////// lua bridge
static int lpcell_add_cell_reference(lua_State* L)
{
    lua_getfield(L, LUA_REGISTRYINDEX, "pcellstate");
    struct pcell_state* pcell_state = lua_touserdata(L, -1);
    lua_pop(L, 1); // pop pcell state
    struct lobject* lobject = lobject_check(L, 1);
    const char* identifier = luaL_checkstring(L, 2);
    const char* new_identifier = pcell_add_cell_reference(pcell_state, lobject_get(lobject), identifier);
    lua_pushstring(L, new_identifier);
    lobject_disown(lobject); // memory is not managed by lua
    return 1;
}

static int lpcell_get_cell_reference(lua_State* L)
{
    lua_getfield(L, LUA_REGISTRYINDEX, "pcellstate");
    struct pcell_state* pcell_state = lua_touserdata(L, -1);
    lua_pop(L, 1); // pop pcell state
    const char* identifier = luaL_checkstring(L, 1);
    struct object* cell = pcell_get_cell_reference_by_name(pcell_state, identifier);
    lobject_adapt(L, cell);
    return 1;
}

void pcell_list_cellpaths(struct pcell_state* pcell_state)
{
    for(unsigned int i = 0; i < vector_size(pcell_state->cellpaths); ++i)
    {
        puts(vector_get(pcell_state->cellpaths, i));
    }
}

// reference cell iterator
struct cell_reference_iterator {
    const struct pcell_state* state;
    size_t index;
};

struct cell_reference_iterator* pcell_create_cell_reference_iterator(const struct pcell_state* pcell_state)
{
    struct cell_reference_iterator* it = malloc(sizeof(*it));
    it->state = pcell_state;
    it->index = 0;
    return it;
}

void pcell_cell_reference_iterator_get(struct cell_reference_iterator* it, char** identifier, struct object** reference, int* numused)
{
    struct cellreference* cellrefreference = vector_get(it->state->references, it->index);
    *identifier = cellrefreference->identifier;
    *reference = cellrefreference->cell;
    *numused = cellrefreference->numused;
}

int pcell_cell_reference_iterator_is_valid(const struct cell_reference_iterator* it)
{
    return it->index < vector_size(it->state->references);
}

void pcell_cell_reference_iterator_advance(struct cell_reference_iterator* it)
{
    ++it->index;
}

void pcell_destroy_cell_reference_iterator(struct cell_reference_iterator* it)
{
    free(it);
}

struct cell_reference_const_iterator {
    const struct pcell_state* state;
    size_t index;
};

struct cell_reference_const_iterator* pcell_create_cell_reference_const_iterator(const struct pcell_state* pcell_state)
{
    struct cell_reference_const_iterator* it = malloc(sizeof(*it));
    it->state = pcell_state;
    it->index = 0;
    return it;
}

void pcell_cell_reference_const_iterator_get(struct cell_reference_const_iterator* it, const char** identifier, const struct object** reference, int* numused)
{
    struct cellreference* cellrefreference = vector_get(it->state->references, it->index);
    *identifier = cellrefreference->identifier;
    *reference = cellrefreference->cell;
    *numused = cellrefreference->numused;
}

int pcell_cell_reference_const_iterator_is_valid(const struct cell_reference_const_iterator* it)
{
    return it->index < vector_size(it->state->references);
}

void pcell_cell_reference_const_iterator_advance(struct cell_reference_const_iterator* it)
{
    ++it->index;
}

void pcell_destroy_cell_reference_const_iterator(struct cell_reference_const_iterator* it)
{
    free(it);
}

void pcell_list_cells(struct pcell_state* pcell_state, const char* listformat)
{
    lua_State* L = util_create_basic_lua_state();
    module_load_support(L);
    if(!lua_isnil(L, -1))
    {
        lua_setglobal(L, "support");
    }
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
        lua_pushstring(L, vector_get(pcell_state->cellpaths, i));
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

void pcell_foreach_cell_reference(struct pcell_state* pcell_state, void (*cellfunc)(struct object*))
{
    struct cell_reference_iterator* it = pcell_create_cell_reference_iterator(pcell_state);
    while(pcell_cell_reference_iterator_is_valid(it))
    {
        char* refidentifier;
        struct object* refcell;
        int refnumused;
        pcell_cell_reference_iterator_get(it, &refidentifier, &refcell, &refnumused);
        cellfunc(refcell);
        pcell_cell_reference_iterator_advance(it);
    }
    pcell_destroy_cell_reference_iterator(it);
}

static int lpcell_get_cell_filename(lua_State* L)
{
    lua_getfield(L, LUA_REGISTRYINDEX, "pcellstate");
    struct pcell_state* pcell_state = lua_touserdata(L, -1);
    lua_pop(L, 1); // pop pcell state
    const char* cellname = luaL_checkstring(L, 1);
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
        free(filename);
    }
    lua_newtable(L);
    lua_pushfstring(L, "could not find cell '%s' in:\n", cellname);
    for(unsigned int i = 0; i < vector_size(pcell_state->cellpaths); ++i)
    {
        lua_pushstring(L, "  ");
        const char* path = vector_get(pcell_state->cellpaths, i);
        lua_pushstring(L, path);
        if(i < vector_size(pcell_state->cellpaths) - 1)
        {
            lua_pushstring(L, "\n");
        }
    }
    lua_concat(L, 3 * vector_size(pcell_state->cellpaths));
    lua_error(L);
    return 0;
}

int open_lpcell_lib(lua_State* L)
{
    lua_newtable(L);
    static const luaL_Reg modfuncs[] =
    {
        { "add_cell_reference",      lpcell_add_cell_reference      },
        { "get_cell_reference",      lpcell_get_cell_reference      },
        { "get_cell_filename",       lpcell_get_cell_filename       },
        { NULL,                      NULL                           }
    };
    luaL_setfuncs(L, modfuncs, 0);
    lua_setglobal(L, "pcell");
    return 0;
}


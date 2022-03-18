#include "pcell.h"

#include "lua/lauxlib.h"
#include <stdlib.h>
#include <string.h>

#include "util.h"
#include "lobject.h"

struct used_name
{
    char* name;
    unsigned int num;
};

struct cellreferences
{
    struct used_name** used_names;
    size_t names_size;
    size_t names_capacity;

    struct cellreference** references;
    size_t size;
    size_t capacity;
};

static struct cellreferences* references;

void pcell_initialize_references(void)
{
    references = malloc(sizeof(*references));
    memset(references, 0, sizeof(*references));
}

void pcell_destroy_references(void)
{
    for(unsigned int i = 0; i < references->names_size; ++i)
    {
        free(references->used_names[i]->name);
        free(references->used_names[i]);
    }
    free(references->used_names);
    for(unsigned int i = 0; i < references->size; ++i)
    {
        object_destroy(references->references[i]->cell);
        free(references->references[i]->identifier);
        free(references->references[i]);
    }
    free(references->references);
    free(references);
}

char* _unique_name(const char* identifier)
{
    unsigned int* ptr = NULL;
    for(unsigned int i = 0; i < references->names_size; ++i)
    {
        if(strcmp(references->used_names[i]->name, identifier) == 0)
        {
            ptr = &references->used_names[i]->num;
            break;
        }
    }
    if(!ptr)
    {
        if(references->names_capacity == references->names_size)
        {
            references->names_capacity = references->names_capacity == 0 ? 1 : references->names_capacity * 2;
            struct used_name** names = realloc(references->used_names, sizeof(*names) * references->names_capacity);
            references->used_names = names;
        }
        references->used_names[references->names_size] = malloc(sizeof(*references->used_names[references->size]));
        references->used_names[references->names_size]->name = malloc(strlen(identifier) + 1);
        strcpy(references->used_names[references->names_size]->name, identifier);
        references->used_names[references->names_size]->num = 0;
        ptr = &references->used_names[references->names_size]->num;
        references->names_size += 1;
    }
    *ptr += 1;
    unsigned int digits = util_num_digits(*ptr);
    unsigned int len = strlen(identifier) + 1 + digits; // + 1 for underscore
    char* str = malloc(len + 1);
    snprintf(str, len + 1, "%s_%*d", identifier, digits, *ptr);
    return str;
}

const char* pcell_add_cell_reference(object_t* cell, const char* identifier)
{
    if(references->capacity == references->size)
    {
        references->capacity = references->capacity == 0 ? 1 : references->capacity * 2;
        struct cellreference** r = realloc(references->references, sizeof(*r) * references->capacity);
        references->references = r;
    }
    references->references[references->size] = malloc(sizeof(*references->references[references->size]));
    references->references[references->size]->cell = cell;
    references->references[references->size]->identifier = _unique_name(identifier);
    references->references[references->size]->numused = 0;
    references->size += 1;
    return references->references[references->size - 1]->identifier;
}

object_t* pcell_use_cell_reference(const char* identifier)
{
    for(unsigned int i = 0; i < references->size; ++i)
    {
        if(strcmp(references->references[i]->identifier, identifier) == 0)
        {
            references->references[i]->numused += 1;
            return references->references[i]->cell;
        }
    }
    return NULL;
}

void pcell_unlink_cell_reference(const char* identifier)
{
    for(unsigned int i = 0; i < references->size; ++i)
    {
        if(strcmp(references->references[i]->identifier, identifier) == 0)
        {
            if(references->references[i]->numused > 0)
            {
                references->references[i]->numused -= 1;
            }
            // FIXME: error otherwise?
        }
    }
    // FIXME: error if not found?
}

size_t pcell_get_reference_count(void)
{
    return references->size;
}

struct cellreference* pcell_get_indexed_cell_reference(unsigned int i)
{
    return references->references[i];
}

//////////////// lua bridge
int lpcell_add_cell_reference(lua_State* L)
{
    lobject_t* lobject = lua_touserdata(L, 1);
    const char* identifier = lua_tostring(L, 2);
    const char* new_identifier = pcell_add_cell_reference(lobject->object, identifier);
    lua_pushstring(L, new_identifier);
    lobject->destroy = 0;
    return 1;
}

int lpcell_get_cell_reference(lua_State* L)
{
    return 0;
}

int lpcell_foreach_cell_references(lua_State* L)
{
    for(unsigned int i = 0; i < references->size; ++i)
    {
        lua_pushvalue(L, 1);
        object_t* cell = references->references[i]->cell;
        lobject_adapt(L, cell);
        lua_call(L, 1, 0);
    }
    return 0;
}

int open_lpcell_lib(lua_State* L)
{
    lua_newtable(L);
    static const luaL_Reg modfuncs[] =
    {
        { "add_cell_reference",      lpcell_add_cell_reference      },
        { "get_cell_reference",      lpcell_get_cell_reference      },
        { "foreach_cell_references", lpcell_foreach_cell_references },
        { NULL,                      NULL                           }
    };
    luaL_setfuncs(L, modfuncs, 0);
    lua_setglobal(L, "pcell");
    return 0;
}

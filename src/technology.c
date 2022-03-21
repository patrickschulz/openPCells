#include "technology.h"

#include "lua/lauxlib.h"
#include <stdlib.h>
#include <string.h>

#include "util.h"
#include "vector.h"

static void _insert_lpp_pairs(lua_State* L, struct keyvaluearray* map)
{
    lua_pushnil(L);
    while (lua_next(L, -2) != 0)
    {
        switch(lua_type(L, -1))
        {
            case LUA_TNUMBER:
                keyvaluearray_add_int(map, lua_tostring(L, -2), lua_tointeger(L, -1));
                break;
            case LUA_TSTRING:
                keyvaluearray_add_string(map, lua_tostring(L, -2), lua_tostring(L, -1));
                break;
            case LUA_TBOOLEAN:
                keyvaluearray_add_boolean(map, lua_tostring(L, -2), lua_toboolean(L, -1));
                break;
        }
        lua_pop(L, 1); // pop value, keep key for next iteration
    }
}

struct layerentry
{
    char* name;
    generics_t* layer;
};

static struct vector* layertable;

static void _insert_layer(char* layername, generics_t* layer)
{
    struct layerentry* entry = malloc(sizeof(*entry));
    entry->name = layername;
    entry->layer = layer;
    vector_append(layertable, entry);
}

generics_t* technology_make_layer(lua_State* L)
{
    generics_t* layer;
    if(lua_isnil(L, -1))
    {
        layer = generics_create_empty_layer();
    }
    else
    {
        // count entries
        size_t num = 0;
        lua_pushnil(L);
        while(lua_next(L, -2) != 0)
        {
            lua_pop(L, 1); // pop value, keep key for next iteration
            num += 1;
        }

        layer = generics_create_premapped_layer(num);
        unsigned int i = 0;
        lua_pushnil(L);
        while (lua_next(L, -2) != 0)
        {
            const char* name = lua_tostring(L, -2);
            layer->exportnames[i] = util_copy_string(name);
            layer->data[i] = keyvaluearray_create();
            _insert_lpp_pairs(L, layer->data[i]);
            lua_pop(L, 1); // pop value, keep key for next iteration
            ++i;
        }
    }
    return layer;
}

int technology_load_layermap(lua_State* L)
{
    const char* name = lua_tostring(L, 1);
    luaL_dofile(L, name);
    lua_pushnil(L);
    while(lua_next(L, -2) != 0)
    {
        char* layername = util_copy_string(lua_tostring(L, -2));
        lua_getfield(L, -1, "layer");
        generics_t* layer = technology_make_layer(L);
        _insert_layer(layername, layer);
        lua_pop(L, 1); // pop layer table
        lua_pop(L, 1); // pop value, keep key for next iteration
    }
    return 0;
}

generics_t* technology_get_layer(const char* layername)
{
    for(unsigned int i = 0; i < vector_size(layertable); ++i)
    {
        struct layerentry* entry = vector_get(layertable, i);
        if(strcmp(entry->name, layername) == 0)
        {
            return entry->layer;
        }
    }
    return NULL;
}

void technology_initialize_layertable(void)
{
    layertable = vector_create();
}

void technology_destroy_layertable(void)
{
    for(unsigned int i = 0; i < vector_size(layertable); ++i)
    {
        struct layerentry* entry = vector_get(layertable, i);
        free(entry->name);
        generics_destroy_layer(entry->layer);
        free(entry);
    }
    vector_destroy(layertable);
}

int open_ltechnology_lib(lua_State* L)
{
    lua_newtable(L);
    static const luaL_Reg modfuncs[] =
    {
        { "load_layermap", technology_load_layermap },
        { NULL,            NULL                      }
    };
    luaL_setfuncs(L, modfuncs, 0);
    lua_setglobal(L, "technology");

    return 0;
}

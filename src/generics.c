#include "generics.h"

#include <stdlib.h>
#include <stdio.h>
#include <string.h>

#include "lua/lua.h"

struct hashmap generics_layer_map;

uint32_t _hash(const char* data)
{
    uint32_t a = 1;
    uint32_t b = 0;
    const uint32_t MODADLER = 65521;
 
    size_t i = 0;
    while(data[i])
    {
        a = (a + data[i]) % MODADLER;
        b = (b + a) % MODADLER;
        i++;
    }
    return (b << 16) | a;
}

generics_t* _get(struct hashmap* map, uint32_t key)
{
    for(unsigned int i = 0; i < map->size; ++i)
    {
        if(map->entries[i].key == key)
        {
            return map->entries[i].layer;
        }
    }
    return NULL;
}

void _insert(struct hashmap* map, uint32_t key, generics_t* layer)
{
    if(map->capacity == map->size)
    {
        map->capacity += 1;
        struct hashmapentry* entries = realloc(map->entries, sizeof(*entries) * map->capacity);
        map->entries = entries;
    }
    map->entries[map->size].key = key;
    map->entries[map->size].layer = layer;
    map->size += 1;
}

static struct generic_premapped_t* _create_premapped(void)
{
    struct generic_premapped_t* premapped = malloc(sizeof(*premapped));
    return premapped;
}

static struct generic_mapped_t* _create_mapped(void)
{
    struct generic_mapped_t* mapped = malloc(sizeof(*mapped));
    mapped->data = keyvaluearray_create();
    keyvaluearray_add_int(mapped->data, "layer", 11);
    keyvaluearray_add_int(mapped->data, "purpose", 0);
    return mapped;
}

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

static void _store_mapped(lua_State* L, struct generic_premapped_t* premapped)
{
    // count entries
    size_t num = 0;
    lua_pushnil(L);
    while (lua_next(L, -2) != 0)
    {
        lua_pop(L, 1); // pop value, keep key for next iteration
        num += 1;
    }

    premapped->data = calloc(num, sizeof(*premapped->data));
    premapped->exportnames = calloc(num, sizeof(*premapped->exportnames));
    premapped->size = num;

    unsigned int i = 0;
    lua_pushnil(L);
    while (lua_next(L, -2) != 0)
    {
        const char* name = lua_tostring(L, -2);
        premapped->exportnames[i] = malloc(strlen(name) + 1);
        strcpy(premapped->exportnames[i], name);
        premapped->data[i] = keyvaluearray_create();
        _insert_lpp_pairs(L, premapped->data[i]);
        lua_pop(L, 1); // pop value, keep key for next iteration
        ++i;
    }
    lua_pop(L, 1); // pop 'content' table
}

generics_t* generics_create_metal(int num, lua_State* L)
{
    char str[10];
    snprintf(str, 10, "metal%4d", num);
    uint32_t key = _hash(str);
    generics_t* layer = _get(&generics_layer_map, key);
    if(!layer)
    {
        layer = malloc(sizeof(*layer));
        layer->layer = _create_premapped();
        layer->is_pre = 1;
        lua_getglobal(L, "technology");
        lua_pushstring(L, "__map");
        lua_rawget(L, -2);
        lua_pushfstring(L, "M%d", num);
        lua_call(L, 1, 1);
        _store_mapped(L, layer->layer);
        lua_pop(L, 1); // pop technology table
        _insert(&generics_layer_map, key, layer);
    }
    return layer;
}

void generics_destroy(generics_t* layer)
{
    if(layer->is_pre)
    {
        struct generic_premapped_t* premapped = layer->layer;
        for(unsigned int i = 0; i < premapped->size; ++i)
        {
            free(premapped->exportnames[i]);
            keyvaluearray_destroy(premapped->data[i]);
        }
    }
    else
    {
        keyvaluearray_destroy(((struct generic_mapped_t*)layer->layer)->data);
    }
    free(layer);
}

void generics_resolve_premapped_layers(const char* name)
{
    for(unsigned int i = 0; i < generics_layer_map.size; ++i)
    {
        generics_t* layer = generics_layer_map.entries[i].layer;
        if(layer->is_pre)
        {
            struct generic_premapped_t* premapped = layer->layer;
            struct keyvaluearray* kvmap = NULL;
            for(unsigned int j = 0; j < premapped->size; ++j)
            {
                if(strcmp(name, premapped->exportnames[j]) == 0)
                {
                    kvmap = premapped->data[j];
                }
                else
                {
                    keyvaluearray_destroy(premapped->data[j]);
                }
                free(premapped->exportnames[j]);
            }
            free(premapped);
            struct generic_mapped_t* mapped = malloc(sizeof(*mapped));
            mapped->data = kvmap;
            layer->layer = mapped;
            layer->is_pre = 0;
        }
    }
}


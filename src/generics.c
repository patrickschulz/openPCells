#include "generics.h"

#include <stdlib.h>
#include <stdio.h>
#include <string.h>

#include "lua/lua.h"

struct hashmapentry
{
    uint32_t key;
    struct layer_collection* layers;
};

struct hashmap // FIXME: pseudo hashmap, but it will probably be good enough as there are not many elements
{
    struct hashmapentry* entries;
    size_t size;
    size_t capacity;
};

struct hashmap* generics_layer_map;

#define METAL_MAGIC_IDENTIFIER 0
#define OTHER_MAGIC_IDENTIFIER 1

uint32_t _hash(const uint8_t* data, size_t size)
{
    uint32_t a = 1;
    uint32_t b = 0;
    const uint32_t MODADLER = 65521;
 
    for(unsigned int i = 0; i < size; ++i)
    {
        a = (a + data[i]) % MODADLER;
        b = (b + a) % MODADLER;
        i++;
    }
    return (b << 16) | a;
}

struct layer_collection* _get(struct hashmap* map, uint32_t key)
{
    for(unsigned int i = 0; i < map->size; ++i)
    {
        if(map->entries[i].key == key)
        {
            return map->entries[i].layers;
        }
    }
    return NULL;
}

void _insert(struct hashmap* map, uint32_t key, struct layer_collection* layers)
{
    if(map->capacity == map->size)
    {
        map->capacity += 1;
        struct hashmapentry* entries = realloc(map->entries, sizeof(*entries) * map->capacity);
        map->entries = entries;
    }
    map->entries[map->size].key = key;
    map->entries[map->size].layers = layers;
    map->size += 1;
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

static void _store_mapped(lua_State* L, struct layer_collection* collection)
{
    lua_len(L, -1);
    collection->size = lua_tointeger(L, -1);
    collection->layers = calloc(collection->size, sizeof(*collection->layers));
    lua_pop(L, 1);
    for(unsigned int coll = 0; coll < collection->size; ++coll)
    {
        lua_rawgeti(L, -1, coll + 1);
        // count entries
        size_t num = 0;
        lua_pushnil(L);
        while (lua_next(L, -2) != 0)
        {
            lua_pop(L, 1); // pop value, keep key for next iteration
            num += 1;
        }

        struct generic_premapped_t* premapped = malloc(sizeof(*premapped));
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
        lua_pop(L, 1); // pop premapped table
        generics_t* layer = malloc(sizeof(*layer));
        layer->is_pre = 1;
        layer->layer = premapped;
        collection->layers[coll] = layer;
    }
}

struct layer_collection* _create_layer_collection(void)
{
    struct layer_collection* collection = malloc(sizeof(*collection));
    collection->size = 0;
    return collection;
}

struct layer_collection* _ensure_translated_layers(struct hashmap* map, uint32_t key, const char* identifier, lua_State* L)
{
    struct layer_collection* collection = _get(map, key);
    if(!collection)
    {
        collection = _create_layer_collection();
        lua_getglobal(L, "technology");
        lua_pushstring(L, "__map");
        lua_rawget(L, -2);
        lua_pushstring(L, identifier);
        lua_call(L, 1, 1);
        _store_mapped(L, collection);
        lua_pop(L, 1); // pop technology table
        _insert(map, key, collection);
    }
    return collection;
}

struct layer_collection* generics_create_metal(int num, lua_State* L)
{
    if(num < 0)
    {
        lua_getglobal(L, "technology");
        lua_pushstring(L, "get_config_value");
        lua_rawget(L, -2);
        lua_pushstring(L, "metals");
        lua_call(L, 1, 1);
        unsigned int nummetals = lua_tointeger(L, -1);
        lua_pop(L, 1);
        num = nummetals + num + 1;
    }
    uint8_t data[sizeof(num) + 1];
    data[0] = METAL_MAGIC_IDENTIFIER;
    memcpy(data + 1, &num, sizeof(num));
    uint32_t key = _hash(data, sizeof(num) + 1);

    struct layer_collection* collection = _ensure_translated_layers(generics_layer_map, key, "M1", L);
    return collection;
}

struct layer_collection* generics_create_other(const char* str, size_t len, lua_State* L)
{
    uint8_t data[len + 1];
    data[0] = OTHER_MAGIC_IDENTIFIER;
    memcpy(data + 1, str, len);
    uint32_t key = _hash(data, len + 1);

    struct layer_collection* collection = _ensure_translated_layers(generics_layer_map, key, str, L);
    return collection;
}

void generics_destroy_layer_collection(struct layer_collection* layers)
{
    for(unsigned int i = 0; i < layers->size; ++i)
    {
        generics_destroy(layers->layers[i]);
    }
    free(layers->layers);
    free(layers);
}

void _destroy_premapped(struct generic_premapped_t* premapped, int full)
{
    if(full)
    {
        for(unsigned int i = 0; i < premapped->size; ++i)
        {
            free(premapped->exportnames[i]);
            keyvaluearray_destroy(premapped->data[i]);
        }
    }
    free(premapped->exportnames);
    free(premapped->data);
    free(premapped);
}

void _destroy_mapped(struct generic_mapped_t* mapped)
{
    keyvaluearray_destroy(mapped->data);
    free(mapped);
}

void generics_destroy(generics_t* layer)
{
    if(layer->is_pre)
    {
        _destroy_premapped(layer->layer, 1);
    }
    else
    {
        _destroy_mapped(layer->layer);
    }
    free(layer);
}

void generics_resolve_premapped_layers(const char* name)
{
    for(unsigned int i = 0; i < generics_layer_map->size; ++i)
    {
        for(unsigned int j = 0; j < generics_layer_map->entries[i].layers->size; ++j)
        {
            generics_t* layer = generics_layer_map->entries[i].layers->layers[j];
            if(layer->is_pre)
            {
                struct generic_premapped_t* premapped = layer->layer;
                struct keyvaluearray* kvmap = NULL;
                for(unsigned int k = 0; k < premapped->size; ++k)
                {
                    if(strcmp(name, premapped->exportnames[k]) == 0)
                    {
                        kvmap = premapped->data[k];
                    }
                    else
                    {
                        keyvaluearray_destroy(premapped->data[k]);
                    }
                    free(premapped->exportnames[k]);
                }
                _destroy_premapped(premapped, 0);
                struct generic_mapped_t* mapped = malloc(sizeof(*mapped));
                mapped->data = kvmap;
                layer->layer = mapped;
                layer->is_pre = 0;
            }
        }
    }
}

void generics_initialize_layer_map(void)
{
    generics_layer_map = malloc(sizeof(*generics_layer_map));
    generics_layer_map->entries = NULL;
    generics_layer_map->capacity = 0;
    generics_layer_map->size = 0;
}

void generics_destroy_layer_map(void)
{
    for(unsigned int i = 0; i < generics_layer_map->size; ++i)
    {
        generics_destroy_layer_collection(generics_layer_map->entries[i].layers);
    }
    free(generics_layer_map->entries);
    free(generics_layer_map);
}


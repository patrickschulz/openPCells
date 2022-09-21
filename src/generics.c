#include "generics.h"

#include <stdlib.h>
#include <stdio.h>
#include <string.h>

#include "vector.h"
#include "technology.h"
#include "util.h"
#include "tagged_value.h"

struct generics_entry {
    char* exportname;
    struct hashmap* data;
};

struct generics {
    char* name;
    struct vector* entries; // stores struct generics_entry*
};

struct layermap {
    struct hashmap* hashmap;
    struct vector* extra_layers;
};

static struct generics_entry* _create_entry(const char* name)
{
    struct generics_entry* entry = malloc(sizeof(*entry));
    entry->exportname = strdup(name);
    entry->data = hashmap_create();
    return entry;
}

static void _destroy_entry(void* entryv)
{
    struct generics_entry* entry = entryv;
    free(entry->exportname);
    hashmap_destroy(entry->data, tagged_value_destroy);
    free(entry);
}

struct generics* generics_create_empty_layer(const char* name)
{
    struct generics* layer = malloc(sizeof(*layer));
    memset(layer, 0, sizeof(*layer));
    layer->name = strdup(name);
    return layer;
}

struct generics* generics_create_premapped_layer(const char* name, size_t size)
{
    struct generics* layer = generics_create_empty_layer(name);
    layer->entries = vector_create(size);
    return layer;
}

static void _insert_lpp_pairs(lua_State* L, struct hashmap* map)
{
    lua_pushnil(L);
    while (lua_next(L, -2) != 0)
    {
        struct tagged_value* value = NULL;
        switch(lua_type(L, -1))
        {
            case LUA_TNUMBER:
                value = tagged_value_create_integer(lua_tointeger(L, -1));
                break;
            case LUA_TSTRING:
                value = tagged_value_create_string(lua_tostring(L, -1));
                break;
            case LUA_TBOOLEAN:
                value = tagged_value_create_boolean(lua_toboolean(L, -1));
                break;
        }
        if(value)
        {
            hashmap_insert(map, lua_tostring(L, -2), value);
        }
        lua_pop(L, 1); // pop value, keep key for next iteration
    }
}

struct generics* generics_make_layer_from_lua(const char* layername, lua_State* L)
{
    struct generics* layer;
    if(lua_isnil(L, -1))
    {
        layer = generics_create_empty_layer(layername);
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

        layer = generics_create_premapped_layer(layername, num);
        lua_pushnil(L);
        while (lua_next(L, -2) != 0)
        {
            const char* name = lua_tostring(L, -2);
            struct generics_entry* entry = _create_entry(name);
            _insert_lpp_pairs(L, entry->data);
            vector_append(layer->entries, entry);
            lua_pop(L, 1); // pop value, keep key for next iteration
        }
    }
    return layer;
}

static const struct generics* _get_or_create_layer(struct layermap* layermap, struct technology_state* techstate, const char* layername)
{
    if(!hashmap_exists(layermap->hashmap, layername))
    {
        struct generics* layer = technology_get_layer(techstate, layername);
        hashmap_insert(layermap->hashmap, layername, layer);
        return layer;
    }
    else
    {
        return hashmap_get(layermap->hashmap, layername);
    }
}

const struct generics* generics_create_metal(struct layermap* layermap, struct technology_state* techstate, int num)
{
    num = technology_resolve_metal(techstate, num);
    size_t len = 1 + util_num_digits(num);
    char* layername = malloc(len + 1);
    snprintf(layername, len + 1, "M%d", num);
    const struct generics* layer = _get_or_create_layer(layermap, techstate, layername);
    free(layername);
    return layer;
}

const struct generics* generics_create_metalport(struct layermap* layermap, struct technology_state* techstate, int num)
{
    num = technology_resolve_metal(techstate, num);
    size_t len = 1 + util_num_digits(num) + 4; // M + %d + port
    char* layername = malloc(len + 1);
    snprintf(layername, len + 1, "M%dport", num);
    const struct generics* layer = _get_or_create_layer(layermap, techstate, layername);
    free(layername);
    return layer;
}

const struct generics* generics_create_viacut(struct layermap* layermap, struct technology_state* techstate, int metal1, int metal2)
{
    metal1 = technology_resolve_metal(techstate, metal1);
    metal2 = technology_resolve_metal(techstate, metal2);
    if(metal1 > metal2)
    {
        int tmp = metal2;
        metal2 = metal1;
        metal1 = tmp;
    }
    size_t len = 6 + 1 + util_num_digits(metal1) + 1 + util_num_digits(metal2); // viacut + M + %d + M + %d
    char* layername = malloc(len + 1);
    snprintf(layername, len + 1, "viacutM%dM%d", metal1, metal2);
    const struct generics* layer = _get_or_create_layer(layermap, techstate, layername);
    free(layername);
    return layer;
}

const struct generics* generics_create_contact(struct layermap* layermap, struct technology_state* techstate, const char* region)
{
    size_t len = 7 + strlen(region); // contact + %s
    char* layername = malloc(len + 1);
    snprintf(layername, len + 1, "contact%s", region);
    const struct generics* layer = _get_or_create_layer(layermap, techstate, layername);
    free(layername);
    return layer;
}

const struct generics* generics_create_oxide(struct layermap* layermap, struct technology_state* techstate, int num)
{
    size_t len = 5 + util_num_digits(num); // oxide + %d
    char* layername = malloc(len + 1);
    snprintf(layername, len + 1, "oxide%d", num);
    const struct generics* layer = _get_or_create_layer(layermap, techstate, layername);
    free(layername);
    return layer;
}

const struct generics* generics_create_implant(struct layermap* layermap, struct technology_state* techstate, char polarity)
{
    size_t len = 8; // [np]implant
    char* layername = malloc(len + 1);
    snprintf(layername, len + 1, "%cimplant", polarity);
    const struct generics* layer = _get_or_create_layer(layermap, techstate, layername);
    free(layername);
    return layer;
}

const struct generics* generics_create_vthtype(struct layermap* layermap, struct technology_state* techstate, char channeltype, int vthtype)
{
    size_t len = 7 + 1 + util_num_digits(vthtype); // vthtype + %c + %d
    char* layername = malloc(len + 1);
    snprintf(layername, len + 1, "vthtype%c%d", channeltype, vthtype);
    const struct generics* layer = _get_or_create_layer(layermap, techstate, layername);
    free(layername);
    return layer;
}

const struct generics* generics_create_other(struct layermap* layermap, struct technology_state* techstate, const char* layername)
{
    const struct generics* layer = _get_or_create_layer(layermap, techstate, layername);
    return layer;
}

const struct generics* generics_create_otherport(struct layermap* layermap, struct technology_state* techstate, const char* str)
{
    size_t len = strlen(str) + 4; // + "port"
    char* layername = malloc(len + 1);
    snprintf(layername, len + 1, "%sport", str);
    const struct generics* layer = _get_or_create_layer(layermap, techstate, layername);
    free(layername);
    return layer;
}

const struct generics* generics_create_special(struct layermap* layermap, struct technology_state* techstate)
{
    const struct generics* layer = _get_or_create_layer(layermap, techstate, "special");
    return layer;
}

int generics_is_empty(const struct generics* layer)
{
    if(layer->entries)
    {
        return vector_size(layer->entries) == 0;
    }
    else
    {
        return 1;
    }
}

int generics_is_layer_name(const struct generics* layer, const char* layername)
{
    return strcmp(layer->name, layername) == 0;
}

const struct hashmap* generics_get_first_layer_data(const struct generics* layer)
{
    const struct generics_entry* entry = vector_get_const(layer->entries, 0);
    return entry->data;
}

void generics_insert_extra_layer(struct layermap* layermap, struct generics* layer)
{
    vector_append(layermap->extra_layers, layer);
}

void generics_destroy_layer(void* layerv)
{
    struct generics* layer = layerv;
    if(layer->entries)
    {
        vector_destroy(layer->entries, _destroy_entry);
    }
    free(layer->name);
    free(layer);
}

struct layermap* generics_initialize_layer_map(void)
{
    struct layermap* layermap = malloc(sizeof(*layermap));
    layermap->hashmap = hashmap_create();
    layermap->extra_layers = vector_create(1024);
    return layermap;
}

void generics_destroy_layer_map(struct layermap* layermap)
{
    hashmap_destroy(layermap->hashmap, NULL);
    vector_destroy(layermap->extra_layers, generics_destroy_layer); // (externally) premapped layers are owned by the layer map
    free(layermap);
}

int _resolve_layer(struct generics* layer, const char* exportname)
{
    int found = 0;
    if(!generics_is_empty(layer)) // empty layers are ignored
    {
        unsigned int idx = 0;
        for(unsigned int k = 0; k < vector_size(layer->entries); ++k)
        {
            const struct generics_entry* entry = vector_get_const(layer->entries, k);
            if(strcmp(exportname, entry->exportname) == 0)
            {
                found = 1;
                idx = k;
            }
        }
        if(!found)
        {
            printf("no layer data for export type '%s' found (layer: %s)\n", exportname, layer->name);
            return 0;
        }

        // swap data
        // for mapped entries, only the first entry is used, but it is easier to keep the data here
        // and let _destroy_generics free all data, regardless if a layer is premapped or mapped
        vector_swap(layer->entries, 0, idx);
    }
    return 1;
}

int generics_resolve_premapped_layers(struct layermap* layermap, const char* exportname)
{
    // main layers
    struct hashmap_iterator* it = hashmap_iterator_create(layermap->hashmap);
    while(hashmap_iterator_is_valid(it))
    {
        struct generics* layer = hashmap_iterator_value(it);
        if(!_resolve_layer(layer, exportname))
        {
            return 0;
        }
        hashmap_iterator_next(it);
    }
    hashmap_iterator_destroy(it);

    // extra layers
    for(unsigned int i = 0; i < vector_size(layermap->extra_layers); ++i)
    {
        struct generics* layer = vector_get(layermap->extra_layers, i);
        if(!_resolve_layer(layer, exportname))
        {
            return 0;
        }
    }
    return 1;
}

struct layer_iterator {
    struct hashmap_iterator* hashmap_iterator;
    struct vector_iterator* extra_iterator;
};

struct layer_iterator* layer_iterator_create(struct layermap* layermap)
{
    struct layer_iterator* it = malloc(sizeof(*it));
    it->hashmap_iterator = hashmap_iterator_create(layermap->hashmap);
    it->extra_iterator = vector_iterator_create(layermap->extra_layers);
    return it;
}

int layer_iterator_is_valid(struct layer_iterator* iterator)
{
    return
        hashmap_iterator_is_valid(iterator->hashmap_iterator)
        ||
        vector_iterator_is_valid(iterator->extra_iterator)
        ;
}

void* layer_iterator_get(struct layer_iterator* iterator)
{
    if(hashmap_iterator_is_valid(iterator->hashmap_iterator))
    {
        return hashmap_iterator_value(iterator->hashmap_iterator);
    }
    else
    {
        return vector_iterator_get(iterator->extra_iterator);
    }
}

void layer_iterator_next(struct layer_iterator* iterator)
{
    if(hashmap_iterator_is_valid(iterator->hashmap_iterator))
    {
        hashmap_iterator_next(iterator->hashmap_iterator);
    }
    else
    {
        vector_iterator_next(iterator->extra_iterator);
    }
}

void layer_iterator_destroy(struct layer_iterator* iterator)
{
    hashmap_iterator_destroy(iterator->hashmap_iterator);
    vector_iterator_destroy(iterator->extra_iterator);
}


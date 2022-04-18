#include "generics.h"

#include <stdlib.h>
#include <stdio.h>
#include <string.h>

#include "technology.h"
#include "util.h"

#define METAL_IDENTIFIER          1
#define METALPORT_IDENTIFIER      2
#define VIA_IDENTIFIER            3
#define CONTACT_IDENTIFIER        4
#define OXIDE_IDENTIFIER          5
#define IMPLANT_IDENTIFIER        6
#define VTHTYPE_IDENTIFIER        7
#define OTHER_IDENTIFIER          8
#define SPECIAL_IDENTIFIER        9


static uint32_t _hash(const uint8_t* data, size_t size)
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

generics_t* generics_create_empty_layer(const char* name)
{
    generics_t* layer = malloc(sizeof(*layer));
    memset(layer, 0, sizeof(*layer));
    layer->name = util_copy_string(name);
    return layer;
}

generics_t* generics_create_premapped_layer(const char* name, size_t size)
{
    generics_t* layer = generics_create_empty_layer(name);
    layer->data = calloc(size, sizeof(*layer->data));
    layer->exportnames = calloc(size, sizeof(*layer->exportnames));
    layer->size = size;
    layer->is_pre = 1;
    return layer;
}

void _insert_layer(struct layermap* generics_layer_map, uint32_t key, generics_t* layer)
{
    if(generics_layer_map->capacity == generics_layer_map->size)
    {
        generics_layer_map->capacity += 1;
        struct hashmapentry** entries = realloc(generics_layer_map->entries, sizeof(*entries) * generics_layer_map->capacity);
        generics_layer_map->entries = entries;
    }
    generics_layer_map->entries[generics_layer_map->size] = malloc(sizeof(struct hashmapentry));
    generics_layer_map->entries[generics_layer_map->size]->key = key;
    generics_layer_map->entries[generics_layer_map->size]->layer = layer;
    generics_layer_map->entries[generics_layer_map->size]->destroy = 0;
    generics_layer_map->size += 1;
}

generics_t* generics_create_metal(struct layermap* generics_layer_map, struct technology_state* techstate, int num)
{
    num = technology_resolve_metal(techstate, num);
    uint32_t key = (METAL_IDENTIFIER << 24) | (num & 0x00ffffff);
    generics_t* layer = generics_get_layer(generics_layer_map, key);
    if(!layer)
    {
        size_t len = 1 + util_num_digits(num);
        char* layername = malloc(len + 1);
        snprintf(layername, len + 1, "M%d", num);
        layer = technology_get_layer(techstate, layername);
        free(layername);
        _insert_layer(generics_layer_map, key, layer);
    }
    return layer;
}

generics_t* generics_create_metalport(struct layermap* generics_layer_map, struct technology_state* techstate, int num)
{
    num = technology_resolve_metal(techstate, num);
    uint32_t key = (METALPORT_IDENTIFIER << 24) | (num & 0x00ffffff);
    generics_t* layer = generics_get_layer(generics_layer_map, key);
    if(!layer)
    {
        size_t len = 1 + util_num_digits(num) + 4; // M + %d + port
        char* layername = malloc(len + 1);
        snprintf(layername, len + 1, "M%dport", num);
        layer = technology_get_layer(techstate, layername);
        free(layername);
        _insert_layer(generics_layer_map, key, layer);
    }
    return layer;
}


generics_t* generics_create_viacut(struct layermap* generics_layer_map, struct technology_state* techstate, int metal1, int metal2)
{
    metal1 = technology_resolve_metal(techstate, metal1);
    metal2 = technology_resolve_metal(techstate, metal2);
    if(metal1 > metal2)
    {
        int tmp = metal2;
        metal2 = metal1;
        metal1 = tmp;
    }
    uint32_t key = (VIA_IDENTIFIER << 24) | ((metal1 & 0x00000fff) << 12) | (metal2 & 0x00000fff);
    generics_t* layer = generics_get_layer(generics_layer_map, key);
    if(!layer)
    {
        size_t len = 6 + 1 + util_num_digits(metal1) + 1 + util_num_digits(metal2); // viacut + M + %d + M + %d
        char* layername = malloc(len + 1);
        snprintf(layername, len + 1, "viacutM%dM%d", metal1, metal2);
        layer = technology_get_layer(techstate, layername);
        free(layername);
        _insert_layer(generics_layer_map, key, layer);
    }
    return layer;
}

generics_t* generics_create_contact(struct layermap* generics_layer_map, struct technology_state* techstate, const char* region)
{
    size_t len = strlen(region);
    uint8_t data[len + 1];
    data[0] = CONTACT_IDENTIFIER;
    memcpy(data + 1, region, len);

    uint32_t key = _hash(data, len + 1);
    generics_t* layer = generics_get_layer(generics_layer_map, key);
    if(!layer)
    {
        size_t len = 7 + strlen(region); // contact + %s
        char* layername = malloc(len + 1);
        snprintf(layername, len + 1, "contact%s", region);
        layer = technology_get_layer(techstate, layername);
        free(layername);
        _insert_layer(generics_layer_map, key, layer);
    }
    return layer;
}

generics_t* generics_create_oxide(struct layermap* generics_layer_map, struct technology_state* techstate, int num)
{
    uint32_t key = (OXIDE_IDENTIFIER << 24) | (num & 0x00ffffff);
    generics_t* layer = generics_get_layer(generics_layer_map, key);
    if(!layer)
    {
        size_t len = 5 + util_num_digits(num); // oxide + %d
        char* layername = malloc(len + 1);
        snprintf(layername, len + 1, "oxide%d", num);
        layer = technology_get_layer(techstate, layername);
        free(layername);
        _insert_layer(generics_layer_map, key, layer);
    }
    return layer;
}

generics_t* generics_create_implant(struct layermap* generics_layer_map, struct technology_state* techstate, char polarity)
{
    uint32_t key = (IMPLANT_IDENTIFIER << 24) | (polarity & 0x00ffffff); // the '& 0x00ffffff' is unnecessary here, but kept for completeness
    generics_t* layer = generics_get_layer(generics_layer_map, key);
    if(!layer)
    {
        size_t len = 8; // [np]implant
        char* layername = malloc(len + 1);
        snprintf(layername, len + 1, "%cimplant", polarity);
        layer = technology_get_layer(techstate, layername);
        free(layername);
        _insert_layer(generics_layer_map, key, layer);
    }
    return layer;
}

generics_t* generics_create_vthtype(struct layermap* generics_layer_map, struct technology_state* techstate, char channeltype, int vthtype)
{
    uint32_t key = (VTHTYPE_IDENTIFIER << 24) | ((channeltype & 0x000000ff) << 16) | (vthtype & 0x0000ffff);
    generics_t* layer = generics_get_layer(generics_layer_map, key);
    if(!layer)
    {
        size_t len = 7 + 1 + util_num_digits(vthtype); // vthtype + %c + %d
        char* layername = malloc(len + 1);
        snprintf(layername, len + 1, "vthtype%c%d", channeltype, vthtype);
        layer = technology_get_layer(techstate, layername);
        free(layername);
        _insert_layer(generics_layer_map, key, layer);
    }
    return layer;
}

generics_t* generics_create_other(struct layermap* generics_layer_map, struct technology_state* techstate, const char* str)
{
    size_t len = strlen(str);
    uint8_t* data = malloc(len + 1);
    data[0] = OTHER_IDENTIFIER;
    memcpy(data + 1, str, len);

    uint32_t key = _hash(data, len + 1);
    free(data);
    generics_t* layer = generics_get_layer(generics_layer_map, key);
    if(!layer)
    {
        layer = technology_get_layer(techstate, str);
        _insert_layer(generics_layer_map, key, layer);
    }
    return layer;
}

generics_t* generics_create_special(struct layermap* generics_layer_map, struct technology_state* techstate)
{
    uint32_t key = (SPECIAL_IDENTIFIER << 24);
    generics_t* layer = generics_get_layer(generics_layer_map, key);
    if(!layer)
    {
        layer = technology_get_layer(techstate, "special");
        _insert_layer(generics_layer_map, key, layer);
    }
    return layer;
}

generics_t* generics_get_layer(struct layermap* generics_layer_map, uint32_t key)
{
    for(unsigned int i = 0; i < generics_layer_map->size; ++i)
    {
        if(generics_layer_map->entries[i]->key == key)
        {
            return generics_layer_map->entries[i]->layer;
        }
    }
    return NULL;
}

void generics_insert_extra_layer(struct layermap* generics_layer_map, uint32_t key, generics_t* layer)
{
    _insert_layer(generics_layer_map, key, layer);
    generics_layer_map->entries[generics_layer_map->size - 1]->destroy = 1;
}

void generics_destroy_layer(generics_t* layer)
{
    for(unsigned int i = 0; i < layer->size; ++i)
    {
        free(layer->exportnames[i]);
        keyvaluearray_destroy(layer->data[i]);
    }
    free(layer->name);
    free(layer->exportnames);
    free(layer->data);
    free(layer);
}

struct layermap* generics_initialize_layer_map(void)
{
    struct layermap* generics_layer_map = malloc(sizeof(*generics_layer_map));
    generics_layer_map->entries = NULL;
    generics_layer_map->capacity = 0;
    generics_layer_map->size = 0;
    return generics_layer_map;
}

void generics_destroy_layer_map(struct layermap* generics_layer_map)
{
    for(unsigned int i = 0; i < generics_layer_map->size; ++i)
    {
        // only explicitely premapped layers in cells need to be destroyed, 
        // all other layers are built and destroyed by the technology module
        if(generics_layer_map->entries[i]->destroy)
        {
            generics_destroy_layer(generics_layer_map->entries[i]->layer);
        }
        free(generics_layer_map->entries[i]);
    }
    free(generics_layer_map->entries);
    free(generics_layer_map);
}

size_t generics_get_layer_map_size(struct layermap* generics_layer_map)
{
    return generics_layer_map->size;
}

generics_t* generics_get_indexed_layer(struct layermap* generics_layer_map, size_t idx)
{
    return generics_layer_map->entries[idx]->layer;
}

int generics_resolve_premapped_layers(struct layermap* generics_layer_map, const char* name)
{
    int found = 0;
    for(unsigned int i = 0; i < generics_layer_map->size; ++i)
    {
        generics_t* layer = generics_layer_map->entries[i]->layer;
        if(layer->is_pre)
        {
            unsigned int idx = 0;
            for(unsigned int k = 0; k < layer->size; ++k)
            {
                if(strcmp(name, layer->exportnames[k]) == 0)
                {
                    found = 1;
                    idx = k;
                }
            }
            if(!found)
            {
                printf("no layer data for export type '%s' found (layer: %s)\n", name, layer->name);
                return 0;
            }

            // swap entries and mark as mapped
            // for mapped entries, only data[0] is used, but it is easier to keep the data here
            // and let _destroy_generics free all data, regardless if a layer is premapped or mapped

            // swap data
            struct keyvaluearray* tmp = layer->data[0];
            layer->data[0] = layer->data[idx];
            layer->data[idx] = tmp;

            // swap export names
            char* str = layer->exportnames[0];
            layer->exportnames[0] = layer->exportnames[idx];
            layer->exportnames[idx] = str;
            layer->is_pre = 0;
        }
    }
    return 1;
}

#include "generics.h"

#include <stdlib.h>
#include <stdio.h>
#include <string.h>

#include "technology.h"
#include "util.h"

struct layermap
{
    struct hashmap* hashmap;
    struct vector* extra_layers;
};

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
    return layer;
}

static generics_t* _get_or_create_layer(struct layermap* layermap, struct technology_state* techstate, const char* layername)
{
    if(!hashmap_exists(layermap->hashmap, layername))
    {
        generics_t* layer = technology_get_layer(techstate, layername);
        hashmap_insert(layermap->hashmap, layername, layer);
        return layer;
    }
    else
    {
        return hashmap_get(layermap->hashmap, layername);
    }
}

generics_t* generics_create_metal(struct layermap* layermap, struct technology_state* techstate, int num)
{
    num = technology_resolve_metal(techstate, num);
    size_t len = 1 + util_num_digits(num);
    char* layername = malloc(len + 1);
    snprintf(layername, len + 1, "M%d", num);
    generics_t* layer = _get_or_create_layer(layermap, techstate, layername);
    free(layername);
    return layer;
}

generics_t* generics_create_metalport(struct layermap* layermap, struct technology_state* techstate, int num)
{
    num = technology_resolve_metal(techstate, num);
    size_t len = 1 + util_num_digits(num) + 4; // M + %d + port
    char* layername = malloc(len + 1);
    snprintf(layername, len + 1, "M%dport", num);
    generics_t* layer = _get_or_create_layer(layermap, techstate, layername);
    free(layername);
    return layer;
}

generics_t* generics_create_viacut(struct layermap* layermap, struct technology_state* techstate, int metal1, int metal2)
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
    generics_t* layer = _get_or_create_layer(layermap, techstate, layername);
    free(layername);
    return layer;
}

generics_t* generics_create_contact(struct layermap* layermap, struct technology_state* techstate, const char* region)
{
    size_t len = 7 + strlen(region); // contact + %s
    char* layername = malloc(len + 1);
    snprintf(layername, len + 1, "contact%s", region);
    generics_t* layer = _get_or_create_layer(layermap, techstate, layername);
    free(layername);
    return layer;
}

generics_t* generics_create_oxide(struct layermap* layermap, struct technology_state* techstate, int num)
{
    size_t len = 5 + util_num_digits(num); // oxide + %d
    char* layername = malloc(len + 1);
    snprintf(layername, len + 1, "oxide%d", num);
    generics_t* layer = _get_or_create_layer(layermap, techstate, layername);
    free(layername);
    return layer;
}

generics_t* generics_create_implant(struct layermap* layermap, struct technology_state* techstate, char polarity)
{
    size_t len = 8; // [np]implant
    char* layername = malloc(len + 1);
    snprintf(layername, len + 1, "%cimplant", polarity);
    generics_t* layer = _get_or_create_layer(layermap, techstate, layername);
    free(layername);
    return layer;
}

generics_t* generics_create_vthtype(struct layermap* layermap, struct technology_state* techstate, char channeltype, int vthtype)
{
    size_t len = 7 + 1 + util_num_digits(vthtype); // vthtype + %c + %d
    char* layername = malloc(len + 1);
    snprintf(layername, len + 1, "vthtype%c%d", channeltype, vthtype);
    generics_t* layer = _get_or_create_layer(layermap, techstate, layername);
    free(layername);
    return layer;
}

generics_t* generics_create_other(struct layermap* layermap, struct technology_state* techstate, const char* layername)
{
    generics_t* layer = _get_or_create_layer(layermap, techstate, layername);
    return layer;
}

generics_t* generics_create_special(struct layermap* layermap, struct technology_state* techstate)
{
    generics_t* layer = _get_or_create_layer(layermap, techstate, "special");
    return layer;
}

void generics_insert_extra_layer(struct layermap* layermap, generics_t* layer)
{
    vector_append(layermap->extra_layers, layer);
}

void generics_destroy_layer(void* layerv)
{
    generics_t* layer = layerv;
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
    struct layermap* layermap = malloc(sizeof(*layermap));
    layermap->hashmap = hashmap_create();
    layermap->extra_layers = vector_create();
    return layermap;
}

void generics_destroy_layer_map(struct layermap* layermap)
{
    hashmap_destroy(layermap->hashmap, NULL);
    vector_destroy(layermap->extra_layers, generics_destroy_layer); // (externally) premapped layers are owned by the layer map
    free(layermap);
}

int _resolve_layer(generics_t* layer, const char* exportname)
{
    int found = 0;
    if(layer->size > 0) // empty layers are ignored
    {
        unsigned int idx = 0;
        for(unsigned int k = 0; k < layer->size; ++k)
        {
            if(strcmp(exportname, layer->exportnames[k]) == 0)
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
    }
    return 1;
}

int generics_resolve_premapped_layers(struct layermap* layermap, const char* exportname)
{
    // main layers
    struct hashmap_iterator* it = hashmap_iterator_create(layermap->hashmap);
    while(hashmap_iterator_is_valid(it))
    {
        generics_t* layer = hashmap_iterator_value(it);
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
        generics_t* layer = vector_get(layermap->extra_layers, i);
        if(!_resolve_layer(layer, exportname))
        {
            return 0;
        }
    }
    return 1;
}

struct layer_iterator
{
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


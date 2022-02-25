#include "generics.h"

#include <stdlib.h>
#include <stdio.h>
#include <string.h>

struct hashmapentry
{
    uint32_t key;
    struct layer_collection* layers;
};

struct hashmap // FIXME: pseudo hashmap, but it will probably be good enough as there are not many elements
{
    struct hashmapentry** entries;
    size_t size;
    size_t capacity;
};

struct hashmap* generics_layer_map;

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

struct layer_collection* generics_get_layers(const uint8_t* data, size_t size)
{
    uint32_t key = _hash(data, size);
    for(unsigned int i = 0; i < generics_layer_map->size; ++i)
    {
        if(generics_layer_map->entries[i]->key == key)
        {
            return generics_layer_map->entries[i]->layers;
        }
    }
    return NULL;
}

void generics_insert_layers(const uint8_t* data, size_t size, struct layer_collection* layers)
{
    uint32_t key = _hash(data, size);
    if(generics_layer_map->capacity == generics_layer_map->size)
    {
        generics_layer_map->capacity += 1;
        struct hashmapentry** entries = realloc(generics_layer_map->entries, sizeof(*entries) * generics_layer_map->capacity);
        generics_layer_map->entries = entries;
    }
    generics_layer_map->entries[generics_layer_map->size] = malloc(sizeof(struct hashmapentry));
    generics_layer_map->entries[generics_layer_map->size]->key = key;
    generics_layer_map->entries[generics_layer_map->size]->layers = layers;
    generics_layer_map->size += 1;
}

struct layer_collection* generics_create_layer_collection(void)
{
    struct layer_collection* collection = malloc(sizeof(*collection));
    collection->size = 0;
    return collection;
}

void _destroy_generics(generics_t* layer)
{
    for(unsigned int i = 0; i < layer->size; ++i)
    {
        free(layer->exportnames[i]);
        keyvaluearray_destroy(layer->data[i]);
    }
    free(layer->exportnames);
    free(layer->data);
    free(layer);
}

void generics_initialize_layer_map(void)
{
    generics_layer_map = malloc(sizeof(*generics_layer_map));
    generics_layer_map->entries = NULL;
    generics_layer_map->capacity = 0;
    generics_layer_map->size = 0;
}

void _destroy_layer_collection(struct layer_collection* layers)
{
    for(unsigned int i = 0; i < layers->size; ++i)
    {
        _destroy_generics(layers->layers[i]);
    }
    free(layers->layers);
    free(layers);
}

void generics_destroy_layer_map(void)
{
    for(unsigned int i = 0; i < generics_layer_map->size; ++i)
    {
        _destroy_layer_collection(generics_layer_map->entries[i]->layers);
        free(generics_layer_map->entries[i]);
    }
    free(generics_layer_map->entries);
    free(generics_layer_map);
}

void generics_resolve_premapped_layers(const char* name)
{
    for(unsigned int i = 0; i < generics_layer_map->size; ++i)
    {
        for(unsigned int j = 0; j < generics_layer_map->entries[i]->layers->size; ++j)
        {
            generics_t* layer = generics_layer_map->entries[i]->layers->layers[j];
            if(layer->is_pre)
            {
                unsigned int idx = 0;
                for(unsigned int k = 0; k < layer->size; ++k)
                {
                    if(strcmp(name, layer->exportnames[k]) == 0)
                    {
                        idx = k;
                    }
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
    }
}

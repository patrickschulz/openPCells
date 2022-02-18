#include "generics.h"

#include <stdlib.h>
#include <stdio.h>

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

generics_t* generics_create_metal(int num)
{
    char str[10];
    snprintf(str, 10, "metal%4d", num);
    uint32_t key = _hash(str);
    generics_t* layer = _get(&generics_layer_map, key);
    if(!layer)
    {
        layer = malloc(sizeof(*layer));
        layer->layer = malloc(sizeof(struct generic_metal_t));
        ((struct generic_metal_t*)layer->layer)->metal = num;
        layer->type = METAL;
        _insert(&generics_layer_map, key, layer);
    }
    return layer;
}


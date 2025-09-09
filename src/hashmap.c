#include "hashmap.h"

#include <stdlib.h>
#include <string.h>
#include <stdint.h>
#include <stdio.h>

#include "util.h"

struct hashmap_entry {
    char* key;
    void* value;
};

struct hashmap {
    struct hashmap_entry* entries;
    size_t size;
    size_t capacity;
    void (*destructor)(void*);
};

static uint32_t _hash(const char* key)
{
    size_t length = strlen(key);
    uint32_t hash = 2166136261u;
    for (size_t i = 0; i < length; i++) {
        hash ^= (uint8_t)key[i];
        hash *= 16777619;
    }
    return hash;
}

static struct hashmap_entry* _find(const struct hashmap* map, const char* key)
{
    size_t index = _hash(key) % map->capacity;
    while(1)
    {
        struct hashmap_entry* entry = map->entries + index;
        if(!entry->key || (strcmp((map->entries + index)->key, key) == 0))
        {
            return entry;
        }
        index = (index + 1) % map->capacity;
    }
    return NULL;
}

static void _resize(struct hashmap* map)
{
    struct hashmap_entry* old = map->entries;
    size_t capacity = map->capacity;
    map->capacity *= 2;
    map->entries = calloc(map->capacity, sizeof(*map->entries));
    // FIXME: check return value of calloc
    if(map->size > 0) // we don't have to rehash the first time
    {
        for(size_t i = 0; i < capacity; ++i)
        {
            if((old + i)->key)
            {
                size_t index = _hash((old + i)->key) % map->capacity;
                while(1)
                {
                    struct hashmap_entry* entry = map->entries + index;
                    if(!entry->key)
                    {
                        break;
                    }
                    index = (index + 1) % map->capacity;
                }
                (map->entries + index)->key = (old + i)->key;
                (map->entries + index)->value = (old + i)->value;

            }
        }
        free(old);
    }
}

struct hashmap* hashmap_create(void (*destructor)(void*))
{
    struct hashmap* map = malloc(sizeof(*map));
    map->size = 0;
    map->capacity = 32; // must be power of two!
    map->entries = NULL;
    map->destructor = destructor;
    _resize(map);
    return map;
}

void hashmap_destroy(struct hashmap* map)
{
    for(size_t i = 0; i < map->capacity; ++i)
    {
        if((map->entries + i)->key)
        {
            free((map->entries + i)->key);
            if(map->destructor)
            {
                map->destructor((map->entries + i)->value);
            }
        }
    }
    free(map->entries);
    free(map);
}

void hashmap_insert(struct hashmap* map, const char* key, void* value)
{
    if(map->size >= (map->capacity >> 1))
    {
        _resize(map);
    }
    struct hashmap_entry* entry = _find(map, key);
    if(!entry->key) // entry does not exist
    {
        entry->key = util_strdup(key);
        entry->value = value;
        map->size += 1;
    }
    else // replace old value
    {
        map->destructor(entry->value);
        entry->value = value;
    }
}

int hashmap_exists(const struct hashmap* map, const char* key)
{
    struct hashmap_entry* entry = _find(map, key);
    return entry->key != NULL;
}

void* hashmap_get(struct hashmap* map, const char* key)
{
    struct hashmap_entry* entry = _find(map, key);
    return entry->value;
}

const void* hashmap_get_const(const struct hashmap* map, const char* key)
{
    struct hashmap_entry* entry = _find(map, key);
    return entry->value;
}

struct hashmap_iterator {
    struct hashmap* hashmap;
    size_t index;
};

struct hashmap_iterator* hashmap_iterator_create(struct hashmap* map)
{
    struct hashmap_iterator* iterator = malloc(sizeof(*iterator));
    iterator->hashmap = map;
    iterator->index = 0;
    if(!map)
    {
        return iterator;
    }
    while((iterator->index < iterator->hashmap->capacity) && (!(iterator->hashmap->entries + iterator->index)->key))
    {
        ++iterator->index;
    }
    return iterator;
}

int hashmap_iterator_is_valid(const struct hashmap_iterator* iterator)
{
    return iterator->hashmap && iterator->index < iterator->hashmap->capacity;
}

const char* hashmap_iterator_key(const struct hashmap_iterator* iterator)
{
    return (iterator->hashmap->entries + iterator->index)->key;
}

void* hashmap_iterator_value(struct hashmap_iterator* iterator)
{
    return (iterator->hashmap->entries + iterator->index)->value;
}

void hashmap_iterator_next(struct hashmap_iterator* iterator)
{
    do
    {
        ++iterator->index;
    }
    while((iterator->index < iterator->hashmap->capacity) && (!(iterator->hashmap->entries + iterator->index)->key));
}

void hashmap_iterator_destroy(struct hashmap_iterator* iterator)
{
    free(iterator);
}

struct hashmap_const_iterator {
    const struct hashmap* hashmap;
    size_t index;
};

struct hashmap_const_iterator* hashmap_const_iterator_create(const struct hashmap* map)
{
    struct hashmap_const_iterator* iterator = malloc(sizeof(*iterator));
    iterator->hashmap = map;
    iterator->index = 0;
    if(!map)
    {
        return iterator;
    }
    while((iterator->index < iterator->hashmap->capacity) && (!(iterator->hashmap->entries + iterator->index)->key))
    {
        ++iterator->index;
    }
    return iterator;
}

int hashmap_const_iterator_is_valid(struct hashmap_const_iterator* iterator)
{
    return iterator->hashmap && iterator->index < iterator->hashmap->capacity;
}

const char* hashmap_const_iterator_key(struct hashmap_const_iterator* iterator)
{
    return (iterator->hashmap->entries + iterator->index)->key;
}

const void* hashmap_const_iterator_value(struct hashmap_const_iterator* iterator)
{
    return (iterator->hashmap->entries + iterator->index)->value;
}

void hashmap_const_iterator_next(struct hashmap_const_iterator* iterator)
{
    do
    {
        ++iterator->index;
    }
    while((iterator->index < iterator->hashmap->capacity) && (!(iterator->hashmap->entries + iterator->index)->key));
}

void hashmap_const_iterator_destroy(struct hashmap_const_iterator* iterator)
{
    free(iterator);
}

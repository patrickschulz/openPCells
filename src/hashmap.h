#ifndef OPC_HASHMAP_H
#define OPC_HASHMAP_H

#include <stddef.h>

struct hashmap_entry
{
    char* key;
    void* value;
};

struct hashmap
{
    struct hashmap_entry* entries;
    size_t size;
    size_t capacity;
};

struct hashmap* hashmap_create(void);
void hashmap_destroy(struct hashmap* map);
void hashmap_insert(struct hashmap* map, const char* key, void* value);
void* hashmap_get(struct hashmap* map, const char* key);

// iterator
struct hashmap_iterator
{
    struct hashmap* hashmap;
    size_t index;
};

struct hashmap_iterator* hashmap_iterator_create(struct hashmap* map);
int hashmap_iterator_is_valid(struct hashmap_iterator* iterator);
void* hashmap_iterator_value(struct hashmap_iterator* iterator);
void hashmap_iterator_next(struct hashmap_iterator* iterator);
void hashmap_iterator_destroy(struct hashmap_iterator* iterator);

#endif // OPC_HASHMAP_H

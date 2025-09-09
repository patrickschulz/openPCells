#ifndef OPC_HASHMAP_H
#define OPC_HASHMAP_H

struct hashmap;
struct hashmap* hashmap_create(void (*destructor)(void*));
void hashmap_destroy(struct hashmap* map);
void hashmap_insert(struct hashmap* map, const char* key, void* value);
int hashmap_exists(const struct hashmap* map, const char* key);
void* hashmap_get(struct hashmap* map, const char* key);
const void* hashmap_get_const(const struct hashmap* map, const char* key);

// iterator
struct hashmap_iterator;
struct hashmap_iterator* hashmap_iterator_create(struct hashmap* map);
int hashmap_iterator_is_valid(const struct hashmap_iterator* iterator);
const char* hashmap_iterator_key(const struct hashmap_iterator* iterator);
void* hashmap_iterator_value(struct hashmap_iterator* iterator);
void hashmap_iterator_next(struct hashmap_iterator* iterator);
void hashmap_iterator_destroy(struct hashmap_iterator* iterator);

// const iterator
struct hashmap_const_iterator;
struct hashmap_const_iterator* hashmap_const_iterator_create(const struct hashmap* map);
int hashmap_const_iterator_is_valid(struct hashmap_const_iterator* iterator);
const char* hashmap_const_iterator_key(struct hashmap_const_iterator* iterator);
const void* hashmap_const_iterator_value(struct hashmap_const_iterator* iterator);
void hashmap_const_iterator_next(struct hashmap_const_iterator* iterator);
void hashmap_const_iterator_destroy(struct hashmap_const_iterator* iterator);

#endif // OPC_HASHMAP_H

#ifndef OPC_GENERICS_H
#define OPC_GENERICS_H

#include <stddef.h>
#include <stdint.h>

#include "keyvaluepairs.h"

enum generic_type
{
    METAL,
    VIA,
    CONTACT,
    FEOL,
    OTHER,
    SPECIAL,
    PREMAPPED,
    MAPPED
};

struct generic_metal_t
{
    int metal;
};

struct generic_via_t
{
    int from;
    int to;
};

struct generic_contact_t
{
    enum {
        GATE,
        SOURCEDRAIN,
        WELL
    } region;
};

struct generic_feol_t
{
    int channeltype;
    int vthtype;
    int oxidetype;
};

struct generic_other_t
{
    char* layer;
};

struct generic_premapped_t
{
    char** exportnames;
    struct keyvaluearray** data;
    size_t size;
};

struct generic_mapped_t
{
    struct keyvaluearray* data;
};

struct generic_special_t
{
    char* layer;
};

typedef struct
{
    void* layer;
    enum generic_type type;
} generics_t;

struct hashmapentry
{
    uint32_t key;
    generics_t* layer;
};

struct hashmap // FIXME: pseudo hashmap, but it will probably be good enough as there are not many elements
{
    struct hashmapentry* entries;
    size_t size;
    size_t capacity;
};
extern struct hashmap generics_layer_map;

generics_t* generics_create_metal(int num);
void generics_destroy(generics_t* layer);
generics_t* generics_copy(generics_t* layer);

#endif /* OPC_GENERICS_H */

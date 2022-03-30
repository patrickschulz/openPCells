#ifndef OPC_GENERICS_H
#define OPC_GENERICS_H

#include <stddef.h>
#include <stdint.h>

#include "keyvaluepairs.h"
//#include "technology.h"
struct technology_state;

typedef struct
{
    char* name;
    char** exportnames;
    struct keyvaluearray** data;
    size_t size;
    int is_pre;
} generics_t;

generics_t* generics_create_empty_layer(const char* name);
generics_t* generics_create_premapped_layer(const char* name, size_t size);
generics_t* generics_create_special(struct technology_state* techstate);

generics_t* generics_create_metal(struct technology_state* techstate, int num);
generics_t* generics_create_metalport(struct technology_state* techstate, int num);
generics_t* generics_create_viacut(struct technology_state* techstate, int metal1, int metal2);
generics_t* generics_create_contact(struct technology_state* techstate, const char* region);
generics_t* generics_create_oxide(struct technology_state* techstate, int num);
generics_t* generics_create_implant(struct technology_state* techstate, char polarity);
generics_t* generics_create_vthtype(struct technology_state* techstate, char channeltype, int vthtype);
generics_t* generics_create_other(struct technology_state* techstate, const char* str);

void generics_destroy_layer(generics_t* layer);

void generics_insert_layer(uint32_t key, generics_t* layer);
void generics_insert_extra_layer(uint32_t key, generics_t* layer);

generics_t* generics_get_layer(uint32_t key);

size_t generics_get_layer_map_size(void);
generics_t* generics_get_indexed_layer(size_t idx);

int generics_resolve_premapped_layers(const char* exportname);

void generics_initialize_layer_map(void);
void generics_destroy_layer_map(void);

#endif /* OPC_GENERICS_H */

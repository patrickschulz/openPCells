#ifndef OPC_PCELL_H
#define OPC_PCELL_H

#include "lua/lua.h"

#include "vector.h"

struct object;

struct cellreference
{
    char* identifier;
    struct object* cell;
    unsigned int numused;
};

struct pcell_state;

struct pcell_state* pcell_initialize_state(struct vector* to_prepend, struct vector* to_append);
void pcell_destroy_state(struct pcell_state* state);

size_t pcell_get_reference_count(struct pcell_state* state);
struct cellreference* pcell_get_indexed_cell_reference(struct pcell_state*, unsigned int i);
struct object* pcell_get_cell_reference_by_name(struct pcell_state*, const char* identifier);
struct object* pcell_use_cell_reference(struct pcell_state*, const char* identifier);
void pcell_unlink_cell_reference(struct pcell_state*, const char* identifier);

void pcell_prepend_cellpath(struct pcell_state*, const char* path);
void pcell_append_cellpath(struct pcell_state*, const char* path);

void pcell_list_cellpaths(struct pcell_state* pcell_state);
void pcell_list_cells(struct pcell_state* pcell_state, const char* listformat);

int open_lpcell_lib(lua_State* L);

#endif // OPC_PCELL_H

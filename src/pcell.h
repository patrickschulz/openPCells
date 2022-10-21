#ifndef OPC_PCELL_H
#define OPC_PCELL_H

#include "lua/lua.h"

#include "vector.h"

struct object;

struct pcell_state;

struct pcell_state* pcell_initialize_state(struct vector* to_prepend, struct vector* to_append);
void pcell_destroy_state(struct pcell_state* state);

struct object* pcell_get_cell_reference_by_name(struct pcell_state*, const char* identifier);
struct object* pcell_use_cell_reference(struct pcell_state*, const char* identifier);
void pcell_unlink_cell_reference(struct pcell_state*, const char* identifier);

void pcell_prepend_cellpath(struct pcell_state*, const char* path);
void pcell_append_cellpath(struct pcell_state*, const char* path);

void pcell_list_cellpaths(const struct pcell_state* pcell_state);
void pcell_list_cells(const struct pcell_state* pcell_state, const char* listformat);

void pcell_foreach_cell_reference(struct pcell_state* pcell_state, void (*cellfunc)(struct object*));

// reference cell iterator
struct cell_reference_iterator;
struct cell_reference_iterator* pcell_create_cell_reference_iterator(const struct pcell_state* pcell_state);
void pcell_cell_reference_iterator_get(struct cell_reference_iterator* it, char** identifier, struct object** reference, int* numused);
int pcell_cell_reference_iterator_is_valid(const struct cell_reference_iterator* it);
void pcell_cell_reference_iterator_advance(struct cell_reference_iterator* it);
void pcell_destroy_cell_reference_iterator(struct cell_reference_iterator* it);

// const reference cell iterator
struct cell_reference_const_iterator;
struct cell_reference_const_iterator* pcell_create_cell_reference_const_iterator(const struct pcell_state* pcell_state);
void pcell_cell_reference_const_iterator_get(struct cell_reference_const_iterator* it, const char** identifier, const struct object** reference, int* numused);
int pcell_cell_reference_const_iterator_is_valid(const struct cell_reference_const_iterator* it);
void pcell_cell_reference_const_iterator_advance(struct cell_reference_const_iterator* it);
void pcell_destroy_cell_reference_const_iterator(struct cell_reference_const_iterator* it);

int open_lpcell_lib(lua_State* L);

#endif // OPC_PCELL_H

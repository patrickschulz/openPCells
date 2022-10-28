#ifndef OPC_PCELL_H
#define OPC_PCELL_H

#include "lua/lua.h"

#include "vector.h"

struct object;

struct pcell_state;

struct pcell_state* pcell_initialize_state(struct vector* to_prepend, struct vector* to_append);
void pcell_destroy_state(struct pcell_state* state);

void pcell_prepend_cellpath(struct pcell_state*, const char* path);
void pcell_append_cellpath(struct pcell_state*, const char* path);

void pcell_list_cellpaths(const struct pcell_state* pcell_state);
void pcell_list_cells(const struct pcell_state* pcell_state, const char* listformat);

int open_lpcell_lib(lua_State* L);

#endif // OPC_PCELL_H

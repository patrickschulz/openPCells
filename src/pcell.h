#ifndef OPC_PCELL_H
#define OPC_PCELL_H

#include "lua/lua.h"

#include "object.h"
#include "technology.h"
#include "vector.h"

struct pcell_state;

typedef int (*cell_layout_func)(struct pcell_state* pcell_state, struct technology_state* techstate, struct object* cell);

struct pcell_state* pcell_initialize_state(struct vector* to_prepend, struct vector* to_append);
void pcell_destroy_state(struct pcell_state* state);

struct object* pcell_create_layout(const char* cellname, struct technology_state* techstate, struct pcell_state* pcell_state);

void pcell_prepend_cellpath(struct pcell_state*, const char* path);
void pcell_append_cellpath(struct pcell_state*, const char* path);

void pcell_list_cellpaths(const struct pcell_state* pcell_state);
void pcell_list_cells(const struct pcell_state* pcell_state, const char* listformat);

int open_lpcell_lib(lua_State* L);

void pcell_enable_debug(struct pcell_state* pcell_state);
void pcell_enable_dprint(struct pcell_state* pcell_state);

struct object* pcell_create_layout_from_script(struct pcell_state* pcell_state, struct technology_state* techstate, const char* cellname, const char* name, struct vector* cellargs);
struct object* pcell_create_layout_env(struct pcell_state* pcell_state, struct technology_state* techstate, const char* cellname, const char* toplevelname);

#endif // OPC_PCELL_H

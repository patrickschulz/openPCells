#ifndef OPC_LEXPORT_H
#define OPC_LEXPORT_H

#include "lua/lua.h"

#define LEXPORTMODULE "export"

#include "object.h"
#include "pcell.h"
#include "vector.h"

struct export_state;

struct export_state* export_create_state(void);
void export_destroy_state(struct export_state* state);
void export_add_searchpath(struct export_state* state, const char* path);
void export_set_basename(struct export_state* state, const char* filename);
void export_set_toplevel_name(struct export_state* state, const char* cellname);
void export_set_export_options(struct export_state* state, const char** exportoptions);
void export_set_write_children_ports(struct export_state* state, int writechildrenports);
void export_set_bus_delimiters(struct export_state* state, char leftdelim, char rightdelim);
void export_set_exportname(struct export_state* state, const char* exportname);
const char* export_get_layername(const struct export_state* state);

char* export_get_export_layername(struct const_vector* searchpaths, const char* exportname);
int export_write_toplevel(struct object* toplevel, struct pcell_state* pcell_state, struct export_state* state);

#endif // OPC_LEXPORT_H

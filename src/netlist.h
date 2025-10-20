#ifndef OPC_NETLIST_H
#define OPC_NETLIST_H

#include "lua/lua.h"

struct netlist;
struct subcircuit;
struct instance;

struct netlist* netlist_create(void);
void netlist_destroy(struct netlist* netlist);
struct subcircuit* netlist_make_subcircuit(void);
void netlist_add_subcircuit(struct netlist* netlist, struct subcircuit* subcircuit);
void netlist_subcircuit_set_name(struct subcircuit* subcircuit, const char* name);
void netlist_subcircuit_add_instance(struct subcircuit* subcircuit, struct instance* instance);
struct instance* netlist_make_instance(const char* identifier);
void netlist_instance_set_type(struct instance* instance, const char* type);
void netlist_instance_add_connection(struct instance* instance, const char* portname, const char* netname);
void netlist_instance_add_parameter(struct instance* instance, const char* key, const char* value);
void netlist_create_lua_representation(struct netlist* netlist, lua_State* L);

#endif /* OPC_NETLIST_H */

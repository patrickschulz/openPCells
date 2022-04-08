#ifndef OPC_MAIN_FUNCTIONS_H
#define OPC_MAIN_FUNCTIONS_H

#include "lua/lua.h"
#include "object.h"
#include "technology.h"
#include "pcell.h"
#include "generics.h"

int main_call_lua_program(lua_State* L, const char* filename);

struct technology_state* main_create_techstate(struct vector* techpaths, const char* techname);
struct pcell_state* main_create_pcell_state(void);
struct layermap* main_create_layermap(void);
object_t* main_create_cell(const char* cellname, struct vector* cellargs, struct technology_state* techstate, struct pcell_state* pcell_state, struct layermap* layermap);

#endif // OPC_MAIN_FUNCTIONS_H

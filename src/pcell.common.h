#ifndef OPC_PCELL_COMMON_H
#define OPC_PCELL_COMMON_H

#include "lua/lua.h"

struct pcell_state;

int pcellcommon_load_pcell_library(lua_State* L, struct pcell_state* pcell_state);
int pcellcommon_read_table_from_file(lua_State* L, const char* filename);
int pcellcommon_load_pfiles(struct pcell_state* pcell_state, lua_State* L);
int pcellcommon_load_cellenv(lua_State* L, const char* cellenvfilename);

#endif /* OPC_PCELL_COMMON_H */

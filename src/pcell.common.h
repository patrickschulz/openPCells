#ifndef OPC_PCELL_COMMON_H
#define OPC_PCELL_COMMON_H

#include "lua/lua.h"

#include "technology.h"

struct pcell_state;

lua_State* pcellcommon_prepare_layout_generation(struct pcell_state* pcell_state, struct technology_state* techstate);
int pcellcommon_read_table_from_file(lua_State* L, const char* filename);
int pcellcommon_load_pfiles(struct pcell_state* pcell_state, lua_State* L);
int pcellcommon_load_cellenv(lua_State* L, const char* cellenvfilename);

#endif /* OPC_PCELL_COMMON_H */

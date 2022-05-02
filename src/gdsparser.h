#ifndef OPC_GDSPARSER_H
#define OPC_GDSPARSER_H

#include "lua/lua.h"

int gdsparser_read_stream(const char* filename, const char* importname);
int gdsparser_show_records(const char* filename);

int open_gdsparser_lib(lua_State* L);

#endif /* OPC_GDSPARSER_H */

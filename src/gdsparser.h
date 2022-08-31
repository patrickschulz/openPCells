#ifndef OPC_GDSPARSER_H
#define OPC_GDSPARSER_H

#include "lua/lua.h"

#include "vector.h"

struct vector* gdsparser_create_layermap(const char* filename);
void gdsparser_destroy_layermap(struct vector* layermap);
int gdsparser_read_stream(const char* filename, const char* importname, const struct vector* layermap);
int gdsparser_show_records(const char* filename);

int open_gdsparser_lib(lua_State* L);

#endif /* OPC_GDSPARSER_H */

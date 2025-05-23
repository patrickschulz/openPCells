#ifndef OPC_GDSPARSER_H
#define OPC_GDSPARSER_H

#include "lua/lua.h"

#include "vector.h"

struct vector* gdsparser_create_layermap(const char* filename);
void gdsparser_destroy_layermap(struct vector* layermap);
int gdsparser_read_stream(const char* filename, const char* importname, const struct vector* layermap, const struct vector* ignorelpp, int16_t* ablayer, int16_t* abpurpose);
int gdsparser_show_records(const char* filename, int raw);
int gdsparser_show_cell_definitions(const char* filename);
void gdsparser_show_cell_hierarchy(const char* filename, size_t depth);

#endif /* OPC_GDSPARSER_H */

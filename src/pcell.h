#ifndef OPC_PCELL_H
#define OPC_PCELL_H

#include "lua/lua.h"

#include "object.h"

struct cellreference
{
    char* identifier;
    object_t* cell;
};

void pcell_initialize_references(void);
void pcell_destroy_references(void);

size_t pcell_get_reference_count(void);
struct cellreference* pcell_get_indexed_cell_reference(unsigned int i);
object_t* pcell_get_cell_reference(const char* identifier);

int open_lpcell_lib(lua_State* L);

#endif // OPC_PCELL_H

#ifndef OPC_TECHNOLOGY_H
#define OPC_TECHNOLOGY_H

#include "lua/lua.h"

#include "generics.h"

struct technology_config
{
    unsigned int metals;
    unsigned int grid;
};

struct via_definition
{
    unsigned int width;
    unsigned int height;
    unsigned int xspace;
    unsigned int yspace;
    int xenclosure;
    int yenclosure;
};

generics_t* technology_get_layer(const char* layername);
int technology_resolve_metal(int metalnum);
struct via_definition** technology_get_via_definitions(int metal1, int metal2);
struct via_definition* technology_get_via_fallback(int metal1, int metal2);
struct via_definition** technology_get_contact_definitions(const char* region);
struct via_definition* technology_get_contact_fallback(const char* region);

void technology_initialize(void);
void technology_destroy(void);

generics_t* technology_make_layer(const char* layername, lua_State* L);

int open_ltechnology_lib(lua_State* L);

#endif // OPC_TECHNOLOGY_H

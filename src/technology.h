#ifndef OPC_TECHNOLOGY_H
#define OPC_TECHNOLOGY_H

#include "lua/lua.h"

#include "vector.h"
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

struct technology_state
{
    struct vector* layertable; // stores generics_t*
    struct vector* viatable; // stores struct viaentry*
    struct technology_config* config;
};

struct technology_state* technology_initialize(void);
void technology_destroy(struct technology_state* state);

generics_t* technology_get_layer(struct technology_state* state, const char* layername);
int technology_resolve_metal(struct technology_state* state, int metalnum);
struct via_definition** technology_get_via_definitions(struct technology_state* state, int metal1, int metal2);
struct via_definition* technology_get_via_fallback(struct technology_state* state, int metal1, int metal2);
struct via_definition** technology_get_contact_definitions(struct technology_state* state, const char* region);
struct via_definition* technology_get_contact_fallback(struct technology_state* state, const char* region);

generics_t* technology_make_layer(const char* layername, lua_State* L);

int open_ltechnology_lib(lua_State* L);

#endif // OPC_TECHNOLOGY_H

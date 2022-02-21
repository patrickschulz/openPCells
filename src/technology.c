#include "generics.h"

#include <stdlib.h>

#include "lua/lauxlib.h"

void _translate(struct hashmap* map)
{
    /*
    for(unsigned int i = 0; i < map->size; ++i)
    {
        generics_t** layer = &map->entries[i].layer;
        switch((*layer)->type)
        {
            case METAL:
            {
                generics_destroy_internal(*layer);
                (*layer)->type = MAPPED;
                (*layer)->layer = malloc(sizeof(struct generic_mapped_t));;
                struct generic_mapped_t* mapped = (*layer)->layer;
                mapped->data = keyvaluearray_create();
                keyvaluearray_add_int(mapped->data, "layer", 11);
                keyvaluearray_add_int(mapped->data, "purpose", 0);
                break;
            }
            default:
                break;
        }
    }
    */
}

int translate(lua_State* L)
{
    (void) L;
    //_translate(&generics_layer_map);
    return 0;
}

int open_technology_lib(lua_State* L)
{
    lua_newtable(L);
    static const luaL_Reg modfuncs[] =
    {
        { "translate", translate },
        { NULL,    NULL                   }
    };
    luaL_setfuncs(L, modfuncs, 0);
    lua_setglobal(L, "technology");
    return 0;
}

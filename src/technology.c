#include "generics.h"

#include "lua/lauxlib.h"

void _translate(struct hashmap* map)
{
    for(unsigned int i = 0; i < map->size; ++i)
    {
        switch(map->entries[i].layer->type)
        {
            case METAL:
                break;
            default:
                break;
        }
    }
}

int translate(lua_State* L)
{
    _translate(&generics_layer_map);
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

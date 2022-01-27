#include "lua/lua.h"
#include "lua/lauxlib.h"

#include <stdlib.h>

#include "lrouter_net.h"
#include "lrouter_route.h"
#include "lrouter_field.h"

struct netcollection
{
    net_t* nets;
    size_t num_nets;
};

static struct netcollection* _initialize(lua_State* L)
{
    size_t num_nets = lua_tointeger(L, 2);
    net_t* nets = calloc(num_nets, sizeof(*nets));
    lua_pushnil(L); // first key
    size_t i = 0;
    while (lua_next(L, 1) != 0)
    {
        printf("%s\n", lua_tostring(L, -2));
        lua_len(L, -1);
        size_t size = lua_tointeger(L, -1);
        lua_pop(L, 1);
        for(size_t j = 1; j <= size; ++j)
        {
            if(j > 2)
            {
                break; // only 2 nets supported currently
            }
            lua_geti(L, -1, j);

            lua_getfield(L, -1, "x");
            int x = lua_tointeger(L, -1);
            lua_pop(L, 1);

            lua_getfield(L, -1, "y");
            int y = lua_tointeger(L, -1);
            lua_pop(L, 1);

            lua_getfield(L, -1, "z");
            int z = lua_tointeger(L, -1);
            lua_pop(L, 1);

            if(j == 1)
            {
                nets[i].x1 = x;
                nets[i].y1 = y;
                nets[i].z1 = z;
            }
            if(j == 2)
            {
                nets[i].x2 = x;
                nets[i].y2 = y;
                nets[i].z2 = z;
            }

            printf("(%d, %d)\n", x, y);

            lua_pop(L, 1);
        }
        ++i;

        lua_pop(L, 1);
    }
    struct netcollection* nc = malloc(sizeof(struct netcollection));
    nc->nets = nets;
    nc->num_nets = num_nets;
    return nc;
}

int lrouter_route(lua_State* L)
{
    printf("calling route\n");
    struct netcollection* nc = _initialize(L);

    sort_nets(nc->nets, nc->num_nets);

    size_t fieldsize = 30;
    size_t num_layers = 4;
    unsigned int via_cost = 10;
    unsigned int wrong_dir_cost = 10;
    int*** field = init_field(fieldsize, num_layers);

    fill_ports(nc->nets, nc->num_nets, field);

    for(unsigned int i = 0; i < nc->num_nets; ++i)
    {
	nc->nets[i].routed = route(nc->nets[i], field, fieldsize,
				   num_layers, via_cost, wrong_dir_cost);
    }

    print_nets(nc->nets, nc->num_nets);

    destroy_field(field, fieldsize, num_layers);
    free(nc->nets);
    free(nc);
    return 0;
}

int open_lrouter_lib(lua_State* L)
{
    static const luaL_Reg modfuncs[] =
    {
        { "route", lrouter_route },
        { NULL,    NULL          }
    };
    lua_newtable(L);
    luaL_setfuncs(L, modfuncs, 0);
    lua_setglobal(L, "router");
    return 0;
}

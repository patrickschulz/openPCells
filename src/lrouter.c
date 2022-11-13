#include "lua/lua.h"
#include "lua/lauxlib.h"

#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <stdbool.h>

#include "lrouter_net.h"
#include "lrouter_route.h"
#include "lrouter_field.h"
#include "lrouter_moves.h"

#include "vector.h"

#define EXCLUDE 1
#define CELL_PORT_LAYER 0
#define DRAW 1
#define NODRAW 0

#define UABSDIFF(v1, v2) (v1 > v2 ? v1 - v2 : v2 - v1)
#define MANHATTAN_DIST(pos1, pos2) (UABSDIFF(pos1->x, pos2->x) +\
        UABSDIFF(pos1->y, pos2->y))
#define CEIL(x1, x2) (x1/x2 + (x1 % x2 != 0))

struct netcollection {
    struct vector* nets;
    struct vector* blockages; /* stores vector* of struct rpoint* */
};

static struct rpoint* _create_point(lua_State *L)
{
    lua_getfield(L, -1, "x");
    int x = lua_tointeger(L, -1) - 1;
    lua_pop(L, 1);
    lua_getfield(L, -1, "y");
    int y = lua_tointeger(L, -1) - 1;
    lua_pop(L, 1);
    lua_getfield(L, -1, "z");
    int z = lua_tointeger(L, -1);
    lua_pop(L, 1);
    return point_new(x, y, z, 0);
}

static void _make_nets(const char* name, struct vector* nets,
        struct vector* positions)
{
    struct net *net = net_create(name, NO_SUFFIX, positions);
    vector_append(nets, net);
}

static struct position* _create_net_position(lua_State* L)
{
    lua_getfield(L, -1, "instance");
    const char *instance = lua_tostring(L, -1);
    lua_pop(L, 1);

    lua_getfield(L, -1, "port");
    const char *port = lua_tostring(L, -1);
    lua_pop(L, 1);

    lua_getfield(L, -1, "x");
    int x = lua_tointeger(L, -1);
    lua_pop(L, 1);

    lua_getfield(L, -1, "y");
    int y = lua_tointeger(L, -1);
    lua_pop(L, 1);

    return net_create_position(instance, port, x - 1, y - 1, CELL_PORT_LAYER);
}

static struct netcollection* _initialize(lua_State* L)
{
    size_t num_nets = lua_rawlen(L, 1);
    struct vector* nets = vector_create(num_nets, net_destroy);
    /* nets */
    for(size_t i = 1; i < num_nets + 1; i++)
    {
        lua_geti(L, 1, i);

        lua_getfield(L, -1, "name");
        const char *name = lua_tostring(L, -1);
        lua_pop(L, 1);

        lua_getfield(L, -1, "positions");
        size_t size = lua_rawlen(L, -1);
        if(size < 2)
        {
            continue;
        }

        struct vector* positions = vector_create(size, net_destroy_position);
        for(size_t j = 1; j <= size; ++j)
        {
            lua_geti(L, -1, j);
            struct position* pos = _create_net_position(L);
            vector_append(positions, pos);
            lua_pop(L, 1);
        }
        _make_nets(name, nets, positions);
        lua_pop(L, 2);
    }

    /* blockages */
    size_t num_blockages = lua_rawlen(L, 2);
    struct vector* blockages = vector_create(num_blockages, free);
    for(size_t i = 1; i <= num_blockages; i++)
    {
        lua_geti(L, 2, i);
        size_t route_size = lua_rawlen(L, -1);
        struct vector* deltas = vector_create(route_size, free);
        for(size_t j = 1; j <= route_size; j++)
        {
            lua_geti(L, -1, j);
            vector_append(deltas, _create_point(L));
            lua_pop(L, 1);
        }
        vector_append(blockages, deltas);
        lua_pop(L, 1);
    }

    struct netcollection* nc = malloc(sizeof(*nc));
    nc->nets = nets;
    nc->blockages = blockages;
    return nc;
}

static void _fill_blockages(struct field* field, struct netcollection *nc)
{
    for(size_t i = 0; i < vector_size(nc->blockages); i++)
    {
        struct vector* deltas = vector_get(nc->blockages, i);
        for(size_t j = 0; j < vector_size(deltas) - 1; j++)
        {

            struct rpoint* start = vector_get(deltas, j);
            struct rpoint* end = vector_get(deltas, j + 1);
            field_create_blockage(field, start, end);
        }
    }
}

static void _create_routing_stack_data(lua_State *L, struct net *net)
{
    lua_newtable(L);
    lua_pushstring(L, net_get_name(net));
    lua_setfield(L, -2, "name");

    int num_deltas = net_get_num_deltas(net);
    int table_pos = 0;

    for(int i = 0; i < num_deltas; i++, table_pos++)
    {
        lua_newtable(L);
        struct rpoint *point = net_get_delta(net, i);
        if(point_get_score(point) == PORT)
        {
            if(i != 0)
            {
                moves_create_via(L, -1, DRAW);
                lua_rawseti(L, -2, table_pos + 1);
                table_pos++;

                lua_newtable(L);
            }
            const struct position *pos =
                net_get_position_at_point(net, point);

            moves_create_port(L, net_position_get_inst(pos),
                    net_position_get_port(pos));
            lua_rawseti(L, -2, table_pos + 1);
            table_pos++;

            /* FIXME: via after first anchor */
            lua_newtable(L);
            moves_create_via(L, 1, NODRAW);

        }
        else if(point->x)
        {
            moves_create_delta(L, X_DIR, -1 * point->x);
        }
        else if(point->y)
        {
            moves_create_delta(L, Y_DIR, -1 * point->y);
        }
        else
        {
            moves_create_via(L, -1 * point->z, DRAW);
        }

        lua_rawseti(L, -2, table_pos + 1);
    }

}

int lrouter_route(lua_State* L)
{
    puts("started routing\n");

    struct netcollection* nc = _initialize(L);
    const size_t field_height = lua_tointeger(L, 4);
    const size_t field_width = lua_tointeger(L, 3);
    printf("field width %zu, field height %zu\n", field_height, field_width);
    const size_t num_layers = 5;

    struct field* field = field_init(field_width, field_height, num_layers);
    _fill_blockages(field, nc);

    int routed_count = 0;

    /* table for all nets */
    lua_newtable(L);
    unsigned int num_nets = vector_size(nc->nets);

    for(unsigned int i = 0; i < num_nets; ++i)
    {
        nets_fill_ports(nc->nets, field);
        struct net* net = vector_get(nc->nets, i);
        route(net, field);
        nets_fill_ports(nc->nets, field);

        if(net_is_routed(net))
        {
            _create_routing_stack_data(L, net);
            lua_rawseti(L, -2, routed_count + 1);
            routed_count++;

            printf("routed %s: %i/%i\n", net_get_name(net), i + 1, num_nets);
        }
        else
        {
            printf("couldnt route %s\n", net_get_name(net));
        }
    }
    field_print(field, 0);
    getchar();
    lua_pushinteger(L, routed_count);

    field_destroy(field);
    vector_destroy(nc->nets);
    vector_destroy(nc->blockages);
    free(nc);
    puts("finished routing\n");
    return 2;
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


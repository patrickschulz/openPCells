#include "lua/lua.h"
#include "lua/lauxlib.h"

#include <stdlib.h>

#include "lrouter_net.h"
#include "lrouter_route.h"
#include "lrouter_field.h"
#include "lrouter_moves.h"

#include "vector.h"

#define CELL_PORT_LAYER 0

struct netcollection {
    struct vector* nets;
    struct vector* blockages; /* stores vector* of struct rpoint* */
};

struct routerstate {
    struct netcollection* nc;
    struct field* field;
    struct vector* deltas;
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

static void _make_and_append_net(const char* name, struct vector* nets, struct vector* positions)
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
    /* nets */
    size_t num_nets = lua_rawlen(L, 1);
    struct vector* nets = vector_create(num_nets, net_destroy);
    for(size_t i = 1; i < num_nets + 1; i++)
    {
        lua_geti(L, 1, i);

        lua_getfield(L, -1, "name");
        const char *name = lua_tostring(L, -1);
        lua_pop(L, 1); // FIXME: while this is probably fine since the string is in the table,
                       // the lua specificatino DOES NOT GUARANTEE that the pointer is valid after its removal from the stack

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
        _make_and_append_net(name, nets, positions);
        lua_pop(L, 2);
    }

    /* blockages */
    // FIXME: the destructor for blockages looks wrong
    //          edit: it is not, but a dedicated function would be better, semantically
    size_t num_blockages = lua_rawlen(L, 2);
    struct vector* blockages = vector_create(num_blockages, vector_destroy);
    for(size_t i = 1; i <= num_blockages; i++)
    {
        lua_geti(L, 2, i);
        size_t route_size = lua_rawlen(L, -1);
        struct vector* blockage = vector_create(route_size, free);
        for(size_t j = 1; j <= route_size; j++)
        {
            lua_geti(L, -1, j);
            vector_append(blockage, _create_point(L));
            lua_pop(L, 1);
        }
        vector_append(blockages, blockage);
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
        struct vector* blockage = vector_get(nc->blockages, i);
        for(size_t j = 0; j < vector_size(blockage) - 1; j++)
        {
            struct rpoint* start = vector_get(blockage, j);
            struct rpoint* end = vector_get(blockage, j + 1);
            field_create_blockage(field, start, end);
        }
    }
}

static void _create_routing_stack_data(lua_State *L, const char* name, const struct net *net)
{
    lua_newtable(L); // table for a single net
    lua_pushstring(L, name);
    lua_setfield(L, -2, "name");
    for(size_t i = 0; i < net_get_endpoints_size(net); ++i)
    {
        const struct position* endpoint = net_get_endpoint(net, i);
        moves_create_port(L, net_position_get_inst(endpoint), net_position_get_port(endpoint), 0); // 0: nodraw
        lua_rawseti(L, -2, i + 1);
    }
}

static void _create_routing_stack_data_with_deltas(lua_State *L, const char* name, const struct net *net, const struct vector* deltas)
{
    lua_newtable(L); // table for a single net
    lua_pushstring(L, name);
    lua_setfield(L, -2, "name");

    // FIXME: currently ports start at metal 1, but that should be in the port info
    int curr_metal = 1; // FIXME: = get_port_metal() or something like that
    int is_first_conn = 1;
    int table_pos = 1;

    for(size_t i = 0; i < vector_size(deltas); i++)
    {
        //const struct rpoint *point = net_get_delta(net, i);
        const struct rpoint *point = vector_get_const(deltas, i);
        if(point_get_score(point) == PORT)
        {
            if(i != 0)
            {
                if(is_first_conn)
                {
                    moves_create_via(L, 1 - curr_metal);
                }
                else
                {
                    moves_create_via_nodraw(L, 1 - curr_metal);
                }
                lua_rawseti(L, -2, table_pos);
                table_pos++;
                curr_metal = 1;
                is_first_conn = 0;
            }
            const struct position *pos = net_get_position_at_point(net, point);

            moves_create_port(L, net_position_get_inst(pos), net_position_get_port(pos), 1); // 1: nodraw
            lua_rawseti(L, -2, table_pos);
            table_pos++;

            /* FIXME: via after first anchor */
            moves_create_via(L, 1);
            curr_metal++;
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
            curr_metal += point->z;
            moves_create_via(L, point->z);
        }
        lua_rawseti(L, -2, table_pos);
        ++table_pos;
    }

    if(is_first_conn)
    {
        moves_create_via(L, -1);
        lua_rawseti(L, -2, table_pos);
    }
}

int lrouter_initialize(lua_State* L)
{
    struct netcollection* nc = _initialize(L);
    const size_t field_height = lua_tointeger(L, 4) + 1;
    const size_t field_width = lua_tointeger(L, 3) + 1;
    const size_t num_layers = 5;

    struct field* field = field_init(field_width, field_height, num_layers);
    _fill_blockages(field, nc);

    struct routerstate* state = malloc(sizeof(*state));
    state->nc = nc;
    state->field = field;

    lua_pushlightuserdata(L, state);
    return 1;
}

int lrouter_route(lua_State* L)
{
    struct routerstate* state = lua_touserdata(L, 1);

    unsigned int num_nets = vector_size(state->nc->nets);

    state->deltas = vector_create(num_nets, vector_destroy);

    for(unsigned int i = 0; i < num_nets; ++i)
    {
        nets_fill_ports(state->nc->nets, state->field);
        struct net* net = vector_get(state->nc->nets, i);
        struct vector* deltas = route(net, state->field);
        vector_append(state->deltas, deltas);
        nets_fill_ports(state->nc->nets, state->field);
    }

    return 0;
}

int lrouter_resolve_routes(lua_State* L)
{
    struct routerstate* state = lua_touserdata(L, 1);

    /* table for all nets */
    lua_newtable(L);
    unsigned int num_nets = vector_size(state->nc->nets);

    int index = 1;
    for(unsigned int i = 0; i < num_nets; ++i)
    {
        struct net* net = vector_get(state->nc->nets, i);

        const char* name = net_get_name(net);
        if(net_is_routed(net))
        {
            struct vector* deltas = vector_get(state->deltas, i);
            _create_routing_stack_data_with_deltas(L, name, net, deltas);
            lua_rawseti(L, -2, index);
        }
        else
        {
            _create_routing_stack_data(L, name, net);
            lua_rawseti(L, -2, index);
        }
        ++index;
    }

    return 1;
}

int open_lrouter_lib(lua_State* L)
{
    static const luaL_Reg modfuncs[] =
    {
        { "initialize",     lrouter_initialize      },
        { "route",          lrouter_route           },
        { "resolve_routes", lrouter_resolve_routes  },
        { NULL,             NULL                    }
    };
    lua_newtable(L);
    luaL_setfuncs(L, modfuncs, 0);
    lua_setglobal(L, "router");
    return 0;
}


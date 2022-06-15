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
#include "ldebug.h"

#include "vector.h"

#define UABSDIFF(v1, v2) (v1 > v2 ? v1 - v2 : v2 - v1)
#define MANHATTAN_DIST(pos1, pos2) (UABSDIFF(pos1->x, pos2->x) + UABSDIFF(pos1->y, pos2->y))

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

/*
 * split nets with more than 2 points into more nets with 2 points
 * with minimum manhattan distance in between
 * e. g. net0: p1 has manhattan distance (m.d.) 4 to p2 and p1 has 3 m.d. to
 * p3 then: make new nets with p1 and p3, and p2 and p3
 */
static void _split_and_make_nets(const char* name, struct vector* nets, struct vector* positions)
{
    size_t splitcount = 0;
    while(vector_size(positions) > 1)
    {
        struct position* pos1 = vector_get(positions, 0);
        struct position* pos2 = NULL; // FIXME: check for NULL when using this
        int mindist = INT_MAX;
        for(size_t k = 1; k < vector_size(positions); k++)
        {
            struct position* npos = vector_get(positions, k);
            int nextdist = MANHATTAN_DIST(pos1, npos);
            if(nextdist < mindist)
            {
                mindist = nextdist;
                pos2 = npos;
            }
        }

        if (mindist == 0)
        {
            continue;
        }

        struct net *net = net_create(name, splitcount, net_copy_position(pos1), net_copy_position(pos2));

        vector_remove(positions, 0, net_destroy_position);

        vector_append(nets, net);
        splitcount++;
    }
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

    return net_create_position(instance, port, x - 1, y - 1);
}

static struct netcollection* _initialize(lua_State* L)
{
    size_t num_nets = lua_rawlen(L, 1);
    struct vector* nets = vector_create(num_nets);

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

        struct vector* positions = vector_create(size);
        for(size_t j = 1; j <= size; ++j)
        {
            lua_geti(L, -1, j);
            struct position* pos = _create_net_position(L);
            vector_append(positions, pos);
            lua_pop(L, 1);
        }
        _split_and_make_nets(name, nets, positions);
        vector_destroy(positions, net_destroy_position);
        lua_pop(L, 2);
    }

    /* blockages */
    size_t num_blockages = lua_rawlen(L, 2);
    struct vector* blockages = vector_create(num_blockages);
    for(size_t i = 1; i <= num_blockages; i++)
    {
        lua_geti(L, 2, i);
        size_t route_size = lua_rawlen(L, -1);
        struct vector* deltas = vector_create(route_size);
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

static void _destroy_blockage(void* ptr)
{
    struct vector* deltas = ptr;
    vector_destroy(deltas, free);
}

int lrouter_route(lua_State* L)
{
    struct netcollection* nc = _initialize(L);
    const size_t field_height = lua_tointeger(L, 4);
    const size_t field_width = lua_tointeger(L, 3);
    const size_t num_layers = 3;

    const unsigned int via_cost = 10;
    const unsigned int wrong_dir_cost = 30;

    struct field* field = field_init(field_width + 1, field_height, num_layers);
    _fill_blockages(field, nc);

    net_sort_nets(nc->nets);
    net_fill_ports(nc->nets, field);

    int routed_count = 0;

    /* table for all nets */
    lua_newtable(L);

    for(unsigned int i = 0; i < vector_size(nc->nets); ++i)
    {
        struct net* net = vector_get(nc->nets, i);
        route(net, field, via_cost, wrong_dir_cost);

        if(net_is_routed(net))
        {
            /* table for whole net */
            lua_newtable(L);
            lua_pushstring(L, net_get_name(net));
            lua_setfield(L, -2, "name");

            /* first anchor entry */
            lua_newtable(L);
            const struct position* pos0 = net_get_startpos(net);
            moves_create_anchor(L, pos0->instance, pos0->port);
            lua_rawseti(L, -2, 1);

            /* FIXME: via after first anchor */
            lua_newtable(L);
            moves_create_via(L, 1);
            lua_rawseti(L, -2, 2);

            net_create_deltas(net);

            int point_count = 2;
            while(1)
            {
                struct rpoint* curr_point = net_dequeue_point(net);
                if(!curr_point)
                {
                    break;
                }
                lua_newtable(L);
                if(curr_point->x)
                {
                    moves_create_delta(L, X_DIR, curr_point->x);
                }
                else if(curr_point->y)
                {
                    moves_create_delta(L, Y_DIR, curr_point->y);
                }
                else if(curr_point->z)
                {
                    moves_create_via(L, -1 * curr_point->z);
                }

                /* move entry */
                /* FIXME: not sure why "zero" deltas are happening */
                if(curr_point->x || curr_point->y || curr_point->z)
                {
                    lua_rawseti(L, -2, point_count + 1);
                    point_count++;
                }
                else
                {
                    lua_pop(L, 1);
                }
                free(curr_point);
            }

            /* FIXME: via before second anchor */
            lua_newtable(L);
            moves_create_via(L, -1);
            lua_rawseti(L, -2, point_count + 1);

            /* second anchor */
            lua_newtable(L);
            const struct position* pos1 = net_get_endpos(net);
            moves_create_anchor(L, pos1->instance, pos1->port);
            lua_rawseti(L, -2, point_count + 2);

            /* put moves table into bigger table */
            lua_rawseti(L, -2, routed_count + 1);
            routed_count++;
        }
    }
    /* num_routed_nets on stack */
    lua_pushinteger(L, routed_count);

    for(unsigned int i = 0; i < 2; ++i)
    {
        //field_print(field, i);
    }

    field_destroy(field);
    vector_destroy(nc->nets, net_destroy);
    vector_destroy(nc->blockages, _destroy_blockage);
    free(nc);
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


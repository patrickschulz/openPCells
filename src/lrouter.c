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

#define MANHATTAN_DIST(x1, y1, x2, y2) (abs(x1 - x2) + abs(y1 - y2))

struct netcollection {
    struct vector* nets;
    struct vector* blockages; /* stores vector* of point_t* */
};

static point_t* _create_point(lua_State *L)
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


static struct netcollection* _initialize(lua_State* L)
{
    size_t num_nets = lua_rawlen(L, 1);
    struct vector* nets = vector_create(num_nets);

    for(size_t i = 1; i < num_nets + 1; i++)
    {
        lua_geti(L, 1, i);

        lua_getfield(L, -1, "name");
        const char *name = lua_tostring(L, -1);

        lua_pop(L, 1);

        lua_getfield(L, -1, "positions");
        size_t size = lua_rawlen(L, -1);

        /* don't include nets with only one endpoint */
        if(size < 2)
        {
            continue;
        }

        struct net* net = net_create(name, size);

        /* fill in net struct from lua */
        for(size_t j = 1; j <= size; ++j)
        {
            lua_geti(L, -1, j);

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

            struct position* pos = net_create_position(instance, port, x - 1, y - 1);
            vector_append(net->positions, pos);

            lua_pop(L, 1);
        }
        vector_append(nets, net);
        lua_pop(L, 1);
    }

    /* fill in blockage deltas */
    size_t num_blockages = lua_rawlen(L, 2);
    struct vector* blockages = vector_create(num_blockages);
    for(size_t i = 1; i <= num_blockages; i++)
    {
        lua_geti(L, 2, i);

        /* now we have a list of deltas forming one blockage route */
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
            point_t* start = vector_get(deltas, j);
            point_t* end = vector_get(deltas, j + 1);
            field_create_blockage(field, start, end);
        }
    }
}

/*
 * split nets with more than 2 points into more nets with 2 points
 * with minimum manhattan distance in between
 * e. g. net0: p1 has manhattan distance (m.d.) 4 to p2 and p1 has 3 m.d. to
 * p3 then: make new nets with p1 and p3, and p2 and p3
 */
static void _split_nets(struct netcollection* nc)
{
    /* iterate over all nets */
    for(size_t i = 0; i < vector_size(nc->nets); i++)
    {
        struct net* net = vector_get(nc->nets, i);
        /* split "more" if still less than 3 positions */
        if(vector_size(net->positions) < 3)
        {
            continue;
        }

        /* iterate over all points in net */
        size_t splitcount = 0;
        for(int j = 0; j < (int)vector_size(net->positions); j++)
        {
            int tempx, tempy, nextx, nexty, mindist, nextdist;
            size_t mink = 0;
            struct position* pos = vector_get(net->positions, 0);
            tempx = (int)pos->x;
            tempy = (int)pos->y;
            mindist = INT_MAX;
            for(size_t k = 0; k < vector_size(net->positions); k++)
            {
                /* dont check m.d. for itself again */
                if((int)k == j)
                {
                    continue;
                }

                struct position* npos = vector_get(net->positions, k);
                nextx = (int)npos->x;
                nexty = (int)npos->y;
                if((nextdist = MANHATTAN_DIST(tempx, tempy, nextx, nexty)) < mindist)
                {
                    mindist = nextdist;
                    mink = k;
                }
            }

            if (mindist == 0)
            {
                continue;
            }

            /*
             * now point nr. j in net has minimum m.d. to point nr. mink
             * so create new split net with only 2 now
             */
            char* name = malloc(strlen(net->name) + 10);
            sprintf(name, "%s_(%zu)", net->name, splitcount);
            struct net *newnet = net_create(name, 2);
            free(name);

            vector_append(newnet->positions, net_copy_position(net, 0));
            vector_append(newnet->positions, net_copy_position(net, mink));

            vector_remove(net->positions, 0, net_destroy_position);

            /* continute splitting net */
            if(vector_size(net->positions) > 2)
            {
                j = -1;
            }

            /* add new net to end of net list */
            vector_append(nc->nets, newnet);
            splitcount++;
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

    _split_nets(nc);
    net_sort_nets(nc->nets);
    net_fill_ports(nc->nets, field);

    int routed_count = 0;

    /* table for all nets */
    lua_newtable(L);

    for(unsigned int i = 0; i < vector_size(nc->nets); ++i)
    {
        struct net* net = vector_get(nc->nets, i);
        /* dont route nets without at least 2 points */
        if(vector_size(net->positions) > 1)
        {
            net->routed = route(net, field, via_cost, wrong_dir_cost);
        }

        if(net->routed)
        {
            /* table for whole net */
            lua_newtable(L);
            lua_pushstring(L, net->name);
            lua_setfield(L, -2, "name");

            /* first anchor entry */
            lua_newtable(L);
            struct position* pos0 = vector_get(net->positions, 0);
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
                point_t* curr_point = queue_dequeue(net->path);
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
            struct position* pos1 = vector_get(net->positions, 1);
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
        field_print(field, i);
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


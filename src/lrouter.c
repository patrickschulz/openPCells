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

#define MANHATTAN_DIST(x1, y1, x2, y2) (abs(x1 - x2) + abs(y1 - y2))

struct blockage_route
{
    point_t *deltas;
    size_t num_deltas;
};

struct netcollection
{
    net_t *nets;
    size_t num_nets;
    struct blockage_route *blockages;
    size_t num_blockages;
};

/* creates point_t if lua stack is in certain order */
static point_t lrouter_create_point(lua_State *L)
{
    point_t point;

    lua_getfield(L, -1, "x");
    point.x = lua_tointeger(L, -1) - 1;
    lua_pop(L, 1);
    lua_getfield(L, -1, "y");
    point.y = lua_tointeger(L, -1) - 1;
    lua_pop(L, 1);
    lua_getfield(L, -1, "z");
    point.z = lua_tointeger(L, -1);
    lua_pop(L, 1);

    return point;
}


static struct netcollection* _initialize(lua_State* L)
{
    size_t num_nets = lua_rawlen(L, 1);
    net_t* nets = calloc(num_nets, sizeof(*nets));

    for(size_t i = 1; i < num_nets + 1; i++)
    {
	lua_geti(L, 1, i);

	lua_getfield(L, -1, "name");
	const char *name = lua_tostring(L, -1);

	lua_pop(L, 1);

	lua_getfield(L, -1, "positions");
	size_t size = lua_rawlen(L, -1);

	nets[i - 1].size = size;
	nets[i - 1].name = calloc(strlen(name) + 1, 1);
	strcpy(nets[i - 1].name, name);
	nets[i - 1].positions = calloc(size, sizeof(position_t));

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

	    position_t pos = *net_create_position(instance, port, x - 1, y - 1);
	    nets[i - 1].positions[j - 1] = pos;

            lua_pop(L, 1);
        }
        lua_pop(L, 1);
    }

    /* fill in blockage deltas */
    size_t num_blockages = lua_rawlen(L, 2);
    struct blockage_route *blockages = calloc(num_blockages,
				      sizeof(*blockages));

    for(size_t i = 1; i <= num_blockages; i++)
    {
	lua_geti(L, 2, i);

	/* now we have a list of deltas forming one blockage route */
	size_t route_size = lua_rawlen(L, -1);
	struct blockage_route *blockage_route =
		calloc(1, sizeof(*blockage_route));
	blockage_route->deltas = calloc(route_size, sizeof(point_t));
	blockage_route->num_deltas = route_size;

	for(size_t j = 1; j <= route_size; j++)
	{
	    lua_geti(L, -1, j);
	    blockage_route->deltas[j - 1] = lrouter_create_point(L);
	    lua_pop(L, 1);
	}
	blockages[i - 1] = *blockage_route;
	lua_pop(L, 1);
    }

    struct netcollection* nc = malloc(sizeof(struct netcollection));
    nc->nets = nets;
    nc->num_nets = num_nets;
    nc->blockages = blockages;
    nc->num_blockages = num_blockages;

    for(int i = 0; i < num_blockages; i++)
    {
	printf("blockage nr %i\n", i);
        for(int j = 0; j < blockages[i].num_deltas; j++)
        {
	    int x = blockages[i].deltas[j].x;
	    int y = blockages[i].deltas[j].y;
	    int z = blockages[i].deltas[j].z;
	    printf("\tdelta %i %i %i\n", x, y, z);
        }
    }
    return nc;
}

static void lrouter_fill_blockages(int ***field, struct netcollection *nc)
{
    for(int i = 0; i < (int)nc->num_blockages; i++)
    {
	for(int j = 0; j < (int)nc->blockages[i].num_deltas - 1; j++)
	{
		point_t start = nc->blockages[i].deltas[j];
		point_t end = nc->blockages[i].deltas[j + 1];
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
static void lrouter_split_nets(struct netcollection* nc)
{
    /* iterate over all nets */
    for(size_t i = 0; i < nc->num_nets; i++)
    {
            /* split "more" if still less than 3 positions */
            if(nc->nets[i].size < 3)
                continue;

            size_t splitcount = 0;
            /* iterate over all points in net */
            for(int j = 0; j < (int)nc->nets[i].size; j++)
            {
                int tempx, tempy, nextx, nexty, mindist, nextdist;
                size_t mink = 0;
                tempx = (int)nc->nets[i].positions[0].x;
                tempy = (int)nc->nets[i].positions[0].y;
                mindist = INT_MAX;
                for(size_t k = 0; k < nc->nets[i].size; k++)
                {
                    /* dont check m.d. for itself again */
                    if((int)k == j)
                        continue;

                    nextx = (int)nc->nets[i].positions[k].x;
                    nexty = (int)nc->nets[i].positions[k].y;
                    if((nextdist = MANHATTAN_DIST
                        (tempx, tempy, nextx, nexty)) < mindist)
                    {
                        mindist = nextdist;
                        mink = k;
                    }
                }

                if (mindist == 0)
                    continue;

                /*
                 * now point nr. j in net has minimum m.d. to point nr. mink
                 * so create new split net with only 2 now
                */
                net_t *newnet = calloc(1, sizeof(net_t));
                newnet->name = calloc(strlen(nc->nets[i].name) + 10, 1);
                newnet->positions = calloc(2, sizeof(position_t));

                sprintf(newnet->name, "%s_(%zu)", nc->nets[i].name, splitcount);

                newnet->positions[0] = *net_create_position(
                    nc->nets[i].positions[0].instance,
                    nc->nets[i].positions[0].port,
                    nc->nets[i].positions[0].x,
                    nc->nets[i].positions[0].y);

                newnet->positions[1] = *net_create_position(
                    nc->nets[i].positions[mink].instance,
                    nc->nets[i].positions[mink].port,
                    nc->nets[i].positions[mink].x,
                    nc->nets[i].positions[mink].y);

                newnet->size = 2;

                net_del_nth_el_arr(nc->nets[i].positions, 0, nc->nets[i].size);
                nc->nets[i].size--;

                /* continute splitting net */
                if(nc->nets[i].size > 2)
                    j = -1;

                /* add new net to end of net list */
                nc->nets = (net_t *)realloc(nc->nets, sizeof(net_t) *
                                (nc->num_nets + 1));
                nc->nets[nc->num_nets] = *newnet;
                nc->num_nets++;
                splitcount++;
            }
    }
}

int lrouter_route(lua_State* L)
{
    struct netcollection* nc = _initialize(L);
    const size_t field_height = lua_tointeger(L, 4);
    const size_t field_width = lua_tointeger(L, 3);
    const size_t num_layers = 3;

    const unsigned int via_cost = 61;
    const unsigned int wrong_dir_cost = 11;
    const unsigned int step_cost = 2;

    int*** field = field_init(field_width, field_height, num_layers);
    lrouter_fill_blockages(field, nc);

    lrouter_split_nets(nc);
    net_sort_nets(nc->nets, nc->num_nets);
    net_fill_ports(nc->nets, nc->num_nets, field);

    int routed_count = 0;

    /* table for all nets */
    lua_newtable(L);

    for(unsigned int i = 0; i < nc->num_nets; ++i)
    {

        /* dont route nets without at least 2 points */
        if(nc->nets[i].size > 1)
        {
	        nc->nets[i].routed = route(&nc->nets[i], field, field_width,
                       field_height, num_layers, via_cost,
                       wrong_dir_cost, step_cost);
        }


        if(nc->nets[i].routed)
        {
            /* table for whole net */
            lua_newtable(L);

            /* first anchor entry */
            lua_newtable(L);
	    moves_create_anchor(L, nc->nets[i].positions[0].instance,
				nc->nets[i].positions[0].port, nc->nets[i].name);
            lua_rawseti(L, -2, 1);

            /* FIXME: via after first anchor */
            lua_newtable(L);
	    moves_create_via(L, 1);
            lua_rawseti(L, -2, 2);

            net_create_deltas(&nc->nets[i]);

            point_t *curr_point;
            int point_count = 2;
            while((curr_point = (point_t *)queue_dequeue(nc->nets[i].path))
                      != NULL)
                {
                    lua_newtable(L);
                    if(curr_point->x)
			moves_create_delta(L, X_DIR, curr_point->x);
		    else if(curr_point->y)
			moves_create_delta(L, Y_DIR, curr_point->y);
		    else if(curr_point->z)
			moves_create_via(L, -1 * curr_point->z);

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
                }

                /* FIXME: via before second anchor */
	        lua_newtable(L);
	        moves_create_via(L, -1);
	        lua_rawseti(L, -2, point_count + 1);

		/* second anchor */
		lua_newtable(L);
	        moves_create_anchor(L, nc->nets[i].positions[1].instance,
				nc->nets[i].positions[1].port, nc->nets[i].name);
		lua_rawseti(L, -2, point_count + 2);

		/* put moves table into bigger table */
		lua_rawseti(L, -2, routed_count + 1);
		routed_count++;
        }
    }
    /* num_routed_nets on stack */
    lua_pushinteger(L, routed_count);

    net_print_nets(nc->nets, nc->num_nets);
    field_print(field, field_width, field_height, 0);
    field_print(field, field_width, field_height, 1);
    //field_print(field, field_width, field_height, 2);
    usleep(1000000);

    field_destroy(field, field_width, field_height, num_layers);
    free(nc->nets);
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

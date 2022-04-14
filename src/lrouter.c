#include "lua/lua.h"
#include "lua/lauxlib.h"

#include <stdlib.h>
#include <string.h>

#include "lrouter_net.h"
#include "lrouter_route.h"
#include "lrouter_field.h"
#include "ldebug.h"

#define MANHATTAN_DIST(x1, y1, x2, y2) (abs(x1 - x2) + abs(y1 - y2))

struct netcollection
{
    net_t *nets;
    size_t num_nets;
};

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
    struct netcollection* nc = malloc(sizeof(struct netcollection));
    nc->nets = nets;
    nc->num_nets = num_nets;
    return nc;
}

/* deletes the nth element of an position_t array and resizes it */
static void del_nth_el_arr(position_t *arr, size_t n, size_t arr_size)
{
    if(arr == NULL || n >= arr_size)
        return;

    for(size_t i = n; i < arr_size - 1; i++)
    {
        arr[i] = arr[i+1];
    }
    position_t *new_arr = realloc(arr, sizeof(position_t) * (arr_size - 1));

    if (!new_arr)
    {
	printf("couldnt realloc in del_nth_el_arr\n");
	return;
    }
    else
    {
	arr = new_arr;
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

                del_nth_el_arr(nc->nets[i].positions, 0, nc->nets[i].size);
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
    const size_t field_height = lua_tointeger(L, 3);
    const size_t field_width = lua_tointeger(L, 2);
    const size_t num_layers = 3;

    const unsigned int via_cost = 10;
    const unsigned int wrong_dir_cost = 30;

    int*** field = init_field(field_width, field_height, num_layers);

    lrouter_split_nets(nc);
    sort_nets(nc->nets, nc->num_nets);

    int count = 0;

    /* table for all nets */
    lua_newtable(L);

    for(unsigned int i = 0; i < nc->num_nets; ++i)
    {

        /* dont route nets without at least 2 points */
        if(nc->nets[i].size > 1)
        {
	        nc->nets[i].routed = route(&nc->nets[i], field, field_width,
                       field_height, num_layers, via_cost,
                       wrong_dir_cost);
        }

	    /* table for whole net */
        lua_newtable(L);

        /* first anchor entry */
        lua_newtable(L);
        lua_pushstring(L, "anchor");
        lua_setfield(L, -2, "type");
    
        lua_pushstring(L, nc->nets[i].positions[0].port);
        lua_setfield(L, -2, "anchor");
    
        lua_pushstring(L, nc->nets[i].positions[0].instance);
        lua_setfield(L, -2, "name");
        lua_rawseti(L, -2, 1);
    
        if(nc->nets[i].routed)
        {
            print_path(nc->nets[i]); 
            point_t *curr_point;
            int point_count = 1;
            while((curr_point = (point_t *)queue_dequeue(nc->nets[i].path))
                      != NULL)
                {
                    printf("getting points from %s\n", nc->nets[i].name);
                    lua_newtable(L);
                    if(curr_point->x)
                    {
                        lua_pushstring(L, "delta");
                        lua_setfield(L, -2, "type");
    
                        lua_pushinteger(L, curr_point->x);
                        lua_setfield(L, -2, "x");
                    }
                    if(curr_point->y)
                    {
                        lua_pushstring(L, "delta");
                        lua_setfield(L, -2, "type");
    
                        lua_pushinteger(L, curr_point->y);
                        lua_setfield(L, -2, "y");
                    }
                    if(curr_point->z)
                    {
                        lua_pushstring(L, "via");
                        lua_setfield(L, -2, "type");
    
                        lua_pushinteger(L, curr_point->z);
                        lua_setfield(L, -2, "z");
                    }
                    /* move entry */
                    lua_rawseti(L, -2, point_count + 1);
                    point_count++;
                }
                count++;
            }
        /* put moves table into bigger table */
        lua_rawseti(L, -2, i + 1);
    }

    /* num_routed_nets on stack */
    lua_pushinteger(L, count);

    print_nets(nc->nets, nc->num_nets);
    print_field(field, field_width, field_height, 0);
    print_field(field, field_width, field_height, 1);
    print_field(field, field_width, field_height, 2);
    usleep(1000000);

    destroy_field(field, field_width, field_height, num_layers);
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

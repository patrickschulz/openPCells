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
    size_t num_nets = lua_tointeger(L, 2);
    net_t* nets = calloc(num_nets, sizeof(*nets));
    lua_pushnil(L); // first key
    size_t i = 0;
    while (lua_next(L, 1) != 0)
    {
	const char *name = lua_tostring(L, -2);
        lua_len(L, -1);
        size_t size = lua_tointeger(L, -1);
        lua_pop(L, 1);

	nets[i].size = size;
	nets[i].xs = calloc(size, sizeof(unsigned int));
	nets[i].ys = calloc(size, sizeof(unsigned int));
	nets[i].zs = calloc(size, sizeof(unsigned int));

	/* fill in net struct from lua */
        for(size_t j = 1; j <= size; ++j)
        {
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
		    lua_getfield(L, -1, "port");
		    const char *port = lua_tostring(L, -1);
		    nets[i].firstport = malloc(strlen(port) + 1);
		    strcpy(nets[i].firstport, port);
		    lua_pop(L, 1);

		    lua_getfield(L, -1, "instance");
		    const char *instance = lua_tostring(L, -1);
		    nets[i].firstinstance = malloc(strlen(instance) + 1);
		    strcpy(nets[i].firstinstance, instance);
		    lua_pop(L, 1);
	    }

	    nets[i].xs[j - 1] = x - 1;
	    nets[i].ys[j - 1] = y - 1;
	    nets[i].zs[j - 1] = z;

	    nets[i].name = malloc(strlen(name) + 1);
	    strcpy(nets[i].name, name);

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

/* deletes the nth element of an array and resizes it */
static void del_nth_el_arr(unsigned int *arr, size_t n, size_t arr_size)
{
    if(arr == NULL || n >= arr_size)
        return;

    for(size_t i = n; i < arr_size - 1; i++)
    {
        arr[i] = arr[i+1];
    }

    arr = (unsigned int *)realloc(arr, arr_size - 1);
}

/*
 * split nets with more than 2 points into more nets with 2 points
 * with minimum manhattan distance in between
 * e. g. net0: p1 has manhattan distance (m.d.) 4 to p2 and p1 has 3 m.d. to
 * p3 then: make new nets with p1 and p3, and p2 and p3
*/
static void lrouter_split_nets(struct netcollection* nc)
{
    for(size_t i = 0; i < nc->num_nets; i++)
    {
	if(nc->nets[i].size < 3)
	    continue;

	for(size_t j = 0; j < nc->nets[i].size; j++)
	{
		int tempx, tempy, nextx, nexty, mindist, nextdist;
		size_t mink = 0;
		tempx = (int)nc->nets[i].xs[j];
		tempy = (int)nc->nets[i].ys[j];
		mindist = INT_MAX;
		for(size_t k = 0; k < nc->nets[i].size; k++)
		{
			/* dont check m.d. for itself again */
		        if(k == j)
			    continue;

			nextx = (int)nc->nets[i].xs[k];
			nexty = (int)nc->nets[i].ys[k];
			if((nextdist = MANHATTAN_DIST(tempx, tempy, nextx, nexty)) <
			   mindist)
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
		net_t newnet;
		newnet.name = malloc(strlen(nc->nets[i].name) + 10);
		newnet.xs = malloc(sizeof(unsigned int) * 2);
		newnet.ys = malloc(sizeof(unsigned int) * 2);
		newnet.zs = malloc(sizeof(unsigned int) * 2);
		sprintf(newnet.name, "%s_(%zu)", nc->nets[i].name, j);
		newnet.xs[0] = nc->nets[i].xs[j];
		newnet.ys[0] = nc->nets[i].ys[j];
		newnet.xs[1] = nc->nets[i].xs[mink];
		newnet.ys[1] = nc->nets[i].ys[mink];
		newnet.size = 2;
		printf("%s, mindist: %u\n", newnet.name, mindist);
		del_nth_el_arr(nc->nets[i].xs, j, nc->nets[i].size);
		del_nth_el_arr(nc->nets[i].ys, j, nc->nets[i].size);

		/* add new net to end of net list */
		nc->nets = (net_t *)realloc(nc->nets, nc->num_nets + 1);
		nc->nets[nc->num_nets] = newnet;
		nc->num_nets++;
	}
    }
}

int lrouter_route(lua_State* L)
{
    printf("calling route\n");
    struct netcollection* nc = _initialize(L);

    sort_nets(nc->nets, nc->num_nets);

    const size_t field_height = lua_tointeger(L, 4);
    const size_t field_width = lua_tointeger(L, 3);
    printf("w: %zu, h: %zu\n", field_width, field_height);
    const size_t num_layers = 3;
    const unsigned int via_cost = 10;
    const unsigned int wrong_dir_cost = 30;
    int*** field = init_field(field_width, field_height, num_layers);

    lua_newtable(L);

    lrouter_split_nets(nc);
    print_nets(nc->nets, nc->num_nets);

    int count = 0;
    for(unsigned int i = 0; i < nc->num_nets; ++i)
    {

	    /* dont route nets without at least 2 points */
	    if(nc->nets[i].size <= 1)
	    {
		    continue;
	    }

	nc->nets[i].routed = route(&nc->nets[i], field, field_width,
				   field_height, num_layers, via_cost,
				   wrong_dir_cost);

	if(nc->nets[i].routed)
	{
		lua_newtable(L);
		lua_pushstring(L, nc->nets[i].name);
		lua_rawseti(L, -2, 1);

		lua_pushstring(L, "firstport");
		lua_pushstring(L, nc->nets[i].firstport);
		lua_rawset(L, -3);

		lua_pushstring(L, "firstinstance");
		lua_pushstring(L, nc->nets[i].firstinstance);
		lua_rawset(L, -3);

		point_t *curr_point;
		int point_count = 0;
		while((curr_point = (point_t *)queue_dequeue(nc->nets[i].path)) 
		      != NULL)
		{
			lua_newtable(L);
			lua_pushinteger(L, curr_point->x);
			lua_rawseti(L, -2, 1);
			lua_pushinteger(L, curr_point->y);
			lua_rawseti(L, -2, 2);
			lua_pushinteger(L, curr_point->z);
			lua_rawseti(L, -2, 3);

			lua_rawseti(L, -2, point_count + 2);
			point_count++;
		}
		lua_rawseti(L, -2, count + 1);
		count++;
	}
    }

    /* num_routed_nets on stack */
    lua_pushinteger(L, count);
    ldebug_dump_stack(L);

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

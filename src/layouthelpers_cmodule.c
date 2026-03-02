#include "layouthelpers_cmodule.h"

#include <string.h>

#include "lua/lauxlib.h"

#include "bltrshape.h"
#include "geometry.h"
#include "lobject.h"
#include "lplacement.h"
#include "lutil.h"
#include "vector.h"

static struct vector* _get_netshapes(lua_State* L, int index)
{
    size_t len = lutil_len(L, index);
    struct vector* netshapes = vector_create(len, bltrshape_destroy);
    for(size_t i = 1; i <= len; ++i)
    {
        lua_rawgeti(L, index, i);
        struct bltrshape* bltrshape = bltrshape_create_from_table(L, -1);
        lua_pop(L, 1);
        vector_append(netshapes, bltrshape);
    }
    return netshapes;
}

static int _compare_nets(const void* net1v, const void* net2v)
{
    return strcmp(net1v, net2v) == 0;
}

// function M.place_vias(cell, netshapes1, netshapes2, excludes, netfilter, onlyfull, nocheck)
int llayouthelpers_place_vias(lua_State* L)
{
    // get techstate
    lua_getfield(L, LUA_REGISTRYINDEX, "techstate");
    struct technology_state* techstate = lua_touserdata(L, -1);
    lua_pop(L, 1); // pop techstate
    // get parameters
    struct lobject* lobject = lobject_check(L, 1);
    struct object* cell = lobject_get_full(L, lobject);
    struct vector* netshapes1 = _get_netshapes(L, 2);
    struct vector* netshapes2 = _get_netshapes(L, 3);
    struct polygon_container* excludes;
    lplacement_create_exclude_vectors(L, &excludes, 4);
    struct vector* netfilter = lutil_get_string_table(L, 5);
    int onlyfull = lua_toboolean(L, 6);
    int nocheck = lua_toboolean(L, 7);
    for(size_t i1 = 0; i1 < vector_size(netshapes1); ++i1)
    {
        struct bltrshape* netshape1 = vector_get(netshapes1, i1);
        int connect = 1;
        if(netfilter)
        {
            if(vector_find_comp(netfilter, _compare_nets, bltrshape_get_net(netshape1)) != -1)
            {
                connect = 0;
            }
        }
        if(connect)
        {
            for(size_t i2 = 0; i2 < vector_size(netshapes2); ++i2)
            {
                struct bltrshape* netshape2 = vector_get(netshapes2, i2);
                if(bltrshape_equal_nets(netshape1, netshape2))
                {
                    struct bltrshape* r = bltrshape_intersection(netshape1, netshape2, onlyfull);
                    if(r)
                    {
                        const struct point* bl = bltrshape_get_bl_const(r);
                        const struct point* tr = bltrshape_get_tr_const(r);
                        int metal1 = technology_metal_layer_to_index(techstate, bltrshape_get_layer(netshape1));
                        int metal2 = technology_metal_layer_to_index(techstate, bltrshape_get_layer(netshape2));
                        int xcont = 0;
                        int ycont = 0;
                        int equal_pitch = 0;
                        coordinate_t widthclass = 0;
                        int create = nocheck || geometry_check_viabltr(techstate, metal1, metal2, bl, tr, xcont, ycont, equal_pitch, widthclass);
                        if(excludes)
                        {
                            create = create && !polygon_container_intersects_rectangle(
                                excludes,
                                point_getx(bl),
                                point_gety(bl),
                                point_getx(tr),
                                point_gety(tr)
                            );
                        }
                        if(create)
                        {
                            coordinate_t minspace = 0;
                            geometry_viabltr(cell, techstate, metal1, metal2, bl, tr, minspace, minspace, xcont, ycont, equal_pitch, widthclass);
                        }
                    }
                }
            }
        }
    }
    return 0;
}

int open_llayouthelpers_cmodule_lib(lua_State* L)
{
    lua_newtable(L);
    static const luaL_Reg modfuncs[] =
    {
        { "place_vias",     llayouthelpers_place_vias   },
        { NULL,             NULL                        }
    };
    luaL_setfuncs(L, modfuncs, 0);

    lua_setglobal(L, "layouthelpers");
    return 0;
}

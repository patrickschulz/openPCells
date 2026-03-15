#include "layouthelpers_cmodule.h"

#include <string.h> // strcmp

#include "lua/lauxlib.h"

#include "bltrshape.h"
#include "geometry.h"
#include "helpers.h"
#include "lgenerics.h"
#include "lobject.h"
#include "lplacement.h"
#include "lpoint.h"
#include "lutil.h"
#include "polygon.h"
#include "vector.h"

int _cmp_break(const void* vlhs, const void* vrhs)
{
    const coordinate_t* lhs = *((const coordinate_t**) vlhs);
    const coordinate_t* rhs = *((const coordinate_t**) vrhs);
    return lhs[0] > rhs[0];
}

static struct vector* _calculate_line_breaks(
    coordinate_t xy,
    coordinate_t size,
    coordinate_t cstart, coordinate_t cstop,
    struct vector* blockages
)
{
    struct vector* pts = vector_create(128, point_destroy_coordinate_array);
    // collect all breaks
    struct vector* breaks = vector_create(128, point_destroy_coordinate_array);
    for(size_t i = 0; i < vector_size(blockages); ++i)
    {
        coordinate_t* blockage = vector_get(blockages, i);
        coordinate_t c1     = blockage[0];
        coordinate_t c2     = blockage[1];
        coordinate_t start  = blockage[2];
        coordinate_t stop   = blockage[3];
        if((xy + size > c1) && (xy < c2))
        {
            coordinate_t* b = point_create_coordinate_array(2);
            b[0] = start;
            b[1] = stop;
            vector_append(breaks, b);
        }
    }
    // process overlaps and insert line points
    vector_sort(breaks, _cmp_break);
    size_t i = 0;
    coordinate_t lastc = cstart;
    while(i < vector_size(breaks))
    {
        coordinate_t* breaki = vector_get(breaks, i);
        coordinate_t start = breaki[0];
        coordinate_t stop = breaki[1];
        for(size_t j = i + 1; j < vector_size(breaks); ++j)
        {
            coordinate_t* breakj = vector_get(breaks, j);
            if(breakj[0] < stop)
            {
                if(breakj[1] > stop)
                {
                    stop = breakj[1];
                }
                ++i;
            }
            else
            {
                break;
            }
        }
        ++i;
        coordinate_t* b = point_create_coordinate_array(2);
        b[0] = lastc;
        b[1] = start;
        vector_append(pts, b);
        lastc = stop;
    }
    // add last point, also solves the case when there are no blockages
    coordinate_t* b = point_create_coordinate_array(2);
    b[0] = lastc;
    b[1] = cstop;
    vector_append(pts, b);
    return pts;
}

struct vector* layouthelpers_place_vlines(
    struct object* cell,
    const struct point* bl, const struct point* tr,
    const struct generics* layer,
    coordinate_t width, coordinate_t space, coordinate_t minheight,
    struct vector* netnames,
    struct polygon_container* excludes
)
{
    struct vector* netshapes = vector_create(8, bltrshape_destroy);
    // FIXME: adapt for polygon boundary
    coordinate_t start = point_getx(bl);
    coordinate_t stop = point_getx(tr);
    coordinate_t ymin = point_gety(bl);
    coordinate_t ymax = point_gety(tr);
    coordinate_t totalwidth = stop - start;
    coordinate_t offset = (totalwidth - totalwidth / (width + space) * (width + space) + space) / 2;
    size_t netcounter = 1;
    // find line blockages
    struct vector* blockages = vector_create(128, point_destroy_coordinate_array);
    if(excludes)
    {
        struct polygon_container_iterator* it = polygon_container_iterator_create(excludes);
        while(polygon_container_iterator_is_valid(it))
        {
            struct simple_polygon* exclude = polygon_container_iterator_get(it);
            if(simple_polygon_is_rectilinear(exclude))
            {
                struct vector* excluderects = simple_polygon_split_rectilinear_polygon(exclude);
                for(size_t i = 0; i < vector_size(excluderects); ++i)
                {
                    struct bltrshape* rect = vector_get(excluderects, i);
                    coordinate_t* b = point_create_coordinate_array(4);
                    // order: c1, c2, start, stop
                    b[0] = MIN2(point_getx(bltrshape_get_bl(rect)), point_getx(bltrshape_get_tr(rect)));
                    b[1] = MAX2(point_getx(bltrshape_get_bl(rect)), point_getx(bltrshape_get_tr(rect)));
                    b[2] = MIN2(point_gety(bltrshape_get_bl(rect)), point_gety(bltrshape_get_tr(rect)));
                    b[3] = MAX2(point_gety(bltrshape_get_bl(rect)), point_gety(bltrshape_get_tr(rect)));
                    vector_append(blockages, b);
                }
            }
            else
            {
                coordinate_t* b = point_create_coordinate_array(4);
                // order: c1, c2, start, stop
                b[0] = simple_polygon_get_minx(exclude);
                b[1] = simple_polygon_get_maxx(exclude);
                b[2] = simple_polygon_get_miny(exclude);
                b[3] = simple_polygon_get_maxy(exclude);
                vector_append(blockages, b);
            }
            polygon_container_iterator_next(it);
        }
        polygon_container_iterator_destroy(it);
    }
    coordinate_t x = start + offset;
    while(x < stop)
    {
        struct vector* ypts = _calculate_line_breaks(x, width, ymin, ymax, blockages);
        for(size_t i = 0; i < vector_size(ypts); ++i)
        {
            coordinate_t* pt = vector_get(ypts, i);
            // clip to boundary
            pt[0] = MAX2(pt[0], ymin);
            pt[1] = MIN2(pt[1], ymax);
            // check for illegal (out-of-range) points
            if(
                (pt[0] < pt[1]) &&
                ((pt[1] - pt[0]) > minheight)
            )
            {
                coordinate_t blx = x;
                coordinate_t bly = pt[0];
                coordinate_t trx = x + width;
                coordinate_t try = pt[1];
                geometry_rectanglebltrxy(cell, layer, blx, bly, trx, try);
                if(netnames)
                {
                    size_t numnets = vector_size(netnames);
                    const char* netname = vector_get(netnames, netcounter % numnets);
                    vector_append(netshapes, bltrshape_create_xy(blx, bly, trx, try, layer, netname));
                }
            }
        }
        x = x + width + space;
        ++netcounter;
    }
    return netshapes;
}

struct vector* layouthelpers_place_hlines(
    struct object* cell,
    const struct point* bl, const struct point* tr,
    const struct generics* layer,
    coordinate_t height, coordinate_t space, coordinate_t minwidth,
    struct vector* netnames,
    struct polygon_container* excludes
)
{
    struct vector* netshapes = vector_create(8, bltrshape_destroy);
    coordinate_t stop = point_gety(tr);
    coordinate_t totalheight = point_ydistance_abs(tr, bl);
    coordinate_t offset = (totalheight - totalheight / (height + space) * (height + space) + space) / 2;
    size_t netcounter = 1;
    // find line blockages
    struct vector* blockages = vector_create(128, point_destroy_coordinate_array);
    if(excludes)
    {
        struct polygon_container_iterator* it = polygon_container_iterator_create(excludes);
        while(polygon_container_iterator_is_valid(it))
        {
            struct simple_polygon* exclude = polygon_container_iterator_get(it);
            if(simple_polygon_is_rectilinear(exclude))
            {
                struct vector* excluderects = simple_polygon_split_rectilinear_polygon(exclude);
                for(size_t i = 0; i < vector_size(excluderects); ++i)
                {
                    struct bltrshape* rect = vector_get(excluderects, i);
                    coordinate_t* b = point_create_coordinate_array(4);
                    // order: c1, c2, start, stop
                    b[0] = MIN2(point_gety(bltrshape_get_bl(rect)), point_gety(bltrshape_get_tr(rect)));
                    b[1] = MAX2(point_gety(bltrshape_get_bl(rect)), point_gety(bltrshape_get_tr(rect)));
                    b[2] = MIN2(point_getx(bltrshape_get_bl(rect)), point_getx(bltrshape_get_tr(rect)));
                    b[3] = MAX2(point_getx(bltrshape_get_bl(rect)), point_getx(bltrshape_get_tr(rect)));
                    vector_append(blockages, b);
                }
            }
            else
            {
                coordinate_t* b = point_create_coordinate_array(4);
                // order: c1, c2, start, stop
                b[0] = simple_polygon_get_miny(exclude);
                b[1] = simple_polygon_get_maxy(exclude);
                b[2] = simple_polygon_get_minx(exclude);
                b[3] = simple_polygon_get_maxx(exclude);
                vector_append(blockages, b);
            }
            polygon_container_iterator_next(it);
        }
        polygon_container_iterator_destroy(it);
    }
    coordinate_t y = point_gety(bl) + offset;
    while(y < stop)
    {
        struct vector* xpts = _calculate_line_breaks(y, height, point_getx(bl), point_getx(tr), blockages);
        for(size_t i = 0; i < vector_size(xpts); ++i)
        {
            coordinate_t* pt = vector_get(xpts, i);
            // clip to boundary
            pt[0] = MAX2(pt[0], point_getx(bl));
            pt[1] = MIN2(pt[1], point_getx(tr));
            // check for illegal (out-of-range) points
            if(
                (pt[0] < pt[1]) &&
                ((pt[1] - pt[0]) > minwidth)
            )
            {
                coordinate_t blx = pt[0];
                coordinate_t bly = y;
                coordinate_t trx = pt[1];
                coordinate_t try = y + height;
                geometry_rectanglebltrxy(cell, layer, blx, bly, trx, try);
                if(netnames)
                {
                    size_t numnets = vector_size(netnames);
                    const char* netname = vector_get(netnames, netcounter % numnets);
                    vector_append(netshapes, bltrshape_create_xy(blx, bly, trx, try, layer, netname));
                }
            }
        }
        y = y + height + space;
        ++netcounter;
    }
    return netshapes;
}

static void _push_netshapes(lua_State* L, const struct vector* netshapes)
{
    lua_newtable(L);
    for(size_t i = 0; i < vector_size(netshapes); ++i)
    {
        bltrshape_push_table(L, vector_get_const(netshapes, i));
        lua_rawseti(L, -2, i + 1);
    }
}

int llayouthelpers_place_hlines(lua_State* L)
{
    // get parameters
    struct lobject* lobject = lobject_check(L, 1);
    struct object* cell = lobject_get_full(L, lobject);
    struct lpoint* lbl = lpoint_checkpoint(L, 2);
    struct lpoint* ltr = lpoint_checkpoint(L, 3);
    const struct point* bl = lpoint_get(lbl);
    const struct point* tr = lpoint_get(ltr);
    const struct generics* layer = generics_check_generics(L, 4);
    coordinate_t height = lpoint_checkcoordinate(L, 5, "height");
    coordinate_t space = lpoint_checkcoordinate(L, 6, "space");
    coordinate_t minwidth = lpoint_checkcoordinate(L, 7, "minwidth");
    struct vector* netnames = lutil_get_string_table(L, 8);
    struct polygon_container* excludes;
    lplacement_create_exclude_vectors(L, &excludes, 9);
    struct vector* netshapes = layouthelpers_place_hlines(
        cell,
        bl, tr,
        layer,
        height, space, minwidth,
        netnames, excludes
    );
    _push_netshapes(L, netshapes);
    return 1;
}

int llayouthelpers_place_vlines(lua_State* L)
{
    // get parameters
    struct lobject* lobject = lobject_check(L, 1);
    struct object* cell = lobject_get_full(L, lobject);
    struct lpoint* lbl = lpoint_checkpoint(L, 2);
    struct lpoint* ltr = lpoint_checkpoint(L, 3);
    const struct point* bl = lpoint_get(lbl);
    const struct point* tr = lpoint_get(ltr);
    const struct generics* layer = generics_check_generics(L, 4);
    coordinate_t width = lpoint_checkcoordinate(L, 5, "width");
    coordinate_t space = lpoint_checkcoordinate(L, 6, "space");
    coordinate_t minheight = lpoint_checkcoordinate(L, 7, "minheight");
    struct vector* netnames = lutil_get_string_table(L, 8);
    struct polygon_container* excludes;
    lplacement_create_exclude_vectors(L, &excludes, 9);
    struct vector* netshapes = layouthelpers_place_vlines(
        cell,
        bl, tr,
        layer,
        width, space, minheight,
        netnames, excludes
    );
    _push_netshapes(L, netshapes);
    return 1;
}

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

void layouthelpers_place_vias(
    struct technology_state* techstate,
    struct object* cell,
    struct vector* netshapes1,
    struct vector* netshapes2,
    struct polygon_container* excludes,
    struct vector* netfilter,
    int onlyfull,
    int nocheck
)
{
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
}

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
    layouthelpers_place_vias(techstate, cell, netshapes1, netshapes2, excludes, netfilter, onlyfull, nocheck);
    return 0;
}

int open_llayouthelpers_cmodule_lib(lua_State* L)
{
    lua_newtable(L);
    static const luaL_Reg modfuncs[] =
    {
        { "place_hlines",   llayouthelpers_place_hlines },
        { "place_vlines",   llayouthelpers_place_vlines },
        { "place_vias",     llayouthelpers_place_vias   },
        { NULL,             NULL                        }
    };
    luaL_setfuncs(L, modfuncs, 0);

    lua_setglobal(L, "layouthelpers");
    return 0;
}

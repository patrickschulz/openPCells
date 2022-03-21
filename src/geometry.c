#include "geometry.h"

#include <stdlib.h>
#include <stddef.h>
#include <math.h>
#include <stdio.h>

#include "technology.h"

static void _multiple_xy(object_t* cell, shape_t* base, ucoordinate_t xrep, ucoordinate_t yrep, ucoordinate_t xpitch, ucoordinate_t ypitch)
{
    if(!shape_is_empty(base))
    {
        for(unsigned int x = 1; x <= xrep; ++x)
        {
            for(unsigned int y = 1; y <= yrep; ++y)
            {
                shape_t* S = shape_copy(base);
                shape_translate(
                    S, 
                    (x - 1) * xpitch - (xrep - 1) * xpitch / 2,
                    (y - 1) * ypitch - (yrep - 1) * ypitch / 2
                );
                object_add_shape(cell, S);
            }
        }
    }
    shape_destroy(base);
}

static void _rectanglebltr (object_t* cell, generics_t* layer, coordinate_t blx, coordinate_t bly, coordinate_t trx, coordinate_t try, ucoordinate_t xrep, ucoordinate_t yrep, ucoordinate_t xpitch, ucoordinate_t ypitch)
{
    shape_t* S = shape_create_rectangle(blx, bly, trx, try);
    S->layer = layer;
    _multiple_xy(cell, S, xrep, yrep, xpitch, ypitch);
}

void geometry_rectanglebltr(object_t* cell, generics_t* layer, point_t* bl, point_t* tr, ucoordinate_t xrep, ucoordinate_t yrep, ucoordinate_t xpitch, ucoordinate_t ypitch)
{
    _rectanglebltr(cell, layer, bl->x, bl->y, tr->x, tr->y, xrep, yrep, xpitch, ypitch);
}

void geometry_rectangle(object_t* cell, generics_t* layer, coordinate_t width, coordinate_t height, coordinate_t xshift, coordinate_t yshift, ucoordinate_t xrep, ucoordinate_t yrep, ucoordinate_t xpitch, ucoordinate_t ypitch)
{
    _rectanglebltr(cell, layer, -width / 2 + xshift, -height / 2 + yshift, width / 2 + xshift, height / 2 + yshift, xrep, yrep, xpitch, ypitch);
}

void geometry_rectanglepoints(object_t* cell, generics_t* layer, point_t* pt1, point_t* pt2, ucoordinate_t xrep, ucoordinate_t yrep, ucoordinate_t xpitch, ucoordinate_t ypitch)
{
    if(pt1->x <= pt2->x && pt1->y <= pt2->y)
    {
        _rectanglebltr(cell, layer, pt1->x, pt1->y, pt2->x, pt2->y, xrep, yrep, xpitch, ypitch);
    }
    else if(pt1->x <= pt2->x && pt1->y  > pt2->y)
    {
        _rectanglebltr(cell, layer, pt1->x, pt2->y, pt2->x, pt1->y, xrep, yrep, xpitch, ypitch);
    }
    else if(pt1->x  > pt2->x && pt1->y <= pt2->y)
    {
        _rectanglebltr(cell, layer, pt2->x, pt1->y, pt1->x, pt2->y, xrep, yrep, xpitch, ypitch);
    }
    else if(pt1->x  > pt2->x && pt1->y  > pt2->y)
    {
        _rectanglebltr(cell, layer, pt2->x, pt2->y, pt1->x, pt1->y, xrep, yrep, xpitch, ypitch);
    }
}

void geometry_polygon(object_t* cell, generics_t* layer, point_t** points, size_t len)
{
    shape_t* S = shape_create_polygon(len);
    S->layer = layer;
    for(unsigned int i = 0; i < len; ++i)
    {
        shape_append(S, points[i]->x, points[i]->y);
    }
    if(!shape_is_empty(S))
    {
        object_add_shape(cell, S);
    }
    else
    {
        shape_destroy(S);
    }
}

void geometry_path(object_t* cell, generics_t* layer, point_t** points, size_t len, ucoordinate_t width, ucoordinate_t bgnext, ucoordinate_t endext)
{
    shape_t* S = shape_create_path(len, width, bgnext, endext);
    S->layer = layer;
    for(unsigned int i = 0; i < len; ++i)
    {
        shape_append(S, points[i]->x, points[i]->y);
    }
    if(!shape_is_empty(S))
    {
        object_add_shape(cell, S);
    }
    else
    {
        shape_destroy(S);
    }
}

static void _shift_line(point_t* pt1, point_t* pt2, ucoordinate_t width, point_t** spt1, point_t** spt2, unsigned int grid)
{
    double angle = atan2(pt2->y - pt1->y, pt2->x - pt1->x) - M_PI / 2;
    coordinate_t xshift = grid * floor(floor(width * cos(angle) + 0.5) / grid);
    coordinate_t yshift = grid * floor(floor(width * sin(angle) + 0.5) / grid);
    *spt1 = point_create(pt1->x + xshift, pt1->y + yshift);
    *spt2 = point_create(pt2->x + xshift, pt2->y + yshift);
}

static point_t** _get_edge_segments(point_t** points, size_t numpoints, ucoordinate_t width, unsigned int grid)
{
    point_t** edges = calloc(4 * (numpoints - 1), sizeof(*edges));
    // start to end
    for(unsigned int i = 0; i < numpoints - 1; ++i)
    {
        _shift_line(points[i], points[i + 1], width / 2, &edges[2 * i], &edges[2 * i + 1], grid);
    }
    // end to start (shift in other direction)
    for(unsigned int i = numpoints - 1; i > 0; --i)
    {
        // the indexing looks funny, but it works out, trust me
        _shift_line(points[i], points[i - 1], width / 2, 
            &edges[2 * (2 * numpoints - 2 - i)], 
            &edges[2 * (2 * numpoints - 2 - i) + 1],
            grid
        );
    }
    return edges;
}

static int _intersection(point_t* s1, point_t* s2, point_t* c1, point_t* c2, point_t** pt)
{
    coordinate_t snum = (c2->x - c1->x) * (s1->y - c1->y) - (s1->x - c1->x) * (c2->y - c1->y);
    coordinate_t cnum = (s2->x - s1->x) * (s1->y - c1->y) - (s1->x - c1->x) * (s2->y - s1->y);
    coordinate_t den = (s2->x - s1->x) * (c2->y - c1->y) - (c2->x - c1->x) * (s2->y - s1->y);
    if(den == 0) // lines are parallel
    {
        return 0;
    }

    // you can use cnum with c-edge or snum with s-edge
    *pt = point_create(s1->x + snum * (s2->x - s1->x) / den, s1->y + snum * (s2->y - s1->y) / den);
    //*pt = point_create(c1->x + cnum * (c2->x - c1->x) / den, c1->y + cnum * (c2->y - c1->y) / den);
    // the comparison is so complex/weird to avoid division
    if((snum == 0 || (snum < 0 && den < 0 && snum >= den) || (snum > 0 && den > 0 && snum <= den)) &&
       (cnum == 0 || (cnum < 0 && den < 0 && cnum >= den) || (cnum > 0 && den > 0 && cnum <= den)))
    {
        return 1;
    }
    else // the line segments don't overlap, but the imaginary extended lines do (important for bevel join)
    {
        return 0;
    }
}

/*
* calculate the outline points of a path with a width
* this works as follows:
* shift the middle path to the left and to the right
* if adjacent lines intersect, that point is part of the outline
* if adjacent lines don't intersect, either:
*      * insert both endpoints (well, the endpoint of the first segment and the startpoint of the second segment).
*        This is a bevel join
*      * insert the point where the extended line segments meet
*        This is a miter join
* the endpoints of the path need extra care
*/
static shape_t* _get_path_pts(point_t** edges, size_t numedges, int miterjoin)
{
    shape_t* poly = shape_create_polygon(2 * numedges); // 2 * numedges: wild guess
    // first start point
    shape_append(poly, edges[0]->x, edges[0]->y);
    // first middle points
    size_t segs = numedges / 4;
    for(unsigned int seg = 0; seg < segs - 1; ++seg)
    {
        unsigned int i = 2 * seg + 1;
        point_t* pt = NULL;
        int inner_outer = _intersection(edges[i - 1], edges[i], edges[i + 1], edges[i + 2], &pt);
        if(pt)
        {
            if(inner_outer || miterjoin)
            {
                shape_append(poly, pt->x, pt->y);
            }
            else
            {
                shape_append(poly, edges[i]->x, edges[i]->y);
                shape_append(poly, edges[i + 1]->x, edges[i + 1]->y);
            }
            free(pt);
        }
    }
    // end points
    shape_append(poly, edges[2 * segs - 1]->x, edges[2 * segs - 1]->y);
    shape_append(poly, edges[2 * segs]->x, edges[2 * segs]->y);
    // second middle points
    for(unsigned int seg = 0; seg < segs - 1; ++seg)
    {
        unsigned int i = 2 * (segs + seg) + 1;
        point_t* pt = NULL;
        int inner_outer = _intersection(edges[i - 1], edges[i], edges[i + 1], edges[i + 2], &pt);
        if(pt)
        {
            if(inner_outer || miterjoin)
            {
                shape_append(poly, pt->x, pt->y);
            }
            else
            {
                shape_append(poly, edges[i]->x, edges[i]->y);
                shape_append(poly, edges[i + 1]->x, edges[i + 1]->y);
            }
            free(pt);
        }
    }
    // second start point
    shape_append(poly, edges[numedges - 1]->x, edges[numedges - 1]->y);
    return poly;
}

void _make_unique_points(point_t** points, size_t* numpoints)
{
    for(unsigned int i = *numpoints - 1; i > 0; --i)
    {
        if((points[i]->x == points[i - 1]->x) && (points[i]->y == points[i - 1]->y))
        {
            point_destroy(points[i]);
            for(unsigned int j = 0; j < *numpoints - i - 1; ++j)
            {
                points[i + j] = points[i + j + 1];
            }
            --(*numpoints);
        }
    }
}

shape_t* geometry_path_to_polygon(point_t** points, size_t numpoints, ucoordinate_t width, int miterjoin)
{
    _make_unique_points(points, &numpoints);
    
    // FIXME: handle path extensions

    // rectangle
    if((numpoints == 2) && ((points[0]->x == points[1]->x) || (points[0]->y == points[1]->y)))
    {
        if    ((points[0]->x  < points[1]->x) && (points[0]->y == points[1]->y))
        {
            return shape_create_rectangle(points[0]->x, points[0]->y - width / 2, points[1]->x, points[0]->y + width / 2);
        }
        else if((points[0]->x  > points[1]->x) && (points[0]->y == points[1]->y))
        {
            return shape_create_rectangle(points[1]->x, points[0]->y - width / 2, points[0]->x, points[0]->y + width / 2);
        }
        else if((points[0]->x == points[1]->x) && (points[0]->y  > points[1]->y))
        {
            return shape_create_rectangle(points[0]->x - width / 2, points[1]->y, points[0]->x + width / 2, points[0]->y);
        }
        else if((points[0]->x == points[1]->x) && (points[0]->y  < points[1]->y))
        {
            return shape_create_rectangle(points[0]->x - width / 2, points[0]->y, points[0]->x + width / 2, points[1]->y);
        }
    }
    // polygon
    point_t** edges = _get_edge_segments(points, numpoints, width, 1);
    shape_t* poly = _get_path_pts(edges, 4 * (numpoints - 1), miterjoin);
    for(unsigned int i = 0; i < 4 * (numpoints - 1); ++i)
    {
        point_destroy(edges[i]);
    }
    free(edges);
    return poly;
}

point_t** _get_any_angle_path_pts(point_t** pts, size_t len, ucoordinate_t width, ucoordinate_t grid, int miterjoin, int allow45, size_t* numpoints)
{
    point_t** edges = _get_edge_segments(pts, len, width, grid);
    shape_t* poly = _get_path_pts(edges, 4 * (len - 1), miterjoin);
    for(unsigned int i = 0; i < 4 * (len - 1); ++i)
    {
        point_destroy(edges[i]);
    }
    free(edges);
//    table.insert(pathpts, edges[1]:copy()) -- close path
//    local poly = {}
//    for i = 1, #pathpts - 1 do
//        local linepts = graphics.line(pathpts[i], pathpts[i + 1], grid, allow45)
//        for _, pt in ipairs(linepts) do
//            table.insert(poly, pt)
//        end
//    end
//    return poly
    return poly;
}

void geometry_any_angle_path(object_t* cell, generics_t* layer, point_t** pts, size_t len, ucoordinate_t width, ucoordinate_t grid, int miterjoin, int allow45)
{
    _make_unique_points(pts, &len);
    size_t numpoints;
    point_t** points = _get_any_angle_path_pts(pts, len, width, grid, miterjoin, allow45, &numpoints);
    geometry_polygon(cell, layer, points, numpoints);
}

static void _fit_via(ucoordinate_t size, unsigned int cutsize, unsigned int space, int encl, unsigned int* rep_result, unsigned int* space_result)
{
    *rep_result = (size + space - 2 * encl) / (cutsize + space);
    *space_result = space;
}

/*
static void _continuous_via(ucoordinate_t size, unsigned int cutsize, unsigned int space, int encl, unsigned int* rep_result, unsigned int* space_result)
{
    (void)encl; // FIXME
    int Nres = 0;
    for(unsigned int N = 1; N < UINT_MAX; ++N)
    {
        if(size % N == 0)
        {
            int S = size / N - cutsize;
            if(S < (int)space)
            {
                break;
            }
            if(S % 2 == 0)
            {
                Nres = N;
            }
        }
    }
    *rep_result = Nres;
    *space_result = size / Nres - cutsize;
}
*/

static struct via_definition* _get_rectangular_arrayzation(ucoordinate_t regionwidth, ucoordinate_t regionheight, struct via_definition** definitions, unsigned int* xrep_ptr, unsigned int* yrep_ptr, unsigned int* xpitch_ptr, unsigned int* ypitch_ptr)
{
    //local xstrat = arrayzation_strategies[options.xcontinuous and "continuous" or "fit"]
    //local ystrat = arrayzation_strategies[options.ycontinuous and "continuous" or "fit"]

    //local idx
    unsigned int lastarea = 0;
    unsigned int xrep = 0;
    unsigned int xspace = 0;
    unsigned int yrep = 0;
    unsigned int yspace = 0;
    struct via_definition* result = NULL;
    struct via_definition** viadef = definitions;
    while(*viadef)
    {
        struct via_definition* entry = *viadef;
        unsigned int _xrep = 0;
        unsigned int _xspace = 0;
        unsigned int _yrep = 0;
        unsigned int _yspace = 0;
        _fit_via(regionwidth, entry->width, entry->xspace, entry->xenclosure, &_xrep, &_xspace);
        _fit_via(regionheight, entry->width, entry->yspace, entry->yenclosure, &_yrep, &_yspace);
        if(_xrep > 0 && _yrep > 0)
        {
            unsigned int area = (_xrep + _yrep) * entry->width * entry->height;
            if(!result || area > lastarea)
            {
                result = entry;
                lastarea = area;
                xrep = _xrep;
                yrep = _yrep;
                xspace = _xspace;
                yspace = _yspace;
            }
        }
        ++viadef;
    }
    if(!result)
    {
        puts("could not fit via, a fallback via could be used, but this is not implemented yet");
        return NULL;
    //if not idx then
    //    if definitions.fallback then
    //        return {
    //            width = definitions.fallback.width,
    //            height = definitions.fallback.height,
    //            xpitch = 0,
    //            ypitch = 0,
    //            xrep = 1,
    //            yrep = 1,
    //        }
    //    else
    //        print("could not fit via, the shape will be ignored. The layout will most likely not be correct.")
    //        return nil
    //    end
    //end
    }
    *xpitch_ptr = result->width + xspace;
    *ypitch_ptr = result->height + yspace;
    *xrep_ptr = xrep;
    *yrep_ptr = yrep;
    return result;
}

static void _viabltr(object_t* cell, int metal1, int metal2, coordinate_t blx, coordinate_t bly, coordinate_t trx, coordinate_t try, ucoordinate_t xrep, ucoordinate_t yrep, ucoordinate_t xpitch, ucoordinate_t ypitch)
{
    metal1 = technology_resolve_metal(metal1);
    metal2 = technology_resolve_metal(metal2);
    if(metal1 > metal2)
    {
        int tmp = metal1;
        metal1 = metal2;
        metal2 = tmp;
    }
    ucoordinate_t width = trx - blx;
    ucoordinate_t height = try - bly;
    for(int i = metal1; i < metal2; ++i)
    {
        struct via_definition** viadefs = technology_get_via_definitions(i, i + 1);
        unsigned int viaxrep, viayrep, viaxpitch, viaypitch;
        struct via_definition* entry = _get_rectangular_arrayzation(width, height, viadefs, &viaxrep, &viayrep, &viaxpitch, &viaypitch);
        if(!entry)
        {
            return;
        }
        for(unsigned int x = 1; x <= xrep; ++x)
        {
            for(unsigned int y = 1; y <= yrep; ++y)
            {
                _rectanglebltr(cell, 
                    generics_create_viacut(i, i + 1), 
                    (x - 1) * xpitch - (xrep - 1) * xpitch / 2 + (blx + trx) / 2 - entry->width / 2,
                    (y - 1) * ypitch - (yrep - 1) * ypitch / 2 + (bly + try) / 2 - entry->height / 2,
                    (x - 1) * xpitch - (xrep - 1) * xpitch / 2 + (blx + trx) / 2 + entry->width / 2,
                    (y - 1) * ypitch - (yrep - 1) * ypitch / 2 + (bly + try) / 2 + entry->height / 2,
                    viaxrep, viayrep, viaxpitch, viaypitch
                );
            }
        }
        _rectanglebltr(cell, generics_create_metal(i), blx, bly, trx, try, xrep, yrep, xpitch, ypitch);
        _rectanglebltr(cell, generics_create_metal(i + 1), blx, bly, trx, try, xrep, yrep, xpitch, ypitch);
    }
}

void geometry_viabltr(object_t* cell, int metal1, int metal2, point_t* bl, point_t* tr, ucoordinate_t xrep, ucoordinate_t yrep, ucoordinate_t xpitch, ucoordinate_t ypitch)
{
    _viabltr(cell, metal1, metal2, bl->x, bl->y, tr->x, tr->y, xrep, yrep, xpitch, ypitch);
}

void geometry_via(object_t* cell, int metal1, int metal2, ucoordinate_t width, ucoordinate_t height, coordinate_t xshift, coordinate_t yshift, ucoordinate_t xrep, ucoordinate_t yrep, ucoordinate_t xpitch, ucoordinate_t ypitch)
{
    _viabltr(cell, metal1, metal2, -(coordinate_t)width / 2 + xshift, -(coordinate_t)height / 2 + yshift, width / 2 + xshift, height / 2 + yshift, xrep, yrep, xpitch, ypitch);
}

static void _contactbltr(object_t* cell, const char* region, coordinate_t blx, coordinate_t bly, coordinate_t trx, coordinate_t try, ucoordinate_t xrep, ucoordinate_t yrep, ucoordinate_t xpitch, ucoordinate_t ypitch)
{
    ucoordinate_t width = trx - blx;
    ucoordinate_t height = try - bly;
    struct via_definition** viadefs = technology_get_contact_definitions(region);
    unsigned int viaxrep, viayrep, viaxpitch, viaypitch;
    struct via_definition* entry = _get_rectangular_arrayzation(width, height, viadefs, &viaxrep, &viayrep, &viaxpitch, &viaypitch);
    if(!entry)
    {
        return;
    }
    for(unsigned int x = 1; x <= xrep; ++x)
    {
        for(unsigned int y = 1; y <= yrep; ++y)
        {
            _rectanglebltr(cell, 
                generics_create_contact(region),
                (x - 1) * xpitch - (xrep - 1) * xpitch / 2 + (blx + trx) / 2 - entry->width / 2,
                (y - 1) * ypitch - (yrep - 1) * ypitch / 2 + (bly + try) / 2 - entry->height / 2,
                (x - 1) * xpitch - (xrep - 1) * xpitch / 2 + (blx + trx) / 2 + entry->width / 2,
                (y - 1) * ypitch - (yrep - 1) * ypitch / 2 + (bly + try) / 2 + entry->height / 2,
                viaxrep, viayrep, viaxpitch, viaypitch
            );
        }
    }
    _rectanglebltr(cell, generics_create_metal(1), blx, bly, trx, try, xrep, yrep, xpitch, ypitch);
}

void geometry_contactbltr(object_t* cell, const char* region, point_t* bl, point_t* tr, ucoordinate_t xrep, ucoordinate_t yrep, ucoordinate_t xpitch, ucoordinate_t ypitch)
{
    _contactbltr(cell, region, bl->x, bl->y, tr->x, tr->y, xrep, yrep, xpitch, ypitch);
}

void geometry_contact(object_t* cell, const char* region, ucoordinate_t width, ucoordinate_t height, coordinate_t xshift, coordinate_t yshift, ucoordinate_t xrep, ucoordinate_t yrep, ucoordinate_t xpitch, ucoordinate_t ypitch)
{
    _contactbltr(cell, region, -(coordinate_t)width / 2 + xshift, -(coordinate_t)height / 2 + yshift, width / 2 + xshift, height / 2 + yshift, xrep, yrep, xpitch, ypitch);
}

void geometry_cross(object_t* cell, generics_t* layer, ucoordinate_t width, ucoordinate_t height, ucoordinate_t crosssize)
{
    shape_t* S = shape_create_polygon(13);
    S->layer = layer;
    shape_append(S,     -width / 2, -crosssize / 2);
    shape_append(S,     -width / 2,  crosssize / 2);
    shape_append(S, -crosssize / 2,  crosssize / 2);
    shape_append(S, -crosssize / 2,     height / 2);
    shape_append(S,  crosssize / 2,     height / 2);
    shape_append(S,  crosssize / 2,  crosssize / 2);
    shape_append(S,      width / 2,  crosssize / 2);
    shape_append(S,      width / 2, -crosssize / 2);
    shape_append(S,  crosssize / 2, -crosssize / 2);
    shape_append(S,  crosssize / 2,    -height / 2);
    shape_append(S, -crosssize / 2,    -height / 2);
    shape_append(S, -crosssize / 2, -crosssize / 2);
    shape_append(S,     -width / 2, -crosssize / 2); // close polygon
    if(!shape_is_empty(S))
    {
        object_add_shape(cell, S);
    }
    else
    {
        shape_destroy(S);
    }
}

void geometry_ring(object_t* cell, generics_t* layer, ucoordinate_t width, ucoordinate_t height, ucoordinate_t ringwidth)
{
    shape_t* S = shape_create_polygon(13);
    S->layer = layer;
    shape_append(S, -(width + ringwidth) / 2, -(height + ringwidth) / 2);
    shape_append(S,  (width + ringwidth) / 2, -(height + ringwidth) / 2);
    shape_append(S,  (width + ringwidth) / 2,  (height + ringwidth) / 2);
    shape_append(S, -(width + ringwidth) / 2,  (height + ringwidth) / 2);
    shape_append(S, -(width + ringwidth) / 2, -(height - ringwidth) / 2);
    shape_append(S, -(width - ringwidth) / 2, -(height - ringwidth) / 2);
    shape_append(S, -(width - ringwidth) / 2,  (height - ringwidth) / 2);
    shape_append(S,  (width - ringwidth) / 2,  (height - ringwidth) / 2);
    shape_append(S,  (width - ringwidth) / 2, -(height - ringwidth) / 2);
    shape_append(S, -(width + ringwidth) / 2, -(height - ringwidth) / 2);
    shape_append(S, -(width + ringwidth) / 2, -(height + ringwidth) / 2); // close polygon
    if(!shape_is_empty(S))
    {
        object_add_shape(cell, S);
    }
    else
    {
        shape_destroy(S);
    }
}

void geometry_unequal_ring(object_t* cell, generics_t* layer, ucoordinate_t width, ucoordinate_t height, ucoordinate_t ringwidth, ucoordinate_t ringheight)
{
    shape_t* S = shape_create_polygon(13);
    S->layer = layer;
    shape_append(S, -(width + ringwidth) / 2, -(height + ringheight) / 2);
    shape_append(S,  (width + ringwidth) / 2, -(height + ringheight) / 2);
    shape_append(S,  (width + ringwidth) / 2,  (height + ringheight) / 2);
    shape_append(S, -(width + ringwidth) / 2,  (height + ringheight) / 2);
    shape_append(S, -(width + ringwidth) / 2, -(height - ringheight) / 2);
    shape_append(S, -(width - ringwidth) / 2, -(height - ringheight) / 2);
    shape_append(S, -(width - ringwidth) / 2,  (height - ringheight) / 2);
    shape_append(S,  (width - ringwidth) / 2,  (height - ringheight) / 2);
    shape_append(S,  (width - ringwidth) / 2, -(height - ringheight) / 2);
    shape_append(S, -(width + ringwidth) / 2, -(height - ringheight) / 2);
    shape_append(S, -(width + ringwidth) / 2, -(height + ringheight) / 2); // close polygon
    if(!shape_is_empty(S))
    {
        object_add_shape(cell, S);
    }
    else
    {
        shape_destroy(S);
    }
}

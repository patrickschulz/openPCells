#include "geometry.h"

#include <stdlib.h>
#include <stddef.h>
#include <math.h>
#include <stdio.h>

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
}

static void _rectanglebltr(object_t* cell, generics_t* layer, coordinate_t blx, coordinate_t bly, coordinate_t trx, coordinate_t try, ucoordinate_t xrep, ucoordinate_t yrep, ucoordinate_t xpitch, ucoordinate_t ypitch)
{
    shape_t* S = shape_create_rectangle(layer, blx, bly, trx, try);
    _multiple_xy(cell, S, xrep, yrep, xpitch, ypitch);
    shape_destroy(S);
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
    shape_t* S = shape_create_polygon(layer, len);
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
    shape_t* S = shape_create_path(layer, len, width, bgnext, endext);
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

static struct vector* _get_edge_segments(point_t** points, size_t numpoints, ucoordinate_t width, unsigned int grid)
{
    struct vector* edges = vector_create(4 * (numpoints - 1));
    // start to end
    for(unsigned int i = 0; i < numpoints - 1; ++i)
    {
        _shift_line(points[i], points[i + 1], width / 2, vector_get_reference(edges, 2 * i), vector_get_reference(edges, 2 * i + 1), grid);
    }
    // end to start (shift in other direction)
    for(unsigned int i = numpoints - 1; i > 0; --i)
    {
        // the indexing looks funny, but it works out, trust me
        _shift_line(points[i], points[i - 1], width / 2, 
            vector_get_reference(edges, 2 * (2 * numpoints - 2 - i)), 
            vector_get_reference(edges, 2 * (2 * numpoints - 2 - i) + 1),
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
static struct vector* _get_path_pts(struct vector* edges, int miterjoin)
{
    size_t numedges = vector_size(edges);
    struct vector* poly = vector_create(2 * numedges); // wild guess on the number of points
    // first start point
    vector_append(poly, point_copy(vector_get(edges, 0)));
    // first middle points
    size_t segs = numedges / 4;
    for(unsigned int seg = 0; seg < segs - 1; ++seg)
    {
        unsigned int i = 2 * seg + 1;
        point_t* pt = NULL;
        int inner_outer = _intersection(vector_get(edges, i - 1), vector_get(edges, i), vector_get(edges, i + 1), vector_get(edges, i + 2), &pt);
        if(pt)
        {
            if(inner_outer || miterjoin)
            {
                vector_append(poly, point_copy(pt));
            }
            else
            {
                vector_append(poly, point_copy(vector_get(edges, i)));
                vector_append(poly, point_copy(vector_get(edges, i + 1)));
            }
            free(pt);
        }
    }
    // end points
    vector_append(poly, point_copy(vector_get(edges, 2 * segs)));
    vector_append(poly, point_copy(vector_get(edges, 2 * segs)));
    // second middle points
    for(unsigned int seg = 0; seg < segs - 1; ++seg)
    {
        unsigned int i = 2 * (segs + seg) + 1;
        point_t* pt = NULL;
        int inner_outer = _intersection(vector_get(edges, i - 1), vector_get(edges, i), vector_get(edges, i + 1), vector_get(edges, i + 2), &pt);
        if(pt)
        {
            if(inner_outer || miterjoin)
            {
                vector_append(poly, point_copy(pt));
            }
            else
            {
                vector_append(poly, point_copy(vector_get(edges, i)));
                vector_append(poly, point_copy(vector_get(edges, i + 1)));
            }
            free(pt);
        }
    }
    // second start point
    vector_append(poly, point_copy(vector_get(edges, numedges)));
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

shape_t* geometry_path_to_polygon(generics_t* layer, point_t** points, size_t numpoints, ucoordinate_t width, int miterjoin)
{
    _make_unique_points(points, &numpoints);
    
    // FIXME: handle path extensions

    // rectangle
    if((numpoints == 2) && ((points[0]->x == points[1]->x) || (points[0]->y == points[1]->y)))
    {
        if    ((points[0]->x  < points[1]->x) && (points[0]->y == points[1]->y))
        {
            return shape_create_rectangle(layer, points[0]->x, points[0]->y - width / 2, points[1]->x, points[0]->y + width / 2);
        }
        else if((points[0]->x  > points[1]->x) && (points[0]->y == points[1]->y))
        {
            return shape_create_rectangle(layer, points[1]->x, points[0]->y - width / 2, points[0]->x, points[0]->y + width / 2);
        }
        else if((points[0]->x == points[1]->x) && (points[0]->y  > points[1]->y))
        {
            return shape_create_rectangle(layer, points[0]->x - width / 2, points[1]->y, points[0]->x + width / 2, points[0]->y);
        }
        else if((points[0]->x == points[1]->x) && (points[0]->y  < points[1]->y))
        {
            return shape_create_rectangle(layer, points[0]->x - width / 2, points[0]->y, points[0]->x + width / 2, points[1]->y);
        }
    }
    // polygon
    struct vector* edges = _get_edge_segments(points, numpoints, width, 1);
    struct vector* poly = _get_path_pts(edges, miterjoin);
    vector_destroy(edges, point_destroy);
    shape_t* S = shape_create_polygon(layer, vector_size(poly));
    struct vector_iterator* it = vector_iterator_create(poly);
    while(vector_iterator_is_valid(it))
    {
        point_t* pt = vector_iterator_get(it);
        shape_append(S, pt->x, pt->y);
        vector_iterator_next(it);
    }
    vector_iterator_destroy(it);
    return S;
}

point_t** _get_any_angle_path_pts(point_t** pts, size_t len, ucoordinate_t width, ucoordinate_t grid, int miterjoin, int allow45, size_t* numpoints)
{
    struct vector* edges = _get_edge_segments(pts, len, width, grid);
    struct vector* poly = _get_path_pts(edges, miterjoin);
    vector_destroy(edges, point_destroy);
//    table.insert(pathpts, edges[1]:copy()) -- close path
//    local poly = {}
//    for i = 1, #pathpts - 1 do
//        local linepts = graphics.line(pathpts[i], pathpts[i + 1], grid, allow45)
//        for _, pt in ipairs(linepts) do
//            table.insert(poly, pt)
//        end
//    end
//    return poly
    return vector_disown_content(poly);
}

void geometry_any_angle_path(object_t* cell, generics_t* layer, point_t** pts, size_t len, ucoordinate_t width, ucoordinate_t grid, int miterjoin, int allow45)
{
    _make_unique_points(pts, &len);
    size_t numpoints;
    point_t** points = _get_any_angle_path_pts(pts, len, width, grid, miterjoin, allow45, &numpoints);
    geometry_polygon(cell, layer, points, numpoints);
}

typedef void (*via_strategy) (ucoordinate_t size, unsigned int cutsize, unsigned int space, int encl, unsigned int* rep_result, unsigned int* space_result);

static void _fit_via(ucoordinate_t size, unsigned int cutsize, unsigned int space, int encl, unsigned int* rep_result, unsigned int* space_result)
{
    *rep_result = (size + space - 2 * encl) / (cutsize + space);
    *space_result = space;
}

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
    if(Nres)
    {
        *space_result = size / Nres - cutsize;
    }
}

static struct via_definition* _get_rectangular_arrayzation(ucoordinate_t regionwidth, ucoordinate_t regionheight, struct via_definition** definitions, struct via_definition* fallback, unsigned int* xrep_ptr, unsigned int* yrep_ptr, unsigned int* xpitch_ptr, unsigned int* ypitch_ptr, int xcont, int ycont)
{
    via_strategy xstrat = _fit_via;
    via_strategy ystrat = _fit_via;
    if(xcont)
    {
        xstrat = _continuous_via;
    }
    if(ycont)
    {
        ystrat = _continuous_via;
    }

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
        xstrat(regionwidth, entry->width, entry->xspace, entry->xenclosure, &_xrep, &_xspace);
        ystrat(regionheight, entry->width, entry->yspace, entry->yenclosure, &_yrep, &_yspace);
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
        if(fallback)
        {
            *xpitch_ptr = 0;
            *ypitch_ptr = 0;
            *xrep_ptr = 1;
            *yrep_ptr = 1;
            return fallback;
        }
        else
        {
            puts("could not fit via, the shape will be ignored. The layout will most likely not be correct.");
            return NULL;
        }
    }
    *xpitch_ptr = result->width + xspace;
    *ypitch_ptr = result->height + yspace;
    *xrep_ptr = xrep;
    *yrep_ptr = yrep;
    return result;
}

static void _viabltr(object_t* cell, struct layermap* layermap, struct technology_state* techstate, int metal1, int metal2, coordinate_t blx, coordinate_t bly, coordinate_t trx, coordinate_t try, ucoordinate_t xrep, ucoordinate_t yrep, ucoordinate_t xpitch, ucoordinate_t ypitch)
{
    metal1 = technology_resolve_metal(techstate, metal1);
    metal2 = technology_resolve_metal(techstate, metal2);
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
        struct via_definition** viadefs = technology_get_via_definitions(techstate, i, i + 1);
        struct via_definition* fallback = technology_get_via_fallback(techstate, i, i + 1);
        if(!viadefs)
        {
            return;
        }
        unsigned int viaxrep, viayrep, viaxpitch, viaypitch;
        struct via_definition* entry = _get_rectangular_arrayzation(width, height, viadefs, fallback, &viaxrep, &viayrep, &viaxpitch, &viaypitch, 0, 0);
        if(!entry)
        {
            return;
        }
        for(unsigned int x = 1; x <= xrep; ++x)
        {
            for(unsigned int y = 1; y <= yrep; ++y)
            {
                _rectanglebltr(cell, 
                    generics_create_viacut(layermap, techstate, i, i + 1), 
                    (x - 1) * xpitch - (xrep - 1) * xpitch / 2 + (blx + trx) / 2 - entry->width / 2,
                    (y - 1) * ypitch - (yrep - 1) * ypitch / 2 + (bly + try) / 2 - entry->height / 2,
                    (x - 1) * xpitch - (xrep - 1) * xpitch / 2 + (blx + trx) / 2 + entry->width / 2,
                    (y - 1) * ypitch - (yrep - 1) * ypitch / 2 + (bly + try) / 2 + entry->height / 2,
                    viaxrep, viayrep, viaxpitch, viaypitch
                );
            }
        }
        _rectanglebltr(cell, generics_create_metal(layermap, techstate, i), blx, bly, trx, try, xrep, yrep, xpitch, ypitch);
        _rectanglebltr(cell, generics_create_metal(layermap, techstate, i + 1), blx, bly, trx, try, xrep, yrep, xpitch, ypitch);
    }
}

void geometry_viabltr(object_t* cell, struct layermap* layermap, struct technology_state* techstate, int metal1, int metal2, point_t* bl, point_t* tr, ucoordinate_t xrep, ucoordinate_t yrep, ucoordinate_t xpitch, ucoordinate_t ypitch)
{
    _viabltr(cell, layermap, techstate, metal1, metal2, bl->x, bl->y, tr->x, tr->y, xrep, yrep, xpitch, ypitch);
}

void geometry_via(object_t* cell, struct layermap* layermap, struct technology_state* techstate, int metal1, int metal2, ucoordinate_t width, ucoordinate_t height, coordinate_t xshift, coordinate_t yshift, ucoordinate_t xrep, ucoordinate_t yrep, ucoordinate_t xpitch, ucoordinate_t ypitch)
{
    _viabltr(cell, layermap, techstate, metal1, metal2, -(coordinate_t)width / 2 + xshift, -(coordinate_t)height / 2 + yshift, width / 2 + xshift, height / 2 + yshift, xrep, yrep, xpitch, ypitch);
}

static void _contactbltr(
    object_t* cell,
    struct layermap* layermap, struct technology_state* techstate,
    const char* region,
    coordinate_t blx, coordinate_t bly, coordinate_t trx, coordinate_t try,
    ucoordinate_t xrep, ucoordinate_t yrep,
    ucoordinate_t xpitch, ucoordinate_t ypitch,
    int xcont, int ycont
)
{
    ucoordinate_t width = trx - blx;
    ucoordinate_t height = try - bly;
    struct via_definition** viadefs = technology_get_contact_definitions(techstate, region);
    struct via_definition* fallback = technology_get_contact_fallback(techstate, region);
    unsigned int viaxrep, viayrep, viaxpitch, viaypitch;
    struct via_definition* entry = _get_rectangular_arrayzation(
        width, height,
        viadefs, fallback,
        &viaxrep, &viayrep,
        &viaxpitch, &viaypitch,
        xcont, ycont
    );
    if(!entry)
    {
        return;
    }
    for(unsigned int x = 1; x <= xrep; ++x)
    {
        for(unsigned int y = 1; y <= yrep; ++y)
        {
            _rectanglebltr(cell, 
                generics_create_contact(layermap, techstate, region),
                (x - 1) * xpitch - (xrep - 1) * xpitch / 2 + (blx + trx) / 2 - entry->width / 2,
                (y - 1) * ypitch - (yrep - 1) * ypitch / 2 + (bly + try) / 2 - entry->height / 2,
                (x - 1) * xpitch - (xrep - 1) * xpitch / 2 + (blx + trx) / 2 + entry->width / 2,
                (y - 1) * ypitch - (yrep - 1) * ypitch / 2 + (bly + try) / 2 + entry->height / 2,
                viaxrep, viayrep, viaxpitch, viaypitch
            );
        }
    }
    _rectanglebltr(cell, generics_create_metal(layermap, techstate, 1), blx, bly, trx, try, xrep, yrep, xpitch, ypitch);
    _rectanglebltr(cell, generics_create_other(layermap, techstate, "active"), blx, bly, trx, try, xrep, yrep, xpitch, ypitch);
}

void geometry_contactbltr(
    object_t* cell,
    struct layermap* layermap, struct technology_state* techstate,
    const char* region,
    point_t* bl, point_t* tr,
    ucoordinate_t xrep, ucoordinate_t yrep,
    ucoordinate_t xpitch, ucoordinate_t ypitch,
    int xcont, int ycont
)
{
    _contactbltr(
        cell,
        layermap, techstate,
        region,
        bl->x, bl->y, tr->x, tr->y,
        xrep, yrep,
        xpitch, ypitch,
        xcont, ycont
    );
}

void geometry_contact(
    object_t* cell,
    struct layermap* layermap, struct technology_state* techstate,
    const char* region,
    ucoordinate_t width, ucoordinate_t height,
    coordinate_t xshift, coordinate_t yshift,
    ucoordinate_t xrep, ucoordinate_t yrep,
    ucoordinate_t xpitch, ucoordinate_t ypitch,
    int xcont, int ycont
)
{
    _contactbltr(
        cell,
        layermap, techstate,
        region,
        -(coordinate_t)width / 2 + xshift, -(coordinate_t)height / 2 + yshift,
        width / 2 + xshift, height / 2 + yshift,
        xrep, yrep,
        xpitch, ypitch,
        xcont, ycont
    );
}

void geometry_cross(object_t* cell, generics_t* layer, ucoordinate_t width, ucoordinate_t height, ucoordinate_t crosssize)
{
    shape_t* S = shape_create_polygon(layer, 13);
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

void geometry_unequal_ring(object_t* cell, generics_t* layer, ucoordinate_t width, ucoordinate_t height, ucoordinate_t ringwidth, ucoordinate_t ringheight)
{
    coordinate_t w = width;
    coordinate_t h = height;
    coordinate_t rw = ringwidth;
    coordinate_t rh = ringheight;
    shape_t* S = shape_create_polygon(layer, 13);
    shape_append(S, -(w + rw) / 2, -(h + rh) / 2);
    shape_append(S,  (w + rw) / 2, -(h + rh) / 2);
    shape_append(S,  (w + rw) / 2,  (h + rh) / 2);
    shape_append(S, -(w + rw) / 2,  (h + rh) / 2);
    shape_append(S, -(w + rw) / 2, -(h - rh) / 2);
    shape_append(S, -(w - rw) / 2, -(h - rh) / 2);
    shape_append(S, -(w - rw) / 2,  (h - rh) / 2);
    shape_append(S,  (w - rw) / 2,  (h - rh) / 2);
    shape_append(S,  (w - rw) / 2, -(h - rh) / 2);
    shape_append(S, -(w + rw) / 2, -(h - rh) / 2);
    shape_append(S, -(w + rw) / 2, -(h + rh) / 2); // close polygon
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
    geometry_unequal_ring(cell, layer, width, height, ringwidth, ringwidth);
}

struct trivertex
{
    point_t* pt;
    int is_ear;
    size_t index;
};

struct trivertex* _vertex_create(point_t* pt)
{
    struct trivertex* v = malloc(sizeof(*v));
    v->pt = pt;
    v->is_ear = 0;
    v->index = 0;
    return v;
}

// bayer coordinates used here to check if a point is in the given triangle, a different approach can also be used
static int _is_in_triangle(const struct trivertex* p, const struct trivertex* v1, const struct trivertex* v2, const struct trivertex* v3)
{
    int alpha = 
        (
            (v2->pt->y - v3->pt->y) * (p->pt->x - v3->pt->x) + 
            (v3->pt->x - v2->pt->x) * (p->pt->y - v3->pt->y)
        ) / 
        (
            (v2->pt->y - v3->pt->y) * (v1->pt->x - v3->pt->x) + 
            (v3->pt->x - v2->pt->x) * (v1->pt->y - v3->pt->y)
        );

    int beta = 
        (
            (v3->pt->y - v1->pt->y) * (p->pt->x - v3->pt->x) + 
            (v1->pt->x - v3->pt->x) * (p->pt->y - v3->pt->y)
        ) / 
        (
            (v2->pt->y - v3->pt->y) * (v1->pt->x - v3->pt->x) + 
            (v3->pt->x - v2->pt->x) * (v1->pt->y - v3->pt->y)
        );

    return (alpha > 0) && (beta > 0) && ((1 - alpha) > beta);
}

// function to check if any point lies within the given triangle
static int _has_points_in_tri(struct vector* vertices, size_t i, size_t idx1, size_t idx2)
{
    for(size_t j = 0; j < vector_size(vertices); j++)
    {
        if(j == idx1 || j == idx2 || j == i)
        {
            continue;
        }
        if(_is_in_triangle(vector_get(vertices, j), vector_get(vertices, i), vector_get(vertices, idx1), vector_get(vertices, idx2)))
        {
            return 1;
        }
    }
    return 0;
}

// ear evaluation is done here
static void _evaluate(struct vector* vertices, size_t i, size_t idx1, size_t idx2)
{
    struct trivertex* vi = vector_get(vertices, i);
    struct trivertex* vidx1 = vector_get(vertices, idx1);
    struct trivertex* vidx2 = vector_get(vertices, idx2);
    // calculate the determinant
    int det = (
        (vi->pt->x - vidx1->pt->x) * (vidx1->pt->y - vidx2->pt->y) -
        (vi->pt->y - vidx1->pt->y) * (vidx1->pt->x - vidx2->pt->x)
    );

    // if positive, we have an ear and set the trivertex ear property to true
    if (det < 0)
    {
        return;
    }

    // check if there is any point in the triangle
    if (!_has_points_in_tri(vertices, i, idx1, idx2))
    {
        vidx1->is_ear = 1;
    }
}

struct vector* geometry_triangulate_polygon(struct vector* polypoints)
{
    // build data structure
    struct vector* vertices = vector_create(1024);
    for(size_t i = 0; i < vector_size(polypoints); ++i)
    {
        vector_append(vertices, _vertex_create(vector_get(polypoints, i)));
    }

    // loop through all vertices and check them for ear/non-ear property
    size_t sz = vector_size(vertices);
    for(size_t i = 0; i < sz; i++)
    {
        _evaluate(vertices, i, (i + 1) % sz, (i + 2) % sz);
        struct trivertex* v = vector_get(vertices, i);
        v->index = i;
    }

    struct vector* result = vector_create((vector_size(vertices) - 2) * 3);

    // loop until the polygon has only 3 vertices remaining
    while(sz >= 3)
    {
        for(size_t i = 0; i < sz; i++)
        {
            // calculate adjacent trivertex indices
            size_t idx1 = (i + 1) % sz; 
            size_t idx2 = (i + 2) % sz;

            // check if trivertex is an ear
            if(((struct trivertex*)vector_get(vertices, idx1))->is_ear)
            {
                // store the triangle points
                vector_append(result, ((struct trivertex*)vector_get(vertices, i))->pt);
                vector_append(result, ((struct trivertex*)vector_get(vertices, idx1))->pt);
                vector_append(result, ((struct trivertex*)vector_get(vertices, idx2))->pt);

                // remove the trivertex from the polygon
                vector_remove(vertices, idx1, NULL); // vertices is non-owning
                sz--;

                // check if adjacent vertices changed their ear/non-ear configuration and update
                idx1 = (i + 1) % sz;
                _evaluate(vertices, i == 0 ? sz - 1 : i - 1, i, idx1);
                idx2 = (i + 2) % sz;
                _evaluate(vertices, idx1, idx2, (idx2 + 1) % sz);

                break;
            }
        }
    }
    return result;
}


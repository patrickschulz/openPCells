#include "geometry.h"

#include <stdlib.h>
#include <stddef.h>
#include <stdio.h>

#include "math.h"

static void _multiple_xy(struct object* cell, struct shape* base, ucoordinate_t xrep, ucoordinate_t yrep, ucoordinate_t xpitch, ucoordinate_t ypitch)
{
    for(unsigned int x = 1; x <= xrep; ++x)
    {
        for(unsigned int y = 1; y <= yrep; ++y)
        {
            struct shape* S = shape_copy(base);
            shape_translate(
                S,
                (x - 1) * xpitch - (xrep - 1) * xpitch / 2,
                (y - 1) * ypitch - (yrep - 1) * ypitch / 2
            );
            object_add_shape(cell, S);
        }
    }
}

static void _rectanglebltr_multiple(struct object* cell, const struct generics* layer, coordinate_t blx, coordinate_t bly, coordinate_t trx, coordinate_t try, ucoordinate_t xrep, ucoordinate_t yrep, ucoordinate_t xpitch, ucoordinate_t ypitch)
{
    if(generics_is_empty(layer))
    {
        return;
    }
    struct shape* S = shape_create_rectangle(layer, blx, bly, trx, try);
    _multiple_xy(cell, S, xrep, yrep, xpitch, ypitch);
    shape_destroy(S); // _multiple_xy copies all shapes, one remains unowned
}

static void _rectanglebltr(struct object* cell, const struct generics* layer, coordinate_t blx, coordinate_t bly, coordinate_t trx, coordinate_t try)
{
    if(generics_is_empty(layer))
    {
        return;
    }
    struct shape* S = shape_create_rectangle(layer, blx, bly, trx, try);
    object_add_shape(cell, S);
}

void geometry_rectanglebltrxy(struct object* cell, const struct generics* layer, coordinate_t blx, coordinate_t bly, coordinate_t trx, coordinate_t try)
{
    if(generics_is_empty(layer))
    {
        return;
    }
    struct shape* S = shape_create_rectangle(layer, blx, bly, trx, try);
    object_add_shape(cell, S);
}

void geometry_rectanglebltr(struct object* cell, const struct generics* layer, const point_t* bl, const point_t* tr)
{
    _rectanglebltr(cell, layer, bl->x, bl->y, tr->x, tr->y);
}

void geometry_rectanglepoints(struct object* cell, const struct generics* layer, const point_t* pt1, const point_t* pt2)
{
    if(pt1->x <= pt2->x && pt1->y <= pt2->y)
    {
        _rectanglebltr(cell, layer, pt1->x, pt1->y, pt2->x, pt2->y);
    }
    else if(pt1->x <= pt2->x && pt1->y  > pt2->y)
    {
        _rectanglebltr(cell, layer, pt1->x, pt2->y, pt2->x, pt1->y);
    }
    else if(pt1->x  > pt2->x && pt1->y <= pt2->y)
    {
        _rectanglebltr(cell, layer, pt2->x, pt1->y, pt1->x, pt2->y);
    }
    else if(pt1->x  > pt2->x && pt1->y  > pt2->y)
    {
        _rectanglebltr(cell, layer, pt2->x, pt2->y, pt1->x, pt1->y);
    }
}

void geometry_rectanglearray(
    struct object* cell,
    const struct generics* layer,
    coordinate_t width, coordinate_t height,
    coordinate_t xshift, coordinate_t yshift,
    unsigned int xrep, unsigned int yrep,
    ucoordinate_t xpitch, ucoordinate_t ypitch
)
{
    for(unsigned int xi = 1; xi <= xrep; ++xi)
    {
        for(unsigned int yi = 1; yi <= yrep; ++yi)
        {
            coordinate_t x = xshift + (xi - 1) * xpitch;
            coordinate_t y = yshift + (yi - 1) * ypitch;
            _rectanglebltr(cell, layer, x, y, x + width, y + height);
        }
    }
}

void geometry_polygon(struct object* cell, const struct generics* layer, const point_t** points, size_t len)
{
    if(len == 0) // don't add empty polygons
    {
        return;
    }
    if(generics_is_empty(layer))
    {
        return;
    }
    struct shape* S = shape_create_polygon(layer, len);
    for(unsigned int i = 0; i < len; ++i)
    {
        shape_append(S, points[i]->x, points[i]->y);
    }
    shape_cleanup(S);
    object_add_shape(cell, S);
}

void geometry_path(struct object* cell, const struct generics* layer, const point_t** points, size_t len, ucoordinate_t width, ucoordinate_t bgnext, ucoordinate_t endext)
{
    if(generics_is_empty(layer))
    {
        return;
    }
    struct shape* S = shape_create_path(layer, len, width, bgnext, endext);
    for(unsigned int i = 0; i < len; ++i)
    {
        shape_append(S, points[i]->x, points[i]->y);
    }
    object_add_shape(cell, S);
}

void geometry_path_polygon(struct object* cell, const struct generics* layer, const point_t** points, size_t len, ucoordinate_t width, ucoordinate_t bgnext, ucoordinate_t endext)
{
    if(generics_is_empty(layer))
    {
        return;
    }
    struct shape* S = shape_create_path(layer, len, width, bgnext, endext);
    for(unsigned int i = 0; i < len; ++i)
    {
        shape_append(S, points[i]->x, points[i]->y);
    }
    shape_resolve_path_inline(S);
    object_add_shape(cell, S);
}

static void _shift_line(const point_t* pt1, const point_t* pt2, ucoordinate_t width, point_t** spt1, point_t** spt2, unsigned int grid)
{
    double angle = atan2(pt2->y - pt1->y, pt2->x - pt1->x) - M_PI / 2;
    coordinate_t xshift = grid * floor(floor(width * cos(angle) + 0.5) / grid);
    coordinate_t yshift = grid * floor(floor(width * sin(angle) + 0.5) / grid);
    (*spt1)->x = pt1->x + xshift;
    (*spt1)->y = pt1->y + yshift;
    (*spt2)->x = pt2->x + xshift;
    (*spt2)->y = pt2->y + yshift;
}

static struct vector* _get_edge_segments(point_t** points, size_t numpoints, ucoordinate_t width, unsigned int grid)
{
    struct vector* edges = vector_create(4 * (numpoints - 1), point_destroy);
    // append dummy points, later filled by _shift_line
    for(unsigned int i = 0; i < 4 * (numpoints - 1); ++i)
    {
        vector_append(edges, point_create(0, 0));
    }
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

static int _intersection(const point_t* s1, const point_t* s2, const point_t* c1, const point_t* c2, point_t** pt)
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
    struct vector* poly = vector_create(2 * numedges, point_destroy); // wild guess on the number of points
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
    vector_append(poly, point_copy(vector_get(edges, 2 * segs - 1)));
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
    vector_append(poly, point_copy(vector_get(edges, numedges - 1)));
    return poly;
}

void _make_unique_points(point_t** points, size_t* numpoints)
{
    for(unsigned int i = *numpoints - 1; i > 0; --i)
    {
        if((points[i]->x == points[i - 1]->x) && (points[i]->y == points[i - 1]->y))
        {
            for(unsigned int j = 0; j < *numpoints - i - 1; ++j)
            {
                points[i + j] = points[i + j + 1];
            }
            --(*numpoints);
        }
    }
}

struct shape* geometry_path_to_polygon(const struct generics* layer, point_t** points, size_t numpoints, ucoordinate_t width, int miterjoin)
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
    vector_destroy(edges);
    struct shape* S = shape_create_polygon(layer, vector_size(poly));
    struct vector_const_iterator* it = vector_const_iterator_create(poly);
    while(vector_const_iterator_is_valid(it))
    {
        const point_t* pt = vector_const_iterator_get(it);
        shape_append(S, pt->x, pt->y);
        vector_const_iterator_next(it);
    }
    vector_const_iterator_destroy(it);
    vector_destroy(poly);
    return S;
}

struct vector* _get_any_angle_path_pts(point_t** pts, size_t len, ucoordinate_t width, ucoordinate_t grid, int miterjoin, int allow45)
{
    (void)allow45;
    struct vector* edges = _get_edge_segments(pts, len, width, grid);
    struct vector* poly = _get_path_pts(edges, miterjoin);
    vector_destroy(edges);
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

void geometry_any_angle_path(struct object* cell, const struct generics* layer, point_t** pts, size_t len, ucoordinate_t width, ucoordinate_t grid, int miterjoin, int allow45)
{
    _make_unique_points(pts, &len);
    struct vector* points = _get_any_angle_path_pts(pts, len, width, grid, miterjoin, allow45);
    geometry_polygon(cell, layer, vector_content(points), vector_size(points));
    vector_destroy(points);
}

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

static void _equal_pitch_via(
    ucoordinate_t width, ucoordinate_t height,
    unsigned int cutsize, unsigned int space, int encl,
    unsigned int* xrep_result, unsigned int* yrep_result,
    unsigned int* xspace_result, unsigned int* yspace_result
)
{
    (void)encl; // FIXME
    int Nxres = 0;
    int Nyres = 0;
    for(unsigned int Nx = 1; Nx < UINT_MAX; ++Nx)
    {
        if(width % Nx == 0)
        {
            if((width / Nx) < (space + cutsize))
            {
                break;
            }
            unsigned int Sx = width / Nx - cutsize; // guaranteed to be non-negative
            if(Sx % 2 == 0)
            {
                for(unsigned int Ny = 1; Ny < UINT_MAX; ++Ny)
                {
                    if(height % Ny == 0)
                    {
                        if((height / Ny) < (space + cutsize))
                        {
                            break;
                        }
                        unsigned int Sy = height / Ny - cutsize; // guaranteed to be non-negative
                        if(Sy % 2 == 0)
                        {
                            if(Sx == Sy)
                            {
                                Nxres = Nx;
                                Nyres = Ny;
                            }
                        }
                    }
                }
            }
        }
    }
    *xrep_result = Nxres;
    *yrep_result = Nyres;
    if(Nxres > 0)
    {
        *xspace_result = width / Nxres - cutsize;
    }
    if(Nyres > 0)
    {
        *yspace_result = height / Nyres - cutsize;
    }
}

static struct via_definition* _get_rectangular_arrayzation(ucoordinate_t regionwidth, ucoordinate_t regionheight, struct via_definition** definitions, struct via_definition* fallback, unsigned int* xrep_ptr, unsigned int* yrep_ptr, unsigned int* xpitch_ptr, unsigned int* ypitch_ptr, int xcont, int ycont, int equal_pitch)
{
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
        if(regionwidth > entry->maxwidth)
        {
            ++viadef;
            continue;
        }
        if(regionheight > entry->maxheight)
        {
            ++viadef;
            continue;
        }
        unsigned int _xrep = 0;
        unsigned int _xspace = 0;
        unsigned int _yrep = 0;
        unsigned int _yspace = 0;
        if(equal_pitch)
        {
            if(entry->width == entry->height) // only square vias can be equal pitch
            {
                int space = entry->xspace > entry->yspace ? entry->xspace : entry->yspace;
                int enclosure = entry->xenclosure > entry->yenclosure ? entry->xenclosure : entry->yenclosure;
                _equal_pitch_via(regionwidth, regionheight, entry->width, space, enclosure, &_xrep, &_yrep, &_xspace, &_yspace);
            }
        }
        else
        {
            if(xcont)
            {
                _continuous_via(regionwidth, entry->width, entry->xspace, entry->xenclosure, &_xrep, &_xspace);
            }
            else
            {
                _fit_via(regionwidth, entry->width, entry->xspace, entry->xenclosure, &_xrep, &_xspace);
            }
            if(ycont)
            {
                _continuous_via(regionheight, entry->height, entry->yspace, entry->yenclosure, &_yrep, &_yspace);
            }
            else
            {
                _fit_via(regionheight, entry->height, entry->yspace, entry->yenclosure, &_yrep, &_yspace);
            }
        }
        if(_xrep > 0 && _yrep > 0)
        {
            unsigned int area = (_xrep + _yrep) * entry->width * entry->height;
            if(!result || (area > lastarea) || ((area == lastarea) && ((_xrep * _yrep) > (xrep * yrep))))
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
            return NULL;
        }
    }
    *xpitch_ptr = result->width + xspace;
    *ypitch_ptr = result->height + yspace;
    *xrep_ptr = xrep;
    *yrep_ptr = yrep;
    return result;
}

static int _via_contact_bltr(
    struct object* cell,
    struct via_definition** viadefs, struct via_definition* fallback,
    const struct generics* cutlayer,
    coordinate_t blx, coordinate_t bly, coordinate_t trx, coordinate_t try,
    int xcont, int ycont,
    int equal_pitch,
    int makearray
)
{
    if(makearray)
    {
        ucoordinate_t width = trx - blx;
        ucoordinate_t height = try - bly;
        unsigned int viaxrep, viayrep, viaxpitch, viaypitch;
        struct via_definition* entry = _get_rectangular_arrayzation(width, height, viadefs, fallback, &viaxrep, &viayrep, &viaxpitch, &viaypitch, xcont, ycont, equal_pitch);
        if(!entry)
        {
            return 0;
        }
        _rectanglebltr_multiple(cell,
            cutlayer,
            (blx + trx) / 2 - entry->width / 2,
            (bly + try) / 2 - entry->height / 2,
            (blx + trx) / 2 + entry->width / 2,
            (bly + try) / 2 + entry->height / 2,
            viaxrep, viayrep, viaxpitch, viaypitch
        );
    }
    else
    {
        _rectanglebltr(cell, cutlayer, blx, bly, trx, try);
    }
    return 1;
}

static int _viabltr(
    struct object* cell,
    struct technology_state* techstate,
    int metal1, int metal2,
    coordinate_t blx, coordinate_t bly, coordinate_t trx, coordinate_t try,
    int xcont, int ycont,
    int equal_pitch,
    int bare
)
{
    metal1 = technology_resolve_metal(techstate, metal1);
    metal2 = technology_resolve_metal(techstate, metal2);
    if(metal1 > metal2)
    {
        int tmp = metal1;
        metal1 = metal2;
        metal2 = tmp;
    }
    int ret = 1;
    for(int i = metal1; i < metal2; ++i)
    {
        struct via_definition** viadefs = technology_get_via_definitions(techstate, i, i + 1);
        struct via_definition* fallback = technology_get_via_fallback(techstate, i, i + 1);
        if(!viadefs)
        {
            return 0;
        }
        ret = ret && _via_contact_bltr(cell,
            viadefs, fallback,
            generics_create_viacut(techstate, i, i + 1),
            blx, bly, trx, try,
            xcont, ycont,
            equal_pitch,
            technology_is_create_via_arrays(techstate)
        );
    }
    if(!bare)
    {
        for(int i = metal1; i <= metal2; ++i)
        {
            _rectanglebltr(cell, generics_create_metal(techstate, i), blx, bly, trx, try);
        }
    }
    return ret;
}

int geometry_viabltr(struct object* cell, struct technology_state* techstate, int metal1, int metal2, const point_t* bl, const point_t* tr, int xcont, int ycont, int equal_pitch)
{
    int bare = 0;
    return _viabltr(cell, techstate, metal1, metal2, bl->x, bl->y, tr->x, tr->y, xcont, ycont, equal_pitch, bare);
}

int geometry_viabarebltr(struct object* cell, struct technology_state* techstate, int metal1, int metal2, const point_t* bl, const point_t* tr, int xcont, int ycont, int equal_pitch)
{
    int bare = 1;
    return _viabltr(cell, techstate, metal1, metal2, bl->x, bl->y, tr->x, tr->y, xcont, ycont, equal_pitch, bare);
}

static int _contactbltr(
    struct object* cell,
    struct technology_state* techstate,
    const char* region,
    coordinate_t blx, coordinate_t bly, coordinate_t trx, coordinate_t try,
    int xcont, int ycont,
    int equal_pitch
)
{
    struct via_definition** viadefs = technology_get_contact_definitions(techstate, region);
    struct via_definition* fallback = technology_get_contact_fallback(techstate, region);
    if(!viadefs)
    {
        return 0;
    }
    int ret = 1;
    ret = ret && _via_contact_bltr(cell,
        viadefs, fallback,
        generics_create_contact(techstate, region),
        blx, bly, trx, try,
        xcont, ycont,
        equal_pitch,
        technology_is_create_via_arrays(techstate)
    );
    _rectanglebltr(cell, generics_create_metal(techstate, 1), blx, bly, trx, try);
    return ret;
}

static int _contactbarebltr(
    struct object* cell,
    struct technology_state* techstate,
    const char* region,
    coordinate_t blx, coordinate_t bly, coordinate_t trx, coordinate_t try,
    int xcont, int ycont,
    int equal_pitch
)
{
    struct via_definition** viadefs = technology_get_contact_definitions(techstate, region);
    struct via_definition* fallback = technology_get_contact_fallback(techstate, region);
    if(!viadefs)
    {
        return 0;
    }
    int ret = 1;
    ret = ret && _via_contact_bltr(cell,
        viadefs, fallback,
        generics_create_contact(techstate, region),
        blx, bly, trx, try,
        xcont, ycont,
        equal_pitch,
        technology_is_create_via_arrays(techstate)
    );
    return ret;
}

int geometry_contactbltr(
    struct object* cell,
    struct technology_state* techstate,
    const char* region,
    const point_t* bl, const point_t* tr,
    int xcont, int ycont,
    int equal_pitch
)
{
    return _contactbltr(
        cell,
        techstate,
        region,
        bl->x, bl->y, tr->x, tr->y,
        xcont, ycont,
        equal_pitch
    );
}

int geometry_contactbarebltr(
    struct object* cell,
    struct technology_state* techstate,
    const char* region,
    const point_t* bl, const point_t* tr,
    int xcont, int ycont,
    int equal_pitch
)
{
    return _contactbarebltr(
        cell,
        techstate,
        region,
        bl->x, bl->y, tr->x, tr->y,
        xcont, ycont,
        equal_pitch
    );
}

void geometry_cross(struct object* cell, const struct generics* layer, ucoordinate_t width, ucoordinate_t height, ucoordinate_t crosssize)
{
    if(generics_is_empty(layer))
    {
        return;
    }
    struct shape* S = shape_create_polygon(layer, 13);
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
    object_add_shape(cell, S);
}

void geometry_unequal_ring(struct object* cell, const struct generics* layer, coordinate_t x0, coordinate_t y0, ucoordinate_t outerwidth, ucoordinate_t outerheight, ucoordinate_t leftwidth, ucoordinate_t rightwidth, ucoordinate_t topwidth, ucoordinate_t bottomwidth)
{
    if(generics_is_empty(layer))
    {
        return;
    }
    coordinate_t w = outerwidth;
    coordinate_t h = outerheight;
    coordinate_t lw = leftwidth;
    coordinate_t rw = rightwidth;
    coordinate_t tw = topwidth;
    coordinate_t bw = bottomwidth;
    struct shape* S = shape_create_polygon(layer, 13);
    shape_append(S, x0 - (w / 2),      y0 - (h / 2));
    shape_append(S, x0 + (w / 2),      y0 - (h / 2));
    shape_append(S, x0 + (w / 2),      y0 + (h / 2));
    shape_append(S, x0 - (w / 2),      y0 + (h / 2));
    shape_append(S, x0 - (w / 2),      y0 - (h / 2 - bw));
    shape_append(S, x0 - (w / 2 - lw), y0 - (h / 2 - bw));
    shape_append(S, x0 - (w / 2 - lw), y0 + (h / 2 - tw));
    shape_append(S, x0 + (w / 2 - rw), y0 + (h / 2 - tw));
    shape_append(S, x0 + (w / 2 - rw), y0 - (h / 2 - bw));
    shape_append(S, x0 - (w / 2),      y0 - (h / 2 - bw));
    shape_append(S, x0 - (w / 2),      y0 - (h / 2)); // close polygon
    object_add_shape(cell, S);
}

void geometry_ring(struct object* cell, const struct generics* layer, coordinate_t x0, coordinate_t y0, ucoordinate_t outerwidth, ucoordinate_t outerheight, ucoordinate_t ringwidth)
{
    geometry_unequal_ring(cell, layer, x0, y0, outerwidth, outerheight, ringwidth, ringwidth, ringwidth, ringwidth);
}

void geometry_unequal_ring_pts(
    struct object* cell,
    const struct generics* layer,
    const point_t* outerbl, const point_t* outertr,
    const point_t* innerbl, const point_t* innertr
)
{
    if(generics_is_empty(layer))
    {
        return;
    }
    struct shape* S = shape_create_polygon(layer, 13);
    shape_append(S, outerbl->x, outerbl->y);
    shape_append(S, outertr->x, outerbl->y);
    shape_append(S, outertr->x, outertr->y);
    shape_append(S, outerbl->x, outertr->y);
    shape_append(S, outerbl->x, innerbl->y);
    shape_append(S, innerbl->x, innerbl->y);
    shape_append(S, innerbl->x, innertr->y);
    shape_append(S, innertr->x, innertr->y);
    shape_append(S, innertr->x, innerbl->y);
    shape_append(S, outerbl->x, innerbl->y);
    shape_append(S, outerbl->x, outerbl->y); // close polygon
    object_add_shape(cell, S);
}


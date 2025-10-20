#include "geometry.h"

#include <stddef.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "helpers.h"
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

void geometry_rectanglebltr(struct object* cell, const struct generics* layer, const struct point* bl, const struct point* tr)
{
    _rectanglebltr(cell, layer, bl->x, bl->y, tr->x, tr->y);
}

void geometry_rectangleblwh(struct object* cell, const struct generics* layer, const struct point* bl, coordinate_t width, coordinate_t height)
{
    _rectanglebltr(cell, layer, bl->x, bl->y, bl->x + width, bl->y + height);
}

void geometry_rectanglepointsxy(
    struct object* cell,
    const struct generics* layer,
    coordinate_t x1, coordinate_t y1,
    coordinate_t x2, coordinate_t y2
)
{
    if(x1 <= x2 && y1 <= y2)
    {
        _rectanglebltr(cell, layer, x1, y1, x2, y2);
    }
    else if(x1 <= x2 && y1  > y2)
    {
        _rectanglebltr(cell, layer, x1, y2, x2, y1);
    }
    else if(x1  > x2 && y1 <= y2)
    {
        _rectanglebltr(cell, layer, x2, y1, x1, y2);
    }
    else if(x1  > x2 && y1  > y2)
    {
        _rectanglebltr(cell, layer, x2, y2, x1, y1);
    }
}

void geometry_rectanglepoints(struct object* cell, const struct generics* layer, const struct point* pt1, const struct point* pt2)
{
    geometry_rectanglepointsxy(cell, layer, pt1->x, pt1->y, pt2->x, pt2->y);
}

void geometry_rectangleareaanchor(struct object* cell, const struct generics* layer, const char* anchor)
{
    struct point* pts = object_get_area_anchor(cell, anchor);
    geometry_rectanglebltr(cell, layer, pts + 0, pts + 1);
    free(pts);
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

void geometry_slotted_rectangle(
    struct object* cell,
    const struct generics* layer,
    const struct point* bl, const struct point* tr,
    coordinate_t slotwidth, coordinate_t slotheight,
    coordinate_t slotxspace, coordinate_t slotyspace,
    coordinate_t slotminedgexspace, coordinate_t slotminedgeyspace
)
{
    coordinate_t regionwidth = tr->x - bl->x;
    coordinate_t regionheight = tr->y - bl->y;
    unsigned int xrep = 0;
    coordinate_t slotedgexspace = 0;
    for(unsigned int _xrep = 0; _xrep < 500; ++_xrep)
    {
        coordinate_t _slotedgexspace = (regionwidth - (_xrep + 1) * slotwidth - _xrep * slotxspace) / 2;
        if(_slotedgexspace < slotminedgexspace)
        {
            break;
        }
        xrep = _xrep;
        slotedgexspace = _slotedgexspace;
    }
    unsigned int yrep = 0;
    coordinate_t slotedgeyspace = 0;
    for(unsigned int _yrep = 0; _yrep < 500; ++_yrep)
    {
        coordinate_t _slotedgeyspace = (regionheight - (_yrep + 1) * slotheight - _yrep * slotyspace) / 2;
        if(_slotedgeyspace < slotminedgeyspace)
        {
            break;
        }
        yrep = _yrep;
        slotedgeyspace = _slotedgeyspace;
    }
    _rectanglebltr(cell, layer, bl->x, bl->y, bl->x + slotedgexspace, tr->y);
    _rectanglebltr(cell, layer, tr->x - slotedgexspace, bl->y, tr->x, tr->y);
    for(unsigned int xi = 0; xi < xrep; ++xi)
    {
        coordinate_t xshift = xi * (slotxspace + slotwidth) + slotedgexspace + slotwidth;
        _rectanglebltr(cell, layer, bl->x + xshift, bl->y, bl->x + xshift + slotxspace, tr->y);
    }
    _rectanglebltr(cell, layer, bl->x, bl->y, tr->x, bl->y + slotedgeyspace);
    _rectanglebltr(cell, layer, bl->x, tr->y - slotedgeyspace, tr->x, tr->y);
    for(unsigned int yi = 0; yi < yrep; ++yi)
    {
        coordinate_t yshift = yi * (slotyspace + slotheight) + slotedgeyspace + slotheight;
        _rectanglebltr(cell, layer, bl->x, bl->y + yshift, tr->x, bl->y + yshift + slotyspace);
    }
}

void geometry_polygon(struct object* cell, const struct generics* layer, const struct point** points, size_t len)
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

void geometry_path(struct object* cell, const struct generics* layer, const struct vector* points, ucoordinate_t width, ucoordinate_t bgnext, ucoordinate_t endext)
{
    if(generics_is_empty(layer))
    {
        return;
    }
    struct shape* S = shape_create_path(layer, vector_size(points), width, bgnext, endext);
    for(size_t i = 0; i < vector_size(points); ++i)
    {
        const struct point* pt = vector_get_const(points, i);
        shape_append(S, pt->x, pt->y);
    }
    object_add_shape(cell, S);
}

void geometry_path_polygon(struct object* cell, const struct generics* layer, const struct vector* points, ucoordinate_t width, ucoordinate_t bgnext, ucoordinate_t endext)
{
    if(generics_is_empty(layer))
    {
        return;
    }
    struct shape* S = shape_create_path(layer, vector_size(points), width, bgnext, endext);
    for(size_t i = 0; i < vector_size(points); ++i)
    {
        const struct point* pt = vector_get_const(points, i);
        shape_append(S, pt->x, pt->y);
    }
    shape_resolve_path_inline(S);
    object_add_shape(cell, S);
}

static void _shift_line(const struct point* pt1, const struct point* pt2, ucoordinate_t width, struct point** spt1, struct point** spt2, unsigned int grid)
{
    double angle = atan2(pt2->y - pt1->y, pt2->x - pt1->x) - M_PI / 2;
    coordinate_t xshift = grid * floor(floor(width * cos(angle) + 0.5) / grid);
    coordinate_t yshift = grid * floor(floor(width * sin(angle) + 0.5) / grid);
    (*spt1)->x = pt1->x + xshift;
    (*spt1)->y = pt1->y + yshift;
    (*spt2)->x = pt2->x + xshift;
    (*spt2)->y = pt2->y + yshift;
}

static void _shift_line_signed(const struct point* pt1, const struct point* pt2, coordinate_t offset, struct point** spt1, struct point** spt2, unsigned int grid)
{
    double angle = atan2(pt2->y - pt1->y, pt2->x - pt1->x) - M_PI / 2;
    coordinate_t xshift = grid * trunc(trunc(offset * cos(angle)) / grid);
    coordinate_t yshift = grid * trunc(trunc(offset * sin(angle)) / grid);
    (*spt1)->x = pt1->x + xshift;
    (*spt1)->y = pt1->y + yshift;
    (*spt2)->x = pt2->x + xshift;
    (*spt2)->y = pt2->y + yshift;
}

static struct vector* _get_edge_segments(struct vector* points, ucoordinate_t shift, unsigned int grid)
{
    size_t numpoints = vector_size(points);
    struct vector* edges = vector_create(4 * (numpoints - 1), point_destroy);
    // append dummy points, later filled by _shift_line
    for(unsigned int i = 0; i < 4 * (numpoints - 1); ++i)
    {
        vector_append(edges, point_create(0, 0));
    }
    // start to end
    for(unsigned int i = 0; i < numpoints - 1; ++i)
    {
        struct point* pt1 = vector_get(points, i);
        struct point* pt2 = vector_get(points, i + 1);
        _shift_line(pt1, pt2, shift,
            vector_get_reference(edges, 2 * i), vector_get_reference(edges, 2 * i + 1),
            grid
        );
    }
    // end to start (shift in other direction)
    for(unsigned int i = numpoints - 1; i > 0; --i)
    {
        struct point* pt1 = vector_get(points, i);
        struct point* pt2 = vector_get(points, i - 1);
        // the indexing looks funny, but it works out
        _shift_line(pt1, pt2, shift,
            vector_get_reference(edges, 2 * (2 * numpoints - 2 - i)),
            vector_get_reference(edges, 2 * (2 * numpoints - 2 - i) + 1),
            grid
        );
    }
    return edges;
}

static struct vector* _get_side_edge_segments(struct vector* points, coordinate_t offset, unsigned int grid)
{
    size_t numpoints = vector_size(points);
    struct vector* edges = vector_create(4 * (numpoints - 1), point_destroy);
    // append dummy points, later filled by _shift_line
    for(unsigned int i = 0; i < 2 * (numpoints - 1); ++i)
    {
        vector_append(edges, point_create(0, 0));
    }
    // start to end
    for(unsigned int i = 0; i < numpoints - 1; ++i)
    {
        const struct point* pt1 = vector_get_const(points, i);
        const struct point* pt2 = vector_get_const(points, i + 1);
        _shift_line_signed(pt1, pt2, offset, vector_get_reference(edges, 2 * i), vector_get_reference(edges, 2 * i + 1), grid);
    }
    return edges;
}

// FIXME: there are too many functions calculating path outlines/polygon offsets.
// These things are basically the same, so this should be simplified
static struct vector* _get_side_edge_segments2(struct vector* points, coordinate_t offset, unsigned int grid)
{
    size_t numpoints = vector_size(points);
    struct vector* edges = vector_create(2 * numpoints, point_destroy);
    // start to end
    for(unsigned int i = 0; i < numpoints; ++i)
    {
        const struct point* pt1 = vector_get_const(points, i);
        const struct point* pt2;
        if(i == numpoints - 1) // last point is firs point
        {
            pt2 = vector_get_const(points, 0);
        }
        else
        {
            pt2 = vector_get_const(points, i + 1);
        }
        struct point* rpt1 = point_create(0, 0);
        struct point* rpt2 = point_create(0, 0);
        _shift_line_signed(pt1, pt2, offset, &rpt1, &rpt2, grid);
        vector_append(edges, rpt1);
        vector_append(edges, rpt2);
    }
    return edges;
}

static int _intersection(const struct point* s1, const struct point* s2, const struct point* c1, const struct point* c2, struct point** pt)
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
        struct point* pt = NULL;
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
        struct point* pt = NULL;
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

static struct vector* _get_polygon_pts(struct vector* edges)
{
    struct vector* poly = vector_create(1, point_destroy);
    for(size_t i = 0; i < vector_size(edges) - 1; i += 2)
    {
        struct point* e1bgn = vector_get(edges, i + 0);
        struct point* e1end = vector_get(edges, i + 1);
        struct point* e2bgn;
        struct point* e2end;
        if(i > vector_size(edges) - 3) // first point is also last point
        {
            e2bgn = vector_get(edges, 0);
            e2end = vector_get(edges, 1);
        }
        else
        {
            e2bgn = vector_get(edges, i + 2);
            e2end = vector_get(edges, i + 3);
        }
        struct point* pt = NULL;
        _intersection(e1bgn, e1end, e2bgn, e2end, &pt);
        if(pt)
        {
            vector_append(poly, pt);
        }
    }
    return poly;
}

static struct vector* _get_side_path_pts(struct vector* edges)
{
    size_t numedges = vector_size(edges);
    struct vector* pts = vector_create(2 * numedges, point_destroy); // wild guess on the number of points
    // first start point
    vector_append(pts, point_copy(vector_get(edges, 0)));
    // middle points
    if(numedges >= 4)
    {
        size_t segs = numedges / 2;
        for(unsigned int seg = 0; seg < segs - 1; ++seg)
        {
            unsigned int i = 2 * seg + 1;
            struct point* pt = NULL;
            _intersection(vector_get(edges, i - 1), vector_get(edges, i), vector_get(edges, i + 1), vector_get(edges, i + 2), &pt);
            if(pt)
            {
                vector_append(pts, point_copy(pt));
                free(pt);
            }
        }
    }
    // end points
    vector_append(pts, point_copy(vector_get(edges, numedges - 1)));
    return pts;
}

void _make_unique_points(struct vector* points)
{
    size_t i = vector_size(points) - 1;
    while(i > 1)
    {
        struct point* pt1 = vector_get(points, i);
        struct point* pt2 = vector_get(points, i - 1);
        if((pt1->x == pt2->x) && (pt1->y == pt2->y))
        {
            vector_remove(points, i);
        }
        --i;
    }
}

struct shape* geometry_path_to_polygon(const struct generics* layer, struct vector* points, ucoordinate_t width, int miterjoin)
{
    size_t numpoints = vector_size(points);
    _make_unique_points(points);

    // FIXME: handle path extensions

    // rectangle
    if(numpoints == 2)
    {
        struct point* pt1 = vector_get(points, 0);
        struct point* pt2 = vector_get(points, 1);
        if((pt1->x == pt2->x) || (pt1->y == pt2->y))
        {
            if    ((pt1->x  < pt2->x) && (pt1->y == pt2->y))
            {
                return shape_create_rectangle(layer, pt1->x, pt1->y - width / 2, pt2->x, pt1->y + width / 2);
            }
            else if((pt1->x  > pt2->x) && (pt1->y == pt2->y))
            {
                return shape_create_rectangle(layer, pt2->x, pt1->y - width / 2, pt1->x, pt1->y + width / 2);
            }
            else if((pt1->x == pt2->x) && (pt1->y  > pt2->y))
            {
                return shape_create_rectangle(layer, pt1->x - width / 2, pt2->y, pt1->x + width / 2, pt1->y);
            }
            else if((pt1->x == pt2->x) && (pt1->y  < pt2->y))
            {
                return shape_create_rectangle(layer, pt1->x - width / 2, pt1->y, pt1->x + width / 2, pt2->y);
            }
        }
    }

    // polygon
    struct vector* edges = _get_edge_segments(points, width / 2, 1);
    struct vector* poly = _get_path_pts(edges, miterjoin);
    vector_destroy(edges);
    struct shape* S = shape_create_polygon(layer, vector_size(poly));
    struct vector_const_iterator* it = vector_const_iterator_create(poly);
    while(vector_const_iterator_is_valid(it))
    {
        const struct point* pt = vector_const_iterator_get(it);
        shape_append(S, pt->x, pt->y);
        vector_const_iterator_next(it);
    }
    vector_const_iterator_destroy(it);
    vector_destroy(poly);
    return S;
}

struct vector* geometry_path_points_to_polygon(struct vector* points, ucoordinate_t width, int miterjoin)
{
    _make_unique_points(points);

    // FIXME: handle path extensions

    struct vector* edges = _get_edge_segments(points, width / 2, 1);
    struct vector* poly = _get_path_pts(edges, miterjoin);
    vector_destroy(edges);
    return poly;
}

// FIXME: this works for many cases, but is not error-free
// high offsets with polygons with acute angles lead to self-intersecting polygons
// the occurence of this should be checked and fixed
struct vector* geometry_offset_polygon_points(struct vector* points, ucoordinate_t offset)
{
    _make_unique_points(points);

    struct vector* edges = _get_side_edge_segments2(points, offset, 1);
    struct vector* poly = _get_polygon_pts(edges);
    vector_destroy(edges);
    return poly;
}

struct vector* geometry_get_side_path_points(struct vector* points, coordinate_t offset)
{
    _make_unique_points(points);

    struct vector* edges = _get_side_edge_segments(points, offset, 1);
    struct vector* poly = _get_side_path_pts(edges);
    vector_destroy(edges);
    return poly;
}

struct vector* _get_any_angle_path_pts(struct vector* pts, ucoordinate_t width, ucoordinate_t grid, int miterjoin, int allow45)
{
    (void)allow45;
    struct vector* edges = _get_edge_segments(pts, width / 2, grid);
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

void geometry_any_angle_path(struct object* cell, const struct generics* layer, struct vector* pts, ucoordinate_t width, ucoordinate_t grid, int miterjoin, int allow45)
{
    _make_unique_points(pts);
    struct vector* points = _get_any_angle_path_pts(pts, width, grid, miterjoin, allow45);
    geometry_polygon(cell, layer, vector_content(points), vector_size(points));
    vector_destroy(points);
}

static void _fit_via(ucoordinate_t size, unsigned int cutsize, unsigned int space, int encl, int* rep_result, unsigned int* space_result)
{
    *rep_result = ((int)size + (int)space - 2 * encl) / ((int)cutsize + (int)space);
    *space_result = space;
}

static void _fit_via_xy(
    coordinate_t blx1, coordinate_t bly1, coordinate_t trx1, coordinate_t try1,
    coordinate_t blx2, coordinate_t bly2, coordinate_t trx2, coordinate_t try2,
    coordinate_t blx, coordinate_t bly, coordinate_t trx, coordinate_t try,
    unsigned int cutwidth, unsigned int cutheight,
    unsigned int xspace, unsigned int yspace,
    int encl1, int encl2,
    int* xrep_result, unsigned int* xspace_result,
    int* yrep_result, unsigned int* yspace_result
)
{
    int xfit1a = ((int)(trx1 - blx1) + (int)xspace - 2 * encl1) / ((int)cutwidth + (int)xspace);
    int yfit1a = ((int)(try1 - bly1) + (int)yspace - 2 * encl2) / ((int)cutheight + (int)yspace);
    int xfit2a = ((int)(trx2 - blx2) + (int)xspace - 2 * encl2) / ((int)cutwidth + (int)xspace);
    int yfit2a = ((int)(try2 - bly2) + (int)yspace - 2 * encl1) / ((int)cutheight + (int)yspace);
    int xfit1b = ((int)(trx1 - blx1) + (int)xspace - 2 * encl2) / ((int)cutwidth + (int)xspace);
    int yfit1b = ((int)(try1 - bly1) + (int)yspace - 2 * encl1) / ((int)cutheight + (int)yspace);
    int xfit2b = ((int)(trx2 - blx2) + (int)xspace - 2 * encl1) / ((int)cutwidth + (int)xspace);
    int yfit2b = ((int)(try2 - bly2) + (int)yspace - 2 * encl2) / ((int)cutheight + (int)yspace);
    if(
        (xfit1a > 0 && yfit1a > 0 && xfit2a > 0 && yfit2a > 0) ||
        (xfit1a > 0 && yfit1a > 0 && xfit2b > 0 && yfit2b > 0) ||
        (xfit1b > 0 && yfit1b > 0 && xfit2a > 0 && yfit2a > 0) ||
        (xfit1b > 0 && yfit1b > 0 && xfit2b > 0 && yfit2b > 0)
    )
    {
        unsigned int xrep = ((trx - blx) + xspace) / (cutwidth + xspace);
        unsigned int yrep = ((try - bly) + yspace) / (cutheight + yspace);
        *xrep_result = xrep;
        *xspace_result = xspace;
        *yrep_result = yrep;
        *yspace_result = yspace;
    }
}

static void _continuous_via(ucoordinate_t size, unsigned int cutsize, unsigned int space, int encl, int* rep_result, unsigned int* space_result)
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
    int* xrep_result, int* yrep_result,
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

static struct via_definition* _get_rectangular_arrayzation(
    ucoordinate_t regionwidth, ucoordinate_t regionheight,
    struct via_definition** definitions,
    struct via_definition* fallback,
    unsigned int* xrep_ptr, unsigned int* yrep_ptr,
    unsigned int* xpitch_ptr, unsigned int* ypitch_ptr,
    coordinate_t minxspace, coordinate_t minyspace,
    int xcont, int ycont,
    int equal_pitch,
    coordinate_t widthclass
)
{
    unsigned int lastarea = 0;
    int xrep = 0;
    unsigned int xspace = 0;
    int yrep = 0;
    unsigned int yspace = 0;
    struct via_definition* result = NULL;
    struct via_definition** viadef = definitions;
    while(*viadef)
    {
        struct via_definition* entry = *viadef;
        if(widthclass > 0 && ((widthclass > entry->maxwidth) || (widthclass > entry->maxheight)))
        {
            ++viadef;
            continue;
        }
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
        int _xrep = 0;
        unsigned int _xspace = 0;
        int _yrep = 0;
        unsigned int _yspace = 0;
        coordinate_t _minxspace = minxspace > entry->xspace ? minxspace : entry->xspace;
        coordinate_t _minyspace = minyspace > entry->yspace ? minyspace : entry->yspace;
        if(equal_pitch)
        {
            if(entry->width == entry->height) // only square vias can be equal pitch
            {
                int space = _minxspace > _minyspace ? _minxspace : _minyspace;
                int enclosure = entry->xenclosure > entry->yenclosure ? entry->xenclosure : entry->yenclosure;
                _equal_pitch_via(regionwidth, regionheight, entry->width, space, enclosure, &_xrep, &_yrep, &_xspace, &_yspace);
            }
        }
        else
        {
            if(xcont)
            {
                _continuous_via(regionwidth, entry->width, _minxspace, entry->xenclosure, &_xrep, &_xspace);
            }
            else
            {
                _fit_via(regionwidth, entry->width, _minxspace, entry->xenclosure, &_xrep, &_xspace);
            }
            if(ycont)
            {
                _continuous_via(regionheight, entry->height, _minyspace, entry->yenclosure, &_yrep, &_yspace);
            }
            else
            {
                _fit_via(regionheight, entry->height, _minyspace, entry->yenclosure, &_yrep, &_yspace);
            }
        }
        if(_xrep > 0 && _yrep > 0)
        {
            unsigned int area = _xrep * _yrep * entry->width * entry->height;
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
            puts("used fallback via");
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

static struct via_definition* _get_rectangular_arrayzation2(
    coordinate_t blx1, coordinate_t bly1, coordinate_t trx1, coordinate_t try1,
    coordinate_t blx2, coordinate_t bly2, coordinate_t trx2, coordinate_t try2,
    coordinate_t blx, coordinate_t bly, coordinate_t trx, coordinate_t try,
    struct via_definition** definitions,
    struct via_definition* fallback,
    unsigned int* xrep_ptr, unsigned int* yrep_ptr,
    unsigned int* xpitch_ptr, unsigned int* ypitch_ptr
)
{
    unsigned int lastarea = 0;
    int xrep = 0;
    unsigned int xspace = 0;
    int yrep = 0;
    unsigned int yspace = 0;
    struct via_definition* result = NULL;
    struct via_definition** viadef = definitions;
    while(*viadef)
    {
        struct via_definition* entry = *viadef;
        int _xrep = 0;
        unsigned int _xspace = 0;
        int _yrep = 0;
        unsigned int _yspace = 0;
        _fit_via_xy(
            blx1, bly1, trx1, try1,
            blx2, bly2, trx2, try2,
            blx, bly, trx, try,
            entry->width, entry->height,
            entry->xspace, entry->yspace,
            entry->xenclosure, entry->yenclosure,
            &_xrep, &_xspace,
            &_yrep, &_yspace
        );
        if(_xrep > 0 && _yrep > 0)
        {
            unsigned int area = _xrep * _yrep * entry->width * entry->height;
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
            puts("used fallback via");
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

static int _check_via_contact_bltr(
    struct via_definition** viadefs, struct via_definition* fallback,
    coordinate_t blx, coordinate_t bly, coordinate_t trx, coordinate_t try,
    int xcont, int ycont,
    int equal_pitch,
    coordinate_t widthclass
)
{
    ucoordinate_t width = trx - blx;
    ucoordinate_t height = try - bly;
    unsigned int viaxrep, viayrep, viaxpitch, viaypitch;
    struct via_definition* entry = _get_rectangular_arrayzation(width, height, viadefs, fallback, &viaxrep, &viayrep, &viaxpitch, &viaypitch, 0, 0, xcont, ycont, equal_pitch, widthclass);
    return entry != NULL;
}

static int _check_viabltr(
    struct technology_state* techstate,
    int metal1, int metal2,
    coordinate_t blx, coordinate_t bly, coordinate_t trx, coordinate_t try,
    int xcont, int ycont,
    int equal_pitch,
    coordinate_t widthclass
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
        struct via_definition** viadefs = technology_get_via_definitions(techstate, i);
        if(!viadefs)
        {
            return 0;
        }
        ret = ret && _check_via_contact_bltr(
            viadefs,
            NULL, // don't use fallback vias
            blx, bly, trx, try,
            xcont, ycont,
            equal_pitch,
            widthclass
        );
    }
    return ret;
}

static int _via_contact_bltr(
    struct object* cell,
    struct via_definition** viadefs, struct via_definition* fallback,
    const struct generics* cutlayer,
    coordinate_t blx, coordinate_t bly, coordinate_t trx, coordinate_t try,
    coordinate_t minxspace, coordinate_t minyspace,
    int xcont, int ycont,
    int equal_pitch,
    coordinate_t widthclass,
    int makearray
)
{
    if(makearray)
    {
        ucoordinate_t width = trx - blx;
        ucoordinate_t height = try - bly;
        unsigned int viaxrep, viayrep, viaxpitch, viaypitch;
        struct via_definition* entry = _get_rectangular_arrayzation(width, height, viadefs, fallback, &viaxrep, &viayrep, &viaxpitch, &viaypitch, minxspace, minyspace, xcont, ycont, equal_pitch, widthclass);
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

static int _calculate_overlap(
    coordinate_t blx1, coordinate_t bly1, coordinate_t trx1, coordinate_t try1,
    coordinate_t blx2, coordinate_t bly2, coordinate_t trx2, coordinate_t try2,
    coordinate_t* blx, coordinate_t* bly, coordinate_t* trx, coordinate_t* try
)
{
    if((blx1 >= trx2) || (blx2 >= trx1) || (bly1 >= try2) || (bly2 >= try1))
    {
        return 0; // no overlap
    }
    *blx = blx1 >= blx2 ? blx1 : blx2;
    *bly = bly1 >= bly2 ? bly1 : bly2;
    *trx = trx1 <= trx2 ? trx1 : trx2;
    *try = try1 <= try2 ? try1 : try2;
    return 1;
}

static int _via_contact_bltr2(
    struct object* cell,
    struct via_definition** viadefs, struct via_definition* fallback,
    const struct generics* cutlayer,
    coordinate_t blx1, coordinate_t bly1, coordinate_t trx1, coordinate_t try1,
    coordinate_t blx2, coordinate_t bly2, coordinate_t trx2, coordinate_t try2,
    int makearray
)
{
    coordinate_t blx;
    coordinate_t bly;
    coordinate_t trx;
    coordinate_t try;
    int ov = _calculate_overlap(
        blx1, bly1, trx1, try1,
        blx2, bly2, trx2, try2,
        &blx, &bly, &trx, &try
    );
    if(!ov)
    {
        return 0;
    }
    if(makearray)
    {
        unsigned int viaxrep, viayrep, viaxpitch, viaypitch;
        struct via_definition* entry = _get_rectangular_arrayzation2(
            blx1, bly1, trx1, try1,
            blx2, bly2, trx2, try2,
            blx, bly, trx, try,
            viadefs, fallback,
            &viaxrep, &viayrep, &viaxpitch, &viaypitch
        );
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

struct viaarray* _make_via_array(
    ucoordinate_t regionwidth, ucoordinate_t regionheight,
    ucoordinate_t width, ucoordinate_t height,
    unsigned int xrep, unsigned yrep,
    coordinate_t xpitch, coordinate_t ypitch,
    const struct generics* layer
)
{
    struct viaarray* array = malloc(sizeof(*array));
    array->width = width;
    array->height = height;
    array->xrep = xrep;
    array->yrep = yrep;
    array->xpitch = xpitch;
    array->ypitch = ypitch;
    // FIXME: there was a weird bug with signed/non-signed integers
    // doing the computation in two steps helped, I don't really understand why
    // I tried some casts and re-ordering, but in the end I don't really have a full grasp on integer promotion
    // however, for now this works, so whatever
    coordinate_t xoffset2 = regionwidth - xrep * width - (xrep - 1) * (xpitch - width);
    array->xoffset = xoffset2 / 2;
    coordinate_t yoffset2 = regionheight - yrep * height - (yrep - 1) * (ypitch - height);
    array->yoffset = yoffset2 / 2;
    array->layer = layer;
    return array;
}

static int _calculate_viabltr(
    struct technology_state* techstate,
    int metal1, int metal2,
    coordinate_t blx, coordinate_t bly, coordinate_t trx, coordinate_t try,
    coordinate_t minxspace, coordinate_t minyspace,
    int xcont, int ycont,
    int equal_pitch,
    coordinate_t widthclass,
    struct vector* result
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
    for(int i = metal1; i < metal2; ++i)
    {
        struct via_definition** viadefs = technology_get_via_definitions(techstate, i);
        struct via_definition* fallback = technology_get_via_fallback(techstate, i);
        if(!viadefs)
        {
            return 0;
        }
        ucoordinate_t width = trx - blx;
        ucoordinate_t height = try - bly;
        unsigned int viaxrep, viayrep, viaxpitch, viaypitch;
        struct via_definition* entry = _get_rectangular_arrayzation(width, height, viadefs, fallback, &viaxrep, &viayrep, &viaxpitch, &viaypitch, minxspace, minyspace, xcont, ycont, equal_pitch, widthclass);
        if(!entry)
        {
            return 0;
        }
        const struct generics* cutlayer = generics_create_viacut(techstate, i, i + 1);
        struct viaarray* array = _make_via_array(width, height, entry->width, entry->height, viaxrep, viayrep, viaxpitch, viaypitch, cutlayer);
        vector_append(result, array);
    }
    return 1;
}

static int _viabltr(
    struct object* cell,
    struct technology_state* techstate,
    int metal1, int metal2,
    coordinate_t blx, coordinate_t bly, coordinate_t trx, coordinate_t try,
    coordinate_t minxspace, coordinate_t minyspace,
    int xcont, int ycont,
    int equal_pitch,
    int bare,
    coordinate_t widthclass
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
        struct via_definition** viadefs = technology_get_via_definitions(techstate, i);
        struct via_definition* fallback = technology_get_via_fallback(techstate, i);
        if(!viadefs)
        {
            return 0;
        }
        const struct generics* viacutlayer = generics_create_viacut(techstate, i, i + 1);
        if(!viacutlayer)
        {
            puts("no viacutlayer defined");
            return 0;
        }
        ret = ret && _via_contact_bltr(cell,
            viadefs, fallback,
            viacutlayer,
            blx, bly, trx, try,
            minxspace, minyspace,
            xcont, ycont,
            equal_pitch,
            widthclass,
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

static int _viabltr2(
    struct object* cell,
    struct technology_state* techstate,
    int metal1, int metal2,
    coordinate_t blx1, coordinate_t bly1, coordinate_t trx1, coordinate_t try1,
    coordinate_t blx2, coordinate_t bly2, coordinate_t trx2, coordinate_t try2,
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
    if(metal2 - metal1 != 1)
    {
        return 0;
    }
    int ret = 1;
    struct via_definition** viadefs = technology_get_via_definitions(techstate, metal1);
    struct via_definition* fallback = technology_get_via_fallback(techstate, metal1);
    if(!viadefs)
    {
        return 0;
    }
    const struct generics* viacutlayer = generics_create_viacut(techstate, metal1, metal2);
    if(!viacutlayer)
    {
        puts("no viacutlayer defined");
        return 0;
    }
    ret = ret && _via_contact_bltr2(cell,
        viadefs, fallback,
        viacutlayer,
        blx1, bly1, trx1, try1,
        blx2, bly2, trx2, try2,
        technology_is_create_via_arrays(techstate)
    );
    if(!bare)
    {
        _rectanglebltr(cell, generics_create_metal(techstate, metal1), blx1, bly1, trx1, try1);
        _rectanglebltr(cell, generics_create_metal(techstate, metal2), blx2, bly2, trx2, try2);
    }
    return ret;
}

int geometry_check_viabltr(struct technology_state* techstate, int metal1, int metal2, const struct point* bl, const struct point* tr, int xcont, int ycont, int equal_pitch, coordinate_t widthclass)
{
    return _check_viabltr(techstate, metal1, metal2, bl->x, bl->y, tr->x, tr->y, xcont, ycont, equal_pitch, widthclass);
}

struct vector* geometry_calculate_viabltr(
    struct technology_state* techstate,
    int metal1, int metal2,
    const struct point* bl, const struct point* tr,
    coordinate_t minxspace, coordinate_t minyspace,
    int xcont, int ycont,
    int equal_pitch,
    coordinate_t widthclass
)
{
    struct vector* result = vector_create(1, free);
    _calculate_viabltr(techstate, metal1, metal2, bl->x, bl->y, tr->x, tr->y, minxspace, minyspace, xcont, ycont, equal_pitch, widthclass, result);
    return result;
}

int geometry_viabltr(struct object* cell, struct technology_state* techstate, int metal1, int metal2, const struct point* bl, const struct point* tr, coordinate_t minxspace, coordinate_t minyspace, int xcont, int ycont, int equal_pitch, coordinate_t widthclass)
{
    int bare = 0;
    return _viabltr(cell, techstate, metal1, metal2, bl->x, bl->y, tr->x, tr->y, minxspace, minyspace, xcont, ycont, equal_pitch, bare, widthclass);
}

int geometry_viabltrov(struct object* cell, struct technology_state* techstate, int metal1, int metal2, const struct point* bl1, const struct point* tr1, const struct point* bl2, const struct point* tr2)
{
    int bare = 0;
    return _viabltr2(cell, techstate,
        metal1, metal2,
        bl1->x, bl1->y, tr1->x, tr1->y,
        bl2->x, bl2->y, tr2->x, tr2->y,
        bare
    );
}

int geometry_viabarebltr(struct object* cell, struct technology_state* techstate, int metal1, int metal2, const struct point* bl, const struct point* tr, coordinate_t minxspace, coordinate_t minyspace, int xcont, int ycont, int equal_pitch, coordinate_t widthclass)
{
    int bare = 1;
    return _viabltr(cell, techstate, metal1, metal2, bl->x, bl->y, tr->x, tr->y, minxspace, minyspace, xcont, ycont, equal_pitch, bare, widthclass);
}

int geometry_viapoints(struct object* cell, struct technology_state* techstate, int metal1, int metal2, const struct point* pt1, const struct point* pt2, coordinate_t minxspace, coordinate_t minyspace, int xcont, int ycont, int equal_pitch, coordinate_t widthclass)
{
    int bare = 0;
    if(pt1->x <= pt2->x && pt1->y <= pt2->y)
    {
        return _viabltr(cell, techstate, metal1, metal2, pt1->x, pt1->y, pt2->x, pt2->y, minxspace, minyspace, xcont, ycont, equal_pitch, bare, widthclass);
    }
    else if(pt1->x <= pt2->x && pt1->y  > pt2->y)
    {
        return _viabltr(cell, techstate, metal1, metal2, pt1->x, pt2->y, pt2->x, pt1->y, minxspace, minyspace, xcont, ycont, equal_pitch, bare, widthclass);
    }
    else if(pt1->x  > pt2->x && pt1->y <= pt2->y)
    {
        return _viabltr(cell, techstate, metal1, metal2, pt2->x, pt1->y, pt1->x, pt2->y, minxspace, minyspace, xcont, ycont, equal_pitch, bare, widthclass);
    }
    else//if(pt1->x  > pt2->x && pt1->y  > pt2->y)
    {
        return _viabltr(cell, techstate, metal1, metal2, pt2->x, pt2->y, pt1->x, pt1->y, minxspace, minyspace, xcont, ycont, equal_pitch, bare, widthclass);
    }
}

static int _contactbltr(
    struct object* cell,
    struct technology_state* techstate,
    const char* region,
    coordinate_t blx, coordinate_t bly, coordinate_t trx, coordinate_t try,
    int xcont, int ycont,
    int equal_pitch,
    coordinate_t widthclass
)
{
    struct via_definition** viadefs = technology_get_contact_definitions(techstate, region);
    struct via_definition* fallback = technology_get_contact_fallback(techstate, region);
    if(!viadefs)
    {
        return 0;
    }
    int ret = 1;
    const struct generics* cutlayer = generics_create_contact(techstate, region);
    if(!cutlayer)
    {
        fprintf(stderr, "could not create contact layer for region '%s'\n", region);
        return 0;
    }
    ret = ret && _via_contact_bltr(cell,
        viadefs, fallback,
        cutlayer,
        blx, bly, trx, try,
        0, 0, // TODO: minxspace, minyspace
        xcont, ycont,
        equal_pitch,
        widthclass,
        technology_is_create_via_arrays(techstate)
    );
    const struct generics* feollayer = NULL;
    if(strcmp(region, "gate") == 0)
    {
        feollayer = generics_create_gate(techstate);
    }
    else if(strcmp(region, "poly") == 0)
    {
        feollayer = generics_create_gate(techstate);
    }
    else if(strcmp(region, "active") == 0)
    {
        feollayer = generics_create_active(techstate);
    }
    else if(strcmp(region, "sourcedrain") == 0)
    {
        feollayer = generics_create_active(techstate);
    }
    if(feollayer)
    {
        _rectanglebltr(cell, feollayer, blx, bly, trx, try);
    }
    _rectanglebltr(cell, generics_create_metal(techstate, 1), blx, bly, trx, try);
    return ret;
}

static int _contactbltr2(
    struct object* cell,
    struct technology_state* techstate,
    const char* region,
    coordinate_t blx1, coordinate_t bly1, coordinate_t trx1, coordinate_t try1,
    coordinate_t blx2, coordinate_t bly2, coordinate_t trx2, coordinate_t try2
)
{
    struct via_definition** viadefs = technology_get_contact_definitions(techstate, region);
    struct via_definition* fallback = technology_get_contact_fallback(techstate, region);
    if(!viadefs)
    {
        return 0;
    }
    int ret = 1;
    const struct generics* cutlayer = generics_create_contact(techstate, region);
    if(!cutlayer)
    {
        fprintf(stderr, "could not create contact layer for region '%s'\n", region);
        return 0;
    }
    ret = ret && _via_contact_bltr2(cell,
        viadefs, fallback,
        cutlayer,
        blx1, bly1, trx1, try1,
        blx2, bly2, trx2, try2,
        technology_is_create_via_arrays(techstate)
    );
    _rectanglebltr(cell, generics_create_gate(techstate), blx1, bly1, trx1, try1);
    _rectanglebltr(cell, generics_create_metal(techstate, 1), blx2, bly2, trx2, try2);
    return ret;
}

static int _contactbarebltr(
    struct object* cell,
    struct technology_state* techstate,
    const char* region,
    coordinate_t blx, coordinate_t bly, coordinate_t trx, coordinate_t try,
    int xcont, int ycont,
    int equal_pitch,
    coordinate_t widthclass
)
{
    struct via_definition** viadefs = technology_get_contact_definitions(techstate, region);
    struct via_definition* fallback = technology_get_contact_fallback(techstate, region);
    if(!viadefs)
    {
        return 0;
    }
    int ret = 1;
    const struct generics* cutlayer = generics_create_contact(techstate, region);
    if(!cutlayer)
    {
        fprintf(stderr, "could not create contact layer for region '%s'\n", region);
        return 0;
    }
    ret = ret && _via_contact_bltr(cell,
        viadefs, fallback,
        cutlayer,
        blx, bly, trx, try,
        0, 0, // TODO: minxspace, minyspace
        xcont, ycont,
        equal_pitch,
        widthclass,
        technology_is_create_via_arrays(techstate)
    );
    return ret;
}

int geometry_contactbltr(
    struct object* cell,
    struct technology_state* techstate,
    const char* region,
    const struct point* bl, const struct point* tr,
    int xcont, int ycont,
    int equal_pitch,
    coordinate_t widthclass
)
{
    return _contactbltr(
        cell,
        techstate,
        region,
        bl->x, bl->y, tr->x, tr->y,
        xcont, ycont,
        equal_pitch,
        widthclass
    );
}

int geometry_contactbltrov(
    struct object* cell,
    struct technology_state* techstate,
    const char* region,
    const struct point* bl1, const struct point* tr1,
    const struct point* bl2, const struct point* tr2
)
{
    return _contactbltr2(
        cell,
        techstate,
        region,
        bl1->x, bl1->y, tr1->x, tr1->y,
        bl2->x, bl2->y, tr2->x, tr2->y
    );
}

int geometry_contactbarebltr(
    struct object* cell,
    struct technology_state* techstate,
    const char* region,
    const struct point* bl, const struct point* tr,
    int xcont, int ycont,
    int equal_pitch,
    coordinate_t widthclass
)
{
    return _contactbarebltr(
        cell,
        techstate,
        region,
        bl->x, bl->y, tr->x, tr->y,
        xcont, ycont,
        equal_pitch,
        widthclass
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
    const struct point* outerbl, const struct point* outertr,
    const struct point* innerbl, const struct point* innertr
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


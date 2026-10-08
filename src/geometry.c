#include "geometry.h"

#include <stddef.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "bltrshape.h"
#include "helpers.h"
#include "math.h"
#include "placement.h"
#include "timeperf.h"

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
    if(pts)
    {
        geometry_rectanglebltr(cell, layer, pts + 0, pts + 1);
        free(pts);
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

/*
 * FIXME: this function could simplify _get_rectangular_arrayzation2
static void _fit_via2(ucoordinate_t size1, ucoordinate_t size2, unsigned int cutsize, unsigned int space, int encl1, int encl2, int* rep_result, unsigned int* space_result)
{
    int rep1 = ((int)size1 + (int)space - 2 * encl1) / ((int)cutsize + (int)space);
    int rep2 = ((int)size2 + (int)space - 2 * encl2) / ((int)cutsize + (int)space);
    *rep_result = MIN2(rep1, rep2);
    *space_result = space;
}
*/

static void _fit_via_xy(
    coordinate_t blx1, coordinate_t bly1, coordinate_t trx1, coordinate_t try1,
    coordinate_t blx2, coordinate_t bly2, coordinate_t trx2, coordinate_t try2,
    coordinate_t blx, coordinate_t bly, coordinate_t trx, coordinate_t try,
    unsigned int cutwidth, unsigned int cutheight,
    unsigned int xspace, unsigned int yspace,
    int xencl1, int xencl2,
    int yencl1, int yencl2,
    int* xrep_result, unsigned int* xspace_result,
    int* yrep_result, unsigned int* yspace_result
)
{
    // this function workings:
    // * calculate symmetric extra extensions in all directions
    //   (the MIN2 catches cases where the line is slightly shifted to one side, asymmetrically.)
    // * calculate x/y cut repetitions for all possible cases
    //   (one enclosure in x-direction, one in y-direction)
    // * combine the four cases (1a-2a, 1a-2b etc.) by minimum, which strips off
    //   excess cuts that are actually outside of the overlap region
    // * find the pair that gives maximum cuts (minimum resistance)
    // * if a pair has a product of larger than 0, a via is possible in the overlap
    int extraxext1 = MIN2(trx1 - trx, blx - blx1);
    int extrayext1 = MIN2(try1 - try, bly - bly1);
    int extraxext2 = MIN2(trx2 - trx, blx - blx2);
    int extrayext2 = MIN2(try2 - try, bly - bly2);
    int xrep1a = ((int)(trx - blx + 2 * extraxext1) + (int)xspace - 2 * xencl1) / ((int)cutwidth + (int)xspace);
    int xrep2a = ((int)(trx - blx + 2 * extraxext2) + (int)xspace - 2 * xencl1) / ((int)cutwidth + (int)xspace);
    int xrep1b = ((int)(trx - blx + 2 * extraxext1) + (int)xspace - 2 * xencl2) / ((int)cutwidth + (int)xspace);
    int xrep2b = ((int)(trx - blx + 2 * extraxext2) + (int)xspace - 2 * xencl2) / ((int)cutwidth + (int)xspace);
    int yrep1a = ((int)(try - bly + 2 * extrayext1) + (int)yspace - 2 * yencl1) / ((int)cutheight + (int)yspace);
    int yrep2a = ((int)(try - bly + 2 * extrayext2) + (int)yspace - 2 * yencl1) / ((int)cutheight + (int)yspace);
    int yrep1b = ((int)(try - bly + 2 * extrayext1) + (int)yspace - 2 * yencl2) / ((int)cutheight + (int)yspace);
    int yrep2b = ((int)(try - bly + 2 * extrayext2) + (int)yspace - 2 * yencl2) / ((int)cutheight + (int)yspace);
    int xreps[4] = {
        // cross 'a-a'
        MIN2(xrep1a, xrep2a),
        // cross 'a-b'
        MIN2(xrep1a, xrep2b),
        // cross 'b-a'
        MIN2(xrep1b, xrep2a),
        // cross 'b-b'
        MIN2(xrep1b, xrep2b),
    };
    int yreps[4] = {
        // cross 'a-a'
        MIN2(yrep1a, yrep2a),
        // cross 'a-b'
        MIN2(yrep1a, yrep2b),
        // cross 'b-a'
        MIN2(yrep1b, yrep2a),
        // cross 'b-b'
        MIN2(yrep1b, yrep2b),
    };
    // get maximum for minimum resistance
    int xrep = xreps[0];
    int yrep = yreps[0];
    for(int i = 1; i < 4; ++i)
    {
        if(xreps[i] * yreps[i] > xrep * yrep)
        {
            xrep = xreps[i];
            yrep = yreps[i];
        }
    }
    // found via, return result
    if(xrep > 0 && yrep > 0)
    {
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
        unsigned int _emxenclosure = MAX2(entry->xenclosure1, entry->xenclosure2);
        unsigned int _emyenclosure = MAX2(entry->yenclosure1, entry->yenclosure2);
        coordinate_t _minxspace = minxspace > entry->xspace ? minxspace : entry->xspace;
        coordinate_t _minyspace = minyspace > entry->yspace ? minyspace : entry->yspace;
        if(equal_pitch)
        {
            if(entry->width == entry->height) // only square vias can be equal pitch
            {
                int space = MAX2(_minxspace, _minyspace);
                int enclosure = MAX2(_emxenclosure, _emyenclosure);
                _equal_pitch_via(regionwidth, regionheight, entry->width, space, enclosure, &_xrep, &_yrep, &_xspace, &_yspace);
            }
        }
        else
        {
            if(xcont)
            {
                _continuous_via(regionwidth, entry->width, _minxspace, _emxenclosure, &_xrep, &_xspace);
            }
            else
            {
                _fit_via(regionwidth, entry->width, _minxspace, _emxenclosure, &_xrep, &_xspace);
            }
            if(ycont)
            {
                _continuous_via(regionheight, entry->height, _minyspace, _emyenclosure, &_yrep, &_yspace);
            }
            else
            {
                _fit_via(regionheight, entry->height, _minyspace, _emyenclosure, &_yrep, &_yspace);
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

static struct via_definition* _get_rectangular_arrayzation_overlap(
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
    coordinate_t regionwidth = trx - blx;
    coordinate_t regionheight = try - bly;
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
            entry->xenclosure1, entry->xenclosure2,
            entry->yenclosure1, entry->yenclosure2,
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

static struct via_definition* _get_rectangular_arrayzation2(
    ucoordinate_t regionwidth1, ucoordinate_t regionheight1,
    ucoordinate_t regionwidth2, ucoordinate_t regionheight2,
    struct via_definition** definitions,
    struct via_definition* fallback,
    unsigned int* xrep_ptr, unsigned int* yrep_ptr,
    unsigned int* xpitch_ptr, unsigned int* ypitch_ptr,
    coordinate_t minxspace, coordinate_t minyspace,
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
        if(regionwidth1 > entry->maxwidth)
        {
            ++viadef;
            continue;
        }
        if(regionheight1 > entry->maxheight)
        {
            ++viadef;
            continue;
        }
        int _xrep1 = 0;
        unsigned int _xspace1 = 0;
        int _yrep1 = 0;
        unsigned int _yspace1 = 0;
        int _xrep2 = 0;
        unsigned int _xspace2 = 0;
        int _yrep2 = 0;
        unsigned int _yspace2 = 0;
        coordinate_t _minxspace = minxspace > entry->xspace ? minxspace : entry->xspace;
        coordinate_t _minyspace = minyspace > entry->yspace ? minyspace : entry->yspace;
        _fit_via(regionwidth1, entry->width, _minxspace, entry->xenclosure1, &_xrep1, &_xspace1);
        _fit_via(regionheight1, entry->height, _minyspace, entry->yenclosure1, &_yrep1, &_yspace1);
        _fit_via(regionwidth2, entry->width, _minxspace, entry->xenclosure2, &_xrep2, &_xspace2);
        _fit_via(regionheight2, entry->height, _minyspace, entry->yenclosure2, &_yrep2, &_yspace2);
        int _xrep;
        int _xspace;
        int _yrep;
        int _yspace;
        if(_xrep1 > _xrep2)
        {
            _xrep = _xrep2;
            _xspace = _xspace2;
        }
        else
        {
            _xrep = _xrep1;
            _xspace = _xspace1;
        }
        if(_yrep1 > _yrep2)
        {
            _yrep = _yrep2;
            _yspace = _yspace2;
        }
        else
        {
            _yrep = _yrep1;
            _yspace = _yspace1;
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

static int _check_via_contact_bltrov(
    struct via_definition** viadefs, struct via_definition* fallback,
    coordinate_t blx1, coordinate_t bly1, coordinate_t trx1, coordinate_t try1,
    coordinate_t blx2, coordinate_t bly2, coordinate_t trx2, coordinate_t try2
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
    unsigned int viaxrep, viayrep, viaxpitch, viaypitch;
    struct via_definition* entry = _get_rectangular_arrayzation_overlap(
        blx1, bly1, trx1, try1,
        blx2, bly2, trx2, try2,
        blx, bly, trx, try,
        viadefs, fallback,
        &viaxrep, &viayrep, &viaxpitch, &viaypitch
    );
    return entry != NULL;
}

static int _check_viabltrov(
    struct technology_state* techstate,
    int metal1, int metal2,
    coordinate_t blx1, coordinate_t bly1, coordinate_t trx1, coordinate_t try1,
    coordinate_t blx2, coordinate_t bly2, coordinate_t trx2, coordinate_t try2
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
        struct via_definition** viadefs = technology_get_via_definitions(techstate, metal1);
        if(!viadefs)
        {
            return 0;
        }
        ret = ret && _check_via_contact_bltrov(
            viadefs,
            NULL, // don't use fallbacks
            blx1, bly1, trx1, try1,
            blx2, bly2, trx2, try2
        );
    }
    return ret;
}

static int _via_contact_bltrov(
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
        return !makearray; // no existing overlap is not a failure with disabled via arrayzation
    }
    if(makearray)
    {
        unsigned int viaxrep, viayrep, viaxpitch, viaypitch;
        struct via_definition* entry = _get_rectangular_arrayzation_overlap(
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

static int _via_contact_bltr2(
    struct object* cell,
    struct via_definition** viadefs, struct via_definition* fallback,
    const struct generics* cutlayer,
    coordinate_t blx1, coordinate_t bly1, coordinate_t trx1, coordinate_t try1,
    coordinate_t blx2, coordinate_t bly2, coordinate_t trx2, coordinate_t try2,
    coordinate_t minxspace, coordinate_t minyspace,
    coordinate_t widthclass,
    int makearray
)
{
    if(makearray)
    {
        ucoordinate_t width1 = trx1 - blx1;
        ucoordinate_t height1 = try1 - bly1;
        ucoordinate_t width2 = trx2 - blx2;
        ucoordinate_t height2 = try2 - bly2;
        unsigned int viaxrep, viayrep, viaxpitch, viaypitch;
        struct via_definition* entry = _get_rectangular_arrayzation2(width1, height1, width2, height2, viadefs, fallback, &viaxrep, &viayrep, &viaxpitch, &viaypitch, minxspace, minyspace, widthclass);
        if(!entry)
        {
            return 0;
        }
        coordinate_t blx = MAX2(blx1, blx2);
        coordinate_t bly = MAX2(bly1, bly2);
        coordinate_t trx = MIN2(trx1, trx2);
        coordinate_t try = MIN2(try1, try2);
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
        _rectanglebltr(cell, cutlayer, blx1, bly1, trx1, try1);
        _rectanglebltr(cell, cutlayer, blx2, bly2, trx2, try2);
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

static int _calculate_viabltr2(
    struct technology_state* techstate,
    int metal1, int metal2,
    coordinate_t blx1, coordinate_t bly1, coordinate_t trx1, coordinate_t try1,
    coordinate_t blx2, coordinate_t bly2, coordinate_t trx2, coordinate_t try2,
    coordinate_t minxspace, coordinate_t minyspace,
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
    if(metal2 - metal1 != 1)
    {
        return 0;
    }
    struct via_definition** viadefs = technology_get_via_definitions(techstate, metal1);
    struct via_definition* fallback = technology_get_via_fallback(techstate, metal1);
    if(!viadefs)
    {
        return 0;
    }
    ucoordinate_t width1 = trx1 - blx1;
    ucoordinate_t height1 = try1 - bly1;
    ucoordinate_t width2 = trx2 - blx2;
    ucoordinate_t height2 = try2 - bly2;
    unsigned int viaxrep, viayrep, viaxpitch, viaypitch;
    struct via_definition* entry = _get_rectangular_arrayzation2(width1, height1, width2, height2, viadefs, fallback, &viaxrep, &viayrep, &viaxpitch, &viaypitch, minxspace, minyspace, widthclass);
    if(!entry)
    {
        return 0;
    }
    const struct generics* cutlayer = generics_create_viacut(techstate, metal1, metal2);
    struct viaarray* array = _make_via_array(MIN2(width1, width2), MIN2(height1, height2), entry->width, entry->height, viaxrep, viayrep, viaxpitch, viaypitch, cutlayer);
    vector_append(result, array);
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
            fprintf(stderr, "no viacutlayer defined from metal %d to metal %d", i, i + 1);
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
    coordinate_t minxspace, coordinate_t minyspace,
    int bare,
    coordinate_t widthclass
)
{
    (void) minxspace;
    (void) minyspace;
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
            fprintf(stderr, "no viacutlayer defined from metal %d to metal %d", i, i + 1);
            return 0;
        }
        ret = ret && _via_contact_bltr2(cell,
            viadefs, fallback,
            viacutlayer,
            blx1, bly1, trx1, try1,
            blx2, bly2, trx2, try2,
            0, 0, // TODO: minxspace, minyspace
            widthclass,
            technology_is_create_via_arrays(techstate)
        );
    }
    if(!bare)
    {
        _rectanglebltr(cell, generics_create_metal(techstate, metal1), blx1, bly1, trx1, try1);
        _rectanglebltr(cell, generics_create_metal(techstate, metal2), blx2, bly2, trx2, try2);
    }
    return ret;
}

static int _viabltrov(
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
            fprintf(stderr, "no viacutlayer defined from metal %d to metal %d\n", i, i + 1);
            return 0;
        }
        ret = ret && _via_contact_bltrov(cell,
            viadefs, fallback,
            viacutlayer,
            blx1, bly1, trx1, try1,
            blx2, bly2, trx2, try2,
            technology_is_create_via_arrays(techstate)
        );
    }
    if(!bare)
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
        if(ov)
        {
            for(int i = metal1; i <= metal2; ++i)
            {
                _rectanglebltr(cell, generics_create_metal(techstate, i), blx, bly, trx, try);
            }
        }
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

struct vector* geometry_calculate_viabltr2(
    struct technology_state* techstate,
    int metal1, int metal2,
    const struct point* bl1, const struct point* tr1,
    const struct point* bl2, const struct point* tr2,
    coordinate_t minxspace, coordinate_t minyspace,
    coordinate_t widthclass
)
{
    struct vector* result = vector_create(1, free);
    _calculate_viabltr2(techstate, metal1, metal2, bl1->x, bl1->y, tr1->x, tr1->y, bl2->x, bl2->y, tr2->x, tr2->y, minxspace, minyspace, widthclass, result);
    return result;
}

int geometry_viabltr(struct object* cell, struct technology_state* techstate, int metal1, int metal2, const struct point* bl, const struct point* tr, coordinate_t minxspace, coordinate_t minyspace, int xcont, int ycont, int equal_pitch, coordinate_t widthclass)
{
    int bare = 0;
    return _viabltr(cell, techstate, metal1, metal2, bl->x, bl->y, tr->x, tr->y, minxspace, minyspace, xcont, ycont, equal_pitch, bare, widthclass);
}

int geometry_check_viabltrov(struct technology_state* techstate, int metal1, int metal2, const struct point* bl1, const struct point* tr1, const struct point* bl2, const struct point* tr2)
{
    return _check_viabltrov(techstate, metal1, metal2, bl1->x, bl1->y, tr1->x, tr1->y, bl2->x, bl2->y, tr2->x, tr2->y);
}

int geometry_viabltrov(struct object* cell, struct technology_state* techstate, int metal1, int metal2, const struct point* bl1, const struct point* tr1, const struct point* bl2, const struct point* tr2)
{
    int bare = 0;
    return _viabltrov(cell, techstate,
        metal1, metal2,
        bl1->x, bl1->y, tr1->x, tr1->y,
        bl2->x, bl2->y, tr2->x, tr2->y,
        bare
    );
}

int geometry_viabltr2(
    struct object* cell,
    struct technology_state* techstate,
    int metal1, int metal2,
    const struct point* bl1, const struct point* tr1,
    const struct point* bl2, const struct point* tr2,
    coordinate_t widthclass
)
{
    int bare = 0;
    return _viabltr2(cell, techstate, metal1, metal2, bl1->x, bl1->y, tr1->x, tr1->y, bl2->x, bl2->y, tr2->x, tr2->y, 0, 0, bare, widthclass);
}

int geometry_viabarebltr(struct object* cell, struct technology_state* techstate, int metal1, int metal2, const struct point* bl, const struct point* tr, coordinate_t minxspace, coordinate_t minyspace, int xcont, int ycont, int equal_pitch, coordinate_t widthclass)
{
    int bare = 1;
    return _viabltr(cell, techstate, metal1, metal2, bl->x, bl->y, tr->x, tr->y, minxspace, minyspace, xcont, ycont, equal_pitch, bare, widthclass);
}

int geometry_viabarebltrov(struct object* cell, struct technology_state* techstate, int metal1, int metal2, const struct point* bl1, const struct point* tr1, const struct point* bl2, const struct point* tr2)
{
    int bare = 1;
    return _viabltrov(cell, techstate,
        metal1, metal2,
        bl1->x, bl1->y, tr1->x, tr1->y,
        bl2->x, bl2->y, tr2->x, tr2->y,
        bare
    );
}

int geometry_viabarebltr2(struct object* cell, struct technology_state* techstate, int metal1, int metal2, const struct point* bl1, const struct point* tr1, const struct point* bl2, const struct point* tr2, coordinate_t widthclass)
{
    int bare = 1;
    return _viabltr2(cell, techstate,
        metal1, metal2,
        bl1->x, bl1->y, tr1->x, tr1->y,
        bl2->x, bl2->y, tr2->x, tr2->y,
        0, 0,
        bare,
        widthclass
    );
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

static int _contactbltrov(
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
    ret = ret && _via_contact_bltrov(cell,
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

static int _contactbltr2(
    struct object* cell,
    struct technology_state* techstate,
    const char* region,
    coordinate_t blx1, coordinate_t bly1, coordinate_t trx1, coordinate_t try1,
    coordinate_t blx2, coordinate_t bly2, coordinate_t trx2, coordinate_t try2,
    coordinate_t widthclass,
    int bare
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
        0, 0, // TODO: minxspace, minyspace
        widthclass,
        technology_is_create_via_arrays(techstate)
    );
    if(!bare)
    {
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
            _rectanglebltr(cell, feollayer, blx1, bly1, trx1, try1);
        }
        _rectanglebltr(cell, generics_create_metal(techstate, 1), blx2, bly2, trx2, try2);
    }
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
    return _contactbltrov(
        cell,
        techstate,
        region,
        bl1->x, bl1->y, tr1->x, tr1->y,
        bl2->x, bl2->y, tr2->x, tr2->y
    );
}

int geometry_contactbltr2(
    struct object* cell,
    struct technology_state* techstate,
    const char* region,
    const struct point* bl1, const struct point* tr1,
    const struct point* bl2, const struct point* tr2,
    coordinate_t widthclass
)
{
    int bare = 0;
    return _contactbltr2(
        cell,
        techstate,
        region,
        bl1->x, bl1->y, tr1->x, tr1->y,
        bl2->x, bl2->y, tr2->x, tr2->y,
        widthclass,
        bare
    );
}

int geometry_contactbarebltr2(
    struct object* cell,
    struct technology_state* techstate,
    const char* region,
    const struct point* bl1, const struct point* tr1,
    const struct point* bl2, const struct point* tr2,
    coordinate_t widthclass
)
{
    int bare = 1;
    return _contactbltr2(
        cell,
        techstate,
        region,
        bl1->x, bl1->y, tr1->x, tr1->y,
        bl2->x, bl2->y, tr2->x, tr2->y,
        widthclass,
        bare
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

void geometry_rectangle_fill_in_boundary_base(
    struct object* cell,
    const struct generics* layer,
    coordinate_t width,
    coordinate_t height,
    coordinate_t xpitch,
    coordinate_t ypitch,
    coordinate_t xstartshift,
    coordinate_t ystartshift,
    struct simple_polygon* targetarea,
    struct polygon_container* excludes
)
{
    struct vector* origins = placement_calculate_origins_centered(width, height, xpitch, ypitch, xstartshift, ystartshift, targetarea, excludes);
    struct vector_const_iterator* origin_it = vector_const_iterator_create(origins);
    while(vector_const_iterator_is_valid(origin_it))
    {
        const struct point* origin = vector_const_iterator_get(origin_it);
        geometry_rectanglebltrxy(
            cell,
            layer,
            point_getx(origin) - width / 2, point_gety(origin) - height / 2,
            point_getx(origin) + width / 2, point_gety(origin) + height / 2
        );
        vector_const_iterator_next(origin_it);
    }
    vector_const_iterator_destroy(origin_it);
    vector_destroy(origins);
}

static coordinate_t _floordiv(coordinate_t a, coordinate_t b)
{
    coordinate_t q = a / b;
    if((a % b != 0) && ((a < 0) != (b < 0)))
    {
        --q;
    }
    return q;
}

static coordinate_t _ceildiv(coordinate_t a, coordinate_t b)
{
    return -_floordiv(-a, b);
}

static int _compare_coordinates(const void* a, const void* b)
{
    coordinate_t ca = *(const coordinate_t*)a;
    coordinate_t cb = *(const coordinate_t*)b;
    return (ca > cb) - (ca < cb);
}

// sort and remove duplicates, returns new number of elements
static size_t _sort_unique(coordinate_t* values, size_t num)
{
    qsort(values, num, sizeof(*values), _compare_coordinates);
    size_t k = 0;
    for(size_t i = 0; i < num; ++i)
    {
        if(k == 0 || values[i] != values[k - 1])
        {
            values[k] = values[i];
            ++k;
        }
    }
    return k;
}

// index of value in sorted unique array (value must be present)
static size_t _find_index(const coordinate_t* values, size_t num, coordinate_t value)
{
    size_t lo = 0;
    size_t hi = num;
    while(lo < hi)
    {
        size_t mid = lo + (hi - lo) / 2;
        if(values[mid] < value)
        {
            lo = mid + 1;
        }
        else
        {
            hi = mid;
        }
    }
    return lo;
}

/*
 * The fill rectangles lie on a lattice: rectangle (i, j) has its center at (xstart + i * xpitch, ystart + j * ypitch).
 * All partitioning is done in lattice index space, so regions always contain whole fill rectangles and all regions
 * share the same lattice (identical result to a single fill over the whole target area).
 */
struct fill_lattice {
    coordinate_t xstart;
    coordinate_t ystart;
    coordinate_t xpitch;
    coordinate_t ypitch;
    coordinate_t width;
    coordinate_t height;
    // extent of the area 'owned' by one lattice position (the fill rectangle plus the gap to the next one)
    coordinate_t xslot;
    coordinate_t yslot;
    // valid index range (inclusive)
    coordinate_t imin;
    coordinate_t imax;
    coordinate_t jmin;
    coordinate_t jmax;
};

// obstruction in lattice index space, half-open ranges [i0, i1) x [j0, j1)
// after compression the indices refer to the compressed coordinates
struct fill_obstruction {
    coordinate_t i0;
    coordinate_t i1;
    coordinate_t j0;
    coordinate_t j1;
};

struct fill_exclude {
    const struct simple_polygon* polygon;
    coordinate_t minx;
    coordinate_t maxx;
    coordinate_t miny;
    coordinate_t maxy;
    int is_split; // rectilinear polygons are split lazily into rectangles (once, not for every test)
    size_t numrects;
    coordinate_t* rects; // blx, bly, trx, try
};

struct fill_state {
    struct object* cell;
    const struct generics* layer;
    const struct fill_lattice* lattice;
    const struct simple_polygon* targetarea;
    int check_targetarea; // only required for non-rectangular target areas
    struct fill_exclude* excludes;
    size_t numexcludes;
    size_t* exclude_buffer;
    size_t num_empty_regions;
    size_t num_check_regions;
};

// map the closed coordinate interval [a, b] to the (inclusive) range of lattice indices whose slots touch it
static int _lattice_range(
    coordinate_t a, coordinate_t b,
    coordinate_t start, coordinate_t halfsize, coordinate_t pitch, coordinate_t slot,
    coordinate_t indexmin, coordinate_t indexmax,
    coordinate_t* i0, coordinate_t* i1
)
{
    // slot i spans [start - halfsize + i * pitch, start - halfsize + i * pitch + slot]
    coordinate_t low = start - halfsize;
    coordinate_t first = _ceildiv(a - slot - low, pitch);
    coordinate_t last = _floordiv(b - low, pitch);
    if(first < indexmin)
    {
        first = indexmin;
    }
    if(last > indexmax)
    {
        last = indexmax;
    }
    *i0 = first;
    *i1 = last;
    return first <= last;
}

static int _add_obstruction(
    const struct fill_lattice* lattice,
    coordinate_t minx, coordinate_t maxx, coordinate_t miny, coordinate_t maxy,
    struct fill_obstruction* obstruction
)
{
    coordinate_t i0, i1, j0, j1;
    if(!_lattice_range(minx, maxx, lattice->xstart, lattice->width / 2, lattice->xpitch, lattice->xslot, lattice->imin, lattice->imax, &i0, &i1))
    {
        return 0;
    }
    if(!_lattice_range(miny, maxy, lattice->ystart, lattice->height / 2, lattice->ypitch, lattice->yslot, lattice->jmin, lattice->jmax, &j0, &j1))
    {
        return 0;
    }
    obstruction->i0 = i0;
    obstruction->i1 = i1 + 1;
    obstruction->j0 = j0;
    obstruction->j1 = j1 + 1;
    return 1;
}

static int _exclude_hits_rectangle(
    struct fill_exclude* exclude,
    coordinate_t blx, coordinate_t bly, coordinate_t trx, coordinate_t try,
    coordinate_t cx, coordinate_t cy
)
{
    // same result as _is_in_excludes() in placement.c, but with a bounding box pre-check and cached rectilinear splitting
    if(trx < exclude->minx || blx > exclude->maxx || try < exclude->miny || bly > exclude->maxy)
    {
        return 0;
    }
    if(polygon_is_point_in_simple_polygon(exclude->polygon, cx, cy) == 1)
    {
        return 1;
    }
    if(!exclude->is_split)
    {
        exclude->is_split = 1;
        if(simple_polygon_is_rectilinear(exclude->polygon))
        {
            struct vector* rects = simple_polygon_split_rectilinear_polygon(exclude->polygon);
            exclude->numrects = vector_size(rects);
            exclude->rects = malloc(4 * exclude->numrects * sizeof(*exclude->rects));
            for(size_t i = 0; i < exclude->numrects; ++i)
            {
                struct bltrshape* r = vector_get(rects, i);
                exclude->rects[4 * i + 0] = bltrshape_get_blx(r);
                exclude->rects[4 * i + 1] = bltrshape_get_bly(r);
                exclude->rects[4 * i + 2] = bltrshape_get_trx(r);
                exclude->rects[4 * i + 3] = bltrshape_get_try(r);
            }
            vector_destroy(rects);
        }
    }
    if(exclude->rects)
    {
        for(size_t i = 0; i < exclude->numrects; ++i)
        {
            const coordinate_t* r = exclude->rects + 4 * i;
            // positive overlap (as bltrshape_is_intersection(..., 0))
            if(MIN2(trx, r[2]) - MAX2(blx, r[0]) > 0 && MIN2(try, r[3]) - MAX2(bly, r[1]) > 0)
            {
                return 1;
            }
        }
        return 0;
    }
    else
    {
        return simple_polygon_intersects_rectangle(exclude->polygon, blx, bly, trx, try);
    }
}

// fill a region of lattice indices [i0, i1) x [j0, j1)
static void _fill_region(struct fill_state* state, coordinate_t i0, coordinate_t i1, coordinate_t j0, coordinate_t j1, int check)
{
    const struct fill_lattice* lattice = state->lattice;
    coordinate_t hw = lattice->width / 2;
    coordinate_t hh = lattice->height / 2;
    coordinate_t x0 = lattice->xstart + i0 * lattice->xpitch;
    coordinate_t y0 = lattice->ystart + j0 * lattice->ypitch;
    if(!check)
    {
        ++state->num_empty_regions;
        // the region does not touch the target area boundary, so it is either completely inside or outside
        if(state->check_targetarea && !placement_is_in_targetarea(x0, y0, lattice->width, lattice->height, state->targetarea))
        {
            return;
        }
        for(coordinate_t i = i0; i < i1; ++i)
        {
            coordinate_t x = lattice->xstart + i * lattice->xpitch;
            for(coordinate_t j = j0; j < j1; ++j)
            {
                coordinate_t y = lattice->ystart + j * lattice->ypitch;
                geometry_rectanglebltrxy(state->cell, state->layer, x - hw, y - hh, x + hw, y + hh);
            }
        }
        return;
    }
    ++state->num_check_regions;
    // collect the excludes that can influence this region
    coordinate_t regionminx = x0 - hw;
    coordinate_t regionmaxx = lattice->xstart + (i1 - 1) * lattice->xpitch + hw;
    coordinate_t regionminy = y0 - hh;
    coordinate_t regionmaxy = lattice->ystart + (j1 - 1) * lattice->ypitch + hh;
    size_t numrelevant = 0;
    for(size_t k = 0; k < state->numexcludes; ++k)
    {
        const struct fill_exclude* exclude = &state->excludes[k];
        if(!(exclude->minx > regionmaxx || exclude->maxx < regionminx || exclude->miny > regionmaxy || exclude->maxy < regionminy))
        {
            state->exclude_buffer[numrelevant] = k;
            ++numrelevant;
        }
    }
    for(coordinate_t i = i0; i < i1; ++i)
    {
        coordinate_t x = lattice->xstart + i * lattice->xpitch;
        for(coordinate_t j = j0; j < j1; ++j)
        {
            coordinate_t y = lattice->ystart + j * lattice->ypitch;
            if(state->check_targetarea && !placement_is_in_targetarea(x, y, lattice->width, lattice->height, state->targetarea))
            {
                continue;
            }
            int excluded = 0;
            for(size_t k = 0; k < numrelevant; ++k)
            {
                if(_exclude_hits_rectangle(&state->excludes[state->exclude_buffer[k]], x - hw, y - hh, x + hw, y + hh, x, y))
                {
                    excluded = 1;
                    break;
                }
            }
            if(!excluded)
            {
                geometry_rectanglebltrxy(state->cell, state->layer, x - hw, y - hh, x + hw, y + hh);
            }
        }
    }
}

static int _compare_obstructions_by_j0(const void* a, const void* b)
{
    const struct fill_obstruction* oa = *(const struct fill_obstruction* const*)a;
    const struct fill_obstruction* ob = *(const struct fill_obstruction* const*)b;
    return (oa->j0 > ob->j0) - (oa->j0 < ob->j0);
}

static int _compare_obstructions_by_j1(const void* a, const void* b)
{
    const struct fill_obstruction* oa = *(const struct fill_obstruction* const*)a;
    const struct fill_obstruction* ob = *(const struct fill_obstruction* const*)b;
    return (oa->j1 > ob->j1) - (oa->j1 < ob->j1);
}

struct fill_span {
    size_t x0;
    size_t x1;
    size_t y0;
    int covered;
};

/*
 * Coordinate compression in lattice index space + row sweep:
 * every row of the compressed grid is split into maximal horizontal spans of equal state (covered/empty),
 * spans with identical x range and state in consecutive rows are merged vertically.
 * Finished regions are filled directly.
 */
static void _partition_and_fill(struct fill_state* state, struct fill_obstruction* obstructions, size_t numobstructions)
{
    const struct fill_lattice* lattice = state->lattice;
    coordinate_t* xbreaks = malloc((2 * numobstructions + 2) * sizeof(*xbreaks));
    coordinate_t* ybreaks = malloc((2 * numobstructions + 2) * sizeof(*ybreaks));
    xbreaks[0] = lattice->imin;
    xbreaks[1] = lattice->imax + 1;
    ybreaks[0] = lattice->jmin;
    ybreaks[1] = lattice->jmax + 1;
    for(size_t k = 0; k < numobstructions; ++k)
    {
        xbreaks[2 * k + 2] = obstructions[k].i0;
        xbreaks[2 * k + 3] = obstructions[k].i1;
        ybreaks[2 * k + 2] = obstructions[k].j0;
        ybreaks[2 * k + 3] = obstructions[k].j1;
    }
    size_t numx = _sort_unique(xbreaks, 2 * numobstructions + 2);
    size_t numy = _sort_unique(ybreaks, 2 * numobstructions + 2);

    // convert obstructions to compressed indices
    struct fill_obstruction** bystart = malloc(numobstructions * sizeof(*bystart));
    struct fill_obstruction** byend = malloc(numobstructions * sizeof(*byend));
    for(size_t k = 0; k < numobstructions; ++k)
    {
        struct fill_obstruction* o = &obstructions[k];
        o->i0 = _find_index(xbreaks, numx, o->i0);
        o->i1 = _find_index(xbreaks, numx, o->i1);
        o->j0 = _find_index(ybreaks, numy, o->j0);
        o->j1 = _find_index(ybreaks, numy, o->j1);
        bystart[k] = o;
        byend[k] = o;
    }
    qsort(bystart, numobstructions, sizeof(*bystart), _compare_obstructions_by_j0);
    qsort(byend, numobstructions, sizeof(*byend), _compare_obstructions_by_j1);

    size_t numcells = numx - 1;
    int* coverage = calloc(numcells, sizeof(*coverage));
    struct fill_span* previous = malloc(numcells * sizeof(*previous));
    struct fill_span* current = malloc(numcells * sizeof(*current));
    size_t numprevious = 0;
    size_t startindex = 0;
    size_t endindex = 0;
    for(size_t row = 0; row < numy - 1; ++row)
    {
        // update coverage
        while(endindex < numobstructions && (size_t)byend[endindex]->j1 == row)
        {
            for(coordinate_t c = byend[endindex]->i0; c < byend[endindex]->i1; ++c)
            {
                --coverage[c];
            }
            ++endindex;
        }
        while(startindex < numobstructions && (size_t)bystart[startindex]->j0 == row)
        {
            for(coordinate_t c = bystart[startindex]->i0; c < bystart[startindex]->i1; ++c)
            {
                ++coverage[c];
            }
            ++startindex;
        }
        // build spans of this row
        size_t numcurrent = 0;
        size_t c = 0;
        while(c < numcells)
        {
            int covered = coverage[c] > 0;
            size_t c1 = c + 1;
            while(c1 < numcells && (coverage[c1] > 0) == covered)
            {
                ++c1;
            }
            current[numcurrent].x0 = c;
            current[numcurrent].x1 = c1;
            current[numcurrent].y0 = row;
            current[numcurrent].covered = covered;
            ++numcurrent;
            c = c1;
        }
        // merge with spans of the previous row (both are sorted by x0), close the ones that don't continue
        size_t k = 0;
        for(size_t p = 0; p < numprevious; ++p)
        {
            while(k < numcurrent && current[k].x0 < previous[p].x0)
            {
                ++k;
            }
            if(k < numcurrent && current[k].x0 == previous[p].x0 && current[k].x1 == previous[p].x1 && current[k].covered == previous[p].covered)
            {
                current[k].y0 = previous[p].y0;
            }
            else
            {
                _fill_region(state, xbreaks[previous[p].x0], xbreaks[previous[p].x1], ybreaks[previous[p].y0], ybreaks[row], previous[p].covered);
            }
        }
        struct fill_span* tmp = previous;
        previous = current;
        current = tmp;
        numprevious = numcurrent;
    }
    for(size_t p = 0; p < numprevious; ++p)
    {
        _fill_region(state, xbreaks[previous[p].x0], xbreaks[previous[p].x1], ybreaks[previous[p].y0], ybreaks[numy - 1], previous[p].covered);
    }

    free(coverage);
    free(previous);
    free(current);
    free(bystart);
    free(byend);
    free(xbreaks);
    free(ybreaks);
}

void geometry_rectangle_fill_in_boundary(
    struct object* cell,
    const struct generics* layer,
    coordinate_t width,
    coordinate_t height,
    coordinate_t xpitch,
    coordinate_t ypitch,
    coordinate_t xstartshift,
    coordinate_t ystartshift,
    struct simple_polygon* targetarea,
    struct polygon_container* excludes
)
{
    TIMEPERF_START();
    coordinate_t xmin;
    coordinate_t xmax;
    coordinate_t ymin;
    coordinate_t ymax;
    simple_polygon_get_minmax_xy(targetarea, &xmin, &xmax, &ymin, &ymax);

    // set up fill lattice (same origins as placement_calculate_origins_centered)
    struct fill_lattice lattice;
    placement_calculate_origins_centered_start(
        width, height,
        xpitch, ypitch,
        xstartshift, ystartshift,
        xmin, xmax, ymin, ymax,
        &lattice.xstart, &lattice.ystart
    );
    lattice.xpitch = xpitch;
    lattice.ypitch = ypitch;
    lattice.width = width;
    lattice.height = height;
    lattice.xslot = MAX2(xpitch, 2 * (width / 2));
    lattice.yslot = MAX2(ypitch, 2 * (height / 2));
    // index range: all rectangles must lie within the bounding box of the target area
    // (the center strictly inside, see placement_is_in_targetarea)
    if(lattice.xstart > xmax || lattice.ystart > ymax)
    {
        TIMEPERF_STOP();
        return;
    }
    lattice.imin = 0;
    lattice.imax = (xmax - lattice.xstart) / xpitch;
    lattice.jmin = 0;
    lattice.jmax = (ymax - lattice.ystart) / ypitch;
    while(lattice.imin <= lattice.imax)
    {
        coordinate_t x = lattice.xstart + lattice.imin * xpitch;
        if(x - width / 2 >= xmin && x > xmin)
        {
            break;
        }
        ++lattice.imin;
    }
    while(lattice.imax >= lattice.imin)
    {
        coordinate_t x = lattice.xstart + lattice.imax * xpitch;
        if(x + width / 2 <= xmax && x < xmax)
        {
            break;
        }
        --lattice.imax;
    }
    while(lattice.jmin <= lattice.jmax)
    {
        coordinate_t y = lattice.ystart + lattice.jmin * ypitch;
        if(y - height / 2 >= ymin && y > ymin)
        {
            break;
        }
        ++lattice.jmin;
    }
    while(lattice.jmax >= lattice.jmin)
    {
        coordinate_t y = lattice.ystart + lattice.jmax * ypitch;
        if(y + height / 2 <= ymax && y < ymax)
        {
            break;
        }
        --lattice.jmax;
    }
    if(lattice.imin > lattice.imax || lattice.jmin > lattice.jmax)
    {
        TIMEPERF_STOP();
        return;
    }

    struct fill_state state;
    state.cell = cell;
    state.layer = layer;
    state.lattice = &lattice;
    state.targetarea = targetarea;
    state.check_targetarea = !simple_polygon_is_rectangle(targetarea);
    state.excludes = NULL;
    state.numexcludes = 0;
    state.exclude_buffer = NULL;
    state.num_empty_regions = 0;
    state.num_check_regions = 0;

    // gather excludes
    size_t maxexcludes = 0;
    if(excludes)
    {
        struct polygon_container_const_iterator* it = polygon_container_const_iterator_create(excludes);
        while(polygon_container_const_iterator_is_valid(it))
        {
            ++maxexcludes;
            polygon_container_const_iterator_next(it);
        }
        polygon_container_const_iterator_destroy(it);
    }
    size_t numtargetpoints = 0;
    {
        struct simple_polygon_const_iterator* it = simple_polygon_const_iterator_create(targetarea);
        while(simple_polygon_const_iterator_is_valid(it))
        {
            ++numtargetpoints;
            simple_polygon_const_iterator_next(it);
        }
        simple_polygon_const_iterator_destroy(it);
    }
    size_t maxobstructions = maxexcludes + (state.check_targetarea ? numtargetpoints : 0);
    struct fill_obstruction* obstructions = malloc((maxobstructions > 0 ? maxobstructions : 1) * sizeof(*obstructions));
    size_t numobstructions = 0;
    state.excludes = malloc((maxexcludes > 0 ? maxexcludes : 1) * sizeof(*state.excludes));
    state.exclude_buffer = malloc((maxexcludes > 0 ? maxexcludes : 1) * sizeof(*state.exclude_buffer));
    if(excludes)
    {
        struct polygon_container_const_iterator* it = polygon_container_const_iterator_create(excludes);
        while(polygon_container_const_iterator_is_valid(it))
        {
            const struct simple_polygon* polygon = polygon_container_const_iterator_get(it);
            struct fill_exclude* exclude = &state.excludes[state.numexcludes];
            exclude->polygon = polygon;
            simple_polygon_get_minmax_xy(polygon, &exclude->minx, &exclude->maxx, &exclude->miny, &exclude->maxy);
            exclude->is_split = 0;
            exclude->numrects = 0;
            exclude->rects = NULL;
            if(_add_obstruction(&lattice, exclude->minx, exclude->maxx, exclude->miny, exclude->maxy, &obstructions[numobstructions]))
            {
                // excludes that don't touch any valid fill position are irrelevant
                ++numobstructions;
                ++state.numexcludes;
            }
            polygon_container_const_iterator_next(it);
        }
        polygon_container_const_iterator_destroy(it);
    }
    // non-rectangular target areas: every lattice position touching the boundary must be checked
    if(state.check_targetarea)
    {
        struct simple_polygon_const_iterator* it = simple_polygon_const_iterator_create(targetarea);
        const struct point* first = NULL;
        const struct point* last = NULL;
        while(simple_polygon_const_iterator_is_valid(it))
        {
            const struct point* pt = simple_polygon_const_iterator_get(it);
            if(!first)
            {
                first = pt;
            }
            else
            {
                if(_add_obstruction(&lattice,
                    MIN2(point_getx(last), point_getx(pt)), MAX2(point_getx(last), point_getx(pt)),
                    MIN2(point_gety(last), point_gety(pt)), MAX2(point_gety(last), point_gety(pt)),
                    &obstructions[numobstructions]))
                {
                    ++numobstructions;
                }
            }
            last = pt;
            simple_polygon_const_iterator_next(it);
        }
        simple_polygon_const_iterator_destroy(it);
        if(first && last && first != last)
        {
            if(_add_obstruction(&lattice,
                MIN2(point_getx(last), point_getx(first)), MAX2(point_getx(last), point_getx(first)),
                MIN2(point_gety(last), point_gety(first)), MAX2(point_gety(last), point_gety(first)),
                &obstructions[numobstructions]))
            {
                ++numobstructions;
            }
        }
    }

    _partition_and_fill(&state, obstructions, numobstructions);
    printf("filled #%zu empty regions and #%zu exclude-aware regions\n", state.num_empty_regions, state.num_check_regions);

    for(size_t k = 0; k < state.numexcludes; ++k)
    {
        free(state.excludes[k].rects);
    }
    free(state.excludes);
    free(state.exclude_buffer);
    free(obstructions);
    TIMEPERF_STOP();
}

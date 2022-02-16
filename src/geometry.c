#include "geometry.h"

#include <stdlib.h>
#include <stddef.h>
#include <math.h>

#include "shape.h"

#define M_PI 3.14159265358979323846264338327

static void _shift_line(point_t* pt1, point_t* pt2, ucoordinate_t width, point_t** spt1, point_t** spt2)
{
    double angle = atan2(pt2->y - pt1->y, pt2->x - pt1->x) - M_PI / 2;
    coordinate_t xshift = floor(width * cos(angle) + 0.5);
    coordinate_t yshift = floor(width * sin(angle) + 0.5);
    *spt1 = point_create(pt1->x + xshift, pt1->y + yshift);
    *spt2 = point_create(pt2->x + xshift, pt2->y + yshift);
}

static point_t** _get_edge_segments(point_t** points, size_t numpoints, ucoordinate_t width)
{
    point_t** edges = calloc(4 * (numpoints - 1), sizeof(*edges));
    // start to end
    for(unsigned int i = 0; i < numpoints - 1; ++i)
    {
        _shift_line(points[i], points[i + 1], width / 2, &edges[2 * i], &edges[2 * i + 1]);
    }
    // end to start (shift in other direction)
    for(unsigned int i = numpoints - 1; i > 0; --i)
    {
        // the indexing looks funny, but it works out, trust me
        _shift_line(points[i], points[i - 1], width / 2, 
                &edges[2 * (2 * numpoints - 2 - i)], 
                &edges[2 * (2 * numpoints - 2 - i) + 1]);
    }
    return edges;
}

static int _intersection(point_t* s1, point_t* s2, point_t* c1, point_t* c2, point_t** pt)
{
    coordinate_t snum = (c2->x - c1->x) * (s1->y - c1->y) - (s1->x - c1->x) * (c2->y - c1->y);
    coordinate_t cnum = (s2->x - s1->x) * (s1->y - c1->y) - (s1->x - c1->x) * (s2->y - s1->y);
    coordinate_t den = (s2->x - s1->x) * (c2->y - c1->y) - (c2->x - c1->x) * (s2->y - s1->y);
    if(den == 0)
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
    else // if the edges don't truly overlap, we return the imaginary intersection
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
    point_t** edges = _get_edge_segments(points, numpoints, width);
    shape_t* poly = _get_path_pts(edges, 4 * (numpoints - 1), miterjoin);
    for(unsigned int i = 0; i < 4 * (numpoints - 1); ++i)
    {
        point_destroy(edges[i]);
    }
    free(edges);
    return poly;
}


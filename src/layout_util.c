#include "layout_util.h"

static int _between(coordinate_t p, coordinate_t a, coordinate_t b)
{
    return (p >= a && p <= b) || (p <= a && p >= b);
}

int layout_util_is_point_in_polygon(coordinate_t x, coordinate_t y, const struct const_vector* polygon)
{
    int inside = 0;
    size_t i = const_vector_size(polygon) - 1;
    size_t j = 0;
    while(j < const_vector_size(polygon))
    {
        const point_t* A = const_vector_get(polygon, i);
        const point_t* B = const_vector_get(polygon, j);
        // corner cases
        if(((x == point_getx(A) && y == point_gety(A)) || (x == point_getx(B) && y == point_gety(B))))
        {
            return 0;
        }
        if((point_gety(A) == point_gety(B) && y == point_gety(A) && _between(x, point_getx(A), point_getx(B))))
        {
            return 0;
        }
        if((_between(y, point_gety(A), point_gety(B)))) // if P inside the vertical range
        {
            // filter out "ray pass vertex" problem by treating the line a little lower
            if(((y == point_gety(A) && point_gety(B) >= point_gety(A)) || (y == point_gety(B) && point_gety(A) >= point_gety(B))))
            {
                goto POINT_IN_POLYGON_CONTINUE;
            }
            // calc cross product `PA X PB`, P lays on left side of AB if c > 0
            coordinate_t c = (point_getx(A) - x) * (point_gety(B) - y) - (point_getx(B) - x) * (point_gety(A) - y);
            if(c == 0)
            {
                return 0;
            }
            if((point_gety(A) < point_gety(B)) == (c > 0))
            {
                inside = !inside;
            }
        }
POINT_IN_POLYGON_CONTINUE:
        i = j;
        j = j + 1;
    }
    return inside ? 1 : -1;
}


#include "polygon.h"

#include <stdlib.h>

#include "point.h"
#include "vector.h"

struct simple_polygon {
    struct vector* points;
};

struct polygon_container {
    struct vector* simple_polygons;
};

struct simple_polygon* simple_polygon_create(void)
{
    struct simple_polygon* simple_polygon = malloc(sizeof(*simple_polygon));
    simple_polygon->points = vector_create(32, point_destroy);
    return simple_polygon;
}

struct simple_polygon* simple_polygon_create_from_rectangle(coordinate_t blx, coordinate_t bly, coordinate_t trx, coordinate_t try)
{
    struct simple_polygon* simple_polygon = malloc(sizeof(*simple_polygon));
    simple_polygon->points = vector_create(4, point_destroy);
    vector_append(simple_polygon->points, point_create(blx, bly));
    vector_append(simple_polygon->points, point_create(trx, bly));
    vector_append(simple_polygon->points, point_create(trx, try));
    vector_append(simple_polygon->points, point_create(blx, try));
    return simple_polygon;
}

struct simple_polygon* simple_polygon_copy(const struct simple_polygon* old)
{
    struct simple_polygon* new = malloc(sizeof(*new));
    new->points = vector_create(vector_size(old->points), point_destroy);
    struct vector_const_iterator* it = vector_const_iterator_create(old->points);
    while(vector_const_iterator_is_valid(it))
    {
        const struct point* pt = vector_const_iterator_get(it);
        vector_append(new->points, point_copy(pt));
        vector_const_iterator_next(it);
    }
    vector_const_iterator_destroy(it);
    return new;
}

struct polygon_container* polygon_container_create(void)
{
    struct polygon_container* polygon_container = malloc(sizeof(*polygon_container));
    polygon_container->simple_polygons = vector_create(32, simple_polygon_destroy);
    return polygon_container;
}

struct polygon_container* polygon_container_create_empty(void)
{
    struct polygon_container* polygon_container = malloc(sizeof(*polygon_container));
    polygon_container->simple_polygons = vector_create(8, simple_polygon_destroy);
    return polygon_container;
}

struct polygon_container* polygon_container_copy(const struct polygon_container* polygon_container)
{
    struct polygon_container* new = malloc(sizeof(*new));
    new->simple_polygons = vector_create(vector_size(polygon_container->simple_polygons), simple_polygon_destroy);
    struct vector_const_iterator* it = vector_const_iterator_create(polygon_container->simple_polygons);
    while(vector_const_iterator_is_valid(it))
    {
        const struct simple_polygon* simple_polygon = vector_const_iterator_get(it);
        polygon_container_add(new, simple_polygon_copy(simple_polygon));
        vector_const_iterator_next(it);
    }
    vector_const_iterator_destroy(it);
    return new;
}

void simple_polygon_destroy(void* sp)
{
    struct simple_polygon* simple_polygon = sp;
    vector_destroy(simple_polygon->points);
    free(simple_polygon);
}

void polygon_container_destroy(void* p)
{
    struct polygon_container* polygon_container = p;
    if(polygon_container->simple_polygons)
    {
        vector_destroy(polygon_container->simple_polygons);
    }
    free(polygon_container);
}

void polygon_container_add(struct polygon_container* polygon_container, struct simple_polygon* simple_polygon)
{
    vector_append(polygon_container->simple_polygons, simple_polygon);
}

int simple_polygon_is_rectangle(const struct simple_polygon* simple_polygon)
{
    if(vector_size(simple_polygon->points) == 4)
    {
        const struct point* pt1 = vector_get_const(simple_polygon->points, 0);
        const struct point* pt2 = vector_get_const(simple_polygon->points, 1);
        const struct point* pt3 = vector_get_const(simple_polygon->points, 2);
        const struct point* pt4 = vector_get_const(simple_polygon->points, 3);
        if(
            point_getx(pt1) == point_getx(pt2) &&
            point_gety(pt2) == point_gety(pt3) &&
            point_getx(pt3) == point_getx(pt4) &&
            point_gety(pt4) == point_gety(pt1)
        )
        {
            return 1;
        }
        if(
            point_gety(pt1) == point_gety(pt2) &&
            point_getx(pt2) == point_getx(pt3) &&
            point_gety(pt3) == point_gety(pt4) &&
            point_getx(pt4) == point_getx(pt1)
        )
        {
            return 1;
        }
    }
    return 0;
}

int polygon_container_is_empty(const struct polygon_container* polygon_container)
{
    return polygon_container->simple_polygons == NULL;
}

static int _between(coordinate_t p, coordinate_t a, coordinate_t b)
{
    return (p >= a && p <= b) || (p <= a && p >= b);
}

int polygon_is_point_in_simple_polygon(const struct simple_polygon* polygon, coordinate_t x, coordinate_t y)
{
    int inside = 0;
    size_t i = vector_size(polygon->points) - 1;
    size_t j = 0;
    while(j < vector_size(polygon->points))
    {
        const struct point* A = vector_get(polygon->points, i);
        const struct point* B = vector_get(polygon->points, j);
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

int polygon_is_point_in_polygon_container(const struct polygon_container* polygon_container, coordinate_t x, coordinate_t y)
{
    if(polygon_container_is_empty(polygon_container))
    {
        return -1;
    }
    int is_in_polygon = -1;
    struct polygon_container_const_iterator* it = polygon_container_const_iterator_create(polygon_container);
    while(polygon_container_const_iterator_is_valid(it))
    {
        const struct simple_polygon* simple_polygon = polygon_container_const_iterator_get(it);
        int _isp = polygon_is_point_in_simple_polygon(simple_polygon, x, y);
        if(_isp == 1)
        {
            is_in_polygon = 1;
            break;
        }
        else if(_isp == 0)
        {
            is_in_polygon = 0;
        }
        polygon_container_const_iterator_next(it);
    }
    polygon_container_const_iterator_destroy(it);
    return is_in_polygon;
}

static int _is_intersection(const struct point* s1, const struct point* s2, const struct point* c1, const struct point* c2)
{
    coordinate_t snum = (c2->x - c1->x) * (s1->y - c1->y) - (s1->x - c1->x) * (c2->y - c1->y);
    coordinate_t cnum = (s2->x - s1->x) * (s1->y - c1->y) - (s1->x - c1->x) * (s2->y - s1->y);
    coordinate_t den = (s2->x - s1->x) * (c2->y - c1->y) - (c2->x - c1->x) * (s2->y - s1->y);
    if(den == 0) // lines are parallel
    {
        return 0;
    }

    if(snum == 0 || cnum == 0 || snum == den || cnum == den) // end points touching, does not count as intersection
    {
        return 0;
    }

    // the comparison is so complex/weird to avoid division
    if(((snum < 0 && den < 0 && snum >= den) || (snum > 0 && den > 0 && snum <= den)) &&
       ((cnum < 0 && den < 0 && cnum >= den) || (cnum > 0 && den > 0 && cnum <= den)))
    {
        return 1;
    }
    else
    {
        return 0;
    }
}

static int _get_intersection(const struct point* s1, const struct point* s2, const struct point* c1, const struct point* c2, struct point** intersection)
{
    coordinate_t snum = (c2->x - c1->x) * (s1->y - c1->y) - (s1->x - c1->x) * (c2->y - c1->y);
    coordinate_t cnum = (s2->x - s1->x) * (s1->y - c1->y) - (s1->x - c1->x) * (s2->y - s1->y);
    coordinate_t den = (s2->x - s1->x) * (c2->y - c1->y) - (c2->x - c1->x) * (s2->y - s1->y);
    if(den == 0) // lines are parallel
    {
        return 0;
    }

    if(snum == 0 || cnum == 0 || snum == den || cnum == den) // end points touching, does not count as intersection
    {
        return 0;
    }

    // the comparison is so complex/weird to avoid division
    if(((snum < 0 && den < 0 && snum >= den) || (snum > 0 && den > 0 && snum <= den)) &&
       ((cnum < 0 && den < 0 && cnum >= den) || (cnum > 0 && den > 0 && cnum <= den)))
    {
        *intersection = point_create(c1->x + cnum * (c2->x - c1->x) / den, c1->y + cnum * (c2->y - c1->y) / den);
        return 1;
    }
    else
    {
        return 0;
    }
}

struct vector* simple_polygon_line_intersections(
    const struct simple_polygon* simple_polygon,
    coordinate_t x1, coordinate_t y1,
    coordinate_t x2, coordinate_t y2
)
{
    struct vector* intersections = vector_create(1, point_destroy);
    for(size_t i = 0; i < vector_size(simple_polygon->points); ++i)
    {
        struct point* cpti1 = vector_get(simple_polygon->points, i);
        struct point* cpti2 = vector_get(simple_polygon->points, (i + 1) % vector_size(simple_polygon->points));
        struct point pt1 = { .x = x1, .y = y1 };
        struct point pt2 = { .x = x2, .y = y2 };
        struct point* intersection;
        if(_get_intersection(cpti1, cpti2, &pt1, &pt2, &intersection))
        {
            vector_append(intersections, intersection);
        }
    }
    return intersections;
}

struct vector* polygon_container_line_intersections(
    const struct polygon_container* polygon_container,
    coordinate_t blx, coordinate_t bly,
    coordinate_t trx, coordinate_t try
)
{
    struct vector* intersections = vector_create(1, point_destroy);
    struct polygon_container_const_iterator* it = polygon_container_const_iterator_create(polygon_container);
    while(polygon_container_const_iterator_is_valid(it))
    {
        const struct simple_polygon* simple_polygon = polygon_container_const_iterator_get(it);
        struct vector* subintersections = simple_polygon_line_intersections(simple_polygon, blx, bly, trx, try);
        while(!vector_empty(subintersections))
        {
            vector_append(intersections, vector_disown_element(subintersections, vector_size(subintersections) - 1));
        }
        polygon_container_const_iterator_next(it);
    }
    polygon_container_const_iterator_destroy(it);
    return intersections;
}


int simple_polygon_intersects_rectangle(
    const struct simple_polygon* simple_polygon,
    coordinate_t blx, coordinate_t bly,
    coordinate_t trx, coordinate_t try
)
{
    // FIXME: this check is not sufficient, a more sophisticated polygon intersection test is required
    for(size_t i = 0; i < vector_size(simple_polygon->points); ++i)
    {
        struct point* cpti1 = vector_get(simple_polygon->points, i);
        struct point* cpti2 = vector_get(simple_polygon->points, (i + 1) % vector_size(simple_polygon->points));
        struct point bl = { .x = blx, .y = bly };
        struct point tl = { .x = blx, .y = try };
        struct point tr = { .x = trx, .y = try };
        struct point br = { .x = trx, .y = bly };
        if(
            _is_intersection(cpti1, cpti2, &bl, &tl) ||
            _is_intersection(cpti1, cpti2, &tl, &tr) ||
            _is_intersection(cpti1, cpti2, &tr, &br) ||
            _is_intersection(cpti1, cpti2, &br, &bl)
        )
        {
            return 1;
        }
    }
    return 0;
}

int polygon_container_intersects_rectangle(
    const struct polygon_container* polygon_container,
    coordinate_t blx, coordinate_t bly,
    coordinate_t trx, coordinate_t try
)
{
    int ret = 0;
    struct polygon_container_const_iterator* it = polygon_container_const_iterator_create(polygon_container);
    while(polygon_container_const_iterator_is_valid(it))
    {
        const struct simple_polygon* simple_polygon = polygon_container_const_iterator_get(it);
        if(simple_polygon_intersects_rectangle(simple_polygon, blx, bly, trx, try))
        {
            ret = 1;
            goto POLYGON_INTERSECTS_RECTANGLE_FINISHED;
        }
        polygon_container_const_iterator_next(it);
    }
POLYGON_INTERSECTS_RECTANGLE_FINISHED:
    polygon_container_const_iterator_destroy(it);
    return ret;
}

void simple_polygon_append(struct simple_polygon* simple_polygon, struct point* pt)
{
    vector_append(simple_polygon->points, pt);
}

coordinate_t simple_polygon_get_minx(const struct simple_polygon* simple_polygon)
{
    coordinate_t minx = COORDINATE_MAX;
    for(size_t i = 0; i < vector_size(simple_polygon->points); ++i)
    {
        const struct point* pt = vector_get(simple_polygon->points, i);
        if(point_getx(pt) < minx)
        {
            minx = point_getx(pt);
        }
    }
    return minx;
}


coordinate_t polygon_container_get_minx(const struct polygon_container* polygon_container)
{
    coordinate_t minx = COORDINATE_MAX;
    struct polygon_container_const_iterator* it = polygon_container_const_iterator_create(polygon_container);
    while(polygon_container_const_iterator_is_valid(it))
    {
        const struct simple_polygon* simple_polygon = polygon_container_const_iterator_get(it);
        coordinate_t _minx = simple_polygon_get_minx(simple_polygon);
        if(_minx < minx)
        {
            minx = _minx;
        }
        polygon_container_const_iterator_next(it);
    }
    return minx;
}

coordinate_t simple_polygon_get_miny(const struct simple_polygon* simple_polygon)
{
    coordinate_t miny = COORDINATE_MAX;
    for(size_t i = 0; i < vector_size(simple_polygon->points); ++i)
    {
        const struct point* pt = vector_get(simple_polygon->points, i);
        if(point_gety(pt) < miny)
        {
            miny = point_gety(pt);
        }
    }
    return miny;
}

coordinate_t polygon_container_get_miny(const struct polygon_container* polygon_container)
{
    coordinate_t miny = COORDINATE_MAX;
    struct polygon_container_const_iterator* it = polygon_container_const_iterator_create(polygon_container);
    while(polygon_container_const_iterator_is_valid(it))
    {
        const struct simple_polygon* simple_polygon = polygon_container_const_iterator_get(it);
        coordinate_t _miny = simple_polygon_get_miny(simple_polygon);
        if(_miny < miny)
        {
            miny = _miny;
        }
        polygon_container_const_iterator_next(it);
    }
    return miny;
}

coordinate_t simple_polygon_get_maxx(const struct simple_polygon* simple_polygon)
{
    coordinate_t maxx = COORDINATE_MIN;
    for(size_t i = 0; i < vector_size(simple_polygon->points); ++i)
    {
        const struct point* pt = vector_get(simple_polygon->points, i);
        if(point_getx(pt) > maxx)
        {
            maxx = point_getx(pt);
        }
    }
    return maxx;
}


coordinate_t polygon_container_get_maxx(const struct polygon_container* polygon_container)
{
    coordinate_t maxx = COORDINATE_MIN;
    struct polygon_container_const_iterator* it = polygon_container_const_iterator_create(polygon_container);
    while(polygon_container_const_iterator_is_valid(it))
    {
        const struct simple_polygon* simple_polygon = polygon_container_const_iterator_get(it);
        coordinate_t _maxx = simple_polygon_get_maxx(simple_polygon);
        if(_maxx > maxx)
        {
            maxx = _maxx;
        }
        polygon_container_const_iterator_next(it);
    }
    return maxx;
}

coordinate_t simple_polygon_get_maxy(const struct simple_polygon* simple_polygon)
{
    coordinate_t maxy = COORDINATE_MIN;
    for(size_t i = 0; i < vector_size(simple_polygon->points); ++i)
    {
        const struct point* pt = vector_get(simple_polygon->points, i);
        if(point_gety(pt) > maxy)
        {
            maxy = point_gety(pt);
        }
    }
    return maxy;
}

coordinate_t polygon_container_get_maxy(const struct polygon_container* polygon_container)
{
    coordinate_t maxy = COORDINATE_MIN;
    struct polygon_container_const_iterator* it = polygon_container_const_iterator_create(polygon_container);
    while(polygon_container_const_iterator_is_valid(it))
    {
        const struct simple_polygon* simple_polygon = polygon_container_const_iterator_get(it);
        coordinate_t _maxy = simple_polygon_get_maxy(simple_polygon);
        if(_maxy > maxy)
        {
            maxy = _maxy;
        }
        polygon_container_const_iterator_next(it);
    }
    return maxy;
}

struct simple_polygon_iterator {
    struct vector_iterator* iterator;
};

struct simple_polygon_iterator* simple_polygon_iterator_create(struct simple_polygon* simple_polygon)
{
    struct simple_polygon_iterator* it = malloc(sizeof(*it));
    it->iterator = vector_iterator_create(simple_polygon->points);
    return it;
}

int simple_polygon_iterator_is_valid(struct simple_polygon_iterator* iterator)
{
    return vector_iterator_is_valid(iterator->iterator);
}

struct point* simple_polygon_iterator_get(struct simple_polygon_iterator* iterator)
{
    return vector_iterator_get(iterator->iterator);
}

void simple_polygon_iterator_next(struct simple_polygon_iterator* iterator)
{
    vector_iterator_next(iterator->iterator);
}

void simple_polygon_iterator_destroy(struct simple_polygon_iterator* iterator)
{
    vector_iterator_destroy(iterator->iterator);
    free(iterator);
}

struct simple_polygon_const_iterator {
    struct vector_const_iterator* iterator;
};

struct simple_polygon_const_iterator* simple_polygon_const_iterator_create(const struct simple_polygon* simple_polygon)
{
    struct simple_polygon_const_iterator* it = malloc(sizeof(*it));
    it->iterator = vector_const_iterator_create(simple_polygon->points);
    return it;
}

int simple_polygon_const_iterator_is_valid(struct simple_polygon_const_iterator* iterator)
{
    return vector_const_iterator_is_valid(iterator->iterator);
}

const struct point* simple_polygon_const_iterator_get(struct simple_polygon_const_iterator* iterator)
{
    return vector_const_iterator_get(iterator->iterator);
}

void simple_polygon_const_iterator_next(struct simple_polygon_const_iterator* iterator)
{
    vector_const_iterator_next(iterator->iterator);
}

void simple_polygon_const_iterator_destroy(struct simple_polygon_const_iterator* iterator)
{
    vector_const_iterator_destroy(iterator->iterator);
    free(iterator);
}

struct polygon_container_iterator {
    struct vector_iterator* iterator;
};

struct polygon_container_iterator* polygon_container_iterator_create(struct polygon_container* polygon_container)
{
    struct polygon_container_iterator* it = malloc(sizeof(*it));
    it->iterator = vector_iterator_create(polygon_container->simple_polygons);
    return it;
}

int polygon_container_iterator_is_valid(struct polygon_container_iterator* iterator)
{
    return vector_iterator_is_valid(iterator->iterator);
}

struct simple_polygon* polygon_container_iterator_get(struct polygon_container_iterator* iterator)
{
    return vector_iterator_get(iterator->iterator);
}

void polygon_container_iterator_next(struct polygon_container_iterator* iterator)
{
    vector_iterator_next(iterator->iterator);
}

void polygon_container_iterator_destroy(struct polygon_container_iterator* iterator)
{
    vector_iterator_destroy(iterator->iterator);
    free(iterator);
}

struct polygon_container_const_iterator {
    struct vector_const_iterator* iterator;
};

struct polygon_container_const_iterator* polygon_container_const_iterator_create(const struct polygon_container* polygon_container)
{
    struct polygon_container_const_iterator* it = malloc(sizeof(*it));
    it->iterator = vector_const_iterator_create(polygon_container->simple_polygons);
    return it;
}

int polygon_container_const_iterator_is_valid(struct polygon_container_const_iterator* iterator)
{
    return vector_const_iterator_is_valid(iterator->iterator);
}

const struct simple_polygon* polygon_container_const_iterator_get(struct polygon_container_const_iterator* iterator)
{
    return vector_const_iterator_get(iterator->iterator);
}

void polygon_container_const_iterator_next(struct polygon_container_const_iterator* iterator)
{
    vector_const_iterator_next(iterator->iterator);
}

void polygon_container_const_iterator_destroy(struct polygon_container_const_iterator* iterator)
{
    vector_const_iterator_destroy(iterator->iterator);
    free(iterator);
}

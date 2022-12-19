#include <stdio.h>
#include <stdlib.h>

#include "math.h"
#include "point.h"
#include "vector.h"

/* code adapted from 'Computational Geometry in C' by Joseph O'Rourke */

struct vertex {
    size_t index;
    point_t* pt;
    int is_ear;
    struct vertex* next;
    struct vertex* prev;
};

/*---------------------------------------------------------------------
  Exclusive or: TRUE iff exactly one argument is true.
  ---------------------------------------------------------------------*/
static int _xor(int x, int y)
{
    /* The arguments are negated to ensure that they are 0/1 values. */
    /* (Idea due to Michael Baldwin.) */
    return !x ^ !y;
}

static int _area_sign(const point_t* a, const point_t* b, const point_t* c)
{
    double area2;

    area2 = (b->x - a->x) * (double)(c->y - a->y) - (c->x - a->x) * (double)(b->y - a->y);

    /* The area should be an integer. */
    if(area2 > 0.5) return 1;
    else if (area2 < -0.5) return -1;
    else return 0;
}

static int _collinear(const point_t* a, const point_t* b, const point_t* c)
{
    return _area_sign(a, b, c) == 0;
}

/*---------------------------------------------------------------------
  Returns true iff c is strictly to the left of the directed
  line through a to b.
  ---------------------------------------------------------------------*/
static int _left(const point_t* a, const point_t* b, const point_t* c)
{ 
    return _area_sign(a, b, c) > 0;
}

static int left_on(const point_t* a, const point_t* b, const point_t* c)
{
    return _area_sign(a, b, c) >= 0;
}

/*---------------------------------------------------------------------
  Returns true iff ab properly intersects cd: they share
  a point interior to both segments.  The properness of the
  intersection is ensured by using strict leftness.
  ---------------------------------------------------------------------*/
static int _intersect_prop(const point_t* a, const point_t* b, const point_t* c, const point_t* d)
{
    /* Eliminate improper cases. */
    if(_collinear(a, b, c) || _collinear(a, b, d) || _collinear(c, d, a) || _collinear(c, d, b))
    {
        return 0;
    }

    return _xor(_left(a,b,c), _left(a,b,d)) && _xor(_left(c,d,a), _left(c,d,b));
}

/*---------------------------------------------------------------------
  Returns TRUE iff point c lies on the closed segement ab.
  First checks that c is collinear with a and b.
  ---------------------------------------------------------------------*/
static int _between(const point_t* a, const point_t* b, const point_t* c)
{
    if (!_collinear(a, b, c))
    {
        return 0;
    }

    /* If ab not vertical, check betweenness on x; else on y. */
    if (a->x != b->x) 
    {
        return ((a->x <= c->x) && (c->x <= b->x)) || ((a->x >= c->x) && (c->x >= b->x));
    }
    else
    {
        return ((a->y <= c->y) && (c->y <= b->y)) || ((a->y >= c->y) && (c->y >= b->y));
    }
}

/*---------------------------------------------------------------------
  Returns TRUE iff segments ab and cd intersect, properly or improperly.
  ---------------------------------------------------------------------*/
static int _intersect(const point_t* a, const point_t* b, const point_t* c, const point_t* d)
{
    if(_intersect_prop(a, b, c, d))
        return 1;
    else if (  _between(a, b, c)
            || _between(a, b, d)
            || _between(c, d, a)
            || _between(c, d, b)
            )
        return 1;
    else return 0;
}

/*---------------------------------------------------------------------
  Returns TRUE iff (a,b) is a proper internal *or* external
  diagonal of P, *ignoring edges incident to a and b*.
  ---------------------------------------------------------------------*/
static int _diagonalie(const struct vertex* vertices, const struct vertex* a, const struct vertex* b)
{
    const struct vertex* c;
    const struct vertex* c1;

    /* For each edge (c,c1) of P */
    c = vertices;
    do {
        c1 = c->next;
        /* Skip edges incident to a or b */
        if (    (c != a) && (c1 != a)
                && (c != b) && (c1 != b)
                && _intersect(a->pt, b->pt, c->pt, c1->pt)
           )
            return 0;
        c = c->next;
    } while (c != vertices);
    return 1;
}

/*---------------------------------------------------------------------
  Returns TRUE iff the diagonal (a,b) is strictly internal to the 
  polygon in the neighborhood of the a endpoint.  
  ---------------------------------------------------------------------*/
static int _in_cone(const struct vertex* a, const struct vertex* b)
{
    /* a0, a, a1 are consecutive vertices. */
    struct vertex* a0;
    struct vertex* a1;

    a1 = a->next;
    a0 = a->prev;

    /* If a is a convex vertex ... */
    if(left_on(a->pt, a1->pt, a0->pt))
    {
        return _left(a->pt, b->pt, a0->pt) && _left(b->pt, a->pt, a1->pt);
    }
    else /* Else a is reflex: */
    {
        return !(left_on(a->pt, b->pt, a1->pt) && left_on(b->pt, a->pt, a0->pt));
    }
}

/*---------------------------------------------------------------------
  Returns TRUE iff (a,b) is a proper internal diagonal.
  ---------------------------------------------------------------------*/
static int _diagonal(const struct vertex* vertices, const struct vertex* a, const struct vertex* b)
{
    return _in_cone(a, b) && _in_cone(b, a) && _diagonalie(vertices, a, b);
}

/*---------------------------------------------------------------------
  This function initializes the data structures, and calls
  triangulate2 to clip off the ears one by one.
  ---------------------------------------------------------------------*/
static void ear_init(struct vertex* vertices)
{
    /* three consecutive vertices */
    struct vertex* v0;
    struct vertex* v1;
    struct vertex* v2;

    /* Initialize v1->ear for all vertices. */
    v1 = vertices;
    do {
        v2 = v1->next;
        v0 = v1->prev;
        v1->is_ear = _diagonal(vertices, v0, v2);
        v1 = v1->next;
    } while (v1 != vertices);

}

static void _add_triangle(const struct vertex* a, const struct vertex* b, const struct vertex* c, struct vector* result)
{
    vector_append(result, point_copy(a->pt));
    vector_append(result, point_copy(b->pt));
    vector_append(result, point_copy(c->pt));
}

static int _triangulate(struct vertex** vertices, size_t nvertices, struct vector* result)
{
    struct vertex* v0;
    struct vertex* v1;
    struct vertex* v2;
    struct vertex* v3;
    struct vertex* v4;
    int earfound;

    ear_init(*vertices);
    /* Each step of outer loop removes one ear. */
    while (nvertices > 3) {     
        /* Inner loop searches for an ear. */
        v2 = *vertices;
        earfound = 0;
        do {
            if (v2->is_ear) {
                earfound = 1;
                /* Ear found. Fill variables. */
                v0 = v2->prev->prev;
                v1 = v2->prev;
                v3 = v2->next;
                v4 = v2->next->next;

                /* (v1,v3) is a diagonal */
                _add_triangle(v1, v2, v3, result);

                /* Update earity of diagonal endpoints */
                v1->is_ear = _diagonal(*vertices, v0, v3);
                v3->is_ear = _diagonal(*vertices, v1, v4);

                /* Cut off the ear v2 */
                v2->prev->next = v2->next;
                v2->next->prev = v2->prev;
                v2->next = NULL;
                v2->prev = NULL;
                *vertices = v3; /* In case the head was v2. */
                --nvertices;

                point_destroy(v2->pt);
                free(v2);
                break;   /* out of inner loop; resume outer loop */
            } /* end if ear found */
            v2 = v2->next;
        } while (v2 != *vertices);

        if(!earfound)
        {
            return 0;
        }
    }
    // FIXME: the upper loop could probably also cut off the last ear, leaving no vertices
    // then this call would not be needed
    _add_triangle(*vertices, (*vertices)->next, (*vertices)->next->next, result);
    return 1;
}

struct vector* geometry_triangulate_polygon(const struct vector* points)
{
    struct vertex* vertices = NULL;
    size_t numvertices = 0;
    struct vector_const_iterator* it = vector_const_iterator_create(points);
    while(vector_const_iterator_is_valid(it))
    {
        const point_t* pt = vector_const_iterator_get(it);
        struct vertex* v = malloc(sizeof(*v));
        v->pt = point_copy(pt);
        v->index = numvertices;
        if(vertices)
        {
            v->next = vertices;
            v->prev = vertices->prev;
            vertices->prev = v;
            v->prev->next = v;
        }
        else
        {
           vertices = v;
           vertices->next = v;
           vertices->prev = v;
        }
        ++numvertices;
        vector_const_iterator_next(it);
    }
    vector_const_iterator_destroy(it);

    struct vector* result = vector_create(32, point_destroy);
    int ret = _triangulate(&vertices, numvertices, result);

    // destroy remaining vertices
    struct vertex* v = vertices;
    do {
        if(v->next == v)
        {
            point_destroy(v->pt);
            free(v);
            v = NULL;
        }
        else
        {
            struct vertex* tmp = v;
            v = v->next;
            tmp->prev->next = tmp->next;
            tmp->next->prev = tmp->prev;
            point_destroy(tmp->pt);
            free(tmp);
        }
    } while(v);

    if(!ret)
    {
        vector_destroy(result);
        return NULL;
    }
    return result;
}

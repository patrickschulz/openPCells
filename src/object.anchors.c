#include "object.h"

#include <stdlib.h>

#define OPC_OBJECT_IMPLEMENTATION
#include "object.util.h"
#undef OPC_OBJECT_IMPLEMENTATION

struct anchor {
    union {
        /* regular anchors have one point, area anchors two */
        struct point* where;
        struct {
            struct point* bl;
            struct point* tr;
        } area ;
    } content;
    int is_area;
};

struct anchor* objectanchor_create_regular(coordinate_t x, coordinate_t y)
{
    struct anchor* anchor = malloc(sizeof(*anchor));
    anchor->is_area = 0;
    anchor->content.where = point_create(x, y);
    return anchor;
}

struct anchor* objectanchor_create_area_bltr(coordinate_t blx, coordinate_t bly, coordinate_t trx, coordinate_t try)
{
    struct anchor* anchor = malloc(sizeof(*anchor));
    anchor->is_area = 1;
    anchor->content.area.bl = point_create(blx, bly);
    anchor->content.area.tr = point_create(trx, try);
    return anchor;
}

struct anchor* objectanchor_create_area_points(coordinate_t blx, coordinate_t bly, coordinate_t trx, coordinate_t try)
{
    struct anchor* anchor = malloc(sizeof(*anchor));
    anchor->is_area = 1;
    objectutil_fix_rectangle_order_xy(&blx, &bly, &trx, &try);
    anchor->content.area.bl = point_create(blx, bly);
    anchor->content.area.tr = point_create(trx, try);
    return anchor;
}

struct anchor* objectanchor_copy(const struct anchor* anchor)
{
    struct anchor* new = malloc(sizeof(*new));
    new->is_area = anchor->is_area;
    if(anchor->is_area)
    {
        new->content.area.bl = point_copy(anchor->content.area.bl);
        new->content.area.tr = point_copy(anchor->content.area.tr);
    }
    else
    {
        new->content.where = point_copy(anchor->content.where);
    }
    return new;
}

void objectanchor_destroy(void* v)
{
    struct anchor* anchor = v;
    if(anchor->is_area)
    {
        point_destroy(anchor->content.area.bl);
        point_destroy(anchor->content.area.tr);
    }
    else
    {
        point_destroy(anchor->content.where);
    }
    free(anchor);
}

int objectanchor_is_area(const struct anchor* anchor)
{
    return anchor->is_area;
}

void objectanchor_apply_tmatrix(struct anchor* anchor, const struct transformationmatrix* trans)
{
    if(objectanchor_is_area(anchor))
    {
        transformationmatrix_apply_transformation_xy(trans, &anchor->content.area.bl->x, &anchor->content.area.bl->y);
        transformationmatrix_apply_transformation_xy(trans, &anchor->content.area.tr->x, &anchor->content.area.tr->y);
        objectutil_fix_rectangle_order(anchor->content.area.bl, anchor->content.area.tr);
    }
    else
    {
        transformationmatrix_apply_transformation_xy(trans, &anchor->content.where->x, &anchor->content.where->y);
    }
}

void objectanchor_get_point(const struct anchor* anchor, struct point* pt)
{
    pt->x = anchor->content.where->x;
    pt->y = anchor->content.where->y;
}

void objectanchor_get_area_points(const struct anchor* anchor, struct point pts[2])
{
    pts[0].x = anchor->content.area.bl->x;
    pts[0].y = anchor->content.area.bl->y;
    pts[1].x = anchor->content.area.tr->x;
    pts[1].y = anchor->content.area.tr->y;
}

int objectanchor_call(const struct anchor* anchor, const char* name, struct transformationmatrix* matrix, anchor_action action, struct generic_arg* extraargs)
{
    struct point pts[2];
    if(anchor->is_area)
    {
        objectanchor_get_area_points(anchor, pts);
        transformationmatrix_apply_transformation(matrix, pts + 0);
        transformationmatrix_apply_transformation(matrix, pts + 1);
        objectutil_fix_rectangle_order(pts + 0, pts + 1);
    }
    else
    {
        objectanchor_get_point(anchor, pts);
        transformationmatrix_apply_transformation(matrix, pts + 0);
    }
    int ret = action(name, pts, anchor->is_area, extraargs);
    return ret;
}


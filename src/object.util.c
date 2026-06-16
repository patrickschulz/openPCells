#define OPC_OBJECT_IMPLEMENTATION
#include "object.util.h"
#undef OPC_OBJECT_IMPLEMENTATION

static void _swap_coordinates(coordinate_t* c1, coordinate_t* c2)
{
    coordinate_t tmp = *c1;
    *c1 = *c2;
    *c2 = tmp;
}

void objectutil_fix_rectangle_order(struct point* bl, struct point* tr)
{
    if(bl->x > tr->x)
    {
        _swap_coordinates(&bl->x, &tr->x);
    }
    if(bl->y > tr->y)
    {
        _swap_coordinates(&bl->y, &tr->y);
    }
}

void objectutil_fix_rectangle_order_xy(coordinate_t* blx, coordinate_t* bly, coordinate_t* trx, coordinate_t* try)
{
    if(*blx > *trx)
    {
        _swap_coordinates(blx, trx);
    }
    if(*bly > *try)
    {
        _swap_coordinates(bly, try);
    }
}

void objectutil_transform_to_global_coordinates_xy(const struct transformationmatrix* trans, coordinate_t* x, coordinate_t* y)
{
    transformationmatrix_apply_transformation_xy(trans, x, y);
}

void objectutil_transform_to_global_coordinates_pt(const struct transformationmatrix* trans, struct point* pt)
{
    transformationmatrix_apply_transformation(trans, pt);
}

void objectutil_transform_to_local_coordinates_xy(const struct transformationmatrix* trans, coordinate_t* x, coordinate_t* y)
{
    transformationmatrix_apply_inverse_transformation_xy(trans, x, y);
}

void objectutil_transform_to_local_coordinates_pt(const struct transformationmatrix* trans, struct point* pt)
{
    transformationmatrix_apply_inverse_transformation(trans, pt);
}

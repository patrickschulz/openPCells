#include "transformationmatrix.h"

#include <stdlib.h>

#include "point.h"

#define M(idx) matrix->coefficients[idx]

transformationmatrix_t* transformationmatrix_create()
{
    transformationmatrix_t* matrix = malloc(sizeof(*matrix));
    return matrix;
}

void transformationmatrix_destroy(transformationmatrix_t* matrix)
{
    free(matrix);
}

void transformationmatrix_identity(transformationmatrix_t* matrix)
{
    M(0) = 1;
    M(1) = 0;
    M(2) = 0;
    M(3) = 0;
    M(4) = 1;
    M(5) = 0;
}

transformationmatrix_t* transformationmatrix_chain(const transformationmatrix_t* lhs, const transformationmatrix_t* rhs)
{
    transformationmatrix_t* matrix = transformationmatrix_create();
    M(0) = lhs->coefficients[0] * rhs->coefficients[0] + lhs->coefficients[1] * rhs->coefficients[3];
    M(1) = lhs->coefficients[0] * rhs->coefficients[1] + lhs->coefficients[1] * rhs->coefficients[4];
    M(2) = lhs->coefficients[0] * rhs->coefficients[2] + lhs->coefficients[1] * rhs->coefficients[5] + lhs->coefficients[2];
    M(3) = lhs->coefficients[3] * rhs->coefficients[0] + lhs->coefficients[4] * rhs->coefficients[3];
    M(4) = lhs->coefficients[3] * rhs->coefficients[1] + lhs->coefficients[4] * rhs->coefficients[4];
    M(5) = lhs->coefficients[3] * rhs->coefficients[2] + lhs->coefficients[4] * rhs->coefficients[5] + lhs->coefficients[5];
    return matrix;
}

transformationmatrix_t* transformationmatrix_copy(const transformationmatrix_t* old)
{
    transformationmatrix_t* matrix = transformationmatrix_create();
    M(0) = old->coefficients[0];
    M(1) = old->coefficients[1];
    M(2) = old->coefficients[2];
    M(3) = old->coefficients[3];
    M(4) = old->coefficients[4];
    M(5) = old->coefficients[5];
    return matrix;
}

transformationmatrix_t* transformationmatrix_invert(const transformationmatrix_t* old)
{
    transformationmatrix_t* matrix = transformationmatrix_create();
    coordinate_t c0 = old->coefficients[0];
    coordinate_t c1 = old->coefficients[1];
    coordinate_t c2 = old->coefficients[2];
    coordinate_t c3 = old->coefficients[3];
    coordinate_t c4 = old->coefficients[4];
    coordinate_t c5 = old->coefficients[5];
    coordinate_t det = old->coefficients[0] * old->coefficients[4] - old->coefficients[1] * old->coefficients[3];
    M(0) = c4 / det;
    M(1) = -c1 / det;
    M(2) = (c1 * c5 - c2 * c4) / det;
    M(3) = -c3 / det;
    M(4) = c0 / det;
    M(5) = (-c0 * c5 - c2 * c3) / det;
    return matrix;
}

void transformationmatrix_move_to(transformationmatrix_t* matrix, coordinate_t x, coordinate_t y)
{
    M(2) = x;
    M(5) = y;
}

void transformationmatrix_move_x_to(transformationmatrix_t* matrix, coordinate_t x)
{
    M(2) = x;
}

void transformationmatrix_move_y_to(transformationmatrix_t* matrix, coordinate_t y)
{
    M(5) = y;
}

void transformationmatrix_translate(transformationmatrix_t* matrix, coordinate_t dx, coordinate_t dy)
{
    M(2) += dx;
    M(5) += dy;
}

void transformationmatrix_translate_x(transformationmatrix_t* matrix, coordinate_t dx)
{
    M(2) += dx;
}

void transformationmatrix_translate_y(transformationmatrix_t* matrix, coordinate_t dy)
{
    M(5) += dy;
}

void transformationmatrix_scale(transformationmatrix_t* matrix, double factor)
{
    M(0) *= factor;
    M(1) *= factor;
    M(2) *= factor;
    M(3) *= factor;
    M(4) *= factor;
    M(5) *= factor;
}

void transformationmatrix_mirror_x(transformationmatrix_t* matrix)
{
    M(3) = -M(3);
    M(4) = -M(4);
    M(5) = -M(5);
}

void transformationmatrix_mirror_y(transformationmatrix_t* matrix)
{
    M(0) = -M(0);
    M(1) = -M(1);
    M(2) = -M(2);
}

void transformationmatrix_mirror_origin(transformationmatrix_t* matrix)
{
    M(0) = -M(0);
    M(1) = -M(1);
    M(2) = -M(2);
    M(3) = -M(3);
    M(4) = -M(4);
    M(5) = -M(5);
}

void transformationmatrix_rotate_90_right(transformationmatrix_t* matrix)
{
    coordinate_t tmp = M(3);
    M(3) = -M(0);
    M(0) = tmp;
    tmp = M(4);
    M(4) = -M(1);
    M(1) = tmp;
    tmp = M(5);
    M(5) = -M(2);
    M(2) = tmp;
}

void transformationmatrix_rotate_90_left(transformationmatrix_t* matrix)
{
    coordinate_t tmp = M(0);
    M(0) = -M(3);
    M(3) = tmp;
    tmp = M(1);
    M(1) = -M(4);
    M(4) = tmp;
    tmp = M(2);
    M(2) = -M(5);
    M(5) = tmp;
}

void transformationmatrix_apply_transformation(const transformationmatrix_t* matrix, point_t* pt)
{
    coordinate_t x = pt->x;
    coordinate_t y = pt->y;
    pt->x = M(0) * x + M(1) * y + M(2);
    pt->y = M(3) * x + M(4) * y + M(5);
}

void transformationmatrix_apply_transformation_xy(const transformationmatrix_t* matrix, coordinate_t* x, coordinate_t* y)
{
    coordinate_t xx = *x;
    coordinate_t yy = *y;
    *x = M(0) * xx + M(1) * yy + M(2);
    *y = M(3) * xx + M(4) * yy + M(5);
}

void transformationmatrix_apply_inverse_transformation(const transformationmatrix_t* matrix, point_t* pt)
{
    coordinate_t x = pt->x;
    coordinate_t y = pt->y;
    coordinate_t det = M(4) * M(4) - M(1) * M(3);
    pt->x = ( M(4) * x + -M(1) * y + ( M(1) * M(5) - M(2) * M(4))) / det;
    pt->y = (-M(3) * x +  M(0) * y + (-M(0) * M(5) - M(2) * M(3))) / det;
}


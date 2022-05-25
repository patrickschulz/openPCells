#include "transformationmatrix.h"

#include <stdlib.h>

#include "point.h"

#define M(matrix, idx) matrix->coefficients[idx]

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
    M(matrix, 0) = 1;
    M(matrix, 1) = 0;
    M(matrix, 2) = 0;
    M(matrix, 3) = 0;
    M(matrix, 4) = 1;
    M(matrix, 5) = 0;
}

transformationmatrix_t* transformationmatrix_chain(const transformationmatrix_t* lhs, const transformationmatrix_t* rhs)
{
    transformationmatrix_t* matrix = transformationmatrix_create();
    M(matrix, 0) = M(lhs, 0) * M(rhs, 0) + M(lhs, 1) * M(rhs, 3);
    M(matrix, 1) = M(lhs, 0) * M(rhs, 1) + M(lhs, 1) * M(rhs, 4);
    M(matrix, 2) = M(lhs, 0) * M(rhs, 2) + M(lhs, 1) * M(rhs, 5) + M(lhs, 2);
    M(matrix, 3) = M(lhs, 3) * M(rhs, 0) + M(lhs, 4) * M(rhs, 3);
    M(matrix, 4) = M(lhs, 3) * M(rhs, 1) + M(lhs, 4) * M(rhs, 4);
    M(matrix, 5) = M(lhs, 3) * M(rhs, 2) + M(lhs, 4) * M(rhs, 5) + M(lhs, 5);
    return matrix;
}

transformationmatrix_t* transformationmatrix_copy(const transformationmatrix_t* old)
{
    transformationmatrix_t* matrix = transformationmatrix_create();
    M(matrix, 0) = M(old, 0);
    M(matrix, 1) = M(old, 1);
    M(matrix, 2) = M(old, 2);
    M(matrix, 3) = M(old, 3);
    M(matrix, 4) = M(old, 4);
    M(matrix, 5) = M(old, 5);
    return matrix;
}

transformationmatrix_t* transformationmatrix_invert(const transformationmatrix_t* old)
{
    transformationmatrix_t* matrix = transformationmatrix_create();
    coordinate_t c0 = M(old, 0);
    coordinate_t c1 = M(old, 1);
    coordinate_t c2 = M(old, 2);
    coordinate_t c3 = M(old, 3);
    coordinate_t c4 = M(old, 4);
    coordinate_t c5 = M(old, 5);
    coordinate_t det = M(old, 0) * M(old, 4) - M(old, 1) * M(old, 3);
    M(matrix, 0) = c4 / det;
    M(matrix, 1) = -c1 / det;
    M(matrix, 2) = (c1 * c5 - c2 * c4) / det;
    M(matrix, 3) = -c3 / det;
    M(matrix, 4) = c0 / det;
    M(matrix, 5) = (-c0 * c5 - c2 * c3) / det;
    return matrix;
}

void transformationmatrix_move_to(transformationmatrix_t* matrix, coordinate_t x, coordinate_t y)
{
    M(matrix, 2) = x;
    M(matrix, 5) = y;
}

void transformationmatrix_move_x_to(transformationmatrix_t* matrix, coordinate_t x)
{
    M(matrix, 2) = x;
}

void transformationmatrix_move_y_to(transformationmatrix_t* matrix, coordinate_t y)
{
    M(matrix, 5) = y;
}

void transformationmatrix_translate(transformationmatrix_t* matrix, coordinate_t dx, coordinate_t dy)
{
    M(matrix, 2) += dx;
    M(matrix, 5) += dy;
}

void transformationmatrix_translate_x(transformationmatrix_t* matrix, coordinate_t dx)
{
    M(matrix, 2) += dx;
}

void transformationmatrix_translate_y(transformationmatrix_t* matrix, coordinate_t dy)
{
    M(matrix, 5) += dy;
}

void transformationmatrix_scale(transformationmatrix_t* matrix, double factor)
{
    M(matrix, 0) *= factor;
    M(matrix, 1) *= factor;
    M(matrix, 2) *= factor;
    M(matrix, 3) *= factor;
    M(matrix, 4) *= factor;
    M(matrix, 5) *= factor;
}

void transformationmatrix_mirror_x(transformationmatrix_t* matrix)
{
    M(matrix, 3) = -M(matrix, 3);
    M(matrix, 4) = -M(matrix, 4);
    M(matrix, 5) = -M(matrix, 5);
}

void transformationmatrix_mirror_y(transformationmatrix_t* matrix)
{
    M(matrix, 0) = -M(matrix, 0);
    M(matrix, 1) = -M(matrix, 1);
    M(matrix, 2) = -M(matrix, 2);
}

void transformationmatrix_mirror_origin(transformationmatrix_t* matrix)
{
    M(matrix, 0) = -M(matrix, 0);
    M(matrix, 1) = -M(matrix, 1);
    M(matrix, 2) = -M(matrix, 2);
    M(matrix, 3) = -M(matrix, 3);
    M(matrix, 4) = -M(matrix, 4);
    M(matrix, 5) = -M(matrix, 5);
}

void transformationmatrix_rotate_90_right(transformationmatrix_t* matrix)
{
    coordinate_t tmp = M(matrix, 3);
    M(matrix, 3) = -M(matrix, 0);
    M(matrix, 0) = tmp;
    tmp = M(matrix, 4);
    M(matrix, 4) = -M(matrix, 1);
    M(matrix, 1) = tmp;
    tmp = M(matrix, 5);
    M(matrix, 5) = -M(matrix, 2);
    M(matrix, 2) = tmp;
}

void transformationmatrix_rotate_90_left(transformationmatrix_t* matrix)
{
    coordinate_t tmp = M(matrix, 0);
    M(matrix, 0) = -M(matrix, 3);
    M(matrix, 3) = tmp;
    tmp = M(matrix, 1);
    M(matrix, 1) = -M(matrix, 4);
    M(matrix, 4) = tmp;
    tmp = M(matrix, 2);
    M(matrix, 2) = -M(matrix, 5);
    M(matrix, 5) = tmp;
}

void transformationmatrix_apply_transformation(const transformationmatrix_t* matrix, point_t* pt)
{
    coordinate_t x = pt->x;
    coordinate_t y = pt->y;
    pt->x = M(matrix, 0) * x + M(matrix, 1) * y + M(matrix, 2);
    pt->y = M(matrix, 3) * x + M(matrix, 4) * y + M(matrix, 5);
}

void transformationmatrix_apply_transformation_xy(const transformationmatrix_t* matrix, coordinate_t* x, coordinate_t* y)
{
    coordinate_t xx = *x;
    coordinate_t yy = *y;
    *x = M(matrix, 0) * xx + M(matrix, 1) * yy + M(matrix, 2);
    *y = M(matrix, 3) * xx + M(matrix, 4) * yy + M(matrix, 5);
}

void transformationmatrix_apply_inverse_transformation(const transformationmatrix_t* matrix, point_t* pt)
{
    coordinate_t x = pt->x;
    coordinate_t y = pt->y;
    coordinate_t det = M(matrix, 4) * M(matrix, 4) - M(matrix, 1) * M(matrix, 3);
    pt->x = ( M(matrix, 4) * x + -M(matrix, 1) * y + ( M(matrix, 1) * M(matrix, 5) - M(matrix, 2) * M(matrix, 4))) / det;
    pt->y = (-M(matrix, 3) * x +  M(matrix, 0) * y + (-M(matrix, 0) * M(matrix, 5) - M(matrix, 2) * M(matrix, 3))) / det;
}


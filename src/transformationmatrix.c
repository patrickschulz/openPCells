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
    matrix->coefficients[0] = 1;
    matrix->coefficients[1] = 0;
    matrix->coefficients[2] = 0;
    matrix->coefficients[3] = 0;
    matrix->coefficients[4] = 1;
    matrix->coefficients[5] = 0;
}

transformationmatrix_t* transformationmatrix_chain(transformationmatrix_t* lhs, transformationmatrix_t* rhs)
{
    transformationmatrix_t* matrix = transformationmatrix_create();
    matrix->coefficients[0] = lhs->coefficients[0] * rhs->coefficients[0] + lhs->coefficients[1] * rhs->coefficients[3];
    matrix->coefficients[1] = lhs->coefficients[0] * rhs->coefficients[1] + lhs->coefficients[1] * rhs->coefficients[4];
    matrix->coefficients[2] = lhs->coefficients[0] * rhs->coefficients[2] + lhs->coefficients[1] * rhs->coefficients[5] + lhs->coefficients[2];
    matrix->coefficients[3] = lhs->coefficients[3] * rhs->coefficients[0] + lhs->coefficients[4] * rhs->coefficients[3];
    matrix->coefficients[4] = lhs->coefficients[3] * rhs->coefficients[1] + lhs->coefficients[4] * rhs->coefficients[4];
    matrix->coefficients[5] = lhs->coefficients[3] * rhs->coefficients[2] + lhs->coefficients[4] * rhs->coefficients[5] + lhs->coefficients[5];
    return matrix;
}

transformationmatrix_t* transformationmatrix_copy(transformationmatrix_t* old)
{
    transformationmatrix_t* matrix = transformationmatrix_create();
    matrix->coefficients[0] = old->coefficients[0];
    matrix->coefficients[1] = old->coefficients[1];
    matrix->coefficients[2] = old->coefficients[2];
    matrix->coefficients[3] = old->coefficients[3];
    matrix->coefficients[4] = old->coefficients[4];
    matrix->coefficients[5] = old->coefficients[5];
    return matrix;
}

void transformationmatrix_move_to(transformationmatrix_t* matrix, coordinate_t x, coordinate_t y)
{
    matrix->coefficients[2] = x;
    matrix->coefficients[5] = y;
}

void transformationmatrix_move_x_to(transformationmatrix_t* matrix, coordinate_t x)
{
    matrix->coefficients[2] = x;
}

void transformationmatrix_move_y_to(transformationmatrix_t* matrix, coordinate_t y)
{
    matrix->coefficients[5] = y;
}

void transformationmatrix_translate(transformationmatrix_t* matrix, coordinate_t dx, coordinate_t dy)
{
    matrix->coefficients[2] = matrix->coefficients[2] + dx;
    matrix->coefficients[5] = matrix->coefficients[5] + dy;
}

void transformationmatrix_translate_x(transformationmatrix_t* matrix, coordinate_t dx)
{
    matrix->coefficients[2] = matrix->coefficients[2] + dx;
}

void transformationmatrix_translate_y(transformationmatrix_t* matrix, coordinate_t dy)
{
    matrix->coefficients[5] = matrix->coefficients[5] + dy;
}

void transformationmatrix_scale(transformationmatrix_t* matrix, double factor)
{
    matrix->coefficients[0] *= factor;
    matrix->coefficients[1] *= factor;
    matrix->coefficients[2] *= factor;
    matrix->coefficients[3] *= factor;
    matrix->coefficients[4] *= factor;
    matrix->coefficients[5] *= factor;
}

void transformationmatrix_mirror_x(transformationmatrix_t* matrix)
{
    matrix->coefficients[0] = -matrix->coefficients[0];
    matrix->coefficients[1] = -matrix->coefficients[1];
    matrix->coefficients[2] = -matrix->coefficients[2];
}

void transformationmatrix_mirror_y(transformationmatrix_t* matrix)
{
    matrix->coefficients[3] = -matrix->coefficients[3];
    matrix->coefficients[4] = -matrix->coefficients[4];
    matrix->coefficients[5] = -matrix->coefficients[5];
}

void transformationmatrix_mirror_origin(transformationmatrix_t* matrix)
{
    matrix->coefficients[0] = -matrix->coefficients[0];
    matrix->coefficients[1] = -matrix->coefficients[1];
    matrix->coefficients[2] = -matrix->coefficients[2];
    matrix->coefficients[3] = -matrix->coefficients[3];
    matrix->coefficients[4] = -matrix->coefficients[4];
    matrix->coefficients[5] = -matrix->coefficients[5];
}

void transformationmatrix_rotate_90_right(transformationmatrix_t* matrix)
{
    coordinate_t tmp = matrix->coefficients[3];
    matrix->coefficients[3] = -matrix->coefficients[0];
    matrix->coefficients[0] = tmp;
    tmp = matrix->coefficients[4];
    matrix->coefficients[4] = -matrix->coefficients[1];
    matrix->coefficients[1] = tmp;
    tmp = matrix->coefficients[5];
    matrix->coefficients[5] = -matrix->coefficients[2];
    matrix->coefficients[2] = tmp;
}

void transformationmatrix_rotate_90_left(transformationmatrix_t* matrix)
{
    coordinate_t tmp = matrix->coefficients[0];
    matrix->coefficients[0] = -matrix->coefficients[3];
    matrix->coefficients[3] = tmp;
    tmp = matrix->coefficients[1];
    matrix->coefficients[1] = -matrix->coefficients[4];
    matrix->coefficients[4] = tmp;
    tmp = matrix->coefficients[2];
    matrix->coefficients[2] = -matrix->coefficients[5];
    matrix->coefficients[5] = tmp;
}

void transformationmatrix_apply_transformation(transformationmatrix_t* matrix, point_t* pt)
{
    coordinate_t x = pt->x;
    coordinate_t y = pt->y;
    pt->x = matrix->coefficients[0] * x + matrix->coefficients[1] * y + matrix->coefficients[2];
    pt->y = matrix->coefficients[3] * x + matrix->coefficients[4] * y + matrix->coefficients[5];
}

void transformationmatrix_apply_inverse_transformation(transformationmatrix_t* matrix, point_t* pt)
{
    coordinate_t x = pt->x;
    coordinate_t y = pt->y;
    coordinate_t det = M(4) * M(4) - M(1) * M(3);
    pt->x = ( M(4) * x + -M(1) * y + ( M(1) * M(5) - M(2) * M(4))) / det;
    pt->y = (-M(3) * x +  M(0) * y + (-M(0) * M(5) - M(2) * M(3))) / det;
}


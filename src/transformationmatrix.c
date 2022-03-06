#include "transformationmatrix.h"

#include <stdlib.h>

#include "point.h"

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
    matrix->coefficients[3] = 1;
    matrix->dx = 0;
    matrix->dy = 0;
    matrix->auxdx = 0;
    matrix->auxdy = 0;
    matrix->scalefactor = 1;
}

transformationmatrix_t* transformationmatrix_chain(transformationmatrix_t* lhs, transformationmatrix_t* rhs)
{
    transformationmatrix_t* matrix = transformationmatrix_create();
    matrix->coefficients[0] = lhs->coefficients[0] * rhs->coefficients[0] + lhs->coefficients[1] * rhs->coefficients[2];
    matrix->coefficients[1] = lhs->coefficients[0] * rhs->coefficients[1] + lhs->coefficients[1] * rhs->coefficients[3];
    matrix->coefficients[2] = lhs->coefficients[2] * rhs->coefficients[0] + lhs->coefficients[3] * rhs->coefficients[2];
    matrix->coefficients[3] = lhs->coefficients[2] * rhs->coefficients[1] + lhs->coefficients[3] * rhs->coefficients[3];
    matrix->dx = lhs->dx + rhs->dx;
    matrix->dy = lhs->dy + rhs->dy;
    matrix->auxdx = lhs->auxdx + rhs->auxdx;
    matrix->auxdy = lhs->auxdy + rhs->auxdy;
    matrix->scalefactor = lhs->scalefactor * rhs->scalefactor;
    return matrix;
}

transformationmatrix_t* transformationmatrix_copy(transformationmatrix_t* old)
{
    transformationmatrix_t* matrix = transformationmatrix_create();
    matrix->coefficients[0] = old->coefficients[0];
    matrix->coefficients[1] = old->coefficients[1];
    matrix->coefficients[2] = old->coefficients[2];
    matrix->coefficients[3] = old->coefficients[3];
    matrix->dx = old->dx;
    matrix->dy = old->dy;
    matrix->auxdx = old->auxdx;
    matrix->auxdy = old->auxdy;
    matrix->scalefactor = old->scalefactor;
    return matrix;
}

void transformationmatrix_move_to(transformationmatrix_t* matrix, coordinate_t x, coordinate_t y)
{
    matrix->dx = x;
    matrix->dy = y;
}

void transformationmatrix_move_x_to(transformationmatrix_t* matrix, coordinate_t x)
{
    matrix->dx = x;
}

void transformationmatrix_move_y_to(transformationmatrix_t* matrix, coordinate_t y)
{
    matrix->dy = y;
}

void transformationmatrix_translate(transformationmatrix_t* matrix, coordinate_t dx, coordinate_t dy)
{
    matrix->dx += dx;
    matrix->dy += dy;
}

void transformationmatrix_translate_x(transformationmatrix_t* matrix, coordinate_t dx)
{
    matrix->dx += dx;
}

void transformationmatrix_translate_y(transformationmatrix_t* matrix, coordinate_t dy)
{
    matrix->dy += dy;
}

void transformationmatrix_auxtranslate(transformationmatrix_t* matrix, coordinate_t dx, coordinate_t dy)
{
    matrix->auxdx += dx;
    matrix->auxdy += dy;
}

void transformationmatrix_scale(transformationmatrix_t* matrix, double factor)
{
    matrix->scalefactor = factor;
}

void transformationmatrix_flipx(transformationmatrix_t* matrix)
{
    matrix->coefficients[0] = -matrix->coefficients[0];
    matrix->coefficients[1] = -matrix->coefficients[1];
}

void transformationmatrix_flipy(transformationmatrix_t* matrix)
{
    matrix->coefficients[2] = -matrix->coefficients[2];
    matrix->coefficients[3] = -matrix->coefficients[3];
}

void transformationmatrix_rotate_90_right(transformationmatrix_t* matrix)
{
    coordinate_t tmp = matrix->coefficients[0];
    matrix->coefficients[0] = matrix->coefficients[2];
    matrix->coefficients[2] = -tmp;
    tmp = matrix->coefficients[1];
    matrix->coefficients[1] = matrix->coefficients[3];
    matrix->coefficients[3] = -tmp;
}

void transformationmatrix_rotate_90_left(transformationmatrix_t* matrix)
{
    coordinate_t tmp = matrix->coefficients[0];
    matrix->coefficients[0] = -matrix->coefficients[2];
    matrix->coefficients[2] = tmp;
    tmp = matrix->coefficients[1];
    matrix->coefficients[1] = -matrix->coefficients[3];
    matrix->coefficients[3] = tmp;
}

void transformationmatrix_apply_translation(transformationmatrix_t* matrix, point_t* pt)
{
    pt->x += matrix->dx;
    pt->y += matrix->dy;
}

void transformationmatrix_apply_aux_translation(transformationmatrix_t* matrix, point_t* pt)
{
    pt->x += matrix->auxdx;
    pt->y += matrix->auxdy;
}

void transformationmatrix_apply_transformation(transformationmatrix_t* matrix, point_t* pt)
{
    coordinate_t x = pt->x;
    coordinate_t y = pt->y;
    pt->x = matrix->scalefactor * (matrix->coefficients[0] * x + matrix->coefficients[1] * y) + matrix->dx + matrix->auxdx;
    pt->y = matrix->scalefactor * (matrix->coefficients[2] * x + matrix->coefficients[3] * y) + matrix->dy + matrix->auxdy;
}

void transformationmatrix_apply_inverse_transformation(transformationmatrix_t* matrix, point_t* pt)
{
    coordinate_t x = pt->x;
    coordinate_t y = pt->y;
    coordinate_t det = matrix->coefficients[0] * matrix->coefficients[3] - matrix->coefficients[1] * matrix->coefficients[2];
    pt->x = ((x - matrix->dx - matrix->auxdx) / matrix->scalefactor * matrix->coefficients[3] - (y - matrix->dy - matrix->auxdy) / matrix->scalefactor * matrix->coefficients[1]) / det;
    pt->y = ((y - matrix->dy - matrix->auxdy) / matrix->scalefactor * matrix->coefficients[0] - (x - matrix->dx - matrix->auxdx) / matrix->scalefactor * matrix->coefficients[2]) / det;
}

void transformationmatrix_apply_inverse_aux_translation(transformationmatrix_t* matrix, point_t* pt)
{
    pt->x -= matrix->auxdx;
    pt->y -= matrix->auxdy;
}


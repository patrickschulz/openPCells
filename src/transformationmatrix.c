#include "transformationmatrix.h"

#include <stdlib.h>

#include "point.h"

/*
 *  /   0   1   2   \
 *  |   3   4   5   |
 *  \   6   7   8   /
 *  6 & 7 are always 0, 8 is always 1
 *      -> these values are not explicitly stored
 */
struct transformationmatrix {
    coordinate_t coefficients[6];
};

#define M(matrix, idx) matrix->coefficients[idx]

struct transformationmatrix* transformationmatrix_create(void)
{
    struct transformationmatrix* matrix = malloc(sizeof(*matrix));
    return matrix;
}

void transformationmatrix_destroy(struct transformationmatrix* matrix)
{
    free(matrix);
}

void transformationmatrix_identity(struct transformationmatrix* matrix)
{
    M(matrix, 0) = 1;
    M(matrix, 1) = 0;
    M(matrix, 2) = 0;
    M(matrix, 3) = 0;
    M(matrix, 4) = 1;
    M(matrix, 5) = 0;
}

void transformationmatrix_chain_inline(struct transformationmatrix* lhs, const struct transformationmatrix* rhs)
{
    coordinate_t c0 = M(lhs, 0) * M(rhs, 0) + M(lhs, 1) * M(rhs, 3);
    coordinate_t c1 = M(lhs, 0) * M(rhs, 1) + M(lhs, 1) * M(rhs, 4);
    coordinate_t c2 = M(lhs, 0) * M(rhs, 2) + M(lhs, 1) * M(rhs, 5) + M(lhs, 2);
    coordinate_t c3 = M(lhs, 3) * M(rhs, 0) + M(lhs, 4) * M(rhs, 3);
    coordinate_t c4 = M(lhs, 3) * M(rhs, 1) + M(lhs, 4) * M(rhs, 4);
    coordinate_t c5 = M(lhs, 3) * M(rhs, 2) + M(lhs, 4) * M(rhs, 5) + M(lhs, 5);
    M(lhs, 0) = c0;
    M(lhs, 1) = c1;
    M(lhs, 2) = c2;
    M(lhs, 3) = c3;
    M(lhs, 4) = c4;
    M(lhs, 5) = c5;
}

struct transformationmatrix* transformationmatrix_chain(const struct transformationmatrix* lhs, const struct transformationmatrix* rhs)
{
    struct transformationmatrix* matrix = transformationmatrix_create();
    M(matrix, 0) = M(lhs, 0) * M(rhs, 0) + M(lhs, 1) * M(rhs, 3);
    M(matrix, 1) = M(lhs, 0) * M(rhs, 1) + M(lhs, 1) * M(rhs, 4);
    M(matrix, 2) = M(lhs, 0) * M(rhs, 2) + M(lhs, 1) * M(rhs, 5) + M(lhs, 2);
    M(matrix, 3) = M(lhs, 3) * M(rhs, 0) + M(lhs, 4) * M(rhs, 3);
    M(matrix, 4) = M(lhs, 3) * M(rhs, 1) + M(lhs, 4) * M(rhs, 4);
    M(matrix, 5) = M(lhs, 3) * M(rhs, 2) + M(lhs, 4) * M(rhs, 5) + M(lhs, 5);
    return matrix;
}

struct transformationmatrix* transformationmatrix_copy(const struct transformationmatrix* old)
{
    struct transformationmatrix* matrix = transformationmatrix_create();
    M(matrix, 0) = M(old, 0);
    M(matrix, 1) = M(old, 1);
    M(matrix, 2) = M(old, 2);
    M(matrix, 3) = M(old, 3);
    M(matrix, 4) = M(old, 4);
    M(matrix, 5) = M(old, 5);
    return matrix;
}

struct transformationmatrix* transformationmatrix_invert(const struct transformationmatrix* old)
{
    struct transformationmatrix* matrix = transformationmatrix_create();
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

void transformationmatrix_move_to(struct transformationmatrix* matrix, coordinate_t x, coordinate_t y)
{
    M(matrix, 2) = x;
    M(matrix, 5) = y;
}

void transformationmatrix_move_x_to(struct transformationmatrix* matrix, coordinate_t x)
{
    M(matrix, 2) = x;
}

void transformationmatrix_move_y_to(struct transformationmatrix* matrix, coordinate_t y)
{
    M(matrix, 5) = y;
}

void transformationmatrix_translate(struct transformationmatrix* matrix, coordinate_t dx, coordinate_t dy)
{
    M(matrix, 2) += dx;
    M(matrix, 5) += dy;
}

void transformationmatrix_translate_x(struct transformationmatrix* matrix, coordinate_t dx)
{
    M(matrix, 2) += dx;
}

void transformationmatrix_translate_y(struct transformationmatrix* matrix, coordinate_t dy)
{
    M(matrix, 5) += dy;
}

void transformationmatrix_scale(struct transformationmatrix* matrix, double factor)
{
    M(matrix, 0) *= factor;
    M(matrix, 1) *= factor;
    M(matrix, 2) *= factor;
    M(matrix, 3) *= factor;
    M(matrix, 4) *= factor;
    M(matrix, 5) *= factor;
}

void transformationmatrix_mirror_x(struct transformationmatrix* matrix)
{
    M(matrix, 3) = -M(matrix, 3);
    M(matrix, 4) = -M(matrix, 4);
    M(matrix, 5) = -M(matrix, 5);
}

void transformationmatrix_mirror_y(struct transformationmatrix* matrix)
{
    M(matrix, 0) = -M(matrix, 0);
    M(matrix, 1) = -M(matrix, 1);
    M(matrix, 2) = -M(matrix, 2);
}

void transformationmatrix_mirror_origin(struct transformationmatrix* matrix)
{
    M(matrix, 0) = -M(matrix, 0);
    M(matrix, 1) = -M(matrix, 1);
    M(matrix, 2) = -M(matrix, 2);
    M(matrix, 3) = -M(matrix, 3);
    M(matrix, 4) = -M(matrix, 4);
    M(matrix, 5) = -M(matrix, 5);
}

void transformationmatrix_rotate_90_right(struct transformationmatrix* matrix)
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

void transformationmatrix_rotate_90_left(struct transformationmatrix* matrix)
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

void transformationmatrix_apply_transformation(const struct transformationmatrix* matrix, struct point* pt)
{
    coordinate_t x = pt->x;
    coordinate_t y = pt->y;
    pt->x = M(matrix, 0) * x + M(matrix, 1) * y + M(matrix, 2);
    pt->y = M(matrix, 3) * x + M(matrix, 4) * y + M(matrix, 5);
}

void transformationmatrix_apply_transformation_rot_mirr(const struct transformationmatrix* matrix, struct point* pt)
{
    coordinate_t x = pt->x;
    coordinate_t y = pt->y;
    pt->x = M(matrix, 0) * x + M(matrix, 1) * y;
    pt->y = M(matrix, 3) * x + M(matrix, 4) * y;
}

void transformationmatrix_apply_transformation_xy(const struct transformationmatrix* matrix, coordinate_t* x, coordinate_t* y)
{
    coordinate_t xx = *x;
    coordinate_t yy = *y;
    *x = M(matrix, 0) * xx + M(matrix, 1) * yy + M(matrix, 2);
    *y = M(matrix, 3) * xx + M(matrix, 4) * yy + M(matrix, 5);
}

void transformationmatrix_apply_inverse_transformation_xy(const struct transformationmatrix* matrix, coordinate_t* ptx, coordinate_t* pty)
{
    coordinate_t x = *ptx;
    coordinate_t y = *pty;
    coordinate_t det = M(matrix, 0) * M(matrix, 4) - M(matrix, 1) * M(matrix, 3);
    *ptx = M(matrix, 4) / det * x - M(matrix, 1) / det * y + (M(matrix, 1) * M(matrix, 5) - M(matrix, 2) * M(matrix, 4)) / det;
    *pty = -M(matrix, 3) / det * x + M(matrix, 0) / det * y - (M(matrix, 0) * M(matrix, 5) - M(matrix, 2) * M(matrix, 1)) / det;
}

void transformationmatrix_apply_inverse_transformation(const struct transformationmatrix* matrix, struct point* pt)
{
    transformationmatrix_apply_inverse_transformation_xy(matrix, &pt->x, &pt->y);
}

const coordinate_t* transformationmatrix_get_coefficients(const struct transformationmatrix* matrix)
{
    return matrix->coefficients;
}


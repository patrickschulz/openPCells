#ifndef OPC_TRANSFORMATIONMATRIX_H
#define OPC_TRANSFORMATIONMATRIX_H

#include "point.h"

struct transformationmatrix;

struct transformationmatrix* transformationmatrix_create(void);
void transformationmatrix_destroy(struct transformationmatrix* matrix);
void transformationmatrix_identity(struct transformationmatrix* matrix);
void transformationmatrix_chain_inline(struct transformationmatrix* lhs, const struct transformationmatrix* rhs);
struct transformationmatrix* transformationmatrix_chain(const struct transformationmatrix* lhs, const struct transformationmatrix* rhs);
struct transformationmatrix* transformationmatrix_copy(const struct transformationmatrix* old);
struct transformationmatrix* transformationmatrix_invert(const struct transformationmatrix* old);
void transformationmatrix_move_to(struct transformationmatrix* matrix, coordinate_t x, coordinate_t y);
void transformationmatrix_move_x_to(struct transformationmatrix* matrix, coordinate_t x);
void transformationmatrix_move_y_to(struct transformationmatrix* matrix, coordinate_t y);
void transformationmatrix_translate(struct transformationmatrix* matrix, coordinate_t dx, coordinate_t dy);
void transformationmatrix_translate_x(struct transformationmatrix* matrix, coordinate_t dx);
void transformationmatrix_translate_y(struct transformationmatrix* matrix, coordinate_t dy);
void transformationmatrix_scale(struct transformationmatrix* matrix, double factor);
void transformationmatrix_mirror_x(struct transformationmatrix* matrix);
void transformationmatrix_mirror_y(struct transformationmatrix* matrix);
void transformationmatrix_mirror_origin(struct transformationmatrix* matrix);
void transformationmatrix_rotate_90_right(struct transformationmatrix* matrix);
void transformationmatrix_rotate_90_left(struct transformationmatrix* matrix);
void transformationmatrix_apply_transformation(const struct transformationmatrix* matrix, point_t* pt);
void transformationmatrix_apply_transformation_rot_mirr(const struct transformationmatrix* matrix, point_t* pt);
void transformationmatrix_apply_transformation_xy(const struct transformationmatrix* matrix, coordinate_t* x, coordinate_t* y);
void transformationmatrix_apply_inverse_transformation(const struct transformationmatrix* matrix, point_t* pt);
void transformationmatrix_apply_inverse_transformation_xy(const struct transformationmatrix* matrix, coordinate_t* x, coordinate_t* y);
const coordinate_t* transformationmatrix_get_coefficients(const struct transformationmatrix* matrix);

#endif /* OPC_TRANSFORMATIONMATRIX_H */

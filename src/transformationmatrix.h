#ifndef OPC_TRANSFORMATIONMATRIX_H
#define OPC_TRANSFORMATIONMATRIX_H

#include "point.h"

typedef struct 
{
    coordinate_t coefficients[4];
    coordinate_t dx;
    coordinate_t dy;
    coordinate_t auxdx;
    coordinate_t auxdy;
    double scalefactor;
} transformationmatrix_t;

transformationmatrix_t* transformationmatrix_create(void);
void transformationmatrix_destroy(transformationmatrix_t* matrix);
void transformationmatrix_identity(transformationmatrix_t* matrix);
transformationmatrix_t* transformationmatrix_chain(transformationmatrix_t* lhs, transformationmatrix_t* rhs);
transformationmatrix_t* transformationmatrix_copy(transformationmatrix_t* old);
void transformationmatrix_move_to(transformationmatrix_t* matrix, coordinate_t x, coordinate_t y);
void transformationmatrix_move_x_to(transformationmatrix_t* matrix, coordinate_t x);
void transformationmatrix_move_y_to(transformationmatrix_t* matrix, coordinate_t y);
void transformationmatrix_translate(transformationmatrix_t* matrix, coordinate_t dx, coordinate_t dy);
void transformationmatrix_translate_x(transformationmatrix_t* matrix, coordinate_t dx);
void transformationmatrix_translate_y(transformationmatrix_t* matrix, coordinate_t dy);
void transformationmatrix_auxtranslate(transformationmatrix_t* matrix, coordinate_t dx, coordinate_t dy);
void transformationmatrix_scale(transformationmatrix_t* matrix, double factor);
void transformationmatrix_flipx(transformationmatrix_t* matrix);
void transformationmatrix_flipy(transformationmatrix_t* matrix);
void transformationmatrix_rotate_90_right(transformationmatrix_t* matrix);
void transformationmatrix_rotate_90_left(transformationmatrix_t* matrix);
void transformationmatrix_apply_translation(transformationmatrix_t* matrix, point_t* pt);
void transformationmatrix_apply_aux_translation(transformationmatrix_t* matrix, point_t* pt);
void transformationmatrix_apply_transformation(transformationmatrix_t* matrix, point_t* pt);
void transformationmatrix_apply_inverse_transformation(transformationmatrix_t* matrix, point_t* pt);
void transformationmatrix_apply_inverse_aux_translation(transformationmatrix_t* matrix, point_t* pt);

#endif /* OPC_TRANSFORMATIONMATRIX_H */

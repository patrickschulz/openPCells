#include "arith.h"

#include <math.h>

coordinate_t arith_div_grid(coordinate_t c, coordinate_t div, coordinate_t grid)
{
    // integer division, hence this is a floor() operation
    return grid * ((c / div) / grid);
}

coordinate_t arith_mul_grid(coordinate_t c, double mul, coordinate_t grid)
{
    return grid * ((coordinate_t)floor(c * mul) / grid);
}

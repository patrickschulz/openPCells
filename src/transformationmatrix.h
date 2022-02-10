#ifndef OPC_TRANSFORMATIONMATRIX_H
#define OPC_TRANSFORMATIONMATRIX_H

#include "lua/lua.h"

#include "point.h"

#define LTRANSFORMATIONMATRIXMODULE "transformationmatrix"

typedef struct 
{
    coordinate_t coefficients[4];
    coordinate_t dx;
    coordinate_t dy;
    coordinate_t auxdx;
    coordinate_t auxdy;
    double scalefactor;
} transformationmatrix_t;

int open_ltransformationmatrix_lib(lua_State* L);

#endif /* OPC_TRANSFORMATIONMATRIX_H */

#ifndef OPC_LTRANSFORMATIONMATRIX_H
#define OPC_LTRANSFORMATIONMATRIX_H

#include "lua/lua.h"

#include "transformationmatrix.h"

#define LTRANSFORMATIONMATRIXMODULE "transformationmatrix"

typedef struct 
{
    transformationmatrix_t* matrix;
} ltransformationmatrix_t;

int open_ltransformationmatrix_lib(lua_State* L);

#endif /* OPC_LTRANSFORMATIONMATRIX_H */

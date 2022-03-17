#ifndef OPC_LSHAPE_H
#define OPC_LSHAPE_H

#include "lua/lua.h"

#include "shape.h"

#define LSHAPEMODULE "shape"

typedef struct
{
    shape_t* shape;
    int destroy;
} lshape_t;

lshape_t* lshape_create_proxy(lua_State* L, shape_t* shape);

int open_lshape_lib(lua_State* L);

#endif /* OPC_LSHAPE_H */

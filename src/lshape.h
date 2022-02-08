#ifndef OPC_LSHAPE_H
#define OPC_LSHAPE_H

#include "lua/lua.h"

#include "lpoint.h"

/*
typedef enum
{
    RECTANGLE,
    POLYGON
} shapetype;

typedef struct
{
    lpoint_t bl;
    lpoint_t tr;
} rectangle_t;

typedef struct
{
    lpoint_t* points;
} polygon_t;

typedef struct
{
    void* geo;
    shapetype type;
} lshape_t;

lshape_t* create_rectangle();
lshape_t* create_polygon();
*/

int open_lshape_lib(lua_State* L);

#endif /* OPC_LSHAPE_H */

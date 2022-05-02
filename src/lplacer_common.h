#ifndef OPC_LPLACER_COMMON_H
#define OPC_LPLACER_COMMON_H

#include "lua/lua.h"

#include <stddef.h>

#include "keyvaluepairs.h"

struct basic_cell {
    unsigned int instance;
    unsigned int reference;
    unsigned int width;
    struct net** nets;
    unsigned int* pinoffset;
    unsigned int num_conns;
};

void placer_initialize_base_cell(lua_State* L, struct basic_cell* base, size_t index, struct keyvaluearray* netmap);
void placer_destroy_base_cell_contents(struct basic_cell* base);

struct floorplan {
    unsigned int floorplan_width;
    unsigned int floorplan_height;
    unsigned int desired_row_width;
    // limiter window
    int limiter_width;
    int limiter_height;
};

struct floorplan* placer_create_floorplan(lua_State* L);
void placer_destroy_floorplan(struct floorplan* floorplan);

// lua result
typedef int* (*row_access_func_t)(const void*, unsigned int);
void placer_create_lua_result(lua_State* L, void* block, row_access_func_t, struct floorplan* floorplan);

#endif /* OPC_LPLACER_COMMON_H */

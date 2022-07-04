#include "lplacer_common.h"

#include <stdint.h>
#include <stdlib.h>

uint64_t factorial(uint64_t num)
{
    if(num == 0)
    {
        return 1;
    }
    if(num == 1)
    {
        return 1;
    }
    return num * factorial(num - 1);
}

unsigned int uintpow(unsigned int base, unsigned int exp)
{
    unsigned int result = 1;
    while(exp)
    {
        if(exp % 2)
        {
           result *= base;
        }
        exp /= 2;
        base *= base;
    }
    return result;
}

int next_permutation(unsigned int* array, size_t len)
{
    //find largest j such that array[j] < array[j+1]; if no such j then done
    int j = -1;
    for (unsigned int i = 0; i < len - 1; i++)
    {
        if (array[i + 1] > array[i])
        {
            j = i;
        }
    }
    if (j == -1)
    {
        return 0;
    }
    else
    {
        int l;
        for (unsigned int i = j + 1; i < len; i++)
        {
            if (array[i] > array[j])
            {
                l = i;
            }
        }
        unsigned int tmp = array[j];
        array[j] = array[l];
        array[l] = tmp;
        // reverse j + 1 to end
        unsigned int k = (len - 1 - j) / 2; // number of pairs to swap
        for (unsigned int i = 0; i < k; i++)
        {
            tmp = array[j + 1 + i];
            array[j + 1 + i] = array[len - 1 - i];
            array[len - 1 - i] = tmp;
        }
    }
    return 1;
}

void placer_initialize_base_cell(lua_State* L, struct basic_cell* base, size_t index, struct hashmap* netmap)
{
    // instance
    base->instance = index;

    // width
    lua_getfield(L, -1, "width");
    base->width = lua_tointeger(L, -1);
    lua_pop(L, 1);

    // nets
    lua_getfield(L, -1, "nets");
    lua_len(L, -1);
    size_t num_conns = lua_tointeger(L, -1);
    lua_pop(L, 1);
    base->nets = calloc(num_conns, sizeof(*base->nets));
    base->pinoffset = calloc(num_conns, sizeof(*base->pinoffset));
    base->num_conns = num_conns;
    for(size_t j = 1; j <= num_conns; ++j)
    {
        lua_geti(L, -1, j); // get net

        lua_getfield(L, -1, "name");
        const char* name = lua_tostring(L, -1);
        base->nets[j - 1] = hashmap_get(netmap, name);
        lua_pop(L, 1); // pop name

        lua_getfield(L, -3, "pinoffsets");
        lua_getfield(L, -2, "port");
        lua_gettable(L, -2);
        int pinoffset = lua_tointeger(L, -1);
        base->pinoffset[j - 1] = pinoffset;
        lua_pop(L, 2); // pop pinoffset + pinoffsets table
        lua_pop(L, 1); // pop net
    }
}

void placer_destroy_base_cell_contents(struct basic_cell* base)
{
    free(base->nets);
    free(base->pinoffset);
}

struct floorplan* placer_create_floorplan(lua_State* L)
{
    lua_getfield(L, 3, "floorplan_width");
    unsigned int floorplan_width = lua_tointeger(L, -1);
    lua_pop(L, 1);
    lua_getfield(L, 3, "floorplan_height");
    unsigned int floorplan_height = lua_tointeger(L, -1);
    lua_pop(L, 1);
    lua_getfield(L, 3, "desired_row_width");
    unsigned int desired_row_width = lua_tointeger(L, -1);
    lua_pop(L, 1);

    struct floorplan* floorplan = malloc(sizeof(struct floorplan));
    floorplan->floorplan_width = floorplan_width;
    floorplan->floorplan_height = floorplan_height;
    floorplan->desired_row_width = desired_row_width;

    return floorplan;
}

void placer_destroy_floorplan(struct floorplan* floorplan)
{
    free(floorplan);
}

void placer_create_lua_result(lua_State* L, void* block, row_access_func_t row_access_func, struct floorplan* floorplan)
{
    lua_newtable(L);
    for(unsigned int cur_row = 0; cur_row < floorplan->floorplan_height; cur_row++)
    {
        int* row_instance_indices = row_access_func(block, cur_row);
        lua_newtable(L);
        int i = 1;
        for(int* idx = row_instance_indices; *idx; ++idx)
        {
            lua_rawgeti(L, 1, *idx);

            lua_newtable(L);
            lua_pushstring(L, "reference");
            lua_getfield(L, -3, "reference");
            lua_settable(L, -3);
            lua_pushstring(L, "instance");
            lua_getfield(L, 1, "instance");
            lua_settable(L, -3);
            lua_pop(L, 1);
            lua_seti(L, -2, i);
            ++i;
        }
        lua_seti(L, -2, cur_row + 1);
        free(row_instance_indices);
    }
}


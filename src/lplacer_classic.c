#include "lplacer_classic.h"

#include <stdlib.h>
#include <stdio.h>
#include <time.h>
#include <limits.h>
#include <stdint.h>
#include <math.h>

#include "lplacer_common.h"
#include "lplacer_rand.h"

#include "keyvaluepairs.h"
#include "util.h"

struct cell {
    struct basic_cell base;
    unsigned int pos_x;
    unsigned int pos_y;
};

struct net {
    unsigned int xmin, xmax;
    unsigned int ymin, ymax;
};

struct block {
    // cells
    struct cell* cells;
    unsigned int num_cells;

    // nets
    struct net* nets;
    unsigned int num_nets;
};

struct rollback {
    struct cell* c1;
    unsigned int x1;
    unsigned int y1;
    struct cell* c2;
    unsigned int x2;
    unsigned int y2;
};

static unsigned int calculate_total_wirelength(struct block* block)
{
    unsigned int total_wirelength = 0;
    unsigned int xweight = 1;
    unsigned int yweight = 1;
    for(size_t i = 0; i < block->num_nets; ++i)
    {
        struct net* net = block->nets + i;
        unsigned int length = xweight * (net->xmax - net->xmin) + yweight * (net->ymax - net->ymin);
        total_wirelength += length;
    }
    return total_wirelength;
}

static struct cell** get_cells_of_row(const struct block* block, unsigned int cur_row, size_t* num_in_row)
{
    size_t capacity = 40;
    size_t cur_cell_idx = 0;
    struct cell** cells_in_row = calloc(capacity, sizeof(struct cell*));
    for(size_t i = 0; i < block->num_cells; ++i)
    {
        struct cell* c = block->cells + i;
        if(c->pos_y == cur_row)
        {
            if(cur_cell_idx == capacity - 1) // -1 for sentinel
            {
                capacity *= 2;
                cells_in_row = realloc(cells_in_row, capacity * sizeof(struct cell*));
            }
            cells_in_row[cur_cell_idx] = c;
            ++cur_cell_idx;
        }
    };
    cells_in_row[cur_cell_idx] = NULL; // sentinel
    if(num_in_row)
    {
        *num_in_row = cur_cell_idx;
    }
    return cells_in_row;
}

static unsigned int calculate_row_width_penalty(struct block* block, struct floorplan* floorplan)
{
    unsigned int penalty = 0;
    for(unsigned int row = 0; row < floorplan->floorplan_height; ++row)
    {
        unsigned int row_width = 0;
        struct cell** cells_in_row = get_cells_of_row(block, row, NULL);
        for(struct cell** c_p = cells_in_row; *c_p; c_p++)
        {
            row_width += (*c_p)->base.width;
        }
        if(row_width > floorplan->floorplan_width)
        {
            penalty += row_width - floorplan->floorplan_width;
        }
    }
    return penalty;
}

void undo(struct rollback* r)
{
    if(r->c1)
    {
        r->c1->pos_x = r->x1;
        r->c1->pos_y = r->y1;
    }
    if(r->c2)
    {
        r->c2->pos_x = r->x2;
        r->c2->pos_y = r->y2;
    }
}

static struct block* _initialize(lua_State* L, struct floorplan* floorplan, struct RanState* rstate)
{
    struct block* block = malloc(sizeof(struct block));

    lua_len(L, 1);
    unsigned int num_cells = lua_tointeger(L, -1);
    lua_pop(L, 1);

    // initialize nets
    lua_len(L, 2);
    size_t num_nets = lua_tointeger(L, -1);
    lua_pop(L, 1);
    block->num_nets = num_nets;
    block->nets = calloc(block->num_nets, sizeof(struct net));
    struct keyvaluearray* netmap = keyvaluearray_create();
    for(size_t i = 1; i <= num_nets; ++i)
    {
        lua_geti(L, 2, i);
        const char* name = lua_tostring(L, -1);
        keyvaluearray_add_untagged(netmap, name, block->nets + i - 1);
        lua_pop(L, 1);
    }

    // initialize all_cells
    block->num_cells = num_cells;
    block->cells = calloc(block->num_cells, sizeof(*block->cells));
    for(size_t i = 1; i <= num_cells; ++i)
    {
        lua_geti(L, 1, i); // get instance
        struct basic_cell* base = &(block->cells + i - 1)->base;
        placer_initialize_base_cell(L, base, i, netmap);
        lua_pop(L, 1); // pop instance
    }
    keyvaluearray_destroy(netmap);

    // shuffle cells
    for (unsigned int i = num_cells - 1; i > 0; i--)
    {
        unsigned int j = _lua_randi(rstate, 0, i);
        struct cell tmp = block->cells[j];
        block->cells[j] = block->cells[i];
        block->cells[i] = tmp;
    }

    // place all cells randomly
    for (unsigned int i = 0; i < block->num_cells; ++i)
    {
        struct cell* c = block->cells + i;
        c->pos_x = _lua_randi(rstate, 0, floorplan->floorplan_width - 1);
        c->pos_y = _lua_randi(rstate, 0, floorplan->floorplan_height - 1);
    }

    return block;
}

static void _clean_up(struct block* block, struct floorplan* floorplan)
{
    for(unsigned int i = 0; i < block->num_cells; ++i)
    {
        placer_destroy_base_cell_contents(&(block->cells + i)->base);
    }
    free(block->cells);
    free(block->nets);
    free(block);
    placer_destroy_floorplan(floorplan);
}

#define min(a, b) ((a) < (b) ? (a) : (b))
#define max(a, b) ((a) > (b) ? (a) : (b))

static void _update_net_positions(struct block* block)
{
    // reset positions
    for(unsigned int i = 0; i < block->num_nets; ++i)
    {
        struct net* net = block->nets + i;
        net->xmin = UINT_MAX;
        net->xmax = 0;
        net->ymin = UINT_MAX;
        net->ymax = 0;
    }
    // update positions
    for(unsigned int i = 0; i < block->num_cells; ++i)
    {
        struct cell* c = block->cells + i;
        for(unsigned int i = 0; i < c->base.num_conns; ++i)
        {
            struct net* net = c->base.nets[i];
            unsigned int pinoffset = c->base.pinoffset[i];
            net->xmin = min(net->xmin, c->pos_x + pinoffset);
            net->xmax = max(net->xmax, c->pos_x+ pinoffset);
            net->ymin = min(net->ymin, c->pos_y);
            net->ymax = max(net->ymax, c->pos_y);
        }
    }
}

static struct cell* random_cell(struct block* block, struct RanState* rstate)
{
    return block->cells + _lua_randi(rstate, 0, block->num_cells - 1);
}

static inline void cell_place_random(struct cell* c, struct floorplan* floorplan, struct RanState* rstate)
{
    c->pos_x = _lua_randi(rstate, 0, floorplan->floorplan_width - 1);
    c->pos_y = _lua_randi(rstate, 0, floorplan->floorplan_height - 1);
}

void m1(struct cell* a, struct rollback* r, struct floorplan* floorplan, struct RanState* rstate)
{
    r->c1 = a;
    r->x1 = a->pos_x;
    r->y1 = a->pos_y;
    r->c2 = NULL;
    cell_place_random(a, floorplan, rstate);
}

void m2(struct cell* a, struct cell* b, struct rollback* r)
{
    r->c1 = a;
    r->x1 = a->pos_x;
    r->y1 = a->pos_y;
    r->c2 = b;
    r->x2 = b->pos_x;
    r->y2 = b->pos_y;

    // swap cell positions
    a->pos_x = b->pos_x;
    a->pos_y = b->pos_y;
    b->pos_x = r->x1;
    b->pos_y = r->y1;
}

static void _simulated_annealing(struct RanState* rstate, struct block* block, struct floorplan* floorplan, double coolingfactor, size_t moves_per_cell_per_temp, int verbose)
{
    (void) verbose;

    double temperature = 5000.0;
    double end_temperature = 0.01;
    unsigned int needed_steps = (unsigned int) log(temperature / end_temperature) / log(1.0 / coolingfactor) + 1;
    unsigned int steps = 1;
    unsigned int percentage_divisor = 10;
    unsigned int percentage = 0;
    unsigned int last_total_penalty = UINT_MAX;
    while(temperature > end_temperature)
    {
        for(size_t move_ctr = 0; move_ctr < moves_per_cell_per_temp * block->num_cells; move_ctr++)
        {
            struct rollback rollback;

            if(random_choice(rstate, 0.25))
            {
                m2(random_cell(block, rstate), random_cell(block, rstate), &rollback);
            }
            else
            {
                m1(random_cell(block, rstate), &rollback, floorplan, rstate);
            }

            _update_net_positions(block);
            unsigned int total_wirelength = calculate_total_wirelength(block);
            unsigned int too_wide_penalty = calculate_row_width_penalty(block, floorplan);

            unsigned int total_penalty = total_wirelength + 100 * too_wide_penalty;
            printf("temperature: %f\n", temperature);
            printf("last penalty / current penalty: %d / %d\n", last_total_penalty, total_penalty);

            /*
            if(move_ctr == 0 && verbose)
            {
                report_status(temperature, block, floorplan);
            }
            */

            if(move_ctr == 0)
            {
                if(steps * 100 / needed_steps >= percentage)
                {
                    printf("placement %2d %% done\n", percentage);
                    percentage += percentage_divisor;
                }
            }

            if(total_penalty > last_total_penalty)
            {
                undo(&rollback);
                //if(random_choice(rstate, exp(-(total_penalty - last_total_penalty) / temperature)))
                //{
                //    // accept
                //    last_total_penalty = total_penalty;    
                //}
                //else
                //{
                //    undo(&rollback);
                //}
            }
            else // last_total_penalty >= total_penalty
            {
                // accept
                last_total_penalty = total_penalty;
            }
        }
        ++steps;
        temperature = temperature * coolingfactor;
    }
}

static int _cell_cmp(const void* p1, const void* p2)
{
    struct cell* const * c1 = p1;
    struct cell* const * c2 = p2;
    if((*c1)->pos_x > (*c2)->pos_x)
    {
        return 1;
    }
    else if((*c1)->pos_x < (*c2)->pos_x)
    {
        return -1;
    }
    else
    {
        return 0;
    }
}

int* get_cell_in_row_index(const void* blockv, unsigned int cur_row)
{
    const struct block* block = blockv;
    size_t numcellrows;
    struct cell** cells_in_row = get_cells_of_row(block, cur_row, &numcellrows);
    qsort(cells_in_row, numcellrows, sizeof(struct cell*), &_cell_cmp);
    int* indices = calloc(numcellrows + 1, sizeof(*indices));
    int i = 0;
    for(struct cell** c = cells_in_row; *c; ++c)
    {
        indices[i] = (*c)->base.instance;
        ++i;
    }
    free(cells_in_row);
    return indices;
}

int lplacer_place_classic(lua_State* L)
{
    struct RanState rstate;
    srand(time(NULL));
    //randseed(&rstate, rand(), rand());
    randseed(&rstate, 127, 42);

    struct floorplan* floorplan = placer_create_floorplan(L);

    struct block* block = _initialize(L, floorplan, &rstate);

    lua_getfield(L, 3, "movespercell");
    //const size_t moves_per_cell_per_temp = lua_tointeger(L, -1);
    const size_t moves_per_cell_per_temp = 1;
    lua_pop(L, 1);

    lua_getfield(L, 3, "coolingfactor");
    //const double coolingfactor = lua_tonumber(L, -1);
    const double coolingfactor = 0.95;
    lua_pop(L, 1);

    lua_getfield(L, 3, "report");
    const int verbose = lua_toboolean(L, -1);
    lua_pop(L, 1);

    //_simulated_annealing(&rstate, block, floorplan, coolingfactor, moves_per_cell_per_temp, verbose);

    placer_create_lua_result(L, block, get_cell_in_row_index, floorplan);

    _clean_up(block, floorplan); // AFTER _create_lua_result!

    return 1; // cells table is returned to lua
}

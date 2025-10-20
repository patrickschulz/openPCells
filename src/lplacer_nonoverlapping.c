#include "lplacer_nonoverlapping.h"

#include <stdlib.h>
#include <stdio.h>
#include <time.h>
#include <limits.h>
#include <stdint.h>

#include "lplacer_common.h"
#include "lplacer_rand.h"
#include "helpers.h"

struct cell {
    unsigned int instance;
    unsigned int reference;
    unsigned int width;
    struct net** nets;
    unsigned int* pinoffset;
    unsigned int num_conns;
};

struct net {
    unsigned int xmin, xmax;
    unsigned int ymin, ymax;
};

struct block {
    // cells
    struct cell* cells;
    unsigned int num_rows;
    unsigned int num_cells;
    unsigned int* row_sizes;

    // nets
    struct net* nets;
    unsigned int num_nets;
};

static struct cell* _get_cell(struct block* block, unsigned int row, unsigned int col)
{
    unsigned int base = 0;
    for(unsigned int i = 0; i < row; ++i)
    {
        base += block->row_sizes[i];
    }
    return block->cells + base + col;
}

struct rollback {
    unsigned int idx1;
    unsigned int idx2;
    unsigned int idx3;
    enum {
        RB_MOVE_CELL,
        RB_MOVE_ROW,
        RB_SWAP
    } what;
};

unsigned int calculate_total_wirelength(struct block* block)
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

static unsigned int calculate_row_width_penalty(struct block* block, unsigned int max_width)
{
    unsigned int penalty = 0;
    for(unsigned int row = 0; row < block->num_rows; ++row)
    {
        unsigned int row_width = 0;
        for(unsigned int col = 0; col < block->row_sizes[row]; ++col)
        {
            struct cell* cell = _get_cell(block, row, col);
            row_width += cell->width;
        }
        if(row_width > max_width)
        {
            penalty += row_width - max_width;
        }
    }
    return penalty;
}

/*
static unsigned int _get_row_from_index(struct block* block, unsigned int index)
{
    unsigned int width = 0;
    for(unsigned int row = 0; row < block->num_rows; ++row)
    {
        if((index >= width) && (index < (block->row_sizes[row] + width)))
        {
            return row;
        }
        width += block->row_sizes[row];
    }
    return UINT_MAX;
}
*/

static void _insert(struct block* block, unsigned int from, unsigned int to)
{
    struct cell tmp = block->cells[from];
    if(from < to)
    {
        for(unsigned int i = from; i < to - 1; ++i)
        {
            block->cells[i] = block->cells[i + 1];
        }
        block->cells[to - 1] = tmp;
    }
    else
    {
        for(unsigned int i = from; i >= to + 1; --i)
        {
            block->cells[i] = block->cells[i - 1];
        }
        block->cells[to] = tmp;
    }
}

static void _move_cell(struct block* block, unsigned int from, unsigned int to)
{
    if((to < from) || (to > from + 1))
    {
        _insert(block, from, to);
        // update row sizes
        unsigned int width = 0;
        unsigned int fromrow;
        unsigned int torow;
        for(unsigned int row = 0; row < block->num_rows; ++row)
        {
            if((from >= width) && (from < (block->row_sizes[row] + width)))
            {
                fromrow = row;
            }
            if((to >= width) && (to < (block->row_sizes[row] + width)))
            {
                torow = row;
            }
            width += block->row_sizes[row];
        }
        if(to == block->num_cells)
        {
            torow = block->num_rows - 1;
        }
        block->row_sizes[fromrow] -= 1;
        block->row_sizes[torow] += 1;
    }
}

static unsigned int _move_to_row(struct block* block, unsigned int idx, unsigned int torow, struct RanState* rstate)
{
    (void) rstate;

    // update row sizes
    unsigned int width = 0;
    unsigned int offset = 0;
    unsigned int fromrow;
    for(unsigned int row = 0; row < block->num_rows; ++row)
    {
        if((idx >= width) && (idx < (block->row_sizes[row] + width)))
        {
            fromrow = row;
        }
        width += block->row_sizes[row];
        if(row < torow)
        {
            offset += block->row_sizes[row];
        }
    }
    block->row_sizes[fromrow] -= 1;
    block->row_sizes[torow] += 1;
    //unsigned int newidx = offset + _lua_randi(rstate, 0, block->row_sizes[torow]);
    unsigned int newidx = offset + block->row_sizes[torow] - 1;
    _insert(block, idx, newidx);
    return newidx;
}

static void _swap_cells(struct block* block, unsigned int i1, unsigned int i2)
{
    struct cell tmp = block->cells[i1];
    block->cells[i1] = block->cells[i2];
    block->cells[i2] = tmp;
}

static void undo(struct block* block, struct rollback* rollback)
{
    switch(rollback->what)
    {
        case RB_MOVE_CELL:
            if(rollback->idx1 > rollback->idx2)
            {
                _move_cell(block, rollback->idx2, rollback->idx1 + 1);
            }
            else if(rollback->idx1 < rollback->idx2) // exclude idx1 == idx2
            {
                _move_cell(block, rollback->idx2 - 1, rollback->idx1);
            }
            break;
        case RB_MOVE_ROW:
            break;
        case RB_SWAP:
            _swap_cells(block, rollback->idx1, rollback->idx2);
            break;
    }
}

static struct block* _initialize(lua_State* L, unsigned int num_rows, struct RanState* rstate)
{
    struct block* block = malloc(sizeof(struct block));

    block->num_nets = lua_tointeger(L, 1);

    lua_len(L, 2);
    unsigned int num_cells = lua_tointeger(L, -1);
    lua_pop(L, 1);

    // initialize nets
    block->nets = calloc(block->num_nets, sizeof(struct net));

    // initialize all_cells
    block->num_cells = num_cells;
    block->num_rows = num_rows;
    block->row_sizes = calloc(num_rows, sizeof(*block->row_sizes));
    if(num_rows > 1)
    {
        for(unsigned int i = 0; i < num_rows - 1; ++i)
        {
            block->row_sizes[i] = block->num_cells / num_rows;
        }
        block->row_sizes[block->num_rows - 1] = block->num_cells - (block->num_cells / num_rows) * (num_rows - 1);
    }
    else
    {
        block->row_sizes[0] = block->num_cells;
    }
    block->cells = calloc(block->num_cells, sizeof(*block->cells));

    for(size_t i = 1; i <= num_cells; ++i)
    {
        lua_geti(L, 2, i);

        struct cell* c = block->cells + i - 1;

        // instance
        lua_getfield(L, -1, "instance");
        c->instance = lua_tointeger(L, -1);
        lua_pop(L, 1);

        // reference
        lua_getfield(L, -1, "reference");
        c->reference = lua_tointeger(L, -1);
        lua_pop(L, 1);

        // width
        lua_getfield(L, -1, "width");
        c->width = lua_tointeger(L, -1);
        lua_pop(L, 1);

        // nets
        lua_getfield(L, -1, "nets");
        lua_len(L, -1);
        size_t num_conns = lua_tointeger(L, -1);
        lua_pop(L, 1);
        c->nets = calloc(num_conns, sizeof(*c->nets));
        c->pinoffset = calloc(num_conns, sizeof(*c->pinoffset));
        c->num_conns = num_conns;
        for(size_t j = 1; j <= num_conns; ++j)
        {
            lua_geti(L, -1, j);

            lua_getfield(L, -1, "index");
            int index = lua_tointeger(L, -1);
            c->nets[j - 1] = &block->nets[index - 1];

            lua_getfield(L, -2, "pinoffset");
            unsigned int pinoffset = lua_tointeger(L, -1);
            c->pinoffset[j - 1] = pinoffset;

            lua_pop(L, 3); // index, pinoffset and net table
        }
        lua_pop(L, 1);
    }

    // shuffle cells
    for (unsigned int i = num_cells - 1; i > 0; i--)
    {
        unsigned int j = _lua_randi(rstate, 0, i);
        struct cell tmp = block->cells[j];
        block->cells[j] = block->cells[i];
        block->cells[i] = tmp;
    }

    return block;
}

static void _clean_up(struct block* block, struct floorplan* floorplan)
{
    for(unsigned int i = 0; i < block->num_cells; ++i)
    {
        free((block->cells + i)->nets);
        free((block->cells + i)->pinoffset);
    }
    free(block->cells);
    free(block->row_sizes);
    free(block->nets);
    free(block);
    placer_destroy_floorplan(floorplan);
}

static void _create_lua_result(lua_State* L, struct block* block)
{
    lua_newtable(L);
    for(unsigned int row = 0; row < block->num_rows; row++)
    {
        lua_newtable(L);
        int i = 1;
        for(unsigned int col = 0; col < block->row_sizes[row]; col++)
        {
            struct cell* c = _get_cell(block, row, col);
            lua_newtable(L);
            lua_pushstring(L, "reference");
            lua_pushinteger(L, c->reference);
            lua_settable(L, -3);
            lua_pushstring(L, "instance");
            lua_pushinteger(L, c->instance);
            lua_settable(L, -3);
            lua_seti(L, -2, i);
            ++i;
        }
        lua_seti(L, -2, row + 1);
    }
}

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
    for(unsigned int row = 0; row < block->num_rows; row++)
    {
        unsigned int width = 0;
        for(unsigned int col = 0; col < block->row_sizes[row]; col++)
        {
            struct cell* c = _get_cell(block, row, col);
            for(unsigned int i = 0; i < c->num_conns; ++i)
            {
                struct net* net = c->nets[i];
                unsigned int pinoffset = c->pinoffset[i];
                net->xmin = MIN2(net->xmin, col + width + pinoffset);
                net->xmax = MAX2(net->xmax, col + width + pinoffset);
                net->ymin = MIN2(net->ymin, row);
                net->ymax = MAX2(net->ymax, row);
            }
            width += c->width;
        }
    }
}

static void _simulated_annealing(struct RanState* rstate, struct block* block, struct floorplan* floorplan, double coolingfactor, size_t moves_per_cell_per_temp, int verbose)
{
    /*
        some random ideas:
            * have _move_to_row and _move_within_row and check if the wirelength is dominated
              by x or y. Use this information to determine which operation to call
     */
    // FIXME: remove
    (void) verbose;
    (void) moves_per_cell_per_temp;
    (void) coolingfactor;
    (void) floorplan;

    struct UPRNG* cell_rng = UPRNG_init(block->num_cells, rstate);
    struct UPRNG* row_rng = UPRNG_init(block->num_rows, rstate);

    unsigned int last_total_penalty = UINT_MAX;

    for(unsigned int i = 0; i < 1; ++i)
    {
        struct rollback rollback;

        //if(random_choice(rstate, 0.25))
        if(1)
        {
            //_move_cell(block, idx1, idx2);
            unsigned int idx = UPRNG_next(cell_rng);
            unsigned int row = UPRNG_next(row_rng);
            _move_to_row(block, idx, row, rstate);
            rollback.idx1 = idx;
            rollback.idx2 = row;
            rollback.what = RB_MOVE_ROW;
        }
        else
        {
            unsigned int idx1 = UPRNG_next(cell_rng);
            unsigned int idx2 = UPRNG_next(cell_rng);
            _swap_cells(block, idx1, idx2);
            rollback.idx1 = idx1;
            rollback.idx2 = idx2;
            rollback.what = RB_SWAP;
        }
        _update_net_positions(block);
        unsigned int total_wirelength = calculate_total_wirelength(block);
        unsigned int too_wide_penalty = calculate_row_width_penalty(block, floorplan->floorplan_width);

        unsigned int total_penalty = total_wirelength + 100 * too_wide_penalty;

        //debugprintf("penalty (current / last): %u / %u\n", total_penalty, last_total_penalty);

        if(total_penalty > last_total_penalty)
        {
            undo(block, &rollback);
        }
        else // last_total_penalty >= total_penalty
        {
            // accept
            last_total_penalty = total_penalty;
        }
    }
    /*
    double temperature = 5000.0;
    double end_temperature = 0.01;
    unsigned int needed_steps = (unsigned int) log(temperature / end_temperature) / log(1.0 / coolingfactor) + 1;
    unsigned int steps = 1;
    unsigned int percentage_divisor = 10;
    unsigned int percentage = 0;
    if(steps * 100 / needed_steps >= percentage)
    {
        debugprintf("placement %2d %% done\n", percentage);
        percentage += percentage_divisor;
    }
    */
    UPRNG_destroy(cell_rng);
    UPRNG_destroy(row_rng);
}

int lplacer_place_nonoverlapping(lua_State* L)
{
    struct RanState rstate;
    srand(time(NULL));
    //randseed(&rstate, rand(), rand());
    randseed(&rstate, 127, 42);

    struct floorplan* floorplan = placer_create_floorplan(L);

    struct block* block = _initialize(L, floorplan->floorplan_height, &rstate);

    lua_getfield(L, 3, "movespercell");
    const size_t moves_per_cell_per_temp = lua_tointeger(L, -1);
    lua_pop(L, 1);

    lua_getfield(L, 3, "coolingfactor");
    const double coolingfactor = lua_tonumber(L, -1);
    lua_pop(L, 1);

    lua_getfield(L, 3, "report");
    const int verbose = lua_toboolean(L, -1);
    lua_pop(L, 1);

    _simulated_annealing(&rstate, block, floorplan, coolingfactor, moves_per_cell_per_temp, verbose);

    _create_lua_result(L, block);

    _clean_up(block, floorplan); // AFTER _create_lua_result!

    return 1; // cells table is returned to lua
}

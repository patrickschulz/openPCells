#include <stdlib.h>
#include <stdio.h>
#include <time.h>

#include "lua/lua.h"
#include "lua/lauxlib.h"

#include "lplacer_rand.h"

struct floorplan {
    unsigned int floorplan_width;
    unsigned int floorplan_height;
    unsigned int desired_row_width;
    double weight_wirelength;
    double weight_width_penalty;
    int cell_count;
    // limiter window
    int limiter_width;
    int limiter_height;
};

struct cell {
    unsigned int instance;
    unsigned int reference;
    unsigned int width;
    struct net** nets;
    unsigned int* pinoffset;
    unsigned int num_conns;
};

struct net {
    unsigned int size;
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
    enum {
        RB_MOVE,
        RB_SWAP
    } what;
};

unsigned int calculate_total_wirelength(struct net* all_nets, size_t num_nets)
{
    unsigned int total_wirelength = 0;
    unsigned int xweight = 1;
    unsigned int yweight = 1;
    for(size_t i = 0; i < num_nets; ++i)
    {
        struct net* net = all_nets + i;
        unsigned int length = xweight * (net->xmax - net->xmin) + yweight * (net->ymax - net->ymin);
        total_wirelength += length;
    }
    return total_wirelength;
}

static void _move_cell(struct block* block, unsigned int from, unsigned int to)
{
    if(from != to)
    {
        struct cell tmp = block->cells[from];
        if(from < to)
        {
            for(unsigned int i = from; i < to; ++i)
            {
                block->cells[i] = block->cells[i + 1];
            }
        }
        else
        {
            for(unsigned int i = from; i >= to + 1; --i)
            {
                block->cells[i] = block->cells[i - 1];
            }
        }
        block->cells[to] = tmp;
    }
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
        case RB_MOVE:
            _move_cell(block, rollback->idx2, rollback->idx1);
            break;
        case RB_SWAP:
            _swap_cells(block, rollback->idx1, rollback->idx2);
            break;
    }
}

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

struct block* _initialize(lua_State* L, unsigned int num_rows, struct RanState* rstate)
{
    struct block* block = malloc(sizeof(struct block));

    block->num_nets = lua_tointeger(L, 1);

    lua_len(L, 2);
    unsigned int num_cells = lua_tointeger(L, -1);
    lua_pop(L, 1);

    // initialize all_nets
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

static struct floorplan* _create_floorplan(lua_State* L)
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
    floorplan->weight_wirelength = 1.0;
    floorplan->weight_width_penalty = 1.0;
    floorplan->desired_row_width = desired_row_width;

    return floorplan;
}

static void _clean_up(struct block* block, struct floorplan* floorplan)
{
    for(unsigned int i = 0; i < block->num_cells; ++i)
    {
        free((block->cells + i)->nets);
    }
    free(block->cells);
    free(block->row_sizes);
    free(block->nets);
    free(block);
    free(floorplan);
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
                net->xmin = min(net->xmin, col + width + pinoffset);
                net->xmax = max(net->xmax, col + width + pinoffset);
                net->ymin = min(net->ymin, row);
                net->ymax = max(net->ymax, row);
            }
            width += c->width;
        }
    }
}

static void _simulated_annealing(struct RanState* rstate, struct block* block, struct floorplan* floorplan, double coolingfactor, size_t moves_per_cell_per_temp, int verbose)
{
    // FIXME: remove
    (void) verbose;
    (void) moves_per_cell_per_temp;
    (void) coolingfactor;
    (void) floorplan;

    //double temperature = 5000.0;
    //double end_temperature = 0.01;

    //unsigned int needed_steps = (unsigned int) log(temperature / end_temperature) / log(1.0 / coolingfactor) + 1;

    struct UPRNG* cell_rng = UPRNG_init(block->num_cells, rstate);

    //unsigned int steps = 1;
    //unsigned int percentage_divisor = 10;
    //unsigned int percentage = 0;
    unsigned int last_total_penalty = UINT_MAX;

    /* optimize:
     *  - wirelength
     *  - row width distribution (roughly equal row widths)
     *  - rows must not be too wide (this could be allowed at the beginning of annealing)
     */

    for(unsigned int i = 0; i < 500; ++i)
    {
        struct rollback rollback;

        unsigned int idx1 = UPRNG_next(cell_rng);
        unsigned int idx2 = UPRNG_next(cell_rng);
        rollback.idx1 = idx1;
        rollback.idx2 = idx2;
        if(random_choice(rstate, 0.25))
        {
            _move_cell(block, idx1, idx2);
            rollback.what = RB_MOVE;
        }
        else
        {
            _swap_cells(block, idx1, idx2);
            rollback.what = RB_SWAP;
        }
        _update_net_positions(block);
        unsigned int total_wirelength = calculate_total_wirelength(block->nets, block->num_nets);

        //unsigned int total_penalty = get_total_penalty(all_cells, num_cells, total_wirelength, floorplan);
        unsigned int total_penalty = total_wirelength;

        printf("penalty (current / last): %u / %u\n", total_penalty, last_total_penalty);

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
    while(temperature > end_temperature)
    {
        for(unsigned int i = 0; i < num_cells; ++i)
        {
            for(unsigned int j = 0; j < moves_per_cell_per_temp; ++j)
            {
                struct rollback rollback;

                _swap_cells(all_cells, cell_rng, &rollback);
                unsigned int total_wirelength = calculate_total_wirelength(all_nets, num_nets);
                printf("wirelength: %d\n", total_wirelength);

                //unsigned int total_penalty = get_total_penalty(all_cells, num_cells, total_wirelength, floorplan);
                unsigned int total_penalty = total_wirelength;

                if(total_penalty > last_total_penalty)
                {
                    if(random_choice(rstate, exp(-(total_penalty - last_total_penalty) / temperature)))
                    {
                        // accept
                        last_total_penalty = total_penalty;    
                    }
                    else
                    {
                        undo(&rollback, &total_wirelength);
                    }
                }
                else // last_total_penalty >= total_penalty
                {
                    // accept
                    last_total_penalty = total_penalty;
                }

                if(i * j == 0 && verbose)
                {
                    report_status(temperature, all_cells, num_cells, total_wirelength, floorplan);
                }

                if(i * j == 0)
                {
                    if(steps * 100 / needed_steps >= percentage)
                    {
                        printf("placement %2d %% done\n", percentage);
                        percentage += percentage_divisor;
                    }
                }

            }
        }
        ++steps;
        temperature = temperature * coolingfactor;
    }
    */
}

int lplacer_place_simulated_annealing(lua_State* L)
{
    struct RanState rstate;
    srand(time(NULL));
    //randseed(&rstate, rand(), rand());
    randseed(&rstate, 127, 42);

    struct floorplan* floorplan = _create_floorplan(L);

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

/*
static void _all_combinations(struct net* all_nets, size_t num_nets, struct cell* all_cells, size_t num_cells, struct floorplan* floorplan, int verbose)
{
    unsigned int total_wirelength = 0;

    unsigned int row = 0;
    unsigned int* columns = malloc(sizeof(*columns) * num_cells);
    for(unsigned int i = 0; i < num_cells; ++i)
    {
        columns[i] = i;
    }

    total_wirelength = UINT_MAX;
    unsigned int solution = 0;
    unsigned int iteration = 0;
    do {
        for(unsigned int i = 0; i < num_cells; ++i)
        {
            struct cell* c = all_cells + i;
            c->row = row;
            c->column = columns[i];
        }
        unsigned int twl = calculate_total_wirelength(all_nets, num_nets);
        if(twl < total_wirelength)
        {
            total_wirelength = twl;
            solution = iteration;
        }
        ++iteration;
    } while(next_permutation(columns, num_cells));

    // apply solution:
    // * reset columns (need to have a sorted array for permutation algorithm)
    // * re-permute (permute N times)
    // * apply to cells
    for(unsigned int i = 0; i < num_cells; ++i) // reset
    {
        columns[i] = i;
    }
    for(unsigned int i = 0; i < solution; ++i) // re-permute
    {
        next_permutation(columns, num_cells);
    }
    for(unsigned int i = 0; i < num_cells; ++i) // apply
    {
        struct cell* c = all_cells + i;
        c->column = columns[i];
    }
}

int lplacer_place_all_combinations(lua_State* L)
{
    size_t num_nets, num_cells;
    struct net* all_nets;
    struct cell* all_cells;
    _initialize(L, &num_nets, &num_cells, &all_nets, &all_cells);

    struct floorplan* floorplan = _create_floorplan(L);

    lua_getfield(L, 3, "report");
    const int verbose = lua_toboolean(L, -1);
    lua_pop(L, 1);

    struct RanState rstate;
    randseed(&rstate, 145, 17);  // initialize with a "random" seed

    _all_combinations(all_nets, num_nets, all_cells, num_cells, floorplan, verbose);

    //_create_lua_result(L, rows, floorplan->floorplan_height);

    _clean_up(all_nets, num_nets, all_cells, num_cells, floorplan); // AFTER _create_lua_result!

    return 1; // cells table is returned to lua
}
*/

int open_lplacer_lib(lua_State* L)
{
    static const luaL_Reg modfuncs[] =
    {
        { "place_simulated_annealing", lplacer_place_simulated_annealing },
        //{ "place_all_combinations", lplacer_place_all_combinations },
        { NULL,    NULL          }
    };
    lua_newtable(L);
    luaL_setfuncs(L, modfuncs, 0);
    lua_setglobal(L, "placer");
    return 0;
}


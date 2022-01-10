#include <stdlib.h>
#include <stdio.h>
#include <unistd.h>
#include <string.h>
#include <assert.h>
#include <math.h>
#include <limits.h>
#include <time.h>

#include "lua/lauxlib.h"

#include "lplacer_rand.h"

#define MAX_PINS_PER_CELL (10)
#define MAX_PINS_PER_NET (32)

/* Structure definitions  */
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
    struct net* net_conn[MAX_PINS_PER_CELL];
};

struct net {
    unsigned int pinoffset[MAX_PINS_PER_NET];
    struct cell* cell_conn[MAX_PINS_PER_NET];
    unsigned int size;
    unsigned int xmin, xmax;
    unsigned int ymin, ymax;
};

struct rows {
    struct cell* cells;
    unsigned int num_rows;
    unsigned int num_cells;
    unsigned int* row_sizes;
};

static struct cell* _get_cell(struct rows* rows, unsigned int row, unsigned int col)
{
    unsigned int base = 0;
    for(unsigned int i = 0; i < row; ++i)
    {
        base += rows->row_sizes[i];
    }
    return rows->cells + base + col;
}

struct rollback {
    unsigned int idx1;
    unsigned int idx2;
    enum {
        RB_MOVE,
        RB_SWAP
    } what;
};

/*
static unsigned int net_update_wirelength(struct net* n)
{
    unsigned int x_upper = 0;
    unsigned int x_lower = UINT_MAX;
    unsigned int y_upper = 0;
    unsigned int y_lower = UINT_MAX;

    if(!n->cell_conn[0] || !n->cell_conn[1])
    {
        // Net has no connections.
        return 0;
    }
    for(unsigned int i = 0; i < n->size; ++i)
    {
        struct cell* c_p = n->cell_conn[i];
        //unsigned int pinoffset = n->pinoffset[i];
        unsigned int pinoffset = 0;
        if((c_p->column + c_p->width + pinoffset) > x_upper)
        {
            x_upper = c_p->column + pinoffset;
        }
        if((c_p->column + pinoffset) < x_lower)
        {
            x_lower = c_p->column + pinoffset;
        }
        if(c_p->row > y_upper)
        {
            y_upper = c_p->row;
        }
        if(c_p->row < y_lower)
        {
            y_lower = c_p->row;              
        }
    }
    return x_upper - x_lower + y_upper - y_lower;
}
*/

/*
void cell_update_wirelengths(struct cell* c, unsigned int* total_wirelength)
{
    struct net** n_p;
    for(n_p = c->net_conn; *n_p; n_p++)
    {
        *total_wirelength += net_update_wirelength(*n_p);
    }
}
*/

/*
static inline void cell_place_random(struct cell* c, struct UPRNG* col_rng, struct UPRNG* row_rng)
{
    c->column = UPRNG_next(col_rng);
    c->row = UPRNG_next(row_rng);
}
*/

unsigned int calculate_total_wirelength(struct net* all_nets, size_t num_nets)
{
    unsigned int total_wirelength = 0;
    for(size_t i = 0; i < num_nets; ++i)
    {
        struct net* net = all_nets + i;
        unsigned int length = net->xmax - net->xmin + net->ymax - net->ymin;
        total_wirelength += length;
    }
    return total_wirelength;
}

static void _move_cell(struct rows* rows, unsigned int from, unsigned int to)
{
    if(from != to)
    {
        struct cell tmp = rows->cells[from];
        if(from < to)
        {
            for(unsigned int i = from; i < to; ++i)
            {
                rows->cells[i] = rows->cells[i + 1];
            }
        }
        else
        {
            for(unsigned int i = from; i >= to + 1; --i)
            {
                rows->cells[i] = rows->cells[i - 1];
            }
        }
        rows->cells[to] = tmp;
    }
}

static void _swap_cells(struct rows* rows, unsigned int i1, unsigned int i2)
{
    struct cell tmp = rows->cells[i1];
    rows->cells[i1] = rows->cells[i2];
    rows->cells[i2] = tmp;
}

static void undo(struct rows* rows, struct rollback* rollback)
{
    switch(rollback->what)
    {
        case RB_MOVE:
            _move_cell(rows, rollback->idx2, rollback->idx1);
            break;
        case RB_SWAP:
            _swap_cells(rows, rollback->idx1, rollback->idx2);
            break;
    }
}

/*
struct cell** get_cells_of_row(struct cell* all_cells, size_t num_cells, unsigned int row, size_t* num_in_row)
{
    size_t capacity = 40;
    size_t cur_cell_idx = 0;
    struct cell** cells_in_row = calloc(capacity, sizeof(struct cell*));
    for(size_t i = 0; i < num_cells; ++i)
    {
        struct cell* c = all_cells + i;
        if(c->row == row)
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
*/

/*
void get_legality_penalty(struct cell* all_cells, size_t num_cells, struct floorplan* floorplan, unsigned int* too_wide_penalty, unsigned int* total_width_penalty, unsigned int* out_of_bounds_penalty)
{
    unsigned int total_width_value = 0;
    unsigned int too_wide_value = 0;
    unsigned int out_of_bounds = 0;

    for(unsigned int row = 0; row < floorplan->floorplan_height; row++)
    {
        struct cell** cells_in_row = get_cells_of_row(all_cells, num_cells, row, NULL);

        unsigned int row_cell_width_sum = 0;

        unsigned int maxx = 0;
        for(struct cell** c_p = cells_in_row; *c_p; c_p++)
        {
            row_cell_width_sum += (*c_p)->width;
            if((*c_p)->column + (*c_p)->width - 1 > maxx)
            {
                maxx = (*c_p)->column + (*c_p)->width - 1;
            }
        } 
        if(maxx > floorplan->floorplan_width)
        {
            out_of_bounds += maxx - floorplan->floorplan_width;
        }
        total_width_value += floorplan->desired_row_width > row_cell_width_sum ? floorplan->desired_row_width - row_cell_width_sum : row_cell_width_sum - floorplan->desired_row_width ;
        if(row_cell_width_sum > floorplan->floorplan_width)
        {
            too_wide_value = row_cell_width_sum - floorplan->floorplan_width;
        }
        // clean up
        free(cells_in_row);
    }
    *too_wide_penalty= too_wide_value;
    *total_width_penalty = total_width_value;
    *out_of_bounds_penalty = out_of_bounds;
}
*/

/*
unsigned int get_total_penalty(struct cell* all_cells, size_t num_cells, int total_wirelength, struct floorplan* floorplan)
{
    int wirelength = total_wirelength;
    unsigned int too_wide_penalty;
    unsigned int total_width_penalty;
    unsigned int out_of_bounds_penalty;
    get_legality_penalty(all_cells, num_cells, floorplan, &too_wide_penalty, &total_width_penalty, &out_of_bounds_penalty);
    unsigned int total_penalty = floorplan->weight_wirelength * wirelength + too_wide_penalty;
    return total_penalty;
}
*/

/*
void report_status(double temperature, struct cell* all_cells, size_t num_cells, int total_wirelength, struct floorplan* floorplan)
{
    int wirelength = total_wirelength;
    unsigned int too_wide_penalty;
    unsigned int total_width_penalty;
    unsigned int out_of_bounds_penalty;
    get_legality_penalty(all_cells, num_cells, floorplan, &too_wide_penalty, &total_width_penalty, &out_of_bounds_penalty);
    unsigned int total_penalty = floorplan->weight_wirelength * wirelength + too_wide_penalty;
    puts("--------------------");
    for(size_t i = 0; i < num_cells; ++i)
    {
        struct cell* c = all_cells + i;
        printf("%s: pos = (%i, %i)\n", c->name, c->column, c->row);
    }
    puts("--------------------");
    printf("temperature = %.3f, ", temperature);
    printf("total_penalty = %d, wirelength = %d, too_wide_penalty = %d, total_width_penalty = %d, out_of_bounds_penalty = %d\n", total_penalty, wirelength, too_wide_penalty, total_width_penalty, out_of_bounds_penalty);
}
*/

/*
static int _cell_cmp(const void* p1, const void* p2)
{
    struct cell* const * c1 = p1;
    struct cell* const * c2 = p2;
    if((*c1)->column > (*c2)->column)
    {
        return 1;
    }
    else if((*c1)->column < (*c2)->column)
    {
        return -1;
    }
    else
    {
        return 0;
    }
}
*/

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

static void _update_net_struct_ptrs(struct net* all_nets, size_t num_nets, struct rows* rows)
{
    struct net** n_p;
    int pin_idx;

    for(size_t i = 0; i < num_nets; ++i)
    {
        struct net* n = all_nets + i;
        pin_idx = 0;
        for(size_t i = 0; i < rows->num_cells; ++i)
        {
            struct cell* c = rows->cells + i;
            for(n_p = c->net_conn; *n_p; n_p++)
            {
                if(*n_p == n)
                {
                    n->cell_conn[pin_idx++] = c;
                    if(pin_idx >= MAX_PINS_PER_NET)
                    {
                        fprintf(stderr, "%s\n", "Error: More than MAX_PINS_PER_NET connections to net");
                        exit(1);
                    }
                }
            }
            n->size = pin_idx;
            n->cell_conn[pin_idx] = NULL;
        }    
    }
}

struct rows* _initialize(lua_State* L, unsigned int num_rows, struct RanState* rstate, size_t* num_nets, struct net** all_nets)
{
    *num_nets = lua_tointeger(L, 1);

    lua_len(L, 2);
    unsigned int num_cells = lua_tointeger(L, -1);
    lua_pop(L, 1);

    // initialize all_nets
    struct net* all_nets_tmp = calloc(*num_nets, sizeof(struct net));
    *all_nets = all_nets_tmp;

    // initialize all_cells
    struct rows* rows = malloc(sizeof(*rows));
    rows->num_cells = num_cells;
    rows->num_rows = num_rows;
    rows->row_sizes = calloc(num_rows, sizeof(*rows->row_sizes));
    if(num_rows > 1)
    {
        for(unsigned int i = 0; i < num_rows - 1; ++i)
        {
            rows->row_sizes[i] = rows->num_cells / num_rows;
        }
        rows->row_sizes[rows->num_rows - 1] = rows->num_cells - (rows->num_cells / num_rows) * (num_rows - 1);
    }
    else
    {
        rows->row_sizes[0] = rows->num_cells;
    }
    rows->cells = calloc(rows->num_cells, sizeof(*rows->cells));

    for(size_t i = 1; i <= num_cells; ++i)
    {
        lua_geti(L, 2, i);

        struct cell* c = rows->cells + i - 1;

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

        // net_conn
        lua_getfield(L, -1, "net_conn");
        lua_len(L, -1);
        size_t numconns = lua_tointeger(L, -1);
        lua_pop(L, 1);
        for(size_t j = 1; j <= numconns; ++j)
        {
            lua_geti(L, -1, j);
            int index = lua_tointeger(L, -1);
            c->net_conn[j - 1] = &all_nets_tmp[index - 1];
            lua_pop(L, 1);
        }
        lua_pop(L, 1);
    }

    // shuffle cells
    for (unsigned int i = num_cells - 1; i > 0; i--)
    {
        unsigned int j = _lua_randi(rstate, 0, i);
        struct cell tmp = rows->cells[j];
        rows->cells[j] = rows->cells[i];
        rows->cells[i] = tmp;
    }

    _update_net_struct_ptrs(*all_nets, *num_nets, rows);

    return rows;
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

static void _clean_up(struct rows* rows, struct net* all_nets, struct floorplan* floorplan)
{
    // free memory (after pushing results to lua)
    free(rows); // FIXME: free internal stuff
    free(all_nets);
    free(floorplan);
}

/*
static void _create_lua_result(lua_State* L, struct cell* all_cells, size_t num_cells, struct floorplan* floorplan)
{
    // bring back results to lua
    lua_newtable(L);
    for(unsigned int cur_row = 0; cur_row < floorplan->floorplan_height; cur_row++)
    {
        size_t numcellrows;
        struct cell** cells_in_row = get_cells_of_row(all_cells, num_cells, cur_row, &numcellrows);
        qsort(cells_in_row, numcellrows, sizeof(struct cell*), &_cell_cmp);
        lua_newtable(L);
        int i = 1;
        for(struct cell** c = cells_in_row; *c; ++c)
        {
            lua_newtable(L);
            lua_pushstring(L, "reference");
            lua_pushinteger(L, (*c)->reference);
            lua_settable(L, -3);
            lua_pushstring(L, "instance");
            lua_pushinteger(L, (*c)->instance);
            lua_settable(L, -3);
            lua_seti(L, -2, i);
            ++i;
        }
        lua_seti(L, -2, cur_row + 1);
        free(cells_in_row);
    }
}
*/

static void _create_lua_result(lua_State* L, struct rows* rows)
{
    // bring back results to lua
    lua_newtable(L);
    for(unsigned int row = 0; row < rows->num_rows; row++)
    {
        lua_newtable(L);
        int i = 1;
        for(unsigned int col = 0; col < rows->row_sizes[row]; col++)
        {
            struct cell* c = _get_cell(rows, row, col);
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
        int k = (len - 1 - j) / 2; // number of pairs to swap
        for (int i = 0; i < k; i++)
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

static void _update_net_positions(struct rows* rows, struct net* all_nets, size_t num_nets)
{
    // reset positions
    for(unsigned int i = 0; i < num_nets; ++i)
    {
        struct net* net = all_nets + i;
        net->xmin = UINT_MAX;
        net->xmax = 0;
        net->ymin = UINT_MAX;
        net->ymax = 0;
    }
    // update positions
    for(unsigned int row = 0; row < rows->num_rows; row++)
    {
        unsigned int width = 0;
        for(unsigned int col = 0; col < rows->row_sizes[row]; col++)
        {
            struct cell* c = _get_cell(rows, row, col);
            for(struct net** netptr = c->net_conn; *netptr; ++netptr)
            {
                struct net* net = *netptr;
                net->xmin = min(net->xmin, col + width);
                net->xmax = max(net->xmax, col + width);
                net->ymin = min(net->ymin, row);
                net->ymax = max(net->ymax, row);
            }
            width += c->width;
        }
    }
}

static void _simulated_annealing(struct RanState* rstate, struct net* all_nets, size_t num_nets, struct rows* rows, struct floorplan* floorplan, double coolingfactor, size_t moves_per_cell_per_temp, int verbose)
{
    // FIXME: remove
    (void) verbose;
    (void) moves_per_cell_per_temp;
    (void) coolingfactor;

    //double temperature = 5000.0;
    //double end_temperature = 0.01;

    //unsigned int needed_steps = (unsigned int) log(temperature / end_temperature) / log(1.0 / coolingfactor) + 1;

    struct UPRNG* cell_rng = UPRNG_init(rows->num_cells, rstate);

    //unsigned int steps = 1;
    //unsigned int percentage_divisor = 10;
    //unsigned int percentage = 0;
    unsigned int last_total_penalty = UINT_MAX;

    /* optimize:
     *  - wirelength
     *  - row width distribution (roughly equal row widths)
     *  - rows must not be too wide (this could be allowed at the beginning of annealing)
     */

    _update_net_positions(rows, all_nets, num_nets);
    unsigned int total_wirelength = calculate_total_wirelength(all_nets, num_nets);
    printf("wirelength: %d\n", total_wirelength);
    for(unsigned int i = 0; i < 5; ++i)
    {
        struct rollback rollback;

        unsigned int idx1 = UPRNG_next(cell_rng);
        unsigned int idx2 = UPRNG_next(cell_rng);
        rollback.idx1 = idx1;
        rollback.idx2 = idx2;
        if(random_choice(rstate, 0.25))
        {
            _move_cell(rows, idx1, idx2);
            rollback.what = RB_MOVE;
        }
        else
        {
            _swap_cells(rows, idx1, idx2);
            rollback.what = RB_SWAP;
        }
        _update_net_positions(rows, all_nets, num_nets);
        unsigned int total_wirelength = calculate_total_wirelength(all_nets, num_nets);

        //unsigned int total_penalty = get_total_penalty(all_cells, num_cells, total_wirelength, floorplan);
        unsigned int total_penalty = total_wirelength;

        printf("penalty (current / last): %u / %u\n", total_penalty, last_total_penalty);

        if(total_penalty > last_total_penalty)
        {
            undo(rows, &rollback);
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

    size_t num_nets;
    struct net* all_nets;
    struct rows* rows = _initialize(L, floorplan->floorplan_height, &rstate, &num_nets, &all_nets);

    lua_getfield(L, 3, "movespercell");
    const size_t moves_per_cell_per_temp = lua_tointeger(L, -1);
    lua_pop(L, 1);

    lua_getfield(L, 3, "coolingfactor");
    const double coolingfactor = lua_tonumber(L, -1);
    lua_pop(L, 1);

    lua_getfield(L, 3, "report");
    const int verbose = lua_toboolean(L, -1);
    lua_pop(L, 1);

    _simulated_annealing(&rstate, all_nets, num_nets, rows, floorplan, coolingfactor, moves_per_cell_per_temp, verbose);

    _create_lua_result(L, rows);

    _clean_up(rows, all_nets, floorplan); // AFTER _create_lua_result!

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


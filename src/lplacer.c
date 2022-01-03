#include <stdlib.h>
#include <stdio.h>
#include <unistd.h>
#include <string.h>
#include <assert.h>
#include <math.h>
#include <limits.h>

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
    char* name;
    unsigned int reference;
    unsigned int width;
    unsigned int column;
    unsigned int row;
    struct net* net_conn[MAX_PINS_PER_CELL];
};

struct net {
    //char* name;
    unsigned int pin_conn[MAX_PINS_PER_NET];
    struct cell* cell_conn[MAX_PINS_PER_NET];
    unsigned int size;
};

struct rollback {
    struct cell* c1;
    unsigned int x1;
    unsigned int y1;
    struct cell* c2;
    unsigned int x2;
    unsigned int y2;
};

static unsigned int net_update_wirelength(struct net* n, unsigned int** pinoffsets)
{
    unsigned int x_upper = 0;
    unsigned int x_lower = UINT_MAX;
    unsigned int y_upper = 0;
    unsigned int y_lower = UINT_MAX;

    if(!n->cell_conn[0])
    {
        // Net has no connections.
        return 0;
    }
    for(unsigned int i = 0; i < n->size; ++i)
    {
        struct cell* c_p = n->cell_conn[i];
        //unsigned int pinoffset = pinoffsets[c_p->reference][n->pin_conn[i]];
        unsigned int pinoffset = 0;
        if((c_p->column + pinoffset) > x_upper)
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

void cell_update_wirelengths(struct cell* c, unsigned int** pinoffsets, unsigned int* total_wirelength)
{
    struct net** n_p;
    for(n_p = c->net_conn; *n_p; n_p++)
    {
        *total_wirelength += net_update_wirelength(*n_p, pinoffsets);
    }
}

static inline void cell_place_random(struct cell* c, struct UPRNG* col_rng, struct UPRNG* row_rng)
{
    c->column = UPRNG_next(col_rng);
    c->row = UPRNG_next(row_rng);
}

void update_net_struct_ptrs(struct net* all_nets, size_t num_nets, struct cell* all_cells, size_t num_cells)
{
    struct net** n_p;
    int pin_idx;

    for(size_t i = 0; i < num_nets; ++i)
    {
        struct net* n = all_nets + i;
        pin_idx = 0;
        for(size_t i = 0; i < num_cells; ++i)
        {
            struct cell* c = all_cells + i;
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

unsigned int calculate_total_wirelength(struct net* all_nets, size_t num_nets, unsigned int** pinoffsets)
{
    unsigned int total_wirelength = 0;
    for(size_t i = 0; i < num_nets; ++i)
    {
        struct net* n = all_nets + i;
        unsigned int length = net_update_wirelength(n, pinoffsets);
        total_wirelength += length;
    }
    return total_wirelength;
}

void undo(struct rollback* rollback, unsigned int** pinoffsets, unsigned int* total_wirelength)
{
    if(rollback->c1)
    {
        rollback->c1->column = rollback->x1;
        rollback->c1->row = rollback->y1;
        cell_update_wirelengths(rollback->c1, pinoffsets, total_wirelength);
    }
    if(rollback->c2)
    {
        rollback->c2->column = rollback->x2;
        rollback->c2->row = rollback->y2;
        cell_update_wirelengths(rollback->c2, pinoffsets, total_wirelength);
    }
}

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

void place_initial_random(unsigned int num_rows, unsigned int* row_indices, struct UPRNG* cell_rng, struct cell* all_cells, unsigned int num_cells)
{
    unsigned int row = 0;
    for(unsigned int i = 0; i < num_cells; ++i)
    {
        struct cell* c = all_cells + UPRNG_next(cell_rng);
        c->row = row;
        c->column = row_indices[row];
        ++row_indices[row];
        row = (row + 1) % num_rows;
    }
}

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

/* Operations M1 and M2 for simulated annealing
 * --------------------------------------------
 */

/*
void m1(struct cell* c, struct UPRNG* col_rng, struct UPRNG* row_rng, struct rollback* rollback, int* total_wirelength)
{
    rollback->c1 = c;
    rollback->x1 = c->column;
    rollback->y1 = c->row;
    rollback->c2 = NULL;
    cell_place_random(c, col_rng, row_rng);
    cell_update_wirelengths(c, total_wirelength);
}

void m2(struct cell* c1, struct cell* c2, struct rollback* rollback, int* total_wirelength)
{
    rollback->c1 = c1;
    rollback->x1 = c1->column;
    rollback->y1 = c1->row;
    rollback->c2 = c2;
    rollback->x2 = c2->column;
    rollback->y2 = c2->row;

    // swap cell positions
    c1->column = c2->column;
    c1->row = c2->row;
    c2->column = rollback->x1;
    c2->row = rollback->y1;

    cell_update_wirelengths(c1, total_wirelength);
    cell_update_wirelengths(c2, total_wirelength);
}
*/
static void _swap_cells(struct cell* all_cells, struct UPRNG* cell_rng, struct rollback* rollback)
{
    struct cell* c1 = all_cells + UPRNG_next(cell_rng);
    struct cell* c2 = all_cells + UPRNG_next(cell_rng);
    rollback->c1 = c1;
    rollback->x1 = c1->column;
    rollback->y1 = c1->row;
    rollback->c2 = c2;
    rollback->x2 = c2->column;
    rollback->y2 = c2->row;

    // swap cell positions
    c1->column = c2->column;
    c1->row = c2->row;
    c2->column = rollback->x1;
    c2->row = rollback->y1;
}

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

void _initialize(lua_State* L, size_t* num_nets, size_t* num_cells, struct net** all_nets, struct cell** all_cells, unsigned int*** pinoffsets)
{
    lua_len(L, 1);
    *num_nets = lua_tointeger(L, -1);
    lua_pop(L, 1);

    lua_len(L, 2);
    *num_cells = lua_tointeger(L, -1);
    lua_pop(L, 1);

    // initialize all_nets
    struct net* all_nets_tmp = calloc(*num_nets, sizeof(struct net));
    //for(size_t i = 1; i <= *num_nets; ++i)
    //{
    //    lua_geti(L, 1, i);
    //    size_t len = 0;
    //    const char* name = lua_tolstring(L, -1, &len);
    //    all_nets_tmp[i - 1].name = malloc(len + 1);
    //    strncpy(all_nets_tmp[i - 1].name, name, len + 1);
    //    lua_pop(L, 1);
    //}
    *all_nets = all_nets_tmp;

    // initialize all_cells
    struct cell* all_cells_tmp = calloc(*num_cells, sizeof(struct cell));
    for(size_t i = 1; i <= *num_cells; ++i)
    {
        lua_geti(L, 2, i);
        size_t len = 0;

        // name
        lua_getfield(L, -1, "instance");
        const char* name = lua_tolstring(L, -1, &len);
        all_cells_tmp[i - 1].name = malloc(len + 1);
        strncpy(all_cells_tmp[i - 1].name, name, len + 1);
        lua_pop(L, 1);

        // reference
        lua_getfield(L, -1, "reference");
        all_cells_tmp[i - 1].reference = lua_tointeger(L, -1);
        lua_pop(L, 1);

        // width
        lua_getfield(L, -1, "width");
        all_cells_tmp[i - 1].width = lua_tointeger(L, -1);
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
            all_cells_tmp[i - 1].net_conn[j - 1] = &all_nets_tmp[index - 1];
            lua_pop(L, 1);
        }
        lua_pop(L, 1);

    }
    *all_cells = all_cells_tmp;

    update_net_struct_ptrs(*all_nets, *num_nets, *all_cells, *num_cells);
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

static void _clean_up(struct net* all_nets, size_t num_nets, struct cell* all_cells, size_t num_cells, struct floorplan* floorplan)
{
    // free memory (after pushing results to lua)
    //for(size_t i = 0; i < num_nets; ++i)
    //{
    //    free(all_nets[i].name);
    //}
    free(all_nets);
    for(size_t i = 1; i <= num_cells; ++i)
    {
        free(all_cells[i - 1].name);
    }
    free(all_cells);

    free(floorplan);
}

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
            lua_pushstring(L, (*c)->name);
            lua_settable(L, -3);
            lua_seti(L, -2, i);
            ++i;
        }
        lua_seti(L, -2, cur_row + 1);
        free(cells_in_row);
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

static void _simulated_annealing(struct RanState* rstate, struct net* all_nets, size_t num_nets, struct cell* all_cells, size_t num_cells, unsigned int** pinoffsets, struct floorplan* floorplan, double coolingfactor, size_t moves_per_cell_per_temp, int verbose)
{
    double temperature = 5000.0;
    double end_temperature = 0.01;

    unsigned int needed_steps = (unsigned int) log(temperature / end_temperature) / log(1.0 / coolingfactor) + 1;

    struct UPRNG* cell_rng = UPRNG_init(num_cells, rstate);

    unsigned int steps = 1;
    unsigned int percentage_divisor = 10;
    unsigned int percentage = 0;
    unsigned int last_total_penalty = UINT_MAX;

    unsigned int* row_indices = malloc(floorplan->floorplan_height * sizeof(unsigned int));
    for(unsigned int i = 0; i < floorplan->floorplan_height; ++i)
    {
        row_indices[i] = 0;
    }

    place_initial_random(floorplan->floorplan_height, row_indices, cell_rng, all_cells, num_cells);
    /* optimize:
     *  - wirelength
     *  - row width distribution (roughly equal row widths)
     *  - rows must not be too wide (this could be allowed at the beginning of annealing)
     */

    unsigned int total_wirelength = calculate_total_wirelength(all_nets, num_nets, pinoffsets);
    //printf("wirelength: %d\n", total_wirelength);
    for(unsigned int i = 0; i < 50; ++i)
    {
        struct rollback rollback;

        _swap_cells(all_cells, cell_rng, &rollback);
        unsigned int total_wirelength = calculate_total_wirelength(all_nets, num_nets, pinoffsets);
        //printf("wirelength: %d\n", total_wirelength);

        //unsigned int total_penalty = get_total_penalty(all_cells, num_cells, total_wirelength, floorplan);
        unsigned int total_penalty = total_wirelength;

        if(total_penalty > last_total_penalty)
        {
            undo(&rollback, pinoffsets, &total_wirelength);
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
    size_t num_nets, num_cells;
    struct net* all_nets;
    struct cell* all_cells;
    unsigned int** pinoffsets;
    _initialize(L, &num_nets, &num_cells, &all_nets, &all_cells, &pinoffsets);

    struct floorplan* floorplan = _create_floorplan(L);

    lua_getfield(L, 3, "movespercell");
    const size_t moves_per_cell_per_temp = lua_tointeger(L, -1);
    lua_pop(L, 1);

    lua_getfield(L, 3, "coolingfactor");
    const double coolingfactor = lua_tonumber(L, -1);
    lua_pop(L, 1);

    lua_getfield(L, 3, "report");
    const int verbose = lua_toboolean(L, -1);
    lua_pop(L, 1);

    struct RanState rstate;
    randseed(&rstate, 145, 17);  /* initialize with a "random" seed */

    _simulated_annealing(&rstate, all_nets, num_nets, all_cells, num_cells, pinoffsets, floorplan, coolingfactor, moves_per_cell_per_temp, verbose);

    _create_lua_result(L, all_cells, num_cells, floorplan);

    _clean_up(all_nets, num_nets, all_cells, num_cells, floorplan); // AFTER _create_lua_result!

    return 1; // cells table is returned to lua
}

static void _all_combinations(struct net* all_nets, size_t num_nets, struct cell* all_cells, size_t num_cells, unsigned int** pinoffsets, struct floorplan* floorplan, int verbose)
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
        unsigned int twl = calculate_total_wirelength(all_nets, num_nets, pinoffsets);
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
    unsigned int** pinoffsets;
    _initialize(L, &num_nets, &num_cells, &all_nets, &all_cells, &pinoffsets);

    struct floorplan* floorplan = _create_floorplan(L);

    lua_getfield(L, 3, "report");
    const int verbose = lua_toboolean(L, -1);
    lua_pop(L, 1);

    struct RanState rstate;
    randseed(&rstate, 145, 17);  /* initialize with a "random" seed */

    _all_combinations(all_nets, num_nets, all_cells, num_cells, pinoffsets, floorplan, verbose);

    _create_lua_result(L, all_cells, num_cells, floorplan);

    _clean_up(all_nets, num_nets, all_cells, num_cells, floorplan); // AFTER _create_lua_result!

    return 1; // cells table is returned to lua
}

int open_lplacer_lib(lua_State* L)
{
    static const luaL_Reg modfuncs[] =
    {
        { "place_simulated_annealing", lplacer_place_simulated_annealing },
        { "place_all_combinations", lplacer_place_all_combinations },
        { NULL,    NULL          }
    };
    lua_newtable(L);
    luaL_setfuncs(L, modfuncs, 0);
    lua_setglobal(L, "placer");
    return 0;
}


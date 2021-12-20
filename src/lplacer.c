#include <stdlib.h>
#include <stdio.h>
#include <stdbool.h>
#include <unistd.h>
#include <string.h>
#include <assert.h>
#include <math.h>
#include <limits.h>

#include "lua/lauxlib.h"

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
    int total_wirelength;
    // limiter window
    int limiter_width;
    int limiter_height;
};

struct cell {
    char* instance_name;
    char* reference_name;
    unsigned int width;
    unsigned int pos_x;
    unsigned int pos_y;
    struct net* net_conn[MAX_PINS_PER_CELL];
};

struct rollback {
    struct cell* c1;
    unsigned int x1;
    unsigned int y1;
    struct cell* c2;
    unsigned int x2;
    unsigned int y2;
};

struct net {
    char* net_name;
    struct cell* cell_conn[MAX_PINS_PER_NET];
    int halfperi_wirelength;
};

/* Placement helper functions
 * --------------------------
 */
#define Rand64		unsigned long
typedef struct {
  Rand64 s[4];
} RanState;

/* avoid using extra bits when needed */
#define trim64(x)	((x) & 0xffffffffffffffffu)

/* rotate left 'x' by 'n' bits */
static Rand64 rotl (Rand64 x, int n) {
  return (x << n) | (trim64(x) >> (64 - n));
}

static Rand64 nextrand(RanState *state)
{
    Rand64 state0 = state->s[0];
    Rand64 state1 = state->s[1];
    Rand64 state2 = state->s[2] ^ state0;
    Rand64 state3 = state->s[3] ^ state1;
    Rand64 res = rotl(state1 * 5, 7) * 9;
    state->s[0] = state0 ^ state3;
    state->s[1] = state1 ^ state2;
    state->s[2] = state2 ^ (state1 << 17);
    state->s[3] = rotl(state3, 45);
    return res;
}


static void randseed (RanState *state, unsigned long n1, unsigned long n2)
{
    int i;
    state->s[0] = (Rand64)(n1);
    state->s[1] = (Rand64)(0xff);  /* avoid a zero state */
    state->s[2] = (Rand64)(n2);
    state->s[3] = (Rand64)(0);
    for (i = 0; i < 16; i++)
    {
        nextrand(state);  /* discard initial values to "spread" seed */
    }
}

/* convert a 'Rand64' to a 'unsigned long' */
#define I2UInt(x)	((unsigned long)trim64(x))

/*
** Project the random integer 'ran' into the interval [0, n].
** Because 'ran' has 2^B possible values, the projection can only be
** uniform when the size of the interval is a power of 2 (exact
** division). Otherwise, to get a uniform projection into [0, n], we
** first compute 'lim', the smallest Mersenne number not smaller than
** 'n'. We then project 'ran' into the interval [0, lim].  If the result
** is inside [0, n], we are done. Otherwise, we try with another 'ran',
** until we have a result inside the interval.
*/
static unsigned long project (unsigned long ran, unsigned long n,
                             RanState *state) {
  if ((n & (n + 1)) == 0)  /* is 'n + 1' a power of 2? */
    return ran & n;  /* no bias */
  else {
    unsigned long lim = n;
    /* compute the smallest (2^b - 1) not smaller than 'n' */
    lim |= (lim >> 1);
    lim |= (lim >> 2);
    lim |= (lim >> 4);
    lim |= (lim >> 8);
    lim |= (lim >> 16);
#if (LUA_MAXUNSIGNED >> 31) >= 3
    lim |= (lim >> 32);  /* integer type has more than 32 bits */
#endif
    while ((ran &= lim) > n)  /* project 'ran' into [0..lim] */
      ran = I2UInt(nextrand(state));  /* not inside [0..n]? try again */
    return ran;
  }
}

#define FIGS 64
/* must throw out the extra (64 - FIGS) bits */
#define shift64_FIG	(64 - FIGS)

/* to scale to [0, 1), multiply by scaleFIG = 2^(-FIGS) */
#define scaleFIG	(l_mathop(0.5) / ((Rand64)1 << (FIGS - 1)))

static double I2d (Rand64 x) {
  return (double)(trim64(x) >> shift64_FIG) * scaleFIG;
}

static double _lua_rand(RanState* state)
{
    Rand64 rv = nextrand(state);  /* next pseudo-random value */
    return I2d(rv);  /* float between 0 and 1 */
}

static long _lua_randi(RanState* state, long low, long up)
{
    Rand64 rv = nextrand(state);  /* next pseudo-random value */
    /* project random integer into the interval [0, up - low] */
    unsigned long p;
    p = project(I2UInt(rv), (unsigned long)up - (unsigned long)low, state);
    return p + (unsigned long)low;
}

/* Returns random boolean, which is true by probability prob */
bool random_choice(RanState* rstate, double prob)
{
    double r = _lua_rand(rstate);
    return r < prob;
}

static inline void net_update_wirelength(struct net* n, int* total_wirelength)
{
    unsigned int x_upper, x_lower, y_upper, y_lower;

    *total_wirelength -= n->halfperi_wirelength;

    if(!n->cell_conn[0])
    {
        // Net has no connections.
        n->halfperi_wirelength = 0;
        return;
    }
    x_upper = x_lower = n->cell_conn[0]->pos_x;
    y_upper = y_lower = n->cell_conn[0]->pos_y;
    struct cell** c_p;
    for(c_p = n->cell_conn + 1; *c_p; c_p++)
    {
        if((*c_p)->pos_x > x_upper)
        {
            x_upper = (*c_p)->pos_x;
        }
        if((*c_p)->pos_x < x_lower)
        {
            x_lower = (*c_p)->pos_x;
        }
        if((*c_p)->pos_y > y_upper)
        {
            y_upper = (*c_p)->pos_y;
        }
        if((*c_p)->pos_y < y_lower)
        {
            y_lower = (*c_p)->pos_y;              
        }
    }
    n->halfperi_wirelength = (x_upper - x_lower) + (y_upper - y_lower);

    *total_wirelength += n->halfperi_wirelength;
}

void cell_update_wirelengths(struct cell* c, struct floorplan* floorplan)
{
    struct net** n_p;
    for(n_p = c->net_conn; *n_p; n_p++)
    {
        net_update_wirelength(*n_p, &floorplan->total_wirelength);
    }
}

static inline void cell_place_random(RanState* rstate, struct cell* c, struct floorplan* floorplan)
{
    c->pos_x = _lua_randi(rstate, 0, floorplan->floorplan_width - 1);
    c->pos_y = _lua_randi(rstate, 0, floorplan->floorplan_height - 1);
}

void update_net_struct_ptrs(struct net* all_nets, size_t num_nets, struct cell* all_cells, size_t num_cells)
{
    struct net** n_p;
    int pin_idx;

    for(size_t i = 0; i < num_nets; ++i)
    {
        struct net* n = all_nets + i;
        pin_idx = 0;
        n->halfperi_wirelength = 0;
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
                        fprintf(stderr, "Error: More than MAX_PINS_PER_NET connections to net %s.\n", n->net_name);
                        exit(1);
                    }
                }
            }
            n->cell_conn[pin_idx] = NULL;
        }    
    }
}

void calculate_total_wirelength(struct net* all_nets, size_t num_nets, int* total_wirelength)
{
    *total_wirelength = 0;
    for(size_t i = 0; i < num_nets; ++i)
    {
        struct net* n = all_nets + i;
        n->halfperi_wirelength = 0;
        net_update_wirelength(n, total_wirelength);
        //total_wirelength += n->halfperi_wirelength;
    }
}

void undo(struct rollback* r, struct floorplan* floorplan)
{
    if(r->c1)
    {
        r->c1->pos_x = r->x1;
        r->c1->pos_y = r->y1;
        cell_update_wirelengths(r->c1, floorplan);
    }
    if(r->c2)
    {
        r->c2->pos_x = r->x2;
        r->c2->pos_y = r->y2;
        cell_update_wirelengths(r->c2, floorplan);
    }
}

struct cell* random_cell(RanState* rstate, struct cell* all_cells, size_t num_cells)
{
    return all_cells + _lua_randi(rstate, 0, num_cells - 1);
}

struct cell** get_cells_of_row(struct cell* all_cells, size_t num_cells, unsigned int cur_row, size_t* num_in_row)
{
    size_t capacity = 40;
    size_t cur_cell_idx = 0;
    struct cell** cells_in_row = calloc(capacity, sizeof(struct cell*));
    for(size_t i = 0; i < num_cells; ++i)
    {
        struct cell* c = all_cells + i;
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

void _ensure_capacity(int** occupancy, size_t* capacity, unsigned int index)
{
    if(index >= *capacity)
    {
        size_t old_capacity = *capacity;
        while(index >= *capacity)
        {
            *capacity *= 2;
        }
        int* tmp = realloc(*occupancy, *capacity * sizeof(int));
        if(tmp)
        {
            *occupancy = tmp;
            memset(*occupancy + old_capacity, 0, (*capacity - old_capacity) * sizeof(int));
        }
        else
        {
            assert(0);
        }
    }
}

void get_legality_penalty(struct cell* all_cells, size_t num_cells, struct floorplan* floorplan, unsigned int* overlap_penalty, unsigned int* too_wide_penalty, unsigned int* total_width_penalty, unsigned int* out_of_bounds_penalty)
{
    unsigned int total_overlap = 0;
    unsigned int total_width_value = 0;
    unsigned int too_wide_value = 0;
    unsigned int out_of_bounds = 0;

    for(unsigned int cur_row = 0; cur_row < floorplan->floorplan_height; cur_row++)
    {
        struct cell** cells_in_row = get_cells_of_row(all_cells, num_cells, cur_row, NULL);

        size_t capacity = 2;
        int* occupancy = malloc(capacity * sizeof(int));
        memset(occupancy, 0, capacity * sizeof(int));

        unsigned int row_cell_width_sum = 0;

        unsigned int maxx = 0;
        for(struct cell** c_p = cells_in_row; *c_p; c_p++)
        {
            row_cell_width_sum += (*c_p)->width;
            for(unsigned int i = 0; i < (*c_p)->width; i++)
            {
                unsigned int index = (*c_p)->pos_x + i;
                _ensure_capacity(&occupancy, &capacity, index);
                occupancy[index]++;
            }
            if((*c_p)->pos_x + (*c_p)->width - 1 > maxx)
            {
                maxx = (*c_p)->pos_x + (*c_p)->width - 1;
            }
        } 
        if(maxx > floorplan->floorplan_width)
        {
            out_of_bounds += maxx - floorplan->floorplan_width;
        }
        unsigned int row_overlap = 0;
        for(size_t i = 0; i < capacity; i++)
        {
            if(occupancy[i] > 1)
            {
                row_overlap += occupancy[i] - 1;
            }
        }
        total_overlap += row_overlap;
        total_width_value += floorplan->desired_row_width > row_cell_width_sum ? floorplan->desired_row_width - row_cell_width_sum : row_cell_width_sum - floorplan->desired_row_width ;
        if(row_cell_width_sum > floorplan->floorplan_width)
        {
            too_wide_value = row_cell_width_sum - floorplan->floorplan_width;
        }
        // clean up
        free(occupancy);
        free(cells_in_row);
    }
    //return total_overlap * total_overlap + floorplan->weight_width_penalty * total_width_penalty;
    //return total_overlap + too_wide_penalty;
    *overlap_penalty = total_overlap;
    *too_wide_penalty= too_wide_value;
    *total_width_penalty = total_width_value;
    *out_of_bounds_penalty = out_of_bounds;
}

void place_initial_random(RanState* rstate, struct cell* all_cells, size_t num_cells, struct floorplan* floorplan)
{
    for(size_t i = 0; i < num_cells; ++i)
    {
        struct cell* c = all_cells + i;
        cell_place_random(rstate, c, floorplan);
        cell_update_wirelengths(c, floorplan);
    }
}

unsigned int get_total_penalty(struct cell* all_cells, size_t num_cells, struct floorplan* floorplan)
{
    int wirelength = floorplan->total_wirelength;
    unsigned int overlap_penalty;
    unsigned int too_wide_penalty;
    unsigned int total_width_penalty;
    unsigned int out_of_bounds_penalty;
    get_legality_penalty(all_cells, num_cells, floorplan, &overlap_penalty, &too_wide_penalty, &total_width_penalty, &out_of_bounds_penalty);
    unsigned int total_penalty = floorplan->weight_wirelength * wirelength + overlap_penalty + too_wide_penalty;
    return total_penalty;
}

void report_status(double temperature, struct cell* all_cells, size_t num_cells, struct floorplan* floorplan)
{
    int wirelength = floorplan->total_wirelength;
    unsigned int overlap_penalty;
    unsigned int too_wide_penalty;
    unsigned int total_width_penalty;
    unsigned int out_of_bounds_penalty;
    get_legality_penalty(all_cells, num_cells, floorplan, &overlap_penalty, &too_wide_penalty, &total_width_penalty, &out_of_bounds_penalty);
    unsigned int total_penalty = floorplan->weight_wirelength * wirelength + overlap_penalty + too_wide_penalty;
    puts("--------------------");
    for(size_t i = 0; i < num_cells; ++i)
    {
        struct cell* c = all_cells + i;
        printf("%s: pos = (%i, %i)\n", c->instance_name, c->pos_x, c->pos_y);
    }
    puts("--------------------");
    printf("temperature = %.3f, ", temperature);
    printf("total_penalty = %d, wirelength = %d, overlap_penalty = %d, too_wide_penalty = %d, total_width_penalty = %d, out_of_bounds_penalty = %d\n", total_penalty, wirelength, overlap_penalty, too_wide_penalty, total_width_penalty, out_of_bounds_penalty);
}

/* Operations M1 and M2 for simulated annealing
 * --------------------------------------------
 */

void m1(RanState* rstate, struct cell* a, struct rollback* r, struct floorplan* floorplan)
{
    r->c1 = a;
    r->x1 = a->pos_x;
    r->y1 = a->pos_y;
    r->c2 = NULL;
    cell_place_random(rstate, a, floorplan);
    cell_update_wirelengths(a, floorplan);
}

void m2(struct cell* a, struct cell* b, struct rollback* r, struct floorplan* floorplan)
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

    cell_update_wirelengths(a, floorplan);
    cell_update_wirelengths(b, floorplan);
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

void _initialize(lua_State* L, size_t* num_nets, size_t* num_cells, struct net** all_nets, struct cell** all_cells)
{
    lua_len(L, 1);
    *num_nets = lua_tointeger(L, -1);
    lua_pop(L, 1);

    lua_len(L, 2);
    *num_cells = lua_tointeger(L, -1);
    lua_pop(L, 1);

    // initialize all_nets
    struct net* all_nets_tmp = calloc(*num_nets, sizeof(struct net));
    for(size_t i = 1; i <= *num_nets; ++i)
    {
        lua_geti(L, 1, i);
        size_t len = 0;
        const char* net_name = lua_tolstring(L, -1, &len);
        all_nets_tmp[i - 1].net_name = malloc(len + 1);
        strncpy(all_nets_tmp[i - 1].net_name, net_name, len + 1);
        all_nets_tmp[i - 1].halfperi_wirelength = 0;
        lua_pop(L, 1);
    }
    *all_nets = all_nets_tmp;

    // initialize all_cells
    struct cell* all_cells_tmp = calloc(*num_cells, sizeof(struct cell));
    for(size_t i = 1; i <= *num_cells; ++i)
    {
        lua_geti(L, 2, i);
        size_t len = 0;

        // instance_name
        lua_getfield(L, -1, "instance_name");
        const char* instance_name = lua_tolstring(L, -1, &len);
        all_cells_tmp[i - 1].instance_name = malloc(len + 1);
        strncpy(all_cells_tmp[i - 1].instance_name, instance_name, len + 1);
        lua_pop(L, 1);

        // reference_name
        lua_getfield(L, -1, "reference_name");
        const char* reference_name = lua_tolstring(L, -1, &len);
        all_cells_tmp[i - 1].reference_name = malloc(len + 1);
        strncpy(all_cells_tmp[i - 1].reference_name, reference_name, len + 1);
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
    floorplan->total_wirelength = 0;
    floorplan->desired_row_width = desired_row_width;

    return floorplan;
}

static void _clean_up(struct net* all_nets, size_t num_nets, struct cell* all_cells, size_t num_cells, struct floorplan* floorplan)
{
    // free memory (after pushing results to lua)
    for(size_t i = 0; i < num_nets; ++i)
    {
        free(all_nets[i].net_name);
    }
    free(all_nets);
    for(size_t i = 1; i <= num_cells; ++i)
    {
        free(all_cells[i - 1].instance_name);
        free(all_cells[i - 1].reference_name);
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
            lua_pushstring(L, (*c)->reference_name);
            lua_settable(L, -3);
            lua_pushstring(L, "instance");
            lua_pushstring(L, (*c)->instance_name);
            lua_settable(L, -3);
            lua_seti(L, -2, i);
            ++i;
        }
        lua_seti(L, -2, cur_row + 1);
        free(cells_in_row);
    }
}

static void _simulated_annealing(RanState* rstate, struct net* all_nets, size_t num_nets, struct cell* all_cells, size_t num_cells, struct floorplan* floorplan, double coolingfactor, size_t moves_per_cell_per_temp, int verbose)
{
    double temperature = 5000.0;
    double end_temperature = 0.01;

    unsigned int needed_steps = (unsigned int) log(temperature / end_temperature) / log(1.0 / coolingfactor) + 1;

    unsigned int steps = 1;
    unsigned int percentage_divisor = 10;
    unsigned int percentage = 0;
    unsigned int last_total_penalty = UINT_MAX;

    place_initial_random(rstate, all_cells, num_cells, floorplan);
    calculate_total_wirelength(all_nets, num_nets, &floorplan->total_wirelength);
    while(temperature > end_temperature)
    {
        for(size_t move_ctr = 0; move_ctr < moves_per_cell_per_temp * num_cells; move_ctr++)
        {
            struct rollback rollback;

            if(random_choice(rstate, 0.25))
            {
                m2(random_cell(rstate, all_cells, num_cells), random_cell(rstate, all_cells, num_cells), &rollback, floorplan);
            }
            else
            {
                m1(rstate, random_cell(rstate, all_cells, num_cells), &rollback, floorplan);
            }

            unsigned int total_penalty = get_total_penalty(all_cells, num_cells, floorplan);

            if(move_ctr == 0 && verbose)
            {
                report_status(temperature, all_cells, num_cells, floorplan);
            }

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
                if(random_choice(rstate, exp(-(total_penalty - last_total_penalty) / temperature)))
                {
                    // accept
                    last_total_penalty = total_penalty;    
                }
                else
                {
                    undo(&rollback, floorplan);
                }
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

int lplacer_place_simulated_annealing(lua_State* L)
{
    size_t num_nets, num_cells;
    struct net* all_nets;
    struct cell* all_cells;
    _initialize(L, &num_nets, &num_cells, &all_nets, &all_cells);

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

    RanState rstate;
    randseed(&rstate, 145, 17);  /* initialize with a "random" seed */

    _simulated_annealing(&rstate, all_nets, num_nets, all_cells, num_cells, floorplan, coolingfactor, moves_per_cell_per_temp, verbose);

    _create_lua_result(L, all_cells, num_cells, floorplan);

    _clean_up(all_nets, num_nets, all_cells, num_cells, floorplan); // AFTER _create_lua_result!

    return 1; // cells table is returned to lua
}

int open_lplacer_lib(lua_State* L)
{
    static const luaL_Reg modfuncs[] =
    {
        { "place_simulated_annealing", lplacer_place_simulated_annealing },
        { NULL,    NULL          }
    };
    lua_newtable(L);
    luaL_setfuncs(L, modfuncs, 0);
    lua_setglobal(L, "placer");
    return 0;
}


#include <stdlib.h>
#include <stdio.h>
#include <stdbool.h>
#include <unistd.h>
#include <string.h>
#include <assert.h>
#include <math.h>

#include "lua/lauxlib.h"

#define MAX_PINS_PER_CELL (10)
#define MAX_PINS_PER_NET (32)

/* Structure definitions  */
struct floorplan {
    int floorplan_width;
    int floorplan_height;
    int desired_row_width;
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
    char* ref_name;
    int width;
    int pos_x;
    int pos_y;
    struct net* net_conn[MAX_PINS_PER_CELL];
};

struct rollback {
    struct cell* c1;
    int x1;
    int y1;
    struct cell* c2;
    int x2;
    int y2;
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

RanState rstate;

/* Returns random boolean, which is true by probability prob */
bool random_choice(double prob)
{
    double r = _lua_rand(&rstate);
    return r < prob;
}

static inline void net_update_wirelength(struct net* n, struct floorplan* floorplan)
{
    int x_upper, x_lower, y_upper, y_lower;

    floorplan->total_wirelength -= n->halfperi_wirelength;

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

    floorplan->total_wirelength += n->halfperi_wirelength;
}

void cell_update_wirelengths(struct cell* c, struct floorplan* floorplan)
{
    struct net** n_p;

    for(n_p = c->net_conn; *n_p; n_p++)
    {
        net_update_wirelength(*n_p, floorplan);
    }
}

static inline void cell_place_random(struct cell* c, struct floorplan* floorplan)
{
    c->pos_x = _lua_randi(&rstate, 0, floorplan->floorplan_width - 1);
    c->pos_y = _lua_randi(&rstate, 0, floorplan->floorplan_height - 1);
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

int get_total_wirelength(bool initial, struct net* all_nets, size_t num_nets, struct floorplan* floorplan)
{
    if(initial)
    {
        floorplan->total_wirelength = 0;
        for(size_t i = 0; i < num_nets; ++i)
        {
            struct net* n = all_nets + i;
            n->halfperi_wirelength = 0;
            net_update_wirelength(n, floorplan);
            //total_wirelength += n->halfperi_wirelength;
        }
    }
    return floorplan->total_wirelength;
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

struct cell* random_cell(struct cell* all_cells, size_t num_cells)
{
    return all_cells + _lua_randi(&rstate, 0, num_cells - 1);
}

struct cell** get_cells_of_row(struct cell* all_cells, size_t num_cells, int cur_row)
{
    size_t capacity = 40;
    size_t cur_cell_idx = 0;
    struct cell** cells_in_row = calloc(capacity, sizeof(struct cell*));
    for(size_t i = 0; i < num_cells; ++i)
    {
        struct cell* c = all_cells + i;
        if(c->pos_y == cur_row)
        {
            if(cur_cell_idx == capacity - 1)
            {
                capacity *= 2;
                cells_in_row = realloc(cells_in_row, capacity * sizeof(struct cell*));
            }
            cells_in_row[cur_cell_idx] = c;
            ++cur_cell_idx;
        }
    };
    cells_in_row[cur_cell_idx] = NULL; // sentinel
    return cells_in_row;
}

double get_legality_penalty(struct cell* all_cells, size_t num_cells, struct floorplan* floorplan)
{
    int total_overlap = 0;
    int total_width_penalty = 0;
    int too_wide_penalty = 0;

    for(int cur_row = 0; cur_row < floorplan->floorplan_height; cur_row++)
    {
        struct cell** cells_in_row = get_cells_of_row(all_cells, num_cells, cur_row);

        size_t capacity = 2;
        int* occupancy = malloc(capacity * sizeof(int));
        memset(occupancy, 0, capacity * sizeof(int));

        int row_cell_width_sum = 0;

        for(struct cell** c_p = cells_in_row; *c_p; c_p++)
        {
            row_cell_width_sum += (*c_p)->width;
            for(int i = 0; i <= (*c_p)->width; i++)
            {
                int index = (*c_p)->pos_x + i;
                if(index >= capacity)
                {
                    size_t old_capacity = capacity;
                    while(index >= capacity)
                    {
                        capacity *= 2;
                    }
                    int* tmp = realloc(occupancy, capacity * sizeof(int));
                    if(tmp)
                    {
                        occupancy = tmp;
                        memset(occupancy + old_capacity, 0, (capacity - old_capacity) * sizeof(int));
                    }
                    else
                    {
                        assert(0);
                    }
                }
                occupancy[index]++;
            }
        } 
        for(int i = 0; i < capacity; i++)
        {
            if(occupancy[i] > 1)
            {
                total_overlap += occupancy[i] - 1;
            }
        }
        //printf("row %i, cell_width_penalty = %i, overlap = %i\n", cur_row, desired_row_width - row_cell_width_sum, row_overlap);
        total_width_penalty += abs(floorplan->desired_row_width - row_cell_width_sum);
        if(row_cell_width_sum > floorplan->floorplan_width)
        {
            too_wide_penalty = 10000;
        }
        // clean up
        free(occupancy);
        free(cells_in_row);
    }
    //return total_overlap * total_overlap + floorplan->weight_width_penalty * total_width_penalty;
    return total_overlap + too_wide_penalty;
}

void place_initial_random(struct cell* all_cells, size_t num_cells, struct floorplan* floorplan)
{
    for(size_t i = 0; i < num_cells; ++i)
    {
        struct cell* c = all_cells + i;
        cell_place_random(c, floorplan);
        cell_update_wirelengths(c, floorplan);
    }
}

double get_total_penalty(struct net* all_nets, size_t num_nets, struct cell* all_cells, size_t num_cells, struct floorplan* floorplan)
{
    int wirelength = get_total_wirelength(false, all_nets, num_nets, floorplan);
    double legality_penalty = get_legality_penalty(all_cells, num_cells, floorplan);
    double total_penalty = floorplan->weight_wirelength * wirelength + legality_penalty;
    return total_penalty;
}

void report_status(double temperature, struct net* all_nets, size_t num_nets, struct cell* all_cells, size_t num_cells, struct floorplan* floorplan)
{
    int wirelength = get_total_wirelength(false, all_nets, num_nets, floorplan);
    double legality_penalty = get_legality_penalty(all_cells, num_cells, floorplan);
    double total_penalty = floorplan->weight_wirelength * wirelength + legality_penalty;
    /*
    puts("--------------------");
    for(size_t i = 0; i < num_cells; ++i)
    {
        struct cell* c = all_cells + i;
        printf("%s: pos = (%i, %i)\n", c->instance_name, c->pos_x, c->pos_y);
    }
    puts("--------------------");
    */
    printf("temperature = %.3f, ", temperature);
    printf("total_penalty = %.1f, wirelength = %d, legality_penalty = %.1f\n", total_penalty, wirelength, legality_penalty);
}

/* Operations M1 and M2 for simulated annealing
 * --------------------------------------------
 */

void m1(struct cell* a, struct rollback* r, struct floorplan* floorplan)
{
    r->c1 = a;
    r->x1 = a->pos_x;
    r->y1 = a->pos_y;
    r->c2 = NULL;
    cell_place_random(a, floorplan);
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

int lplacer_place(lua_State* L)
{
    lua_len(L, 1);
    size_t num_nets = lua_tointeger(L, -1);
    lua_pop(L, 1);

    lua_len(L, 2);
    size_t num_cells = lua_tointeger(L, -1);
    lua_pop(L, 1);

    // initialize all_nets
    struct net* all_nets = calloc(num_nets, sizeof(struct net));
    for(size_t i = 1; i <= num_nets; ++i)
    {
        lua_geti(L, 1, i);
        size_t len = 0;
        const char* net_name = lua_tolstring(L, -1, &len);
        all_nets[i - 1].net_name = malloc(len + 1);
        strncpy(all_nets[i - 1].net_name, net_name, len + 1);
        all_nets[i - 1].halfperi_wirelength = 0;
        lua_pop(L, 1);
    }

    // initialize all_cells
    struct cell* all_cells = calloc(num_cells, sizeof(struct cell));
    for(size_t i = 1; i <= num_cells; ++i)
    {
        lua_geti(L, 2, i);
        size_t len = 0;

        // instance_name
        lua_getfield(L, -1, "instance_name");
        const char* instance_name = lua_tolstring(L, -1, &len);
        all_cells[i - 1].instance_name = malloc(len + 1);
        strncpy(all_cells[i - 1].instance_name, instance_name, len + 1);
        lua_pop(L, 1);

        // ref_name
        lua_getfield(L, -1, "ref_name");
        const char* ref_name = lua_tolstring(L, -1, &len);
        all_cells[i - 1].ref_name = malloc(len + 1);
        strncpy(all_cells[i - 1].ref_name, ref_name, len + 1);
        lua_pop(L, 1);

        // width
        lua_getfield(L, -1, "width");
        all_cells[i - 1].width = lua_tointeger(L, -1);
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
            all_cells[i - 1].net_conn[j - 1] = &all_nets[index - 1];
            lua_pop(L, 1);
        }
        lua_pop(L, 1);

        lua_pop(L, 1);
    }

    lua_getfield(L, 3, "floorplan_width");
    int floorplan_width = lua_tointeger(L, -1);
    lua_pop(L, 1);
    lua_getfield(L, 3, "floorplan_height");
    int floorplan_height = lua_tointeger(L, -1);
    lua_pop(L, 1);

    lua_getfield(L, 3, "desired_row_width");
    int desired_row_width = lua_tointeger(L, -1);
    lua_pop(L, 1);

    lua_getfield(L, 3, "movespercell");
    const size_t moves_per_cell_per_temp = lua_tointeger(L, -1);
    lua_pop(L, 1);

    lua_getfield(L, 3, "coolingfactor");
    const double coolingfactor = lua_tonumber(L, -1);
    lua_pop(L, 1);

    lua_getfield(L, 3, "report");
    const int verbose = lua_toboolean(L, -1);
    lua_pop(L, 1);

    // ------ end of lua bridge ------

    /* For lengths, 1 unit is equal to 1 nm */
    struct floorplan floorplan = {
        .floorplan_width = floorplan_width,
        .floorplan_height = floorplan_height,
        .weight_wirelength = 1.0,
        .weight_width_penalty = 1.0,
        .total_wirelength = 0,
        .desired_row_width = desired_row_width
    };

    randseed(&rstate, 145, 17);  /* initialize with a "random" seed */

    update_net_struct_ptrs(all_nets, num_nets, all_cells, num_cells);
    place_initial_random(all_cells, num_cells, &floorplan);
    get_total_wirelength(true, all_nets, num_nets, &floorplan);

    double temperature = 5000.0;
    double end_temperature = 0.01;

    int needed_steps = log(end_temperature / temperature) / log(coolingfactor) + 1;

    int steps = 1;
    int percentage_divisor = 10;
    int percentage = 0;
    double last_total_penalty = 100000000000;
    while(temperature > end_temperature)
    {
        for(size_t move_ctr = 0; move_ctr < moves_per_cell_per_temp * num_cells; move_ctr++)
        {
            struct rollback rollback;

            if(random_choice(0.25))
            {
                m2(random_cell(all_cells, num_cells), random_cell(all_cells, num_cells), &rollback, &floorplan);
            }
            else
            {
                m1(random_cell(all_cells, num_cells), &rollback, &floorplan);
            }

            double total_penalty = get_total_penalty(all_nets, num_nets, all_cells, num_cells, &floorplan);

            if(move_ctr == 0 && verbose)
            {
                report_status(temperature, all_nets, num_nets, all_cells, num_cells, &floorplan);
            }

            if(move_ctr == 0)
            {
                if(steps * 100 / needed_steps >= percentage)
                {
                    printf("placement %2d %% done\n", percentage);
                    percentage += percentage_divisor;
                }
                /*
                if(steps * 100 / needed_steps == percentage)
                {
                    printf("placement %2d %% done\n", percentage);
                    percentage = round(((double)steps * 100 / needed_steps) / percentage_divisor) * percentage_divisor;
                }
                */
            }

            if(total_penalty > last_total_penalty)
            {
                if(random_choice(exp(-(total_penalty - last_total_penalty) / temperature)))
                {
                    // accept
                    last_total_penalty = total_penalty;    
                }
                else
                {
                    undo(&rollback, &floorplan);
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

    //puts("before legalization");
    //for(size_t i = 0; i < num_cells; ++i)
    //{
    //    struct cell* c = all_cells + i;
    //    printf("%s: pos = (%i, %i)\n", c->ref_name, c->pos_x, c->pos_y);
    //}

    // legalize placement
    //for(int cur_row = 0; cur_row < floorplan.floorplan_height; cur_row++)
    //{
    //    struct cell** cells_in_row = get_cells_of_row(all_cells, num_cells, cur_row);
    //    size_t numcellrows = 0;
    //    for(struct cell** c = cells_in_row; *c; ++c)
    //    {
    //        ++numcellrows;
    //    }
    //    qsort(cells_in_row, numcellrows, sizeof(struct cell*), &_cell_cmp);
    //    int curx = 0;
    //    for(struct cell** c = cells_in_row; *c; ++c)
    //    {
    //        (*c)->pos_x = curx;
    //        curx += (*c)->width;
    //    }
    //    free(cells_in_row);
    //}

    //puts("after legalization");
    //for(size_t i = 0; i < num_cells; ++i)
    //{
    //    struct cell* c = all_cells + i;
    //    printf("%s: pos = (%i, %i)\n", c->instance_name, c->pos_x, c->pos_y);
    //}

    // bring back results to lua
    lua_newtable(L);
    for(int cur_row = 0; cur_row < floorplan.floorplan_height; cur_row++)
    {
        struct cell** cells_in_row = get_cells_of_row(all_cells, num_cells, cur_row);
        lua_newtable(L);
        int i = 1;
        for(struct cell** c = cells_in_row; *c; ++c)
        {
            lua_pushstring(L, (*c)->ref_name);
            lua_seti(L, -2, i);
            ++i;
        }
        lua_seti(L, -2, cur_row + 1);
        free(cells_in_row);
    }

    /*
    lua_createtable(L, num_cells, 0);
    for(size_t i = 1; i <= num_cells; ++i)
    {
        struct cell* c = all_cells + i - 1;
        lua_newtable(L);
        lua_pushinteger(L, c->pos_x);
        lua_setfield(L, -2, "x");
        lua_pushinteger(L, c->pos_y);
        lua_setfield(L, -2, "y");
        lua_setfield(L, -2, c->instance_name);
    }
    */

    for(size_t i = 0; i < num_nets; ++i)
    {
        free(all_nets[i].net_name);
    }
    free(all_nets);
    for(size_t i = 1; i <= num_cells; ++i)
    {
        free(all_cells[i - 1].instance_name);
        free(all_cells[i - 1].ref_name);
    }
    free(all_cells);

    return 1;
}

int open_lplacer_lib(lua_State* L)
{
    static const luaL_Reg modfuncs[] =
    {
        { "place", lplacer_place },
        { NULL,    NULL          }
    };
    lua_newtable(L);
    luaL_setfuncs(L, modfuncs, 0);
    lua_setglobal(L, "placer");
    return 0;
}


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
#define MAX_CELLS_PER_ROW (2000)
#define MAX_UNITS_PER_ROW (1000)

/* Global variables
 * ----------------
 */

/* For lengths, 1 unit is equal to 1 nm. */
const int floorplan_width = 10000, floorplan_height = 20000;
const int site_height = 640, site_width = 19;
const double weight_wirelength = 1.0;
const double weight_width_penalty = 1.0;
int cell_count, cell_total_width;
int total_wirelength;

/* Strcture definitions & netlist include
 * --------------------------------------
 */
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
double _rand(void)
{
    return rand() / (double) RAND_MAX;
}

int _randi(void)
{
    return RAND_MAX * _rand();
}

/* Returns random boolean, which is true by probability prob */
bool random_choice(double prob)
{
    double r = _rand();
    return r < prob;
}

static inline void net_update_wirelength(struct net* n)
{
    int x_upper, x_lower, y_upper, y_lower;

    total_wirelength -= n->halfperi_wirelength;

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

    total_wirelength += n->halfperi_wirelength;
}

void cell_update_wirelengths(struct cell* c)
{
    struct net** n_p;

    for(n_p = c->net_conn; *n_p; n_p++)
    {
        net_update_wirelength(*n_p);
    }
}

static inline void cell_place_random(struct cell* c)
{
    c->pos_x = (_randi() % ((floorplan_width - c->width) / site_width)) * site_width;
    c->pos_y = (_randi() % (floorplan_height / site_height - 1)) * site_height;
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

int get_total_wirelength(bool initial, struct net* all_nets, size_t num_nets)
{
    if(initial)
    {
        total_wirelength = 0;
        for(size_t i = 0; i < num_nets; ++i)
        {
            struct net* n = all_nets + i;
            n->halfperi_wirelength = 0;
            net_update_wirelength(n);
            //total_wirelength += n->halfperi_wirelength;
        }
    }
    return total_wirelength;
}

void update_cell_count(struct cell* all_cells, size_t num_cells)
{
    cell_count = 0;
    cell_total_width = 0;
    for(size_t i = 0; i < num_cells; ++i)
    {
        struct cell* c = all_cells + i;
        cell_count++;
        cell_total_width += c->width;
    }
}

void undo(struct rollback* r)
{
    if(r->c1)
    {
        r->c1->pos_x = r->x1;
        r->c1->pos_y = r->y1;
        cell_update_wirelengths(r->c1);
    }
    if(r->c2)
    {
        r->c2->pos_x = r->x2;
        r->c2->pos_y = r->y2;
        cell_update_wirelengths(r->c2);
    }
}

struct cell* random_cell(struct cell* all_cells)
{
    return all_cells + _randi() % cell_count;
}

void get_cells_of_row(struct cell* all_cells, size_t num_cells, struct cell** cells_in_row, int cur_row)
{
    int cur_cell_idx = 0;
    for(size_t i = 0; i < num_cells; ++i)
    {
        struct cell* c = all_cells + i;
        if(c->pos_y == cur_row * site_height)
        {
            cells_in_row[cur_cell_idx++] = c;
            if(cur_cell_idx >= MAX_CELLS_PER_ROW)
            {
                fprintf(stderr, "Error: Too many cells in row.\n");
                exit(1);
            }
        }
    };
    cells_in_row[cur_cell_idx] = NULL;
}

double get_legality_penalty(struct cell* all_cells, size_t num_cells)
{
    struct cell* cells_in_row[MAX_CELLS_PER_ROW];

    int units_per_row = floorplan_width / site_width;
    assert(MAX_UNITS_PER_ROW > units_per_row); // this is not sufficient as the stdcell width is not factored in

    int desired_width_per_row = cell_total_width / ((floorplan_height / site_height) - 1);

    struct cell** c_p;
    int cur_row;
    int unit_ctr;

    double total_overlap = 0.0;
    double total_width_penalty = 0.0;

    for(cur_row = 0; cur_row < floorplan_height/site_height - 1; cur_row++)
    {
        int occupancy[MAX_UNITS_PER_ROW];
        int row_cell_width_sum;
        int row_overlap;

        get_cells_of_row(all_cells, num_cells, cells_in_row, cur_row);

        memset(occupancy, 0, sizeof(occupancy));

        row_cell_width_sum = 0;

        for(c_p = cells_in_row;* c_p; c_p++)
        {
            row_cell_width_sum += (*c_p)->width;
            for(unit_ctr = 0;unit_ctr<(*c_p)->width / site_width;unit_ctr++)
            {
                occupancy[(*c_p)->pos_x / site_width + unit_ctr]++;
            }
        } 
        row_overlap = 0;
        for(unit_ctr = 0; unit_ctr < units_per_row + 30; unit_ctr++) // TODO +30
        {
            if(occupancy[unit_ctr] > 1)
            {
                row_overlap += occupancy[unit_ctr];
            }
        }
        //printf("row %i, cell_width_penalty = %i, overlap = %i\n", cur_row, desired_width_per_row-row_cell_width_sum, row_overlap);
        total_overlap += row_overlap;
        total_width_penalty += abs(desired_width_per_row - row_cell_width_sum);
    }
    return total_overlap * total_overlap + weight_width_penalty * total_width_penalty;
}

void write_cell_locations(struct cell* all_cells, size_t num_cells, char* fn)
{
    FILE* f = fopen(fn, "w");

    if(!f)
    {
        perror("Failed to open file to write cell positions.");
        exit(1);
    }
    //fprintf(f, "set cell_location {\n");
    for(size_t i = 0; i < num_cells; ++i)
    {
        struct cell* c = all_cells + i;
        fprintf(f, "%s:translate(%d, %d)\n", c->instance_name, c->pos_x, c->pos_y);
    }
    //fprintf(f, "}\n");

    fclose(f);
}

void place_initial_random(struct cell* all_cells, size_t num_cells)
{
    for(size_t i = 0; i < num_cells; ++i)
    {
        struct cell* c = all_cells + i;
        cell_place_random(c);
        cell_update_wirelengths(c);
        //printf("%s: pos = (%i, %i)\n", c->instance_name, c->pos_x, c->pos_y);
    }
}

double get_total_penalty(struct net* all_nets, size_t num_nets, struct cell* all_cells, size_t num_cells)
{
    int wirelength = get_total_wirelength(false, all_nets, num_nets);
    double legality_penalty = get_legality_penalty(all_cells, num_cells);
    double total_penalty = weight_wirelength * wirelength + legality_penalty;
    return total_penalty;
}

void report_status(struct net* all_nets, size_t num_nets, struct cell* all_cells, size_t num_cells)
{
    int wirelength = get_total_wirelength(false, all_nets, num_nets);
    double legality_penalty = get_legality_penalty(all_cells, num_cells);
    double total_penalty = weight_wirelength * wirelength + legality_penalty;
    printf("total_penalty = %.1f, wirelength = %i.%i, legality_penalty = %.1f\n", total_penalty, wirelength / 100, wirelength % 100, legality_penalty);
}

/* Operations M1 and M2 for simulated annealing
 * --------------------------------------------
 */

void m1(struct cell* a, struct rollback* r)
{
    r->c1 = a;
    r->x1 = a->pos_x;
    r->y1 = a->pos_y;
    r->c2 = NULL;
    cell_place_random(a);
    cell_update_wirelengths(a);
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

    cell_update_wirelengths(a);
    cell_update_wirelengths(b);
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

    // ------ end of lua bridge ------

    // always start with same random seed -> leads to deterministic execution:
    srand(0);
    update_net_struct_ptrs(all_nets, num_nets, all_cells, num_cells);
    place_initial_random(all_cells, num_cells);
    update_cell_count(all_cells, num_cells);
    get_total_wirelength(true, all_nets, num_nets);
    report_status(all_nets, num_nets, all_cells, num_cells);

    const int moves_per_cell_per_temp = 2;
    double temperature = 5000.0;

    int move_ctr;
    double last_total_penalty = 100000000000;
    while(temperature > 0.01)
    {
        for(move_ctr = 0; move_ctr < moves_per_cell_per_temp * cell_count; move_ctr++)
        {
            struct rollback r;

            if(random_choice(0.25))
            {
                m2(random_cell(all_cells), random_cell(all_cells), &r);
            }
            else
            {
                m1(random_cell(all_cells), &r);
            }

            double total_penalty = get_total_penalty(all_nets, num_nets, all_cells, num_cells);

            if(move_ctr == 0)
            {
                printf("temperature = %.3f, ", temperature);
                report_status(all_nets, num_nets, all_cells, num_cells);
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
                    undo(&r);
                }
            }
            else // last_total_penalty >= total_penalty
            {
                // accept
                last_total_penalty = total_penalty;
            }
        }
        temperature *= 0.95;
    }

    report_status(all_nets, num_nets, all_cells, num_cells);
    //write_cell_locations(all_cells, num_cells, "cellpositions");

    // bring back results to lua
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


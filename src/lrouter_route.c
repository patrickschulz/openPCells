#include "lrouter_route.h"

#include "lrouter_net.h"
#include "lrouter_min_heap.h"
#include "lrouter_field.h"

#include <stdlib.h>
#include <stdio.h>
#include <limits.h>
#include <pthread.h>
#include <sys/sysinfo.h>

#define MIN(a,b) (((a)<(b))?(a):(b))
#define EVEN(val) ((val % 2) == 0)
#define POSITIVE(val) (val > 0)
#define NUM_DIRECTIONS 6

#define NUM_CPUS() (get_nprocs())
//#define NUM_CPUS() (2)

#define STEP_COST 2
#define VIA_COST 63
#define WRONG_DIR_COST 11

const int xincr[NUM_DIRECTIONS] = {-1,  0,  1,  0,  0,  0};
const int yincr[NUM_DIRECTIONS] = { 0,  1,  0, -1,  0,  0};
const int zincr[NUM_DIRECTIONS] = { 0,  0,  0,  0, -1,  1};

static inline struct rpoint _min_next_point(const struct rpoint *nextpoints)
{
    struct rpoint min_point = { .score = INT_MAX };
    for(int i = 0; i < NUM_DIRECTIONS; i++)
    {
        min_point = (nextpoints[i].score < min_point.score) ?
            nextpoints[i] : min_point;
    }
    return min_point;
}

static int _next_field_position(int i, const struct rpoint* current,
        struct rpoint* next)
{
    next->x = current->x + xincr[i];
    next->y = current->y + yincr[i];
    next->z = current->z + zincr[i];
    return 1;
}

static int _get_cost_increment(struct rpoint current, struct rpoint next)
{
    if(next.z != current.z) /* via */
    {
        return VIA_COST;
    }
    else if(next.y != current.y && EVEN(current.z)) /* wrong y direction */
    {
        return WRONG_DIR_COST;
    }
    else if (next.x != current.x && !EVEN(current.z)) /* wrong x direction */
    {
        return WRONG_DIR_COST;
    }
    return STEP_COST;
}

static int _is_unvisited(int nextfield)
{
    return nextfield == UNVISITED;
}

static int _is_final_port(int nextfield, struct rpoint next,
        struct position* endpos)
{
    return nextfield == PORT && next.x == endpos->x && next.y == endpos->y &&
        next.z == endpos->z;
}

static int _is_smaller_score(int score, int score_incr, int nextfield)
{
    return (score + score_incr) < nextfield;
}

static int _find_path(struct field *field, struct position *startpos,
        struct position *endpos)
{
    /* put starting point in min_heap */
    int routing_cost = INT_MAX;
    struct minheap* min_heap = heap_init();
    heap_insert_point(min_heap, startpos->x, startpos->y, startpos->z, 0);

    struct rpoint current = { .x = startpos->x, .y = startpos->y,
        .z = startpos->z };

    field_set(field, startpos->x, startpos->y, startpos->z, 0);

    /* do as long as there are points to be marked or endpoint is reached */
    while(!(current.x == endpos->x && current.y == endpos->y &&
                current.z == endpos->z))
    {
        /* get next point from heap */
        struct rpoint* point_ptr = heap_get_point(min_heap);

        current.x = point_ptr->x;
        current.y = point_ptr->y;
        current.z = point_ptr->z;

        free(point_ptr);

        int score = field_get(field, current.x, current.y, current.z);

        /* circle around every point */
        for(int i = 0; i < NUM_DIRECTIONS; i++)
        {
            struct rpoint next;
            if(!_next_field_position(i, &current, &next))
            {
                continue;
            }

            if(!field_is_field_point(field, next.x, next.y, next.z))
            {
                continue;
            }

            int score_incr = _get_cost_increment(current, next);

            /* check if point is visitable */
            int nextfield = field_get(field, next.x, next.y, next.z);
            if( _is_unvisited(nextfield) ||
                    _is_final_port(nextfield, next, endpos) ||
                    _is_smaller_score(score, score_incr, nextfield)
              )
            {
                routing_cost = score + score_incr;
                field_set(field, next.x, next.y, next.z, routing_cost);
                heap_insert_point(min_heap, next.x, next.y, next.z,
                        routing_cost);
            }
        }

        /* router is stuck */
        if(heap_empty(min_heap))
        {
            /* clean up */
            heap_destroy(min_heap);
            return INT_MAX;
        }
    }
    heap_destroy(min_heap);
    return routing_cost;
}

static int _has_same_coords(struct rpoint *point, struct position *pos)
{
    return (point->x == pos->x && point->y == pos->y && point->z == pos->z);
}

static void _backtrace(struct field *field, struct net *net,
        struct position *startpos, struct position *endpos,
        struct vector *pathpoints)
{
    struct rpoint current = { .x = endpos->x, .y = endpos->y, .z = endpos->z };
    struct rpoint oldpoint = {.x = UINT_MAX, .y = UINT_MAX, .z = UINT_MAX,
        .score = INT_MAX};

    int xdiff = 0, ydiff = 0, zdiff = 0;

    do
    {
        int score = field_get(field, current.x, current.y, current.z);
        struct rpoint nextpoints[] = { [0  ... NUM_DIRECTIONS - 1] =
            {.x = UINT_MAX, .y = UINT_MAX, .z = UINT_MAX,
                .score = INT_MAX}};

        /* circle around every point + check layer above and below store possible points in array */
        for(int i = 0; i < NUM_DIRECTIONS; i++)
        {
            struct rpoint next;
            next.x = current.x + xincr[i];
            next.y = current.y + yincr[i];
            next.z = current.z + zincr[i];

            if(!field_is_field_point(field, next.x, next.y, next.z))
            {
                continue;
            }

            /* check if point is visitable if yes store it in array */
            int nextfield = field_get(field, next.x, next.y, next.z);
            if(!field_is_visitable(field, next.x, next.y, next.z))
            {
                continue;
            }

            int is_wrong_dir = (yincr[i] && EVEN(current.z)) ||
                (xincr[i] && !EVEN(current.z));

            int is_reachable =
                ((score - nextfield) == VIA_COST) ||
                (((score - nextfield) == WRONG_DIR_COST) && is_wrong_dir) ||
                (((score - nextfield) == STEP_COST) && !is_wrong_dir);

            if(is_reachable && nextfield < score &&
                    nextfield < nextpoints[i].score)
            {
                nextpoints[i] = next;
                nextpoints[i].score = nextfield;

                /*
                 * check if the point before the current point has been initialized
                 * and a corner is ocurring
                 * if yes store the point, and modify its score gets ranked lower than another
                 * reachable point with the same score without a corner
                 */
                if(oldpoint.x != UINT_MAX &&
                        ((oldpoint.x != current.x &&
                          current.x == next.x) ||
                         (oldpoint.y != current.y &&
                          current.y == next.y)))
                {
                    nextpoints[i].score += WRONG_DIR_COST;
                    nextpoints[i].score += STEP_COST;
                }
            }
        }

        struct rpoint nextpoint = _min_next_point(nextpoints);

        if(nextpoint.z != current.z)
        {
            vector_append(pathpoints, point_new(current.x, current.y,
                        current.z, VIA));
        }
        else
        {
            vector_append(pathpoints, point_new(current.x, current.y,
                        current.z, PATH));
        }

        /* put diffs into delta vector for lua part */
        xdiff = ((int)nextpoint.x - (int)current.x);
        ydiff = ((int)nextpoint.y - (int)current.y);
        zdiff = ((int)nextpoint.z - (int)current.z);

        struct rpoint *diff_point;
        /*
         * put endport of backtrace with absolute positions
         * into list of deltas to make the data transfer to lua easier
         */
        if(_has_same_coords(&current, endpos))
        {
            diff_point = point_new(endpos->x, endpos->y, endpos->z, PORT);
            net_append_delta(net, diff_point);
        }

        diff_point = point_new(xdiff, ydiff, zdiff, PATH);
        net_append_delta(net, diff_point);

        oldpoint.x = current.x;
        oldpoint.x = current.y;
        oldpoint.x = current.z;

        current.x = nextpoint.x;
        current.y = nextpoint.y;
        current.z = nextpoint.z;
    }
    while(!(current.x == startpos->x && current.y == startpos->y &&
                current.z == startpos->z));
}

struct thread_data
{
    struct field *field;
    struct position *startpos;
    struct position *endpos;
    int routing_cost;
    int port_index;
};

void *_find_path_thread(void *args)
{
    struct thread_data *tdata = (struct thread_data *)args;
    tdata->routing_cost = _find_path(tdata->field, tdata->startpos,
            tdata->endpos);
    pthread_exit(NULL);
}

void _mark_as_route(struct field *field, struct vector *pathpoints)
{
    for(unsigned int i = 0; i < vector_size(pathpoints); i++)
    {
        struct rpoint *point = vector_get(pathpoints, i);
        int value = point_get_score(point);

        if(value == PATH || value == PORT || value == VIA)
        {
            field_set(field, point->x, point->y, point->z, value);
        }
    }
}

static int _curr_min_routing_cost_index(struct thread_data *tdata,
        int issued_threads)
{
    int min_cost = INT_MAX;
    int min_i = INT_MAX;
    for(int i = 0; i < issued_threads; i++)
    {
        /* skip routing to "itself" again */
        if(tdata[i].routing_cost == 0)
        {
            tdata[i].routing_cost = INT_MAX;
        }

        if(tdata[i].routing_cost < min_cost)
        {
            min_cost = tdata[i].routing_cost;
            min_i = i;
        }
    }
    return min_i;
}

static struct thread_data *_init_thread_dates(int num_cpus)
{
    struct thread_data *tdates = malloc(sizeof(*tdates) * num_cpus);

    for(int i = 0; i < num_cpus; i++)
    {
        tdates[i].field = NULL;
        tdates[i].startpos = NULL;
        tdates[i].endpos = NULL;
        tdates[i].routing_cost = INT_MAX;
        tdates[i].port_index = INT_MAX;
    }
    return tdates;
}

static void _destroy_thread_dates(struct thread_data *tdates, int num_cpus)
{
    for(int i = 0; i < num_cpus; i++)
    {
        net_destroy_position(tdates[i].startpos);
        net_destroy_position(tdates[i].endpos);
        field_destroy(tdates[i].field);
    }
}

pthread_t *_init_thids(int num_cpus)
{
    return malloc(sizeof(pthread_t) * num_cpus);
}

static void _fill_thread_date(struct thread_data *tdate, struct field *field,
        struct position *startpos, struct position *endpos, int port_index)
{
    tdate->field = field_copy(field);
    tdate->startpos = net_copy_position(startpos);
    tdate->endpos = net_copy_position(endpos);
    tdate->port_index = port_index;
}

void route(struct net *net, struct field* field)
{
    printf("\n\nrouting %s\n", net_get_name(net));

    int num_cpus = NUM_CPUS();
    int min_port_index = INT_MAX;

    pthread_t *thread_ids = _init_thids(num_cpus);

    struct position *startpos = NULL;
    struct position minimum_endpos;
    struct position minimum_startpos;

    struct vector *pathpoints = vector_create(1, free);

    /* append first port of net to position vector */
    vector_append(pathpoints, net_position_to_point(net_get_position(net, 0)));

    /*
     * for every possible point do a route search,
     * get the next point with the lowest routing cost,
     * backtrace and add the new backtrace points to the
     * possible points vector
     * repeat until all ports are reached
     */
    struct net *net_backup = net_copy(net);
    
    struct thread_data *tdates;

    while(net_get_size(net) > 1)
    {
        tdates = _init_thread_dates(num_cpus);

        printf("netsize %i\n", net_get_size(net));
        int pathpoint_size = vector_size(pathpoints);
        int issued_threads = 0;
        int min_routing_cost = INT_MAX;

        for(int i = 0; i < pathpoint_size; i++)
        {
            /*
             * get the next starting point from the list and check for the
             * cheapest way to reach any of the end ports (multithreaded)
             */
            startpos = net_point_to_position(vector_get(pathpoints, i));
            int net_size = net_get_size(net);

            for(int j = 1; j < net_size && issued_threads < NUM_CPUS(); j++)
            {
                struct position *endpos = net_get_position(net, j);
                _fill_thread_date(&tdates[issued_threads], field, startpos,
                        endpos, j);
                pthread_create(&thread_ids[issued_threads], NULL,
                        _find_path_thread, &tdates[issued_threads]);
                issued_threads++;
            }

            /*
             * join all threads if maximum of threads has been reached
             * or there are no more loop iterations
             */
            if(issued_threads == (NUM_CPUS()) ||
                    i == (pathpoint_size - 1))
            {
                for(int z = 0; z < issued_threads; z++)
                {
                    pthread_join(thread_ids[z], NULL);
                }

                int min_i = _curr_min_routing_cost_index(tdates,
                        issued_threads);

                if(min_i < num_cpus &&
                        tdates[min_i].routing_cost < min_routing_cost)
                {
                    min_routing_cost = tdates[min_i].routing_cost;
                    minimum_startpos = *tdates[min_i].startpos;
                    minimum_endpos = *tdates[min_i].endpos;
                    min_port_index = tdates[min_i].port_index;
                }
                _destroy_thread_dates(tdates, issued_threads);
                issued_threads = 0;
            }
            net_destroy_position(startpos);
        }
        if(min_routing_cost == INT_MAX)
        {
            printf("not routable\n");
            break;
        }
        /* look for path again to prepare the field for the backtrace */
        _find_path(field, &minimum_startpos, &minimum_endpos);
        _backtrace(field, net, &minimum_startpos, &minimum_endpos, pathpoints);

        net_remove_position(net, min_port_index);
        field_reset(field);
    }
    net_restore_positions(net, net_backup);

    _mark_as_route(field, pathpoints);
    net_mark_as_routed(net);
    net_make_deltas(net);

    vector_destroy(pathpoints);
    net_destroy(net_backup);
    free(thread_ids);
    free(tdates);
}


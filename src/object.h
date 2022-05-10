#ifndef OPC_OBJECT_H
#define OPC_OBJECT_H

#include "transformationmatrix.h"
#include "shape.h"
#include "pcell.h"
#include "vector.h"
#include "hashmap.h"

struct port
{
    char* name;
    point_t* where;
    generics_t* layer;
    int isbusport;
    int busindex;
};

struct object_t
{
    char* name;

    char* identifier; // for children
    struct object_t* reference; // for children
    int isproxy;
    int isarray;
    unsigned int xrep;
    unsigned int yrep;
    unsigned int xpitch;
    unsigned int ypitch;

    transformationmatrix_t* trans;

    shape_t** shapes;
    size_t shapes_size;
    size_t shapes_capacity;

    struct vector* ports;

    struct hashmap* anchors;

    coordinate_t* alignmentbox; // NULL or contains four coordinates

    struct vector* children;
};

typedef struct object_t object_t;

object_t* object_create(void);
object_t* object_copy(object_t*);
void object_destroy(void* cell);

void object_add_raw_shape(object_t* cell, shape_t* S);
void object_add_shape(object_t* cell, shape_t* S);
void object_remove_shape(object_t* cell, size_t i);
object_t* object_add_child(object_t* cell, struct pcell_state* pcell_state, const char* identifier, const char* name);
object_t* object_add_child_array(object_t* cell, struct pcell_state* pcell_state, const char* identifier, unsigned int xrep, unsigned int yrep, unsigned int xpitch, unsigned int ypitch, const char* name);
void object_merge_into_shallow(object_t* cell, object_t* other);
void object_add_anchor(object_t* cell, const char* name, coordinate_t x, coordinate_t y);
point_t* object_get_anchor(const object_t* cell, const char* name);
void object_add_port(object_t* cell, const char* name, generics_t* layer, point_t* where);
void object_add_bus_port(object_t* cell, const char* name, generics_t* layer, point_t* where, int startindex, int endindex, unsigned int xpitch, unsigned int ypitch);
void object_set_alignment_box(object_t* cell, coordinate_t blx, coordinate_t bly, coordinate_t trx, coordinate_t try);
void object_inherit_alignment_box(object_t* cell, object_t* other);
void object_get_minmax_xy(const object_t* cell, coordinate_t* minxp, coordinate_t* minyp, coordinate_t* maxxp, coordinate_t* maxyp);

// transformations
void object_move_to(object_t* cell, coordinate_t x, coordinate_t y);
void object_translate(object_t* cell, coordinate_t x, coordinate_t y);
void object_mirror_at_xaxis(object_t* cell);
void object_mirror_at_yaxis(object_t* cell);
void object_mirror_at_origin(object_t* cell);
void object_rotate_90_left(object_t* cell);
void object_rotate_90_right(object_t* cell);
void object_flipx(object_t* cell);
void object_flipy(object_t* cell);
void object_move_anchor(object_t* cell, const char* name, coordinate_t x, coordinate_t y);
void object_move_anchor_x(object_t* cell, const char* name, coordinate_t x, coordinate_t y);
void object_move_anchor_y(object_t* cell, const char* name, coordinate_t x, coordinate_t y);

void object_apply_transformation(object_t* cell);
int object_is_empty(object_t* cell);
void object_flatten(object_t* cell, struct pcell_state* pcell_state, int flattenports);

#endif // OPC_OBJECT_H

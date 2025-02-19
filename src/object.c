#include "object.h"

#include <stdlib.h>
#include <string.h>
#include <stdio.h>

#include "util.h"

#define min(a, b) ((a) < (b) ? (a) : (b))
#define max(a, b) ((a) > (b) ? (a) : (b))

#define OBJECT_DEFAULT_SHAPES_SIZE 32
#define OBJECT_DEFAULT_CHILDREN_SIZE 16
#define OBJECT_DEFAULT_REFERENCES_SIZE 8
#define OBJECT_DEFAULT_PORT_SIZE 16
#define OBJECT_DEFAULT_LABEL_SIZE 16

struct port {
    char* name;
    struct point* where;
    const struct generics* layer;
    int isbusport;
    int busindex;
    unsigned int sizehint;
};

static void _port_destroy(void* p)
{
    struct port* port = p;
    point_destroy(port->where);
    free(port->name);
    free(port);
}

struct anchor {
    union {
        /* regular anchors have one point, area anchors two */
        struct point* where;
        struct {
            struct point* bl;
            struct point* tr;
        };
    };
    int is_area;
};

static struct anchor* _anchor_create_regular(coordinate_t x, coordinate_t y)
{
    struct anchor* anchor = malloc(sizeof(*anchor));
    anchor->is_area = 0;
    anchor->where = point_create(x, y);
    return anchor;
}

static struct anchor* _anchor_create_area(coordinate_t blx, coordinate_t bly, coordinate_t trx, coordinate_t try)
{
    struct anchor* anchor = malloc(sizeof(*anchor));
    anchor->is_area = 1;
    anchor->bl = point_create(blx, bly);
    anchor->tr = point_create(trx, try);
    return anchor;
}

static struct anchor* _anchor_copy(const struct anchor* anchor)
{
    struct anchor* new = malloc(sizeof(*new));
    new->is_area = anchor->is_area;
    if(anchor->is_area)
    {
        new->bl = point_copy(anchor->bl);
        new->tr = point_copy(anchor->tr);
    }
    else
    {
        new->where = point_copy(anchor->where);
    }
    return new;
}

static void _anchor_destroy(void* v)
{
    struct anchor* anchor = v;
    if(anchor->is_area)
    {
        point_destroy(anchor->bl);
        point_destroy(anchor->tr);
    }
    else
    {
        point_destroy(anchor->where);
    }
    free(anchor);
}

static int _anchor_is_area(const struct anchor* anchor)
{
    return anchor->is_area;
}

struct object {
    char* name;
    int isproxy;
    int ismanaged;
    int isused;
    struct transformationmatrix* trans;

    union {
        // proxy objects (light handles to children)
        struct {
            const struct object* reference;
            int isarray;
            unsigned int xrep;
            unsigned int yrep;
            coordinate_t xpitch;
            coordinate_t ypitch;
            struct transformationmatrix* array_trans;
        };
        // full objects
        struct {
            struct vector* shapes; // stores struct shape*
            struct vector* ports; // stores struct port*
            struct vector* labels; // like a port, but always drawn; stores struct port*
            struct hashmap* anchors;
            struct vector* children; // stores struct object*
            struct vector* references; // stores struct object*
            coordinate_t* alignmentbox; // NULL or contains eight coordinates: blx, blx, trx, try for both outer (first) and inner (second)
            struct vector* boundary; // a polygon, stores struct point*
            struct hashmap* layer_boundaries; // contains polygons that store struct point*
            size_t childcounter;
        };
    };
};

static struct object* _create(const char* name)
{
    struct object* obj = malloc(sizeof(*obj));
    if(!obj)
    {
        return NULL;
    }
    memset(obj, 0, sizeof(*obj));
    if(name)
    {
        obj->name = util_strdup(name);
    }
    else
    {
        obj->name = NULL;
    }
    obj->ismanaged = 0;
    obj->isused = 1;
    return obj;
}

struct object* object_create(const char* name)
{
    struct object* obj = _create(name);
    obj->trans = transformationmatrix_create();
    transformationmatrix_identity(obj->trans);
    obj->isproxy = 0;
    return obj;
}

struct object* object_create_pseudo(void)
{
    struct object* obj = _create(NULL);
    obj->trans = transformationmatrix_create();
    transformationmatrix_identity(obj->trans);
    obj->isproxy = 0;
    return obj;
}

static struct object* _create_proxy(const char* name, struct object* reference)
{
    struct object* obj = _create(name);
    obj->reference = reference;
    obj->isproxy = 1;
    // does not need a transformation matrix as it is created by add_child
    obj->isarray = 0;
    obj->xrep = 1;
    obj->yrep = 1;
    obj->xpitch = 0;
    obj->ypitch = 0;
    return obj;
}

static char* _get_unique_name(struct object* reference)
{
    ++reference->childcounter;
    size_t num = reference->childcounter;
    char* str = malloc(5 + 1 + util_num_digits(num) + 1);
    sprintf(str, "child_%zd", num);
    return str;
}

struct object* object_copy(const struct object* cell)
{
    struct object* new = _create(cell->name);
    if(!new)
    {
        return NULL;
    }
    new->isproxy = cell->isproxy;
    new->ismanaged = cell->ismanaged;
    new->isused = cell->isused;

    // trans
    transformationmatrix_destroy(new->trans);
    new->trans = transformationmatrix_copy(cell->trans);

    if(cell->isproxy)
    {
        new->reference = cell->reference;
        new->isarray = cell->isarray;
        new->xrep = cell->xrep;
        new->yrep = cell->yrep;
        new->xpitch = cell->xpitch;
        new->ypitch = cell->ypitch;
        transformationmatrix_destroy(new->array_trans);
        new->array_trans = transformationmatrix_copy(cell->array_trans);
    }
    else
    {
        // shapes
        if(cell->shapes)
        {
            new->shapes = vector_copy(cell->shapes, shape_copy);
        }

        // alignmentbox
        if(cell->alignmentbox)
        {
            object_set_alignment_box(
                new,
                cell->alignmentbox[0], cell->alignmentbox[1],
                cell->alignmentbox[2], cell->alignmentbox[3],
                cell->alignmentbox[4], cell->alignmentbox[5],
                cell->alignmentbox[6], cell->alignmentbox[7]
            );
        }

        // anchors
        if(cell->anchors)
        {
            new->anchors = hashmap_create();
            struct hashmap_const_iterator* it = hashmap_const_iterator_create(cell->anchors);
            while(hashmap_const_iterator_is_valid(it))
            {
                const char* key = hashmap_const_iterator_key(it);
                const struct anchor* anchor = hashmap_const_iterator_value(it);
                hashmap_insert(new->anchors, key, _anchor_copy(anchor));
                hashmap_const_iterator_next(it);
            }
            hashmap_const_iterator_destroy(it);
        }

        // children
        if(cell->children)
        {
            new->children = vector_create(vector_size(cell->children), object_destroy);
            for(unsigned int i = 0; i < vector_size(cell->children); ++i)
            {
                vector_append(new->children, object_copy(vector_get(cell->children, i)));
            }
            new->references = vector_create(vector_size(cell->references), object_destroy);
            for(unsigned int i = 0; i < vector_size(cell->references); ++i)
            {
                vector_append(new->references, object_copy(vector_get(cell->references, i)));
            }
        }

        // ports
        if(cell->ports)
        {
            new->ports = vector_create(vector_size(cell->ports), _port_destroy);
            for(unsigned int i = 0; i < vector_size(cell->ports); ++i)
            {
                struct port* port = vector_get(cell->ports, i);
                struct port* newport = malloc(sizeof(*newport));
                newport->where = point_copy(port->where);
                newport->layer = port->layer;
                newport->isbusport = port->isbusport;
                newport->busindex = port->busindex;
                newport->name = util_strdup(port->name);
                newport->sizehint = port->sizehint;
                vector_append(new->ports, newport);
            }
        }

        // labels
        if(cell->labels)
        {
            new->labels = vector_create(vector_size(cell->labels), _port_destroy);
            for(unsigned int i = 0; i < vector_size(cell->labels); ++i)
            {
                struct port* port = vector_get(cell->labels, i);
                struct port* newport = malloc(sizeof(*newport));
                newport->where = point_copy(port->where);
                newport->layer = port->layer;
                newport->isbusport = port->isbusport;
                newport->busindex = port->busindex;
                newport->name = util_strdup(port->name);
                newport->sizehint = port->sizehint;
                vector_append(new->labels, newport);
            }
        }

        // boundary
        if(cell->boundary)
        {
            new->boundary = vector_create(4, point_destroy);
            struct vector_const_iterator* bit = vector_const_iterator_create(cell->boundary);
            while(vector_const_iterator_is_valid(bit))
            {
                const struct point* pt = vector_const_iterator_get(bit);
                vector_append(new->boundary, point_copy(pt));
                vector_const_iterator_next(bit);
            }
            vector_const_iterator_destroy(bit);
        }

        // layer boundaries
        if(cell->layer_boundaries)
        {
            new->layer_boundaries = hashmap_create();
            struct hashmap_iterator* lbit = hashmap_iterator_create(cell->layer_boundaries);
            while(hashmap_iterator_is_valid(lbit))
            {
                const char* key = hashmap_iterator_key(lbit);
                struct polygon* polygon = hashmap_iterator_value(lbit);
                hashmap_insert(new->layer_boundaries, key, polygon_copy(polygon));
                hashmap_iterator_next(lbit);
            }
            hashmap_iterator_destroy(lbit);
        }
    }
    return new;
}

void object_destroy(void* cellv)
{
    struct object* cell = cellv;
    if(!cell->isproxy)
    {
        // shapes
        if(cell->shapes)
        {
            vector_destroy(cell->shapes);
        }

        // children
        if(cell->children)
        {
            vector_destroy(cell->children);
            vector_destroy(cell->references);
        }

        // anchors
        if(cell->anchors)
        {
            hashmap_destroy(cell->anchors, _anchor_destroy);
        }

        // ports
        if(cell->ports)
        {
            vector_destroy(cell->ports);
        }

        // labels
        if(cell->labels)
        {
            vector_destroy(cell->labels);
        }

        // alignmentbox
        if(cell->alignmentbox)
        {
            free(cell->alignmentbox);
        }

        // boundary
        if(cell->boundary)
        {
            vector_destroy(cell->boundary);
        }

        // layer boundaries
        if(cell->layer_boundaries)
        {
            hashmap_destroy(cell->layer_boundaries, polygon_destroy);
        }
    }
    else // isproxy
    {
        transformationmatrix_destroy(cell->array_trans);
    }

    // name
    free(cell->name);

    // transformation matrix
    transformationmatrix_destroy(cell->trans);

    // object itself
    free(cell);
}

void object_set_name(struct object* cell, const char* name)
{
    free(cell->name);
    cell->name = util_strdup(name);
}

void object_add_raw_shape(struct object* cell, struct shape* S)
{
    if(!cell->shapes)
    {
        cell->shapes = vector_create(OBJECT_DEFAULT_SHAPES_SIZE, shape_destroy);
    }
    vector_append(cell->shapes, S);
}

void object_add_shape(struct object* cell, struct shape* S)
{
    object_add_raw_shape(cell, S);
    shape_apply_inverse_transformation(S, cell->trans);
}

struct shape* object_disown_shape(struct object* cell, size_t idx)
{
    struct shape* shape = vector_disown_element(cell->shapes, idx);
    return shape;
}

void object_remove_shape(struct object* cell, size_t idx)
{
    vector_remove(cell->shapes, idx);
}

struct object* object_create_handle(struct object* cell, struct object* reference)
{
    if(object_is_pseudo(reference)) // can't add pseudo objects
    {
        return NULL;
    }
    if(!cell->children)
    {
        cell->children = vector_create(OBJECT_DEFAULT_CHILDREN_SIZE, object_destroy);
        cell->references = vector_create(OBJECT_DEFAULT_REFERENCES_SIZE, object_destroy);
    }
    /* store owning reference to original reference object */
    vector_append(cell->references, reference);
    reference->ismanaged = 1;
    reference->isused = 0; // stored objects are not necessarily used
    return reference;
}

struct object* object_add_child(struct object* cell, struct object* child, const char* name)
{
    if(object_is_pseudo(child)) // can't add pseudo objects
    {
        return NULL;
    }
    char* genname = NULL;
    if(!name) // no explicit name, generate one
    {
        genname = _get_unique_name(cell);
        name = genname;
    }
    struct object* proxy = _create_proxy(name, child);
    if(genname)
    {
        free(genname);
    }
    proxy->trans = transformationmatrix_invert(cell->trans);
    if(!cell->children)
    {
        cell->children = vector_create(OBJECT_DEFAULT_CHILDREN_SIZE, object_destroy);
        cell->references = vector_create(OBJECT_DEFAULT_REFERENCES_SIZE, object_destroy);
    }
    vector_append(cell->children, proxy);
    /* store owning reference to original child object (if it is not already managed by another object) */
    if(!child->ismanaged)
    {
        if(vector_find_flat(cell->references, child) == -1)
        {
            vector_append(cell->references, child);
        }
    }
    else
    {
        child->isused = 1;
    }
    return proxy;
}

struct object* object_add_child_array(struct object* cell, struct object* child, const char* name, unsigned int xrep, unsigned int yrep, coordinate_t xpitch, coordinate_t ypitch)
{
    if(object_is_pseudo(child)) // can't add pseudo objects
    {
        return NULL;
    }
    struct object* proxy = object_add_child(cell, child, name);
    proxy->isarray = 1;
    proxy->xrep = xrep;
    proxy->yrep = yrep;
    proxy->xpitch = xpitch;
    proxy->ypitch = ypitch;
    proxy->array_trans = transformationmatrix_create();
    transformationmatrix_identity(proxy->array_trans);
    return proxy;
}

void object_merge_into(struct object* cell, const struct object* other)
{
    if(other->shapes)
    {
        for(unsigned int i = 0; i < vector_size(other->shapes); ++i)
        {
            struct shape* shape = shape_copy(vector_get(other->shapes, i));
            object_add_raw_shape(cell, shape);
            shape_apply_transformation(shape, other->trans);
            shape_apply_inverse_transformation(shape, cell->trans);
        }
    }
    if(other->children)
    {
        // * add_child expects an object that will be owned by the cell
        // * this means that the references must be copied
        // * the references must be only copied once, otherwise all children reference different objects
        // * the data structure of struct object does not allow for finding all children of one references in a simple manner, therefore the
        //   following code is a bit convoluted
        struct const_vector* used_cell_references = const_vector_create(OBJECT_DEFAULT_REFERENCES_SIZE);
        struct vector* new_cell_references = vector_create(OBJECT_DEFAULT_REFERENCES_SIZE, NULL); // non-owning vector, but non-constant elements are needed
        for(size_t i = 0; i < vector_size(other->children); ++i)
        {
            const struct object* child = vector_get_const(other->children, i);
            int index = const_vector_find_flat(used_cell_references, child->reference);
            if(index == -1)
            {
                const_vector_append(used_cell_references, child->reference);
                vector_append(new_cell_references, object_copy(child->reference));
                index = vector_size(new_cell_references) - 1;
            }
            struct object* newchild = object_add_child(cell, vector_get(new_cell_references, index), child->name);
            object_apply_other_transformation(newchild, child->trans);
            // FIXME: transformation
        }
    }
    if(other->labels)
    {
        for(unsigned int i = 0; i < vector_size(other->labels); ++i)
        {
            struct port* label = vector_get(other->labels, i);
            object_add_label(cell, label->name, label->layer, label->where, label->sizehint);
            struct port* newlabel = vector_get(cell->labels, vector_size(cell->labels) - 1);
            transformationmatrix_apply_inverse_transformation(cell->trans, newlabel->where);
            transformationmatrix_apply_transformation(other->trans, newlabel->where);
        }
    }
}

void object_merge_into_with_ports(struct object* cell, const struct object* other)
{
    object_merge_into(cell, other);
    if(other->ports)
    {
        for(unsigned int i = 0; i < vector_size(other->ports); ++i)
        {
            struct port* port = vector_get(other->ports, i);
            object_add_port(cell, port->name, port->layer, port->where, port->sizehint);
            struct port* newport = vector_get(cell->ports, vector_size(cell->ports) - 1);
            transformationmatrix_apply_inverse_transformation(cell->trans, newport->where);
            transformationmatrix_apply_transformation(other->trans, newport->where);
        }
    }
}

static void _swap_coordinates(coordinate_t* c1, coordinate_t* c2)
{
    coordinate_t tmp = *c1;
    *c1 = *c2;
    *c2 = tmp;
}

static void _fix_rectangle_order(struct point* bl, struct point* tr)
{
    if(bl->x > tr->x)
    {
        _swap_coordinates(&bl->x, &tr->x);
    }
    if(bl->y > tr->y)
    {
        _swap_coordinates(&bl->y, &tr->y);
    }
}

static void _fix_rectangle_order_xy(coordinate_t* blx, coordinate_t* bly, coordinate_t* trx, coordinate_t* try)
{
    if(*blx > *trx)
    {
        _swap_coordinates(blx, trx);
    }
    if(*bly > *try)
    {
        _swap_coordinates(bly, try);
    }
}

static void _transform_anchor_to_cell_coordinates(struct object* cell, struct anchor* anchor)
{
    if(_anchor_is_area(anchor))
    {
        transformationmatrix_apply_inverse_transformation(cell->trans, anchor->bl);
        transformationmatrix_apply_inverse_transformation(cell->trans, anchor->tr);
        _fix_rectangle_order(anchor->bl, anchor->tr);
    }
    else
    {
        transformationmatrix_apply_inverse_transformation(cell->trans, anchor->where);
    }
}

static int _add_anchor(struct object* cell, const char* name, struct anchor* anchor)
{
    if(!cell->anchors)
    {
        cell->anchors = hashmap_create();
    }
    if(hashmap_exists(cell->anchors, name))
    {
        return 0;
    }
    else
    {
        _transform_anchor_to_cell_coordinates(cell, anchor);
        hashmap_insert(cell->anchors, name, anchor);
    }
    return 1;
}

int object_add_anchor(struct object* cell, const char* name, coordinate_t x, coordinate_t y)
{
    struct anchor* anchor = _anchor_create_regular(x, y);
    int ret = _add_anchor(cell, name, anchor);
    if(!ret)
    {
        _anchor_destroy(anchor);
    }
    return ret;
}

static int _add_area_anchor_bltr(struct object* cell, const char* base, coordinate_t blx, coordinate_t bly, coordinate_t trx, coordinate_t try)
{
    struct anchor* anchor = _anchor_create_area(blx, bly, trx, try);
    int ret = _add_anchor(cell, base, anchor);
    if(!ret)
    {
        _anchor_destroy(anchor);
    }
    return ret;
}

int object_add_area_anchor_bltr(struct object* cell, const char* base, const struct point* bl, const struct point* tr)
{
    return _add_area_anchor_bltr(cell, base, bl->x, bl->y, tr->x, tr->y);
}

int object_add_area_anchor_points(struct object* cell, const char* base, const struct point* pt1, const struct point* pt2)
{
    coordinate_t blx = point_getx(pt1);
    coordinate_t bly = point_gety(pt1);
    coordinate_t trx = point_getx(pt2);
    coordinate_t try = point_gety(pt2);
    _fix_rectangle_order_xy(&blx, &bly, &trx, &try);
    return _add_area_anchor_bltr(cell, base, blx, bly, trx, try);
}

int object_inherit_area_anchor(struct object* cell, const struct object* other, const char* name)
{
    return object_inherit_area_anchor_as(cell, other, name, name);
}

int object_inherit_area_anchor_as(struct object* cell, const struct object* other, const char* name, const char* newname)
{
    if(cell->isproxy)
    {
        return 0;
    }
    struct point* anchor = object_get_area_anchor(other, name);
    if(anchor)
    {
        object_add_area_anchor_bltr(cell, newname, anchor + 0, anchor + 1);
        free(anchor);
    }
    return 1;
}

int object_inherit_anchor(struct object* cell, const struct object* other, const char* name)
{
    return object_inherit_anchor_as(cell, other, name, name);
}

int object_inherit_anchor_as(struct object* cell, const struct object* other, const char* name, const char* newname)
{
    if(cell->isproxy)
    {
        return 0;
    }
    struct point* anchor = object_get_anchor(other, name);
    if(anchor)
    {
        object_add_anchor(cell, newname, point_getx(anchor), point_gety(anchor));
        free(anchor);
    }
    return 1;
}

void object_inherit_all_anchors_with_prefix(struct object* cell, const struct object* other, const char* prefix)
{
    const struct object* obj = other;
    if(other->isproxy)
    {
        obj = other->reference;
    }
    if(obj->anchors)
    {
        struct hashmap_const_iterator* it = hashmap_const_iterator_create(obj->anchors);
        while(hashmap_const_iterator_is_valid(it))
        {
            const char* key = hashmap_const_iterator_key(it);
            const struct anchor* anchor = hashmap_const_iterator_value(it);
            char* newanchorname = malloc(strlen(prefix) + strlen(key) + 1);
            sprintf(newanchorname, "%s%s", prefix, key);
            if(_anchor_is_area(anchor))
            {
                object_inherit_area_anchor_as(cell, obj, key, newanchorname);
            }
            else
            {
                object_inherit_anchor_as(cell, obj, key, newanchorname);
            }
            free(newanchorname);
            hashmap_const_iterator_next(it);
        }
        hashmap_const_iterator_destroy(it);
    }
}

static struct point* _get_regular_anchor(const struct object* cell, const char* name)
{
    const struct object* obj = cell;
    if(cell->isproxy)
    {
        obj = cell->reference;
    }
    if(obj->anchors)
    {
        if(hashmap_exists(obj->anchors, name))
        {
            struct anchor* anchor = hashmap_get(obj->anchors, name);
            if(!_anchor_is_area(anchor))
            {
                return point_copy(anchor->where);
            }
            else
            {
                return NULL;
            }
        }
    }
    return NULL;
}

static void _transform_to_global_coordinates_xy(const struct object* cell, coordinate_t* x, coordinate_t* y)
{
    if(object_is_proxy(cell))
    {
        transformationmatrix_apply_transformation_xy(cell->reference->trans, x, y);
    }
    transformationmatrix_apply_transformation_xy(cell->trans, x, y);
}

static void _transform_to_global_coordinates(const struct object* cell, struct point* pt)
{
    _transform_to_global_coordinates_xy(cell, &pt->x, &pt->y);
}

static void _check_coordinates(coordinate_t* alignmentbox, size_t idx1, size_t idx2)
{
    if(alignmentbox[idx1] > alignmentbox[idx2])
    {
        coordinate_t tmp = alignmentbox[idx1];
        alignmentbox[idx1] = alignmentbox[idx2];
        alignmentbox[idx2] = tmp;
    }
}

static void _fix_alignmentbox_order(coordinate_t* alignmentbox)
{
    _check_coordinates(alignmentbox, 0, 2);
    _check_coordinates(alignmentbox, 0, 4);
    _check_coordinates(alignmentbox, 0, 6);
    _check_coordinates(alignmentbox, 4, 2);
    _check_coordinates(alignmentbox, 4, 6);
    _check_coordinates(alignmentbox, 6, 2);
    _check_coordinates(alignmentbox, 1, 3);
    _check_coordinates(alignmentbox, 1, 5);
    _check_coordinates(alignmentbox, 1, 7);
    _check_coordinates(alignmentbox, 5, 3);
    _check_coordinates(alignmentbox, 5, 7);
    _check_coordinates(alignmentbox, 7, 3);
}

#define _alignmentbox_get_outerblx(b) b[0]
#define _alignmentbox_get_outerbly(b) b[1]
#define _alignmentbox_get_outertrx(b) b[2]
#define _alignmentbox_get_outertry(b) b[3]
#define _alignmentbox_get_innerblx(b) b[4]
#define _alignmentbox_get_innerbly(b) b[5]
#define _alignmentbox_get_innertrx(b) b[6]
#define _alignmentbox_get_innertry(b) b[7]

static coordinate_t* _get_transformed_alignment_box(const struct object* cell)
{
    struct transformationmatrix* trans1 = cell->trans;
    struct transformationmatrix* trans2 = NULL;
    const struct object* obj = cell;
    if(cell->isproxy)
    {
        obj = cell->reference;
        trans2 = obj->trans;
    }
    if(!obj->alignmentbox)
    {
        return NULL;
    }
    coordinate_t* alignmentbox = calloc(8, sizeof(coordinate_t));
    memcpy(alignmentbox, obj->alignmentbox, 8 * sizeof(coordinate_t));
    for(unsigned int i = 0; i < 4; ++i)
    {
        transformationmatrix_apply_transformation_xy(trans1, alignmentbox + 0 + i * 2, alignmentbox + 1 + i * 2);
    }
    if(trans2)
    {
        for(unsigned int i = 0; i < 4; ++i)
        {
            transformationmatrix_apply_transformation_xy(trans2, alignmentbox + 0 + i * 2, alignmentbox + 1 + i * 2);
        }
    }
    _fix_alignmentbox_order(alignmentbox);
    if(object_is_child_array(cell))
    {
        _alignmentbox_get_innertrx(alignmentbox) += (cell->xrep - 1) * cell->xpitch;
        _alignmentbox_get_innertry(alignmentbox) += (cell->yrep - 1) * cell->ypitch;
        _alignmentbox_get_outertrx(alignmentbox) += (cell->xrep - 1) * cell->xpitch;
        _alignmentbox_get_outertry(alignmentbox) += (cell->yrep - 1) * cell->ypitch;
    }
    return alignmentbox;
}

struct point* object_get_anchor(const struct object* cell, const char* name)
{
    struct point* pt = _get_regular_anchor(cell, name);
    if(pt)
    {
        _transform_to_global_coordinates(cell, pt);
        return pt;
    }
    // no anchor found
    return NULL;
}

struct point* object_get_alignment_anchor(const struct object* cell, const char* name)
{
    coordinate_t* ab = _get_transformed_alignment_box(cell);
    coordinate_t x, y;
    if(strcmp(name, "outerbl") == 0)
    {
        x = _alignmentbox_get_outerblx(ab);
        y = _alignmentbox_get_outerbly(ab);
    }
    else if(strcmp(name, "outerbr") == 0)
    {
        x = _alignmentbox_get_outertrx(ab);
        y = _alignmentbox_get_outerbly(ab);
    }
    else if(strcmp(name, "outertl") == 0)
    {
        x = _alignmentbox_get_outerblx(ab);
        y = _alignmentbox_get_outertry(ab);
    }
    else if(strcmp(name, "outertr") == 0)
    {
        x = _alignmentbox_get_outertrx(ab);
        y = _alignmentbox_get_outertry(ab);
    }
    else if(strcmp(name, "innerbl") == 0)
    {
        x = _alignmentbox_get_innerblx(ab);
        y = _alignmentbox_get_innerbly(ab);
    }
    else if(strcmp(name, "innerbr") == 0)
    {
        x = _alignmentbox_get_innertrx(ab);
        y = _alignmentbox_get_innerbly(ab);
    }
    else if(strcmp(name, "innertl") == 0)
    {
        x = _alignmentbox_get_innerblx(ab);
        y = _alignmentbox_get_innertry(ab);
    }
    else if(strcmp(name, "innertr") == 0)
    {
        x = _alignmentbox_get_innertrx(ab);
        y = _alignmentbox_get_innertry(ab);
    }
    else
    {
        free(ab);
        return NULL;
    }
    free(ab);
    return point_create(x, y);
}

struct point* object_get_area_anchor(const struct object* cell, const char* base)
{
    const struct object* obj = cell;
    if(cell->isproxy)
    {
        obj = cell->reference;
    }

    if(obj->anchors)
    {
        if(hashmap_exists(obj->anchors, base) && _anchor_is_area(hashmap_get(obj->anchors, base)))
        {
            struct anchor* anchor = hashmap_get(obj->anchors, base);
            coordinate_t blx = anchor->bl->x;
            coordinate_t bly = anchor->bl->y;
            coordinate_t trx = anchor->tr->x;
            coordinate_t try = anchor->tr->y;
            _transform_to_global_coordinates_xy(cell, &blx, &bly);
            _transform_to_global_coordinates_xy(cell, &trx, &try);
            if(blx > trx)
            {
                coordinate_t tmp = blx;
                blx = trx;
                trx = tmp;
            }
            if(bly > try)
            {
                coordinate_t tmp = bly;
                bly = try;
                try = tmp;
            }
            struct point* pts = malloc(2 * sizeof(*pts));
            pts[0].x = blx;
            pts[0].y = bly;
            pts[1].x = trx;
            pts[1].y = try;
            return pts;
        }
    }
    return NULL;
}

struct point* object_get_array_anchor(const struct object* cell, int xindex, int yindex, const char* name)
{
    if(!object_is_child_array(cell))
    {
        return NULL;
    }
    // resolve negative indices
    if(xindex < 0)
    {
        xindex = cell->xrep + xindex + 1;
    }
    if(yindex < 0)
    {
        yindex = cell->yrep + yindex + 1;
    }
    struct point* pt = object_get_anchor(cell, name);
    if(pt)
    {
        point_translate(pt, cell->xpitch * (xindex - 1), cell->ypitch * (yindex - 1));
        return pt;
    }
    // no anchor found
    return NULL;
}

struct point* object_get_array_area_anchor(const struct object* cell, int xindex, int yindex, const char* base)
{
    if(!object_is_child_array(cell))
    {
        return NULL;
    }
    if(xindex > (int)cell->xrep)
    {
        return NULL;
    }
    if(yindex > (int)cell->yrep)
    {
        return NULL;
    }
    // resolve negative indices
    if(xindex < 0)
    {
        xindex = cell->xrep + xindex + 1;
    }
    if(yindex < 0)
    {
        yindex = cell->yrep + yindex + 1;
    }

    const struct object* obj = cell->reference;
    if(obj->anchors)
    {
        if(hashmap_exists(obj->anchors, base) && _anchor_is_area(hashmap_get(obj->anchors, base)))
        {
            struct anchor* anchor = hashmap_get(obj->anchors, base);
            coordinate_t blx = anchor->bl->x;
            coordinate_t bly = anchor->bl->y;
            coordinate_t trx = anchor->tr->x;
            coordinate_t try = anchor->tr->y;
            _transform_to_global_coordinates_xy(cell, &blx, &bly);
            _transform_to_global_coordinates_xy(cell, &trx, &try);
            if(blx > trx)
            {
                coordinate_t tmp = blx;
                blx = trx;
                trx = tmp;
            }
            if(bly > try)
            {
                coordinate_t tmp = bly;
                bly = try;
                try = tmp;
            }
            struct point* pts = malloc(2 * sizeof(*pts));
            pts[0].x = blx;
            pts[0].y = bly;
            pts[1].x = trx;
            pts[1].y = try;
            // translate for array
            pts[0].x += xindex * cell->xpitch;
            pts[0].y += yindex * cell->ypitch;
            pts[1].x += xindex * cell->xpitch;
            pts[1].y += yindex * cell->ypitch;
            return pts;
        }
    }
    return NULL;
}

struct point* object_get_alignmentbox_anchor_outerbl(const struct object* cell)
{
    coordinate_t* ab = _get_transformed_alignment_box(cell);
    coordinate_t x = _alignmentbox_get_outerblx(ab);
    coordinate_t y = _alignmentbox_get_outerbly(ab);
    free(ab);
    return point_create(x, y);
}

struct point* object_get_alignmentbox_anchor_outertr(const struct object* cell)
{
    coordinate_t* ab = _get_transformed_alignment_box(cell);
    coordinate_t x = _alignmentbox_get_outertrx(ab);
    coordinate_t y = _alignmentbox_get_outertry(ab);
    free(ab);
    return point_create(x, y);
}

struct point* object_get_alignmentbox_anchor_innerbl(const struct object* cell)
{
    coordinate_t* ab = _get_transformed_alignment_box(cell);
    coordinate_t x = _alignmentbox_get_innerblx(ab);
    coordinate_t y = _alignmentbox_get_innerbly(ab);
    free(ab);
    return point_create(x, y);
}

struct point* object_get_alignmentbox_anchor_innertr(const struct object* cell)
{
    coordinate_t* ab = _get_transformed_alignment_box(cell);
    coordinate_t x = _alignmentbox_get_innertrx(ab);
    coordinate_t y = _alignmentbox_get_innertry(ab);
    free(ab);
    return point_create(x, y);
}

const struct hashmap* object_get_all_regular_anchors(const struct object* cell)
{
    struct hashmap* anchors = hashmap_create();
    const struct object* obj = cell;
    if(cell->isproxy)
    {
        obj = cell->reference;
    }
    if(obj->anchors)
    {
        struct hashmap_const_iterator* it = hashmap_const_iterator_create(obj->anchors);
        while(hashmap_const_iterator_is_valid(it))
        {
            const char* key = hashmap_const_iterator_key(it);
            const struct anchor* anchor = hashmap_const_iterator_value(it);
            if(_anchor_is_area(anchor))
            {
                size_t len = strlen(key);
                char* name = malloc(len + 2 + 1);
                strcpy(name, key);
                const struct point* bl = anchor->bl;
                const struct point* tr = anchor->tr;
                name[len + 0] = 'b';
                name[len + 1] = 'l';
                hashmap_insert(anchors, name, point_create(bl->x, bl->y));
                name[len + 0] = 'b';
                name[len + 1] = 'r';
                hashmap_insert(anchors, name, point_create(tr->x, bl->y));
                name[len + 0] = 't';
                name[len + 1] = 'l';
                hashmap_insert(anchors, name, point_create(bl->x, tr->y));
                name[len + 0] = 't';
                name[len + 1] = 'r';
                hashmap_insert(anchors, name, point_create(tr->x, tr->y));
            }
            else
            {
                hashmap_insert(anchors, key, point_copy(anchor->where));
            }
            hashmap_const_iterator_next(it);
        }
        hashmap_const_iterator_destroy(it);
        return obj->anchors;
    }
    return NULL;
}

int object_abut_right(struct object* cell, const struct object* other)
{
    coordinate_t* alb1 = _get_transformed_alignment_box(cell);
    coordinate_t* alb2 = _get_transformed_alignment_box(other);
    coordinate_t x1 = _alignmentbox_get_outerblx(alb1);
    coordinate_t x2 = _alignmentbox_get_innertrx(alb2);
    object_translate(cell, x2 - x1, 0);
    free(alb1);
    free(alb2);
    return 1;
}

int object_abut_left(struct object* cell, const struct object* other)
{
    coordinate_t* alb1 = _get_transformed_alignment_box(cell);
    coordinate_t* alb2 = _get_transformed_alignment_box(other);
    coordinate_t x1 = _alignmentbox_get_outertrx(alb1);
    coordinate_t x2 = _alignmentbox_get_innerblx(alb2);
    object_translate(cell, x2 - x1, 0);
    free(alb1);
    free(alb2);
    return 1;
}

int object_abut_top(struct object* cell, const struct object* other)
{
    coordinate_t* alb1 = _get_transformed_alignment_box(cell);
    coordinate_t* alb2 = _get_transformed_alignment_box(other);
    coordinate_t y1 = _alignmentbox_get_outerbly(alb1);
    coordinate_t y2 = _alignmentbox_get_innertry(alb2);
    object_translate(cell, 0, y2 - y1);
    free(alb1);
    free(alb2);
    return 1;
}

int object_abut_bottom(struct object* cell, const struct object* other)
{
    coordinate_t* alb1 = _get_transformed_alignment_box(cell);
    coordinate_t* alb2 = _get_transformed_alignment_box(other);
    coordinate_t y1 = _alignmentbox_get_outertry(alb1);
    coordinate_t y2 = _alignmentbox_get_innerbly(alb2);
    object_translate(cell, 0, y2 - y1);
    free(alb1);
    free(alb2);
    return 1;
}

int object_abut_right_origin(struct object* cell)
{
    coordinate_t* alb1 = _get_transformed_alignment_box(cell);
    coordinate_t x1 = _alignmentbox_get_outerblx(alb1);
    object_translate(cell, 0 - x1, 0);
    free(alb1);
    return 1;
}

int object_abut_left_origin(struct object* cell)
{
    coordinate_t* alb1 = _get_transformed_alignment_box(cell);
    coordinate_t x1 = _alignmentbox_get_outertrx(alb1);
    object_translate(cell, 0 - x1, 0);
    free(alb1);
    return 1;
}

int object_abut_top_origin(struct object* cell)
{
    coordinate_t* alb1 = _get_transformed_alignment_box(cell);
    coordinate_t y1 = _alignmentbox_get_outerbly(alb1);
    object_translate(cell, 0, 0 - y1);
    free(alb1);
    return 1;
}

int object_abut_bottom_origin(struct object* cell)
{
    coordinate_t* alb1 = _get_transformed_alignment_box(cell);
    coordinate_t y1 = _alignmentbox_get_outertry(alb1);
    object_translate(cell, 0, 0 - y1);
    free(alb1);
    return 1;
}

int object_align_right(struct object* cell, const struct object* other)
{
    coordinate_t* alb1 = _get_transformed_alignment_box(cell);
    coordinate_t* alb2 = _get_transformed_alignment_box(other);
    coordinate_t x1 = _alignmentbox_get_outertrx(alb1);
    coordinate_t x2 = _alignmentbox_get_outertrx(alb2);
    object_translate(cell, x2 - x1, 0);
    free(alb1);
    free(alb2);
    return 1;
}

int object_align_left(struct object* cell, const struct object* other)
{
    coordinate_t* alb1 = _get_transformed_alignment_box(cell);
    coordinate_t* alb2 = _get_transformed_alignment_box(other);
    coordinate_t x1 = _alignmentbox_get_outerblx(alb1);
    coordinate_t x2 = _alignmentbox_get_outerblx(alb2);
    object_translate(cell, x2 - x1, 0);
    free(alb1);
    free(alb2);
    return 1;
}

int object_align_top(struct object* cell, const struct object* other)
{
    coordinate_t* alb1 = _get_transformed_alignment_box(cell);
    coordinate_t* alb2 = _get_transformed_alignment_box(other);
    coordinate_t y1 = _alignmentbox_get_outertry(alb1);
    coordinate_t y2 = _alignmentbox_get_outertry(alb2);
    object_translate(cell, 0, y2 - y1);
    free(alb1);
    free(alb2);
    return 1;
}

int object_align_bottom(struct object* cell, const struct object* other)
{
    coordinate_t* alb1 = _get_transformed_alignment_box(cell);
    coordinate_t* alb2 = _get_transformed_alignment_box(other);
    coordinate_t y1 = _alignmentbox_get_outerbly(alb1);
    coordinate_t y2 = _alignmentbox_get_outerbly(alb2);
    object_translate(cell, 0, y2 - y1);
    free(alb1);
    free(alb2);
    return 1;
}

int object_align_right_origin(struct object* cell)
{
    coordinate_t* alb1 = _get_transformed_alignment_box(cell);
    coordinate_t x1 = _alignmentbox_get_outertrx(alb1);
    object_translate(cell, 0 - x1, 0);
    free(alb1);
    return 1;
}

int object_align_left_origin(struct object* cell)
{
    coordinate_t* alb1 = _get_transformed_alignment_box(cell);
    coordinate_t x1 = _alignmentbox_get_outerblx(alb1);
    object_translate(cell, 0 - x1, 0);
    free(alb1);
    return 1;
}

int object_align_top_origin(struct object* cell)
{
    coordinate_t* alb1 = _get_transformed_alignment_box(cell);
    coordinate_t y1 = _alignmentbox_get_outertry(alb1);
    object_translate(cell, 0, 0 - y1);
    free(alb1);
    return 1;
}

int object_align_bottom_origin(struct object* cell)
{
    coordinate_t* alb1 = _get_transformed_alignment_box(cell);
    coordinate_t y1 = _alignmentbox_get_outerbly(alb1);
    object_translate(cell, 0, 0 - y1);
    free(alb1);
    return 1;
}

#define _area_anchor_get_blx(pts) pts[0].x
#define _area_anchor_get_bly(pts) pts[0].y
#define _area_anchor_get_trx(pts) pts[1].x
#define _area_anchor_get_try(pts) pts[1].y

int object_abut_area_anchor_right(struct object* cell, const char* anchorname, const struct object* other, const char* otheranchorname)
{
    struct point* pts1 = object_get_area_anchor(cell, anchorname);
    struct point* pts2 = object_get_area_anchor(other, otheranchorname);
    coordinate_t blx1 = _area_anchor_get_blx(pts1);
    coordinate_t trx2 = _area_anchor_get_trx(pts2);
    object_translate(cell, trx2 - blx1, 0);
    free(pts1);
    free(pts2);
    return 1;
}

int object_abut_area_anchor_left(struct object* cell, const char* anchorname, const struct object* other, const char* otheranchorname)
{
    struct point* pts1 = object_get_area_anchor(cell, anchorname);
    struct point* pts2 = object_get_area_anchor(other, otheranchorname);
    coordinate_t trx1 = _area_anchor_get_trx(pts1);
    coordinate_t blx2 = _area_anchor_get_blx(pts2);
    object_translate(cell, blx2 - trx1, 0);
    free(pts1);
    free(pts2);
    return 1;
}

int object_abut_area_anchor_top(struct object* cell, const char* anchorname, const struct object* other, const char* otheranchorname)
{
    struct point* pts1 = object_get_area_anchor(cell, anchorname);
    struct point* pts2 = object_get_area_anchor(other, otheranchorname);
    coordinate_t bly1 = _area_anchor_get_bly(pts1);
    coordinate_t try2 = _area_anchor_get_try(pts2);
    object_translate(cell, 0, try2 - bly1);
    free(pts1);
    free(pts2);
    return 1;
}

int object_abut_area_anchor_bottom(struct object* cell, const char* anchorname, const struct object* other, const char* otheranchorname)
{
    struct point* pts1 = object_get_area_anchor(cell, anchorname);
    struct point* pts2 = object_get_area_anchor(other, otheranchorname);
    coordinate_t try1 = _area_anchor_get_try(pts1);
    coordinate_t bly2 = _area_anchor_get_bly(pts2);
    object_translate(cell, 0, bly2 - try1);
    free(pts1);
    free(pts2);
    return 1;
}

int object_area_anchors_fit(const struct object* cell, const char* anchorname, const struct object* other, const char* otheranchorname)
{
    struct point* pts1 = object_get_area_anchor(cell, anchorname);
    struct point* pts2 = object_get_area_anchor(other, otheranchorname);
    coordinate_t blx1 = _area_anchor_get_blx(pts1);
    coordinate_t bly1 = _area_anchor_get_bly(pts1);
    coordinate_t trx1 = _area_anchor_get_trx(pts1);
    coordinate_t try1 = _area_anchor_get_try(pts1);
    coordinate_t blx2 = _area_anchor_get_blx(pts2);
    coordinate_t bly2 = _area_anchor_get_bly(pts2);
    coordinate_t trx2 = _area_anchor_get_trx(pts2);
    coordinate_t try2 = _area_anchor_get_try(pts2);
    free(pts1);
    free(pts2);
    return ((trx1 - blx1) == (trx2 - blx2)) && ((try1 - bly1) == (try2 - bly2));
}

int object_align_area_anchor(struct object* cell, const char* anchorname, const struct object* other, const char* otheranchorname)
{
    if(!object_area_anchors_fit(cell, anchorname, other, otheranchorname))
    {
        return 0;
    }
    struct point* pts1 = object_get_area_anchor(cell, anchorname);
    struct point* pts2 = object_get_area_anchor(other, otheranchorname);
    coordinate_t blx1 = _area_anchor_get_blx(pts1);
    coordinate_t bly1 = _area_anchor_get_bly(pts1);
    coordinate_t blx2 = _area_anchor_get_blx(pts2);
    coordinate_t bly2 = _area_anchor_get_bly(pts2);
    object_translate(cell, blx2 - blx1, bly2 - bly1);
    free(pts1);
    free(pts2);
    return 1;
}

int object_align_area_anchor_x(struct object* cell, const char* anchorname, const struct object* other, const char* otheranchorname)
{
    struct point* pts1 = object_get_area_anchor(cell, anchorname);
    struct point* pts2 = object_get_area_anchor(other, otheranchorname);
    coordinate_t blx1 = _area_anchor_get_blx(pts1);
    coordinate_t blx2 = _area_anchor_get_blx(pts2);
    object_translate(cell, blx2 - blx1, 0);
    free(pts1);
    free(pts2);
    return 1;
}

int object_align_area_anchor_left(struct object* cell, const char* anchorname, const struct object* other, const char* otheranchorname)
{
    struct point* pts1 = object_get_area_anchor(cell, anchorname);
    struct point* pts2 = object_get_area_anchor(other, otheranchorname);
    coordinate_t blx1 = _area_anchor_get_blx(pts1);
    coordinate_t blx2 = _area_anchor_get_blx(pts2);
    object_translate(cell, blx2 - blx1, 0);
    free(pts1);
    free(pts2);
    return 1;
}

int object_align_area_anchor_right(struct object* cell, const char* anchorname, const struct object* other, const char* otheranchorname)
{
    struct point* pts1 = object_get_area_anchor(cell, anchorname);
    struct point* pts2 = object_get_area_anchor(other, otheranchorname);
    coordinate_t trx1 = _area_anchor_get_trx(pts1);
    coordinate_t trx2 = _area_anchor_get_trx(pts2);
    object_translate(cell, trx2 - trx1, 0);
    free(pts1);
    free(pts2);
    return 1;
}

int object_align_area_anchor_y(struct object* cell, const char* anchorname, const struct object* other, const char* otheranchorname)
{
    struct point* pts1 = object_get_area_anchor(cell, anchorname);
    struct point* pts2 = object_get_area_anchor(other, otheranchorname);
    coordinate_t bly1 = _area_anchor_get_bly(pts1);
    coordinate_t bly2 = _area_anchor_get_bly(pts2);
    object_translate(cell, 0, bly2 - bly1);
    free(pts1);
    free(pts2);
    return 1;
}

int object_align_area_anchor_top(struct object* cell, const char* anchorname, const struct object* other, const char* otheranchorname)
{
    struct point* pts1 = object_get_area_anchor(cell, anchorname);
    struct point* pts2 = object_get_area_anchor(other, otheranchorname);
    coordinate_t try1 = _area_anchor_get_try(pts1);
    coordinate_t try2 = _area_anchor_get_try(pts2);
    object_translate(cell, 0, try2 - try1);
    free(pts1);
    free(pts2);
    return 1;
}

int object_align_area_anchor_bottom(struct object* cell, const char* anchorname, const struct object* other, const char* otheranchorname)
{
    struct point* pts1 = object_get_area_anchor(cell, anchorname);
    struct point* pts2 = object_get_area_anchor(other, otheranchorname);
    coordinate_t bly1 = _area_anchor_get_bly(pts1);
    coordinate_t bly2 = _area_anchor_get_bly(pts2);
    object_translate(cell, 0, bly2 - bly1);
    free(pts1);
    free(pts2);
    return 1;
}

void object_set_boundary(struct object* cell, struct vector* boundary)
{
    cell->boundary = vector_create(vector_size(boundary), point_destroy);
    struct vector_const_iterator* it = vector_const_iterator_create(boundary);
    while(vector_const_iterator_is_valid(it))
    {
        const struct point* pt = vector_const_iterator_get(it);
        struct point* newpt = point_copy(pt);
        transformationmatrix_apply_inverse_transformation(cell->trans, newpt);
        vector_append(cell->boundary, newpt);
        vector_const_iterator_next(it);
    }
    vector_const_iterator_destroy(it);
}

void object_set_empty_layer_boundary(struct object* cell, const struct generics* layer)
{
    if(!cell->layer_boundaries)
    {
        cell->layer_boundaries = hashmap_create();
    }
    if(hashmap_exists(cell->layer_boundaries, (const char*)layer))
    {
        struct polygon* boundary = hashmap_get(cell->layer_boundaries, (const char*)layer);
        polygon_destroy(boundary);
    }
    struct polygon* boundary = polygon_create_empty();
    hashmap_insert(cell->layer_boundaries, (const char*)layer, boundary);
}

void object_add_layer_boundary(struct object* cell, const struct generics* layer, struct simple_polygon* new)
{
    if(!cell->layer_boundaries)
    {
        cell->layer_boundaries = hashmap_create();
    }
    if(!hashmap_exists(cell->layer_boundaries, (const char*)layer))
    {
        struct polygon* polygon = polygon_create();
        hashmap_insert(cell->layer_boundaries, (const char*)layer, polygon);
    }
    struct polygon* boundary = hashmap_get(cell->layer_boundaries, (const char*)layer);
    // transform points to local coordinates
    struct simple_polygon_iterator* it = simple_polygon_iterator_create(new);
    while(simple_polygon_iterator_is_valid(it))
    {
        struct point* pt = simple_polygon_iterator_get(it);
        transformationmatrix_apply_inverse_transformation(cell->trans, pt);
        simple_polygon_iterator_next(it);
    }
    simple_polygon_iterator_destroy(it);
    // add transformed polygon
    polygon_add(boundary, new);
}

void object_inherit_boundary(struct object* cell, const struct object* othercell)
{
    cell->boundary = vector_create(4, point_destroy);
    struct vector_const_iterator* it;
    if(othercell->isproxy)
    {
        it = vector_const_iterator_create(othercell->reference->boundary);
    }
    else
    {
        it = vector_const_iterator_create(othercell->boundary);
    }
    while(vector_const_iterator_is_valid(it))
    {
        const struct point* pt = vector_const_iterator_get(it);
        struct point* newpt = point_copy(pt);
        transformationmatrix_apply_transformation(othercell->trans, newpt);
        transformationmatrix_apply_inverse_transformation(cell->trans, newpt);
        vector_append(cell->boundary, newpt);
        vector_const_iterator_next(it);
    }
    vector_const_iterator_destroy(it);
}

void object_inherit_layer_boundary(struct object* cell, const struct object* othercell, const struct generics* layer)
{
    struct polygon* boundary = object_get_layer_boundary(othercell, layer);

    struct polygon_iterator* it = polygon_iterator_create(boundary);
    while(polygon_iterator_is_valid(it))
    {
        const struct simple_polygon* sp = polygon_iterator_get(it);
        struct simple_polygon* new = simple_polygon_copy(sp);
        object_add_layer_boundary(cell, layer, new);
        polygon_iterator_next(it);
    }
    polygon_iterator_destroy(it);
    polygon_destroy(boundary);
}

int object_has_boundary(const struct object* cell)
{
    if(cell->isproxy)
    {
        return cell->reference->boundary ? 1 : 0;
    }
    else
    {
        return cell->boundary ? 1 : 0;
    }
}

struct vector* object_get_boundary(const struct object* cell)
{
    struct vector* boundary = vector_create(4, point_destroy);
    if(cell->isproxy)
    {
        struct vector* cellboundary = cell->reference->boundary;
        if(cellboundary)
        {
            struct vector_const_iterator* it = vector_const_iterator_create(cellboundary);
            while(vector_const_iterator_is_valid(it))
            {
                const struct point* pt = vector_const_iterator_get(it);
                struct point* newpt = point_copy(pt);
                transformationmatrix_apply_transformation(cell->reference->trans, newpt);
                transformationmatrix_apply_transformation(cell->trans, newpt);
                vector_append(boundary, newpt);
                vector_const_iterator_next(it);
            }
            vector_const_iterator_destroy(it);
        }
        else
        {
            coordinate_t blx, bly, trx, try;
            object_get_minmax_xy(cell->reference, &blx, &bly, &trx, &try, NULL); // no extra transformation matrix (FIXME: is this correct?)
            transformationmatrix_apply_transformation_xy(cell->trans, &blx, &bly);
            transformationmatrix_apply_transformation_xy(cell->trans, &trx, &try);
            vector_append(boundary, point_create(blx, bly));
            vector_append(boundary, point_create(trx, bly));
            vector_append(boundary, point_create(trx, try));
            vector_append(boundary, point_create(blx, try));
        }
    }
    else
    {
        struct vector* cellboundary = cell->boundary;
        if(cellboundary)
        {
            struct vector_const_iterator* it = vector_const_iterator_create(cellboundary);
            while(vector_const_iterator_is_valid(it))
            {
                const struct point* pt = vector_const_iterator_get(it);
                struct point* newpt = point_copy(pt);
                transformationmatrix_apply_transformation(cell->trans, newpt);
                vector_append(boundary, newpt);
                vector_const_iterator_next(it);
            }
            vector_const_iterator_destroy(it);
        }
        else
        {
            coordinate_t blx, bly, trx, try;
            object_get_minmax_xy(cell, &blx, &bly, &trx, &try, NULL); // no extra transformation matrix (FIXME: is this correct?)
            vector_append(boundary, point_create(blx, bly));
            vector_append(boundary, point_create(trx, bly));
            vector_append(boundary, point_create(trx, try));
            vector_append(boundary, point_create(blx, try));
        }
    }
    return boundary;
}

int object_has_layer_boundary(const struct object* cell, const struct generics* layer)
{
    if(cell->isproxy)
    {
        if(cell->reference->layer_boundaries)
        {
            return hashmap_exists(cell->reference->layer_boundaries, (const char*)layer);
        }
        else
        {
            return 0;
        }
    }
    else
    {
        if(cell->layer_boundaries)
        {
            return hashmap_exists(cell->layer_boundaries, (const char*)layer);
        }
        else
        {
            return 0;
        }
    }
}

struct polygon* object_get_layer_boundary(const struct object* cell, const struct generics* layer)
{
    if(cell->isproxy)
    {
        if(!cell->reference->layer_boundaries)
        {
            return polygon_create_empty();
        }
        struct polygon* cellboundary = hashmap_get(cell->reference->layer_boundaries, (const char*)layer);
        if(cellboundary)
        {
            if(polygon_is_empty(cellboundary))
            {
                return polygon_create_empty();
            }
            struct polygon* boundary = polygon_create();
            struct polygon_const_iterator* pit = polygon_const_iterator_create(cellboundary);
            while(polygon_const_iterator_is_valid(pit))
            {
                const struct simple_polygon* simple_polygon = polygon_const_iterator_get(pit);
                struct simple_polygon_const_iterator* it = simple_polygon_const_iterator_create(simple_polygon);
                struct simple_polygon* single_boundary = simple_polygon_create();
                while(simple_polygon_const_iterator_is_valid(it))
                {
                    const struct point* pt = simple_polygon_const_iterator_get(it);
                    struct point* newpt = point_copy(pt);
                    _transform_to_global_coordinates(cell, newpt);
                    simple_polygon_append(single_boundary, newpt);
                    simple_polygon_const_iterator_next(it);
                }
                simple_polygon_const_iterator_destroy(it);
                polygon_add(boundary, single_boundary);
                polygon_const_iterator_next(pit);
            }
            polygon_const_iterator_destroy(pit);
            return boundary;
        }
        else
        {
            struct polygon* boundary = polygon_create();
            coordinate_t blx, bly, trx, try;
            object_get_minmax_xy(cell->reference, &blx, &bly, &trx, &try, NULL); // no extra transformation matrix (FIXME: is this correct?)
            transformationmatrix_apply_transformation_xy(cell->trans, &blx, &bly);
            transformationmatrix_apply_transformation_xy(cell->trans, &trx, &try);
            struct simple_polygon* single_boundary = simple_polygon_create();
            simple_polygon_append(single_boundary, point_create(blx, bly));
            simple_polygon_append(single_boundary, point_create(trx, bly));
            simple_polygon_append(single_boundary, point_create(trx, try));
            simple_polygon_append(single_boundary, point_create(blx, try));
            polygon_add(boundary, single_boundary);
            return boundary;
        }
    }
    else
    {
        if(!cell->layer_boundaries)
        {
            return polygon_create_empty();
        }
        struct polygon* cellboundary = hashmap_get(cell->layer_boundaries, (const char*)layer);
        if(cellboundary)
        {
            if(polygon_is_empty(cellboundary))
            {
                return polygon_create_empty();
            }
            struct polygon* boundary = polygon_create();
            struct polygon_const_iterator* pit = polygon_const_iterator_create(cellboundary);
            while(polygon_const_iterator_is_valid(pit))
            {
                const struct simple_polygon* simple_polygon = polygon_const_iterator_get(pit);
                struct simple_polygon_const_iterator* it = simple_polygon_const_iterator_create(simple_polygon);
                struct simple_polygon* single_boundary = simple_polygon_create();
                while(simple_polygon_const_iterator_is_valid(it))
                {
                    const struct point* pt = simple_polygon_const_iterator_get(it);
                    struct point* newpt = point_copy(pt);
                    _transform_to_global_coordinates(cell, newpt);
                    simple_polygon_append(single_boundary, newpt);
                    simple_polygon_const_iterator_next(it);
                }
                simple_polygon_const_iterator_destroy(it);
                polygon_add(boundary, single_boundary);
                polygon_const_iterator_next(pit);
            }
            polygon_const_iterator_destroy(pit);
            return boundary;
        }
        else
        {
            struct polygon* boundary = polygon_create();
            coordinate_t blx, bly, trx, try;
            object_get_minmax_xy(cell, &blx, &bly, &trx, &try, NULL); // no extra transformation matrix (FIXME: is this correct?)
            struct simple_polygon* single_boundary = simple_polygon_create();
            simple_polygon_append(single_boundary, point_create(blx, bly));
            simple_polygon_append(single_boundary, point_create(trx, bly));
            simple_polygon_append(single_boundary, point_create(trx, try));
            simple_polygon_append(single_boundary, point_create(blx, try));
            polygon_add(boundary, single_boundary);
            return boundary;
        }
    }
}

static void _add_port(struct object* cell, const char* name, const struct generics* layer, coordinate_t x, coordinate_t y, int isbusport, int busindex, unsigned int sizehint)
{
    if(!generics_is_empty(layer))
    {
        if(!cell->ports)
        {
            cell->ports = vector_create(OBJECT_DEFAULT_PORT_SIZE, _port_destroy);
        }
        struct port* port = malloc(sizeof(*port));
        port->where = point_create(x, y);
        transformationmatrix_apply_inverse_transformation(cell->trans, port->where);
        port->layer = layer;
        port->isbusport = isbusport;
        port->busindex = busindex;
        port->name = malloc(strlen(name) + 1);
        strcpy(port->name, name);
        port->sizehint = sizehint;
        vector_append(cell->ports, port);
    }
}

void object_add_port(struct object* cell, const char* name, const struct generics* layer, const struct point* where, unsigned int sizehint)
{
    _add_port(cell, name, layer, where->x, where->y, 0, 0, sizehint);
}

void object_add_bus_port(struct object* cell, const char* name, const struct generics* layer, const struct point* where, int startindex, int endindex, coordinate_t xpitch, coordinate_t ypitch, unsigned int sizehint)
{
    int shift = 0;
    if(startindex < endindex)
    {
        for(int i = startindex; i <= endindex; ++i)
        {
            _add_port(cell, name, layer, where->x + shift * xpitch, where->y + shift * ypitch, 1, i, sizehint);
            ++shift;
        }
    }
    else
    {
        for(int i = startindex; i >= endindex; --i)
        {
            _add_port(cell, name, layer, where->x + shift * xpitch, where->y + shift * ypitch, 1, i, sizehint);
            ++shift;
        }
    }
}

static void _add_label(struct object* cell, const char* name, const struct generics* layer, coordinate_t x, coordinate_t y, unsigned int sizehint)
{
    if(!generics_is_empty(layer))
    {
        if(!cell->labels)
        {
            cell->labels = vector_create(OBJECT_DEFAULT_LABEL_SIZE, _port_destroy);
        }
        struct port* port = malloc(sizeof(*port));
        port->where = point_create(x, y);
        transformationmatrix_apply_inverse_transformation(cell->trans, port->where);
        port->layer = layer;
        port->isbusport = 0; // not used for labels
        port->busindex = 0;
        port->name = malloc(strlen(name) + 1);
        strcpy(port->name, name);
        port->sizehint = sizehint;
        vector_append(cell->labels, port);
    }
}

void object_add_label(struct object* cell, const char* name, const struct generics* layer, const struct point* where, unsigned int sizehint)
{
    _add_label(cell, name, layer, where->x, where->y, sizehint);
}

const struct vector* object_get_ports(const struct object* cell)
{
    return cell->ports;
}

const struct vector* object_get_labels(const struct object* cell)
{
    return cell->labels;
}

void object_clear_alignment_box(struct object* cell)
{
    free(cell->alignmentbox);
    cell->alignmentbox = NULL;
}

void object_set_alignment_box(
    struct object* cell,
    coordinate_t outerblx, coordinate_t outerbly,
    coordinate_t outertrx, coordinate_t outertry,
    coordinate_t innerblx, coordinate_t innerbly,
    coordinate_t innertrx, coordinate_t innertry
)
{
    if(!cell->alignmentbox)
    {
        cell->alignmentbox = calloc(8, sizeof(coordinate_t));
    }
    cell->alignmentbox[0] = outerblx;
    cell->alignmentbox[1] = outerbly;
    cell->alignmentbox[2] = outertrx;
    cell->alignmentbox[3] = outertry;
    cell->alignmentbox[4] = innerblx;
    cell->alignmentbox[5] = innerbly;
    cell->alignmentbox[6] = innertrx;
    cell->alignmentbox[7] = innertry;
}

// FIXME: this does not account for transformations, at least not really
void object_inherit_alignment_box(struct object* cell, const struct object* other)
{
    struct point* outerbl = object_get_alignmentbox_anchor_outerbl(other);
    struct point* outertr = object_get_alignmentbox_anchor_outertr(other);
    struct point* innerbl = object_get_alignmentbox_anchor_innerbl(other);
    struct point* innertr = object_get_alignmentbox_anchor_innertr(other);
    coordinate_t outerblx = outerbl->x;
    coordinate_t outerbly = outerbl->y;
    coordinate_t outertrx = outertr->x;
    coordinate_t outertry = outertr->y;
    coordinate_t innerblx = innerbl->x;
    coordinate_t innerbly = innerbl->y;
    coordinate_t innertrx = innertr->x;
    coordinate_t innertry = innertr->y;
    if(cell->alignmentbox)
    {
        coordinate_t souterblx = cell->alignmentbox[0];
        coordinate_t souterbly = cell->alignmentbox[1];
        coordinate_t soutertrx = cell->alignmentbox[2];
        coordinate_t soutertry = cell->alignmentbox[3];
        coordinate_t sinnerblx = cell->alignmentbox[4];
        coordinate_t sinnerbly = cell->alignmentbox[5];
        coordinate_t sinnertrx = cell->alignmentbox[6];
        coordinate_t sinnertry = cell->alignmentbox[7];
        outerblx = min(outerblx, souterblx);
        outerbly = min(outerbly, souterbly);
        outertrx = max(outertrx, soutertrx);
        outertry = max(outertry, soutertry);
        innerblx = min(innerblx, sinnerblx);
        innerbly = min(innerbly, sinnerbly);
        innertrx = max(innertrx, sinnertrx);
        innertry = max(innertry, sinnertry);
    }
    object_set_alignment_box(cell, outerblx, outerbly, outertrx, outertry, innerblx, innerbly, innertrx, innertry);
    point_destroy(outerbl);
    point_destroy(outertr);
    point_destroy(innerbl);
    point_destroy(innertr);
}

static void _alignment_box_include_xy(struct object* cell, coordinate_t x, coordinate_t y, int include_x, int include_y)
{
    transformationmatrix_apply_inverse_transformation_xy(cell->trans, &x, &y);
    coordinate_t souterblx = cell->alignmentbox[0];
    coordinate_t souterbly = cell->alignmentbox[1];
    coordinate_t soutertrx = cell->alignmentbox[2];
    coordinate_t soutertry = cell->alignmentbox[3];
    coordinate_t sinnerblx = cell->alignmentbox[4];
    coordinate_t sinnerbly = cell->alignmentbox[5];
    coordinate_t sinnertrx = cell->alignmentbox[6];
    coordinate_t sinnertry = cell->alignmentbox[7];
    coordinate_t outerblx, outertrx, innerblx, innertrx;
    coordinate_t outerbly, outertry, innerbly, innertry;
    if(include_x)
    {
        outerblx = min(x, souterblx);
        outertrx = max(x, soutertrx);
        innerblx = min(x, sinnerblx);
        innertrx = max(x, sinnertrx);
    }
    else
    {
        outerblx = souterblx;
        outertrx = soutertrx;
        innerblx = sinnerblx;
        innertrx = sinnertrx;
    }
    if(include_y)
    {
        outerbly = min(y, souterbly);
        outertry = max(y, soutertry);
        innerbly = min(y, sinnerbly);
        innertry = max(y, sinnertry);
    }
    else
    {
        outerbly = souterbly;
        outertry = soutertry;
        innerbly = sinnerbly;
        innertry = sinnertry;
    }
    object_set_alignment_box(cell, outerblx, outerbly, outertrx, outertry, innerblx, innerbly, innertrx, innertry);
}

void object_alignment_box_include_point(struct object* cell, const struct point* pt)
{
    if(cell->isproxy)
    {
        return;
    }
    if(cell->alignmentbox)
    {
        // copy coordinates as they are transformed
        coordinate_t x = pt->x;
        coordinate_t y = pt->y;
        _alignment_box_include_xy(cell, x, y, 1, 1); // include both x and y
    }
    else
    {
        puts("using object.alignment_box_include_point on an object without an alignment box. While this could be a sensible operation, it is currently not implemented.");
        // FIXME
    }
}

void object_alignment_box_include_x(struct object* cell, coordinate_t x)
{
    if(cell->isproxy)
    {
        return;
    }
    if(cell->alignmentbox)
    {
        _alignment_box_include_xy(cell, x, 0, 1, 0); // include only x
    }
    else
    {
        puts("using object.alignment_box_include_point on an object without an alignment box. While this could be a sensible operation, it is currently not implemented.");
        // FIXME
    }
}

void object_alignment_box_include_y(struct object* cell, coordinate_t y)
{
    if(cell->isproxy)
    {
        return;
    }
    if(cell->alignmentbox)
    {
        _alignment_box_include_xy(cell, 0, y, 0, 1); // include only y
    }
    else
    {
        puts("using object.alignment_box_include_point on an object without an alignment box. While this could be a sensible operation, it is currently not implemented.");
        // FIXME
    }
}

int object_extend_alignment_box(struct object* cell,
    coordinate_t extouterblx, coordinate_t extouterbly,
    coordinate_t extoutertrx, coordinate_t extoutertry,
    coordinate_t extinnerblx, coordinate_t extinnerbly,
    coordinate_t extinnertrx, coordinate_t extinnertry)
{
    if(!cell->alignmentbox)
    {
        return 0;
    }
    cell->alignmentbox[0] += extouterblx;
    cell->alignmentbox[1] += extouterbly;
    cell->alignmentbox[2] += extoutertrx;
    cell->alignmentbox[3] += extoutertry;
    cell->alignmentbox[4] += extinnerblx;
    cell->alignmentbox[5] += extinnerbly;
    cell->alignmentbox[6] += extinnertrx;
    cell->alignmentbox[7] += extinnertry;
    return 1;
}

void object_move_to(struct object* cell, coordinate_t x, coordinate_t y)
{
    transformationmatrix_move_to(cell->trans, x, y);
}

void object_reset_translation(struct object* cell)
{
    transformationmatrix_move_to(cell->trans, 0, 0);
}

void object_translate(struct object* cell, coordinate_t x, coordinate_t y)
{
    transformationmatrix_translate(cell->trans, x, y);
}

void object_translate_x(struct object* cell, coordinate_t x)
{
    transformationmatrix_translate(cell->trans, x, 0);
}

void object_translate_y(struct object* cell, coordinate_t y)
{
    transformationmatrix_translate(cell->trans, 0, y);
}

void object_mirror_at_xaxis(struct object* cell)
{
    transformationmatrix_mirror_x(cell->trans);
}

void object_mirror_at_yaxis(struct object* cell)
{
    transformationmatrix_mirror_y(cell->trans);
}

void object_mirror_at_origin(struct object* cell)
{
    transformationmatrix_mirror_origin(cell->trans);
}

void object_rotate_90_left(struct object* cell)
{
    transformationmatrix_rotate_90_left(cell->trans);
}

void object_rotate_90_right(struct object* cell)
{
    transformationmatrix_rotate_90_right(cell->trans);
}

void object_array_rotate_90_left(struct object* cell)
{
    transformationmatrix_rotate_90_left(cell->array_trans);
}

void object_array_rotate_90_right(struct object* cell)
{
    transformationmatrix_rotate_90_right(cell->array_trans);
}

void object_apply_other_transformation(struct object* cell, const struct transformationmatrix* trans)
{
    transformationmatrix_chain_inline(cell->trans, trans);
}

int object_move_point(struct object* cell, const struct point* source, const struct point* target)
{
    object_translate(cell, target->x - source->x, target->y - source->y);
    return 1;
}

int object_move_point_to_origin(struct object* cell, const struct point* target)
{
    object_translate(cell, target->x, target->y);
    return 1;
}

int object_move_point_to_origin_xy(struct object* cell, coordinate_t x, coordinate_t y)
{
    object_translate(cell, x, y);
    return 1;
}

int object_move_point_x(struct object* cell, const struct point* source, const struct point* target)
{
    object_translate(cell, target->x - source->x, 0);
    return 1;
}

int object_move_point_y(struct object* cell, const struct point* source, const struct point* target)
{
    object_translate(cell, 0, target->y - source->y);
    return 1;
}

void object_scale(struct object* cell, double factor)
{
    transformationmatrix_scale(cell->trans, factor);
}

static void _fix_minmax_order(coordinate_t *minx, coordinate_t* miny, coordinate_t* maxx, coordinate_t* maxy)
{
    if(*minx > *maxx)
    {
        coordinate_t tmp = *minx;
        *minx = *maxx;
        *maxx = tmp;
    }
    if(*miny > *maxy)
    {
        coordinate_t tmp = *miny;
        *miny = *maxy;
        *maxy = tmp;
    }
}

void object_get_minmax_xy(const struct object* cell, coordinate_t* minxp, coordinate_t* minyp, coordinate_t* maxxp, coordinate_t* maxyp, const struct transformationmatrix* extratrans)
{
    coordinate_t minx = COORDINATE_MAX;
    coordinate_t maxx = COORDINATE_MIN;
    coordinate_t miny = COORDINATE_MAX;
    coordinate_t maxy = COORDINATE_MIN;
    if(cell->shapes)
    {
        for(unsigned int i = 0; i < vector_size(cell->shapes); ++i)
        {
            struct shape* S = vector_get(cell->shapes, i);
            coordinate_t minx_;
            coordinate_t maxx_;
            coordinate_t miny_;
            coordinate_t maxy_;
            shape_get_minmax_xy(S, &minx_, &miny_, &maxx_, &maxy_);
            transformationmatrix_apply_transformation_xy(cell->trans, &minx_, &miny_);
            transformationmatrix_apply_transformation_xy(cell->trans, &maxx_, &maxy_);
            if(extratrans)
            {
                transformationmatrix_apply_transformation_xy(extratrans, &minx_, &miny_);
                transformationmatrix_apply_transformation_xy(extratrans, &maxx_, &maxy_);
            }
            _fix_minmax_order(&minx_, &miny_, &maxx_, &maxy_);
            minx = min(minx, minx_);
            maxx = max(maxx, maxx_);
            miny = min(miny, miny_);
            maxy = max(maxy, maxy_);
        }
    }
    if(cell->children)
    {
        for(unsigned int i = 0; i < vector_size(cell->children); ++i)
        {
            const struct object* child = vector_get(cell->children, i);
            const struct object* obj = child->reference;
            coordinate_t minx_, maxx_, miny_, maxy_;
            object_get_minmax_xy(obj, &minx_, &miny_, &maxx_, &maxy_, child->trans);
            transformationmatrix_apply_transformation_xy(cell->trans, &minx_, &miny_);
            transformationmatrix_apply_transformation_xy(cell->trans, &maxx_, &maxy_);
            _fix_minmax_order(&minx_, &miny_, &maxx_, &maxy_);
            // FIXME: transformation? -> should be handled by recursive call, but check this! (construct a cell with the right transformations)
            minx = min(minx, minx_);
            maxx = max(maxx, maxx_);
            miny = min(miny, miny_);
            maxy = max(maxy, maxy_);
        }
    }
    *minxp = minx;
    *maxxp = maxx;
    *minyp = miny;
    *maxyp = maxy;
}

void object_width_height_alignmentbox(const struct object* cell, ucoordinate_t* width, ucoordinate_t* height)
{
    coordinate_t* ab = _get_transformed_alignment_box(cell);
    *width = _alignmentbox_get_outertrx(ab) - _alignmentbox_get_innerblx(ab);
    *height = _alignmentbox_get_outertry(ab) - _alignmentbox_get_innerbly(ab);
    free(ab);
}

void object_foreach_shapes(struct object* cell, void (*func)(struct shape*))
{
    if(cell->shapes)
    {
        for(unsigned int i = 0; i < vector_size(cell->shapes); ++i)
        {
            struct shape* shape = vector_get(cell->shapes, i);
            func(shape);
        }
    }
}

size_t object_get_shapes_size(const struct object* cell)
{
    if(!cell->shapes)
    {
        return 0;
    }
    else
    {
        return vector_size(cell->shapes);
    }
}

struct shape* object_get_shape(struct object* cell, size_t idx)
{
    return vector_get(cell->shapes, idx);
}

struct shape* object_get_transformed_shape(struct object* cell, size_t idx)
{
    struct shape* shape = vector_get(cell->shapes, idx);
    shape_apply_transformation(shape, cell->trans);
    return shape;
}

static void _rasterize_curves(struct shape* shape)
{
    if(!shape_is_curve(shape))
    {
        return;
    }
    shape_rasterize_curve_inline(shape);
}

void object_rasterize_curves(struct object* cell)
{
    object_foreach_shapes(cell, _rasterize_curves);
}

const struct transformationmatrix* object_get_transformation_matrix(const struct object* cell)
{
    return cell->trans;
}

const struct transformationmatrix* object_get_array_transformation_matrix(const struct object* cell)
{
    return cell->array_trans;
}

static void _get_transformation_correction(const struct object* cell, coordinate_t* cx, coordinate_t* cy)
{
    const struct object* obj = cell;
    if(cell->isproxy)
    {
        obj = cell->reference;
    }
    coordinate_t blx, bly, trx, try;
    // FIXME: fix for alignmentbox with eight coordinates
    if(obj->alignmentbox)
    {
        blx = obj->alignmentbox[0];
        bly = obj->alignmentbox[1];
        trx = obj->alignmentbox[2];
        try = obj->alignmentbox[3];
    }
    else
    {
        object_get_minmax_xy(obj, &blx, &bly, &trx, &try, NULL); // no extra transformation matrix
    }
    coordinate_t x = 0;
    coordinate_t y = 0;
    transformationmatrix_apply_transformation_xy(cell->trans, &x, &y);
    *cx = blx + trx + 2 * x;
    *cy = bly + try + 2 * y;
}

static void _flipx(struct object* cell, int ischild)
{
    coordinate_t cx, cy;
    _get_transformation_correction(cell, &cx, &cy);
    transformationmatrix_mirror_y(cell->trans);
    if(!ischild)
    {
        object_translate(cell, cx, 0);
    }
    if(!cell->isproxy)
    {
        if(cell->children)
        {
            for(unsigned int i = 0; i < vector_size(cell->children); ++i)
            {
                _flipx(vector_get(cell->children, i), 1);
            }
        }
    }
}

void object_flipx(struct object* cell)
{
    _flipx(cell, 0);
}

static void _flipy(struct object* cell, int ischild)
{
    coordinate_t cx, cy;
    _get_transformation_correction(cell, &cx, &cy);
    transformationmatrix_mirror_x(cell->trans);
    if(!ischild)
    {
        object_translate(cell, 0, cy);
    }
    if(!cell->isproxy)
    {
        if(cell->children)
        {
            for(unsigned int i = 0; i < vector_size(cell->children); ++i)
            {
                _flipy(vector_get(cell->children, i), 1);
            }
        }
    }
}

void object_flipy(struct object* cell)
{
    _flipy(cell, 0);
}

void object_apply_transformation(struct object* cell)
{
    if(cell->shapes)
    {
        for(unsigned int i = 0; i < vector_size(cell->shapes); ++i)
        {
            struct shape* shape = vector_get(cell->shapes, i);
            shape_apply_transformation(shape, cell->trans);
        }
    }
}

void object_transform_point(const struct object* cell, struct point* pt)
{
    transformationmatrix_apply_transformation(cell->trans, pt);
}

int object_is_pseudo(const struct object* cell)
{
    return cell->name == NULL;
}

int object_is_proxy(const struct object* cell)
{
    return cell->isproxy;
}

int object_has_shapes(const struct object* cell)
{
    return cell->shapes ? !vector_empty(cell->shapes) : 0;
}

int object_has_children(const struct object* cell)
{
    return cell->children ? !vector_empty(cell->children) : 0;
}

int object_has_ports(const struct object* cell)
{
    return cell->ports ? !vector_empty(cell->ports) : 0;
}

int object_is_empty(const struct object* cell)
{
    return !object_has_shapes(cell) && !object_has_children(cell) && !object_has_ports(cell);
}

int object_is_used(const struct object* cell)
{
    return cell->isused;
}

int object_is_child_array(const struct object* cell)
{
    return cell->isproxy && cell->isarray;
}

int object_has_anchor(const struct object* cell, const char* anchorname)
{
    if(cell->isproxy)
    {
        if(!cell->reference->anchors)
        {
            return 0;
        }
        if(hashmap_exists(cell->reference->anchors, anchorname))
        {
            struct anchor* anchor = hashmap_get(cell->reference->anchors, anchorname);
            return !_anchor_is_area(anchor);
        }
        else
        {
            return 0;
        }
    }
    else
    {
        if(!cell->anchors)
        {
            return 0;
        }
        if(hashmap_exists(cell->anchors, anchorname))
        {
            struct anchor* anchor = hashmap_get(cell->anchors, anchorname);
            return !_anchor_is_area(anchor);
        }
        else
        {
            return 0;
        }
    }
}

int object_has_area_anchor(const struct object* cell, const char* anchorname)
{
    if(cell->isproxy)
    {
        if(!cell->reference->anchors)
        {
            return 0;
        }
        if(hashmap_exists(cell->reference->anchors, anchorname))
        {
            struct anchor* anchor = hashmap_get(cell->reference->anchors, anchorname);
            return _anchor_is_area(anchor);
        }
        else
        {
            return 0;
        }
    }
    else
    {
        if(!cell->anchors)
        {
            return 0;
        }
        if(hashmap_exists(cell->anchors, anchorname))
        {
            struct anchor* anchor = hashmap_get(cell->anchors, anchorname);
            return _anchor_is_area(anchor);
        }
        else
        {
            return 0;
        }
    }
}

int object_has_alignmentbox(const struct object* cell)
{
    if(object_is_proxy(cell))
    {
        return cell->reference->alignmentbox != NULL;
    }
    else
    {
        return cell->alignmentbox != NULL;
    }
}

const char* object_get_name(const struct object* cell)
{
    return cell->name;
}

const char* object_get_child_reference_name(const struct object* child)
{
    return child->reference->name;
}

coordinate_t object_get_area_anchor_width(const struct object* cell, const char* anchorname)
{
    struct point* anchor = object_get_area_anchor(cell, anchorname);
    coordinate_t width = anchor[1].x - anchor[0].x;
    free(anchor);
    return width;
}

coordinate_t object_get_area_anchor_height(const struct object* cell, const char* anchorname)
{
    struct point* anchor = object_get_area_anchor(cell, anchorname);
    coordinate_t height = anchor[1].y - anchor[0].y;
    free(anchor);
    return height;
}

void object_flatten_inline(struct object* cell, int flattenports)
{
    // add shapes and flatten children (recursive)
    if(cell->children)
    {
        for(unsigned int i = 0; i < vector_size(cell->children); ++i)
        {
            struct object* child = vector_get(cell->children, i);
            const struct object* reference = child->reference;
            struct object* flat = object_flatten(reference, flattenports);
            if(flat->shapes)
            {
                size_t size = vector_size(flat->shapes);
                while(size > 0)
                {
                    struct shape* S = object_disown_shape(flat, size - 1);
                    --size;
                    shape_apply_transformation(S, flat->trans);
                    shape_apply_transformation(S, child->trans);
                    for(unsigned int ix = 1; ix <= child->xrep; ++ix)
                    {
                        for(unsigned int iy = 1; iy <= child->yrep; ++iy)
                        {
                            struct shape* copy = shape_copy(S);
                            shape_translate(copy, (ix - 1) * child->xpitch, (iy - 1) * child->ypitch);
                            object_add_raw_shape(cell, copy);
                        }
                    }
                    shape_destroy(S);
                }
            }
            if(flattenports)
            {
                for(unsigned int p = 0; p < vector_size(flat->ports); ++p)
                {
                    struct port* port = vector_get(flat->ports, p);
                    coordinate_t x = port->where->x;
                    coordinate_t y = port->where->y;
                    transformationmatrix_apply_transformation_xy(child->trans, &x, &y);
                    transformationmatrix_apply_transformation_xy(flat->trans, &x, &y);
                    _add_port(cell, port->name, port->layer, x, y, port->isbusport, port->busindex, port->sizehint);
                }
            }
            object_destroy(flat);
        }
        vector_destroy(cell->children);
        cell->children = NULL;
        vector_destroy(cell->references);
        cell->references = NULL;
    }
}

struct object* object_flatten(const struct object* cell, int flattenports)
{
    struct object* new = object_copy(cell);
    object_flatten_inline(new, flattenports);
    return new;
}

unsigned int object_get_child_xrep(const struct object* cell)
{
    return cell->xrep;
}

unsigned int object_get_child_yrep(const struct object* cell)
{
    return cell->yrep;
}

coordinate_t object_get_child_xpitch(const struct object* cell)
{
    return cell->xpitch;
}

coordinate_t object_get_child_ypitch(const struct object* cell)
{
    return cell->ypitch;
}

static void _collect_references(const struct object* cell, struct const_vector* references)
{
    if(cell->references)
    {
        struct vector_const_iterator* it = vector_const_iterator_create(cell->references);
        while(vector_const_iterator_is_valid(it))
        {
            const struct object* ref = vector_const_iterator_get(it);
            _collect_references(ref, references);
            const_vector_append(references, ref);
            vector_const_iterator_next(it);
        }
        vector_const_iterator_destroy(it);
    }
}

struct const_vector* object_collect_references(const struct object* cell)
{
    struct const_vector* references = const_vector_create(8);
    _collect_references(cell, references);
    return references;
}

static void _collect_references_mutable(const struct object* cell, struct vector* references)
{
    if(cell->references)
    {
        struct vector_iterator* it = vector_iterator_create(cell->references);
        while(vector_iterator_is_valid(it))
        {
            struct object* ref = vector_iterator_get(it);
            _collect_references_mutable(ref, references);
            vector_append(references, ref);
            vector_iterator_next(it);
        }
        vector_iterator_destroy(it);
    }
}

struct vector* object_collect_references_mutable(struct object* cell)
{
    struct vector* references = vector_create(8, NULL);
    _collect_references_mutable(cell, references);
    return references;
}

/*
const char* object_get_identifier(const struct object* cell)
{
    return cell->identifier;
}
*/

struct shape_iterator {
    const struct vector* shapes;
    size_t index;
};

struct shape_iterator* object_create_shape_iterator(const struct object* cell)
{
    struct shape_iterator* it = malloc(sizeof(*it));
    it->shapes = cell->shapes;
    it->index = 0;
    return it;
}

int shape_iterator_is_valid(struct shape_iterator* it)
{
    if(!it->shapes)
    {
        return 0;
    }
    else
    {
        return it->index < vector_size(it->shapes);
    }
}

void shape_iterator_next(struct shape_iterator* it)
{
    it->index += 1;
}

const struct shape* shape_iterator_get(struct shape_iterator* it)
{
    return vector_get_const(it->shapes, it->index);
}

void shape_iterator_destroy(struct shape_iterator* it)
{
    free(it);
}

// child iterator
struct child_iterator {
    const struct vector* children;
    size_t index;
};

struct child_iterator* object_create_child_iterator(const struct object* cell)
{
    struct child_iterator* it = malloc(sizeof(*it));
    it->children = cell->children;
    it->index = 0;
    return it;
}

int child_iterator_is_valid(struct child_iterator* it)
{
    if(!it->children)
    {
        return 0;
    }
    else
    {
        return it->index < vector_size(it->children);
    }
}

void child_iterator_next(struct child_iterator* it)
{
    it->index += 1;
}

const struct object* child_iterator_get(struct child_iterator* it)
{
    return vector_get_const(it->children, it->index);
}

void child_iterator_destroy(struct child_iterator* it)
{
    free(it);
}

// reference iterator
struct reference_iterator {
    const struct vector* references;
    size_t index;
};

struct reference_iterator* object_create_reference_iterator(const struct object* cell)
{
    struct reference_iterator* it = malloc(sizeof(*it));
    it->references = cell->references;
    it->index = 0;
    return it;
}

int reference_iterator_is_valid(struct reference_iterator* it)
{
    if(!it->references)
    {
        return 0;
    }
    else
    {
        return it->index < vector_size(it->references);
    }
}

void reference_iterator_next(struct reference_iterator* it)
{
    it->index += 1;
}

const struct object* reference_iterator_get(struct reference_iterator* it)
{
    return vector_get_const(it->references, it->index);
}

void reference_iterator_destroy(struct reference_iterator* it)
{
    free(it);
}

// mutable reference iterator
struct mutable_reference_iterator {
    struct vector* references;
    size_t index;
};

struct mutable_reference_iterator* object_create_mutable_reference_iterator(struct object* cell)
{
    struct mutable_reference_iterator* it = malloc(sizeof(*it));
    it->references = cell->references;
    it->index = 0;
    return it;
}

int mutable_reference_iterator_is_valid(struct mutable_reference_iterator* it)
{
    if(!it->references)
    {
        return 0;
    }
    else
    {
        return it->index < vector_size(it->references);
    }
}

void mutable_reference_iterator_next(struct mutable_reference_iterator* it)
{
    it->index += 1;
}

struct object* mutable_reference_iterator_get(struct mutable_reference_iterator* it)
{
    return vector_get(it->references, it->index);
}

void mutable_reference_iterator_destroy(struct mutable_reference_iterator* it)
{
    free(it);
}

// anchor iterator
struct anchor_iterator {
    const struct object* object;
    struct hashmap_const_iterator* anchoriterator;
    struct point* container;
};

struct anchor_iterator* object_create_anchor_iterator(const struct object* cell)
{
    struct anchor_iterator* it = malloc(sizeof(*it));
    it->object = cell;
    it->anchoriterator = hashmap_const_iterator_create(cell->anchors);
    it->container = NULL;
    return it;
}

int anchor_iterator_is_valid(struct anchor_iterator* it)
{
    return hashmap_const_iterator_is_valid(it->anchoriterator);
}

void anchor_iterator_next(struct anchor_iterator* it)
{
    return hashmap_const_iterator_next(it->anchoriterator);
}

const struct point* anchor_iterator_anchor(struct anchor_iterator* it)
{
    const char* key = hashmap_const_iterator_key(it->anchoriterator);
    const struct anchor* anchor = hashmap_const_iterator_value(it->anchoriterator);
    // get anchor through object methods for proper transformation
    if(_anchor_is_area(anchor))
    {
        struct point* anchor = object_get_area_anchor(it->object, key);
        if(it->container)
        {
            free(it->container);
        }
        it->container = malloc(2 * sizeof(*it->container));
        memcpy(it->container, anchor, 2 * sizeof(*it->container));
        free(anchor);
    }
    else
    {
        struct point* anchor = object_get_anchor(it->object, key);
        if(it->container)
        {
            free(it->container);
        }
        it->container = malloc(sizeof(*it->container));
        memcpy(it->container, anchor, sizeof(*it->container));
        free(anchor);
    }
    return it->container;
}

const char* anchor_iterator_name(struct anchor_iterator* it)
{
    const char* key = hashmap_const_iterator_key(it->anchoriterator);
    return key;
}

int anchor_iterator_is_area(struct anchor_iterator* it)
{
    const struct anchor* anchor = hashmap_const_iterator_value(it->anchoriterator);
    return _anchor_is_area(anchor);
}

void anchor_iterator_destroy(struct anchor_iterator* it)
{
    hashmap_const_iterator_destroy(it->anchoriterator);
    if(it->container)
    {
        free(it->container);
    }
    free(it);
}

// port iterator
struct port_iterator {
    const struct vector* ports;
    size_t index;
};

struct port_iterator* object_create_port_iterator(const struct object* cell)
{
    struct port_iterator* it = malloc(sizeof(*it));
    it->ports = cell->ports;
    it->index = 0;
    return it;
}

int port_iterator_is_valid(struct port_iterator* it)
{
    if(!it->ports)
    {
        return 0;
    }
    else
    {
        return it->index < vector_size(it->ports);
    }
}

void port_iterator_next(struct port_iterator* it)
{
    it->index += 1;
}

void port_iterator_get(struct port_iterator* it, const char** portname, const struct point** portwhere, const struct generics** portlayer, int* portisbusport, int* portbusindex, unsigned int* sizehint)
{
    const struct port* port = vector_get_const(it->ports, it->index);
    if(portname) { *portname = port->name; }
    if(portwhere) { *portwhere = port->where; }
    if(portlayer) { *portlayer = port->layer; }
    if(portisbusport) { *portisbusport = port->isbusport; }
    if(portbusindex) { *portbusindex = port->busindex; }
    if(sizehint) { *sizehint = port->sizehint; }
}

void port_iterator_destroy(struct port_iterator* it)
{
    free(it);
}

// label iterator
struct label_iterator {
    const struct vector* labels;
    size_t index;
};

struct label_iterator* object_create_label_iterator(const struct object* cell)
{
    struct label_iterator* it = malloc(sizeof(*it));
    it->labels = cell->labels;
    it->index = 0;
    return it;
}

int label_iterator_is_valid(struct label_iterator* it)
{
    if(!it->labels)
    {
        return 0;
    }
    else
    {
        return it->index < vector_size(it->labels);
    }
}

void label_iterator_next(struct label_iterator* it)
{
    it->index += 1;
}

void label_iterator_get(struct label_iterator* it, const char** labelname, const struct point** labelwhere, const struct generics** labellayer, unsigned int* sizehint)
{
    const struct port* label = vector_get_const(it->labels, it->index);
    if(labelname) { *labelname = label->name; }
    if(labelwhere) { *labelwhere = label->where; }
    if(labellayer) { *labellayer = label->layer; }
    if(sizehint) { *sizehint = label->sizehint; }
}

void label_iterator_destroy(struct label_iterator* it)
{
    free(it);
}


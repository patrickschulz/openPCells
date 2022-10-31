#include "object.h"

#include <stdlib.h>
#include <string.h>
#include <stdio.h>

#include "util.h"

#define min(a, b) ((a) < (b) ? (a) : (b))
#define max(a, b) ((a) > (b) ? (a) : (b))

#define OBJECT_DEFAULT_CHILDREN_SIZE 16
#define OBJECT_DEFAULT_PORT_SIZE 16

struct port {
    char* name;
    point_t* where;
    const struct generics* layer;
    int isbusport;
    int busindex;
};

struct object {
    char* name;
    int isproxy;
    struct transformationmatrix* trans;

    union{
        // proxy objects (light handles to children)
        struct {
            const struct object* reference;
            int isarray;
            unsigned int xrep;
            unsigned int yrep;
            unsigned int xpitch;
            unsigned int ypitch;
        };
        // full objects
        struct {
            struct vector* shapes; // stores struct shape*
            struct vector* ports; // stores struct port*
            struct hashmap* anchors;
            struct vector* children; // stores struct object*
            struct vector* references; // stores struct object*
            coordinate_t* alignmentbox; // NULL or contains four coordinates: blx, blx, trx, try
        };
    };
};

static struct object* _create(const char* name)
{
    struct object* obj = malloc(sizeof(*obj));
    memset(obj, 0, sizeof(*obj));
    obj->name = strdup(name);
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

static struct object* _create_proxy(const char* name, struct object* reference)
{
    struct object* obj = _create(name);
    obj->reference = reference;
    obj->isproxy = 1;
    // don't need a transformation matrix as it is created by add_child
    obj->isarray = 0;
    obj->xrep = 1;
    obj->yrep = 1;
    obj->xpitch = 0;
    obj->ypitch = 0;
    return obj;
}

struct object* object_copy(const struct object* cell)
{
    struct object* new = _create(cell->name);
    new->isproxy = cell->isproxy;

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
            object_set_alignment_box(new, cell->alignmentbox[0], cell->alignmentbox[1], cell->alignmentbox[2], cell->alignmentbox[3]);
        }

        // anchors
        if(cell->anchors)
        {
            new->anchors = hashmap_create();
            struct hashmap_const_iterator* it = hashmap_const_iterator_create(cell->anchors);
            while(hashmap_const_iterator_is_valid(it))
            {
                const char* key = hashmap_const_iterator_key(it);
                const point_t* pt = hashmap_const_iterator_value(it);
                hashmap_insert(new->anchors, key, point_copy(pt));
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
            hashmap_destroy(cell->anchors, point_destroy);
        }

        if(cell->ports)
        {
            vector_destroy(cell->ports);
        }
    }

    // name
    if(cell->name)
    {
        free(cell->name);
    }

    // transformation matrix
    transformationmatrix_destroy(cell->trans);

    // alignmentbox
    if(cell->alignmentbox)
    {
        free(cell->alignmentbox);
    }

    // object itself
    free(cell);
}

void object_add_raw_shape(struct object* cell, struct shape* S)
{
    if(!cell->shapes)
    {
        cell->shapes = vector_create(32, shape_destroy);
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
    struct shape* shape = vector_get(cell->shapes, idx);
    vector_remove(cell->shapes, idx, NULL);
    return shape;
}

void object_remove_shape(struct object* cell, size_t idx)
{
    vector_remove(cell->shapes, idx, shape_destroy);
}

struct object* object_add_child(struct object* cell, struct object* child, const char* name)
{
    struct object* proxy = _create_proxy(name, child);
    proxy->trans = transformationmatrix_invert(cell->trans);
    if(!cell->children)
    {
        cell->children = vector_create(OBJECT_DEFAULT_CHILDREN_SIZE, object_destroy);
        cell->references = vector_create(8, object_destroy);
    }
    vector_append(cell->children, proxy);
    // check if child is already stored
    int found = 0;
    struct vector_const_iterator* it = vector_const_iterator_create(cell->references);
    while(vector_const_iterator_is_valid(it))
    {
        const struct object* ref = vector_const_iterator_get(it);
        if(ref == child)
        {
            found = 1;
            break;
        }
        vector_const_iterator_next(it);
    }
    vector_const_iterator_destroy(it);
    if(!found)
    {
        vector_append(cell->references, child);
    }
    return proxy;
}

struct object* object_add_child_array(struct object* cell, struct object* child, const char* name, unsigned int xrep, unsigned int yrep, unsigned int xpitch, unsigned int ypitch)
{
    struct object* proxy = object_add_child(cell, child, name);
    proxy->isarray = 1;
    proxy->xrep = xrep;
    proxy->yrep = yrep;
    proxy->xpitch = xpitch;
    proxy->ypitch = ypitch;
    return proxy;
}

void object_merge_into_shallow(struct object* cell, const struct object* other)
{
    if(other->shapes)
    {
        for(unsigned int i = 0; i < vector_size(other->shapes); ++i)
        {
            struct shape* shape = shape_copy(vector_get(other->shapes, i));
            object_add_shape(cell, shape);
            shape_apply_transformation(shape, other->trans);
        }
    }
}

void object_add_anchor(struct object* cell, const char* name, coordinate_t x, coordinate_t y)
{
    if(!cell->anchors)
    {
        cell->anchors = hashmap_create();
    }
    if(hashmap_exists(cell->anchors, name))
    {
        point_t* pt = hashmap_get(cell->anchors, name);
        pt->x = x;
        pt->y = y;
    }
    else
    {
        hashmap_insert(cell->anchors, name, point_create(x, y));
    }
}

void object_add_anchor_suffix(struct object* cell, const char* base, const char* suffix, coordinate_t x, coordinate_t y)
{
    if(!cell->anchors)
    {
        cell->anchors = hashmap_create();
    }
    size_t len = strlen(base) + strlen(suffix);
    char* name = malloc(len + 1);
    snprintf(name, len + 1, "%s%s", base, suffix);
    hashmap_insert(cell->anchors, name, point_create(x, y));
    free(name);
}

void object_add_anchor_area(struct object* cell, const char* base, coordinate_t width, coordinate_t height, coordinate_t xshift, coordinate_t yshift)
{
    object_add_anchor_suffix(cell, base, "bl", xshift - width / 2, yshift - height / 2);
    object_add_anchor_suffix(cell, base, "cl", xshift - width / 2, yshift             );
    object_add_anchor_suffix(cell, base, "tl", xshift - width / 2, yshift + height / 2);
    object_add_anchor_suffix(cell, base, "bc", xshift            , yshift - height / 2);
    object_add_anchor_suffix(cell, base, "cc", xshift            , yshift             );
    object_add_anchor_suffix(cell, base, "tc", xshift            , yshift + height / 2);
    object_add_anchor_suffix(cell, base, "br", xshift + width / 2, yshift - height / 2);
    object_add_anchor_suffix(cell, base, "cr", xshift + width / 2, yshift             );
    object_add_anchor_suffix(cell, base, "tr", xshift + width / 2, yshift + height / 2);
}

void object_add_anchor_area_bltr(struct object* cell, const char* base, const point_t* bl, const point_t* tr)
{
    coordinate_t blx = bl->x;
    coordinate_t bly = bl->y;
    coordinate_t trx = tr->x;
    coordinate_t try = tr->y;
    object_add_anchor_suffix(cell, base, "bl", blx, bly);
    object_add_anchor_suffix(cell, base, "cl", blx, (bly + try) / 2);
    object_add_anchor_suffix(cell, base, "tl", blx, try);
    object_add_anchor_suffix(cell, base, "bc", (blx + trx) / 2, bly);
    object_add_anchor_suffix(cell, base, "cc", (blx + trx) / 2, (bly + try) / 2);
    object_add_anchor_suffix(cell, base, "tc", (blx + trx) / 2, try);
    object_add_anchor_suffix(cell, base, "br", trx, bly);
    object_add_anchor_suffix(cell, base, "cr", trx, (bly + try) / 2);
    object_add_anchor_suffix(cell, base, "tr", trx, try);
}

static point_t* _get_special_anchor(const struct object* cell, const char* name, const struct transformationmatrix* trans1, const struct transformationmatrix* trans2)
{
    if(!cell->alignmentbox)
    {
        return NULL;
    }
    coordinate_t blx = cell->alignmentbox[0];
    coordinate_t bly = cell->alignmentbox[1];
    coordinate_t trx = cell->alignmentbox[2];
    coordinate_t try = cell->alignmentbox[3];
    transformationmatrix_apply_transformation_xy(trans1, &blx, &bly);
    transformationmatrix_apply_transformation_xy(trans1, &trx, &try);
    if(trans2)
    {
        transformationmatrix_apply_transformation_xy(trans2, &blx, &bly);
        transformationmatrix_apply_transformation_xy(trans2, &trx, &try);
    }
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
    coordinate_t x, y;
    if(strcmp(name, "left") == 0)
    {
        x = blx;
        y = (bly + try) / 2;
    }
    else if(strcmp(name, "right") == 0)
    {
        x = trx;
        y = (bly + try) / 2;
    }
    else if(strcmp(name, "top") == 0)
    {
        x = (blx + trx) / 2;
        y = try;
    }
    else if(strcmp(name, "bottom") == 0)
    {
        x = (blx + trx) / 2;
        y = bly;
    }
    else if(strcmp(name, "bottomleft") == 0)
    {
        x = blx;
        y = bly;
    }
    else if(strcmp(name, "bottomright") == 0)
    {
        x = trx;
        y = bly;
    }
    else if(strcmp(name, "topleft") == 0)
    {
        x = blx;
        y = try;
    }
    else if(strcmp(name, "topright") == 0)
    {
        x = trx;
        y = try;
    }
    else
    {
        return NULL;
    }
    return point_create(x, y);
}

static point_t* _get_regular_anchor(const struct object* cell, const char* name)
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
            return point_copy((point_t*) hashmap_get(obj->anchors, name));
        }
    }
    return NULL;
}

point_t* object_get_anchor(const struct object* cell, const char* name)
{
    struct transformationmatrix* trans1 = cell->trans;
    struct transformationmatrix* trans2 = NULL;
    const struct object* obj = cell;
    if(cell->isproxy)
    {
        obj = cell->reference;
        trans2 = obj->trans;
    }
    point_t* pt = NULL;
    pt = _get_special_anchor(obj, name, trans1, trans2);
    if(pt)
    {
        return pt;
    }
    else
    {
        pt = _get_regular_anchor(obj, name);
        if(pt)
        {
            transformationmatrix_apply_transformation(obj->trans, pt);
            if(cell->isproxy)
            {
                transformationmatrix_apply_transformation(cell->trans, pt);
            }
            return pt;
        }
    }
    // no anchor found
    return NULL;
}

point_t* object_get_array_anchor(const struct object* cell, int xindex, int yindex, const char* name)
{
    if(!cell->isarray)
    {
        return NULL;
    }
    struct transformationmatrix* trans1 = cell->trans;
    struct transformationmatrix* trans2 = cell->reference->trans;
    const struct object* obj = cell->reference;
    // resolve negative indices
    if(xindex < 0)
    {
        xindex = cell->xrep + xindex + 1;
    }
    if(yindex < 0)
    {
        yindex = cell->yrep + yindex + 1;
    }
    point_t* pt = NULL;
    pt = _get_special_anchor(obj, name, trans1, trans2);
    if(pt)
    {
        point_translate(pt, cell->xpitch * (xindex - 1), cell->ypitch * (yindex - 1));
        return pt;
    }
    else
    {
        pt = _get_regular_anchor(obj, name);
        if(pt)
        {
            transformationmatrix_apply_transformation(obj->trans, pt);
            if(cell->isproxy)
            {
                transformationmatrix_apply_transformation(cell->trans, pt);
            }
            point_translate(pt, cell->xpitch * (xindex - 1), cell->ypitch * (yindex - 1));
            return pt;
        }
    }
    // no anchor found
    return NULL;
}

const struct hashmap* object_get_all_regular_anchors(const struct object* cell)
{
    const struct object* obj = cell;
    if(cell->isproxy)
    {
        obj = cell->reference;
    }
    if(obj->anchors)
    {
        return obj->anchors;
    }
    return NULL;
}

void _port_destroy(void* p)
{
    struct port* port = p;
    point_destroy(port->where);
    free(port->name);
    free(port);
}

static void _add_port(struct object* cell, const char* name, const char* anchorname, const struct generics* layer, coordinate_t x, coordinate_t y, int isbusport, int busindex, int storeanchor)
{
    if(!generics_is_empty(layer))
    {
        if(!cell->ports)
        {
            cell->ports = vector_create(OBJECT_DEFAULT_PORT_SIZE, _port_destroy);
        }
        struct port* port = malloc(sizeof(*port));
        port->where = point_create(x, y);
        port->layer = layer;
        port->isbusport = isbusport;
        port->busindex = busindex;
        port->name = malloc(strlen(name) + 1);
        strcpy(port->name, name);
        vector_append(cell->ports, port);
    }
    if(storeanchor)
    {
        object_add_anchor(cell, anchorname, x, y);
    }
}

void object_add_port(struct object* cell, const char* name, const struct generics* layer, const point_t* where, int storeanchor)
{
    _add_port(cell, name, name, layer, where->x, where->y, 0, 0, storeanchor);
}

void object_add_bus_port(struct object* cell, const char* name, const struct generics* layer, const point_t* where, int startindex, int endindex, unsigned int xpitch, unsigned int ypitch, int storeanchor)
{
    int shift = 0;
    if(startindex < endindex)
    {
        for(int i = startindex; i <= endindex; ++i)
        {
            unsigned int digits = util_num_digits(i);
            unsigned int len = strlen(name) + digits; // + 1 for underscore
            char* anchorname = malloc(len + 1);
            snprintf(anchorname, len + 1, "%s%*d", name, digits, i);
            _add_port(cell, name, anchorname, layer, where->x + shift * xpitch, where->y + shift * ypitch, 1, i, storeanchor);
            free(anchorname);
            ++shift;
        }
    }
    else
    {
        for(int i = startindex; i >= endindex; --i)
        {
            unsigned int digits = util_num_digits(i);
            unsigned int len = strlen(name) + digits; // + 1 for underscore
            char* anchorname = malloc(len + 1);
            snprintf(anchorname, len + 1, "%s%*d", name, digits, i);
            _add_port(cell, name, anchorname, layer, where->x + shift * xpitch, where->y + shift * ypitch, 1, i, storeanchor);
            free(anchorname);
            ++shift;
        }
    }
}

const struct vector* object_get_ports(const struct object* cell)
{
    return cell->ports;
}

void object_set_alignment_box(struct object* cell, coordinate_t blx, coordinate_t bly, coordinate_t trx, coordinate_t try)
{
    if(!cell->alignmentbox)
    {
        cell->alignmentbox = calloc(4, sizeof(coordinate_t));
    }
    cell->alignmentbox[0] = blx;
    cell->alignmentbox[1] = bly;
    cell->alignmentbox[2] = trx;
    cell->alignmentbox[3] = try;
}

void object_inherit_alignment_box(struct object* cell, const struct object* other)
{
    point_t* bl = object_get_anchor(other, "bottomleft");
    point_t* tr = object_get_anchor(other, "topright");
    if(bl && tr)
    {
        coordinate_t blx = bl->x;
        coordinate_t bly = bl->y;
        coordinate_t trx = tr->x;
        coordinate_t try = tr->y;
        if(cell->alignmentbox)
        {
            coordinate_t sblx = cell->alignmentbox[0];
            coordinate_t sbly = cell->alignmentbox[1];
            coordinate_t strx = cell->alignmentbox[2];
            coordinate_t stry = cell->alignmentbox[3];
            blx = min(blx, sblx);
            bly = min(bly, sbly);
            trx = max(trx, strx);
            try = max(try, stry);
        }
        object_set_alignment_box(cell, blx, bly, trx, try);
        point_destroy(bl);
        point_destroy(tr);
    }
}

int object_get_alignment_box_corners(const struct object* cell, coordinate_t* blx, coordinate_t* bly, coordinate_t* trx, coordinate_t* try)
{
    if(!cell->alignmentbox)
    {
        return 0;
    }
    *blx = cell->alignmentbox[0];
    *bly = cell->alignmentbox[1];
    *trx = cell->alignmentbox[2];
    *try = cell->alignmentbox[3];
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

static int _get_move_anchor_translation(const struct object* cell, const char* name, coordinate_t wx, coordinate_t wy, coordinate_t* dx, coordinate_t* dy)
{
    point_t* anchor = object_get_anchor(cell, name);
    if(anchor)
    {
        *dx = wx - anchor->x;
        *dy = wy - anchor->y;
        point_destroy(anchor);
        return 1;
    }
    else
    {
        return 0;
    }
}

int object_move_anchor(struct object* cell, const char* name, coordinate_t x, coordinate_t y)
{
    coordinate_t dx = 0;
    coordinate_t dy = 0;
    int ret = _get_move_anchor_translation(cell, name, x, y, &dx, &dy);
    if(!ret)
    {
        return 0;
    }
    object_translate(cell, dx, dy);
    return 1;
}

int object_move_anchor_x(struct object* cell, const char* name, coordinate_t x)
{
    coordinate_t dx = 0;
    coordinate_t dy = 0; // not used
    int ret = _get_move_anchor_translation(cell, name, x, 0, &dx, &dy);
    if(!ret)
    {
        return 0;
    }
    object_translate(cell, dx, 0);
    return 1;
}

int object_move_anchor_y(struct object* cell, const char* name, coordinate_t y)
{
    coordinate_t dx = 0; // not used
    coordinate_t dy = 0;
    int ret = _get_move_anchor_translation(cell, name, 0, y, &dx, &dy);
    if(!ret)
    {
        return 0;
    }
    object_translate(cell, 0, dy);
    return 1;
}

void object_scale(struct object* cell, double factor)
{
    transformationmatrix_scale(cell->trans, factor);
}

void object_get_minmax_xy(const struct object* cell, coordinate_t* minxp, coordinate_t* minyp, coordinate_t* maxxp, coordinate_t* maxyp)
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
            coordinate_t _minx;
            coordinate_t _maxx;
            coordinate_t _miny;
            coordinate_t _maxy;
            shape_get_minmax_xy(S, cell->trans, &_minx, &_miny, &_maxx, &_maxy);
            minx = min(minx, _minx);
            maxx = max(maxx, _maxx);
            miny = min(miny, _miny);
            maxy = max(maxy, _maxy);
        }
    }
    if(cell->children)
    {
        for(unsigned int i = 0; i < vector_size(cell->children); ++i)
        {
            const struct object* child = vector_get(cell->children, i);
            const struct object* obj = child->reference;
            coordinate_t minx_, maxx_, miny_, maxy_;
            object_get_minmax_xy(obj, &minx_, &miny_, &maxx_, &maxy_);
            // FIXME: transformation?
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
void object_foreach_shapes(struct object* cell, void (*func)(struct shape*))
{
    for(unsigned int i = 0; i < vector_size(cell->shapes); ++i)
    {
        struct shape* shape = vector_get(cell->shapes, i);
        func(shape);
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

const struct transformationmatrix* object_get_transformation_matrix(const struct object* cell)
{
    return cell->trans;
}

static void _get_transformation_correction(const struct object* cell, coordinate_t* cx, coordinate_t* cy)
{
    const struct object* obj = cell;
    if(cell->isproxy)
    {
        obj = cell->reference;
    }
    coordinate_t blx, bly, trx, try;
    if(obj->alignmentbox)
    {
        blx = obj->alignmentbox[0];
        bly = obj->alignmentbox[1];
        trx = obj->alignmentbox[2];
        try = obj->alignmentbox[3];
    }
    else
    {
        object_get_minmax_xy(obj, &blx, &bly, &trx, &try);
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

void object_transform_point(const struct object* cell, point_t* pt)
{
    transformationmatrix_apply_transformation(cell->trans, pt);
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

int object_is_child_array(const struct object* cell)
{
    return cell->isarray;
}

const char* object_get_name(const struct object* cell)
{
    return cell->name;
}

const char* object_get_child_reference_name(const struct object* child)
{
    return child->reference->name;
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
                    shape_apply_transformation(S, child->trans);
                    shape_apply_transformation(S, flat->trans);
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
                    _add_port(cell, port->name, NULL, port->layer, x, y, port->isbusport, port->busindex, 0); // 0: !storeanchor
                }
            }
            object_destroy(flat);
        }
        // FIXME: destroy children
        //vector_destroy(cell->children);
    }
    cell->children = NULL;
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

unsigned int object_get_child_xpitch(const struct object* cell)
{
    return cell->xpitch;
}

unsigned int object_get_child_ypitch(const struct object* cell)
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

void port_iterator_get(struct port_iterator* it, const char** portname, const point_t** portwhere, const struct generics** portlayer, int* portisbusport, int* portbusindex)
{
    const struct port* port = vector_get_const(it->ports, it->index);
    if(portname) { *portname = port->name; }
    if(portwhere) { *portwhere = port->where; }
    if(portlayer) { *portlayer = port->layer; }
    if(portisbusport) { *portisbusport = port->isbusport; }
    if(portbusindex) { *portbusindex = port->busindex; }
}

void port_iterator_destroy(struct port_iterator* it)
{
    free(it);
}


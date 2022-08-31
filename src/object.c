#include "object.h"

#include <stdlib.h>
#include <string.h>
#include <stdio.h>

#include "util.h"
#include "pcell.h"

#define min(a, b) ((a) < (b) ? (a) : (b))
#define max(a, b) ((a) > (b) ? (a) : (b))

#define OBJECT_DEFAULT_CHILDREN_SIZE 16
#define OBJECT_DEFAULT_PORT_SIZE 16

struct port {
    char* name;
    point_t* where;
    struct generics* layer;
    int isbusport;
    int busindex;
};

struct object {
    char* name;

    // for children:
    // 'proxy' objects are light handles to objects
    // these are created by the 'all_child' method of objects
    // proxy objects behave like real objects (they can be moved etc.)
    int isproxy;
    char* identifier;
    struct object* reference;
    int isarray;
    unsigned int xrep;
    unsigned int yrep;
    unsigned int xpitch;
    unsigned int ypitch;

    struct transformationmatrix* trans;

    struct vector* shapes; // stores struct shape*

    struct vector* ports; // stores struct port*

    struct hashmap* anchors;

    coordinate_t* alignmentbox; // NULL or contains four coordinates: blx, blx, trx, try

    struct vector* children; // stores struct object*
};

static struct object* _create(void)
{
    struct object* obj = malloc(sizeof(*obj));
    memset(obj, 0, sizeof(*obj));
    return obj;
}

struct object* object_create(void)
{
    struct object* obj = _create();
    obj->trans = transformationmatrix_create();
    transformationmatrix_identity(obj->trans);
    obj->isproxy = 0;
    return obj;
}

struct object* object_create_proxy(const char* name, struct object* reference, const char* identifier)
{
    struct object* obj = _create();
    if(name)
    {
        obj->name = malloc(strlen(name) + 1);
        strcpy(obj->name, name);
    }
    obj->reference = reference;
    obj->identifier = malloc(strlen(identifier) + 1);
    strcpy(obj->identifier, identifier);
    obj->isproxy = 1;
    // don't need a transformation matrix as it is created by add_child
    obj->isarray = 0;
    obj->xrep = 1;
    obj->yrep = 1;
    obj->xpitch = 0;
    obj->ypitch = 0;
    return obj;
}

struct object* object_copy(struct object* cell)
{
    struct object* new = _create();
    new->isproxy = cell->isproxy;

    // name
    if(cell->name)
    {
        new->name = malloc(strlen(cell->name) + 1);
        strcpy(new->name, cell->name);
        new->reference = cell->reference;
    }
    
    // trans
    transformationmatrix_destroy(new->trans);
    new->trans = transformationmatrix_copy(cell->trans);

    if(cell->isproxy)
    {
        new->identifier = malloc(strlen(cell->identifier) + 1);
        strcpy(new->identifier, cell->identifier);
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
            struct hashmap_iterator* it = hashmap_iterator_create(cell->anchors);
            while(hashmap_iterator_is_valid(it))
            {
                const char* key = hashmap_iterator_key(it);
                point_t* pt = hashmap_iterator_value(it);
                hashmap_insert(new->anchors, key, point_copy(pt));
                hashmap_iterator_next(it);
            }
            hashmap_iterator_destroy(it);
        }

        // children
        if(cell->children)
        {
            new->children = vector_create(vector_size(cell->children));
            for(unsigned int i = 0; i < vector_size(cell->children); ++i)
            {
                vector_append(new->children, object_copy(vector_get(cell->children, i)));
            }
        }
    }
    return new;
}


void _port_destroy(void* p)
{
    struct port* port = p;
    point_destroy(port->where);
    free(port->name);
    free(port);
}

void object_destroy(void* cellv)
{
    struct object* cell = cellv;
    if(cell->isproxy)
    {
        free(cell->identifier);
    }
    else
    {
        // shapes
        if(cell->shapes)
        {
            vector_destroy(cell->shapes, shape_destroy);
        }

        // children
        if(cell->children)
        {
            vector_destroy(cell->children, object_destroy);
        }

        // anchors
        if(cell->anchors)
        {
            hashmap_destroy(cell->anchors, point_destroy);
        }

        if(cell->ports)
        {
            vector_destroy(cell->ports, _port_destroy);
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
        cell->shapes = vector_create(32);
    }
    vector_append(cell->shapes, S);
}

void object_add_shape(struct object* cell, struct shape* S)
{
    object_add_raw_shape(cell, S);
    shape_apply_inverse_transformation(S, cell->trans);
}

void object_disown_shape(struct object* cell, size_t idx)
{
    vector_remove(cell->shapes, idx, NULL);
}

void object_remove_shape(struct object* cell, size_t idx)
{
    vector_remove(cell->shapes, idx, shape_destroy);
}

struct object* object_add_child(struct object* cell, struct pcell_state* pcell_state, const char* identifier, const char* name)
{
    struct object* reference = pcell_use_cell_reference(pcell_state, identifier);
    struct object* child = object_create_proxy(name, reference, identifier);
    child->trans = transformationmatrix_invert(cell->trans);
    if(!cell->children)
    {
        cell->children = vector_create(OBJECT_DEFAULT_CHILDREN_SIZE);
    }
    vector_append(cell->children, child);
    return child;
}

struct object* object_add_child_array(struct object* cell, struct pcell_state* pcell_state, const char* identifier, unsigned int xrep, unsigned int yrep, unsigned int xpitch, unsigned int ypitch, const char* name)
{
    struct object* child = object_add_child(cell, pcell_state, identifier, name);
    child->isarray = 1;
    child->xrep = xrep;
    child->yrep = yrep;
    child->xpitch = xpitch;
    child->ypitch = ypitch;
    return child;
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
    hashmap_insert(cell->anchors, name, point_create(x, y));
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
        if(cell->isproxy && cell->isarray)
        {
            y += (cell->yrep - 1) * cell->ypitch / 2;
        }
    }
    else if(strcmp(name, "right") == 0)
    {
        x = trx;
        y = (bly + try) / 2;
        if(cell->isproxy && cell->isarray)
        {
            x += (cell->xrep - 1) * cell->xpitch;
            y += (cell->yrep - 1) * cell->ypitch / 2;
        }
    }
    else if(strcmp(name, "top") == 0)
    {
        x = (blx + trx) / 2;
        y = try;
        if(cell->isproxy && cell->isarray)
        {
            x += (cell->xrep - 1) * cell->xpitch / 2;
            y += (cell->yrep - 1) * cell->ypitch;
        }
    }
    else if(strcmp(name, "bottom") == 0)
    {
        x = (blx + trx) / 2;
        y = bly;
        if(cell->isproxy && cell->isarray)
        {
            x += (cell->xrep - 1) * cell->xpitch / 2;
        }
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
        if(cell->isproxy && cell->isarray)
        {
            x += (cell->xrep - 1) * cell->xpitch;
        }
    }
    else if(strcmp(name, "topleft") == 0)
    {
        x = blx;
        y = try;
        if(cell->isproxy && cell->isarray)
        {
            y += (cell->yrep - 1) * cell->ypitch;
        }
    }
    else if(strcmp(name, "topright") == 0)
    {
        x = trx;
        y = try;
        if(cell->isproxy && cell->isarray)
        {
            x += (cell->xrep - 1) * cell->xpitch;
            y += (cell->yrep - 1) * cell->ypitch;
        }
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

static void _add_port(struct object* cell, const char* name, const char* anchorname, struct generics* layer, coordinate_t x, coordinate_t y, int isbusport, int busindex, int storeanchor)
{
    if(!generics_is_empty(layer))
    {
        if(!cell->ports)
        {
            cell->ports = vector_create(OBJECT_DEFAULT_PORT_SIZE);
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

void object_add_port(struct object* cell, const char* name, struct generics* layer, const point_t* where, int storeanchor)
{
    _add_port(cell, name, name, layer, where->x, where->y, 0, 0, storeanchor);
}

void object_add_bus_port(struct object* cell, const char* name, struct generics* layer, const point_t* where, int startindex, int endindex, unsigned int xpitch, unsigned int ypitch, int storeanchor)
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

struct vector* object_get_ports(struct object* cell)
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

void object_move_to(struct object* cell, coordinate_t x, coordinate_t y)
{
    transformationmatrix_move_to(cell->trans, x, y);
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
            // FIXME: is the transformation really needed? If yes, then the shapes points also need to be transformed
            //local pt1 = point.create(minx_, miny_)
            //local pt2 = point.create(maxx_, maxy_)
            //obj.trans:apply_transformation(pt1)
            //obj.trans:apply_transformation(pt2)
            //minx_, miny_ = pt1:unwrap()
            //maxx_, maxy_ = pt2:unwrap()
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
    transformationmatrix_mirror_x(cell->trans);
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

void object_flatten(struct object* cell, struct pcell_state* pcell_state, int flattenports)
{
    // add shapes and flatten children (recursive)
    if(cell->children)
    {
        for(unsigned int i = 0; i < vector_size(cell->children); ++i)
        {
            struct object* child = vector_get(cell->children, i);
            struct object* reference = child->reference; // FIXME: do we need to copy? If this cell is used somewhere else (partial flatten) than that will most likely cause headaches
            object_flatten(reference, pcell_state, flattenports);
            if(reference->shapes)
            {
                for(unsigned int ix = 1; ix <= child->xrep; ++ix)
                {
                    for(unsigned int iy = 1; iy <= child->yrep; ++iy)
                    {
                        for(unsigned int i = 0; i < vector_size(reference->shapes); ++i)
                        {
                            struct shape* S = shape_copy(vector_get(reference->shapes, i));
                            shape_apply_transformation(S, child->trans);
                            shape_apply_transformation(S, reference->trans);
                            shape_translate(S, (ix - 1) * child->xpitch, (iy - 1) * child->ypitch);
                            object_add_raw_shape(cell, S);
                        }
                        //if flattenports then
                        //    for _, port in ipairs(cell.ports) do
                        //        local new = { name = port.name, layer = port.layer:copy(), where = port.where:copy() }
                        //        child.trans:apply_translation(new.where)
                        //        obj.trans:apply_translation(new.where)
                        //        new.where:translate((ix - 1) * xpitch, (iy - 1) * ypitch)
                        //    end
                        //end
                    }
                }
            }
        }
        // destroy children
        for(unsigned int i = 0; i < vector_size(cell->children); ++i)
        {
            struct object* child = vector_get(cell->children, i);
            pcell_unlink_cell_reference(pcell_state, child->identifier);
        }
        vector_destroy(cell->children, object_destroy);
    }
    cell->children = NULL;
}

int object_is_child_array(const struct object* cell)
{
    return cell->isarray;
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

const char* object_get_identifier(const struct object* cell)
{
    return cell->identifier;
}

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


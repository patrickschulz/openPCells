#include "object.h"

#include <stdlib.h>
#include <string.h>
#include <stdio.h>

#include "util.h"
#include "pcell.h"

#define min(a, b) ((a) < (b) ? (a) : (b))
#define max(a, b) ((a) > (b) ? (a) : (b))

static object_t* _create(void)
{
    object_t* obj = malloc(sizeof(*obj));
    memset(obj, 0, sizeof(*obj));
    return obj;
}

object_t* object_create(void)
{
    object_t* obj = _create();
    obj->trans = transformationmatrix_create();
    transformationmatrix_identity(obj->trans);
    obj->isproxy = 0;
    return obj;
}

object_t* object_create_proxy(const char* name, object_t* reference, const char* identifier)
{
    object_t* obj = _create();
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
    return obj;
}

object_t* object_copy(object_t* cell)
{
    object_t* new = _create();
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
        new->shapes_size = cell->shapes_size;
        new->shapes_capacity = cell->shapes_capacity;
        new->shapes = malloc(sizeof(*new->shapes) * new->shapes_capacity);
        for(unsigned int i = 0; i < new->shapes_size; ++i)
        {
            new->shapes[i] = shape_copy(cell->shapes[i]);
        }

        // alignmentbox
        if(cell->alignmentbox)
        {
            object_set_alignment_box(new, cell->alignmentbox[0], cell->alignmentbox[1], cell->alignmentbox[2], cell->alignmentbox[3]);
        }

        // anchors
        new->anchors_size = cell->anchors_size;
        new->anchors_capacity = cell->anchors_capacity;
        new->anchors = malloc(sizeof(*new->anchors) * new->anchors_capacity);
        for(unsigned int i = 0; i < cell->anchors_size; ++i)
        {
            new->anchors[i] = malloc(sizeof(*new->anchors[i]));
            new->anchors[i]->where = point_copy(cell->anchors[i]->where);
            new->anchors[i]->name = malloc(strlen(cell->anchors[i]->name) + 1);
            strcpy(new->anchors[i]->name, cell->anchors[i]->name);
        }

        // children
        new->children_size = cell->children_size;
        new->children_capacity = cell->children_capacity;
        new->children = malloc(sizeof(*new->children) * cell->children_capacity);
        for(unsigned int i = 0; i < cell->children_size; ++i)
        {
            new->children[i] = object_copy(cell->children[i]);
        }
    }
    return new;
}


void object_destroy(object_t* cell)
{
    if(cell->isproxy)
    {
        free(cell->identifier);
    }
    else
    {
        // shapes
        for(unsigned int i = 0; i < cell->shapes_size; ++i)
        {
            shape_destroy(cell->shapes[i]);
        }
        free(cell->shapes);

        // children
        for(unsigned int i = 0; i < cell->children_size; ++i)
        {
            object_destroy(cell->children[i]);
        }
        free(cell->children);

        // anchors
        for(unsigned int i = 0; i < cell->anchors_size; ++i)
        {
            point_destroy(cell->anchors[i]->where);
            free(cell->anchors[i]->name);
            free(cell->anchors[i]);
        }
        free(cell->anchors);

        // ports
        for(unsigned int i = 0; i < cell->ports_size; ++i)
        {
            point_destroy(cell->ports[i]->where);
            free(cell->ports[i]->name);
            free(cell->ports[i]);
        }
        free(cell->ports);
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

void object_add_raw_shape(object_t* cell, shape_t* S)
{
    if(cell->shapes_capacity == cell->shapes_size)
    {
        cell->shapes_capacity = cell->shapes_capacity == 0 ? 1 : cell->shapes_capacity * 2;
        shape_t** shapes = realloc(cell->shapes, sizeof(*shapes) * cell->shapes_capacity);
        cell->shapes = shapes;
    }
    cell->shapes[cell->shapes_size] = S;
    cell->shapes_size += 1;
}

void object_add_shape(object_t* cell, shape_t* S)
{
    object_add_raw_shape(cell, S);
    shape_apply_inverse_transformation(S, cell->trans);
}

void object_remove_shape(object_t* cell, size_t idx)
{
    for(size_t i = idx + 1; i < cell->shapes_size; ++i)
    {
        cell->shapes[i - 1] = cell->shapes[i];
    }
    --cell->shapes_size;
}

object_t* object_add_child(object_t* cell, const char* identifier, const char* name)
{
    object_t* reference = pcell_use_cell_reference(identifier);
    object_t* child = object_create_proxy(name, reference, identifier);
    child->isarray = 0;
    child->xrep = 1;
    child->yrep = 1;
    child->xpitch = 0;
    child->ypitch = 0;
    child->trans = transformationmatrix_invert(cell->trans);

    if(cell->children_capacity == cell->children_size)
    {
        cell->children_capacity = cell->children_capacity == 0 ? 1 : cell->children_capacity * 2;
        object_t** children = realloc(cell->children, sizeof(*children) * cell->children_capacity);
        cell->children = children;
    }
    cell->children[cell->children_size] = child;
    cell->children_size += 1;
    return child;
}

object_t* object_add_child_array(object_t* cell, const char* identifier, unsigned int xrep, unsigned int yrep, unsigned int xpitch, unsigned int ypitch, const char* name)
{
    //if not xpitch then -- alignmentbox mode
    //    local obj = pcell.get_cell_reference(identifier)
    //    local xpitch, ypitch = obj:width_height_alignmentbox()
    //    return cell:add_child_array(identifier, xrep, yrep, xpitch, ypitch, name)

    object_t* child = object_add_child(cell, identifier, name);
    child->isarray = 1;
    child->xrep = xrep;
    child->yrep = yrep;
    child->xpitch = xpitch;
    child->ypitch = ypitch;
    return child;
}

void object_merge_into_shallow(object_t* cell, object_t* other)
{
    for(unsigned int i = 0; i < other->shapes_size; ++i)
    {
        shape_t* shape = shape_copy(other->shapes[i]);
        object_add_shape(cell, shape);
        shape_apply_transformation(shape, other->trans);
    }
}

void object_add_anchor(object_t* cell, const char* name, coordinate_t x, coordinate_t y)
{
    if(cell->anchors_capacity == cell->anchors_size)
    {
        cell->anchors_capacity = cell->anchors_capacity == 0 ? 1 : cell->anchors_capacity * 2;
        struct anchor** anchors = realloc(cell->anchors, sizeof(*anchors) * cell->anchors_capacity);
        cell->anchors = anchors;
    }
    cell->anchors[cell->anchors_size] = malloc(sizeof(*cell->anchors[cell->anchors_size]));
    cell->anchors[cell->anchors_size]->where = point_create(x, y);
    cell->anchors[cell->anchors_size]->name = malloc(strlen(name) + 1);
    strcpy(cell->anchors[cell->anchors_size]->name, name);
    cell->anchors_size += 1;
}

static point_t* _get_special_anchor(const object_t* cell, const char* name, const transformationmatrix_t* trans1, const transformationmatrix_t* trans2)
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

static point_t* _get_regular_anchor(const object_t* cell, const char* name)
{
    const object_t* obj = cell;
    if(cell->isproxy)
    {
        obj = cell->reference;
    }
    point_t* pt = NULL;
    for(unsigned int i = 0; i < obj->anchors_size; ++i)
    {
        if(strcmp(obj->anchors[i]->name, name) == 0)
        {
            pt = point_copy(obj->anchors[i]->where);
            break;
        }
    }
    return pt;
}

point_t* object_get_anchor(const object_t* cell, const char* name)
{
    transformationmatrix_t* trans1 = cell->trans;
    transformationmatrix_t* trans2 = NULL;
    const object_t* obj = cell;
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

static void _add_port(object_t* cell, const char* name, const char* anchorname, generics_t* layer, coordinate_t x, coordinate_t y, int isbusport, int busindex)
{
    cell->ports_size += 1;
    struct port** ports = realloc(cell->ports, sizeof(*ports) * cell->ports_size);
    cell->ports = ports; // TODO: error checking
    cell->ports[cell->ports_size - 1] = malloc(sizeof(*cell->ports[cell->ports_size]));
    cell->ports[cell->ports_size - 1]->where = point_create(x, y);
    cell->ports[cell->ports_size - 1]->layer = layer;
    cell->ports[cell->ports_size - 1]->isbusport = isbusport;
    cell->ports[cell->ports_size - 1]->busindex = busindex;
    cell->ports[cell->ports_size - 1]->name = malloc(strlen(name) + 1);
    strcpy(cell->ports[cell->ports_size - 1]->name, name);
    object_add_anchor(cell, anchorname, x, y);
}

void object_add_port(object_t* cell, const char* name, generics_t* layer, point_t* where)
{
    _add_port(cell, name, name, layer, where->x, where->y, 0, 0);
}

void object_add_bus_port(object_t* cell, const char* name, generics_t* layer, point_t* where, int startindex, int endindex, unsigned int xpitch, unsigned int ypitch)
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
            _add_port(cell, name, anchorname, layer, where->x + shift * xpitch, where->y + shift * ypitch, 1, i);
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
            _add_port(cell, name, anchorname, layer, where->x + shift * xpitch, where->y + shift * ypitch, 1, i);
            free(anchorname);
            ++shift;
        }
    }
}

void object_set_alignment_box(object_t* cell, coordinate_t blx, coordinate_t bly, coordinate_t trx, coordinate_t try)
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

void object_inherit_alignment_box(object_t* cell, object_t* other)
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

void object_move_to(object_t* cell, coordinate_t x, coordinate_t y)
{
    transformationmatrix_move_to(cell->trans, x, y);
}

void object_translate(object_t* cell, coordinate_t x, coordinate_t y)
{
    transformationmatrix_translate(cell->trans, x, y);
}

void object_mirror_at_xaxis(object_t* cell)
{
    transformationmatrix_mirror_x(cell->trans);
}

void object_mirror_at_yaxis(object_t* cell)
{
    transformationmatrix_mirror_y(cell->trans);
}

void object_mirror_at_origin(object_t* cell)
{
    transformationmatrix_mirror_origin(cell->trans);
}

void object_rotate_90_left(object_t* cell)
{
    transformationmatrix_rotate_90_left(cell->trans);
}

void object_rotate_90_right(object_t* cell)
{
    transformationmatrix_rotate_90_right(cell->trans);
}

static void _get_move_anchor_translation(object_t* cell, const char* name, coordinate_t wx, coordinate_t wy, coordinate_t* dx, coordinate_t* dy)
{
    point_t* anchor = object_get_anchor(cell, name);
    if(anchor)
    {
        *dx = wx - anchor->x;
        *dy = wy - anchor->y;
    }
    point_destroy(anchor);
}

void object_move_anchor(object_t* cell, const char* name, coordinate_t x, coordinate_t y)
{
    coordinate_t dx, dy;
    _get_move_anchor_translation(cell, name, x, y, &dx, &dy);
    object_translate(cell, dx, dy);
}

void object_move_anchor_x(object_t* cell, const char* name, coordinate_t x, coordinate_t y)
{
    coordinate_t dx, dy;
    _get_move_anchor_translation(cell, name, x, y, &dx, &dy);
    object_translate(cell, dx, 0);
}

void object_move_anchor_y(object_t* cell, const char* name, coordinate_t x, coordinate_t y)
{
    coordinate_t dx, dy;
    _get_move_anchor_translation(cell, name, x, y, &dx, &dy);
    object_translate(cell, 0, dy);
}

static void _get_minmax_xy(object_t* cell, coordinate_t* minxp, coordinate_t* minyp, coordinate_t* maxxp, coordinate_t* maxyp)
{
    coordinate_t minx = COORDINATE_MAX;
    coordinate_t maxx = COORDINATE_MIN;
    coordinate_t miny = COORDINATE_MAX;
    coordinate_t maxy = COORDINATE_MIN;
    for(unsigned int i = 0; i < cell->shapes_size; ++i)
    {
        shape_t* S = cell->shapes[i];
        // FIXME: also include paths
        switch(S->type)
        {
            case RECTANGLE:
                minx = min(minx, S->points[0]->x);
                maxx = max(maxx, S->points[1]->x);
                miny = min(miny, S->points[0]->y);
                maxy = max(maxy, S->points[1]->y);
                break;
            case POLYGON:
                for(unsigned int i = 0; i < S->size; ++i)
                {
                    minx = min(minx, S->points[i]->x);
                    maxx = max(maxx, S->points[i]->x);
                    miny = min(miny, S->points[i]->y);
                    maxy = max(maxy, S->points[i]->y);
                }
                break;
        }
    }
    for(unsigned int i = 0; i < cell->children_size; ++i)
    {
        object_t* obj = cell->children[i]->reference;
        coordinate_t minx_, maxx_, miny_, maxy_;
        _get_minmax_xy(obj, &minx_, &miny_, &maxx_, &maxy_);
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
    *minxp = minx;
    *maxxp = maxx;
    *minyp = miny;
    *maxyp = maxy;
}

static void _get_transformation_correction(object_t* cell, coordinate_t* cx, coordinate_t* cy)
{
    object_t* obj = cell;
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
        _get_minmax_xy(obj, &blx, &bly, &trx, &try);
    }
    coordinate_t x = 0;
    coordinate_t y = 0;
    transformationmatrix_apply_transformation_xy(cell->trans, &x, &y);
    *cx = blx + trx + 2 * x;
    *cy = bly + try + 2 * y;
}

static void _flipx(object_t* cell, int ischild)
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
        for(unsigned int i = 0; i < cell->children_size; ++i)
        {
            _flipx(cell->children[i], 1);
        }
    }
}

void object_flipx(object_t* cell)
{
    _flipx(cell, 0);
}

static void _flipy(object_t* cell, int ischild)
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
        for(unsigned int i = 0; i < cell->children_size; ++i)
        {
            _flipy(cell->children[i], 1);
        }
    }
}

void object_flipy(object_t* cell)
{
    _flipy(cell, 0);
}

void object_apply_transformation(object_t* cell)
{
    for(unsigned int i = 0; i < cell->shapes_size; ++i)
    {
        shape_t* shape = cell->shapes[i];
        shape_apply_transformation(shape, cell->trans);
    }
}

int object_is_empty(object_t* cell)
{
    return (cell->shapes_size == 0) && (cell->children_size == 0) && (cell->ports_size == 0);
}

void object_flatten(object_t* cell, int flattenports)
{
    // add shapes and flatten children (recursive)
    for(unsigned int i = 0; i < cell->children_size; ++i)
    {
        object_t* child = cell->children[i];
        object_t* reference = child->reference; // FIXME: do we need to copy? If this cell is used somewhere else (partial flatten) than that will most likely cause headaches
        object_flatten(reference, flattenports);
        for(unsigned int ix = 1; ix <= child->xrep; ++ix)
        {
            for(unsigned int iy = 1; iy <= child->yrep; ++iy)
            {
                for(unsigned int i = 0; i < reference->shapes_size; ++i)
                {
                    shape_t* S = shape_copy(reference->shapes[i]);
                    shape_apply_transformation(S, child->trans);
                    shape_apply_transformation(S, reference->trans);
                    for(unsigned int i = 0; i < S->size; ++i)
                    {
                        S->points[i]->x += (ix - 1) * child->xpitch;
                        S->points[i]->y += (iy - 1) * child->ypitch;
                    }
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
    // destroy children
    for(unsigned int i = 0; i < cell->children_size; ++i)
    {
        pcell_unlink_cell_reference(cell->children[i]->identifier);
        object_destroy(cell->children[i]);
    }
    free(cell->children);
    cell->children = NULL;
    cell->children_size = 0;
}


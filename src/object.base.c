/*
 * implementation notice:
 * The object module is divided into several files.
 * At points, this is a bit awkward, due to the way visibility and
 * 'class' privacy works in C.
 * An 'object' can be either a full or a proxy object.
 * Full objects hold shapes, ports etc. and represent an actual layout cell.
 * Proxy objects on the other hand are lightweight handles that point to full objects.
 * They represent instantiations of layout cells in hierarchies.
 * This is implemented via a union.
 * On top of this, there is a common part that is shared between full and proxy objects.
 * Therefore, the 'object' struct holds a common part, the full/proxy union and a type tag.
 * The struct is defined 'object.def.h', which is only included by files that implement struct object.
 *
 * The files have the following responsibilities:
 * object.h:
 *   Declares the public interface that is used by other non-object modules.
 * object.public.c:
 *   Defines the interface functions from object.h.
 * object.def.h:
 *   *Defines* the object struct and access macros (for convenience and abstraction)
 * object.base.[c,h]:
 *   Contains function that manipulate objects (full and proxy). This is basically
 *   a wrapper for object.h/object.public.c, implementing all public functions with
 *   more visibility and access privileges.
 *   This module part only sorts out which functions to call, it acts as an organization layer.
 *   The actual functionality is built in object.full and object.proxy
 * object.common.[c,h]:
 *   Implements the 'common' functionality of objects.
 * object.full.[c,h]:
 *   Implements the functions that are called from object.base.c for full objects
 * object.proxy.[c,h]:
 *   Implements the functions that are called from object.base.c for proxy objects
 * object.util.[c,h]:
 *   Utility functions that are used in the object module, but are not directly related to objects
 * object.ports.[c,h] and objects.anchors.[c,h]:
 *   Implementation of anchor and port structs, as they are separate structs used only within objects.
 *
 * Notes about transformation:
 * Layout cells can hold millions of shapes, hence the typical way of dealing with efficient transformation
 * is to only transform a matrix and apply the matrix when really needed.
 * This means that every object has a transformation matrix (both full and proxy objects),
 * so it is in the 'common' part. This means that the 'full' and 'proxy' implementations have no
 * visibility of these matrices, but need them to process (basically) everything.
 * For this, the 'base' module passes the proper matrix to the functions from the lower modules.
 */
#include "object.h"

#define OPC_OBJECT_IMPLEMENTATION
#include "object.anchors.h"
#include "object.base.h"
#include "object.common.h"
#include "object.def.h"
#include "object.full.h"
#include "object.ports.h"
#include "object.proxy.h"
#include "object.util.h"
#undef OPC_OBJECT_IMPLEMENTATION

#include <stdlib.h>
#include <string.h>
#include <stdio.h>

#include "assert.h"
#include "bltrshape.h"
#include "helpers.h"
#include "util.h"

// helper functions for chained matrices
static void _get_trans12(const struct object* cell, const struct transformationmatrix** trans1, const struct transformationmatrix** trans2)
{
    *trans1 = objectbase_get_tmatrix(cell);
    if(objectbase_is_proxy(cell))
    {
        *trans2 = objectbase_get_tmatrix(REFERENCE(cell));
    }
    else
    {
        *trans2 = NULL;
    }
}

static struct transformationmatrix* _make_trans12(const struct object* cell)
{
    struct transformationmatrix* trans = transformationmatrix_create();
    transformationmatrix_chain_inline(trans, objectbase_get_tmatrix(cell));
    if(objectbase_is_proxy(cell))
    {
        transformationmatrix_chain_inline(trans, objectbase_get_tmatrix(REFERENCE(cell)));
    }
    return trans;
}

static struct object* _create(const char* name)
{
    struct object* obj = malloc(sizeof(*obj));
    if(!obj)
    {
        return NULL;
    }
    memset(obj, 0, sizeof(*obj));
    objectcommon_initialize(COMMON(obj));
    objectcommon_set_name(COMMON(obj), name);
    objectcommon_set_used(COMMON(obj), 1);
    return obj;
}

struct object* objectbase_create(const char* name)
{
    struct object* obj = _create(name);
    objectcommon_set_proxy(COMMON(obj), 0);
    objectfull_set_managed(FULL(obj), 0);
    return obj;
}

struct object* objectbase_create_pseudo(void)
{
    struct object* obj = _create(NULL);
    objectcommon_set_proxy(COMMON(obj), 0);
    objectfull_set_managed(FULL(obj), 0);
    return obj;
}

struct object* objectbase_create_proxy(const char* name, struct object* reference)
{
    CHECK_FULL(reference);
    struct object* obj = _create(name);
    objectcommon_set_proxy(COMMON(obj), 1);
    objectproxy_initialize(PROXY(obj), reference);
    return obj;
}

struct object* objectbase_copy(const struct object* cell)
{
    struct object* new = _create(NULL); // name is copied in objectcommon_copy_to
    if(!new)
    {
        return NULL;
    }
    objectcommon_copy_to(COMMON(cell), COMMON(new));

    if(objectbase_is_proxy(cell))
    {
        objectproxy_copy_to(PROXY(cell), PROXY(new));
    }
    else
    {
        objectfull_copy_to(FULL(cell), FULL(new));
    }
    return new;
}

void objectbase_destroy(void* cellv)
{
    struct object* cell = cellv;
    if(objectbase_is_proxy(cell))
    {
        objectproxy_destroy(PROXY(cell));
    }
    else
    {
        objectfull_destroy(FULL(cell));
    }
    objectcommon_destroy(COMMON(cell));
    free(cell);
}

void objectbase_set_name(struct object* cell, const char* name)
{
    objectcommon_set_name(COMMON(cell), name);
}

void objectbase_add_raw_shape(struct object* cell, struct shape* S)
{
    objectfull_add_shape(FULL(cell), S);
}

void objectbase_add_shape(struct object* cell, struct shape* S)
{
    objectfull_add_shape(FULL(cell), S);
    shape_apply_inverse_transformation(S, objectbase_get_tmatrix(cell));
}

void objectbase_remove_shape(struct object* cell, size_t idx)
{
    objectfull_remove_shape(FULL(cell), idx);
}

struct shape* objectbase_disown_shape(struct object* cell, size_t idx)
{
    return objectfull_disown_shape(FULL(cell), idx);
}

void objectbase_set_managed(struct object* reference)
{
    objectfull_set_managed(FULL(reference), 1);
}

void objectbase_set_unused(struct object* reference)
{
    objectcommon_set_used(COMMON(reference), 0);
}

void objectbase_set_used(struct object* reference)
{
    objectcommon_set_used(COMMON(reference), 1);
}

void objectbase_add_reference(struct object* cell, struct object* reference)
{
    if(objectfull_add_reference(FULL(cell), reference))
    {
        objectbase_set_managed(reference);
    }
}

void objectbase_add_proxy(struct object* cell, struct object* proxy)
{
    objectfull_add_proxy(FULL(cell), proxy);
}

const struct object* objectbase_get_reference(const struct object* cell)
{
    CHECK_PROXY(cell);
    return objectproxy_get_reference(PROXY(cell));
}

struct object* objectbase_get_reference_mutable(struct object* cell)
{
    CHECK_PROXY(cell);
    return objectproxy_get_reference_mutable(PROXY(cell));
}

const struct transformationmatrix* objectbase_get_tmatrix(const struct object* cell)
{
    return objectcommon_get_tmatrix(COMMON(cell));
}

const struct transformationmatrix* objectbase_get_array_tmatrix(const struct object* cell)
{
    CHECK_PROXY(cell);
    return objectproxy_get_array_tmatrix(PROXY(cell));
}

struct transformationmatrix* objectbase_get_inverted_tmatrix(
    const struct object* cell
)
{
    return transformationmatrix_invert(objectbase_get_tmatrix(cell));
}

void objectbase_set_tmatrix(struct object* cell, struct transformationmatrix* trans)
{
    objectcommon_set_tmatrix(COMMON(cell), trans);
}

void objectbase_set_array(struct object* cell, unsigned int xrep, unsigned int yrep, coordinate_t xpitch, coordinate_t ypitch)
{
    CHECK_PROXY(cell);
    objectproxy_set_array(PROXY(cell), xrep, yrep, xpitch, ypitch);
}

static struct transformationmatrix* _get_effective_tmatrix(const struct object* target, const struct object* source)
{
    return transformationmatrix_chain_inv1(
        objectbase_get_tmatrix(target),
        objectbase_get_tmatrix(source)
    );
}

void objectbase_merge_into(struct object* cell, const struct object* other, int merge_ports)
{
    CHECK_FULL(cell);
    CHECK_FULL(other);
    struct transformationmatrix* M = _get_effective_tmatrix(cell, other);
    objectfull_merge_into(FULL(cell), FULL(other), M, merge_ports);
    transformationmatrix_destroy(M);
}

static int _add_anchor(struct object* cell, const char* name, struct anchor* anchor)
{
    struct transformationmatrix* M = objectbase_get_inverted_tmatrix(cell);
    int ret = objectfull_add_anchor(FULL(cell), M, name, anchor);
    transformationmatrix_destroy(M);
    if(!ret)
    {
        objectanchor_destroy(anchor);
        return 0;
    }
    return 1;
}

int objectbase_add_anchor(struct object* cell, const char* name, coordinate_t x, coordinate_t y)
{
    CHECK_FULL(cell);
    struct anchor* anchor = objectanchor_create_regular(x, y);
    if(!anchor)
    {
        return 0;
    }
    return _add_anchor(cell, name, anchor);
}

int objectbase_add_area_anchor_bltr(
    struct object* cell,
    const char* name,
    coordinate_t blx, coordinate_t bly,
    coordinate_t trx, coordinate_t try
)
{
    CHECK_FULL(cell);
    struct anchor* anchor = objectanchor_create_area_bltr(blx, bly, trx, try);
    if(!anchor)
    {
        return 0;
    }
    return _add_anchor(cell, name, anchor);
}

void objectbase_inherit_all_anchors_with_prefix(struct object* cell, const struct object* other, const char* prefix)
{
    CHECK_FULL(cell);
    CHECK_FULL_OR_PROXY(other);
    struct transformationmatrix* sourcetrans = _make_trans12(other);
    if(objectbase_is_proxy(other))
    {
        objectfull_inherit_all_anchors_with_prefix(
            FULL(cell),
            FULLREFERENCE(other),
            objectcommon_get_inverse_tmatrix(COMMON(cell)),
            sourcetrans,
            prefix
        );
    }
    else
    {
        objectfull_inherit_all_anchors_with_prefix(
            FULL(cell),
            FULL(other),
            objectcommon_get_inverse_tmatrix(COMMON(cell)),
            sourcetrans,
            prefix
        );
    }
    transformationmatrix_destroy(sourcetrans);
}

int objectbase_add_anchor_line_x(struct object* cell, const char* name, coordinate_t c)
{
    CHECK_FULL(cell);
    const struct transformationmatrix* trans = objectbase_get_tmatrix(cell);
    objectfull_add_anchor_line_xy(
        FULL(cell),
        trans,
        name,
        c,
        0
    );
    return 1;
}

int objectbase_add_anchor_line_y(struct object* cell, const char* name, coordinate_t c)
{
    CHECK_FULL(cell);
    const struct transformationmatrix* trans = objectbase_get_tmatrix(cell);
    objectfull_add_anchor_line_xy(
        FULL(cell),
        trans,
        name,
        c,
        1
    );
    return 1;
}

void objectbase_transform_to_local_coordinates_xy(const struct object* cell, coordinate_t* x, coordinate_t* y)
{
    objectcommon_transform_to_local_coordinates_xy(COMMON(cell), x, y);
    if(objectbase_is_proxy(cell))
    {
        objectcommon_transform_to_local_coordinates_xy(COMMON(REFERENCE(cell)), x, y);
    }
}

void objectbase_transform_to_local_coordinates(const struct object* cell, struct point* pt)
{
    objectbase_transform_to_local_coordinates_xy(cell, &pt->x, &pt->y);
}

void objectbase_transform_to_local_coordinates_shape(const struct object* cell, struct shape* shape)
{
    objectcommon_transform_to_local_coordinates_shape(COMMON(cell), shape);
    if(objectbase_is_proxy(cell))
    {
        objectcommon_transform_to_local_coordinates_shape(COMMON(REFERENCE(cell)), shape);
    }
}

void objectbase_transform_to_global_coordinates_xy(const struct object* cell, coordinate_t* x, coordinate_t* y)
{
    objectcommon_transform_to_global_coordinates_xy(COMMON(cell), x, y);
    if(objectbase_is_proxy(cell))
    {
        objectcommon_transform_to_global_coordinates_xy(COMMON(REFERENCE(cell)), x, y);
    }
}

void objectbase_transform_to_global_coordinates(const struct object* cell, struct point* pt)
{
    objectbase_transform_to_global_coordinates_xy(cell, &pt->x, &pt->y);
}

void objectbase_transform_to_global_coordinates_shape(const struct object* cell, struct shape* shape)
{
    objectcommon_transform_to_global_coordinates_shape(COMMON(cell), shape);
    if(objectbase_is_proxy(cell))
    {
        objectcommon_transform_to_global_coordinates_shape(COMMON(REFERENCE(cell)), shape);
    }
}

static int _transform_array_point_to_local_coordinates(void* v, struct generic_arg* args)
{
    struct point* pt = v;
    const struct object* cell = args_get_const_pointer(args, 1);
    objectbase_transform_to_local_coordinates(cell, pt);
    return 1;
}

void objectbase_transform_to_local_coordinates_pts(const struct object* cell, struct vector* pts)
{
    struct generic_arg args[] = {
        { .type = ARG_CONST_POINTER, .content.cptr = cell },
        { .type = ARG_END }
    };
    vector_foreach(pts, _transform_array_point_to_local_coordinates, args);
}

static int _transform_array_point_to_global_coordinates(void* v, struct generic_arg* args)
{
    struct point* pt = v;
    const struct object* cell = args_get_const_pointer(args, 1);
    objectbase_transform_to_global_coordinates(cell, pt);
    return 1;
}

void objectbase_transform_to_global_coordinates_vector(const struct object* cell, struct vector* pts)
{
    struct generic_arg args[] = {
        { .type = ARG_CONST_POINTER, .content.cptr = cell },
        { .type = ARG_END }
    };
    vector_foreach(pts, _transform_array_point_to_global_coordinates, args);
}

void objectbase_transform_to_global_coordinates_polygon_container(const struct object* cell, struct polygon_container* polygon)
{
    struct generic_arg args[] = {
        { .type = ARG_CONST_POINTER, .content.cptr = cell },
        { .type = ARG_END }
    };
    polygon_container_foreach_points(polygon, _transform_array_point_to_global_coordinates, args);
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
coordinate_t* objectbase_get_untransformed_alignment_box(const struct object* cell)
{
    CHECK_FULL_OR_PROXY(cell);
    coordinate_t* alignmentbox;
    if(objectbase_is_proxy(cell))
    {
        alignmentbox = objectfull_get_alignment_box(FULLREFERENCE(cell));
    }
    else
    {
        alignmentbox = objectfull_get_alignment_box(FULL(cell));
    }
    return alignmentbox; // can be NULL
}

coordinate_t* objectbase_get_transformed_alignment_box(const struct object* cell)
{
    CHECK_FULL_OR_PROXY(cell);
    coordinate_t* alignmentbox = objectbase_get_untransformed_alignment_box(cell);
    if(!alignmentbox)
    {
        return NULL;
    }
    const struct transformationmatrix* trans1;
    const struct transformationmatrix* trans2;
    _get_trans12(cell, &trans1, &trans2);
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
    if(objectbase_is_array(cell))
    {
        objectproxy_translate_x_to_array_end(PROXY(cell), &objectbase_alignmentbox_get_innertrx(alignmentbox));
        objectproxy_translate_y_to_array_end(PROXY(cell), &objectbase_alignmentbox_get_innertry(alignmentbox));
        objectproxy_translate_x_to_array_end(PROXY(cell), &objectbase_alignmentbox_get_outertrx(alignmentbox));
        objectproxy_translate_y_to_array_end(PROXY(cell), &objectbase_alignmentbox_get_outertry(alignmentbox));
    }
    return alignmentbox;
}

coordinate_t* objectbase_get_untransformed_minmax_xy(const struct object* cell)
{
    coordinate_t* minmax;
    CHECK_FULL_OR_PROXY(cell);
    if(objectbase_is_proxy(cell))
    {
        minmax = objectfull_get_minmax_xy(FULLREFERENCE(cell), NULL);
    }
    else
    {
        minmax = objectfull_get_minmax_xy(FULL(cell), NULL);
    }
    return minmax;
}

coordinate_t* objectbase_get_minmax_xy(const struct object* cell)
{
    coordinate_t* minmax = objectbase_get_untransformed_minmax_xy(cell);
    objectbase_transform_to_global_coordinates_xy(cell,
        &objectbase_boundingbox_get_blx(minmax),
        &objectbase_boundingbox_get_bly(minmax)
    );
    objectbase_transform_to_global_coordinates_xy(cell,
        &objectbase_boundingbox_get_trx(minmax),
        &objectbase_boundingbox_get_try(minmax)
    );
    objectutil_fix_rectangle_order_xy(
        &objectbase_boundingbox_get_blx(minmax),
        &objectbase_boundingbox_get_bly(minmax),
        &objectbase_boundingbox_get_trx(minmax),
        &objectbase_boundingbox_get_try(minmax)
    );
    return minmax;
}

static int _get_minmax_xy_layer_shape(const struct shape* shape, struct generic_arg* extraargs)
{
    const struct generics* layer = args_get_const_pointer(extraargs, 1);
    if(!layer || shape_is_layer(shape, layer))
    {
        coordinate_t minx_;
        coordinate_t maxx_;
        coordinate_t miny_;
        coordinate_t maxy_;
        shape_get_minmax_xy(shape, &minx_, &miny_, &maxx_, &maxy_);
        coordinate_t* minx = args_get_pointer(extraargs, 2);
        coordinate_t* maxx = args_get_pointer(extraargs, 3);
        coordinate_t* miny = args_get_pointer(extraargs, 4);
        coordinate_t* maxy = args_get_pointer(extraargs, 5);
        *minx = MIN2(*minx, minx_);
        *maxx = MAX2(*maxx, maxx_);
        *miny = MIN2(*miny, miny_);
        *maxy = MAX2(*maxy, maxy_);
    }
    return 1;
}

static int _get_minmax_xy_layer_child(const struct object* child, struct generic_arg* extraargs)
{
    const struct generics* layer = args_get_pointer(extraargs, 1);
    coordinate_t* minx = args_get_pointer(extraargs, 2);
    coordinate_t* maxx = args_get_pointer(extraargs, 3);
    coordinate_t* miny = args_get_pointer(extraargs, 4);
    coordinate_t* maxy = args_get_pointer(extraargs, 5);
    const struct object* obj = REFERENCE(child);
    coordinate_t minx_, maxx_, miny_, maxy_;
    objectbase_get_minmax_xy_layer(obj, &minx_, &miny_, &maxx_, &maxy_, layer);
    // FIXME: transformation? -> should be handled by recursive call, but check this! (construct a cell with the right transformations)
    *minx = MIN2(*minx, minx_);
    *maxx = MAX2(*maxx, maxx_);
    *miny = MIN2(*miny, miny_);
    *maxy = MAX2(*maxy, maxy_);
    return 1;
}

void objectbase_get_minmax_xy_layer(const struct object* cell, coordinate_t* minxp, coordinate_t* minyp, coordinate_t* maxxp, coordinate_t* maxyp, const struct generics* layer)
{
    // FIXME: arrays?
    CHECK_FULL_OR_PROXY(cell);
    const struct object_full* full;
    if(objectbase_is_proxy(cell))
    {
        full = FULLREFERENCE(cell);
    }
    else
    {
        full = FULL(cell);
    }
    coordinate_t minx = COORDINATE_MAX;
    coordinate_t maxx = COORDINATE_MIN;
    coordinate_t miny = COORDINATE_MAX;
    coordinate_t maxy = COORDINATE_MIN;
    // generic argument table for foreach shapes/children
    struct generic_arg args[] = {
        { .type = ARG_CONST_POINTER, .content.cptr = layer, },
        { .type = ARG_POINTER, .content.ptr = &minx, },
        { .type = ARG_POINTER, .content.ptr = &maxx, },
        { .type = ARG_POINTER, .content.ptr = &miny, },
        { .type = ARG_POINTER, .content.ptr = &maxy, },
        { .type = ARG_END }
    };
    // shapes
    objectfull_foreach_shapes_const(full, _get_minmax_xy_layer_shape, args);
    // children
    objectfull_foreach_children_const(full, _get_minmax_xy_layer_child, args);
    // coordinates are untransformed up to here, for efficiency
    // this automatically handles extra transformations for children
    objectbase_transform_to_global_coordinates_xy(cell, &minx, &miny);
    objectbase_transform_to_global_coordinates_xy(cell, &maxx, &maxy);
    objectutil_fix_rectangle_order_xy(&minx, &miny, &maxx, &maxy);
    // return result
    *minxp = minx;
    *maxxp = maxx;
    *minyp = miny;
    *maxyp = maxy;
}

coordinate_t* objectbase_get_transformed_bounding_box(const struct object* cell)
{
    return objectbase_get_minmax_xy(cell);
}

static const struct anchor* _get_anchor(const struct object* cell, const char* name)
{
    struct anchor* anchor = NULL;
    if(objectbase_is_proxy(cell))
    {
        anchor = objectfull_get_anchor(FULLREFERENCE(cell), name);
    }
    else
    {
        anchor = objectfull_get_anchor(FULL(cell), name);
    }
    if(!anchor)
    {
        return NULL;
    }
    return anchor;
}

int objectbase_has_anchor(const struct object* cell, const char* anchorname)
{
    const struct anchor* anchor = _get_anchor(cell, anchorname);
    if(anchor)
    {
        return !objectanchor_is_area(anchor);
    }
    return 0;
}

int objectbase_has_area_anchor(const struct object* cell, const char* anchorname)
{
    const struct anchor* anchor = _get_anchor(cell, anchorname);
    if(anchor)
    {
        return objectanchor_is_area(anchor);
    }
    return 0;
}


struct point* objectbase_get_anchor(const struct object* cell, const char* name)
{
    const struct anchor* anchor = _get_anchor(cell, name);
    if(!anchor)
    {
        return NULL;
    }
    if(objectanchor_is_area(anchor))
    {
        return NULL;
    }
    struct point* pt = point_create(0, 0);
    objectanchor_get_point(anchor, pt);
    objectbase_transform_to_global_coordinates(cell, pt);
    return pt;
}

struct point* objectbase_get_area_anchor(const struct object* cell, const char* name)
{
    const struct anchor* anchor = _get_anchor(cell, name);
    if(!anchor)
    {
        return NULL;
    }
    if(!objectanchor_is_area(anchor))
    {
        return NULL;
    }
    struct point* pts = malloc(2 * sizeof(*pts));
    objectanchor_get_area_points(anchor, pts);
    objectbase_transform_to_global_coordinates(cell, pts + 0);
    objectbase_transform_to_global_coordinates(cell, pts + 1);
    objectutil_fix_rectangle_order(pts + 0, pts + 1);
    return pts;
}

coordinate_t* objectbase_get_anchor_line(const struct object* cell, const char* name)
{
    if(objectbase_is_proxy(cell))
    {
        return objectfull_get_anchor_line(FULLREFERENCE(cell), name);
    }
    else
    {
        return objectfull_get_anchor_line(FULL(cell), name);
    }
}

struct point* objectbase_get_array_anchor(const struct object* cell, int xindex, int yindex, const char* name)
{
    CHECK_PROXY(cell);
    if(!objectbase_is_array(cell))
    {
        return NULL;
    }
    if(!objectproxy_check_array_bounds(PROXY(cell), xindex, yindex))
    {
        return NULL;
    }
    struct point* pt = objectbase_get_anchor(cell, name);
    if(pt)
    {
        objectproxy_translate_pt_to_array(PROXY(cell), pt, xindex, yindex);
    }
    return pt;
}

struct point* objectbase_get_array_area_anchor(const struct object* cell, int xindex, int yindex, const char* base)
{
    CHECK_PROXY(cell);
    if(!objectbase_is_array(cell))
    {
        return NULL;
    }
    if(!objectproxy_check_array_bounds(PROXY(cell), xindex, yindex))
    {
        return NULL;
    }
    struct point* pts = objectbase_get_area_anchor(cell, base);
    if(pts)
    {
        objectproxy_translate_pt_to_array(PROXY(cell), pts + 0, xindex, yindex);
        objectproxy_translate_pt_to_array(PROXY(cell), pts + 1, xindex, yindex);
    }
    return pts;
}

const struct hashmap* objectbase_get_all_regular_anchors(const struct object* cell)
{
    const struct object_full* obj;
    if(objectbase_is_proxy(cell))
    {
        obj = FULLREFERENCE(cell);
    }
    else
    {
        obj = FULL(cell);
    }
    const struct hashmap* cellanchors = objectfull_get_anchors(obj);
    struct hashmap* anchors = NULL;
    if(cellanchors)
    {
        anchors = hashmap_create(point_destroy);
        struct hashmap_const_iterator* it = hashmap_const_iterator_create(cellanchors);
        while(hashmap_const_iterator_is_valid(it))
        {
            const char* key = hashmap_const_iterator_key(it);
            const struct anchor* anchor = hashmap_const_iterator_value(it);
            if(objectanchor_is_area(anchor))
            {
                size_t len = strlen(key);
                char* name = malloc(len + 2 + 1);
                strcpy(name, key);
                struct point pts[2];
                objectanchor_get_area_points(anchor, pts);
                struct point* bl = pts + 0;
                struct point* tr = pts + 1;
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
                struct point pt;
                objectanchor_get_point(anchor, &pt);
                hashmap_insert(anchors, key, &pt);
            }
            hashmap_const_iterator_next(it);
        }
        hashmap_const_iterator_destroy(it);
        // transformation
        struct hashmap_iterator* ait = hashmap_iterator_create(anchors);
        while(hashmap_iterator_is_valid(ait))
        {
            struct point* pt = hashmap_iterator_value(ait);
            objectbase_transform_to_global_coordinates(cell, pt);
            hashmap_iterator_next(ait);
        }
        hashmap_iterator_destroy(ait);
    }
    return anchors;
}

void objectbase_set_boundary(struct object* cell, struct vector* boundary)
{
    CHECK_FULL(cell);
    struct vector* new = objectfull_set_boundary(FULL(cell), boundary);
    objectbase_transform_to_local_coordinates_pts(cell, new);
}

struct vector* objectbase_get_boundary(const struct object* cell)
{
    CHECK_FULL_OR_PROXY(cell);
    struct vector* boundary = NULL;
    if(objectbase_is_proxy(cell))
    {
        boundary = objectfull_get_boundary(FULLREFERENCE(cell));
    }
    else
    {
        boundary = objectfull_get_boundary(FULL(cell));
    }
    if(boundary)
    {
        objectbase_transform_to_global_coordinates_vector(cell, boundary);
    }
    return boundary;
}

void objectbase_inherit_boundary(struct object* cell, const struct object* othercell)
{
    CHECK_FULL(cell);
    CHECK_FULL_OR_PROXY(othercell);
    struct vector* boundary = objectbase_get_boundary(othercell);
    objectbase_set_boundary(cell, boundary);
}

struct point** objectbase_get_bounding_box(const struct object* cell)
{
    CHECK_FULL_OR_PROXY(cell);
    coordinate_t* bb = objectbase_get_minmax_xy(cell);
    struct point** boundary = malloc(2 * sizeof(*boundary));
    boundary[0] = point_create(
        objectbase_boundingbox_get_blx(bb),
        objectbase_boundingbox_get_bly(bb)
    );
    boundary[1] = point_create(
        objectbase_boundingbox_get_trx(bb),
        objectbase_boundingbox_get_try(bb)
    );
    free(bb);
    return boundary;
}

int objectbase_has_boundary(const struct object* cell)
{
    if(objectbase_is_proxy(cell))
    {
        return objectfull_has_boundary(FULLREFERENCE(cell));
    }
    else
    {
        return objectfull_has_boundary(FULL(cell));
    }
}

void objectbase_set_empty_layer_boundary(struct object* cell, const struct generics* layer)
{
    CHECK_FULL(cell);
    objectfull_set_empty_layer_boundary(FULL(cell), layer);
}

void objectbase_add_layer_boundary(struct object* cell, const struct generics* layer, struct simple_polygon* new)
{
    CHECK_FULL(cell);
    objectfull_add_layer_boundary(FULL(cell), layer, new);
    // transform points to local coordinates
    // NOTE: the object takes ownership of the 'new' polygon
    // This works because this function is called from lua, where a new polygon is assembled from a table.
    // If this ever changes, handle this the same way as cell boundaries: return a pointer to the new polygon, transform here
    struct simple_polygon_iterator* it = simple_polygon_iterator_create(new);
    while(simple_polygon_iterator_is_valid(it))
    {
        struct point* pt = simple_polygon_iterator_get(it);
        objectbase_transform_to_local_coordinates(cell, pt);
        simple_polygon_iterator_next(it);
    }
    simple_polygon_iterator_destroy(it);
}

void objectbase_inherit_layer_boundary(struct object* cell, const struct object* othercell, const struct generics* layer)
{
    struct polygon_container* boundary = object_get_layer_boundary(othercell, layer);
    struct polygon_container_iterator* it = polygon_container_iterator_create(boundary);
    while(polygon_container_iterator_is_valid(it))
    {
        const struct simple_polygon* sp = polygon_container_iterator_get(it);
        struct simple_polygon* new = simple_polygon_copy(sp);
        object_add_layer_boundary(cell, layer, new);
        polygon_container_iterator_next(it);
    }
    polygon_container_iterator_destroy(it);
    polygon_container_destroy(boundary);
}

int objectbase_has_layer_boundary(const struct object* cell, const struct generics* layer)
{
    if(objectbase_is_proxy(cell))
    {
        return objectfull_has_layer_boundary(FULLREFERENCE(cell), layer);
    }
    else
    {
        return objectfull_has_layer_boundary(FULL(cell), layer);
    }
}

struct polygon_container* objectbase_get_layer_boundary(const struct object* cell, const struct generics* layer)
{
    CHECK_FULL_OR_PROXY(cell);
    struct polygon_container* boundary = NULL;
    if(objectbase_is_proxy(cell))
    {
        boundary = objectfull_get_layer_boundary(FULLREFERENCE(cell), layer);
    }
    else
    {
        boundary = objectfull_get_layer_boundary(FULL(cell), layer);
    }
    if(boundary)
    {
        objectbase_transform_to_global_coordinates_polygon_container(cell, boundary);
    }
    return boundary;
}

struct bltrshape* objectbase_get_layer_occupation(const struct object* cell, const struct generics** layers, size_t numlayers)
{
    coordinate_t blx0 = COORDINATE_MAX;
    coordinate_t bly0 = COORDINATE_MAX;
    coordinate_t trx0 = COORDINATE_MIN;
    coordinate_t try0 = COORDINATE_MIN;
    if(layers)
    {
        for(size_t i = 0; i < numlayers; ++i)
        {
            const struct generics* layer = layers[i];
            coordinate_t blx, bly, trx, try;
            objectbase_get_minmax_xy_layer(cell, &blx, &bly, &trx, &try, layer);
            blx0 = MIN2(blx0, blx);
            bly0 = MIN2(bly0, bly);
            trx0 = MAX2(trx0, trx);
            try0 = MAX2(try0, try);
        }
        return bltrshape_create_xy_no_net(blx0, bly0, trx0, try0);
    }
    else
    {
        coordinate_t blx, bly, trx, try;
        objectbase_get_minmax_xy_layer(cell, &blx, &bly, &trx, &try, NULL);
        return bltrshape_create_xy_no_net(blx, bly, trx, try);
    }
}

void objectbase_add_port(struct object* cell, const char* name, const struct generics* layer, const struct point* where, unsigned int sizehint)
{
    CHECK_FULL(cell);
    if(!generics_is_empty(layer))
    {
        struct port* port = objectport_create(name, layer, where->x, where->y, 0, 0, sizehint);
        objectbase_transform_to_local_coordinates(cell, objectport_get_point(port));
        objectfull_add_port(FULL(cell), port);
    }
}

void objectbase_add_bus_port(struct object* cell, const char* name, const struct generics* layer, const struct point* where, int startindex, int endindex, coordinate_t xpitch, coordinate_t ypitch, unsigned int sizehint)
{
    CHECK_FULL(cell);
    int shift = 0;
    if(startindex < endindex)
    {
        SWAP(startindex, endindex, int);
    }
    for(int i = startindex; i <= endindex; ++i)
    {
        struct port* port = objectport_create(name, layer, where->x + shift * xpitch, where->y + shift * ypitch, 1, i, sizehint);
        objectbase_transform_to_global_coordinates(cell, objectport_get_point(port));
        objectfull_add_port(FULL(cell), port);
        ++shift;
    }
}

void objectbase_add_label(struct object* cell, const char* name, const struct generics* layer, const struct point* where, unsigned int sizehint)
{
    CHECK_FULL(cell);
    if(!generics_is_empty(layer))
    {
        struct port* label = objectport_create(name, layer, where->x, where->y, 0, 0, sizehint);
        objectbase_transform_to_global_coordinates(cell, objectport_get_point(label));
        objectfull_add_label(FULL(cell), label);
    }
}

size_t objectbase_get_labels_size(const struct object* cell)
{
    CHECK_FULL(cell);
    return objectfull_get_labels_size(FULL(cell));
}

struct port* objectbase_get_label(struct object* cell, size_t idx)
{
    CHECK_FULL(cell);
    return objectfull_get_label(FULL(cell), idx);
}

const struct generics* objectbase_get_label_layer(const struct object* cell, size_t idx)
{
    CHECK_FULL(cell);
    return objectfull_get_label_layer(FULL(cell), idx);
}

void objectbase_remove_label(struct object* cell, size_t idx)
{
    CHECK_FULL(cell);
    objectfull_remove_label(FULL(cell), idx);
}

const struct vector* objectbase_get_labels(
    const struct object* cell
)
{
    CHECK_FULL(cell);
    return objectfull_get_labels(FULL(cell));
}

void objectbase_add_net_shape(struct object* cell, const char* netname, const struct point* bl, const struct point* tr, const struct generics* layer)
{
    struct bltrshape* netarea = objectfull_add_net_shape(FULL(cell), netname, bl, tr, layer);
    objectbase_transform_to_local_coordinates(cell, bltrshape_get_bl(netarea));
    objectbase_transform_to_local_coordinates(cell, bltrshape_get_tr(netarea));
}

const struct hashmap* objectbase_get_all_net_shapes(
    const struct object* cell
)
{
    CHECK_FULL(cell);
    return objectfull_get_all_net_shapes(FULL(cell));
}

struct vector* objectbase_get_net_shapes(const struct object* cell, const char* netname, const struct generics* layer)
{
    CHECK_FULL_OR_PROXY(cell);
    struct vector* nets;
    if(objectbase_is_proxy(cell))
    {
        nets = objectfull_get_net_shapes(FULLREFERENCE(cell), netname, layer);
    }
    else
    {
        nets = objectfull_get_net_shapes(FULL(cell), netname, layer);
    }
    if(!nets)
    {
        return NULL;
    }
    if(objectbase_is_array(cell))
    {
        size_t netsize = vector_size(nets); // store size here, as the vector is modified
        for(unsigned int i = 0; i < netsize; ++i)
        {
            const struct bltrshape* s = vector_get_const(nets, i);
            // start x/y indices at 1, as the first object is already represented in nets
            for(unsigned int xindex = 1; xindex < objectproxy_get_xrep(PROXY(cell)); ++xindex)
            {
                for(unsigned int yindex = 1; yindex < objectproxy_get_yrep(PROXY(cell)); ++yindex)
                {
                    struct bltrshape* bltrshape = bltrshape_copy(s);
                    objectbase_transform_to_global_coordinates(cell, bltrshape_get_bl(bltrshape));
                    objectbase_transform_to_global_coordinates(cell, bltrshape_get_tr(bltrshape));
                    objectproxy_translate_pt_to_array(PROXY(cell), bltrshape_get_bl(bltrshape), xindex, yindex);
                    objectproxy_translate_pt_to_array(PROXY(cell), bltrshape_get_tr(bltrshape), xindex, yindex);
                    vector_append(nets, bltrshape);
                }
            }
        }
    }
    else
    {
        for(unsigned int i = 0; i < vector_size(nets); ++i)
        {
            struct bltrshape* bltrshape = vector_get(nets, i);
            objectbase_transform_to_global_coordinates(cell, bltrshape_get_bl(bltrshape));
            objectbase_transform_to_global_coordinates(cell, bltrshape_get_tr(bltrshape));
        }
    }
    return nets;
}

struct vector* objectbase_get_array_net_shapes(const struct object* cell, int xindex, int yindex, const char* netname, const struct generics* layer)
{
    CHECK_PROXY(cell);
    if(!objectbase_is_array(cell))
    {
        return NULL;
    }
    struct vector* nets = objectfull_get_net_shapes(FULLREFERENCE(cell), netname, layer);
    if(!nets)
    {
        return NULL;
    }
    else
    {
        for(unsigned int i = 0; i < vector_size(nets); ++i)
        {
            struct bltrshape* bltrshape = vector_get(nets, i);
            objectbase_transform_to_global_coordinates(cell, bltrshape_get_bl(bltrshape));
            objectbase_transform_to_global_coordinates(cell, bltrshape_get_tr(bltrshape));
            objectproxy_translate_pt_to_array(PROXY(cell), bltrshape_get_bl(bltrshape), xindex, yindex);
            objectproxy_translate_pt_to_array(PROXY(cell), bltrshape_get_tr(bltrshape), xindex, yindex);
        }
    }
    return nets;
}

void objectbase_inherit_net_shapes(struct object* cell, const struct object* other, const struct generics* layer)
{
    CHECK_FULL(cell); // FIXME: why can't this be a proxy?
    CHECK_FULL_OR_PROXY(other);
    const struct object_full* obj;
    if(objectbase_is_proxy(cell))
    {
        obj = FULLREFERENCE(other);
    }
    else
    {
        obj = FULL(other);
    }
    struct transformationmatrix* sourcetrans = _make_trans12(other);
    objectfull_inherit_net_shapes(
        FULL(cell),
        obj,
        objectbase_get_tmatrix(cell),
        sourcetrans,
        layer
    );
    transformationmatrix_destroy(sourcetrans);
}

int objectbase_has_net(
    const struct object* cell,
    const char* netname
)
{
    const struct object_full* full;
    if(objectbase_is_proxy(cell))
    {
        full = FULLREFERENCE(cell);
    }
    else
    {
        full = FULL(cell);
    }
    return objectfull_has_net(full, netname);
}

void objectbase_clear_alignment_box(struct object* cell)
{
    CHECK_FULL(cell);
    objectfull_clear_alignment_box(FULL(cell));
}

void objectbase_set_alignment_box(
    struct object* cell,
    coordinate_t outerblx, coordinate_t outerbly,
    coordinate_t outertrx, coordinate_t outertry,
    coordinate_t innerblx, coordinate_t innerbly,
    coordinate_t innertrx, coordinate_t innertry
)
{
    CHECK_FULL(cell);
    objectbase_transform_to_local_coordinates_xy(cell, &outerblx, &outerbly);
    objectbase_transform_to_local_coordinates_xy(cell, &outertrx, &outertry);
    objectbase_transform_to_local_coordinates_xy(cell, &innerblx, &innerbly);
    objectbase_transform_to_local_coordinates_xy(cell, &innertrx, &innertry);
    objectutil_fix_rectangle_order_xy(&outerblx, &outerbly, &outertrx, &outertry);
    objectutil_fix_rectangle_order_xy(&innerblx, &innerbly, &innertrx, &innertry);
    objectfull_set_alignment_box(
        FULL(cell),
        outerblx, outerbly, outertrx, outertry,
        innerblx, innerbly, innertrx, innertry
    );
}

void objectbase_inherit_alignment_box(struct object* cell, const struct object* other)
{
    // usage of the public interface takes care of all transformation
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
    objectbase_transform_to_local_coordinates_xy(cell, &outerblx, &outerbly);
    objectbase_transform_to_local_coordinates_xy(cell, &outertrx, &outertry);
    objectbase_transform_to_local_coordinates_xy(cell, &innerblx, &innerbly);
    objectbase_transform_to_local_coordinates_xy(cell, &innertrx, &innertry);
    objectutil_fix_rectangle_order_xy(&outerblx, &outerbly, &outertrx, &outertry);
    objectutil_fix_rectangle_order_xy(&innerblx, &innerbly, &innertrx, &innertry);
    objectfull_extend_alignment_box(
        FULL(cell),
        outerblx, outerbly, outertrx, outertry,
        innerblx, innerbly, innertrx, innertry
    );
    point_destroy(outerbl);
    point_destroy(outertr);
    point_destroy(innerbl);
    point_destroy(innertr);
}

static void _alignment_box_include_xy(struct object* cell, coordinate_t x, coordinate_t y, int include_x, int include_y)
{
    CHECK_FULL(cell);
    objectbase_transform_to_global_coordinates_xy(cell, &x, &y);
    struct point* outerbl = object_get_alignmentbox_anchor_outerbl(cell);
    struct point* outertr = object_get_alignmentbox_anchor_outertr(cell);
    struct point* innerbl = object_get_alignmentbox_anchor_innerbl(cell);
    struct point* innertr = object_get_alignmentbox_anchor_innertr(cell);
    coordinate_t souterblx = outerbl->x;
    coordinate_t souterbly = outerbl->y;
    coordinate_t soutertrx = outertr->x;
    coordinate_t soutertry = outertr->y;
    coordinate_t sinnerblx = innerbl->x;
    coordinate_t sinnerbly = innerbl->y;
    coordinate_t sinnertrx = innertr->x;
    coordinate_t sinnertry = innertr->y;
    coordinate_t outerblx, outertrx, innerblx, innertrx;
    coordinate_t outerbly, outertry, innerbly, innertry;
    if(include_x)
    {
        outerblx = MIN2(x, souterblx);
        outertrx = MAX2(x, soutertrx);
        innerblx = MIN2(x, sinnerblx);
        innertrx = MAX2(x, sinnertrx);
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
        outerbly = MIN2(y, souterbly);
        outertry = MAX2(y, soutertry);
        innerbly = MIN2(y, sinnerbly);
        innertry = MAX2(y, sinnertry);
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

void objectbase_alignment_box_include_point(struct object* cell, const struct point* pt)
{
    CHECK_FULL(cell);
    if(objectbase_is_proxy(cell))
    {
        return;
    }
    if(objectfull_has_alignment_box(FULL(cell)))
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

void objectbase_alignment_box_include_x(struct object* cell, coordinate_t x)
{
    CHECK_FULL(cell);
    if(objectbase_is_proxy(cell))
    {
        return;
    }
    if(objectfull_has_alignment_box(FULL(cell)))
    {
        _alignment_box_include_xy(cell, x, 0, 1, 0); // include only x
    }
    else
    {
        puts("using object.alignment_box_include_point on an object without an alignment box. While this could be a sensible operation, it is currently not implemented.");
        // FIXME
    }
}

void objectbase_alignment_box_include_y(struct object* cell, coordinate_t y)
{
    CHECK_FULL(cell);
    if(objectbase_is_proxy(cell))
    {
        return;
    }
    if(objectfull_has_alignment_box(FULL(cell)))
    {
        _alignment_box_include_xy(cell, 0, y, 0, 1); // include only y
    }
    else
    {
        puts("using object.alignment_box_include_point on an object without an alignment box. While this could be a sensible operation, it is currently not implemented.");
        // FIXME
    }
}

int objectbase_extend_alignment_box(struct object* cell,
    coordinate_t extouterblx, coordinate_t extouterbly,
    coordinate_t extoutertrx, coordinate_t extoutertry,
    coordinate_t extinnerblx, coordinate_t extinnerbly,
    coordinate_t extinnertrx, coordinate_t extinnertry)
{
    CHECK_FULL(cell);
    struct point* outerbl = object_get_alignmentbox_anchor_outerbl(cell);
    struct point* outertr = object_get_alignmentbox_anchor_outertr(cell);
    struct point* innerbl = object_get_alignmentbox_anchor_innerbl(cell);
    struct point* innertr = object_get_alignmentbox_anchor_innertr(cell);
    coordinate_t outerblx = outerbl->x + extouterblx;
    coordinate_t outerbly = outerbl->y + extouterbly;
    coordinate_t outertrx = outertr->x + extoutertrx;
    coordinate_t outertry = outertr->y + extoutertry;
    coordinate_t innerblx = innerbl->x + extinnerblx;
    coordinate_t innerbly = innerbl->y + extinnerbly;
    coordinate_t innertrx = innertr->x + extinnertrx;
    coordinate_t innertry = innertr->y + extinnertry;
    object_set_alignment_box(cell, outerblx, outerbly, outertrx, outertry, innerblx, innerbly, innertrx, innertry);
    return 1;
}

int objectbase_get_alignment_box_corners(
    const struct object* cell,
    coordinate_t* outerblx, coordinate_t* outerbly, coordinate_t* outertrx, coordinate_t* outertry,
    coordinate_t* innerblx, coordinate_t* innerbly, coordinate_t* innertrx, coordinate_t* innertry
)
{
    struct point* outerbl = object_get_alignmentbox_anchor_outerbl(cell);
    struct point* outertr = object_get_alignmentbox_anchor_outertr(cell);
    struct point* innerbl = object_get_alignmentbox_anchor_innerbl(cell);
    struct point* innertr = object_get_alignmentbox_anchor_innertr(cell);
    *outerblx = point_getx(outerbl);
    *outerbly = point_gety(outerbl);
    *outertrx = point_getx(outertr);
    *outertry = point_gety(outertr);
    *innerblx = point_getx(innerbl);
    *innerbly = point_gety(innerbl);
    *innertrx = point_getx(innertr);
    *innertry = point_gety(innertr);
    return 1;
}

void objectbase_move_to(struct object* cell, coordinate_t x, coordinate_t y)
{
    objectcommon_move_to(COMMON(cell), x, y);
}

void objectbase_translate(struct object* cell, coordinate_t x, coordinate_t y)
{
    objectcommon_translate(COMMON(cell), x, y);
}

void objectbase_reset_translation(struct object* cell)
{
    objectbase_move_to(cell, 0, 0);
}

void objectbase_mirror_at_xaxis(struct object* cell)
{
    objectcommon_mirror_at_xaxis(COMMON(cell));
}

void objectbase_mirror_at_yaxis(struct object* cell)
{
    objectcommon_mirror_at_yaxis(COMMON(cell));
}

void objectbase_mirror_at_origin(struct object* cell)
{
    objectcommon_mirror_at_origin(COMMON(cell));
}

void objectbase_rotate_90_left(struct object* cell)
{
    objectcommon_rotate_90_left(COMMON(cell));
}

void objectbase_rotate_90_right(struct object* cell)
{
    objectcommon_rotate_90_right(COMMON(cell));
}

void objectbase_array_rotate_90_left(struct object* cell)
{
    CHECK_PROXY(cell);
    objectproxy_array_rotate_90_left(PROXY(cell));
}

void objectbase_array_rotate_90_right(struct object* cell)
{
    CHECK_PROXY(cell);
    objectproxy_array_rotate_90_right(PROXY(cell));
}

int objectbase_move_x(struct object* cell, coordinate_t source, coordinate_t target)
{
    objectbase_translate(cell, target - source, 0);
    return 1;
}

int objectbase_move_y(struct object* cell, coordinate_t source, coordinate_t target)
{
    objectbase_translate(cell, 0, target - source);
    return 1;
}

int objectbase_move_point(struct object* cell, const struct point* source, const struct point* target)
{
    objectbase_translate(cell, target->x - source->x, target->y - source->y);
    return 1;
}

int objectbase_move_point_to_origin(struct object* cell, const struct point* target)
{
    objectbase_translate(cell, target->x, target->y);
    return 1;
}

int objectbase_move_point_to_origin_xy(struct object* cell, coordinate_t x, coordinate_t y)
{
    objectbase_translate(cell, x, y);
    return 1;
}

int objectbase_move_point_x(struct object* cell, const struct point* source, const struct point* target)
{
    objectbase_translate(cell, target->x - source->x, 0);
    return 1;
}

int objectbase_move_point_y(struct object* cell, const struct point* source, const struct point* target)
{
    objectbase_translate(cell, 0, target->y - source->y);
    return 1;
}

int objectbase_center(struct object* cell, const struct point* target)
{
    struct point* outerbl = object_get_alignmentbox_anchor_outerbl(cell);
    struct point* outertr = object_get_alignmentbox_anchor_outertr(cell);
    coordinate_t sourcex = 0.5 * (point_getx(outertr) + point_getx(outerbl));
    coordinate_t sourcey = 0.5 * (point_gety(outertr) + point_gety(outerbl));
    coordinate_t targetcx = 0;
    coordinate_t targetcy = 0;
    if(target)
    {
        targetcx = point_getx(target);
        targetcy = point_gety(target);
    }
    objectbase_translate(cell, targetcx - sourcex, targetcy - sourcey);
    return 1;
}

int objectbase_center_x(struct object* cell, const struct point* target)
{
    struct point* outerbl = object_get_alignmentbox_anchor_outerbl(cell);
    struct point* outertr = object_get_alignmentbox_anchor_outertr(cell);
    coordinate_t source = 0.5 * (point_getx(outertr) + point_getx(outerbl));
    coordinate_t targetc = 0;
    if(target)
    {
        targetc = point_getx(target);
    }
    objectbase_translate(cell, targetc - source, 0);
    return 1;
}

int objectbase_center_y(struct object* cell, const struct point* target)
{
    struct point* outerbl = object_get_alignmentbox_anchor_outerbl(cell);
    struct point* outertr = object_get_alignmentbox_anchor_outertr(cell);
    coordinate_t source = 0.5 * (point_gety(outertr) + point_gety(outerbl));
    coordinate_t targetc = 0;
    if(target)
    {
        targetc = point_gety(target);
    }
    objectbase_translate(cell, 0, targetc - source);
    return 1;
}

void objectbase_scale(struct object* cell, double factor)
{
    CHECK_FULL_OR_PROXY(cell);
    objectcommon_scale(COMMON(cell), factor);
}

void objectbase_foreach_shapes(struct object* cell, shape_action action, struct generic_arg* extraargs)
{
    CHECK_FULL(cell);
    objectfull_foreach_shapes(FULL(cell), action, extraargs);
}

size_t objectbase_get_shapes_size(const struct object* cell)
{
    CHECK_FULL(cell);
    return objectfull_get_shapes_size(FULL(cell));
}

struct shape* objectbase_get_shape(struct object* cell, size_t idx)
{
    CHECK_FULL(cell);
    return objectfull_get_shape(FULL(cell), idx);
}

const struct shape* objectbase_get_shape_const(const struct object* cell, size_t idx)
{
    CHECK_FULL(cell);
    return objectfull_get_shape_const(FULL(cell), idx);
}

struct shape* objectbase_get_transformed_shape(const struct object* cell, size_t idx)
{
    const struct shape* shape = objectbase_get_shape_const(cell, idx);
    struct shape* new = shape_copy(shape);
    objectbase_transform_to_global_coordinates_shape(cell, new);
    return new;
}

static int _rasterize_curves(struct shape* shape, struct generic_arg* extraargs)
{
    (void)extraargs;
    if(shape_is_curve(shape))
    {
        shape_rasterize_curve_inline(shape);
    }
    return 1;
}

void objectbase_rasterize_curves(struct object* cell)
{
    objectbase_foreach_shapes(cell, _rasterize_curves, NULL);
}

// FIXME: maxlevel does nothing
static void _get_all_shapes_helper(const struct object* cell, const struct generics** layers, size_t numlayers, size_t maxlevel, struct vector* shapes)
{
    for(size_t i = 0; i < objectbase_get_shapes_size(cell); ++i)
    {
        const struct shape* testshape = objectbase_get_shape_const(cell, i);
        for(size_t j = 0; j < numlayers; ++j)
        {
            const struct generics* layer = layers[j];
            if(shape_is_layer(testshape, layer))
            {
                struct shape* shape = objectbase_get_transformed_shape(cell, i);
                vector_append(shapes, shape);
                break;
            }
        }
    }
    struct child_iterator* it = object_create_child_iterator(cell);
    while(child_iterator_is_valid(it))
    {
        const struct object* child = child_iterator_get(it);
        struct vector* subshapes = vector_create(64, shape_destroy);
        _get_all_shapes_helper(REFERENCE(child), layers, numlayers, maxlevel, subshapes);
        // apply child transformation and add to parent 'shapes' vector
        for(int i = vector_size(subshapes) - 1; i >= 0; --i)
        {
            struct shape* shape = vector_disown_element(subshapes, i);
            shape_apply_transformation(shape, objectbase_get_tmatrix(child));
            if(object_is_array(child))
            {
                coordinate_t xpitch = object_get_child_xpitch(child);
                coordinate_t ypitch = object_get_child_ypitch(child);
                for(unsigned int x = 1; x <= object_get_child_xrep(child); ++x)
                {
                    for(unsigned int y = 1; y <= object_get_child_yrep(child); ++y)
                    {
                        struct shape* copy = shape_copy(shape);
                        shape_translate(copy, (x - 1) * xpitch, (y - 1) * ypitch);
                        vector_append(shapes, copy);
                    }
                }
            }
            else
            {
                vector_append(shapes, shape);
            }
        }
        child_iterator_next(it);
    }
    child_iterator_destroy(it);
}

static struct vector* _get_all_shapes(const struct object* cell, const struct generics** layers, size_t numlayers, size_t maxlevel)
{
    struct vector* shapes = vector_create(64, shape_destroy);
    _get_all_shapes_helper(cell, layers, numlayers, maxlevel, shapes);
    return shapes;
}

struct polygon_container* objectbase_get_shape_outlines(const struct object* cell, const struct generics** layers, size_t numlayers)
{
    struct polygon_container* container = polygon_container_create();
    struct vector* shapes = _get_all_shapes(cell, layers, numlayers, 0);
    for(size_t i = 0; i < vector_size(shapes); ++i)
    {
        struct shape* shape = vector_get(shapes, i);
        struct simple_polygon* polygon = shape_to_polygon(shape);
        polygon_container_add(container, polygon);
    }
    vector_destroy(shapes);
    return container;
}

const struct transformationmatrix* objectbase_get_array_transformation_matrix(const struct object* cell)
{
    if(!objectbase_is_array(cell))
    {
        return NULL;
    }
    return objectproxy_get_array_tmatrix(PROXY(cell));
}

static void _get_transformation_correction(const struct object* cell, coordinate_t* cx, coordinate_t* cy)
{
    coordinate_t* ab = objectbase_get_untransformed_alignment_box(cell);
    coordinate_t blx, bly, trx, try;
    if(ab)
    {
        // FIXME: fix for alignmentbox with eight coordinates
        blx = ab[0];
        bly = ab[1];
        trx = ab[2];
        try = ab[3];
        free(ab);
    }
    else
    {
        coordinate_t* minmaxxy = objectbase_get_untransformed_minmax_xy(cell);
        blx = minmaxxy[0];
        bly = minmaxxy[1];
        trx = minmaxxy[2];
        try = minmaxxy[3];
        free(minmaxxy);
    }
    coordinate_t x = 0;
    coordinate_t y = 0;
    // only apply first-level transformation
    // FIXME: why? It was like this and that worked, but check
    objectcommon_transform_to_global_coordinates_xy(COMMON(cell), &x, &y);
    *cx = blx + trx + 2 * x;
    *cy = bly + try + 2 * y;
}

static int _flipx(struct object* cell, struct generic_arg* args)
{
    int ischild = args_get_int(args, 1);
    coordinate_t cx, cy;
    _get_transformation_correction(cell, &cx, &cy);
    objectbase_mirror_at_yaxis(cell);
    if(!ischild)
    {
        objectbase_translate(cell, cx, 0);
    }
    if(!objectbase_is_proxy(cell))
    {
        struct generic_arg childargs[] = {
            { .type = ARG_INT, .content.i = 1 },
            { .type = ARG_END }
        };
        objectfull_foreach_children(FULL(cell), _flipx, childargs);
    }
    return 1;
}

void objectbase_flipx(struct object* cell)
{
    struct generic_arg args[] = {
        { .type = ARG_INT, .content.i = 0 },
        { .type = ARG_END }
    };
    _flipx(cell, args);
}

static int _flipy(struct object* cell, struct generic_arg* args)
{
    int ischild = args_get_int(args, 1);
    coordinate_t cx, cy;
    _get_transformation_correction(cell, &cx, &cy);
    objectbase_mirror_at_xaxis(cell);
    if(!ischild)
    {
        objectbase_translate(cell, 0, cy);
    }
    if(!objectbase_is_proxy(cell))
    {
        struct generic_arg childargs[] = {
            { .type = ARG_INT, .content.i = 1 },
            { .type = ARG_END }
        };
        objectfull_foreach_children(FULL(cell), _flipy, childargs);
    }
    return 1;
}

void objectbase_flipy(struct object* cell)
{
    struct generic_arg args[] = {
        { .type = ARG_INT, .content.i = 0 },
        { .type = ARG_END }
    };
    _flipy(cell, args);
}

void objectbase_transform_point(const struct object* cell, struct point* pt)
{
    objectcommon_transform_to_global_coordinates_xy(COMMON(cell), &pt->x, &pt->y);
}

int objectbase_is_pseudo(const struct object* cell)
{
    return objectcommon_is_pseudo(COMMON(cell));
}

int objectbase_is_proxy(const struct object* cell)
{
    return objectcommon_is_proxy(COMMON(cell));
}

int objectbase_has_shapes(const struct object* cell)
{
    CHECK_FULL_OR_PROXY(cell);
    if(objectbase_is_proxy(cell))
    {
        return 0;
    }
    else
    {
        return objectfull_get_shapes_size(FULL(cell)) > 0;
    }
}

int objectbase_has_layer_flat(const struct object* cell, const struct generics* layer)
{
    CHECK_FULL_OR_PROXY(cell);
    if(objectbase_is_proxy(cell))
    {
        return objectfull_has_layer_flat(FULLREFERENCE(cell), layer);
    }
    else
    {
        return objectfull_has_layer_flat(FULL(cell), layer);
    }
}

int objectbase_has_layer(const struct object* cell, const struct generics* layer)
{
    CHECK_FULL_OR_PROXY(cell);
    if(objectbase_is_proxy(cell))
    {
        return objectfull_has_layer(FULLREFERENCE(cell), layer);
    }
    else
    {
        return objectfull_has_layer(FULL(cell), layer);
    }
}

int objectbase_has_children(const struct object* cell)
{
    CHECK_FULL(cell);
    return objectfull_has_children(FULL(cell));
}

int objectbase_has_ports(const struct object* cell)
{
    CHECK_FULL(cell);
    return objectfull_has_ports(FULL(cell));
}

size_t objectbase_get_ports_size(const struct object* cell)
{
    CHECK_FULL(cell);
    return objectfull_get_ports_size(FULL(cell));
}

struct port* objectbase_get_port(struct object* cell, size_t idx)
{
    CHECK_FULL(cell);
    return objectfull_get_port(FULL(cell), idx);
}

const struct generics* objectbase_get_port_layer(const struct object* cell, size_t idx)
{
    CHECK_FULL(cell);
    return objectfull_get_port_layer(FULL(cell), idx);
}

void objectbase_remove_port(struct object* cell, size_t idx)
{
    CHECK_FULL(cell);
    objectfull_remove_port(FULL(cell), idx);
}

const struct vector* objectbase_get_ports(
    const struct object* cell
)
{
    CHECK_FULL(cell);
    return objectfull_get_ports(FULL(cell));
}

int objectbase_is_empty(const struct object* cell)
{
    CHECK_FULL(cell);
    return !objectbase_has_shapes(cell) && !objectbase_has_children(cell) && !objectbase_has_ports(cell);
}

int objectbase_is_used(const struct object* cell)
{
    return objectcommon_is_used(COMMON(cell));
}

int objectbase_is_array(const struct object* cell)
{
    return objectcommon_is_proxy(COMMON(cell)) && objectproxy_is_array(PROXY(cell));
}

int objectbase_has_alignmentbox(const struct object* cell)
{
    if(objectbase_is_proxy(cell))
    {
        return objectfull_has_alignment_box(FULLREFERENCE(cell));
    }
    else
    {
        return objectfull_has_alignment_box(FULL(cell));
    }
}

const char* objectbase_get_name(const struct object* cell)
{
    return objectcommon_get_name(COMMON(cell));
}

const char* objectbase_get_child_reference_name(const struct object* child)
{
    return objectbase_get_name(REFERENCE(child));
}

void objectbase_flatten_inline(struct object* cell, int flattenports)
{
    CHECK_FULL(cell);
    objectfull_flatten_inline(FULL(cell), flattenports);
}

struct object* objectbase_flatten(const struct object* cell, int flattenports)
{
    struct object* new = objectbase_copy(cell);
    objectbase_flatten_inline(new, flattenports);
    return new;
}

unsigned int objectbase_get_child_xrep(const struct object* cell)
{
    CHECK_PROXY(cell);
    return objectproxy_get_xrep(PROXY(cell));
}

unsigned int objectbase_get_child_yrep(const struct object* cell)
{
    CHECK_PROXY(cell);
    return objectproxy_get_yrep(PROXY(cell));
}

coordinate_t objectbase_get_child_xpitch(const struct object* cell)
{
    CHECK_PROXY(cell);
    return objectproxy_get_xpitch(PROXY(cell));
}

coordinate_t objectbase_get_child_ypitch(const struct object* cell)
{
    CHECK_PROXY(cell);
    return objectproxy_get_ypitch(PROXY(cell));
}

static int _const_reference_collector(const struct object* cell, struct generic_arg* extraargs)
{
    struct const_vector* references = args_get_pointer(extraargs, 1);
    const_vector_append(references, REFERENCE(cell));
    return 1; // for foreach
}

struct const_vector* objectbase_collect_references(const struct object* cell)
{
    CHECK_FULL(cell);
    struct const_vector* references = const_vector_create(8);
    struct generic_arg args[] = {
        { .type = ARG_POINTER, .content.ptr = references },
        { .type = ARG_END }
    };
    objectfull_foreach_children_const(FULL(cell), _const_reference_collector, args);
    return references;
}

static int _reference_collector(struct object* cell, struct generic_arg* extraargs)
{
    struct vector* references = args_get_pointer(extraargs, 1);
    vector_append(references, REFERENCE_MUTABLE(cell));
    return 1; // for foreach
}

struct vector* objectbase_collect_references_mutable(struct object* cell)
{
    CHECK_FULL(cell);
    struct vector* references = vector_create(8, NULL); // non-owning vector
    struct generic_arg args[] = {
        { .type = ARG_POINTER, .content.ptr = references },
        { .type = ARG_END }
    };
    objectfull_foreach_children(FULL(cell), _reference_collector, args);
    return references;
}

const struct vector* objectbase_get_full_shapes_const(
    const struct object* cell
)
{
    CHECK_FULL(cell);
    return objectfull_get_shapes_const(FULL(cell));
}

const struct vector* objectbase_get_full_children_const(
    const struct object* cell
)
{
    CHECK_FULL(cell);
    return objectfull_get_children_const(FULL(cell));
}

const struct vector* objectbase_get_full_references_const(
    const struct object* cell
)
{
    CHECK_FULL(cell);
    return objectfull_get_references_const(FULL(cell));
}

struct vector* objectbase_get_full_references(
    struct object* cell
)
{
    CHECK_FULL(cell);
    return objectfull_get_references(FULL(cell));
}

int objectbase_foreach_anchor(const struct object* cell, anchor_action action, struct generic_arg* extraargs)
{
    CHECK_FULL(cell);
    objectfull_foreach_anchor(FULL(cell), objectbase_get_tmatrix(cell), action, extraargs);
    return 1;
}

int objectbase_foreach_port(const struct object* cell, port_action action, struct generic_arg* extraargs)
{
    objectfull_foreach_port(FULL(cell), objectbase_get_tmatrix(cell), action, extraargs);
    return 1;
}

int objectbase_foreach_label(const struct object* cell, label_action action, struct generic_arg* extraargs)
{
    objectfull_foreach_label(FULL(cell), objectbase_get_tmatrix(cell), action, extraargs);
    return 1;
}

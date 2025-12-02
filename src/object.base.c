#include "object.h"

#define OPC_OBJECT_IMPLEMENTATION
#include "object.anchors.h"
#include "object.base.h"
#include "object.common.h"
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

struct object {
    struct object_common common;
    union {
        struct object_proxy proxy; // proxy objects (light handles to children)
        struct object_full full; // full objects
    } content;
};

#define COMMON(obj) &obj->common
#define PROXY(obj) &obj->content.proxy
#define FULL(obj) &obj->content.full
#define REFERENCE(obj) objectproxy_get_reference(&obj->content.proxy)
#define FULLREFERENCE(obj) FULL(REFERENCE(obj))

#define CHECK_FULL(obj)\
    OPC_ASSERT_MSG2(\
        objectcommon_is_full(COMMON(obj)),\
        __func__,\
        ": object given must be a full object"\
    )
#define CHECK_PROXY(obj)\
    OPC_ASSERT_MSG2(\
        objectcommon_is_proxy(COMMON(obj)),\
        __func__,\
        ": object given must be a proxy object"\
    )
#define CHECK_FULL_OR_PROXY(obj)\
    OPC_ASSERT_MSG2(\
        objectcommon_is_full(COMMON(obj)) || objectcommon_is_proxy(COMMON(obj)),\
        __func__,\
        ": object given must be a full object"\
    )

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
    objectcommon_set_managed(COMMON(obj), 0);
    objectcommon_set_used(COMMON(obj), 1);
    return obj;
}

struct object* object_create(const char* name)
{
    struct object* obj = _create(name);
    objectcommon_set_proxy(COMMON(obj), 0);
    return obj;
}

struct object* object_create_pseudo(void)
{
    struct object* obj = _create(NULL);
    objectcommon_set_proxy(COMMON(obj), 0);
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

struct object* object_copy(const struct object* cell)
{
    struct object* new = _create(NULL); // name is copied in objectcommon_copy_to
    if(!new)
    {
        return NULL;
    }
    objectcommon_copy_to(COMMON(cell), COMMON(new));

    if(objectcommon_is_proxy(COMMON(cell)))
    {
        objectproxy_copy_to(PROXY(cell), PROXY(new));
    }
    else
    {
        objectfull_copy_to(FULL(cell), FULL(new));
    }
    return new;
}

void object_destroy(void* cellv)
{
    struct object* cell = cellv;
    if(objectcommon_is_proxy(COMMON(cell)))
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

void object_set_name(struct object* cell, const char* name)
{
    objectcommon_set_name(COMMON(cell), name);
}

void objectbase_add_raw_shape(struct object* cell, struct shape* S)
{
    objectfull_add_shape(FULL(cell), S);
}

void objectbase_set_managed(struct object* reference)
{
    objectcommon_set_managed(COMMON(reference), 1);
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

const struct transformationmatrix* objectbase_get_tmatrix(const struct object* cell)
{
    return objectcommon_get_tmatrix(COMMON(cell));
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

void object_merge_into(struct object* cell, const struct object* other)
{
    CHECK_FULL(cell);
    CHECK_FULL(other);
    objectfull_merge_into(FULL(cell), FULL(other), 0);
}

void object_merge_into_with_ports(struct object* cell, const struct object* other)
{
    CHECK_FULL(cell);
    CHECK_FULL(other);
    objectfull_merge_into(FULL(cell), FULL(other), 1);
}

int objectbase_add_anchor(struct object* cell, const char* name, struct anchor* anchor)
{
    CHECK_FULL(cell);
    objectfull_add_anchor(FULL(cell), name, anchor);
    return 1;
}

void object_inherit_all_anchors_with_prefix(struct object* cell, const struct object* other, const char* prefix)
{
    CHECK_FULL_OR_PROXY(other);
    if(object_is_proxy(other))
    {
        objectfull_inherit_all_anchors_with_prefix(FULL(cell), FULLREFERENCE(other), prefix);
    }
    else
    {
        objectfull_inherit_all_anchors_with_prefix(FULL(cell), FULL(other), prefix);
    }
}

int object_add_anchor_line_x(struct object* cell, const char* name, coordinate_t c)
{
    CHECK_FULL(cell);
    objectfull_add_anchor_line_xy(FULL(cell), name, c, 0);
    return 1;
}

int object_add_anchor_line_y(struct object* cell, const char* name, coordinate_t c)
{
    CHECK_FULL(cell);
    objectfull_add_anchor_line_xy(FULL(cell), name, c, 1);
    return 1;
}

void objectbase_transform_to_local_coordinates_xy(const struct object* cell, coordinate_t* x, coordinate_t* y)
{
    objectcommon_transform_to_local_coordinates_xy(COMMON(cell), x, y);
    if(object_is_proxy(cell))
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
    if(object_is_proxy(cell))
    {
        objectcommon_transform_to_local_coordinates_shape(COMMON(REFERENCE(cell)), shape);
    }
}

void objectbase_transform_to_global_coordinates_xy(const struct object* cell, coordinate_t* x, coordinate_t* y)
{
    objectcommon_transform_to_global_coordinates_xy(COMMON(cell), x, y);
    if(object_is_proxy(cell))
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
    if(object_is_proxy(cell))
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

static void _get_trans12(const struct object* cell, const struct transformationmatrix** trans1, const struct transformationmatrix** trans2)
{
    *trans1 = objectcommon_get_tmatrix(COMMON(cell));
    if(object_is_proxy(cell))
    {
        *trans2 = objectcommon_get_tmatrix(COMMON(REFERENCE(cell)));
    }
    else
    {
        *trans2 = NULL;
    }
}

coordinate_t* objectbase_get_untransformed_alignment_box(const struct object* cell)
{
    CHECK_FULL_OR_PROXY(cell);
    coordinate_t* alignmentbox;
    if(object_is_proxy(cell))
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
    coordinate_t* alignmentbox = objectbase_get_untransformed_bounding_box(cell);
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
    if(object_is_child_array(cell))
    {
        objectproxy_translate_x_to_array_end(PROXY(cell), &objectbase_alignmentbox_get_innertrx(alignmentbox));
        objectproxy_translate_y_to_array_end(PROXY(cell), &objectbase_alignmentbox_get_innertry(alignmentbox));
        objectproxy_translate_x_to_array_end(PROXY(cell), &objectbase_alignmentbox_get_outertrx(alignmentbox));
        objectproxy_translate_y_to_array_end(PROXY(cell), &objectbase_alignmentbox_get_outertry(alignmentbox));
    }
    return alignmentbox;
}

coordinate_t* objectbase_get_minmax_xy(const struct object* cell)
{
    coordinate_t* minmax;
    CHECK_FULL_OR_PROXY(cell);
    if(object_is_proxy(cell))
    {
        minmax = objectfull_get_minmax_xy(FULLREFERENCE(cell));
    }
    else
    {
        minmax = objectfull_get_minmax_xy(FULL(cell));
    }
    return minmax;
}

coordinate_t* objectbase_get_transformed_bounding_box(const struct object* cell)
{
    const struct transformationmatrix* trans1;
    const struct transformationmatrix* trans2;
    _get_trans12(cell, &trans1, &trans2);
    coordinate_t* boundingbox = objectbase_get_minmax_xy(cell);
    objectbase_transform_to_global_coordinates_xy(cell, boundingbox + 0, boundingbox + 1);
    objectbase_transform_to_global_coordinates_xy(cell, boundingbox + 2, boundingbox + 3);
    objectutil_fix_rectangle_order_xy(boundingbox + 0, boundingbox + 1, boundingbox + 2, boundingbox + 3);
    return boundingbox;
}

struct anchor* objectbase_get_anchor(const struct object* cell, const char* name)
{
    if(object_is_proxy(cell))
    {
        return objectfull_get_anchor(FULLREFERENCE(cell), name);
    }
    else
    {
        return objectfull_get_anchor(FULL(cell), name);
    }
}

coordinate_t* objectbase_get_anchor_line(const struct object* cell, const char* name)
{
    if(object_is_proxy(cell))
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
    if(!object_is_child_array(cell))
    {
        return NULL;
    }
    if(!objectproxy_check_array_bounds(PROXY(cell), xindex, yindex))
    {
        return NULL;
    }
    struct point* pt = object_get_anchor(cell, name);
    if(pt)
    {
        objectproxy_translate_pt_to_array(PROXY(cell), pt, xindex, yindex);
    }
    return pt;
}

struct point* objectbase_get_array_area_anchor(const struct object* cell, int xindex, int yindex, const char* base)
{
    CHECK_PROXY(cell);
    if(!object_is_child_array(cell))
    {
        return NULL;
    }
    if(!objectproxy_check_array_bounds(PROXY(cell), xindex, yindex))
    {
        return NULL;
    }
    struct point* pts = object_get_area_anchor(cell, base);
    if(pts)
    {
        objectproxy_translate_pt_to_array(PROXY(cell), pts + 0, xindex, yindex);
        objectproxy_translate_pt_to_array(PROXY(cell), pts + 1, xindex, yindex);
    }
    return pts;
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
    if(object_is_proxy(cell))
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

int object_has_boundary(const struct object* cell)
{
    if(object_is_proxy(cell))
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

void object_inherit_layer_boundary(struct object* cell, const struct object* othercell, const struct generics* layer)
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

int object_has_layer_boundary(const struct object* cell, const struct generics* layer)
{
    if(object_is_proxy(cell))
    {
        return objectfull_has_layer_boundary(FULLREFERENCE(cell), layer);
    }
    else
    {
        return objectfull_has_layer_boundary(FULL(cell), layer);
    }
}

struct polygon_container* object_get_layer_boundary(const struct object* cell, const struct generics* layer)
{
    CHECK_FULL_OR_PROXY(cell);
    struct polygon_container* boundary = NULL;
    if(object_is_proxy(cell))
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

void object_add_port(struct object* cell, const char* name, const struct generics* layer, const struct point* where, unsigned int sizehint)
{
    CHECK_FULL(cell);
    if(!generics_is_empty(layer))
    {
        struct port* port = objectport_create(name, layer, where->x, where->y, 0, 0, sizehint);
        objectbase_transform_to_global_coordinates(cell, objectport_get_point(port));
        objectfull_add_port(FULL(cell), port);
    }
}

void object_add_bus_port(struct object* cell, const char* name, const struct generics* layer, const struct point* where, int startindex, int endindex, coordinate_t xpitch, coordinate_t ypitch, unsigned int sizehint)
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

void object_add_label(struct object* cell, const char* name, const struct generics* layer, const struct point* where, unsigned int sizehint)
{
    CHECK_FULL(cell);
    if(!generics_is_empty(layer))
    {
        struct port* label = objectport_create(name, layer, where->x, where->y, 0, 0, sizehint);
        objectbase_transform_to_global_coordinates(cell, objectport_get_point(label));
        objectfull_add_label(FULL(cell), label);
    }
}

void object_add_net_shape(struct object* cell, const char* netname, const struct point* bl, const struct point* tr, const struct generics* layer)
{
    struct bltrshape* netarea = objectfull_add_net_shape(FULL(cell), netname, bl, tr, layer);
    objectbase_transform_to_local_coordinates(cell, bltrshape_get_bl(netarea));
    objectbase_transform_to_local_coordinates(cell, bltrshape_get_tr(netarea));
}

struct vector* object_get_net_shapes(const struct object* cell, const char* netname, const struct generics* layer)
{
    CHECK_FULL_OR_PROXY(cell);
    struct vector* nets;
    if(object_is_proxy(cell))
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
    if(object_is_child_array(cell))
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

struct vector* object_get_array_net_shapes(const struct object* cell, int xindex, int yindex, const char* netname, const struct generics* layer)
{
    CHECK_PROXY(cell);
    if(!object_is_child_array(cell))
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

void object_clear_alignment_box(struct object* cell)
{
    CHECK_FULL(cell);
    objectfull_clear_alignment_box(FULL(cell));
}

void object_set_alignment_box(
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

void object_inherit_alignment_box(struct object* cell, const struct object* other)
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

void object_alignment_box_include_point(struct object* cell, const struct point* pt)
{
    CHECK_FULL(cell);
    if(object_is_proxy(cell))
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

void object_alignment_box_include_x(struct object* cell, coordinate_t x)
{
    CHECK_FULL(cell);
    if(object_is_proxy(cell))
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

void object_alignment_box_include_y(struct object* cell, coordinate_t y)
{
    CHECK_FULL(cell);
    if(object_is_proxy(cell))
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

int object_extend_alignment_box(struct object* cell,
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

void objectbase_translate_x(struct object* cell, coordinate_t x)
{
    objectbase_translate(cell, x, 0);
}

void objectbase_translate_y(struct object* cell, coordinate_t y)
{
    objectbase_translate(cell, 0, y);
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
    objectcommon_array_rotate_90_left(COMMON(cell));
}

void objectbase_array_rotate_90_right(struct object* cell)
{
    objectcommon_array_rotate_90_right(COMMON(cell));
}

/*
void object_apply_other_transformation(struct object* cell, const struct transformationmatrix* trans)
{
    transformationmatrix_chain_inline(cell->trans, trans);
}
*/

int object_move_x(struct object* cell, coordinate_t source, coordinate_t target)
{
    object_translate(cell, target - source, 0);
    return 1;
}

int object_move_y(struct object* cell, coordinate_t source, coordinate_t target)
{
    object_translate(cell, 0, target - source);
    return 1;
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

int objectbase_center(struct object* cell, const struct point* target)
{
    struct point* outerbl = object_get_alignmentbox_anchor_outerbl(cell);
    struct point* outertr = object_get_alignmentbox_anchor_outertr(cell);
    coordinate_t sourcex = 0.5 * (point_getx(outertr) - point_getx(outerbl));
    coordinate_t sourcey = 0.5 * (point_gety(outertr) - point_gety(outerbl));
    coordinate_t targetcx = 0;
    coordinate_t targetcy = 0;
    if(target)
    {
        targetcx = point_getx(target);
        targetcy = point_gety(target);
    }
    object_translate(cell, targetcx - sourcex, targetcy - sourcey);
    return 1;
}

int objectbase_center_x(struct object* cell, const struct point* target)
{
    struct point* outerbl = object_get_alignmentbox_anchor_outerbl(cell);
    struct point* outertr = object_get_alignmentbox_anchor_outertr(cell);
    coordinate_t source = 0.5 * (point_getx(outertr) - point_getx(outerbl));
    coordinate_t targetc = 0;
    if(target)
    {
        targetc = point_getx(target);
    }
    object_translate(cell, targetc - source, 0);
    return 1;
}

int objectbase_center_y(struct object* cell, const struct point* target)
{
    struct point* outerbl = object_get_alignmentbox_anchor_outerbl(cell);
    struct point* outertr = object_get_alignmentbox_anchor_outertr(cell);
    coordinate_t source = 0.5 * (point_gety(outertr) - point_gety(outerbl));
    coordinate_t targetc = 0;
    if(target)
    {
        targetc = point_gety(target);
    }
    object_translate(cell, 0, targetc - source);
    return 1;
}

void objectbase_scale(struct object* cell, double factor)
{
    CHECK_FULL_OR_PROXY(cell);
    objectcommon_scale(COMMON(cell), factor);
}

void objectbase_foreach_shapes(struct object* cell, void (*func)(struct shape*))
{
    CHECK_FULL(cell);
    objectfull_foreach_shapes(FULL(cell), func);
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

static void _get_all_shapes_helper(const struct object* cell, const struct generics* layer, size_t maxlevel, struct vector* shapes)
{
    for(size_t i = 0; i < objectbase_get_shapes_size(cell); ++i)
    {
        const struct shape* shape = objectbase_get_shape_const(cell, i);
        if(shape_is_layer(shape, layer))
        {
            vector_append(shapes, shape_to_polygon(shape));
        }
    }
    struct child_iterator* it = object_create_child_iterator(cell);
    while(child_iterator_is_valid(it))
    {
        const struct object* child = child_iterator_get(it);
        _get_all_shapes_helper(child, layer, maxlevel, shapes);
        child_iterator_next(it);
    }
    child_iterator_destroy(it);
}

static struct vector* _get_all_shapes(const struct object* cell, const struct generics* layer, size_t maxlevel)
{
    struct vector* outlines = vector_create(64, polygon_container_destroy);
    _get_all_shapes_helper(cell, layer, maxlevel, outlines);
    return outlines;
}

struct polygon_container* object_get_shape_outlines(const struct object* cell, const struct generics* layer)
{
    struct polygon_container* container = polygon_container_create();
    struct vector* shapes = _get_all_shapes(cell, layer, 0);
    for(size_t i = 0; i < vector_size(shapes); ++i)
    {
        struct shape* shape = vector_get(shapes, i);
        struct simple_polygon* polygon = shape_to_polygon(shape);
        polygon_container_add(container, polygon);
    }
    return container;
}

const struct transformationmatrix* object_get_transformation_matrix(const struct object* cell)
{
    return objectcommon_get_tmatrix(COMMON(cell));
}

const struct transformationmatrix* object_get_array_transformation_matrix(const struct object* cell)
{
    if(!object_is_child_array(cell))
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
    }
    else
    {
        objectbase_get_minmax_xy(obj, &blx, &bly, &trx, &try, NULL); // no extra transformation matrix
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
    if(!object_is_proxy(cell))
    {
        if(cell->content.full.children)
        {
            for(unsigned int i = 0; i < vector_size(cell->content.full.children); ++i)
            {
                _flipx(vector_get(cell->content.full.children, i), 1);
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
    if(!object_is_proxy(cell))
    {
        if(cell->content.full.children)
        {
            for(unsigned int i = 0; i < vector_size(cell->content.full.children); ++i)
            {
                _flipy(vector_get(cell->content.full.children, i), 1);
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
    if(cell->content.full.shapes)
    {
        for(unsigned int i = 0; i < vector_size(cell->content.full.shapes); ++i)
        {
            struct shape* shape = vector_get(cell->content.full.shapes, i);
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
    return cell->content.full.shapes ? !vector_empty(cell->content.full.shapes) : 0;
}

int object_has_layer_flat(const struct object* cell, const struct generics* layer)
{
    const struct object* obj = cell;
    if(object_is_proxy(cell))
    {
        obj = cell->content.proxy.reference;
    }
    if(obj->content.full.shapes)
    {
        struct vector_iterator* it = vector_iterator_create(obj->content.full.shapes);
        while(vector_iterator_is_valid(it))
        {
            struct shape* shape = vector_iterator_get(it);
            if(shape_is_layer(shape, layer))
            {
                return 1;
            }
            vector_iterator_next(it);
        }
        vector_iterator_destroy(it);
    }
    return 0;
}

int object_has_layer(const struct object* cell, const struct generics* layer)
{
    const struct object* obj = cell;
    if(object_is_proxy(cell))
    {
        obj = cell->content.proxy.reference;
    }
    if(object_has_layer_flat(obj, layer))
    {
        return 1;
    }
    if(obj->content.full.children)
    {
        struct vector_iterator* it = vector_iterator_create(obj->content.full.children);
        while(vector_iterator_is_valid(it))
        {
            struct object* object = vector_iterator_get(it);
            if(object_has_layer(object, layer))
            {
                return 1;
            }
            vector_iterator_next(it);
        }
        vector_iterator_destroy(it);
    }
    return 0;
}

int object_has_children(const struct object* cell)
{
    return cell->content.full.children ? !vector_empty(cell->content.full.children) : 0;
}

int object_has_ports(const struct object* cell)
{
    return cell->content.full.ports ? !vector_empty(cell->content.full.ports) : 0;
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
    return cell->isproxy && cell->content.proxy.isarray;
}

int object_has_alignmentbox(const struct object* cell)
{
    if(object_is_proxy(cell))
    {
        return cell->content.proxy.reference->content.full.alignmentbox != NULL;
    }
    else
    {
        return cell->content.full.alignmentbox != NULL;
    }
}

const char* object_get_name(const struct object* cell)
{
    return cell->name;
}

const char* object_get_child_reference_name(const struct object* child)
{
    return child->content.proxy.reference->name;
}

void object_flatten_inline(struct object* cell, int flattenports)
{
    // add shapes and flatten children (recursive)
    if(cell->content.full.children)
    {
        for(unsigned int i = 0; i < vector_size(cell->content.full.children); ++i)
        {
            struct object* child = vector_get(cell->content.full.children, i);
            const struct object* reference = child->content.proxy.reference;
            struct object* flat = object_flatten(reference, flattenports);
            if(flat->content.full.shapes)
            {
                size_t size = vector_size(flat->content.full.shapes);
                while(size > 0)
                {
                    struct shape* S = object_disown_shape(flat, size - 1);
                    --size;
                    shape_apply_transformation(S, flat->trans);
                    shape_apply_transformation(S, child->trans);
                    for(unsigned int ix = 1; ix <= child->content.proxy.xrep; ++ix)
                    {
                        for(unsigned int iy = 1; iy <= child->content.proxy.yrep; ++iy)
                        {
                            struct shape* copy = shape_copy(S);
                            shape_translate(copy, (ix - 1) * child->content.proxy.xpitch, (iy - 1) * child->content.proxy.ypitch);
                            object_add_raw_shape(cell, copy);
                        }
                    }
                    shape_destroy(S);
                }
            }
            if(flat->content.full.labels)
            {
                for(unsigned int p = 0; p < vector_size(flat->content.full.labels); ++p)
                {
                    struct port* label = vector_get(flat->content.full.labels, p);
                    struct port* newlabel = objectport_copy(label);
                    objectport_transform_to_global_coordinates(newlabel, flat->trans);
                    objectport_transform_to_global_coordinates(newlabel, child->trans);
                    _add_port(cell, newlabel);
                }
            }
            if(flattenports)
            {
                if(flat->content.full.ports)
                {
                    for(unsigned int p = 0; p < vector_size(flat->content.full.ports); ++p)
                    {
                        struct port* port = vector_get(flat->content.full.ports, p);
                        struct port* newport = objectport_copy(port);
                        objectport_transform_to_global_coordinates(newport, flat->trans);
                        objectport_transform_to_global_coordinates(newport, child->trans);
                        _add_port(cell, newport);
                    }
                }
            }
            object_destroy(flat);
        }
        vector_destroy(cell->content.full.children);
        cell->content.full.children = NULL;
        vector_destroy(cell->content.full.references);
        cell->content.full.references = NULL;
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
    return cell->content.proxy.xrep;
}

unsigned int object_get_child_yrep(const struct object* cell)
{
    return cell->content.proxy.yrep;
}

coordinate_t object_get_child_xpitch(const struct object* cell)
{
    return cell->content.proxy.xpitch;
}

coordinate_t object_get_child_ypitch(const struct object* cell)
{
    return cell->content.proxy.ypitch;
}

static void _collect_references(const struct object* cell, struct const_vector* references)
{
    if(cell->content.full.references)
    {
        struct vector_const_iterator* it = vector_const_iterator_create(cell->content.full.references);
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
    if(cell->content.full.references)
    {
        struct vector_iterator* it = vector_iterator_create(cell->content.full.references);
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
    it->shapes = cell->content.full.shapes;
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
    it->children = cell->content.full.children;
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
    it->references = cell->content.full.references;
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
    it->references = cell->content.full.references;
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

int object_foreach_anchor(const struct object* cell, anchor_action action, struct generic_arg* extraargs)
{
    if(cell->content.full.anchors)
    {
        struct hashmap_const_iterator* it = hashmap_const_iterator_create(cell->content.full.anchors);
        while(hashmap_const_iterator_is_valid(it))
        {
            const char* name = hashmap_const_iterator_key(it);
            const struct anchor* anchor = hashmap_const_iterator_value(it);
            if(!objectanchor_call(anchor, name, cell->trans, action, extraargs))
            {
                hashmap_const_iterator_destroy(it);
                return 0;
            }
            hashmap_const_iterator_next(it);
        }
        hashmap_const_iterator_destroy(it);
    }
    return 1;
}

int object_foreach_port(const struct object* cell, port_action action, struct generic_arg* extraargs)
{
    if(cell->content.full.ports)
    {
        for(size_t i = 0; i < vector_size(cell->content.full.ports); ++i)
        {
            const struct port* port = vector_get_const(cell->content.full.ports, i);
            if(!objectport_call_port(port, cell->trans, action, extraargs))
            {
                return 0;
            }
        }
    }
    return 1;
}

int object_foreach_label(const struct object* cell, label_action action, struct generic_arg* extraargs)
{
    if(cell->content.full.labels)
    {
        for(size_t i = 0; i < vector_size(cell->content.full.labels); ++i)
        {
            const struct port* label = vector_get_const(cell->content.full.labels, i);
            if(!objectport_call_label(label, cell->trans, action, extraargs))
            {
                return 0;
            }
        }
    }
    return 1;
}

// FIXME: when you reach this point you need to rename all object_ functions in this file to objectbase_
//        and create a corresponding function in object.public.c, which calls the base function
//        From the list of used objectbase_ functions in object.public.c it can also be determined which
//        functions require a CHECK_FULL/CHECK_FULL_OR_PROXY at the beginning. Some functions are called
//        frequently, it might be wise to just check in the top-level calling functions.

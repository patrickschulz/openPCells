#define OPC_OBJECT_IMPLEMENTATION
#include "object.anchors.h"
#include "object.def.h"
#include "object.full.h"
#include "object.util.h"
#undef OPC_OBJECT_IMPLEMENTATION

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "helpers.h"
#include "tuple.h"

#define OBJECT_DEFAULT_SHAPES_SIZE 32
#define OBJECT_DEFAULT_CHILDREN_SIZE 16
#define OBJECT_DEFAULT_REFERENCES_SIZE 8
#define OBJECT_DEFAULT_PORT_SIZE 16
#define OBJECT_DEFAULT_LABEL_SIZE 16

void objectfull_copy_to(const struct object_full* full, struct object_full* new)
{
    // shapes
    if(full->private.shapes)
    {
        new->private.shapes = vector_copy(full->private.shapes, shape_copy);
    }

    // alignmentbox
    if(full->private.alignmentbox)
    {
        objectfull_set_alignment_box(
            new,
            full->private.alignmentbox[0], full->private.alignmentbox[1],
            full->private.alignmentbox[2], full->private.alignmentbox[3],
            full->private.alignmentbox[4], full->private.alignmentbox[5],
            full->private.alignmentbox[6], full->private.alignmentbox[7]
        );
    }

    // anchors
    if(full->private.anchors)
    {
        new->private.anchors = hashmap_create(objectanchor_destroy);
        struct hashmap_const_iterator* it = hashmap_const_iterator_create(full->private.anchors);
        while(hashmap_const_iterator_is_valid(it))
        {
            const char* key = hashmap_const_iterator_key(it);
            const struct anchor* anchor = hashmap_const_iterator_value(it);
            hashmap_insert(new->private.anchors, key, objectanchor_copy(anchor));
            hashmap_const_iterator_next(it);
        }
        hashmap_const_iterator_destroy(it);
    }

    // anchor lines
    if(full->private.anchorlines)
    {
        new->private.anchorlines = hashmap_create(free);
        struct hashmap_const_iterator* it = hashmap_const_iterator_create(full->private.anchorlines);
        while(hashmap_const_iterator_is_valid(it))
        {
            const char* key = hashmap_const_iterator_key(it);
            const coordinate_t* c = hashmap_const_iterator_value(it);
            coordinate_t* cc = malloc(sizeof(*cc));
            *cc = *c;
            hashmap_insert(new->private.anchorlines, key, cc);
            hashmap_const_iterator_next(it);
        }
        hashmap_const_iterator_destroy(it);
    }

    // children
    if(full->private.children)
    {
        new->private.children = vector_create(vector_size(full->private.children), object_destroy);
        for(unsigned int i = 0; i < vector_size(full->private.children); ++i)
        {
            vector_append(new->private.children, object_copy(vector_get(full->private.children, i)));
        }
        new->private.references = vector_create(vector_size(full->private.references), object_destroy);
        for(unsigned int i = 0; i < vector_size(full->private.references); ++i)
        {
            vector_append(new->private.references, object_copy(vector_get(full->private.references, i)));
        }
    }

    // ports
    if(full->private.ports)
    {
        new->private.ports = vector_create(vector_size(full->private.ports), objectport_destroy);
        for(unsigned int i = 0; i < vector_size(full->private.ports); ++i)
        {
            struct port* port = vector_get(full->private.ports, i);
            struct port* newport = objectport_copy(port);
            vector_append(new->private.ports, newport);
        }
    }

    // labels
    if(full->private.labels)
    {
        new->private.labels = vector_create(vector_size(full->private.labels), objectport_destroy);
        for(unsigned int i = 0; i < vector_size(full->private.labels); ++i)
        {
            struct port* label = vector_get(full->private.labels, i);
            struct port* newlabel = objectport_copy(label);
            vector_append(new->private.labels, newlabel);
        }
    }

    // boundary
    if(full->private.boundary)
    {
        new->private.boundary = vector_create(4, point_destroy);
        struct vector_const_iterator* bit = vector_const_iterator_create(full->private.boundary);
        while(vector_const_iterator_is_valid(bit))
        {
            const struct point* pt = vector_const_iterator_get(bit);
            vector_append(new->private.boundary, point_copy(pt));
            vector_const_iterator_next(bit);
        }
        vector_const_iterator_destroy(bit);
    }

    // layer boundaries
    if(full->private.layer_boundaries)
    {
        new->private.layer_boundaries = vector_create(2, tuple2_destroy);
        struct vector_iterator* lbit = vector_iterator_create(full->private.layer_boundaries);
        while(vector_iterator_is_valid(lbit))
        {
            struct tuple2* tuple = vector_iterator_get(lbit);
            const struct generics* key = tuple->first;
            struct polygon_container* polygon_container = tuple->second;
            struct tuple2* tnew = tuple2_create(
                (void*) key,
                NULL,
                polygon_container_copy(polygon_container),
                polygon_container_destroy
            );
            vector_append(new->private.layer_boundaries, tnew);
            vector_iterator_next(lbit);
        }
        vector_iterator_destroy(lbit);
    }

    // nets
    if(full->private.nets)
    {
        new->private.nets = hashmap_create(vector_destroy);
        struct hashmap_iterator* netit = hashmap_iterator_create(full->private.nets);
        while(hashmap_iterator_is_valid(netit))
        {
            const char* key = hashmap_iterator_key(netit);
            struct vector* nets = hashmap_iterator_value(netit);
            hashmap_insert(new->private.nets, key, vector_copy(nets, bltrshape_copy));
            hashmap_iterator_next(netit);
        }
        hashmap_iterator_destroy(netit);
    }

    new->private.ismanaged = full->private.ismanaged;
}

void objectfull_destroy(struct object_full* full)
{
    // shapes
    if(full->private.shapes)
    {
        vector_destroy(full->private.shapes);
    }

    // children
    if(full->private.children)
    {
        vector_destroy(full->private.children);
        vector_destroy(full->private.references);
    }

    // anchors
    if(full->private.anchors)
    {
        hashmap_destroy(full->private.anchors);
    }

    // anchor lines
    if(full->private.anchorlines)
    {
        hashmap_destroy(full->private.anchorlines);
    }

    // ports
    if(full->private.ports)
    {
        vector_destroy(full->private.ports);
    }

    // labels
    if(full->private.labels)
    {
        vector_destroy(full->private.labels);
    }

    // alignmentbox
    if(full->private.alignmentbox)
    {
        free(full->private.alignmentbox);
    }

    // boundary
    if(full->private.boundary)
    {
        vector_destroy(full->private.boundary);
    }

    // layer boundaries
    if(full->private.layer_boundaries)
    {
        vector_destroy(full->private.layer_boundaries);
    }

    // nets
    if(full->private.nets)
    {
        hashmap_destroy(full->private.nets);
    }
}

void objectfull_add_shape(struct object_full* full, struct shape* S)
{
    if(!full->private.shapes)
    {
        full->private.shapes = vector_create(OBJECT_DEFAULT_SHAPES_SIZE, shape_destroy);
    }
    vector_append(full->private.shapes, S);
}

void objectfull_remove_shape(struct object_full* full, size_t idx)
{
    vector_remove(full->private.shapes, idx);
}

struct shape* objectfull_disown_shape(struct object_full* full, size_t idx)
{
    struct shape* shape = vector_disown_element(full->private.shapes, idx);
    return shape;
}

int objectfull_foreach_shapes_const(
    const struct object_full* full,
    const_shape_action action,
    struct generic_arg* extraargs
)
{
    if(full->private.shapes)
    {
        for(unsigned int i = 0; i < vector_size(full->private.shapes); ++i)
        {
            const struct shape* shape = vector_get(full->private.shapes, i);
            if(!action(shape, extraargs))
            {
                return 0;
            }
        }
    }
    return 1;
}

int objectfull_foreach_shapes(
    struct object_full* full,
    shape_action action,
    struct generic_arg* extraargs
)
{
    if(full->private.shapes)
    {
        for(unsigned int i = 0; i < vector_size(full->private.shapes); ++i)
        {
            struct shape* shape = vector_get(full->private.shapes, i);
            if(!action(shape, extraargs))
            {
                return 0;
            }
        }
    }
    return 1;
}

struct shape* objectfull_get_shape(struct object_full* full, size_t idx)
{
    return vector_get(full->private.shapes, idx);
}

const struct shape* objectfull_get_shape_const(const struct object_full* full, size_t idx)
{
    return vector_get_const(full->private.shapes, idx);
}

size_t objectfull_get_shapes_size(const struct object_full* full)
{
    if(!full->private.shapes)
    {
        return 0;
    }
    else
    {
        return vector_size(full->private.shapes);
    }
}

struct vector* objectfull_get_shapes(struct object_full* full)
{
    return full->private.shapes;
}

const struct vector* objectfull_get_shapes_const(const struct object_full* full)
{
    return full->private.shapes;
}

int objectfull_has_layer_flat(const struct object_full* full, const struct generics* layer)
{
    if(full->private.shapes)
    {
        struct vector_iterator* it = vector_iterator_create(full->private.shapes);
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

int objectfull_has_layer(const struct object_full* full, const struct generics* layer)
{
    if(objectfull_has_layer_flat(full, layer))
    {
        return 1;
    }
    if(full->private.children)
    {
        struct vector_iterator* it = vector_iterator_create(full->private.children);
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

static int _contains_reference(const struct object_full* full, const struct object* reference)
{
    return vector_find_flat(full->private.references, reference) != -1;
}

void objectfull_set_managed(struct object_full* full, int ismanaged)
{
    full->private.ismanaged = ismanaged;
}

int objectfull_is_managed(const struct object_full* full)
{
    return full->private.ismanaged;
}

int objectfull_add_reference(struct object_full* full, struct object* reference)
{
    if(!full->private.children)
    {
        full->private.children = vector_create(OBJECT_DEFAULT_CHILDREN_SIZE, object_destroy);
        full->private.references = vector_create(OBJECT_DEFAULT_REFERENCES_SIZE, object_destroy);
    }
    struct object_full* rf = FULL(reference);
    if(!rf->private.ismanaged && !_contains_reference(full, reference))
    {
        vector_append(full->private.references, reference);
        return 1;
    }
    else
    {
        return 0;
    }
}

void objectfull_add_proxy(struct object_full* full, struct object* proxy)
{
    if(!full->private.children)
    {
        full->private.children = vector_create(OBJECT_DEFAULT_CHILDREN_SIZE, object_destroy);
        full->private.references = vector_create(OBJECT_DEFAULT_REFERENCES_SIZE, object_destroy);
    }
    vector_append(full->private.children, proxy);
}

int objectfull_foreach_children_const(const struct object_full* full, const_object_action action, struct generic_arg* extraargs)
{
    if(full->private.children)
    {
        for(size_t i = 0; i < vector_size(full->private.children); ++i)
        {
            struct object* child = vector_get(full->private.children, i);
            int ret = action(child, extraargs);
            if(!ret)
            {
                return 0;
            }
        }
    }
    return 1;
}

int objectfull_foreach_children(struct object_full* full, object_action action, struct generic_arg* extraargs)
{
    if(full->private.children)
    {
        for(size_t i = 0; i < vector_size(full->private.children); ++i)
        {
            struct object* child = vector_get(full->private.children, i);
            int ret = action(child, extraargs);
            if(!ret)
            {
                return 0;
            }
        }
    }
    return 1;
}

int objectfull_foreach_references_const(
    const struct object_full* full,
    const_object_action action,
    struct generic_arg* extraargs
)
{
    if(full->private.children)
    {
        for(size_t i = 0; i < vector_size(full->private.children); ++i)
        {
            struct object* child = vector_get(full->private.children, i);
            const struct object* reference = object_get_reference(child);
            int ret = action(reference, extraargs);
            if(!ret)
            {
                return 0;
            }
        }
    }
    return 1;
}

int objectfull_foreach_references(
    struct object_full* full,
    object_action action,
    struct generic_arg* extraargs
)
{
    if(full->private.children)
    {
        for(size_t i = 0; i < vector_size(full->private.children); ++i)
        {
            struct object* child = vector_get(full->private.children, i);
            struct object* reference = object_get_reference_mutable(child);
            int ret = action(reference, extraargs);
            if(!ret)
            {
                return 0;
            }
        }
    }
    return 1;
}

int objectfull_has_children(const struct object_full* full)
{
    return full->private.children ? !vector_empty(full->private.children) : 0;
}

struct vector* objectfull_get_children(const struct object_full* full)
{
    return full->private.children;
}

const struct vector* objectfull_get_children_const(const struct object_full* full)
{
    return full->private.children;
}

struct vector* objectfull_get_references(const struct object_full* full)
{
    return full->private.references;
}

const struct vector* objectfull_get_references_const(const struct object_full* full)
{
    return full->private.references;
}

// this function is messed up and does not correspond well to the new partitioned object module structure.
// It *might* be better to implement this in object.base.c, with proper access functions
void objectfull_merge_into(
    struct object_full* fulltarget,
    const struct object_full* fullsource,
    const struct transformationmatrix* trans,
    int merge_ports
)
{
    if(fullsource->private.shapes)
    {
        for(unsigned int i = 0; i < vector_size(fullsource->private.shapes); ++i)
        {
            struct shape* shape = shape_copy(vector_get(fullsource->private.shapes, i));
            objectfull_add_shape(fulltarget, shape);
            shape_apply_transformation(shape, trans);
        }
    }
    // FIXME:
    /*
    if(fullsource->private.children)
    {
        // * add_child expects an object that will be owned by the fulltarget
        // * this means that the references must be copied
        // * the references must be only copied once, otherwise all children reference different objects
        // * the data structure of struct object does not allow for finding all children of one reference in a simple manner,
        //   therefore the following code is a bit convoluted
        struct const_vector* used_cell_references = const_vector_create(OBJECT_DEFAULT_REFERENCES_SIZE);
        struct vector* new_cell_references = vector_create(OBJECT_DEFAULT_REFERENCES_SIZE, NULL); // non-owning vector, but non-constant elements are needed
        for(size_t i = 0; i < vector_size(fullsource->private.children); ++i)
        {
            const struct object* child = vector_get_const(fullsource->private.children, i);
            int index = const_vector_find_flat(used_cell_references, REFERENCE(child));
            if(index == -1)
            {
                const_vector_append(used_cell_references, REFERENCE(child));
                vector_append(new_cell_references, object_copy(REFERENCE(child)));
                index = vector_size(new_cell_references) - 1;
            }
            struct object* newchild = objectfull_add_child(fulltarget, vector_get(new_cell_references, index), object_get_name(child));
            object_apply_other_transformation(newchild, child->trans);
            // FIXME: transformation
        }
        const_vector_destroy(used_cell_references);
        vector_destroy(new_cell_references);
    }
    */
    if(fullsource->private.labels)
    {
        for(unsigned int i = 0; i < vector_size(fullsource->private.labels); ++i)
        {
            struct port* label = vector_get(fullsource->private.labels, i);
            struct port* newlabel = objectport_copy(label);
            objectport_apply_tmatrix(newlabel, trans);
            objectfull_add_label(fulltarget, newlabel);
        }
    }
    if(fullsource->private.ports)
    {
        for(unsigned int i = 0; i < vector_size(fullsource->private.ports); ++i)
        {
            struct port* port = vector_get(fullsource->private.ports, i);
            struct port* newport = objectport_copy(port);
            objectport_apply_tmatrix(newport, trans);
            objectfull_add_port(fulltarget, newport);
        }
    }
}

int objectfull_add_anchor(
    struct object_full* full,
    const struct transformationmatrix* trans,
    const char* name,
    struct anchor* anchor
)
{
    if(!full->private.anchors)
    {
        full->private.anchors = hashmap_create(objectanchor_destroy);
    }
    if(hashmap_exists(full->private.anchors, name))
    {
        return 0;
    }
    else
    {
        objectanchor_apply_tmatrix(anchor, trans);
        hashmap_insert(full->private.anchors, name, anchor);
    }
    return 1;
}

int objectfull_inherit_anchor_as(
    struct object_full* full,
    const struct object_full* other,
    const struct transformationmatrix* targettrans,
    const struct transformationmatrix* sourcetrans,
    const char* name,
    const char* newname
)
{
    if(!full->private.anchors)
    {
        full->private.anchors = hashmap_create(objectanchor_destroy);
    }
    const struct anchor* anchor = hashmap_get_const(other->private.anchors, name);
    if(!hashmap_exists(other->private.anchors, name))
    {
        return 0;
    }
    if(objectanchor_is_area(anchor))
    {
        return 0;
    }
    struct anchor* newanchor = objectanchor_copy(anchor);
    objectanchor_apply_tmatrix(newanchor, sourcetrans); // transform to global coordinates
    int ret = objectfull_add_anchor(full, targettrans, newname, newanchor);
    if(!ret)
    {
        objectanchor_destroy(newanchor);
        return 0;
    }
    return 1;
}

int objectfull_inherit_area_anchor_as(
    struct object_full* full,
    const struct object_full* other,
    const struct transformationmatrix* targettrans,
    const struct transformationmatrix* sourcetrans,
    const char* name,
    const char* newname
)
{
    if(!full->private.anchors)
    {
        full->private.anchors = hashmap_create(objectanchor_destroy);
    }
    const struct anchor* anchor = hashmap_get_const(other->private.anchors, name);
    if(!hashmap_exists(other->private.anchors, name))
    {
        return 0;
    }
    if(!objectanchor_is_area(anchor))
    {
        return 0;
    }
    struct anchor* newanchor = objectanchor_copy(anchor);
    objectanchor_apply_tmatrix(newanchor, sourcetrans); // transform to global coordinates
    int ret = objectfull_add_anchor(full, targettrans, newname, newanchor);
    if(!ret)
    {
        objectanchor_destroy(newanchor);
        return 0;
    }
    return 1;
}

void objectfull_inherit_all_anchors_with_prefix(
    struct object_full* full,
    const struct object_full* other,
    const struct transformationmatrix* targettrans,
    const struct transformationmatrix* sourcetrans,
    const char* prefix
)
{
    if(other->private.anchors)
    {
        struct hashmap_const_iterator* it = hashmap_const_iterator_create(other->private.anchors);
        while(hashmap_const_iterator_is_valid(it))
        {
            const char* key = hashmap_const_iterator_key(it);
            const struct anchor* anchor = hashmap_const_iterator_value(it);
            char* newanchorname = malloc(strlen(prefix) + strlen(key) + 1);
            sprintf(newanchorname, "%s%s", prefix, key);
            if(objectanchor_is_area(anchor))
            {
                objectfull_inherit_area_anchor_as(full, other, targettrans, sourcetrans, key, newanchorname);
            }
            else
            {
                objectfull_inherit_anchor_as(full, other, targettrans, sourcetrans, key, newanchorname);
            }
            free(newanchorname);
            hashmap_const_iterator_next(it);
        }
        hashmap_const_iterator_destroy(it);
    }
}

int objectfull_add_anchor_line_xy(
    struct object_full* full,
    const struct transformationmatrix* trans,
    const char* name,
    coordinate_t c,
    int xory
)
{
    if(!full->private.anchorlines)
    {
        full->private.anchorlines = hashmap_create(free);
    }
    if(hashmap_exists(full->private.anchorlines, name))
    {
        return 0;
    }
    else
    {
        coordinate_t dummy = 0;
        if(xory)
        {
            transformationmatrix_apply_inverse_transformation_xy(trans, &c, &dummy);
        }
        else
        {
            transformationmatrix_apply_inverse_transformation_xy(trans, &dummy, &c);
        }
        coordinate_t* ptr = malloc(sizeof(*ptr));
        *ptr = c;
        hashmap_insert(full->private.anchorlines, name, ptr);
    }
    return 1;
}

struct anchor* objectfull_get_anchor(const struct object_full* full, const char* name)
{
    if(hashmap_exists(full->private.anchors, name))
    {
        return hashmap_get(full->private.anchors, name);
    }
    else
    {
        return NULL;
    }
}

coordinate_t* objectfull_get_anchor_line(const struct object_full* full, const char* name)
{
    if(hashmap_exists(full->private.anchorlines, name))
    {
        return hashmap_get(full->private.anchorlines, name);
    }
    else
    {
        return NULL;
    }
}

const struct hashmap* objectfull_get_anchors(const struct object_full* full)
{
    return full->private.anchors;
}

int objectfull_foreach_anchor(
    const struct object_full* full,
    const struct transformationmatrix* trans,
    anchor_action action,
    struct generic_arg* extraargs
)
{
    if(full->private.anchors)
    {
        struct hashmap_const_iterator* it = hashmap_const_iterator_create(full->private.anchors);
        while(hashmap_const_iterator_is_valid(it))
        {
            const char* name = hashmap_const_iterator_key(it);
            const struct anchor* anchor = hashmap_const_iterator_value(it);
            if(!objectanchor_call(anchor, name, trans, action, extraargs))
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

void objectfull_clear_alignment_box(struct object_full* full)
{
    free(full->private.alignmentbox);
    full->private.alignmentbox = NULL;
}

coordinate_t* objectfull_get_alignment_box(const struct object_full* full)
{
    if(!full->private.alignmentbox)
    {
        return NULL;
    }
    else
    {
        coordinate_t* alignmentbox = calloc(8, sizeof(coordinate_t));
        memcpy(alignmentbox, full->private.alignmentbox, 8 * sizeof(coordinate_t));
        return alignmentbox;
    }
}

void objectfull_set_alignment_box(
    struct object_full* full,
    coordinate_t outerblx, coordinate_t outerbly,
    coordinate_t outertrx, coordinate_t outertry,
    coordinate_t innerblx, coordinate_t innerbly,
    coordinate_t innertrx, coordinate_t innertry
)
{
    if(!full->private.alignmentbox)
    {
        full->private.alignmentbox = calloc(8, sizeof(coordinate_t));
    }
    full->private.alignmentbox[0] = outerblx;
    full->private.alignmentbox[1] = outerbly;
    full->private.alignmentbox[2] = outertrx;
    full->private.alignmentbox[3] = outertry;
    full->private.alignmentbox[4] = innerblx;
    full->private.alignmentbox[5] = innerbly;
    full->private.alignmentbox[6] = innertrx;
    full->private.alignmentbox[7] = innertry;
}

void objectfull_extend_alignment_box(
    struct object_full* full,
    coordinate_t outerblx, coordinate_t outerbly,
    coordinate_t outertrx, coordinate_t outertry,
    coordinate_t innerblx, coordinate_t innerbly,
    coordinate_t innertrx, coordinate_t innertry
)
{
    if(!full->private.alignmentbox)
    {
        objectfull_set_alignment_box(
            full,
            outerblx, outerbly, outertrx, outertry,
            innerblx, innerbly, innertrx, innertry
        );
    }
    else
    {
        coordinate_t souterblx = full->private.alignmentbox[0];
        coordinate_t souterbly = full->private.alignmentbox[1];
        coordinate_t soutertrx = full->private.alignmentbox[2];
        coordinate_t soutertry = full->private.alignmentbox[3];
        coordinate_t sinnerblx = full->private.alignmentbox[4];
        coordinate_t sinnerbly = full->private.alignmentbox[5];
        coordinate_t sinnertrx = full->private.alignmentbox[6];
        coordinate_t sinnertry = full->private.alignmentbox[7];
        outerblx = MIN2(outerblx, souterblx);
        outerbly = MIN2(outerbly, souterbly);
        outertrx = MAX2(outertrx, soutertrx);
        outertry = MAX2(outertry, soutertry);
        innerblx = MIN2(innerblx, sinnerblx);
        innerbly = MIN2(innerbly, sinnerbly);
        innertrx = MAX2(innertrx, sinnertrx);
        innertry = MAX2(innertry, sinnertry);
        objectfull_set_alignment_box(
            full,
            outerblx, outerbly, outertrx, outertry,
            innerblx, innerbly, innertrx, innertry
        );
    }
}

int objectfull_has_alignment_box(const struct object_full* full)
{
    return full->private.alignmentbox ? 1 : 0;;
}

struct vector* objectfull_set_boundary(struct object_full* full, struct vector* boundary)
{
    if(full->private.boundary)
    {
        vector_destroy(full->private.boundary);
    }
    full->private.boundary = vector_create(vector_size(boundary), point_destroy);
    struct vector_const_iterator* it = vector_const_iterator_create(boundary);
    while(vector_const_iterator_is_valid(it))
    {
        const struct point* pt = vector_const_iterator_get(it);
        struct point* newpt = point_copy(pt);
        vector_append(full->private.boundary, newpt);
        vector_const_iterator_next(it);
    }
    vector_const_iterator_destroy(it);
    return full->private.boundary;
}

static struct vector* _get_bounding_box(const struct object_full* full)
{
    coordinate_t* pts = objectfull_get_minmax_xy(full, NULL);
    struct vector* boundary = vector_create(4, point_destroy);
    vector_append(boundary, point_create(pts[0], pts[1]));
    vector_append(boundary, point_create(pts[2], pts[1]));
    vector_append(boundary, point_create(pts[2], pts[3]));
    vector_append(boundary, point_create(pts[0], pts[3]));
    return boundary;
}

struct vector* objectfull_get_boundary(const struct object_full* full)
{
    if(full->private.boundary)
    {
        return full->private.boundary;
    }
    else
    {
        return _get_bounding_box(full);
    }
}

int objectfull_has_boundary(const struct object_full* full)
{
    if(full->private.boundary)
    {
        return 1;
    }
    else
    {
        return 0;
    }
}

static int _compare_layer_boundary(const void* v, const void* extraarg)
{
    const struct tuple2* tuple = v;
    const struct generics* layer = extraarg;
    if(tuple->first == layer)
    {
        return 1;
    }
    else
    {
        return 0;
    }
}

void objectfull_set_empty_layer_boundary(struct object_full* full, const struct generics* layer)
{
    if(!full->private.layer_boundaries)
    {
        full->private.layer_boundaries = vector_create(2, tuple2_destroy);
    }
    int index = vector_find_comp(full->private.layer_boundaries, _compare_layer_boundary, layer);
    struct tuple2* tuple;
    if(index != -1)
    {
        tuple = vector_get(full->private.layer_boundaries, index);
        polygon_container_destroy(tuple->second);
    }
    else
    {
        tuple = tuple2_create((void*)layer, NULL, NULL, polygon_container_destroy); // fill second later
        vector_append(full->private.layer_boundaries, tuple);
    }
    // create new polygon container, either the old one was destroyed or there was none
    tuple->second = polygon_container_create_empty();
}

void objectfull_add_layer_boundary(struct object_full* full, const struct generics* layer, struct simple_polygon* new)
{
    if(!full->private.layer_boundaries)
    {
        full->private.layer_boundaries = vector_create(2, tuple2_destroy);
    }
    int index = vector_find_comp(full->private.layer_boundaries, _compare_layer_boundary, layer);
    struct tuple2* tuple;
    if(index != -1)
    {
        tuple = vector_get(full->private.layer_boundaries, index);
    }
    else
    {
        tuple = tuple2_create((void*)layer, NULL, polygon_container_create(), polygon_container_destroy);
        vector_append(full->private.layer_boundaries, tuple);
    }
    struct polygon_container* boundary = tuple->second;
    // add transformed polygon
    polygon_container_add(boundary, new);
}

int objectfull_has_layer_boundary(const struct object_full* full, const struct generics* layer)
{
    if(full->private.layer_boundaries)
    {
        int index = vector_find_comp(full->private.layer_boundaries, _compare_layer_boundary, layer);
        return index != -1;
    }
    else
    {
        return 0;
    }
}

struct polygon_container* objectfull_get_layer_boundary(
    const struct object_full* full,
    const struct generics* layer
)
{
    if(!full->private.layer_boundaries)
    {
        return polygon_container_create_empty();
    }
    int index = vector_find_comp(full->private.layer_boundaries, _compare_layer_boundary, layer);
    if(index != -1)
    {
        struct tuple2* tuple = vector_get(full->private.layer_boundaries, index);
        struct polygon_container* full = tuple->second;
        if(polygon_container_is_empty(full))
        {
            return polygon_container_create_empty();
        }
        struct polygon_container* boundary = polygon_container_create();
        struct polygon_container_const_iterator* pit = polygon_container_const_iterator_create(full);
        while(polygon_container_const_iterator_is_valid(pit))
        {
            const struct simple_polygon* simple_polygon = polygon_container_const_iterator_get(pit);
            struct simple_polygon_const_iterator* it = simple_polygon_const_iterator_create(simple_polygon);
            struct simple_polygon* single_boundary = simple_polygon_create();
            while(simple_polygon_const_iterator_is_valid(it))
            {
                const struct point* pt = simple_polygon_const_iterator_get(it);
                struct point* newpt = point_copy(pt);
                simple_polygon_append(single_boundary, newpt);
                simple_polygon_const_iterator_next(it);
            }
            simple_polygon_const_iterator_destroy(it);
            polygon_container_add(boundary, single_boundary);
            polygon_container_const_iterator_next(pit);
        }
        polygon_container_const_iterator_destroy(pit);
        return boundary;
    }
    else
    {
        struct polygon_container* boundary = polygon_container_create();
        coordinate_t* pts = objectfull_get_minmax_xy(full, NULL);
        struct simple_polygon* single_boundary = simple_polygon_create();
        simple_polygon_append(single_boundary, point_create(pts[0], pts[1]));
        simple_polygon_append(single_boundary, point_create(pts[2], pts[1]));
        simple_polygon_append(single_boundary, point_create(pts[2], pts[3]));
        simple_polygon_append(single_boundary, point_create(pts[0], pts[3]));
        polygon_container_add(boundary, single_boundary);
        return boundary;
    }
}

void objectfull_add_port(struct object_full* full, struct port* port)
{
    if(!full->private.ports)
    {
        full->private.ports = vector_create(OBJECT_DEFAULT_PORT_SIZE, objectport_destroy);
    }
    vector_append(full->private.ports, port);
}

void objectfull_add_label(struct object_full* full, struct port* label)
{
    if(!full->private.labels)
    {
        full->private.labels = vector_create(OBJECT_DEFAULT_PORT_SIZE, objectport_destroy);
    }
    vector_append(full->private.labels, label);
}

size_t objectfull_get_labels_size(const struct object_full* full)
{
    if(!full->private.labels)
    {
        return 0;
    }
    else
    {
        return vector_size(full->private.labels);
    }
}

struct port* objectfull_get_label(struct object_full* full, size_t idx)
{
    return vector_get(full->private.labels, idx);
}

const struct generics* objectfull_get_label_layer(const struct object_full* full, size_t idx)
{
    return objectport_get_layer(vector_get(full->private.labels, idx));
}

void objectfull_remove_label(struct object_full* full, size_t idx)
{
    vector_remove(full->private.labels, idx);
}

const struct vector* objectfull_get_labels(
    const struct object_full* full
)
{
    return full->private.labels;
}

int objectfull_has_ports(const struct object_full* full)
{
    return full->private.ports ? !vector_empty(full->private.ports) : 0;
}

size_t objectfull_get_ports_size(const struct object_full* full)
{
    if(!full->private.ports)
    {
        return 0;
    }
    else
    {
        return vector_size(full->private.ports);
    }
}

struct port* objectfull_get_port(struct object_full* full, size_t idx)
{
    return vector_get(full->private.ports, idx);
}

const struct generics* objectfull_get_port_layer(const struct object_full* full, size_t idx)
{
    return objectport_get_layer(vector_get(full->private.ports, idx));
}

void objectfull_remove_port(struct object_full* full, size_t idx)
{
    vector_remove(full->private.ports, idx);
}

const struct vector* objectfull_get_ports(
    const struct object_full* full
)
{
    return full->private.ports;
}

int objectfull_foreach_port(const struct object_full* full, const struct transformationmatrix* trans, port_action action, struct generic_arg* extraargs)
{
    if(full->private.ports)
    {
        for(size_t i = 0; i < vector_size(full->private.ports); ++i)
        {
            const struct port* port = vector_get_const(full->private.ports, i);
            if(!objectport_call_port(port, trans, action, extraargs))
            {
                return 0;
            }
        }
    }
    return 1;
}

int objectfull_foreach_label(const struct object_full* full, const struct transformationmatrix* trans, label_action action, struct generic_arg* extraargs)
{
    if(full->private.labels)
    {
        for(size_t i = 0; i < vector_size(full->private.labels); ++i)
        {
            const struct port* label = vector_get_const(full->private.labels, i);
            if(!objectport_call_label(label, trans, action, extraargs))
            {
                return 0;
            }
        }
    }
    return 1;
}

struct bltrshape* objectfull_add_net_shape(struct object_full* full, const char* netname, const struct point* bl, const struct point* tr, const struct generics* layer)
{
    if(!full->private.nets)
    {
        full->private.nets = hashmap_create(vector_destroy);
    }
    if(!hashmap_exists(full->private.nets, netname))
    {
        struct vector* v = vector_create(8, bltrshape_destroy);
        hashmap_insert(full->private.nets, netname, v);
    }
    struct vector* nets = hashmap_get(full->private.nets, netname);
    struct bltrshape* netarea = bltrshape_create(bl, tr, layer, netname);
    vector_append(nets, netarea);
    return netarea;
}

const struct hashmap* objectfull_get_all_net_shapes(
    const struct object_full* full
)
{
    return full->private.nets;
}

struct vector* objectfull_get_net_shapes(const struct object_full* full, const char* netname, const struct generics* layer)
{
    if(!full->private.nets)
    {
        return NULL;
    }
    if(!hashmap_exists(full->private.nets, netname))
    {
        return NULL;
    }
    const struct vector* nets = hashmap_get(full->private.nets, netname);
    struct vector* new = vector_create(vector_size(nets), bltrshape_destroy);
    for(unsigned int i = 0; i < vector_size(nets); ++i)
    {
        const struct bltrshape* s = vector_get_const(nets, i);
        int include = 1;
        if(layer && !bltrshape_is_layer(s, layer))
        {
            include = 0;
        }
        if(include)
        {
            struct bltrshape* bltrshape = bltrshape_copy(s);
            vector_append(new, bltrshape);
        }
    }
    return new;
}

void objectfull_inherit_net_shapes(
    struct object_full* cell,
    const struct object_full* other,
    const struct transformationmatrix* targettrans,
    const struct transformationmatrix* sourcetrans,
    const struct generics* layer
)
{
    if(!other->private.nets)
    {
        return;
    }
    struct hashmap_const_iterator* it = hashmap_const_iterator_create(other->private.nets);
    while(hashmap_const_iterator_is_valid(it))
    {
        const char* netname = hashmap_const_iterator_key(it);
        const struct vector* nets = hashmap_const_iterator_value(it);
        for(unsigned int i = 0; i < vector_size(nets); ++i)
        {
            const struct bltrshape* bltrshape = vector_get_const(nets, i);
            int include = 1;
            if(layer && !bltrshape_is_layer(bltrshape, layer))
            {
                include = 0;
            }
            if(include)
            {
                struct point* bl = point_copy(bltrshape_get_bl_const(bltrshape));
                struct point* tr = point_copy(bltrshape_get_tr_const(bltrshape));
                objectutil_transform_to_global_coordinates_pt(sourcetrans, bl);
                objectutil_transform_to_global_coordinates_pt(sourcetrans, tr);
                objectutil_transform_to_local_coordinates_pt(targettrans, bl);
                objectutil_transform_to_local_coordinates_pt(targettrans, tr);
                objectutil_fix_rectangle_order(bl, tr);
                objectfull_add_net_shape(cell, netname, bl, tr, bltrshape_get_layer(bltrshape));
                point_destroy(bl);
                point_destroy(tr);
            }
        }
        hashmap_const_iterator_next(it);
    }
    hashmap_const_iterator_destroy(it);
}

int objectfull_has_net(
    const struct object_full* full,
    const char* netname
)
{
    if(full->private.nets && hashmap_exists(full->private.nets, netname))
    {
        const struct vector* nets = hashmap_get(full->private.nets, netname);
        return vector_size(nets) > 0;
    }
    return 0;
}

coordinate_t* objectfull_get_minmax_xy(
    const struct object_full* full,
    const struct transformationmatrix* trans
)
{
    // FIXME: arrays?
    coordinate_t minx = COORDINATE_MAX;
    coordinate_t maxx = COORDINATE_MIN;
    coordinate_t miny = COORDINATE_MAX;
    coordinate_t maxy = COORDINATE_MIN;
    if(full->private.shapes)
    {
        for(unsigned int i = 0; i < vector_size(full->private.shapes); ++i)
        {
            struct shape* S = vector_get(full->private.shapes, i);
            coordinate_t minx_;
            coordinate_t maxx_;
            coordinate_t miny_;
            coordinate_t maxy_;
            shape_get_minmax_xy(S, &minx_, &miny_, &maxx_, &maxy_);
            minx = MIN2(minx, minx_);
            maxx = MAX2(maxx, maxx_);
            miny = MIN2(miny, miny_);
            maxy = MAX2(maxy, maxy_);
        }
    }
    if(full->private.children)
    {
        for(unsigned int i = 0; i < vector_size(full->private.children); ++i)
        {
            const struct object* child = vector_get(full->private.children, i);
            coordinate_t* pts = object_get_minmax_xy(child);
            coordinate_t minx_ = pts[0];
            coordinate_t maxx_ = pts[2];
            coordinate_t miny_ = pts[1];
            coordinate_t maxy_ = pts[3];
            free(pts);
            if(trans)
            {
                transformationmatrix_apply_transformation_xy(trans, &minx_, &miny_);
                transformationmatrix_apply_transformation_xy(trans, &maxx_, &maxy_);
            }
            objectutil_fix_rectangle_order_xy(&minx_, &miny_, &maxx_, &maxy_);
            // FIXME: transformation? -> should be handled by recursive call, but check this! (construct a cell with the right transformations)
            minx = MIN2(minx, minx_);
            maxx = MAX2(maxx, maxx_);
            miny = MIN2(miny, miny_);
            maxy = MAX2(maxy, maxy_);
        }
    }
    // FIXME: put in helper function
    coordinate_t* minmax = calloc(4, sizeof(coordinate_t)); // order: minx, miny, maxx, maxy
    *(minmax + 0) = minx;
    *(minmax + 1) = miny;
    *(minmax + 2) = maxx;
    *(minmax + 3) = maxy;
    return minmax;
}

void objectfull_flatten_inline(struct object_full* full, int flattenports)
{
    // add shapes and flatten children (recursive)
    if(full->private.children)
    {
        for(unsigned int i = 0; i < vector_size(full->private.children); ++i)
        {
            struct object* child = vector_get(full->private.children, i);
            const struct object* reference = object_get_reference(child);
            struct object* flat = object_flatten(reference, flattenports);
            struct object_full* flat_full = FULL(flat);
            for(unsigned int ix = 1; ix <= object_get_child_xrep(child); ++ix)
            {
                for(unsigned int iy = 1; iy <= object_get_child_yrep(child); ++iy)
                {
                    if(flat_full->private.shapes)
                    {
                        for(size_t si = 0; si < vector_size(flat_full->private.shapes); ++si)
                        {
                            const struct shape* S = objectfull_get_shape_const(flat_full, si);
                            struct shape* copy = shape_copy(S);
                            shape_apply_transformation(copy, object_get_transformation_matrix(flat));
                            shape_apply_transformation(copy, object_get_transformation_matrix(child));
                            shape_translate(copy, (ix - 1) * object_get_child_xpitch(child), (iy - 1) * object_get_child_ypitch(child));
                            objectfull_add_shape(full, copy);
                        }
                    }
                    if(flattenports && flat_full->private.ports)
                    {
                        for(unsigned int p = 0; p < vector_size(flat_full->private.ports); ++p)
                        {
                            struct port* port = vector_get(flat_full->private.ports, p);
                            struct port* newport = objectport_copy(port);
                            //objectport_transform_to_global_coordinates(newport, flat_full->trans);
                            //objectport_transform_to_global_coordinates(newport, child->trans);
                            objectfull_add_port(full, newport);
                        }
                    }
                    if(flat_full->private.labels)
                    {
                        for(unsigned int p = 0; p < vector_size(flat_full->private.labels); ++p)
                        {
                            struct port* label = vector_get(flat_full->private.labels, p);
                            struct port* newlabel = objectport_copy(label);
                            //objectport_transform_to_global_coordinates(newlabel, flat_full->trans);
                            //objectport_transform_to_global_coordinates(newlabel, child->trans);
                            objectfull_add_port(full, newlabel);
                        }
                    }
                }
            }
            object_destroy(flat);
        }
        vector_destroy(full->private.children);
        full->private.children = NULL;
        vector_destroy(full->private.references);
        full->private.references = NULL;
    }
}


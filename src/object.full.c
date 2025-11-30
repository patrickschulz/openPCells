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
        object_set_alignment_box(
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
        new->private.layer_boundaries = hashmap_create(polygon_container_destroy);
        struct hashmap_iterator* lbit = hashmap_iterator_create(full->private.layer_boundaries);
        while(hashmap_iterator_is_valid(lbit))
        {
            const char* key = hashmap_iterator_key(lbit);
            struct polygon_container* polygon_container = hashmap_iterator_value(lbit);
            hashmap_insert(new->private.layer_boundaries, key, polygon_container_copy(polygon_container));
            hashmap_iterator_next(lbit);
        }
        hashmap_iterator_destroy(lbit);
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
        hashmap_destroy(full->private.layer_boundaries);
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

void objectbase_foreach_shapes(struct object* full, void (*func)(struct shape*))
{
    if(full->private.shapes)
    {
        for(unsigned int i = 0; i < vector_size(full->private.shapes); ++i)
        {
            struct shape* shape = vector_get(full->private.shapes, i);
            func(shape);
        }
    }
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

struct shape* objectfull_get_shape(struct object_full* full, size_t idx)
{
    return vector_get(full->private.shapes, idx);
}

const struct shape* objectfull_get_shape_const(const struct object_full* full, size_t idx)
{
    return vector_get_const(full->private.shapes, idx);
}

static int _contains_reference(const struct object_full* full, const struct object* reference)
{
    return vector_find_flat(full->private.references, reference) != -1;
}

int objectfull_add_reference(struct object_full* full, struct object* reference)
{
    if(!full->private.children)
    {
        full->private.children = vector_create(OBJECT_DEFAULT_CHILDREN_SIZE, object_destroy);
        full->private.references = vector_create(OBJECT_DEFAULT_REFERENCES_SIZE, object_destroy);
    }
    if(!reference->ismanaged && !_contains_reference(full, reference))
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

void objectfull_merge_into(struct object_full* fulltarget, const struct object_full* fullsource, int merge_ports)
{
    if(fullsource->private.shapes)
    {
        for(unsigned int i = 0; i < vector_size(fullsource->private.shapes); ++i)
        {
            struct shape* shape = shape_copy(vector_get(fullsource->private.shapes, i));
            object_add_raw_shape(fulltarget, shape);
            shape_apply_transformation(shape, fullsource->trans);
            shape_apply_inverse_transformation(shape, fulltarget->trans);
        }
    }
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
            int index = const_vector_find_flat(used_cell_references, child->private.reference);
            if(index == -1)
            {
                const_vector_append(used_cell_references, child->private.reference);
                vector_append(new_cell_references, object_copy(child->private.reference));
                index = vector_size(new_cell_references) - 1;
            }
            struct object* newchild = object_add_child(fulltarget, vector_get(new_cell_references, index), child->name);
            object_apply_other_transformation(newchild, child->trans);
            // FIXME: transformation
        }
        const_vector_destroy(used_cell_references);
        vector_destroy(new_cell_references);
    }
    if(fullsource->private.labels)
    {
        for(unsigned int i = 0; i < vector_size(fullsource->private.labels); ++i)
        {
            struct port* label = vector_get(fullsource->private.labels, i);
            struct port* newlabel = objectport_copy(label);
            objectport_transform_to_global_coordinates(newlabel, fullsource->trans);
            objectport_transform_to_cell_coordinates(newlabel, fulltarget->trans);
            _add_label(fulltarget, newlabel);
        }
    }
    if(fullsource->private.ports)
    {
        for(unsigned int i = 0; i < vector_size(fullsource->private.ports); ++i)
        {
            struct port* port = vector_get(fullsource->private.ports, i);
            struct port* newport = objectport_copy(port);
            objectport_transform_to_global_coordinates(newport, fullsource->trans);
            objectport_transform_to_cell_coordinates(newport, fulltarget->trans);
            _add_port(fulltarget, newport);
        }
    }
}

int objectfull_add_anchor(struct object_full* full, const char* name, struct anchor* anchor)
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
        objectanchor_transform_to_cell_coordinates(anchor, full->trans);
        hashmap_insert(full->private.anchors, name, anchor);
    }
    return 1;
}

void objectfull_inherit_all_anchors_with_prefix(struct object_full* full, const struct object_full* other, const char* prefix)
{
    if(full->private.anchors)
    {
        struct hashmap_const_iterator* it = hashmap_const_iterator_create(full->private.anchors);
        while(hashmap_const_iterator_is_valid(it))
        {
            const char* key = hashmap_const_iterator_key(it);
            const struct anchor* anchor = hashmap_const_iterator_value(it);
            char* newanchorname = malloc(strlen(prefix) + strlen(key) + 1);
            sprintf(newanchorname, "%s%s", prefix, key);
            if(objectanchor_is_area(anchor))
            {
                object_inherit_area_anchor_as(full, full, key, newanchorname);
            }
            else
            {
                object_inherit_anchor_as(full, full, key, newanchorname);
            }
            free(newanchorname);
            hashmap_const_iterator_next(it);
        }
        hashmap_const_iterator_destroy(it);
    }
}

int objectfull_add_anchor_line_xy(struct object_full* full, const char* name, coordinate_t c, int xory)
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
            objectbase_transform_to_local_coordinates_xy(full, &c, &dummy);
        }
        else
        {
            objectbase_transform_to_local_coordinates_xy(full, &dummy, &c);
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
        transformationmatrix_apply_inverse_transformation(full->trans, newpt);
        vector_append(cullell->private.boundary, newpt);
        vector_const_iterator_next(it);
    }
    vector_const_iterator_destroy(it);
    return full->private.boundary;
}

struct vector* objectfull_get_boundary(const struct object_full* full)
{
    if(full->private.boundary)
    {
        return full->private.boundary;
    }
    else
    {
        return NULL;
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

void objectfull_set_empty_layer_boundary(struct object_full* full, const struct generics* layer)
{
    if(!full->private.layer_boundaries)
    {
        full->private.layer_boundaries = hashmap_create(polygon_container_destroy);
    }
    if(hashmap_exists(full->private.layer_boundaries, (const char*)layer))
    {
        struct polygon_container* boundary = hashmap_get(full->private.layer_boundaries, (const char*)layer);
        polygon_container_destroy(boundary);
    }
    struct polygon_container* boundary = polygon_container_create_empty();
    hashmap_insert(full->private.layer_boundaries, (const char*)layer, boundary);
}

void objectfull_add_layer_boundary(struct object_full* full, const struct generics* layer, struct simple_polygon* new)
{
    if(!full->private.layer_boundaries)
    {
        full->private.layer_boundaries = hashmap_create(polygon_container_destroy);
    }
    if(!hashmap_exists(full->private.layer_boundaries, (const char*)layer))
    {
        struct polygon_container* polygon_container = polygon_container_create();
        hashmap_insert(full->private.layer_boundaries, (const char*)layer, polygon_container);
    }
    struct polygon_container* boundary = hashmap_get(full->private.layer_boundaries, (const char*)layer);
    // add transformed polygon
    polygon_container_add(boundary, new);
}

int objectfull_has_layer_boundary(const struct object_full* full, const struct generics* layer)
{
    if(full->private.layer_boundaries)
    {
        return hashmap_exists(full->private.layer_boundaries, (const char*)layer);
    }
    else
    {
        return 0;
    }
}

struct polygon_container* objectfull_get_layer_boundary(const struct object_full* full, const struct generics* layer)
{
    if(!full->private.layer_boundaries)
    {
        return polygon_container_create_empty();
    }
    struct polygon_container* cellboundary = hashmap_get(full->private.layer_boundaries, (const char*)layer);
    if(cellboundary)
    {
        if(polygon_container_is_empty(cellboundary))
        {
            return polygon_container_create_empty();
        }
        struct polygon_container* boundary = polygon_container_create();
        struct polygon_container_const_iterator* pit = polygon_container_const_iterator_create(cellboundary);
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
        coordinate_t blx, bly, trx, try;
        object_get_minmax_xy(full, &blx, &bly, &trx, &try, NULL); // no extra transformation matrix (FIXME: is this correct?)
        struct simple_polygon* single_boundary = simple_polygon_create();
        simple_polygon_append(single_boundary, point_create(blx, bly));
        simple_polygon_append(single_boundary, point_create(trx, bly));
        simple_polygon_append(single_boundary, point_create(trx, try));
        simple_polygon_append(single_boundary, point_create(blx, try));
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

void objectfull_add_port(struct object_full* full, struct port* port)
{
    if(!full->private.labels)
    {
        full->private.labels = vector_create(OBJECT_DEFAULT_PORT_SIZE, objectport_destroy);
    }
    vector_append(full->private.labels, port);
}

struct bltrshape* objectull_add_net_shape(struct object_full* full, const char* netname, const struct point* bl, const struct point* tr, const struct generics* layer)
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
    struct bltrshape* netarea = bltrshape_create(bl, tr, layer);
    vector_append(nets, netarea);
    return netarea;
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

coordinate_t* objectfull_get_minmax_xy(const struct object_full* full)
{
    coordinate_t* minmax = calloc(4, sizeof(coordinate_t)); // order: minx, miny, maxx, maxy
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
            const struct object* obj = child->private.reference;
            coordinate_t minx_, maxx_, miny_, maxy_;
            objectbase_get_minmax_xy(obj, &minx_, &miny_, &maxx_, &maxy_, child->trans);
            transformationmatrix_apply_transformation_xy(full->trans, &minx_, &miny_);
            transformationmatrix_apply_transformation_xy(full->trans, &maxx_, &maxy_);
            _fix_minmax_order(&minx_, &miny_, &maxx_, &maxy_);
            // FIXME: transformation? -> should be handled by recursive call, but check this! (construct a cell with the right transformations)
            minx = MIN2(minx, minx_);
            maxx = MAX2(maxx, maxx_);
            miny = MIN2(miny, miny_);
            maxy = MAX2(maxy, maxy_);
        }
    }
    *(minmax + 0) = minx;
    *(minmax + 1) = maxx;
    *(minmax + 2) = miny;
    *(minmax + 3) = maxy;
}


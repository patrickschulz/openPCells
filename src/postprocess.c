#include "postprocess.h"

#include <string.h>

#include "vector.h"
#include "union.h"

static void _merge_shapes(struct object* object, struct technology_state* techstate)
{
    struct layer_iterator* it = layer_iterator_create(techstate);
    while(layer_iterator_is_valid(it))
    {
        const struct generics* layer = layer_iterator_get(it);
        struct vector* rectangles = vector_create(32, NULL);
        for(int j = object_get_shapes_size(object) - 1; j >= 0; --j)
        {
            struct shape* S = object_get_shape(object, j);
            if(shape_is_rectangle(S) && shape_get_layer(S) == layer)
            {
                vector_append(rectangles, S);
                object_disown_shape(object, j);
            }
        }
        if(vector_size(rectangles) > 1)
        {
            union_rectangle_all(rectangles);
        }
        for(unsigned int i = 0; i < vector_size(rectangles); ++i)
        {
            object_add_raw_shape(object, vector_get(rectangles, i));
        }
        vector_destroy(rectangles);
        layer_iterator_next(it);
    }
    layer_iterator_destroy(it);
}

void postprocess_merge_shapes(struct object* object, struct technology_state* techstate)
{
    _merge_shapes(object, techstate);
}

void postprocess_remove_layer_shapes_flat(struct object* object, const struct generics* layer)
{
    for(int i = object_get_shapes_size(object) - 1; i >= 0; --i)
    {
        struct shape* S = object_get_shape(object, i);
        if(shape_get_layer(S) == layer)
        {
            object_remove_shape(object, i);
        }
    }
}

void postprocess_remove_layer_shapes(struct object* object, const struct generics* layer)
{
    postprocess_remove_layer_shapes_flat(object, layer);
    struct mutable_reference_iterator* ref_it = object_create_mutable_reference_iterator(object);
    while(mutable_reference_iterator_is_valid(ref_it))
    {
        struct object* reference = mutable_reference_iterator_get(ref_it);
        postprocess_remove_layer_shapes(reference, layer);
        mutable_reference_iterator_next(ref_it);
    }
}


#include "postprocess.h"

#include <string.h>

#include "vector.h"
#include "union.h"
#include "pcell.h"

static void _merge_shapes(object_t* object, struct layermap* layermap)
{
    struct layer_iterator* it = layer_iterator_create(layermap);
    while(layer_iterator_is_valid(it))
    {
        generics_t* layer = layer_iterator_get(it);
        struct vector* rectangles = vector_create(32);
        for(int j = object_get_shapes_size(object) - 1; j >= 0; --j)
        {
            shape_t* S = object_get_shape(object, j);
            if(S->type == RECTANGLE && S->layer == layer)
            {
                vector_append(rectangles, S);
                object_remove_shape(object, j);
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
        vector_destroy(rectangles, NULL);
        layer_iterator_next(it);
    }
    layer_iterator_destroy(it);
}

void postprocess_merge_shapes(object_t* object, struct layermap* layermap)
{
    _merge_shapes(object, layermap);
}

void postprocess_filter_exclude(object_t* object, const char** layernames)
{
    for(int i = object_get_shapes_size(object) - 1; i >= 0; --i)
    {
        shape_t* S = object_get_shape(object, i);
        const char** layername = layernames;
        while(*layername)
        {
            if(strcmp(S->layer->name, *layername) == 0)
            {
                object_remove_shape(object, i);
            }
            ++layername;
        }
    }
}

void postprocess_filter_include(object_t* object, const char** layernames)
{
    for(int i = object_get_shapes_size(object) - 1; i >= 0; --i)
    {
        shape_t* S = object_get_shape(object, i);
        int keep = 0;
        const char** layername = layernames;
        while(*layername)
        {
            if(strcmp(S->layer->name, *layername) == 0)
            {
                keep = 1;
            }
            ++layername;
        }
        if(!keep)
        {
            object_remove_shape(object, i);
        }
    }
}


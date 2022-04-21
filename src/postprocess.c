#include "postprocess.h"

#include <string.h>

#include "vector.h"
#include "union.h"
#include "pcell.h"

static void _merge_shapes(object_t* object, struct layermap* layermap)
{
    // merge rectangles
    for(unsigned int i = 0; i < generics_get_layer_map_size(layermap); ++i)
    {
        generics_t* layer = generics_get_indexed_layer(layermap, i);
        struct vector* rectangles = vector_create();
        for(int j = object->shapes_size - 1; j >= 0; --j)
        {
            shape_t* S = object->shapes[j];
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
    }
}

void postprocess_merge_shapes(object_t* object, struct layermap* layermap)
{
    _merge_shapes(object, layermap);
}

void postprocess_filter_exclude(object_t* object, const char** layernames)
{
    for(int i = object->shapes_size - 1; i >= 0; --i)
    {
        shape_t* S = object->shapes[i];
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
    for(int i = object->shapes_size - 1; i >= 0; --i)
    {
        shape_t* S = object->shapes[i];
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


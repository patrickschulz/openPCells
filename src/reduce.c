#include "reduce.h"

#include "vector.h"
#include "union.h"
#include "pcell.h"

static void _merge_shapes(object_t* object)
{
    // merge rectangles
    for(unsigned int i = 0; i < generics_get_layer_map_size(); ++i)
    {
        generics_t* layer = generics_get_indexed_layer(i);
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
        vector_destroy(rectangles);
    }
}

void reduce_merge_shapes(object_t* object)
{
    _merge_shapes(object);
    for(unsigned int i = 0; i < pcell_get_reference_count(); ++i)
    {
        struct cellreference* reference = pcell_get_indexed_cell_reference(i);
        _merge_shapes(reference->cell);
    }
}


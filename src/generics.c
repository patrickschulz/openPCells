#include "generics.h"

#include <stdlib.h>

// FIXME
#include <stdio.h>

generics_t* generics_create_metal(int num)
{
    generics_t* layer = malloc(sizeof(*layer));
    layer->layer = malloc(sizeof(struct generic_metal_t));
    ((struct generic_metal_t*)layer->layer)->metal = num;
    layer->type = METAL;
    return layer;
}

void generics_destroy(generics_t* layer)
{
    free(layer);
}

generics_t* generics_copy(generics_t* layer)
{
    if(layer->type == METAL)
    {
        return generics_create_metal(((struct generic_metal_t*)layer->layer)->metal);
    }
    else
    {
        puts("NO IMPLEMENTATION TO COPY THIS LAYER!");
        return NULL;
    }
}

#include "info.h"

#include <stdio.h>

void info_cellinfo(struct object* cell)
{
    printf("number of shapes: %ld\n", object_get_shapes_size(cell));

    //print("used layers:")
    //for _, lpp in cell:layers() do
    //    print(string.format("  %s", lpp:str()))
    //end
}


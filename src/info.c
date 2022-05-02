#include "info.h"

#include <stdio.h>

void info_cellinfo(object_t* cell)
{
    printf("number of shapes: %ld\n", cell->shapes_size);

    //print("used layers:")
    //for _, lpp in cell:layers() do
    //    print(string.format("  %s", lpp:str()))
    //end
}


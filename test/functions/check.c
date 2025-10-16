#include "check.h"

#include <stdio.h>

void check_boolean(int b, const char* message)
{
    if(b)
    {
        printf("\033[1;32mfunction test succeeded: %s\033[0m\n", message);
    }
    else
    {
        printf("\033[1;31mfunction test failed: %s\033[0m\n", message);
    }
}

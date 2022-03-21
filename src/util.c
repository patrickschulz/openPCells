#include "util.h"

#include <stdlib.h>
#include <string.h>

unsigned int util_num_digits(unsigned int n)
{
    if(n == 0) return 1;
    unsigned int count = 0;
    while (n > 0)
    {
        ++count;
        n /= 10;
    }
    return count;
}

char* util_copy_string(const char* str)
{
    size_t len = strlen(str);
    char* copy = malloc(len + 1);
    strncpy(copy, str, len + 1);
    return copy;
}


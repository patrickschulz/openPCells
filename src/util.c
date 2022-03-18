#include "util.h"

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


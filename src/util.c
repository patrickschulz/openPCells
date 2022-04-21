#include "util.h"

#include <stdlib.h>
#include <string.h>
#include <sys/stat.h>

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

void util_append_string(char* target, const char* str)
{
    size_t len = strlen(target) + strlen(str);
    char* tmp = realloc(target, len + 1);
    target = tmp;
    strcat(target, str);
}

int util_file_exists(const char* path)
{
    if(!path)
    {
        return 0;
    }
    struct stat buf;
    if(stat(path, &buf))
    {
        return 0;
    }
    else
    {
        return 1;
    }
}

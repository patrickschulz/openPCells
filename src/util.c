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

int util_split_string(const char* src, char delim, char** first, char** second)
{
    const char* ptr = src;
    while(*ptr)
    {
        if(*ptr == delim)
        {
            break;
        }
        ++ptr;
    }
    if(*ptr)
    {
        *first = malloc(ptr - src + 1);
        strncpy(*first, src, ptr - src);
        (*first)[ptr - src] = 0;
        *second = malloc(strlen(src) - (ptr - src + 1) + 1);
        strncpy(*second, ptr + 1, strlen(src) - (ptr - src + 1) + 1);
        return 1;
    }
    else
    {
        return 0;
    }
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

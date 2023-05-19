#include "util.h"

#include <stdlib.h>
#include <string.h>
#include <sys/stat.h>
#include <string.h>
#include <stdlib.h>
#include <stdio.h>

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

int util_match_string(const char* str, const char* match)
{
    const char* ptr = str;
    while(*ptr)
    {
        const char* src = ptr;
        const char* cmp = match;
        while(*cmp && *src && *cmp == *src)
        {
            ++cmp;
            ++src;
        }
        if(!*cmp) /* match found */
        {
            return 1;
        }
        ++ptr;
    }
    return 0;
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
        memcpy(*first, src, ptr - src);
        (*first)[ptr - src] = 0;
        *second = malloc(strlen(src) - (ptr - src + 1) + 1);
        memcpy(*second, ptr + 1, strlen(src) - (ptr - src + 1) + 1);
        (*second)[strlen(src) - (ptr - src + 1) + 1] = 0;
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

char* util_strdup(const char* str)
{
    char* dup = malloc(strlen(str) + 1);
    strcpy(dup, str);
    return dup;
}

char* util_concat_path(const char* prefix, const char* suffix)
{
    size_t prefixlen = strlen(prefix);
    size_t suffixlen = strlen(suffix);
    size_t fulllen = prefixlen + suffixlen + 1; /* +1: '/' */
    char* fullpath = malloc(fulllen + 1);
    snprintf(fullpath, fulllen + 1, "%s/%s", prefix, suffix);
    return fullpath;
}


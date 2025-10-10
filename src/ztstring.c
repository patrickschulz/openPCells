#include "ztstring.h"

#include <string.h>

char* ztstring_create(void)
{
    char* str = malloc(1);
    str[0] = 0;
    return str;
}

void ztstring_append(char* str, char ch)
{
    size_t len = strlen(str);
    str = realloc(str, len + 1 + 1);
    str[len] = ch;
    str[len + 1] = 0;
}


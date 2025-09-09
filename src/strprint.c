#include "string.h"

static void _add_digit(struct string* string, int i)
{
    if(i > 9)
    {
        _add_digit(string, i / 10);
        while(i > 9)
        {
            i = i - (i / 10) * 10;
        }
        string_add_character(string, i + '0');
    }
    else
    {
        string_add_character(string, i + '0');
    }
}

void strprint_integer(struct string* string, int i)
{
    if(i < 0)
    {
        string_add_character(string, '-');
        i = -i;
    }
    _add_digit(string, i);
}


#include "strprint.h"

#include <assert.h>

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

static void _add_udigit(struct string* string, unsigned int i)
{
    if(i > 9)
    {
        _add_udigit(string, i / 10);
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

void strprint_uinteger(struct string* string, unsigned int i)
{
    _add_udigit(string, i);
}

char* strprintf(const char* fmt, ...)
{
    va_list args;
    va_start(args, fmt);
    char* str = strprintfv(fmt, args);
    va_end(args);
    return str;
}

char* strprintfv(const char* fmt, va_list args)
{
    struct string* str = string_create();
    const char* ptr = fmt;
    while(*ptr)
    {
        if(*ptr == '%')
        {
            ++ptr;
            if(!*ptr) // check for '%' at the end of a string
            {
                break;
            }
            switch(*ptr)
            {
                case '%':
                    string_add_character(str, '%');
                    break;
                case 's':
                {
                    const char* s = va_arg(args, const char*);
                    string_add_string(str, s);
                    break;
                }
                case 'd':
                {
                    int i = va_arg(args, int);
                    strprint_integer(str, i);
                    break;
                }
                case 'u':
                {
                    unsigned int i = va_arg(args, unsigned int);
                    strprint_integer(str, i);
                    break;
                }
                default:
                    assert(0);
                    break;
            }
        }
        else
        {
            string_add_character(str, *ptr);
        }
        ++ptr;
    }
    return string_dissolve(str);
}

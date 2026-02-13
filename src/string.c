#include "string.h"

#include <stdarg.h>
#include <stddef.h>
#include <stdlib.h>

struct string {
    char* content;
    size_t size;
    size_t capacity;
};

static void _resize_data(struct string* string, size_t capacity)
{
    string->capacity = capacity;
    void* e = realloc(string->content, sizeof(char) * string->capacity);
    string->content = e;
    for(size_t i = string->size; i < string->capacity; ++i)
    {
        string->content[i] = 0;
    }
}

struct string* string_create(void)
{
    struct string* string = malloc(sizeof(*string));
    string->content = NULL;
    string->size = 0;
    string->capacity = 8;
    _resize_data(string, string->capacity);
    return string;
}

void string_destroy(void* v)
{
    struct string* string = v;
    free(string->content);
    free(string);
}

char* string_dissolve(struct string* string)
{
    char* content = string->content;
    free(string);
    return content;
}

void string_add_character(struct string* string, char ch)
{
    while(string->size + 1 == string->capacity)
    {
        _resize_data(string, string->capacity ? string->capacity * 2 : 1);
    }
    string->content[string->size] = ch;
    string->size += 1;
}

void string_add_string(struct string* string, const char* str)
{
    while(*str)
    {
        string_add_character(string, *str);
        ++str;
    }
}

void string_add_string_n(struct string* string, const char* str, size_t n)
{
    size_t num = 0;
    while(*str)
    {
        if(num < n)
        {
            string_add_character(string, *str);
        }
        else
        {
            break;
        }
        ++num;
        ++str;
    }
}

void string_add_strings(struct string* string, size_t num, ...)
{
    va_list strings;
    va_start(strings, num);
    for(size_t i = 0; i < num; ++i)
    {
        const char* str = va_arg(strings, const char*);
        string_add_string(string, str);
    }
    va_end(strings);
}

const char* string_get(struct string* string)
{
    return string->content;
}

char string_get_character(struct string* string, size_t i)
{
    return string->content[i];
}


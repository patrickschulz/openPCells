#ifndef RCREDUCER_STRING_H
#define RCREDUCER_STRING_H

#include <stddef.h>

struct string;

struct string* string_create(void);
void string_destroy(void* v);
char* string_dissolve(struct string* string);
void string_add_character(struct string* string, char ch);
void string_add_string(struct string* string, const char* str);
void string_add_strings(struct string* string, size_t num, ...);
const char* string_get(struct string* string);
char string_get_character(struct string* string, size_t i);

#endif /* RCREDUCER_STRING_H */

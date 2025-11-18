#ifndef OPC_FOREACH_ARGS_H
#define OPC_FOREACH_ARGS_H

#include <stddef.h>

enum arg_type {
    ARG_INT,
    ARG_DOUBLE,
    ARG_CHAR,
    ARG_STRING,
    ARG_POINTER,
    ARG_CONST_POINTER,
    ARG_END // terminator
};

struct generic_arg {
    union {
        int i;
        double d;
        char ch;
        const char* str;
        void* ptr;
        const void* cptr;
    } content;
    enum arg_type type;
};

int args_get_int(struct generic_arg* args, size_t index);
double args_get_double(struct generic_arg* args, size_t index);
char args_get_char(struct generic_arg* args, size_t index);
const char* args_get_string(struct generic_arg* args, size_t index);
void* args_get_pointer(struct generic_arg* args, size_t index);
const void* args_get_const_pointer(struct generic_arg* args, size_t index);

#endif /* OPC_FOREACH_ARGS_H */

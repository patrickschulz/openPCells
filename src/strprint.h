#ifndef OPC_STRPRINT_H
#define OPC_STRPRINT_H

#include <stdarg.h>

#include "string.h"

void strprint_integer(struct string* string, int i);
char* strprintf(const char* fmt, ...);
char* strprintfv(const char* fmt, va_list args);

#endif /* OPC_STRPRINT_H */

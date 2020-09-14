#ifndef LFRAC_H
#define LFRAC_H

#include <stdint.h>

typedef uint8_t lfrac_sign_t;
typedef uint32_t lfrac_int_t;

#define MAXDIGITS 80
#define TYPENAME "lfrac"
#define MODULENAME "fractional"
#define CONVPRECISION 100000

typedef struct _frac
{
    lfrac_sign_t sign;
    lfrac_int_t numerator;
    lfrac_int_t denominator;
} lfrac_t;

int open_lfrac_lib(lua_State* L);

#endif // LFRAC_H

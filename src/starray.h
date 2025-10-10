#ifndef OPC_STARRAY_H
#define OPC_STARRAY_H

#include <stdlib.h>

#define starray_create(name, type) type* name = malloc(1 * sizeof(*name)); name[0] = NULL;
#define starray_append(name, type, element) \
    do {\
        type* p = name; \
        size_t len = 1; \
        while(*p) \
        { \
            ++len; \
            ++p; \
        } \
        name = realloc(name, (len + 1) * sizeof(*name)); \
        name[len - 1] = element; \
        name[len] = NULL; \
    } while(0)
#define starray_destroy(name, type, destructor) \
    do {\
        type* p = name; \
        while(*p) \
        { \
            destructor(*p); \
            ++p; \
        } \
    } while(0)


#endif /* OPC_STARRAY_H */

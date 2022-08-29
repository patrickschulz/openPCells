#include <stddef.h>

/*
 * This datastructure can be used like an array,
 * e.g. int* v = valvector_create(sizeof(*v));
 *      printf("%d\n", v[0]);
 * bookkeeping data is kept BEFORE the data (which a pointer to is returned)
 * While the signature is void*, ALL functions that take a valvector as argument
 * expect a pointer to the vector (&v), since the argument could be modified.
 * While functions such as valvector_size do not modify it, for consistency 
 * still &v must be passed
 */

void* valvector_create(size_t elem_size);
void valvector_destroy(void* vp);
void valvector_append(void* vp, const void* e);
size_t valvector_size(void* vp);

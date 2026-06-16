#ifndef OPC_TEST_CHECK_H
#define OPC_TEST_CHECK_H

#include <stdlib.h> // for convenience, malloc/free will be used in tests

#include "src/point.h"

void check_boolean(int b, const char* msg);
void check_point(struct point* pt, coordinate_t x, coordinate_t y, const char* msg);

#endif /* OPC_TEST_CHECK_H */

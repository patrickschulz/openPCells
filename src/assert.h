#ifndef OPC_ASSERT_H
#define OPC_ASSERT_H

#include <assert.h>

#define OPC_ASSERT_MSG1(condition, message1) if(!condition) { fprintf(stderr, "assertation failed: %s", message1); }
#define OPC_ASSERT_MSG2(condition, message1, message2) if(!condition) { fprintf(stderr, "assertation failed: %s%s", message1, message2); }

#endif /* OPC_ASSERT_H */

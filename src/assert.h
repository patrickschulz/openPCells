#ifndef OPC_ASSERT_H
#define OPC_ASSERT_H

#include <assert.h>

#ifdef NDEBUG
#define OPC_ASSERT_MSG1(condition, message1) do {} while(0)
#define OPC_ASSERT_MSG2(condition, message1, message2) do {} while(0)
#else
#define OPC_ASSERT_MSG1(condition, message1) if(!condition) { fprintf(stderr, "assertation failed: %s\n", message1); abort(); }
#define OPC_ASSERT_MSG2(condition, message1, message2) if(!condition) { fprintf(stderr, "assertation failed: %s%s\n", message1, message2); abort(); }
#endif

#endif /* OPC_ASSERT_H */

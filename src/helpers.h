#ifndef OPC_HELPERS_H
#define OPC_HELPERS_H

#define debugprintf printf

// min/max expressions
#define MAX2(a, b) ((a) > (b) ? (a) : (b))
#define MIN2(a, b) ((a) > (b) ? (b) : (a))
#define MAX4(a, b, c, d) MAX2(MAX2(a, b), MAX2(c, d))
#define MIN4(a, b, c, d) MIN2(MIN2(a, b), MIN2(c, d))

#endif /* OPC_HELPERS_H */

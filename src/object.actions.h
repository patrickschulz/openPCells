#ifndef OPC_OBJECT_ACTION_H
#define OPC_OBJECT_ACTION_H

/*
 * function pointer typedefs for various object-related foreach functions
 */

struct generic_arg;
struct shape;
struct object;

typedef int (*const_shape_action)(const struct shape* shape, struct generic_arg* extraargs);
typedef int (*shape_action)(struct shape* shape, struct generic_arg* extraargs);

typedef int (*const_object_action)(const struct object* object, struct generic_arg* extraargs);
typedef int (*object_action)(struct object* object, struct generic_arg* extraargs);

#endif /* OPC_OBJECT_ACTION_H*/

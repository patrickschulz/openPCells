#ifndef OPC_OBJECT_IMPLEMENTATION
#error "This header must only be included in the implementation files of the object module. It is not intended for external use."
#endif

#ifndef OPC_OBJECT_DEF_H
#define OPC_OBJECT_DEF_H

#include "object.common.h"
#include "object.full.h"
#include "object.proxy.h"

#include "assert.h"

struct object {
    struct object_common common;
    union {
        struct object_proxy proxy; // proxy objects (light handles to children)
        struct object_full full; // full objects
    } content;
};

#define COMMON(obj) &obj->common
#define PROXY(obj) &obj->content.proxy
#define FULL(obj) &obj->content.full
#define REFERENCE(obj) objectproxy_get_reference(&obj->content.proxy)
#define REFERENCE_MUTABLE(obj) objectproxy_get_reference_mutable(&obj->content.proxy)
#define FULLREFERENCE(obj) FULL(REFERENCE(obj))

#define CHECK_FULL(obj)\
    OPC_ASSERT_MSG2(\
        objectcommon_is_full(COMMON(obj)),\
        __func__,\
        ": object given must be a full object"\
    )
#define CHECK_PROXY(obj)\
    OPC_ASSERT_MSG2(\
        objectcommon_is_proxy(COMMON(obj)),\
        __func__,\
        ": object given must be a proxy object"\
    )
#define CHECK_FULL_OR_PROXY(obj)\
    OPC_ASSERT_MSG2(\
        objectcommon_is_full(COMMON(obj)) || objectcommon_is_proxy(COMMON(obj)),\
        __func__,\
        ": object given must be a full object"\
    )

#endif /* OPC_OBJECT_DEF_H */

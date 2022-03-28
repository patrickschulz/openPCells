#include "object.h"

void postprocess_merge_shapes(object_t* object);
void postprocess_filter_include(object_t* object, const char** layernames, size_t len);
void postprocess_filter_exclude(object_t* object, const char** layernames, size_t len);

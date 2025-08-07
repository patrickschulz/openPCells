#ifndef RCREDUCER_BUFFER_H
#define RCREDUCER_BUFFER_H

#include <stddef.h>

struct buffer;

struct buffer* open_buffer(const char* filename);
void close_buffer(struct buffer* buffer);
int buffer_empty(struct buffer* buffer);
int buffer_get(struct buffer* buffer, char* ch);
size_t buffer_get_index(struct buffer* buffer);
void buffer_advance(struct buffer* buffer);

#endif /* RCREDUCER_BUFFER_H */

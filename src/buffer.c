#include "buffer.h"

#include <stdlib.h>
#include <stdio.h>

#define BUFFER_SIZE 1024

struct buffer {
    FILE* file;
    char* current;
    size_t index;
    size_t totalindex;
    size_t size;
    int empty;
};

static void _fill_buffer(struct buffer* buffer, size_t offset)
{
    size_t read = fread(buffer->current + offset, sizeof(char), BUFFER_SIZE - offset, buffer->file);
    buffer->index = 0;
    buffer->size = read;
    if(read == 0)
    {
        buffer->empty = 1;
    }
    else
    {
        buffer->empty = 0;
    }
}

struct buffer* open_buffer(const char* filename)
{
    struct buffer* buffer = malloc(sizeof(*buffer));
    buffer->file = fopen(filename, "r");
    if(!buffer->file)
    {
        return NULL;
    }
    buffer->current = malloc(BUFFER_SIZE * sizeof(*buffer->current));
    _fill_buffer(buffer, 0);
    buffer->totalindex = 0;
    return buffer;
}

void close_buffer(struct buffer* buffer)
{
    fclose(buffer->file);
    free(buffer->current);
    free(buffer);
}

int buffer_empty(struct buffer* buffer)
{
    return buffer->empty;
}

int buffer_get(struct buffer* buffer, char* ch)
{
    if(buffer->index >= buffer->size)
    {
        return 0;
    }
    *ch = buffer->current[buffer->index];
    return 1;
}

size_t buffer_get_index(struct buffer* buffer)
{
    return buffer->totalindex;
}

void buffer_advance(struct buffer* buffer)
{
    ++buffer->index;
    if(buffer->index > buffer->size - 1)
    {
        _fill_buffer(buffer, 0);
    }
    ++buffer->totalindex;
}


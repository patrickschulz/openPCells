#include "export_common.h"

#include <string.h>

static void _resize_data(struct export_data* data, size_t capacity)
{
    data->capacity = capacity;
    unsigned char* d = realloc(data->data, sizeof(char) * data->capacity);
    data->data = d;
}

struct export_data* export_create_data(void)
{
    struct export_data* data = malloc(sizeof(*data));
    data->data = NULL;
    data->length = 0;
    _resize_data(data, 1024);
    return data;
}

void export_destroy_data(struct export_data* data)
{
    free(data->data);
    free(data);
}

void export_data_append_byte(struct export_data* data, unsigned char byte)
{
    while(data->length + 1 > data->capacity)
    {
        _resize_data(data, data->capacity * 2);
    }
    data->data[data->length] = byte;
    data->length += 1;
}

void export_data_append_two_bytes(struct export_data* data, int16_t datum)
{
    while(data->length + 2 > data->capacity)
    {
        _resize_data(data, data->capacity * 2);
    }
    int8_t byte1 = datum >> 8;
    if(datum < 0)
    {
        byte1 += 256;
    }
    datum = datum - (byte1 << 8);
    int8_t byte2 = datum;
    data->data[data->length + 0] = byte1;
    data->data[data->length + 1] = byte2;
    data->length += 2;
}

void export_data_append_four_bytes(struct export_data* data, int32_t datum)
{
    while(data->length + 4 > data->capacity)
    {
        _resize_data(data, data->capacity * 2);
    }
    int8_t byte1 = datum >> 24;
    if(datum < 0)
    {
        byte1 += 256;
    }
    datum = datum - (byte1 << 24);
    int8_t byte2 = datum >> 16;
    datum = datum - (byte2 << 16);
    int8_t byte3 = datum >> 8;
    datum = datum - (byte3 << 8);
    int8_t byte4 = datum;
    data->data[data->length + 0] = byte1;
    data->data[data->length + 1] = byte2;
    data->data[data->length + 2] = byte3;
    data->data[data->length + 3] = byte4;
    data->length += 4;
}

void export_data_append_string(struct export_data* data, const char* str, size_t length)
{
    while(data->length + length > data->capacity)
    {
        _resize_data(data, data->capacity * 2);
    }
    memcpy(data->data + data->length, str, length);
    data->length += length;
}

struct export_functions* export_create_functions(void)
{
    struct export_functions* funcs = malloc(sizeof(*funcs));
    memset(funcs, 0, sizeof(*funcs));
    return funcs;
}

void export_destroy_functions(struct export_functions* funcs)
{
    free(funcs);
}

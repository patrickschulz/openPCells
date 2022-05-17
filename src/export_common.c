#include "export_common.h"

#include <string.h>

struct export_data {
    unsigned char* data;
    size_t length;
    size_t capacity;
};

static void _resize_data(struct export_data* data, size_t capacity)
{
    data->capacity = capacity;
    unsigned char* d = realloc(data->data, sizeof(char) * data->capacity);
    // FIXME: check return value
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

void export_data_append_nullbyte(struct export_data* data)
{
    export_data_ensure_additional_capacity(data, 1);
    data->data[data->length] = 0;
    data->length += 1;
}

void export_data_append_byte(struct export_data* data, unsigned char byte)
{
    export_data_ensure_additional_capacity(data, 1);
    data->data[data->length] = byte;
    data->length += 1;
}

void export_data_append_two_bytes(struct export_data* data, int16_t datum)
{
    export_data_ensure_additional_capacity(data, 2);
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
    export_data_ensure_additional_capacity(data, 4);
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
    export_data_ensure_additional_capacity(data, length);
    memcpy(data->data + data->length, str, length);
    data->length += length;
}

void export_data_ensure_additional_capacity(struct export_data* data, size_t num)
{
    unsigned int factor = 1;
    while((data->length + num) > (factor * data->capacity))
    {
        factor *= 2;
    }
    if(factor > 1)
    {
        _resize_data(data, data->capacity * factor);
    }
}

void export_data_append_nullbyte_unchecked(struct export_data* data)
{
    data->data[data->length] = 0;
    data->length += 1;
}

void export_data_append_byte_unchecked(struct export_data* data, unsigned char byte)
{
    data->data[data->length] = byte;
    data->length += 1;
}

void export_data_append_two_bytes_unchecked(struct export_data* data, int16_t datum)
{
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

void export_data_append_four_bytes_unchecked(struct export_data* data, int32_t datum)
{
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

void export_data_append_string_unchecked(struct export_data* data, const char* str, size_t length)
{
    memcpy(data->data + data->length, str, length);
    data->length += length;
}

void export_data_write_to_file(struct export_data* data, FILE* file)
{
    fwrite(data->data, 1, data->length, file);
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

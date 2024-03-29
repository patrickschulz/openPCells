#ifndef OPC_UTIL_H
#define OPC_UTIL_H

unsigned int util_num_digits(unsigned int n);
int util_match_string(const char* str, const char* match);
int util_split_string(const char* src, char delim, char** first, char** second);
void util_append_string(char* target, const char* str);
int util_file_exists(const char* path);
char* util_strdup(const char* str);
char* util_concat_path(const char* prefix, const char* suffix);

#define util_min(a, b) ((a) < (b) ? (a) : (b))
#define util_max(a, b) ((a) > (b) ? (a) : (b))

#endif // OPC_UTIL_H

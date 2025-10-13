/*
 * This program does a simple character-by-character comparison of two files.
 * If the content of both files are equal, the result is true, otherwise false.
 * If any of the files can't be opened, the result is also false.
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define BUFLEN 1024

int compare(const char* filename1, const char* filename2)
{
    char buf1[BUFLEN];
    char buf2[BUFLEN];
    FILE* file1 = fopen(filename1, "r");
    FILE* file2 = fopen(filename2, "r");
    if(!file1)
    {
        fprintf(stderr, "test_compare: could not open reference file '%s' \n", filename1);
        return 0;
    }
    if(!file2)
    {
        fclose(file1);
        fprintf(stderr, "test_compare: could not open test file '%s' \n", filename2);
        return 0;
    }
    int result = 1;
    while(1)
    {
        size_t read1 = fread(buf1, 1, BUFLEN, file1);
        size_t read2 = fread(buf2, 1, BUFLEN, file2);
        if(read1 == 0) // EOF
        {
            break;
        }
        if(read1 != read2)
        {
            result = 0;
            break;
        }
        for(size_t i = 0; i < read1; ++i)
        {
            if(buf1[i] != buf2[i])
            {
                result = 0;
                break;
            }
        }
    }
    if(file1)
    {
        fclose(file1);
    }
    if(file2)
    {
        fclose(file2);
    }
    return result;
}

int main(int argc, char** argv)
{
    if(argc < 2)
    {
        fputs("test_compare: no basename given\n", stderr);
        return 1;
    }
    if(argc < 3)
    {
        fputs("test_compare: no export type given\n", stderr);
        return 1;
    }
    const char* basename = argv[1];
    const char* exporttype = argv[2];
    char* filename1 = malloc(strlen(basename) + strlen("reference") + strlen("_") + strlen(".") + strlen(exporttype) + 1);
    char* filename2 = malloc(strlen(basename) + strlen("test") + strlen("_") + strlen(".") + strlen(exporttype) + 1);
    sprintf(filename1, "%s_%s.%s", "reference", basename, exporttype);
    sprintf(filename2, "%s_%s.%s", "test", basename, exporttype);
    int result = compare(filename1, filename2);
    free(filename1);
    free(filename2);
    return !result; // shells consider 0 success, everything else failure
}

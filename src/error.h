#ifndef OPC_ERROR_H
#define OPC_ERROR_H

typedef struct error_t {
    int status;
    char* message;
} error_t;

void error_clean(error_t* e);
error_t error_fail(void);
error_t error_success(void);
void error_set_failure(error_t* e);
void error_prepend(error_t* e , const char* message);
void error_add(error_t* e , const char* message);

#endif /* OPC_ERROR_H */

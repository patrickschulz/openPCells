#ifndef LROUTER_QUEUE_H
#define LROUTER_QUEUE_H

/*
 * taken from
 * https://de.wikibooks.org/wiki/Algorithmen_und_Datenstrukturen_in_C/
 * _Warteschlange
 */

#define SUCCESS 0
#define ERR_INVAL 1
#define ERR_NOMEM 2

#define FALSE 0
#define TRUE 1

typedef struct queue_s queue_t;

int queue_destroy(queue_t *queue);
int queue_empty(queue_t *queue);
queue_t *queue_new(void);
void *queue_dequeue(queue_t *queue);
int queue_enqueue(queue_t *queue, void *data);
int queue_len(queue_t *queue);

#endif

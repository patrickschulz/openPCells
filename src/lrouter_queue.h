#ifndef LROUTER_QUEUE_H
#define LROUTER_QUEUE_H

#include "lrouter_field.h"

/*
 * taken from
 * https://de.wikibooks.org/wiki/Algorithmen_und_Datenstrukturen_in_C/
 * _Warteschlange
 * Modified by Philipp nickel
 */

#define SUCCESS 0
#define ERR_INVAL 1
#define ERR_NOMEM 2

#define FALSE 0
#define TRUE 1

typedef struct queue_s queue_t;

struct queue_node_s {
	struct queue_node_s *next;
	void *data;
};

struct queue_s {
	struct queue_node_s *front;
	struct queue_node_s *back;
};

int queue_destroy(queue_t *queue);
int queue_empty(queue_t *queue);
queue_t *queue_new(void);
void *queue_dequeue(queue_t *queue);
int queue_enqueue(queue_t *queue, void *data);
int queue_len(queue_t *queue);
void queue_print(queue_t *queue);
void queue_reverse(queue_t *queue);
void *queue_peek_nth_elem(queue_t *queue, unsigned int n);

/* takes a queue and gives back the entries as a position_t array */
point_t *queue_as_array(queue_t *queue);

#endif

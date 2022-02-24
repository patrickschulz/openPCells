/*
 * taken from
 * https://de.wikibooks.org/wiki/Algorithmen_und_Datenstrukturen_in_C/
 * _Warteschlange
 */

#include "lrouter_queue.h"
#include "lrouter_field.h"

#include <stddef.h>
#include <stdio.h>
#include <stdlib.h>

struct queue_node_s {
	struct queue_node_s *next;
	void *data;
};

struct queue_s {
	struct queue_node_s *front;
	struct queue_node_s *back;
};

int queue_destroy(queue_t *queue)
{
	if (queue == NULL) {
		return ERR_INVAL;
	}
	while (queue->front != NULL) {
	    struct queue_node_s *node = queue->front;
	    queue->front = node->next;
	    free(node);
	}
	free(queue);
	return SUCCESS;
}

int queue_empty(queue_t *queue)
{
	  if (queue == NULL || queue->front == NULL) {
		return TRUE;
	  } else {
		return FALSE;
	  }
}

queue_t *queue_new(void)
{
	  queue_t *queue = malloc(sizeof(*queue));
	  if (queue == NULL) {
		return NULL;
	  }
	  queue->front = queue->back = NULL;
	  return queue;
}

void *queue_dequeue(queue_t *queue)
{
	  if (queue == NULL || queue->front == NULL) {
		return NULL;
	  }
	  struct queue_node_s *node = queue->front;
	  void *data = node->data;
	  queue->front = node->next;
	  if (queue->front == NULL) {
		queue->back = NULL;
	  }
	  free(node);
	  return data;
}

int queue_enqueue(queue_t *queue, void *data)
{
	  if (queue == NULL) {
		return ERR_INVAL;
	  }
	  struct queue_node_s *node = malloc(sizeof(*node));
	  if (node == NULL) {
		return ERR_NOMEM;
	  }
	  node->data = data;
	  node->next = NULL;
	  if (queue->back == NULL) {
		queue->front = queue->back = node;
	  } else {
		queue->back->next = node;
		queue->back = node;
	  }
	  return SUCCESS;
}

int queue_len(queue_t *queue)
{
	if(queue == NULL)
		return -1;
	if(queue->front == NULL)
		return 0;

	int count = 0;
	struct queue_node_s *node = queue->front;

	while(node->next != NULL)
	{
		node = node->next;
		count++;
	}

	return count;
}

void queue_print(queue_t *queue)
{
	if(queue == NULL)
		return;
	struct queue_node_s *node = queue->front;
	while(node != NULL)
	{
		point_t point = *(point_t*)node->data;
		printf("p: x %i, y %i, z %i\n", (int)point.x,
		       (int)point.y, (int)point.z);
		node = node->next;
	}

}

void queue_reverse(queue_t *queue)
{
	if(queue == NULL || queue->front == NULL)
		return;
	printf("pre reverse\n");
	queue_print(queue);

	struct queue_node_s *prev = NULL;
	struct queue_node_s *current = queue->front;
	struct queue_node_s *next = NULL;

	while(current != NULL)
	{
		next = current->next;
		current->next = prev;
		prev = current;
		current = next;
	}
	queue->front = prev;

	printf("post reverse\n");
	queue_print(queue);
}

/*
 * taken from
 * https://de.wikibooks.org/wiki/Algorithmen_und_Datenstrukturen_in_C/
 * _Warteschlange
 */

#include "lrouter_queue.h"
#include "lrouter_field.h"
#include "lrouter_net.h"

#include <stddef.h>
#include <stdio.h>
#include <stdlib.h>

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

void *queue_peek_nth_elem(queue_t *queue, unsigned int n)
{
	if (queue == NULL || queue->front == NULL ||
	    (unsigned int)queue_len(queue) < n) {
		return NULL;
	}
	struct queue_node_s *node = queue->front;
	unsigned int count = 0;

	while(node != NULL) {
		if (count == n)
			return node->data;
		node = node->next;
		count++;
	}

	return NULL;
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

	while(node != NULL)
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
}

point_t *queue_as_array(queue_t *queue)
{
	if(queue_len(queue) < 1)
	{
		printf("ERROR: queue_as_array got a 0 len array\n");
		return NULL;
	}

	point_t *arr = calloc(queue_len(queue), sizeof(point_t));
	int i = 0;
	struct queue_node_s *node = queue->front;

	while(node != NULL)
	{
		arr[i] = *(point_t *)node->data;
		printf("\n\nas array %i: %i, %i, %i\n", i, arr[i].x, arr[i].y,
		       arr[i].z);
		node = node->next;
		i++;
	}

	return arr;
}

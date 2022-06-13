/*
 * taken from
 * https://de.wikibooks.org/wiki/Algorithmen_und_Datenstrukturen_in_C/
 * _Warteschlange
 */

#include "lrouter_queue.h"

#include <stdlib.h>

struct queue_node {
	struct queue_node *next;
	void *data;
};

struct queue {
	struct queue_node *front;
	struct queue_node *back;
};

struct queue *queue_new(void)
{
    struct queue *queue = malloc(sizeof(*queue));
    queue->front = queue->back = NULL;
    return queue;
}

int queue_destroy(struct queue *queue)
{
    while(queue->front != NULL)
    {
        struct queue_node *node = queue->front;
        queue->front = node->next;
        free(node);
    }
    free(queue);
    return 1;
}

int queue_empty(struct queue *queue)
{
    return queue->front == NULL;
}

void queue_clear(struct queue *queue)
{
    while(queue->front != NULL)
    {
        struct queue_node *node = queue->front;
        queue->front = node->next;
        free(node);
    }
    queue->back = NULL;
}

void *queue_peek_nth_elem(struct queue *queue, unsigned int n)
{
    if (queue->front == NULL || (unsigned int)queue_len(queue) < n)
    {
        return NULL;
    }
    struct queue_node *node = queue->front;
    unsigned int count = 0;

    while(node != NULL) {
        if (count == n)
            return node->data;
        node = node->next;
        count++;
    }

    return NULL;
}

void *queue_dequeue(struct queue *queue)
{
    if(queue->front == NULL)
    {
        return NULL;
    }
    struct queue_node *node = queue->front;
    void *data = node->data;
    queue->front = node->next;
    if (queue->front == NULL)
    {
        queue->back = NULL;
    }
    free(node);
    return data;
}

int queue_enqueue(struct queue *queue, void *data)
{
    struct queue_node* node = malloc(sizeof(*node));
    if (node == NULL)
    {
        return 0;
    }
    node->data = data;
    node->next = NULL;
    if (queue->back == NULL)
    {
        queue->front = queue->back = node;
    }
    else
    {
        queue->back->next = node;
        queue->back = node;
    }
    return 1;
}

int queue_len(struct queue *queue)
{
    if(queue->front == NULL)
    {
        return 0;
    }

    int count = 0;
    struct queue_node *node = queue->front;

    while(node != NULL)
    {
        node = node->next;
        count++;
    }

    return count;
}

void queue_reverse(struct queue *queue)
{
    if(queue->front == NULL)
    {
        return;
    }

    struct queue_node *prev = NULL;
    struct queue_node *current = queue->front;
    struct queue_node *next = NULL;

    while(current != NULL)
    {
        next = current->next;
        current->next = prev;
        prev = current;
        current = next;
    }
    queue->front = prev;
}

point_t *queue_as_array(struct queue *queue)
{
    if(queue_len(queue) < 1)
    {
        return NULL;
    }

    point_t *arr = calloc(queue_len(queue), sizeof(*arr));
    int i = 0;
    struct queue_node *node = queue->front;

    while(node != NULL)
    {
        arr[i] = *(point_t *)node->data;
        free(node->data);
        node = node->next;
        i++;
    }
    return arr;
}

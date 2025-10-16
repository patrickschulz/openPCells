.PHONY: all
all: polygon.test
	@./polygon.test

polygon.test: polygon.c check.h check.c
	gcc -Wall -Wextra -I ../../ polygon.c check.c ../../src/polygon.c ../../src/vector.c ../../src/point.c -o polygon.test

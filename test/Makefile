.PHONY: all
all: helpers/test_compare
	@$(MAKE) -C full all

helpers/test_compare: helpers/test_compare.c
	@$(MAKE) -C helpers test_compare

.PHONY: clean
clean:
	@$(MAKE) -C helpers clean

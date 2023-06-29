opc: src/config.h src/*.c src/*.h src/scripts/*.lua src/modules/*.lua src/lua/*.c src/lua/*.h
	@$(MAKE) -C src default
	@mv src/opc .

opc.1: src/cmdoptions_def.c
	@$(MAKE) -C src opc.1
	mv src/opc.1 .

-include Makefile.install

.PHONY: doc
doc:
	@$(MAKE) -C doc full

.PHONY: clean
clean:
	@$(MAKE) -C src clean
	rm -f src/config.h
	rm -f opc
	rm -f opc.1
	rm -f Makefile.install

opc: src/*.c src/*.h src/scripts/*.lua src/modules/*.lua src/lua/*.c src/lua/*.h
	@echo '/* This file is auto-generated. Do not edit it. */' > src/config.h
	@echo '#define OPC_HOME "$(CURDIR)"' >> src/config.h
	@$(MAKE) -C src default
	@mv src/opc .

opc.1: src/cmdoptions_def.c
	@$(MAKE) -C src opc.1
	mv src/opc.1 .

.PHONY: doc
doc:
	@$(MAKE) -C doc full

.PHONY: clean
clean:
	@$(MAKE) -C src clean
	rm -f opc
	rm -f opc.1

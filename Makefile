opc: src/*.c src/*.h src/scripts/*.lua src/lua/*.c src/lua/*.h
	@echo '/* This file is auto-generated. Do not edit it. */' > src/config.h
	@echo '#define OPC_HOME "$(CURDIR)"' >> src/config.h
	@$(MAKE) -C src default
	@cp src/opc .

opc.1: opc src/cmdoptions.lua src/generate_manpage.lua
	./opc --script src/generate_manpage.lua > opc.1

.PHONY: clean
clean:
	@$(MAKE) -C src clean
	rm -f opc

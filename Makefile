opc: src/*
	@echo '/* This file is auto-generated. Do not edit it. */' > config.h
	@echo '#define OPC_HOME "$(CURDIR)"' >> src/config.h
	@$(MAKE) -C src default
	@cp src/opc .

opc.1: opc src/cmdoptions.lua src/generate_manpage.lua
	./opc --script src/generate_manpage.lua > opc.1

.PHONY: clean
clean:
	@$(MAKE) -C src clean

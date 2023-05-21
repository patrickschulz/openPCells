# NOTE: don't build in parallel (-j), as this created race conditions and might lead to weird errors

opc: src/config.h src/*.c src/*.h src/scripts/*.lua src/modules/*.lua src/lua/*.c src/lua/*.h
	@$(MAKE) -C src default
	@mv src/opc .

src/config.h:
	@echo '/* This file is auto-generated. Do not edit it. */' > src/config.h
	@echo '#define OPC_HOME "$(CURDIR)"' >> src/config.h

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

.PHONY: fixmes
fixmes:
	@grep --recursive FIXME src

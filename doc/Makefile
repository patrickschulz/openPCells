cells := ../cells/passive/capacitor/mom.lua ../cells/passive/inductor/octagonal.lua
documents := presentation.pdf userguide.pdf techdoc.pdf techfiles.pdf celldesign.pdf export.pdf

.PHONY: all
all: ${documents}

.PHONY: full
full:
	@$(MAKE) all
	rm ${documents}
	@$(MAKE) all
	rm ${documents}
	@$(MAKE) all

presentation.pdf: src/presentation/main.tex src/presentation/preamble.tex
	$(MAKE) -C src/presentation main.pdf
	mv src/presentation/main.pdf presentation.pdf

userguide.pdf: src/userguide/main.tex src/preamble.tex
	$(MAKE) -C src/userguide main.pdf
	mv src/userguide/main.pdf userguide.pdf

techdoc.pdf: src/techdoc/main.tex src/preamble.tex
	$(MAKE) -C src/techdoc main.pdf
	mv src/techdoc/main.pdf techdoc.pdf

celldesign.pdf: src/celldesign/main.tex src/preamble.tex ${cells} src/celldesign/code/*
	$(MAKE) -C src/celldesign main.pdf
	mv src/celldesign/main.pdf celldesign.pdf

techfiles.pdf: src/techfiles/main.tex src/preamble.tex
	$(MAKE) -C src/techfiles main.pdf
	mv src/techfiles/main.pdf techfiles.pdf

export.pdf: src/export/main.tex src/preamble.tex
	$(MAKE) -C src/export main.pdf
	mv src/export/main.pdf export.pdf

# in src directories
main.pdf:
	lualatex -shell-escape main.tex

.PHONY: clean
clean:
	$(MAKE) -C src/presentation clean
	$(MAKE) -C src/userguide clean
	$(MAKE) -C src/techdoc clean
	$(MAKE) -C src/celldesign clean
	$(MAKE) -C src/techfiles clean

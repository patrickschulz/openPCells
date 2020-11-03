cells := ../cells/passive/capacitor/mom.lua ../cells/passive/inductor/octagonal.lua
documents := userguide.pdf techdoc.pdf techfiles.pdf celldesign.pdf

.PHONY: all
all: ${documents}

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

# in src directories
main.pdf:
	lualatex -shell-escape main.tex

.PHONY: clean
clean:
	$(MAKE) -C userguide singleclean
	$(MAKE) -C techdoc singleclean
	$(MAKE) -C celldesign singleclean
	$(MAKE) -C techfiles singleclean

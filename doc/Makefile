cells := ../cells/momcap.lua ../cells/octagonal_inductor.lua

.PHONY: all
all: userguide/userguide.pdf techdoc/techdoc.pdf celldesign/celldesign.pdf techfiles/techfiles.pdf

userguide/userguide.pdf: userguide/userguide.tex preamble.tex
	$(MAKE) -C userguide all

techdoc/techdoc.pdf: techdoc/techdoc.tex preamble.tex
	$(MAKE) -C techdoc all

celldesign/celldesign.pdf: celldesign/celldesign.tex preamble.tex ${cells}
	$(MAKE) -C celldesign all

techfiles/techfiles.pdf: techfiles/techfiles.tex preamble.tex
	$(MAKE) -C techfiles all

.PHONY: clean
clean:
	$(MAKE) -C userguide clean
	$(MAKE) -C techdoc clean
	$(MAKE) -C celldesign clean
	$(MAKE) -C techfiles clean

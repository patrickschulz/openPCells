cells := ../cells/momcap.lua ../cells/octagonal_inductor.lua

.PHONY: all
all: userguide/userguide.pdf techdoc/techdoc.pdf celldesign/celldesign.pdf techfiles/techfiles.pdf

userguide/userguide.pdf: userguide/userguide.tex preamble.tex
	lualatex -output-directory userguide userguide/userguide.tex

techdoc/techdoc.pdf: techdoc/techdoc.tex preamble.tex
	lualatex -output-directory techdoc techdoc/techdoc.tex

celldesign/celldesign.pdf: celldesign/celldesign.tex preamble.tex ${cells}
	lualatex -output-directory celldesign celldesign/celldesign.tex

techfiles/techfiles.pdf: techfiles/techfiles.tex preamble.tex
	lualatex -output-directory techfiles techfiles/techfiles.tex

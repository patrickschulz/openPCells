cells := ../../cells/momcap.lua ../../cells/octagonal_inductor.lua

.PHONY: all
all: ${cells}
	lualatex -shell-escape celldesign.tex

.PHONY: clean
clean:
	rm -f celldesign.toc celldesign.log celldesign.aux 

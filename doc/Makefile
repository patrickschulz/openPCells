HTMLFILES:= \
	index.html \
	apiref.html \
	tutorials/beginner.html \
	guides.html \
	guides/pcells.html \
	guides/export.html \
	guides/user.html \
	guides/techfiles.html \
	guides/virtuoso.html

.PHONY: all
all: $(HTMLFILES) celldoc apirefs.js

.PHONY: clean
clean:
	@rm -f $(HTMLFILES)
	@rm -rf includes
	@rm -rf cells

.PHONY: celldoc
celldoc: ../src/create_cell_documentation
	@rm -rf celldoc cells.html cells.htmlpre
	@../src/create_cell_documentation cells.htmlpre cells
	@lua process_html.lua cells
	@find cells -name '*.htmlpre' -exec sh -c 'lua process_html.lua $${1/.htmlpre/}' sh {} \;

apirefs.js:

../src/create_cell_documentation:
	@$(MAKE) -C ../src create_cell_documentation

%.html: %.htmlpre includes/footer.html
	@lua process_html.lua $*

includes/footer.html: ../src/version.h
	@gcc create_footer.c -o create_footer
	@./create_footer
	@rm create_footer

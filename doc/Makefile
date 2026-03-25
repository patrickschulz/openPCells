HTMLFILES:= \
	index.html \
	cells.html \
	apiref.html \
	guides.html \
	guides/export.html \
	guides/user.html \
	guides/techfiles.html \
	guides/virtuoso.html

.PHONY: all
all: $(HTMLFILES) apirefs.js

.PHONY: clean
clean:
	@rm -f $(HTMLFILES)
	@rm -rf includes

.PHONY: celldoc
celldoc: ../src/create_cell_documentation
	../src/create_cell_documentation cells

apirefs.js:

../src/create_cell_documentation:
	@$(MAKE) -C ../src create_cell_documentation

%.html: %.htmlpre includes/footer.html
	@lua process_html.lua $*

includes/footer.html: ../src/version.h
	@gcc create_footer.c -o create_footer
	@./create_footer
	@rm create_footer

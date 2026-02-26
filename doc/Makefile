HTMLFILES:= \
	index.html \
	cells.html \
	apiref.html \
	guides.html \
	guides/export.html \
	guides/user.html \
	guides/techfiles.html

.PHONY: all
all: $(HTMLFILES) apirefs.js

.PHONY: clean
clean:
	@rm -f $(HTMLFILES)

.PHONY: celldoc
celldoc: ../src/create_cell_documentation
	../src/create_cell_documentation cells

apirefs.js:

../src/create_cell_documentation:
	@$(MAKE) -C ../src create_cell_documentation

%.html: %.htmlpre includes/footer.html
	@lua process_html.lua $*

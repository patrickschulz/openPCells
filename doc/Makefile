HTMLFILES:= \
	index.html \
	cells.html \
	apiref.html \
	guides.html \
	guides/export.html \
	guides/user.html \
	guides/techfiles.html \
	cells/routing/bus.html

.PHONY: all
all: $(HTMLFILES)

.PHONY: clean
clean:
	@rm -f $(HTMLFILES)

%.html: %.htmlpre includes/footer.html
	@lua process_html.lua $*

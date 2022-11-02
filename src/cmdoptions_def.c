/* Main Generation Functions */
cmdoptions_add_section(cmdoptions, "Main generation functions");
cmdoptions_add_option(cmdoptions, 'T', "technology", SINGLE_ARG, "specify technology");
cmdoptions_add_option(cmdoptions, 'C', "cell", SINGLE_ARG, "specify cell");
cmdoptions_add_option(cmdoptions, 'E', "export", MULTI_ARGS, "specify export type (multiple arguments possible). Some export types re-use layer data defined for other export types (for example, GDSII and OASIS layer/purpose pairs often use the same data). It is possible to specify the used data by prefixing it separated with a colon (':') -> 'gds:oasis' uses the GDSII layers for the oasis export type. While it is possible to use something like 'gds:gds', this is not needed.");
//cmdoptions_add_option(cmdoptions, NO_SHORT, "export-layers", SINGLE_ARG, "specify which layer data from the technology layer map is given to the export. If this matches the name of the export (e.g. gds and gds) then this option is not needed. It is only useful if an export uses layer definition intended for another export (e.g. magic and SKILL)");
cmdoptions_add_option(cmdoptions, 'X', "export-options", MULTI_ARGS, "pass special options to export. This passes the next argument (separated by white space) literally. This means that several arguments have to be grouped, usually by enclosing it in quotations marks (e.g. -X '--foo --bar'). An overview of the available options for the respective export can be found by passing -h, e.g. opc --export gds -X -h");
cmdoptions_add_option(cmdoptions, 'c', "cellscript", SINGLE_ARG, "execute cell script. With this option, --cell is not needed to create a layout. The layout described in the cell script is generated, so the called file must return an object.");
cmdoptions_add_option(cmdoptions, NO_SHORT, "cellscript-args", MULTI_ARGS, "pass arguments to cellscripts (use with --cellscript). Can be called multiple times");
cmdoptions_add_option(cmdoptions, NO_SHORT, "cell-environment", SINGLE_ARG, "read cell environment from the given file");

/* Auxiliary Generation Functions */
cmdoptions_add_section(cmdoptions, "Auxiliary generation functions");
cmdoptions_add_option_default(cmdoptions, 'n', "cellname", SINGLE_ARG, "opctoplevel", "export toplevel cell name. Not all exports support a cell name.");
cmdoptions_add_option(cmdoptions, NO_SHORT, "flat", NO_ARG, "flatten hierarchy before exporting. This is only necessary if the selected export supports hierarchies. Otherwise this option is applied anyway");
cmdoptions_add_option(cmdoptions, NO_SHORT, "flatten-ports", NO_ARG, "include ports in hierarchy flattening. Can lead to confusing results, especially in large hierarchies. Mostly useful for layout debugging");
cmdoptions_add_option(cmdoptions, NO_SHORT, "bus-delimiters", SINGLE_ARG, "delimiters for bus ports. Useful values: '[]' or '<>', but others are possible. This option expects two characters for the left and right delimiters");
cmdoptions_add_option(cmdoptions, NO_SHORT, "techpath", MULTI_ARGS, "add (append) searchpath for technology files (can be used multiple times: --techpath foo --techpath bar)");
cmdoptions_add_option(cmdoptions, NO_SHORT, "prepend-parameter-file", MULTI_ARGS, "file to read parameters from (prepended to the list). This file should be a regular lua file returning a table with the parameters. This option can be used multiple times. Parameter files that are specified later overwrite parameters from earlier files.");
cmdoptions_add_option(cmdoptions, NO_SHORT, "append-parameter-file", MULTI_ARGS, "file to read parameters from (appended to the list). This file should be a regular lua file returning a table with the parameters. This option can be used multiple times. Parameter files that are specified later overwrite parameters from earlier files.");
cmdoptions_add_alias(cmdoptions, "append-parameter-file", 'p', "pfile", "synonym for --append-parameter-file");
cmdoptions_add_option(cmdoptions, NO_SHORT, "disable-pfile", NO_ARG, "disable reading of any parameter files");
cmdoptions_add_option_default(cmdoptions, 'f', "filename", SINGLE_ARG, "openPCells", "specify output filename for export. The name should be specified without an extension (such as '.gds'), as the export types add their specific extension to the filename, this is especially useful when using more than one export type");
cmdoptions_add_option(cmdoptions, NO_SHORT, "origin", SINGLE_ARG, "origin of cell (move (0, 0)). This option expects a point input, e.g. '(10, 10)' (with parantheses)");
cmdoptions_add_option(cmdoptions, NO_SHORT, "translate", SINGLE_ARG, "move cell by (x, y). This option expects a point input, e.g. '(10, 10)' (with parantheses)");
cmdoptions_add_option(cmdoptions, NO_SHORT, "orientation", SINGLE_ARG, "orientation of cell (possible values: 0 (regular), fx (flip x), fy (flip y), fxy (flip x and y))");
cmdoptions_add_option(cmdoptions, NO_SHORT, "scale", SINGLE_ARG, "scale factor for all shapes");
cmdoptions_add_option(cmdoptions, NO_SHORT, "write-children-ports", NO_ARG, "export ports of sub cells. Depending on what you do with the generated layouts this could possible break a clean LVS (possible szenario: importing a SKILL representation of a layout hierarchy. Since the SKILL export creates a flat layout, sub-level ports now become top-level ports, which is almost certainly wrong.)");
cmdoptions_add_option(cmdoptions, NO_SHORT, "append-cellpath", MULTI_ARGS, "append searchpath for cells (can be used multiple times: --append-cellpath foo --append-cellpath bar)");
cmdoptions_add_option(cmdoptions, NO_SHORT, "prepend-cellpath", MULTI_ARGS, "prepend searchpath for cells (can be used multiple times: --prepend-cellpath foo --prepend-cellpath bar)");
cmdoptions_add_alias(cmdoptions, "append-cellpath", NO_SHORT, "cellpath", "synonym for --append-cellpath");
cmdoptions_add_option(cmdoptions, NO_SHORT, "filter-layers", MULTI_ARGS, "filter layers to be generated. Any layer (in generic notation) in this list will not be generated. This option can be called multiple times. The effect of this options is also controlled by --filter-list. This filter is installed BEFORE technology translation, so the layers must be specified in generic notation (e.g. M1 or contactsourcedrain).");
cmdoptions_add_option_default(cmdoptions, NO_SHORT, "filter-list", SINGLE_ARG, "exclude", "set filter list type (include or exclude, default exclude)");
cmdoptions_add_option(cmdoptions, NO_SHORT, "export-filter", MULTI_ARGS, "filter exported data. Possible values: rectangle, polygon, reference, link. This option can be called multiple times. The effect of this options is also controlled by --export-filter-list.");
cmdoptions_add_option_default(cmdoptions, NO_SHORT, "export-filter-list", SINGLE_ARG, "exclude", "set export filter list type (include or exclude, default exclude)");
cmdoptions_add_option(cmdoptions, NO_SHORT, "ignore-missing-layers", NO_ARG, "ignore missing layers in the technology translation. Layers that are not present in the layermap file are handled as if their values was '{}'");
cmdoptions_add_option(cmdoptions, NO_SHORT, "ignore-missing-export", NO_ARG, "ignore layers with missing exports in the technology translation");
cmdoptions_add_option(cmdoptions, NO_SHORT, "disable-gatecut", NO_ARG, "disable gatecut (only useful for technologies that support gate cuts)");
cmdoptions_add_option(cmdoptions, NO_SHORT, "merge-rectangles", NO_ARG, "merge rectangles");
cmdoptions_add_option(cmdoptions, NO_SHORT, "resolve-paths", NO_ARG, "resolve paths to rectangles and polygons");
cmdoptions_add_option(cmdoptions, NO_SHORT, "rasterize-curves", NO_ARG, "rasterize curves");
cmdoptions_add_option(cmdoptions, NO_SHORT, "triangulate-polygons", NO_ARG, "triangulate all polygons");
cmdoptions_add_option(cmdoptions, NO_SHORT, "disable-via-arrayzation", NO_ARG, "don't create via arrays, instead create single large via regions (useful for EM simulations)");
cmdoptions_add_option(cmdoptions, NO_SHORT, "separator", SINGLE_ARG, "cell parameter separator (default \\n)");
cmdoptions_add_option(cmdoptions, NO_SHORT, "seed", SINGLE_ARG, "set seed for random functions for reproducible layout generation. Random functions are mostly used in digital place & route functions, but also in some cells");

/* Layout Debugging */
cmdoptions_add_section(cmdoptions, "Layout debugging functions");
cmdoptions_add_option(cmdoptions, NO_SHORT, "draw-anchor", MULTI_ARGS, "draw a cell anchor. It is drawn in the 'special' layer, so your layermap needs to have an entry for that.");
cmdoptions_add_option(cmdoptions, NO_SHORT, "draw-all-anchors", NO_ARG, "draw all cell anchors. They are drawn in the 'special' layer, so your layermap needs to have an entry for that.");
cmdoptions_add_option(cmdoptions, NO_SHORT, "draw-alignmentbox", NO_ARG, "draw the alignment box (if present). The box is drawn in the 'special' layer, so your layermap needs to have an entry for that.");
cmdoptions_add_option(cmdoptions, NO_SHORT, "draw-all-alignmentboxes", NO_ARG, "draw all present alignment box (also those of subcells). The box is drawn in the 'special' layer, so your layermap needs to have an entry for that.");
cmdoptions_add_option(cmdoptions, NO_SHORT, "enable-dprint", NO_ARG, "enables debugging print statements in cell layout definitions");
cmdoptions_add_option(cmdoptions, NO_SHORT, "debug-cell", NO_ARG, "show detailed cell debugging call stack");

/* Miscellaneous Functions */
cmdoptions_add_section(cmdoptions, "Miscellaneous functions");
cmdoptions_add_option(cmdoptions, NO_SHORT, "no-user-config", NO_ARG, "don't load the user config");
cmdoptions_add_option(cmdoptions, 'w', "watch", NO_ARG, "start 'watch' mode. This continuously monitors the specified cell and regenerates the layout upon changes in the file.");

/* Generator Functions (Import) */
cmdoptions_add_section(cmdoptions, "Layout import functions");
cmdoptions_add_option(cmdoptions, NO_SHORT, "read-gds", SINGLE_ARG, "read a GDS stream file and export all cells as opc-compatible code. This can take some time, depending on the size of the stream file");
cmdoptions_add_option(cmdoptions, NO_SHORT, "gds-layermap", SINGLE_ARG, "provide a layermap for GDS stream reading to enable different export types for read cells");
cmdoptions_add_option(cmdoptions, NO_SHORT, "gds-ignore-lpp", MULTI_ARGS, "layer-purpose-pairs to be ignored during gds import. Separate layers and purposes with a colon (:)");
cmdoptions_add_option(cmdoptions, NO_SHORT, "import-prefix", SINGLE_ARG, "specifies a directory in which imported cells will be placed. For example, if --read-gds FOO and --import-prefix BAR is given, the imported cells will reside in BAR/FOO/*.lua");
cmdoptions_add_option(cmdoptions, NO_SHORT, "import-libname", SINGLE_ARG, "specify the name of the opc library name. If this option is not given, the filename from the import file is taken");
cmdoptions_add_option(cmdoptions, NO_SHORT, "import-flatten-cell-pattern", SINGLE_ARG, "pattern for cells that should be flattened in a hierarchy during import");
cmdoptions_add_option(cmdoptions, NO_SHORT, "import-name-pattern", SINGLE_ARG, "lua pattern to string.match to filter/rename cells. Every cell name is run through this matching and the first capture is used as cell name. The default is (.+), so the entire string is used.");
cmdoptions_add_option(cmdoptions, NO_SHORT, "gds-alignmentbox-layer", SINGLE_ARG, "provide a layer number to write an alignment box to generated cells");
cmdoptions_add_option(cmdoptions, NO_SHORT, "gds-alignmentbox-purpose", SINGLE_ARG, "provide a layer purpose to write an alignment box to generated cells");
cmdoptions_add_option(cmdoptions, NO_SHORT, "gds-use-libname", NO_ARG, "use the library name of the gds file for the resulting opc library");
cmdoptions_add_option(cmdoptions, NO_SHORT, "import-overwrite", NO_ARG, "overwrite files while importing. This does not check whether these overwritten files are from a previous import or something else, so use this option with caution. This option does NOT cause any overwriting or deletion of files that are present and not generated by the import, so it can be used to add cells to an already existing library, but no safety checks are done");
cmdoptions_add_option(cmdoptions, NO_SHORT, "import-verilog", SINGLE_ARG, "import a verilog gate netlist (the parser only handles a very simple subset of verilog, RTL and such things won't work) and generate a pcell skeleton with all cells and connections (ALPHA STAGE, NOT TESTED EXHAUSTIVELY). This option expects a filename for a script which handles the import");
cmdoptions_add_option(cmdoptions, NO_SHORT, "techfile-assistant", NO_ARG, "start the techfile assistant for easy creation of technology files");

/* Info Functions */
cmdoptions_add_section(cmdoptions, "Info functions");
cmdoptions_add_option(cmdoptions, 'P', "parameters", NO_ARG, "display available cell parameters and exit (requires --cell)");
cmdoptions_add_option(cmdoptions, NO_SHORT, "parameters-format", SINGLE_ARG, "format for listing parameters. The following formats are recognized: %t: parameter type, %n: parameter name, %d: parameter display name, %v: parameter value, %a: parameter argument type, %r: parameter is read-only (true/false), %p: parent cell. The default is %n (%d) %v");
cmdoptions_add_option(cmdoptions, NO_SHORT, "constraints", NO_ARG, "show required technology parameter (requires --cell and --technology)");
cmdoptions_add_option(cmdoptions, 'L', "list", NO_ARG, "list available cells");
cmdoptions_add_option(cmdoptions, NO_SHORT, "list-format", SINGLE_ARG, "format for listing cells. The following format is recognized: prefmt:postfmt:prepathfmt:postpathfmt:prebasefmt:postbasefmt:cellfmt. The default is '::%p\\n::  %b\\n::    %c\\n'. A possible format for creating a nested list (e.g. for lisp) would be 'list(\\n:)\\n:::list(\"%b\" list(:))\\n:\"%c\"'");
cmdoptions_add_option(cmdoptions, NO_SHORT, "list-all", NO_ARG, "list all available cells (including hidden cells)");
cmdoptions_add_option(cmdoptions, NO_SHORT, "list-no-directories", NO_ARG, "don't list parent directories when listing available cells");
cmdoptions_add_option(cmdoptions, NO_SHORT, "listcellpaths", NO_ARG, "list cell search paths");
cmdoptions_add_option(cmdoptions, NO_SHORT, "listtechpaths", NO_ARG, "list technology search paths");
cmdoptions_add_option(cmdoptions, NO_SHORT, "api-help", SINGLE_ARG, "display help about an API function or module");

/* Utility Functions */
cmdoptions_add_section(cmdoptions, "Utility functions");
cmdoptions_add_option(cmdoptions, NO_SHORT, "show-gds-data", SINGLE_ARG, "show data in a GDS stream file");
cmdoptions_add_option(cmdoptions, NO_SHORT, "show-gds-cell-hierarchy", SINGLE_ARG, "show cell hierarchy in a GDS stream file");
cmdoptions_add_option_default(cmdoptions, NO_SHORT, "show-gds-depth", SINGLE_ARG, "1000", "maximum depth for gds traversal (affects --show-gds-data and --show-gds-hierarchy)");
cmdoptions_add_option_default(cmdoptions, NO_SHORT, "show-gds-data-flags", MULTI_ARGS, "all", "flags to control what data is shown with --show-gds-data (default: all)");
cmdoptions_add_option(cmdoptions, NO_SHORT, "show-gds-data-raw", NO_ARG, "also print the raw stream data after the parsed data");

/* Diagnostic Functions */
cmdoptions_add_section(cmdoptions, "Diagnostic functions");
cmdoptions_add_option(cmdoptions, NO_SHORT, "show-cellinfo", NO_ARG, "show some cell information: shape count, used layers, etc.");
cmdoptions_add_option(cmdoptions, NO_SHORT, "profile", NO_ARG, "collect and display profiling data (this significantly increases run time, be patient while profiling larger cells)");
cmdoptions_add_option(cmdoptions, 'V', "verbose", NO_ARG, "enable verbose output");
cmdoptions_add_option(cmdoptions, 'D', "debug", NO_ARG, "enable debugging output");
cmdoptions_add_option(cmdoptions, NO_SHORT, "check", NO_ARG, "check cell code and parameter variations. Strict checking, e.g. if a cell parameter can not work with odd values, specify the parameter as even()");
cmdoptions_add_option(cmdoptions, NO_SHORT, "check-technology", NO_ARG, "check technology layer map and config. (not implemented)");
cmdoptions_add_option(cmdoptions, NO_SHORT, "noexport", NO_ARG, "disable all export functions. This is different from --dryrun, which calls the export translation, but does not write any files. Both options are mostly related to profiling, if exporting should be profiled --dryrun must be used");
cmdoptions_add_option(cmdoptions, NO_SHORT, "dryrun", NO_ARG, "perform all calculations, but don't actually write any files. This is useful for profiling, where the program should run normally but should not produce any output");
cmdoptions_add_option(cmdoptions, 'v', "version", NO_ARG, "display version");
cmdoptions_add_option(cmdoptions, 'h', "help", NO_ARG, "display help");
cmdoptions_add_option(cmdoptions, NO_SHORT, "stderr-to", SINGLE_ARG, "redirect standard error to the given file (will be overwritten)");

/* Help Header */
cmdoptions_prepend_help_message(cmdoptions, "openPCells layout generator (opc) - Patrick Kurth 2020 - 2022");
cmdoptions_prepend_help_message(cmdoptions, "");
cmdoptions_prepend_help_message(cmdoptions, "Generate layouts of integrated circuit geometry");
cmdoptions_prepend_help_message(cmdoptions, "opc supports technology-independent descriptions of parametric layout cells (pcells),");
cmdoptions_prepend_help_message(cmdoptions, "which can be translated into a physical technology and exported to a file via a specific export.");

/* Help Footer */
cmdoptions_append_help_message(cmdoptions, "");
cmdoptions_append_help_message(cmdoptions, "Most common usage examples:");
cmdoptions_append_help_message(cmdoptions, "   get cell parameter information:             opc --cell stdcells/dff --parameters");
cmdoptions_append_help_message(cmdoptions, "   create a cell:                              opc --technology TECH --export gds --cell stdcells/dff");
cmdoptions_append_help_message(cmdoptions, "   create a cell from a foreign collection:    opc --cellpath /path/to/collection --technology TECH --export gds --cell other/somecell");
cmdoptions_append_help_message(cmdoptions, "   create a cell by using a cellscript:        opc --technology TECH --export gds --cellscript celldef.lua");
cmdoptions_append_help_message(cmdoptions, "   read a GDS stream file and create cells:    opc --read-GDS stream.gds");

// vim: nowrap

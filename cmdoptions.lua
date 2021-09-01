return {
    section("Main generation functions"),
    store{ 
        name = "technology", short = "-T", long = "--technology",
        help = "specify technology"
    },
    store{ 
        name = "cell", short = "-C", long = "--cell",
        help = "specify cell"
    },
    store{ 
        name = "export", short = "-E", long = "--export",
        help = "specify export type"
    },
    store_multiple_string{ 
        name = "export_options", short = "-X", long = "--xopts",
        help = "pass special options to export. This passes the next argument (separated by white space) literally. This means that several arguments have to be grouped, usually by enclosing it in quotations marks (e.g. -X '--foo --bar'). An overview of the available options for the respective export can be found by passing -h, e.g. opc --export gds -X -h"
    },
    store{
        name = "cellscript", short = "-c", long = "--cellscript",
        help = "execute cell script. With this option, --cell is not needed to create a layout. The layout described in the cell script is generated, so the called file must return an object."
    },
    section("Auxiliary generation functions"),
    store{
        name = "toplevelname", short = "-n", long = "--cellname",
        help = "export toplevel cell name. Not all exports support a cell name."
    },
    switch{
        name = "flatten", long = "--flat",
        help = "flatten hierarchy before exporting. This is only necessary if the selected export supports hierarchies. Otherwise this option is applied anyway"
    },
    store_multiple{
        name = "techpath", long = "--techpath",
        help = "add (append) searchpath for technology files (can be used multiple times: --techpath foo --techpath bar)"
    },
    store_multiple{ 
        name = "appendparamfile", short = "-p", long = "--pfile",
        help = "synonym for --append-parameter-file"
    },
    store_multiple{ 
        name = "prependparamfile", long = "--prepend-parameter-file",
        help = "file to read parameters from (prepended to the list). This file should be a regular lua file returning a table with the parameters. This option can be used multiple times. Parameter files that are specified later overwrite parameters from earlier files."
    },
    store_multiple{ 
        name = "appendparamfile", long = "--append-parameter-file",
        help = "file to read parameters from (appended to the list). This file should be a regular lua file returning a table with the parameters. This option can be used multiple times. Parameter files that are specified later overwrite parameters from earlier files."
    },
    switch{
        name = "noparamfile", long = "--disable-pfile",
        help = "disable reading of any parameter files"
    },
    store{ 
        name = "filename", short = "-f", long = "--filename",
        help = "specify output filename for export"
    },
    consumer_string{ 
        name = "origin", long  = "--origin",
        help = "origin of cell (move (0, 0)). This option expects a point input, e.g. '(10, 10)' (with parantheses)"
    },
    consumer_string{ 
        name = "translate", long  = "--translate",
        help = "move cell by (x, y). This option expects a point input, e.g. '(10, 10)' (with parantheses)"
    },
    consumer_string{ 
        name = "orientation", long  = "--orientation",
        help = "orientation of cell (possible values: 0 (regular), fx (flip x), fy (flip y), fxy (flip x and y))"
    },
    store_multiple{
        name = "cellpath", long = "--append-cellpath",
        help = "append searchpath for cells (can be used multiple times: --append-cellpath foo --append-cellpath bar)"
    },
    store_multiple{
        name = "prependcellpath", long = "--prepend-cellpath",
        help = "prepend searchpath for cells (can be used multiple times: --prepend-cellpath foo --prepend-cellpath bar)"
    },
    store_multiple{
        name = "cellpath", long = "--cellpath",
        help = "synonym for --append-cellpath"
    },
    store_multiple{
        name = "prelayerfilter", long = "--pre-filter",
        help = "filter layers to be generated. Any layer (in generic notation) in this list will not be generated. This option can be called multiple times. The effect of this options is also controlled by --pre-filter-list. This filter is installed BEFORE technology translation, so the layers must be specified in generic notation (e.g. M1 or contactsourcedrain).",
    },
    store{
        name = "prelayerfilterlist", long = "--pre-filter-list",
        help = "set pre-technology-translation filter list type (white or black, default black)"
    },
    store_multiple{
        name = "postlayerfilter", long = "--post-filter",
        help = "filter layers to be generated. Any layer (in generic notation) in this list will not be generated. This option can be called multiple times. The effect of this options is also controlled by --post-filter-list. This filter is installed AFTER technology translation, so the layers must be specified in technology-specific notation.",
    },
    store{
        name = "postlayerfilterlist", long = "--post-filter-list",
        help = "set post-technology-translation filter list type (white or black, default black)"
    },
    store_multiple{
        name = "exportfilter", long = "--export-filter",
        help = "filter exported data. Possible values: rectangle, polygon, reference, link. This option can be called multiple times. The effect of this options is also controlled by --export-filter-list.",
    },
    store{
        name = "exportfilterlist", long = "--export-filter-list",
        help = "set export filter list type (white or black, default black)"
    },
    switch{
        name = "ignoremissinglayers", long = "--ignore-missing-layers",
        help = "ignore missing layers in the technology translation. Layers that are not present in the layermap file are handled as if their values was '{}'",
    },
    switch{
        name = "ignoremissingexport", long = "--ignore-missing-export",
        help = "ignore layers with missing exports in the technology translation"
    },
    switch{
        name = "mergerectangles", long = "--merge-rectangles",
        help = "merge rectangles"
    },
    switch{
        name = "human", short = "-H", long = "--human",
        help = "format info output (parameters, cell lists etc.) for humans"
    },
    switch{
        name = "machine", short = "-M", long = "--machine",
        help = "format info output (parameters, cell lists etc.) for machines (computer). Use this for parsing the data for interfaces"
    },
    store{ 
        name = "separator", long = "--separator",
        help = "cell parameter separator (default \\n)"
    },
    store{
        name = "seed", long = "--seed",
        help = "set seed for random functions for reproducible layout generation"
    },
    section("Layout debugging functions"),
    switch{
        name = "drawaxes", long = "--draw-axes",
        help = "draw axes. They are drawn in the 'special' layer, so your layermap needs to have an entry for that."
    },
    store_multiple{
        name = "drawanchor", long = "--draw-anchor",
        help = "draw a cell anchor. It is drawn in the 'special' layer, so your layermap needs to have an entry for that."
    },
    switch{
        name = "drawalignmentbox", long = "--draw-alignmentbox",
        help = "draw the alignment box (if present). The box is drawn in the 'special' layer, so your layermap needs to have an entry for that."
    },
    switch{
        name = "debugcell", long = "--debug-cell",
        help = "enables debugging print statements in cell layout definitions"
    },
    section("Miscellaneous functions"),
    switch{
        name = "nouserconfig", long = "--nouserconfig",
        help = "don't load the user config"
    },
    store{
        name = "script", short = "-S", long = "--script",
        help = "execute arbitrary script. This can be used to run lua code with the opc API loaded. If a cell is generated in this file, --cellscript is recommended, as then no manual technology/export/etc. loading is necessary."
    },
    switch{
        name = "watch", short = "-w", long = "--watch",
        help = "start 'watch' mode. This continuously monitors the specified cell and regenerates the layout upon changes in the file."
    },
    store{
        name = "readgds", long = "--read-gds",
        help = "read a GDS stream file and export all cells as opc-compatible code. This can take some time, depending on the size of the stream file"
    },
    store{
        name = "gdslayermap", long = "--gds-layermap",
        help = "provide a layermap for GDS stream reading to enable different export types for read cells"
    },
    store{
        name = "importprefix", long = "--import-prefix",
        help = "specifies a directory in which imported cells will be placed. For example, if --read-gds FOO and --import-prefix BAR is given, the imported cells will reside in BAR/FOO/*.lua"
    },
    store{
        name = "gdsalignmentboxlayer", long = "--gds-alignmentbox-layer",
        help = "provide a layer number to write an alignment box to generated cells"
    },
    store{
        name = "gdsalignmentboxpurpose", long = "--gds-alignmentbox-purpose",
        help = "provide a layer purpose to write an alignment box to generated cells"
    },
    switch{
        name = "gdsusestreamlibname", long = "--gds-use-libname",
        help = "use the library name of the gds file for the resulting opc library. The default behaviour is to use the name of the stream file."
    },
    switch{
        name = "gdsusefilename", long = "--gds-use-filename",
        help = "Use the name of the stream file as opc library name. This is the opposite of --gds-use-libname and the default, so this option exists only for explicitness. This option overrules --gds-use-libname"
    },
    switch{
        name = "importoverwrite", long = "--import-overwrite",
        help = "overwrite files while importing. This does not check whether these overwritten files are from a previous import or something else, so use this option with caution"
    },
    section("Info functions"),
    switch{ 
        name = "params", short = "-P", long  = "--parameters",
        help = "display available cell parameters and exit (requires --cell)"
    },
    store{
        name = "parametersformat", long = "--parameters-format",
        help = "format for listing parameters. The following formats are recognized: %t: parameter type, %n: parameter name, %d: parameter display name, %v: parameter value, %a: parameter argument type, %r: parameter is read-only (true/false). The default is %n (%d) %v"
    },
    switch{ 
        name = "constraints", long  = "--constraints",
        help = "show required technology parameter (requires --cell and --technology)"
    },
    switch{ 
        name = "listcells", short = "-L", long  = "--list",
        help = "list available cells"
    },
    store{
        name = "listformat", long = "--list-format",
        help = "format for listing cells. The following format is recognized: prefmt:postfmt:prepathfmt:postpathfmt:prebasefmt:postbasefmt:cellfmt. The default is '::%p\\n::  %b\\n::    %c\\n. A possible format for creating a nested list (e.g. for lisp) would be list(\\n:)\\n:::list(\"%b\" list(:))\\n:\"%c\""
    },
    switch{ 
        name = "listallcells", long  = "--list-all",
        help = "list all available cells (including hidden cells)"
    },
    switch{
        name = "listnodirectories", long = "--list-no-directories",
        help = "don't list parent directories when listing available cells"
    },
    switch{
        name = "listcellpaths", long = "--listcellpaths",
        help = "list cell search paths"
    },
    switch{
        name = "listtechpaths", long = "--listtechpaths",
        help = "list technology search paths"
    },
    section("Utility functions"),
    store{
        name = "showgdsdata", long = "--show-gds-data",
        help = "show data in a GDS stream file"
    },
    store{
        name = "showgdshierarchy", long = "--show-gds-cell-hierarchy",
        help = "show cell hierarchy in a GDS stream file"
    },
    store_multiple{
        name = "showgdsdataflags", long = "--show-gds-data-flags",
        help = "flags to control what data is shown with --show-gds-data (default: all)"
    },
    store_multiple{
        name = "showgdsdataraw", long = "--show-gds-data-raw",
        help = "also print the raw stream data after the parsed data"
    },
    section("Diagnostic functions"),
    switch{
        name = "cellinfo", long = "--show-cellinfo",
        help = "show some cell information: shape count, used layers, etc."
    },
    switch{
        name = "profile", long  = "--profile",
        help = "collect and display profiling data (this significantly increases run time, be patient while profiling larger cells)"
    },
    switch{ 
        name = "verbose", short = "-V", long = "--verbose",
        help = "enable verbose output"
    },
    switch{ 
        name = "debug", short = "-D", long = "--debug",
        --help = "enable debugging output (specify modules separated by commas)"
        help = "enable debugging output",
    },
    switch{ 
        name = "check", long = "--check",
        help = "check cell code and parameter variations. Strict checking, e.g. if a cell parameter can not work with even values, specify the parameter as even()"
    },
    switch{ 
        name = "checktech", long = "--check-technology",
        help = "check technology layer map and config. (not implemented)"
    },
    switch{ 
        name = "notech", long = "--notech",
        help = "disable all technology translation functions (metal translation, via arrayzation, layer mapping, grid fixing). This also installs a dummy technology that can be used for debugging"
    },
    switch{ 
        name = "noexport", long = "--noexport",
        help = "disable all export functions. This is different from --dryrun, which calls the export translation, but does not write any files. Both options are mostly related to profiling, if exporting should be profiled --dryrun must be used"
    },
    switch{ 
        name = "dryrun", long = "--dryrun",
        help = "perform all calculations, but don't actually write any files. This is useful for profiling, where the program should run normally but should not produce any output"
    },
}

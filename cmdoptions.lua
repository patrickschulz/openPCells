return {
    section("Main generation functions"),
    store{ 
        name  = "technology", short = "-T", long  = "--technology",
        help  = "specify technology"
    },
    store{ 
        name  = "cell", short = "-C", long  = "--cell",
        help  = "specify cell"
    },
    store{ 
        name  = "export", short = "-E", long  = "--export",
        help  = "specify export type"
    },
    consumer_table{ 
        name  = "export_options", long  = "--iopt",
        help  = "pass special options to export"
    },
    store{
        name = "script", short = "-S", long = "--script",
        help = "execute cell script. This can also be used to run lua code with the opc API loaded"
    },
    section("Auxiliary generation functions"),
    store_multiple{
        name = "techpath", long = "--techpath",
        help = "add (append) searchpath for technology files (can be used multiple times: --techpath foo --techpath bar)"
    },
    store{ 
        name  = "paramfile", short = "-p", long  = "--pfile",
        help  = "file to read parameters from. This file should be a regular lua file returning a table with the parameters"
    },
    store{ 
        name  = "filename", short = "-f", long  = "--filename",
        help  = "specify output filename for export"
    },
    consumer_string{ 
        name  = "origin", long  = "--origin",
        help  = "origin of cell (move (0, 0)). This option expects a point input, e.g. '(10, 10)' (with parantheses)"
    },
    consumer_string{ 
        name  = "translate", long  = "--translate",
        help  = "move cell by (x, y). This option expects a point input, e.g. '(10, 10)' (with parantheses)"
    },
    consumer_string{ 
        name  = "orientation", long  = "--orientation",
        help  = "orientation of cell (possible values: 0 (regular), fx (flip x), fy (flip y), fxy (flip x and y))"
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
        name = "layerfilter", long = "--filter",
        help = "filter layers to be generated. Any layer (in generic notation) in this list will not be generated."
    },
    store{
        name = "layerfilterlist", long = "--filter-list",
        help = "set filter list type (white or black, default black)"
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
        name  = "separator", long  = "--separator",
        help  = "cell parameter separator (default \\n)"
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
    section("Miscellaneous functions"),
    switch{
        name = "nouserconfig", long = "--nouserconfig",
        help = "don't load the user config"
    },
    section("Info functions"),
    switch{ 
        name  = "params", short = "-P", long  = "--parameters",
        help  = "display available cell parameters and exit (requires --cell)"
    },
    switch{ 
        name  = "constraints", long  = "--constraints",
        help  = "show required technology parameter (requires --cell and --technology)"
    },
    switch{ 
        name  = "listcells", short = "-L", long  = "--list",
        help  = "list available cells"
    },
    switch{ 
        name  = "listallcells", long  = "--list-all",
        help  = "list all available cells (including hidden cells)"
    },
    switch{
        name = "listcellpaths", long = "--listcellpaths",
        help = "list cell search paths"
    },
    switch{
        name = "listtechpaths", long = "--listtechpaths",
        help = "list technology search paths"
    },
    section("Diagnostic functions"),
    switch{
        name = "cellinfo", long = "--show-cellinfo",
        help = "show some cell information: shape count, used layers, etc."
    },
    switch{
        name  = "profile", long  = "--profile",
        help  = "collect and display profiling data"
    },
    switch{ 
        name  = "verbose", short = "-V", long  = "--verbose",
        help  = "enable verbose output"
    },
    store{ 
        name  = "debug", short = "-D", long  = "--debug",
        help  = "enable debugging output (specify modules separated by commas)"
    },
    switch{ 
        name  = "check", long  = "--check",
        help  = "check cell code and parameter variations. Strict checking, e.g. if a cell parameter can not work with even values, specify the parameter as even()"
    },
    switch{ 
        name  = "checktech", long  = "--check-technology",
        help  = "check technology layer map and config. (not implemented)"
    },
    switch{ 
        name  = "notech", long  = "--notech",
        help  = "disable all technology translation functions (metal translation, via arrayzation, layer mapping, grid fixing). This also installs a dummy technology that can be used for debugging"
    },
    switch{ 
        name  = "noexport", long  = "--noexport",
        help  = "disable all export functions. This is different from --dryrun, which calls the export translation, but does not write any files. Both options are mostly related to profiling, if exporting should be profiled --dryrun must be used"
    },
    switch{ 
        name  = "dryrun", long  = "--dryrun",
        help  = "perform all calculations, but don't actually write any files. This is useful for profiling, where the program should run normally but should not produce any output"
    },
}

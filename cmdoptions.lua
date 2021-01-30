return {
    switch{
        name  = "profile", long  = "--profile",
        help  = "collect and display profiling data"
    },
    switch{ 
        name  = "params", short = "-P", long  = "--parameters",
        help  = "display available cell parameters and exit"
    },
    switch{ 
        name  = "listcells", short = "-L", long  = "--list",
        help  = "list available cells"
    },
    switch{ 
        name  = "constraints", long  = "--constraints",
        help  = "show required technology parameter (needs --cell and --technology)"
    },
    switch{
        name = "human", long = "--human",
        help = "format info output (parameters, cell lists etc.) for humans"
    },
    switch{
        name = "machine", long = "--machine",
        help = "format info output (parameters, cell lists etc.) for machines (computer). Use this for parsing the data for interfaces"
    },
    store{ 
        name  = "separator", long  = "--separator",
        help  = "cell parameter separator (default \\n)"
    },
    store{ 
        name  = "technology", short = "-T", long  = "--technology",
        help  = "specify technology"
    },
    store{ 
        name  = "interface", short = "-I", long  = "--interface",
        help  = "specify interface"
    },
    store{ 
        name  = "cell", short = "-C", long  = "--cell",
        help  = "specify cell"
    },
    store{ 
        name  = "paramfile", short = "-p", long  = "--pfile",
        help  = "file to read parameters from. This file should be a regular lua file returning a table with the parameters"
    },
    --[[
    store{ 
        name  = "export",
        short = "-E",
        long  = "--export",
        help  = "specify export"
    },
    --]]
    store{ 
        name  = "filename", short = "-f", long  = "--filename",
        help  = "specify output filename for interface and export"
    },
    consumer_string{ 
        name  = "origin", long  = "--origin",
        help  = "origin of cell (move (0, 0))"
    },
    consumer_string{ 
        name  = "orientation", long  = "--orientation",
        help  = "orientation of cell (possible values: 0 (regular), fx (flip x), fy (flip y), fxy (flip x and y))"
    },
    consumer_table{ 
        name  = "interface_options", long  = "--iopt",
        help  = "pass special options to interface"
    },
    store_multiple{
        name = "cellpath", long = "--cellpath",
        help = "add searchpath for cells (can be used multiple times: --cellpath foo --cellpath bar)"
    },
    store{
        name = "script", short = "-S", long = "--script",
        help = "execute cell script"
    },
    switch{ 
        name  = "check", long  = "--check",
        help  = "check cell code"
    },
    switch{ 
        name  = "notech", long  = "--notech",
        help  = "disable all technology translation functions (metal translation, via arrayzation, layer mapping grid fixing)"
    },
    switch{ 
        name  = "nointerface", long  = "--nointerface",
        help  = "disable all interface/export functions. This is different from --dryrun, which calls the interface translation, but does not write any files. Both options are mostly related to profiling, if interfaces should be profiled --dryrun must be used"
    },
    switch{ 
        name  = "dryrun", long  = "--dryrun",
        help  = "perform all calculations, but don't actually write any files. This is useful for profiling, where the program should run normally but should not produce any output"
    },
    store{ 
        name  = "debug", short = "-D", long  = "--debug",
        help  = "enable debugging output (specify modules separated by commas)"
    },
}

return {
    { 
        name  = "params",
        short = "-P",
        long  = "--parameters",
        func  = "switch",
        help  = "display available cell parameters and exit"
    },
    { 
        name  = "listcells",
        short = "-L",
        long  = "--list",
        func  = "switch",
        help  = "list available cells"
    },
    { 
        name  = "constraints",
        long  = "--constraints",
        func  = "switch",
        help  = "show required technology parameter (needs --cell and --technology)"
    },
    { 
        name  = "separator",
        long  = "--separator",
        func  = "store",
        help  = "cell parameter separator (default \\n)"
    },
    { 
        name  = "technology",
        short = "-T",
        long  = "--technology",
        func  = "store",
        help  = "specify technology"
    },
    { 
        name  = "interface",
        short = "-I",
        long  = "--interface",
        func  = "store",
        help  = "specify interface"
    },
    { 
        name  = "cell",
        short = "-C",
        long  = "--cell",
        func  = "store",
        help  = "specify cell"
    },
    --[[
    { 
        name  = "export",
        short = "-E",
        long  = "--export",
        func  = "store",
        help  = "specify export"
    },
    --]]
    { 
        name  = "filename",
        short = "-f",
        long  = "--filename",
        func  = "store",
        help  = "specify output filename for interface and export"
    },
    { 
        name  = "origin",
        long  = "--origin",
        func  = "consumer_string",
        help  = "origin of cell (move (0, 0))"
    },
    { 
        name  = "orientation",
        long  = "--orientation",
        func  = "consumer_string",
        help  = "orientation of cell (possible values: 0 (regular), fx (flip x), fy (flip y), fxy (flip x and y))"
    },
    { 
        name  = "interface_options",
        long  = "--iopt",
        func  = "consumer_table",
        help  = "pass special options to interface"
    },
    { 
        name  = "check",
        long  = "--check",
        func  = "switch",
        help  = "check cell code"
    },
    { 
        name  = "notech",
        long  = "--notech",
        func  = "switch",
        help  = "disable all technology translation functions (metal translation, via arrayzation, layer mapping grid fixing)"
    },
    { 
        name  = "nointerface",
        long  = "--nointerface",
        func  = "switch",
        help  = "disable all interface/export functions. This is different from --dryrun, which calls the interface translation, but does not write any files. Both options are mostly related to profiling, if interfaces should be profiled --dryrun must be used"
    },
    { 
        name  = "dryrun",
        long  = "--dryrun",
        func  = "switch",
        help  = "perform all calculations, but don't actually write any files. This is useful for profiling, where the program should run normally but should not produce any output"
    },
    { 
        name  = "debug",
        short = "-D",
        long  = "--debug",
        func  = "store",
        help  = "enable debugging output (specify modules separated by commas)"
    },
}

return {
    store{ 
        name  = "libname", short = "-L", long  = "--libname",
        help  = "specify library name"
    },
    store{ 
        name  = "cellname", short = "-C", long  = "--cellname",
        help  = "specify toplevel cell name"
    },
    switch{ 
        name  = "flat", short = "-f", long  = "--flat",
        help  = "write a flat cell, not a hierarchy"
    },
}

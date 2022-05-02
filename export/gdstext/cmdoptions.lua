return {
    store{ 
        name  = "libname", short = "-L", long  = "--libname",
        help  = "specify library name"
    },
    store{
        name  = "userunit", short = "-u", long  = "--user-unit",
        help  = "specify user unit"
    },
    store{
        name  = "databaseunit", short = "-d", long  = "--database-unit",
        help  = "specify database unit"
    },
    store_multiple{
        name = "recordfilter", long = "--filter",
        help = "filter exported records. Record names are expected in all upper case (e.g. HEADER)."
    },
    store{
        name = "recordfilterlist", long = "--filter-list",
        help = "set record filter list type (white or black, default black)"
    },
    switch{
        name = "disablepath", short = "-p", long = "--disable-paths",
        help = "don't export paths as paths but as polygons/rectangles"
    },
    store{
        name = "labelsize", short = "-s", long = "--label-size",
        help = "labelsize in database units (default 1)"
    },
}

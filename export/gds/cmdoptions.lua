return {
    store{ 
        name  = "libname", short = "-L", long  = "--libname",
        help  = "specify library name"
    },
    store{ 
        name  = "cellname", short = "-C", long  = "--cellname",
        help  = "specify toplevel cell name"
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
        help = "filter exported records. Record names are expected in all upper case (e.g. HEADER). This option very likely leads to a corrupted GDS file, but is useful with the textmode option."
    },
    store{
        name = "recordfilterlist", long = "--filter-list",
        help = "set record filter list type (white or black, default black)"
    },
    switch{
        name = "textmode", short = "-t", long = "--text",
        help = "create a text representation"
    },
    switch{
        name = "disablepath", short = "-p", long = "--disable-paths",
        help = "don't export paths as paths but as polygons/rectangles"
    },
}

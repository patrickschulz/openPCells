std = {
    read_globals = {
        -- standard global symbols
        "_ENV",
        "arg",
        "os",
        "io",
        "table",
        "string",
        "math",
        "debug",
        "assert",
        "error",
        "ipairs",
        "pairs",
        "print",
        "pcall",
        "type",
        "tostring",
        "tonumber",
        "setmetatable",
        -- opc global symbols
        "_load_module",
        "_get_opc_home",
        "point",
        "pcell",
        "object",
        "shape",
        "graphics",
        "geometry",
        "generics",
        "abstract",
        "stringfile",
        "config",
        "reduce",
        "util",
        "aux",
        "bind",
        "enable",
        -- layermap globals
        "map",
        "array",
        "refer",
    },
    globals = {
        "parameters",
        "layout",
    }
}

exclude_files = {
    "testsuite/module/modules/syntaxerror.lua",
    "doc",
}

codes = true
quiet = 1
max_line_length = false

-- vim: ft=lua

function parameters()
    pcell.add_parameters(
        { "oxidetype",  "0.9" },
        { "pvthtype",   "slvt" },
        { "nvthtype",   "slvt" },
        { "pwidth",     500 },
        { "nwidth",     500 },
        { "glength",    100 },
        { "gspace",     150 },
        { "gext",       100 },
        { "sdwidth",     60 },
        { "gstwidth",   100 },
        { "fingers",      1 },
        { "dummies",      1 },
        { "dummycontheight",      80 },
        { "separation", 400 },
        { "ttypeext",   100 },
        { "powerwidth", 200 },
        { "powerspace", 100 },
        { "conngate",     1 },
        { "connmetal",    3 },
        { "connwidth",  100 },
        { "connoffset",   1 }
    )
end

function layout(gate, _P)
    gate:merge_into(pcell.create_layout("logic/nand_gate"):translate(-5000, 0))
    gate:merge_into(pcell.create_layout("logic/not_gate"):translate(5000, 0))
end

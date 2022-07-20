function parameters()
    pcell.reference_cell("stdcells/base")
    pcell.reference_cell("stdcells/not_gate")
    pcell.reference_cell("stdcells/nor_gate")
    pcell.reference_cell("stdcells/nand_gate")
end
function layout(toplevel)
    local cellnames = {
        {
            { instance = "nor3", reference = "nor_gate" },
            { instance = "fill_1_2", reference = "isogate" },
            { instance = "fill_1_1", reference = "isogate" },
            { instance = "nor4", reference = "nor_gate" },
        },
        {
            { instance = "nor1", reference = "nor_gate" },
            { instance = "fill_2_2", reference = "isogate" },
            { instance = "fill_2_1", reference = "isogate" },
            { instance = "nor2", reference = "nor_gate" },
        },
        {
            { instance = "nandr", reference = "nand_gate" },
            { instance = "notr", reference = "not_gate" },
            { instance = "fill_3_3", reference = "isogate" },
            { instance = "fill_3_2", reference = "isogate" },
            { instance = "fill_3_1", reference = "isogate" },
        },
        {
            { instance = "nor5", reference = "nor_gate" },
            { instance = "fill_4_2", reference = "isogate" },
            { instance = "fill_4_1", reference = "isogate" },
            { instance = "nor6", reference = "nor_gate" },
        },
        {
            { instance = "nor7", reference = "nor_gate" },
            { instance = "fill_5_2", reference = "isogate" },
            { instance = "fill_5_1", reference = "isogate" },
            { instance = "nor8", reference = "nor_gate" },
        },
    }
    local rows = placement.create_reference_rows(cellnames)
    local cells = placement.rowwise(toplevel, rows)
    local routes = {
        {
            name = "up_(0)",
            { type = "anchor", name = "nor1", anchor = "A" },
            { z = 1, type = "via" },
            { x = 1, type = "delta" },
            { y = 1, type = "delta" },
            { x = 2, type = "delta" },
            { y = -2, type = "delta" },
            { z = -1, type = "via" },
            { type = "anchor", name = "nor2", anchor = "O" },
        },
        {
            name = "up_(1)",
            startmetal = 2,
            { type = "anchor", name = "nor1", anchor = "A" },
            { type = "shift", x = 1, y = 1 },
            { y = 9, type = "delta" },
            { x = -1, type = "delta" },
            { z = -1, type = "via" },
            { type = "anchor", name = "nandr", anchor = "A" },
        },
        {
            name = "net1_(0)",
            { type = "anchor", name = "nor3", anchor = "B" },
            { type = "shift", x = -1 },
            { z = 1, type = "via" },
            { x = 2, type = "delta" },
            { y = 11, type = "delta" },
            { z = -1, type = "via" },
            { type = "anchor", name = "nor1", anchor = "O" },
        },
        {
            name = "net1_(1)",
            { type = "anchor", name = "nor1", anchor = "O" },
            { y = 1, type = "delta" },
            { type = "anchor", name = "nor2", anchor = "A" },
        },
        {
            name = "net2_(0)",
            { type = "anchor", name = "nor3", anchor = "O" },
            { y = 1, type = "delta" },
            { x = 3, type = "delta" },
            { type = "anchor", name = "nor4", anchor = "B" },
        },
        {
            name = "net2_(1)",
            { type = "anchor", name = "nor4", anchor = "B" },
            { type = "shift", x = -1 },
            { z = 1, type = "via" },
            { y = 10, type = "delta" },
            { z = -1, type = "via" },
            { type = "anchor", name = "nor2", anchor = "B" },
        },
        {
            name = "net3_(0)",
            { type = "anchor", name = "nor3", anchor = "A" },
            { z = 1, type = "via" },
            { x = 1, type = "delta" },
            { y = 1, type = "delta" },
            { x = 2, type = "delta" },
            { z = -1, type = "via" },
            { type = "anchor", name = "nor4", anchor = "O" },
        },
        {
            name = "up_(0)",
            { type = "anchor", name = "nor5", anchor = "B" },
            { type = "shift", x = -1 },
            { z = 1, type = "via" },
            { x = 1, type = "delta" },
            { y = -1, type = "delta" },
            { x = 2, type = "delta" },
            { y = 2, type = "delta" },
            { z = -1, type = "via" },
            { type = "anchor", name = "nor6", anchor = "O" },
        },
        {
            name = "up_(1)",
            startmetal = 2,
            { type = "anchor", name = "nor5", anchor = "B" },
            { type = "shift", x = 0, y = -1 },
            { y = -9, type = "delta" },
            { x = -1, type = "delta" },
            { z = -1, type = "via" },
            { type = "anchor", name = "nandr", anchor = "B" },
        },
        {
            name = "net1_(0)",
            { type = "anchor", name = "nor7", anchor = "A" },
            { z = 1, type = "via" },
            { x = 2, type = "delta" },
            { y = -11, type = "delta" },
            { z = -1, type = "via" },
            { type = "anchor", name = "nor5", anchor = "O" },
        },
        {
            name = "net1_(1)",
            { type = "anchor", name = "nor5", anchor = "O" },
            { y = -1, type = "delta" },
            { type = "anchor", name = "nor6", anchor = "B" },
        },
        {
            name = "net2_(0)",
            { type = "anchor", name = "nor7", anchor = "O" },
            { y = -1, type = "delta" },
            { x = 3, type = "delta" },
            { type = "anchor", name = "nor8", anchor = "A" },
        },
        {
            name = "net2_(1)",
            { type = "anchor", name = "nor8", anchor = "A" },
            --{ type = "shift", x = 1 },
            { z = 1, type = "via" },
            { y = -10, type = "delta" },
            { z = -1, type = "via" },
        },
        {
            name = "net3_(0)",
            { type = "anchor", name = "nor7", anchor = "B" },
            { type = "shift", x = -1 },
            { z = 1, type = "via" },
            { x = 1, type = "delta" },
            { y = -1, type = "delta" },
            { x = 2, type = "delta" },
            { z = -1, type = "via" },
            { type = "anchor", name = "nor8", anchor = "O" },
        },
        {
            name = "resetb_(0)",
            { type = "anchor", name = "nandr", anchor = "O" },
            { type = "anchor", name = "notr", anchor = "I" },
        },
        {
            name = "reset_1",
            { type = "anchor", name = "notr", anchor = "O" },
            { z = 1, type = "via" },
            { y = -25, type = "delta" },
            { x = 2, type = "delta" },
            { z = -1, type = "via" },
            { type = "anchor", name = "nor4", anchor = "A" },
        },
        {
            name = "reset_2",
            { type = "anchor", name = "notr", anchor = "O" },
            { z = 1, type = "via" },
            { y = 25, type = "delta" },
            { x = 2, type = "delta" },
            { z = -1, type = "via" },
            { type = "anchor", name = "nor8", anchor = "B" },
        },
    }
    local bp = pcell.get_parameters("stdcells/base")
    local width = bp.routingwidth
    local xgrid = bp.gspace + bp.glength
    local ygrid = bp.routingwidth + bp.routingspace
    routing.route(toplevel, routes, cells, width, xgrid, ygrid)
    toplevel:add_port("ref", generics.metalport(1), cells["nor1"]:get_anchor("B"))
    toplevel:add_port("sig", generics.metalport(1), cells["nor5"]:get_anchor("A"))
    toplevel:add_port("up", generics.metalport(1), cells["nor2"]:get_anchor("O"))
    toplevel:add_port("down", generics.metalport(1), cells["nor6"]:get_anchor("O"))
end

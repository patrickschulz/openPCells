function layout(toplevel)
    local cellnames = {
        {
            { instance = "invd", reference = "not_gate" },
            { instance = "dffp1", reference = "dffp" },
        },
        {
            { instance = "inv1", reference = "not_gate" },
            { instance = "inv2", reference = "not_gate" },
            { instance = "nand", reference = "nand_gate" },
        },
    }
    local rows = placement.create_reference_rows(cellnames)
    local cells = placement.digital(toplevel, rows, 24)
    local xpitch = 104
    local ypitch = 80
    local routes = {
        {
            { type = "anchor", name = "invd", anchor = "O" },
            { type = "via", metal = 2 },
            { type = "delta", y = 2 * ypitch, x = 5 * xpitch },
            --{ type = "via", metal = 2 },
            { type = "switchdirection" },
            { type = "anchor", name = "nand", anchor = "A" },
        }
    }
    routing.route(toplevel, routes, cells, 100)
end

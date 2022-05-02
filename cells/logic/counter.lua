--[[
This cell implements a down-counting counter with numrows * numcolumns bits
The counter is down-counting, since this can be implemented more regularly 
than an upcounting counter. (At least that's what I think, if you see this differently, let me know.)

This design is practically glitch-free, as no positively-clocked flip-flop follows another positively-clocked ff and vice versa.
This comes at the cost of higher silicon area (2 * N DFFs for N bits) and setup violations at clock frequencies lower than you
could go with a different approach.

                            |-------XNOR
       pre[0:N] -----DFFP   |       XNOR---- out[0:N] -------DFFN
                     DFFP---(---*-- XNOR                     DFFN--- pre[0:N]
            clk ---->DFFP   |   |                   clk ---->DFFN
                            |   |
                            |   |-----OR
                            |         OR------ carry[0:N]
         vss,carry[0:N-1] --*---------OR

--]]

function parameters()
    pcell.reference_cell("stdcells/base")
    pcell.add_parameters(
        { "numcolumns(Number of Columns)", 2 },
        { "numrows(Number of Rows)", 2 }
    )
end

function layout(counter, _P)
    local bp = pcell.get_parameters("stdcells/base")
    local width = bp.gstwidth
    local xgrid = bp.gspace + bp.glength
    local ygrid = bp.gstwidth + bp.gstspace

    -- single bit instance
    local bitref = object.create()
    local bitcellnames = {
        {
            { instance = "dffp", reference = "dffpq" },
            { instance = "xnor", reference = "xor_gate" },
            { instance = "or",   reference = "or_gate" },
            { instance = "dffn", reference = "dffnq" },
        }
    }
    local bitrow = placement.create_reference_rows(bitcellnames)
    local bitcells = placement.rowwise(bitref, bitrow)
    bitref:add_anchor("I", bitcells["dffp"]:get_anchor("D"))
    bitref:add_anchor("O", bitcells["dffn"]:get_anchor("Q"))
    local bitroutes = {}
    table.insert(bitroutes, {
        { type = "anchor", name = "dffn", anchor = "Q" },
        { type = "via", metal = 3 },
        { type = "delta", y = 2 },
        { type = "anchor", name = "dffp", anchor = "D" },
        { type = "via", metal = 2 },
    })
    table.insert(bitroutes, {
        { type = "anchor", name = "dffp", anchor = "Q" },
        { type = "via", metal = 3 },
        { type = "anchor", name = "xnor", anchor = "A" },
        { type = "anchor", name = "or", anchor = "A" },
        { type = "via", metal = 1 },
    })
    table.insert(bitroutes, {
        { type = "anchor", name = "xnor", anchor = "B" },
        { type = "via", metal = 3 },
        { type = "anchor", name = "or", anchor = "B" },
    })
    --table.insert(bitroutes, {
    --    { type = "anchor", name = "xnor", anchor = "O" },
    --    { type = "via", metal = 2 },
    --    { type = "delta", x = 100 },
    --    { type = "anchor", name = "dffn", anchor = "D" },
    --})
    routing.route(bitref, bitroutes, bitcells, width, xgrid, ygrid)

    -- row placement
    local bitname = pcell.add_cell_reference(bitref, "bit")
    local bitnames = {}
    for i = 1, _P.numrows do
        local row = {}
        for j = 1, _P.numcolumns do
            row[j] = bitname
        end
        table.insert(bitnames, row)
    end
    local rows = placement.format_rows(bitnames)
    local cells = placement.rowwise(counter, rows)

    -- routes
    local routes = {}
    for i = 1, _P.numrows do
        for j = 1, _P.numcolumns do
            -- routes
            if j < _P.numcolumns then
                table.insert(routes, {
                    --{ type = "anchor", name = string.format("or_%d_%d", i, j), anchor = "O" },
                    { type = "point", where = cells[i][j]:get_anchor("O") },
                    { type = "via", metal = 4 },
                    { type = "delta", y = -2 },
                    --{ type = "anchor", name = string.format("or_%d_%d", i, j + 1), anchor = "B" },
                    { type = "point", where = cells[i][j + 1]:get_anchor("I") },
                })
            end
        end
    end
    routing.route(counter, routes, cells, width, xgrid, ygrid)
end


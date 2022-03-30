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
    local cellnames = {}
    local routes = {}
    for i = 1, _P.numrows do
        local row = {}
        for j = 1, _P.numcolumns do
            -- cells
            table.insert(row, { instance = string.format("dffp_%d_%d", i, j), reference = "dffp" })
            table.insert(row, { instance = string.format("xnor_%d_%d", i, j), reference = "xor_gate" })
            table.insert(row, { instance = string.format("or_%d_%d", i, j), reference = "or_gate" })
            table.insert(row, { instance = string.format("dffn_%d_%d", i, j), reference = "dffn" })
            -- routes
            table.insert(routes, {
                { type = "anchor", name = string.format("dffn_%d_%d", i, j), anchor = "Q" },
                { type = "via", metal = 3 },
                { type = "delta", y = 200 },
                { type = "anchor", name = string.format("dffp_%d_%d", i, j), anchor = "D" },
            })
            table.insert(routes, {
                { type = "anchor", name = string.format("dffp_%d_%d", i, j), anchor = "Q" },
                { type = "via", metal = 3 },
                { type = "anchor", name = string.format("xnor_%d_%d", i, j), anchor = "A" },
                { type = "anchor", name = string.format("or_%d_%d", i, j), anchor = "A" },
            })
            table.insert(routes, {
                { type = "anchor", name = string.format("xnor_%d_%d", i, j), anchor = "B" },
                { type = "via", metal = 4 },
                { type = "anchor", name = string.format("or_%d_%d", i, j), anchor = "B" },
            })
            table.insert(routes, {
                { type = "anchor", name = string.format("xnor_%d_%d", i, j), anchor = "O" },
                { type = "via", metal = 2 },
                { type = "delta", x = 100 },
                { type = "anchor", name = string.format("dffn_%d_%d", i, j), anchor = "D" },
            })
            --if j < _P.numcolumns then
            --    table.insert(routes, {
            --        { type = "anchor", name = string.format("or_%d_%d", i, j), anchor = "O" },
            --        { type = "via", metal = 4 },
            --        { type = "delta", y = -200 },
            --        { type = "anchor", name = string.format("or_%d_%d", i, j + 1), anchor = "B" },
            --    })
            --end
        end
        table.insert(cellnames, row)
    end
    local rows = placement.create_reference_rows(cellnames)
    local cells = placement.rowwise(counter, rows)
    routing.route(counter, routes, cells, 40)
end


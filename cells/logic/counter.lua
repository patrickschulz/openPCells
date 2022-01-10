--[[
This cell implements a down-counting counter with numrows * numcolumns bits
The counter is down-counting, since this can be implemented more regularly 
than an upcounting counter. (At least that's what I think, if you see this differently, let me know.)

This design is nearly glitch-free, as no positively-clocked flip-flop follows another positively-clocked ff and vice versa.
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
        { "numrows(Number of Rows)", 5 }
    )
end

function layout(counter, _P)
    -- generate cell layouts
    --pcell.push_overwrites("stdcells/base", { leftdummies = 1, rightdummies = 1 })
    --local dffpref = pcell.create_layout("stdcells/dff", { clockpolarity = "positive", enable_Q = true, enable_QN = false })
    --local dffnref = pcell.create_layout("stdcells/dff", { clockpolarity = "negative", enable_Q = true, enable_QN = false })
    --local xorref  = pcell.create_layout("stdcells/xor_gate")
    --local orref   = pcell.create_layout("stdcells/or_gate")
    --pcell.pop_overwrites("stdcells/base")

    ---- create references
    --local dffpname = pcell.add_cell_reference(dffpref, "dffp")
    --local dffnname = pcell.add_cell_reference(dffnref, "dffn")
    --local xorname  = pcell.add_cell_reference(xorref, "xor")
    --local orname   = pcell.add_cell_reference(orref, "or")

    local rows = {}
    for i = 1, _P.numrows do
        local row = {}
        for j = 1, _P.numcolumns do
            table.insert(row, { instance = string.format("dffp_%d_%d", i, j), reference = "dff" })
            table.insert(row, { instance = string.format("xor_%d_%d", i, j), reference = "xor_gate" })
            table.insert(row, { instance = string.format("or_%d_%d", i, j), reference = "or_gate" })
            table.insert(row, { instance = string.format("dffn_%d_%d", i, j), reference = "dff" })
        end
        table.insert(rows, row)
    end
    table.insert(rows, { "dff" })
    local cells = placement.digital(counter, 100, rows)
end


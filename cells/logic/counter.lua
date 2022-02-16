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
    local cellnames = {}
    for i = 1, _P.numrows do
        local row = {}
        for j = 1, _P.numcolumns do
            table.insert(row, "dffp")
            table.insert(row, "xor_gate")
            table.insert(row, "or_gate")
            table.insert(row, "dffn")
        end
        table.insert(cellnames, row)
    end
    local rows = placement.create_reference_rows(cellnames)
    local cells = placement.digital(counter, rows, 200)
end


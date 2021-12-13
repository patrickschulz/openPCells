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
    pcell.push_overwrites("stdcells/base", { leftdummies = 1, rightdummies = 1 })
    local dffpref = pcell.create_layout("stdcells/dff", { clockpolarity = "positive", enable_Q = true, enable_QN = false })
    local dffnref = pcell.create_layout("stdcells/dff", { clockpolarity = "negative", enable_Q = true, enable_QN = false })
    local xorref  = pcell.create_layout("stdcells/xor_gate")
    local orref   = pcell.create_layout("stdcells/or_gate")
    pcell.pop_overwrites("stdcells/base")

    -- create references
    local dffpname = pcell.add_cell_reference(dffpref, "dffp")
    local dffnname = pcell.add_cell_reference(dffnref, "dffn")
    local xorname  = pcell.add_cell_reference(xorref, "xor")
    local orname   = pcell.add_cell_reference(orref, "or")

    -- place cells
    local rows = {}
    for i = 1, _P.numrows do
        for j = 1, _P.numcolumns do
            local column = {}

            -- positive flip flop
            column.dffp = counter:add_child(dffpname)

            if i > 1 then
                column.dffp:move_anchor("bottom", rows[i - 1][1].dffp:get_anchor("top"))
            end
            if j > 1 then
                column.dffp:move_anchor("left", rows[i][j - 1].dffn:get_anchor("right"))
            end

            -- xor gate
            column.xorgate = counter:add_child(xorname)
            column.xorgate:move_anchor("left", column.dffp:get_anchor("right"))

            -- or gate
            column.orgate = counter:add_child(orname)
            column.orgate:move_anchor("left", column.xorgate:get_anchor("right"))

            -- positive flip flop
            column.dffn = counter:add_child(dffnname)
            column.dffn:move_anchor("left", column.orgate:get_anchor("right"))

            -- save row
            if j == 1 then
                rows[i] = {}
            end
            rows[i][j] = column
        end
        -- flip every second row
        if i % 2 == 0 then
            for _, column in ipairs(rows[i]) do
                for _, gate in pairs(column) do
                    gate:flipy()
                end
            end
        end
    end
end

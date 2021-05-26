function parameters()

end

function layout(cell, _P)
    --[[
    -- place flat rectangle
    cell:merge_into(geometry.rectangle(generics.metal(1), 200, 200))

    -- place two subcells
    local sub = pcell.create_layout("__test/sub")
    cell:add_child(sub, point.create(0,  500))
    cell:add_child(sub, point.create(0, -500))
    cell:add_child(sub, point.create(500, 0))
    --]]

    --cell:add_child(pcell.create_layout("logic/nor_gate"), point.create(0, 0))
    --cell:add_child(pcell.create_layout("logic/and_gate"), point.create(2000, 0))

    local isogate = pcell.create_layout("logic/isogate")
    cell:add_child(isogate)

    local gate1 = pcell.create_layout("logic/nor_gate")
    cell:add_child(gate1, isogate:get_anchor("left") - gate1:get_anchor("right"))

    local gate2 = pcell.create_layout("logic/and_gate")
    gate2:translate(500, 0)
    cell:add_child(gate2, isogate:get_anchor("right") - gate2:get_anchor("left"))
end

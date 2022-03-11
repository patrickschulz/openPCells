function parameters()

end

function layout(cell, _P)
    -- place flat rectangle
    cell:merge_into_shallow(geometry.rectangle(generics.metal(1), 200, 200))

    -- place two subcells
    local sub = pcell.create_layout("__test/sub")
    local name = pcell.add_cell_reference(sub, "sub")
    cell:add_child(name):translate(   0,  500)
    cell:add_child(name):translate(   0, -500):flipy()
    cell:add_child(name):translate( 500,    0)
    cell:add_child(name):translate(-500,    0)

    --[[
    local child = cell:add_child(name)
    child:translate(0, -500)
    child:flipy()
    --]]
end

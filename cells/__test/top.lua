function parameters()

end

function layout(cell, _P)
    --[[
    -- place flat rectangle
    cell:merge_into(geometry.rectangle(generics.metal(1), 200, 200))

    -- place two subcells
    local sub = pcell.create_layout("__test/sub")
    local name = cell:add_child_reference(sub, "sub")
    cell:add_child_link(name):translate(   0,  500)
    cell:add_child_link(name):translate(   0, -500):flipy()
    cell:add_child_link(name):translate( 500,    0)
    cell:add_child_link(name):translate(-500,    0)
    --]]

    local sub = pcell.create_layout("__test/sub")
    sub:translate(0, 200)
    sub:flipy()
    cell:merge_into(sub)
end

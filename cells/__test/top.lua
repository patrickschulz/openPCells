function parameters()

end

function layout(cell, _P)
    -- place flat rectangle
    cell:merge_into(geometry.rectangle(generics.metal(1), 200, 200))

    -- place two subcells
    local sub = pcell.create_layout("__test/sub")
    local name = cell:add_child_reference(sub, "sub")
    cell:add_child_link(name, point.create(   0,  500))
    cell:add_child_link(name, point.create(   0, -500))
    cell:add_child_link(name, point.create( 500,    0))
    cell:add_child_link(name, point.create(-500,    0))
end

function parameters()

end

function layout(cell, _P)
    local subsub = pcell.create_layout("__test/subsub")
    local name = cell:add_child_reference(subsub, "sub")
    cell:add_child_link(name, point.create(-100, -100))
    cell:add_child_link(name, point.create(-100,  100))
    cell:add_child_link(name, point.create( 100, -100))
    cell:add_child_link(name, point.create( 100,  100))
end

function parameters()

end

function layout(cell, _P)
    local subsub = pcell.create_layout("__test/subsub")
    cell:add_child(subsub, point.create(-100, -100))
    cell:add_child(subsub, point.create(-100,  100))
    cell:add_child(subsub, point.create( 100, -100))
    cell:add_child(subsub, point.create( 100,  100))
end

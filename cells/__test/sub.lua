function parameters()

end

function layout(cell, _P)
    local subsub = pcell.create_layout("__test/subsub")
    local name = cell:add_child_reference(subsub, "sub")
    cell:add_child_link(name):translate(-100, -100)
    cell:add_child_link(name):translate( 100, -100)
    cell:add_child_link(name):translate(   0,  100)

    cell:merge_into(geometry.rectangle(generics.metal(1), 100, 20):translate(0, 50))
end

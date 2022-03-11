function parameters()

end

function layout(cell, _P)
    local subsub = pcell.create_layout("__test/subsub")
    local name = pcell.add_cell_reference(subsub, "subsub")
    cell:add_child(name):translate(-100, -100)
    cell:add_child(name):translate( 100, -100)
    cell:add_child(name):translate(   0,  100)

    cell:merge_into_shallow(geometry.rectangle(generics.metal(1), 20, 20))
end

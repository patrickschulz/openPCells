function parameters()

end

function layout(cell, _P)
    local subsub = pcell.create_layout("__test/subsub", "subsub")
    cell:add_child(subsub, "subsub0"):translate(-100, -100)
    cell:add_child(subsub, "subsub1"):translate( 100, -100)
    cell:add_child(subsub, "subsub2"):translate(   0,  100)

    geometry.rectangle(cell, generics.metal(1), 20, 20)
end

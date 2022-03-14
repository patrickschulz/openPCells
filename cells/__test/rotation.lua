function parameters()

end

function layout(cell)
    local subref = object.create()
    geometry.rectanglebltr(subref, generics.metal(1), point.create(0, 0), point.create(100, 100))
    local subname = pcell.add_cell_reference(subref, "sub")
    local sub = cell:add_child(subname)
    sub:rotate_90()
end

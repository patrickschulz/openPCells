function parameters()

end

function layout(cell)
    local subname = pcell.add_cell_reference(geometry.rectanglebltr(generics.metal(1), point.create(0, 0), point.create(100, 100)), "sub")
    local sub = cell:add_child(subname)
    sub:rotate_90()
end

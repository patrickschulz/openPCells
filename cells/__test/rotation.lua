function parameters()

end

function layout(cell)
    local subref = object.create()
    geometry.rectanglebltr(subref, generics.metal(1), point.create(0, 0), point.create(100, 100))
    local sub = cell:add_child(subref, "sub")
    sub:rotate_90_left()
end

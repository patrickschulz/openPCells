function parameters()

end

function layout(cell, _P)
    local sub = pcell.create_layout("__test/sub")
    cell:merge_into(geometry.rectangle(generics.metal(1), 200, 200))
    cell:add_child(sub:copy():translate(0, 500))
    cell:add_child(sub:translate(0, -500))
    cell:merge_into(geometry.path(generics.metal(3), { point.create(-200, 0), point.create(200, 0) }, 50))
end

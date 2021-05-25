function parameters()

end

function layout(cell, _P)
    -- place flat rectangle
    cell:merge_into(geometry.rectangle(generics.metal(1), 200, 200))

    -- place two subcells
    local sub = pcell.create_layout("__test/sub")
    cell:add_child(sub, point.create(0,  500))
    cell:add_child(sub, point.create(0, -500))
end

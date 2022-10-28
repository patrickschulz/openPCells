function parameters()

end

function layout(cell, _P)
    -- place flat rectangle
    --geometry.rectangle(cell, generics.metal(1), 200, 200)

    -- place subcells
    local sub = pcell.create_layout("__test/sub", "sub")
    cell:add_child(sub, "sub0"):translate(   0,  500)
    cell:add_child(sub, "sub2"):translate(   0, -500):flipy()
    cell:add_child(sub, "sub3"):translate( 500,    0)
    cell:add_child(sub, "sub4"):translate(-500,    0)
end

function parameters()

end

function layout(cell, _P)
    local sub = pcell.create_layout("__test/sub")
    cell:merge_into(sub:copy():translate(0, 100))
    cell:merge_into(sub:translate(0, -100))
end

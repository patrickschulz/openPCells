function parameters()

end

function layout(cell, _P)
    local dff = pcell.create_layout("logic/dff")
    cell:merge_into_shallow(dff:flatten())
end

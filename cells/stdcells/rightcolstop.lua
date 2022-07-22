function layout(colstop)
    local cell = pcell.create_layout("stdcells/colstop", { leftnotright = false, fingers = 4 })
    colstop:exchange(cell)
end

function layout(colstop)
    local cell = pcell.create_layout("stdcells/colstop", { leftnotright = false, fingers = 1 })
    colstop:exchange(cell)
end

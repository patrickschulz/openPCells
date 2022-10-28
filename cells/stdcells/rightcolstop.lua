function layout(colstop)
    local cell = pcell.create_layout("stdcells/colstop", "rightcolstop", { leftnotright = false, fingers = 1 })
    colstop:exchange(cell)
end

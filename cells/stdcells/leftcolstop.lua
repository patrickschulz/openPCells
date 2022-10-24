function layout(colstop)
    local cell = pcell.create_layout("stdcells/colstop", "leftcolstop", { fingers = 1 })
    colstop:exchange(cell)
end

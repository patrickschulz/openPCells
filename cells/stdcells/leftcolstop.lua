function layout(colstop)
    local cell = pcell.create_layout("stdcells/colstop", { fingers = 4 })
    colstop:exchange(cell)
end

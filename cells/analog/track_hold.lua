function parameters()

end

function layout(cell, _P)
    local momcap = pcell.create_layout("passive/capacitor/mom")
    local momname = pcell.add_cell_reference(momcap, "momcap")
    local mom1 = cell:add_child(momname)
    mom1:move_anchor("minus")
    local mom2 = cell:add_child(momname)
    mom2:move_anchor("plus")
    mom2:flipy()
end

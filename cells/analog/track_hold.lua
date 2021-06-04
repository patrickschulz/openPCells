function parameters()

end

function layout(cell, _P)
    local momcap = pcell.create_layout("passive/capacitor/mom")
    local momname = cell:add_child_reference(momcap, "momcap")
    local mom1 = cell:add_child_link(momname)
    mom1:move_anchor("minus")
    local mom2 = cell:add_child_link(momname)
    mom2:move_anchor("plus")
    mom2:flipy()
end

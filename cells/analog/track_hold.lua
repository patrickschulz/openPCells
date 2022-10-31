function parameters()

end

function layout(cell, _P)
    local momcap = pcell.create_layout("passive/capacitor/mom", "momcap")
    local mom1 = cell:add_child(momcap, "mom2")
    mom1:move_anchor("minus")
    local mom2 = cell:add_child(momcap, "mom2")
    mom2:move_anchor("plus")
    mom2:flipy()
end

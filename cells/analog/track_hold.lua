function parameters()

end

function layout(cell, _P)
    local momcap = pcell.create_layout("passive/capacitor/mom", "momcap")
    local mom1 = cell:add_child(momcap, "mom1")
    local mom2 = cell:add_child(momcap, "mom2")
    mom2:flipy()
    mom1:align_area_anchor("upperrail", mom2, "upperrail")
end

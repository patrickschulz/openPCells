function parameters()

end

function layout(cell, _P)
    local dff = pcell.create_layout("logic/dff")
    --dff:flatten()
    local ref = cell:add_child_reference(dff)
    local dff1 = cell:add_child_link(ref)
    local dff2 = cell:add_child_link(ref)
    dff2:move_anchor("bottom", dff1:get_anchor("top"))
    dff2:flipy()

    --cell:merge_into(marker.cross(dff2:get_anchor("bottom")))
    --cell:merge_into(marker.cross(dff2:get_anchor("I")))

    local dff3 = pcell.create_layout("logic/dff")
    dff3:flatten()
    dff3:translate(-5000, 0)
    dff3:flipy()
    cell:merge_into(dff3)
    cell:merge_into(marker.cross(dff3:get_anchor("bottom")))
    cell:merge_into(marker.cross(dff3:get_anchor("D")))
    cell:merge_into(marker.cross(dff3:get_anchor("top")))
end

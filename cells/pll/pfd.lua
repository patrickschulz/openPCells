function parameters()
    pcell.add_parameters(
        { "deadzone", false }
    )
end

function layout(pfd, _P)
    local norref = pcell.create_layout("logic/nor_gate")
    local norname = pcell.add_cell_reference(norref, "nor")
    local nor1 = pfd:add_child(norname)
    local nor2 = pfd:add_child(norname)
    nor2:move_anchor("left", nor1:get_anchor("right"))
    local nor3 = pfd:add_child(norname)
    nor3:flipy()
    nor3:move_anchor("top", nor1:get_anchor("bottom"))
    local nor4 = pfd:add_child(norname)
    nor4:flipy()
    nor4:move_anchor("left", nor3:get_anchor("right"))
end

function parameters()
    pcell.reference_cell("logic/base")
    pcell.add_parameter("bitwidth", 8)
end

function layout(register, _P)
    local dffref = pcell.create_layout("logic/dff")
    local dffname = register:add_child_reference(dffref, "dff")
    local anchor = point.create(0, 0)
    for i = 1, _P.bitwidth do
        local dff = register:add_child_link(dffname)
        dff:move_anchor("left", anchor)
        anchor = dff:get_anchor("right")
    end
end

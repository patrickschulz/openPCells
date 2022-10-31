function parameters()
    pcell.reference_cell("stdcells/base")
    pcell.add_parameter("bitwidth", 8)
end

function layout(register, _P)
    local dffref = pcell.create_layout("stdcells/dff", "dff")
    local anchor = point.create(0, 0)
    for i = 1, _P.bitwidth do
        local dff = register:add_child(dffref, string.format("dff_%d", i))
        dff:move_anchor("left", anchor)
        anchor = dff:get_anchor("right")
    end
end

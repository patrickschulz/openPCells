function parameters()
    pcell.reference_cell("stdcells/base")
    pcell.add_parameter("bitwidth", 8)
end

function layout(register, _P)
    local dffref = pcell.create_layout("stdcells/dff")
    local dffname = pcell.add_cell_reference(dffref, "dff")
    local anchor = point.create(0, 0)
    for i = 1, _P.bitwidth do
        local dff = register:add_child(dffname)
        dff:move_anchor("left", anchor)
        anchor = dff:get_anchor("right")
    end
end

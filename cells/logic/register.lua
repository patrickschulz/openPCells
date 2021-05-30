function parameters()
    pcell.reference_cell("logic/base")
    pcell.add_parameter("bitwidth", 8)
end

function layout(register, _P)
    local anchor = point.create(0, 0)
    for i = 1, _P.bitwidth do
        local dff = pcell.create_layout("logic/dff")
        dff:move_anchor("VDD", anchor)
        register:merge_into_shallow(dff)
        anchor = dff:get_anchor("VSS")
    end
end

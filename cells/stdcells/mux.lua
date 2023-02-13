function layout(gate, _P)
    local bp = pcell.get_parameters("stdcells/base")
    local xpitch = bp.gspace + bp.glength

    local gatecontactpos = {
        "upper", "lower", "center"
    }

    local contactpos = { "power", "inner", "inner", "power" }
    local harness = pcell.create_layout("stdcells/harness", "harness", {
        gatecontactpos = gatecontactpos,
        pcontactpos = contactpos,
        ncontactpos = contactpos,
    })
    gate:merge_into(harness)
    gate:inherit_alignment_box(harness)

    -- ports
    gate:add_port("A", generics.metalport(1), harness:get_area_anchor("G1").bl)
    gate:add_port("B", generics.metalport(1), harness:get_area_anchor("G1").bl)
    gate:add_port("O", generics.metalport(1), point.create((3 + 1) * xpitch / 2, 0))
    gate:add_port("VDD", generics.metalport(1), harness:get_area_anchor("PRp").bl)
    gate:add_port("VSS", generics.metalport(1), harness:get_area_anchor("PRn").bl)
end

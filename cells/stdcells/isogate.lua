function config()
    pcell.set_property("hidden", true)
end

function parameters()
    pcell.inherit_parameters("stdcells/base")
end

function layout(gate, _P)
    local xpitch = _P.gspace + _P.glength

    local harness = pcell.create_layout("stdcells/harness", "mosfets", {
        gatecontactpos = { "dummy" },
        pcontactpos = { "power", "power" },
        ncontactpos = { "power", "power" },
        pwidthoffset = _P.pwidthoffset,
        nwidthoffset = _P.nwidthoffset,
        drawdummyactivecontacts = false,
    })
    gate:merge_into(harness)

    gate:inherit_alignment_box(harness)

    gate:add_port("VDD", generics.metalport(1), harness:get_area_anchor("PRp").bl)
    gate:add_port("VSS", generics.metalport(1), harness:get_area_anchor("PRn").bl)

    -- center gate
    gate:translate(xpitch / 2, 0)
end

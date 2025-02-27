function parameters()
    pcell.add_parameter("fingers", 1)
    pcell.add_parameter("pwidthoffset", 0)
    pcell.add_parameter("nwidthoffset", 0)
    pcell.add_parameter("shiftinput", 0)
    pcell.add_parameter("inputpos", "center", { posvals = set("center", "lower", "upper") })
    pcell.add_parameter("shiftoutput", 0)
    pcell.add_parameter("swapoddcorrectiongate", false)
    pcell.add_parameter("connectoutput", true)
    pcell.inherit_parameters("stdcells/harness")
end

function layout(gate, _P)
    local xpitch = _P.gspace + _P.glength

    local gatecontactpos = {}
    for i = 1, _P.fingers do gatecontactpos[i] = _P.inputpos end

    local contactpos = {}
    for i = 1, _P.fingers + 1 do
        if i % 2 == 0 then
            contactpos[i] = "inner"
        else
            contactpos[i] = "power"
        end
    end
    if _P.fingers % 2 == 1 then
        if _P.swapoddcorrectiongate then
            table.insert(gatecontactpos, 1, "dummy")
        else
            table.insert(gatecontactpos, "dummy")
        end
        table.insert(contactpos, "power")
    end
    local harness = pcell.create_layout("stdcells/harness", "mosfets", {
        pwidthoffset = _P.pwidthoffset,
        nwidthoffset = _P.nwidthoffset,
        shiftgatecontacts = _P.shiftinput,
        gatecontactpos = gatecontactpos,
        pcontactpos = contactpos,
        ncontactpos = contactpos,
    })
    gate:merge_into(harness)
    gate:inherit_alignment_box(harness)

    -- gate strap
    if _P.fingers > 1 then
        geometry.rectanglebltr(
            gate, generics.metal(1),
            harness:get_area_anchor("G1").bl,
            harness:get_area_anchor(string.format("G%d", _P.fingers)).tr
        )
    end

    -- signal transistors drain connections
    if _P.connectoutput then
        geometry.path_cshape(gate, generics.metal(1),
            harness:get_area_anchor(string.format("pSD%d", 2)).br:translate(0, _P.sdwidth / 2),
            harness:get_area_anchor(string.format("nSD%d", 2)).tr:translate(0, -_P.sdwidth / 2),
            harness:get_area_anchor(string.format("G%d", _P.fingers)).bl:translate(xpitch + _P.shiftoutput, 0),
            _P.sdwidth
        )
    end

    -- ports
    if _P.swapoddcorrectiongate then
        gate:add_port("I", generics.metalport(1), harness:get_area_anchor("G2").bl)
    else
        gate:add_port("I", generics.metalport(1), harness:get_area_anchor("G1").bl)
    end
    --if _P.connectoutput then
        gate:add_port("O", generics.metalport(1), harness:get_area_anchor(string.format("G%d", _P.fingers)).bl:translate(xpitch + _P.shiftoutput, 0))
    --end
    gate:add_port("VDD", generics.metalport(1), harness:get_area_anchor("PRp").bl)
    gate:add_port("VSS", generics.metalport(1), harness:get_area_anchor("PRn").bl)
end

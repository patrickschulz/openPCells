function parameters()
    pcell.add_parameters(
        { "fingers", 1 },
        { "shiftinput", 0 },
        { "inputpos", "center", posvals = set("center", "lower", "upper") },
        { "shiftoutput", technology.get_dimension("Minimum M1 Space") },
        { "swapoddcorrectiongate", false },
        { "connectoutput", true }
    )
    pcell.inherit_parameters("stdcells/base")
end

function layout(gate, _P)
    local xpitch = _P.gatespace + _P.gatelength

    local inputpos
    if _P.inputpos == "lower" then
        inputpos = "lower1"
    elseif _P.inputpos == "upper" then
        inputpos = "upper1"
    else
        inputpos = "center"
    end
    local gatecontactpos = {}
    for i = 1, _P.fingers do gatecontactpos[i] = inputpos end

    local contactpos = {}
    for i = 1, _P.fingers + 1 do
        if i % 2 == 0 then
            contactpos[i] = "inner"
        else
            contactpos[i] = "power"
        end
    end
    if _P.fingers % 2 == 1 then
        if _P.xalign_method == "sourcedrain" then
            if _P.swapoddcorrectiongate then
                table.insert(gatecontactpos, 1, "dummy")
            else
                table.insert(gatecontactpos, "dummy")
            end
            table.insert(contactpos, "power")
        end
    end
    local baseparameters = {}
    for name, value in pairs(_P) do
        if pcell.has_parameter("stdcells/harness", name) then
            baseparameters[name] = value
        end
    end
    local harness = pcell.create_layout("stdcells/harness", "mosfets", util.add_options(baseparameters, {
        gatecontactpos = gatecontactpos,
        pcontactpos = contactpos,
        ncontactpos = contactpos,
    }))
    gate:merge_into(harness)
    gate:inherit_alignment_box(harness)

    -- gate strap
    gate:add_area_anchor_bltr("gatestrap",
        harness:get_area_anchor("G1").bl,
        harness:get_area_anchor(string.format("G%d", _P.fingers)).tr
    )
    geometry.rectanglebltr(
        gate, generics.metal(1),
        gate:get_area_anchor("gatestrap").bl,
        gate:get_area_anchor("gatestrap").tr
    )

    -- signal transistors drain connections
    if _P.connectoutput then
        geometry.path_cshape(gate, generics.metal(1),
            harness:get_area_anchor(string.format("pSD%d", 2)).bl:translate(0, _P.sdwidth / 2),
            harness:get_area_anchor(string.format("nSD%d", 2)).tl:translate(0, -_P.sdwidth / 2),
            gate:get_area_anchor("gatestrap").tr:translate_x(_P.sdwidth / 2 + _P.shiftoutput),
            _P.sdwidth
        )
    end

    -- ports
    if _P.swapoddcorrectiongate then
        gate:add_area_anchor_bltr("I",
            harness:get_area_anchor("G2").bl,
            harness:get_area_anchor("G2").tr
        )
    else
        gate:add_area_anchor_bltr("I",
            harness:get_area_anchor("G1").bl,
            harness:get_area_anchor("G1").tr
        )
    end
    gate:add_label("I", generics.metalport(1), gate:get_area_anchor("I").bl)
    gate:add_area_anchor_bltr("O",
        harness:get_area_anchor(string.format("G%d", _P.fingers)).bl:translate_x(xpitch + _P.shiftoutput),
        harness:get_area_anchor(string.format("G%d", _P.fingers)).tl:translate_x(xpitch + _P.shiftoutput)
    )
    if _P.connectoutput then
        gate:add_label("O", generics.metalport(1), gate:get_area_anchor("O").bl)
    end
    gate:inherit_area_anchor_as(harness, "PRp", "VDD")
    gate:inherit_area_anchor_as(harness, "PRn", "VSS")
    gate:add_label("VDD", generics.metalport(1), gate:get_area_anchor("VDD").bl)
    gate:add_label("VSS", generics.metalport(1), gate:get_area_anchor("VSS").bl)
end

function config()
    pcell.set_property("hidden", true)
end

function parameters()
    pcell.add_parameters(
        { "fingers",       1 },
        { "gatetype", "nand" },
        { "swapinputs", false },
        { "shiftoutput", technology.get_dimension("Minimum M1 Space") }
    )
    pcell.inherit_parameters("stdcells/base")
end

function layout(gate, _P)
    local xpitch = _P.gatespace + _P.gatelength

    local gatecontactpos = { }
    for i = 1, 2 * _P.fingers do
        if not _P.swapinputs then
            if i % 4 > 1 then
                gatecontactpos[i] = "upper1"
            else
                gatecontactpos[i] = "lower1"
            end
        else
            if i % 4 > 1 then
                gatecontactpos[i] = "lower1"
            else
                gatecontactpos[i] = "upper1"
            end
        end
    end

    local pcontacts = {}
    local ncontacts = {}
    for i = 1, 2 * _P.fingers + 1 do
        if i % 2 == 0 then
            pcontacts[i] = "inner"
        else
            pcontacts[i] = "power"
        end
        if i % 4 == 1 then
            ncontacts[i] = "power"
        elseif i % 4 == 3 then
            ncontacts[i] = "inner"
        else
            ncontacts[i] = "unused"
        end
    end

    if _P.fingers % 2 == 1 then
        if _P.xalign_method ~= "rails" then
            gatecontactpos[#gatecontactpos + 1] = "dummy"
            pcontacts[#pcontacts + 1] = "power"
            ncontacts[#ncontacts + 1] = "power"
        end
    end

    local baseparameters = {}
    for k, v in pairs(_P) do
        if pcell.has_parameter("stdcells/harness", k) then
            baseparameters[k] = v
        end
    end
    local harness = pcell.create_layout("stdcells/harness", "mosfets", util.add_options(baseparameters, {
        gatecontactpos = gatecontactpos,
        pcontactpos = _P.gatetype == "nand" and pcontacts or ncontacts,
        ncontactpos = _P.gatetype == "nand" and ncontacts or pcontacts,
    }))
    gate:merge_into(harness)
    gate:inherit_alignment_box(harness)

    -- gate straps
    gate:add_area_anchor_bltr("A_gatestrap",
        point.create(
            harness:get_area_anchor("G1").l,
            harness:get_area_anchor("G1").b
        ),
        point.create(
            harness:get_area_anchor_fmt("G%d", 2 * _P.fingers).r,
            harness:get_area_anchor("G1").t
        )
    )
    gate:add_area_anchor_bltr("B_gatestrap",
        point.create(
            harness:get_area_anchor("G1").l,
            harness:get_area_anchor("G2").b
        ),
        point.create(
            harness:get_area_anchor_fmt("G%d", 2 * _P.fingers).r,
            harness:get_area_anchor("G2").t
        )
    )
    geometry.rectangleareaanchor(gate, generics.metal(1), "A_gatestrap")
    geometry.rectangleareaanchor(gate, generics.metal(1), "B_gatestrap")

    -- drain connection
    local yinvert = _P.gatetype == "nand" and 1 or -1
    local startpt, endpt
    --local connpt = harness:get_area_anchor(string.format("G%d", 2 * _P.fingers)).bl:translate(xpitch + _P.gatelength / 2 + _P.shiftoutput, 0)
    local connpt = gate:get_area_anchor("A_gatestrap").tr:translate_x(_P.sdwidth / 2 + _P.shiftoutput)
    if _P.gatetype == "nand" then
        startpt = harness:get_area_anchor("nSD3").tr:translate(0, -yinvert * _P.sdwidth / 2)
        endpt = harness:get_area_anchor("pSD2").br:translate(0, yinvert * _P.sdwidth / 2)
    else
        startpt = harness:get_area_anchor("pSD3").br:translate(0, -yinvert * _P.sdwidth / 2)
        endpt = harness:get_area_anchor(string.format("%sSD2", "n")).tr:translate(0, yinvert * _P.sdwidth / 2)
    end
    geometry.path_cshape(gate, generics.metal(1),
        startpt, endpt, connpt,
        _P.sdwidth
    )

    -- input ports
    gate:add_port_with_anchor("A", generics.metalport(1), harness:get_area_anchor("G1").bl:translate_y(_P.routingwidth / 2))
    gate:add_port_with_anchor("B", generics.metalport(1), harness:get_area_anchor("G2").bl:translate(-xpitch, _P.routingwidth / 2))

    gate:add_area_anchor_bltr("output",
        point.create(
            gate:get_area_anchor("A_gatestrap").r + _P.shiftoutput,
            gate:get_area_anchor("A_gatestrap").b
        ),
        point.create(
            gate:get_area_anchor("A_gatestrap").r + _P.sdwidth + _P.shiftoutput,
            gate:get_area_anchor("B_gatestrap").t
        )
    )
    gate:add_port("O", generics.metalport(1), 
        point.create(
            gate:get_area_anchor("output").l,
            gate:get_area_anchor("output").b
        )
    )
    gate:add_port_with_anchor("VDD", generics.metalport(1), harness:get_area_anchor("PRp").bl)
    gate:add_port_with_anchor("VSS", generics.metalport(1), harness:get_area_anchor("PRn").bl)
end

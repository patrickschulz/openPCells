function parameters()
    pcell.add_parameters(
        { "fingers", 2 },
        { "splitenables", true },
        { "inputpos", "center" },
        { "enableppos", "upper1" },
        { "enablenpos", "lower1" },
        { "swapinputs", false },
        { "swapoutputs", false },
        { "shiftoutput", 0 },
        { "connectoutput", true }
    )
    pcell.inherit_parameters("stdcells/base")
end

function layout(gate, _P)
    local xpitch = _P.gatespace + _P.gatelength
    local xincr = 1

    local fingers = (_P.splitenables and 3 or 2) * _P.fingers

    local gatecontactpos = {}
    if _P.splitenables then
        for i = 1, _P.fingers do
            if i % 2 == 1 then
                if i == 1 then
                    table.insert(gatecontactpos, "dummy")
                end
                table.insert(gatecontactpos, _P.enablenpos)
                table.insert(gatecontactpos, _P.enableppos)
                table.insert(gatecontactpos, _P.inputpos)
            else
                table.insert(gatecontactpos, _P.inputpos)
                table.insert(gatecontactpos, _P.enableppos)
                table.insert(gatecontactpos, _P.enablenpos)
                if i == _P.fingers then
                    table.insert(gatecontactpos, "dummy")
                end
            end
        end
    else
        for i = 1, _P.fingers do
            if i % 2 == 1 then
                if i == 1 then
                    table.insert(gatecontactpos, "dummy")
                end
                table.insert(gatecontactpos, _P.inputpos)
                table.insert(gatecontactpos, "split")
            else
                table.insert(gatecontactpos, "split")
                table.insert(gatecontactpos, _P.inputpos)
                if i == _P.fingers then
                    table.insert(gatecontactpos, "dummy")
                end
            end
        end
    end

    dprint("gatecontactpos")
    for _, v in ipairs(gatecontactpos) do dprint(v) end
    dprint()

    local pcontactpos = {}
    local ncontactpos = {}
    if _P.splitenables then
        table.insert(ncontactpos, "power")
        table.insert(ncontactpos, "inner")
        table.insert(ncontactpos, "unused")
        table.insert(ncontactpos, "power")
        table.insert(ncontactpos, "power")
        table.insert(pcontactpos, "power")
        table.insert(pcontactpos, "inner")
        table.insert(pcontactpos, "outer")
        table.insert(pcontactpos, "outer")
        table.insert(pcontactpos, "power")
        -- fingers = 2
        table.insert(ncontactpos, "power")
        table.insert(ncontactpos, "unused")
        table.insert(ncontactpos, "inner")
        table.insert(pcontactpos, "outer")
        table.insert(pcontactpos, "outer")
        table.insert(pcontactpos, "inner")
    else
        local numcontacts = #gatecontactpos + 1
        local contactpool = { "inner", "unused", "power" }
        local poolindex = 1
        local pooldir = true
        for i = 1, numcontacts do
            if (i == 1) or (i == numcontacts) then
                table.insert(ncontactpos, "dummyouter")
                table.insert(pcontactpos, "dummyouter")
            else
                table.insert(ncontactpos, contactpool[poolindex])
                table.insert(pcontactpos, contactpool[poolindex])
                poolindex = poolindex + (pooldir and 1 or -1)
                if (poolindex < 1) or (poolindex > 3) then
                    poolindex = 2
                    pooldir = not pooldir
                end
            end
        end
    end

    dprint("s/d contactpos")
    for _, v in ipairs(pcontactpos) do dprint(v) end

    while #ncontactpos > #gatecontactpos + 1 do
        table.remove(ncontactpos)
        table.remove(pcontactpos)
    end
    while #ncontactpos < #gatecontactpos + 1 do
        table.insert(ncontactpos, "fullpower")
        table.insert(pcontactpos, "fullpower")
    end

    local baseparameters = {}
    for name, value in pairs(_P) do
        if pcell.has_parameter("stdcells/harness", name) then
            baseparameters[name] = value
        end
    end
    local harness = pcell.create_layout("stdcells/harness", "mosfets", util.add_options(baseparameters, {
        gatecontactpos = gatecontactpos,
        pcontactpos = pcontactpos,
        ncontactpos = ncontactpos,
    }))
    gate:merge_into(harness)
    gate:inherit_alignment_box(harness)

    -- gate straps
    if _P.fingers > 1 then
        if _P.splitenables then
            geometry.rectanglebltr(gate, generics.metal(1),
                harness:get_area_anchor("G2").br,
                harness:get_area_anchor(string.format("G%d",
                    _P.fingers % 2 == 0 and
                        1 + (3 * _P.fingers) or
                        1 + (3 * _P.fingers - 2)
                )).tl
            )
            geometry.rectanglebltr(gate, generics.metal(1),
                harness:get_area_anchor("G3").br,
                harness:get_area_anchor(string.format("G%d",
                    3 * _P.fingers
                )).tl
            )
            geometry.rectanglepoints(gate, generics.metal(1),
                harness:get_area_anchor("G5").br,
                harness:get_area_anchor(string.format("G%d",
                    _P.fingers % 2 == 0 and
                        1 + (3 * _P.fingers - 3) or
                        1 + (3 * _P.fingers)
                )).tl
            )
        else
            if _P.swapinputs then
                geometry.path(
                    gate, generics.metal(1),
                    {
                        harness:get_area_anchor("G3").bl,
                        harness:get_area_anchor(string.format("G%d",
                            _P.fingers % 2 == 0 and
                                1 + (2 * _P.fingers - 1) or
                                1 + (2 * _P.fingers)
                        )).bl,
                    },
                    _P.sdwidth
                )
                geometry.path(
                    gate, generics.metal(1),
                    {
                        harness:get_area_anchor("Gupper2").bl,
                        harness:get_area_anchor(string.format("Gupper%d",
                            _P.fingers % 2 == 0 and
                                1 + (2 * _P.fingers) or
                                1 + (2 * _P.fingers - 1)
                        )).bl,
                    },
                    _P.sdwidth
                )
                geometry.path(
                    gate, generics.metal(1),
                    {
                        harness:get_area_anchor("Glower2").bl,
                        harness:get_area_anchor(string.format("Glower%d",
                            _P.fingers % 2 == 0 and
                                1 + (2 * _P.fingers) or
                                1 + (2 * _P.fingers - 1)
                        )).bl,
                    },
                    _P.sdwidth
                )
            else
                geometry.rectanglebltr(gate, generics.metal(1),
                    harness:get_area_anchor("G2").br,
                    harness:get_area_anchor(string.format("G%d",
                        _P.fingers % 2 == 0 and
                            1 + (2 * _P.fingers) or
                            1 + (2 * _P.fingers - 1)
                    )).tl
                )
                geometry.rectanglebltr(gate, generics.metal(1),
                    harness:get_area_anchor("Gupper3").br,
                    harness:get_area_anchor(string.format("Gupper%d",
                        _P.fingers % 2 == 0 and
                            1 + (2 * _P.fingers - 1) or
                            1 + (2 * _P.fingers)
                    )).tl
                )
                geometry.rectanglebltr(gate, generics.metal(1),
                    harness:get_area_anchor("Glower3").br,
                    harness:get_area_anchor(string.format("Glower%d",
                        _P.fingers % 2 == 0 and
                            1 + (2 * _P.fingers - 1) or
                            1 + (2 * _P.fingers)
                    )).tl
                )
            end
        end
    end

    -- drain connection
    if _P.connectoutput then
        geometry.path_cshape(gate, generics.metal(1),
            harness:get_area_anchor(string.format("pSD%d", 2)).br:translate(0,  _P.sdwidth / 2),
            harness:get_area_anchor(string.format("nSD%d", 2)).tr:translate(0, -_P.sdwidth / 2),
            harness:get_area_anchor(string.format("Gbase%d", #gatecontactpos)).bl:translate_x(_P.shiftoutput + 1 * xpitch / 4),
            _P.sdwidth
        )
    end

    -- short transistors
    if _P.splitenables then
        for i = 1, _P.fingers do
            geometry.rectanglebltr(gate, generics.metal(1),
                harness:get_area_anchor(string.format("pSD%d", 1 + (i - 1) * 3 + 2)).tr:translate_y(-_P.sdwidth),
                harness:get_area_anchor(string.format("pSD%d", 1 + (i - 1) * 3 + 3)).tl
            )
        end
    end

    --[[
    -- ports
    if _P.splitenables then
        gate:add_port("I", generics.metalport(1), harness:get_area_anchor("G4").bl)
        gate:add_port("EP", generics.metalport(1), harness:get_area_anchor("G3").bl)
        gate:add_port("EN", generics.metalport(1), harness:get_area_anchor("G2").bl)
    else
        if _P.swapinputs then
            gate:add_port("I", generics.metalport(1), harness:get_area_anchor("G3").bl)
            gate:add_port("EP", generics.metalport(1), harness:get_area_anchor("Gupper2").bl)
            gate:add_port("EN", generics.metalport(1), harness:get_area_anchor("Glower2").bl)
        else
            gate:add_port("I", generics.metalport(1), harness:get_area_anchor("G2").bl)
            gate:add_port("EP", generics.metalport(1), harness:get_area_anchor("Gupper3").bl)
            gate:add_port("EN", generics.metalport(1), harness:get_area_anchor("Glower3").bl)
        end
    end
    gate:add_port("O", generics.metalport(1), point.create(_P.fingers * xpitch + _P.shiftoutput, 0))
    gate:add_port("VDD", generics.metalport(1), harness:get_area_anchor("PRp").bl)
    gate:add_port("VSS", generics.metalport(1),  harness:get_area_anchor("PRn").bl)
    --]]
end

function parameters()
    pcell.add_parameters(
        { "glength", technology.get_dimension("Minimum Gate Length") },
        { "gspace", technology.get_dimension("Minimum Gate XSpace") },
        { "fingers", 2 },
        { "pwidth", 2 * technology.get_dimension("Minimum Gate Width") },
        { "nwidth", 2 * technology.get_dimension("Minimum Gate Width") },
        { "gatestrapwidth", technology.get_dimension("Minimum M1 Width") },
        { "sdwidth", technology.get_dimension("Minimum M1 Width") },
        { "sdspace", technology.get_dimension("Minimum M1 Space") },
        { "powerspace", technology.get_dimension("Minimum M1 Space") },
        { "nmosflippedwell", false },
        { "pmosflippedwell", false },
        { "guardringwidth", technology.get_dimension("Minimum M1 Width") },
        { "nmosvthtype", 1 },
        { "pmosvthtype", 1 }
    )
end

function layout(tgate, _P)
    local guardringxsep = 300
    local guardringysep = 400
    local baseopt = {
        gatelength = _P.glength,
        gatespace = _P.gspace,
        fingers = _P.fingers,
        sdwidth = _P.sdwidth,
        connectsource = true,
        connectsourcewidth = _P.sdwidth,
        connectsourcespace = _P.sdspace,
        connectdrain = true,
        connectdrainwidth = _P.sdwidth,
        connectdrainspace = _P.sdspace,
        connectdrainmetal = 2,
        drawdrainvia = true,
        drawguardring = true,
        guardringwidth = _P.guardringwidth,
        guardringxsep = guardringxsep,
        guardringysep = guardringysep,
        guardringsegments = { "top", "bottom", "left", "right" },
        drawtopgate = true,
        topgatestrspace = _P.sdwidth + 2 * _P.sdspace,
        topgatestrwidth = _P.gatestrapwidth,
        drawbotgate = true,
        botgatestrspace = _P.sdwidth + 2 * _P.sdspace,
        botgatestrwidth = _P.gatestrapwidth,
    }
    local pmos = pcell.create_layout("basic/mosfet", "pmos", util.add_options(baseopt, {
        channeltype = "pmos",
        fingers = _P.fingers,
        fingerwidth = _P.pwidth,
        vthtype = _P.pmosvthtype,
        flippedwell = _P.pmosflippedwell,
    })
    local nmos = pcell.create_layout("basic/mosfet", "nmos", util.add_options(baseopt, {
        channeltype = "nmos",
        fingers = _P.fingers,
        fingerwidth = _P.nwidth,
        vthtype = _P.nmosvthtype,
        flippedwell = _P.nmosflippedwell,
    })
    pmos:abut_area_anchor_top("outerguardring", nmos, "outerguardring")
    pmos:translate(0, _P.sdwidth + 2 * _P.powerspace)
    tgate:merge_into(pmos)
    tgate:merge_into(nmos)

    -- additional rails between guard rings
    geometry.rectanglebltr(tgate, generics.metal(1),
        nmos:get_area_anchor("outerguardring").tl:translate(0, _P.powerspace),
        pmos:get_area_anchor("outerguardring").br:translate(0, -_P.powerspace)
    )
    geometry.rectanglebltr(tgate, generics.metal(1),
        pmos:get_area_anchor("outerguardring").tl:translate(0, _P.powerspace),
        pmos:get_area_anchor("outerguardring").tr:translate(0, _P.powerspace + _P.sdwidth)
    )
    geometry.rectanglebltr(tgate, generics.metal(1),
        nmos:get_area_anchor("outerguardring").bl:translate(0, -_P.powerspace - _P.sdwidth),
        nmos:get_area_anchor("outerguardring").br:translate(0, -_P.powerspace)
    )
    tgate:add_area_anchor_bltr("lowerrail",
        nmos:get_area_anchor("outerguardring").bl:translate(0, -_P.powerspace - _P.sdwidth),
        nmos:get_area_anchor("outerguardring").br:translate(0, -_P.powerspace)
    )
    tgate:add_area_anchor_bltr("middlerail",
        nmos:get_area_anchor("outerguardring").tl:translate(0, _P.powerspace),
        pmos:get_area_anchor("outerguardring").br:translate(0, -_P.powerspace)
    )
    tgate:add_area_anchor_bltr("upperrail",
        pmos:get_area_anchor("outerguardring").tl:translate(0, _P.powerspace),
        pmos:get_area_anchor("outerguardring").tr:translate(0, _P.powerspace + _P.sdwidth)
    )

    -- connect top and bottom gate strap
    local gateconnoffset = 200
    geometry.polygon(tgate, generics.metal(1), {
        nmos:get_area_anchor("botgatestrap").tl,
        nmos:get_area_anchor("botgatestrap").tl:translate_x(-gateconnoffset),
        nmos:get_area_anchor("topgatestrap").bl:translate_x(-gateconnoffset),
        nmos:get_area_anchor("topgatestrap").bl,
        nmos:get_area_anchor("topgatestrap").tl,
        nmos:get_area_anchor("topgatestrap").tl:translate_x(-gateconnoffset - _P.gatestrapwidth),
        nmos:get_area_anchor("botgatestrap").bl:translate_x(-gateconnoffset - _P.gatestrapwidth),
        nmos:get_area_anchor("botgatestrap").bl
    })
    geometry.polygon(tgate, generics.metal(1), {
        pmos:get_area_anchor("botgatestrap").tl,
        pmos:get_area_anchor("botgatestrap").tl:translate_x(-gateconnoffset),
        pmos:get_area_anchor("topgatestrap").bl:translate_x(-gateconnoffset),
        pmos:get_area_anchor("topgatestrap").bl,
        pmos:get_area_anchor("topgatestrap").tl,
        pmos:get_area_anchor("topgatestrap").tl:translate_x(-gateconnoffset - _P.gatestrapwidth),
        pmos:get_area_anchor("botgatestrap").bl:translate_x(-gateconnoffset - _P.gatestrapwidth),
        pmos:get_area_anchor("botgatestrap").bl
    })
    --geometry.polygon(tgate, generics.metal(1), {
    --    nmos:get_area_anchor("botgatestrap").br,
    --    nmos:get_area_anchor("botgatestrap").br:translate_x(gateconnoffset + _P.gatestrapwidth),
    --    nmos:get_area_anchor("topgatestrap").tr:translate_x(gateconnoffset + _P.gatestrapwidth),
    --    nmos:get_area_anchor("topgatestrap").tr,
    --    nmos:get_area_anchor("topgatestrap").br,
    --    nmos:get_area_anchor("topgatestrap").br:translate_x(gateconnoffset),
    --    nmos:get_area_anchor("botgatestrap").tr:translate_x(gateconnoffset),
    --    nmos:get_area_anchor("botgatestrap").tl,
    --})
    --geometry.polygon(tgate, generics.metal(1), {
    --    pmos:get_area_anchor("botgatestrap").br,
    --    pmos:get_area_anchor("botgatestrap").br:translate_x(gateconnoffset + _P.gatestrapwidth),
    --    pmos:get_area_anchor("topgatestrap").tr:translate_x(gateconnoffset + _P.gatestrapwidth),
    --    pmos:get_area_anchor("topgatestrap").tr,
    --    pmos:get_area_anchor("topgatestrap").br,
    --    pmos:get_area_anchor("topgatestrap").br:translate_x(gateconnoffset),
    --    pmos:get_area_anchor("botgatestrap").tr:translate_x(gateconnoffset),
    --    pmos:get_area_anchor("botgatestrap").tl,
    --})

    -- input connection
    local inputconnoffset = 500
    geometry.polygon(tgate, generics.metal(3), {
        nmos:get_area_anchor("sourcestrap").tl,
        nmos:get_area_anchor("sourcestrap").tl:translate_x(-inputconnoffset),
        pmos:get_area_anchor("sourcestrap").bl:translate_x(-inputconnoffset),
        pmos:get_area_anchor("sourcestrap").bl,
        pmos:get_area_anchor("sourcestrap").tl,
        pmos:get_area_anchor("sourcestrap").tl:translate_x(-inputconnoffset - _P.sdwidth),
        nmos:get_area_anchor("sourcestrap").bl:translate_x(-inputconnoffset - _P.sdwidth),
        nmos:get_area_anchor("sourcestrap").bl,
    })
    geometry.viabltr(tgate, 1, 3,
        nmos:get_area_anchor("sourcestrap").bl,
        nmos:get_area_anchor("sourcestrap").tr
    )
    geometry.viabltr(tgate, 1, 3,
        pmos:get_area_anchor("sourcestrap").bl,
        pmos:get_area_anchor("sourcestrap").tr
    )

    -- output connection
    local outputconnoffset = 500
    geometry.polygon(tgate, generics.metal(2), {
        nmos:get_area_anchor("drainstrap").br,
        nmos:get_area_anchor("drainstrap").br:translate_x(outputconnoffset + _P.sdwidth),
        pmos:get_area_anchor("drainstrap").tr:translate_x(outputconnoffset + _P.sdwidth),
        pmos:get_area_anchor("drainstrap").tr,
        pmos:get_area_anchor("drainstrap").br,
        pmos:get_area_anchor("drainstrap").br:translate_x(outputconnoffset),
        nmos:get_area_anchor("drainstrap").tr:translate_x(outputconnoffset),
        nmos:get_area_anchor("drainstrap").tr,
    })

    -- alignmentbox
    tgate:set_alignment_box(
        nmos:get_area_anchor("outerguardring").bl:translate(0, -_P.powerspace - _P.sdwidth),
        pmos:get_area_anchor("outerguardring").tr:translate(0, _P.powerspace + _P.sdwidth),
        nmos:get_area_anchor("innerguardring").bl:translate(0, -_P.guardringwidth - _P.powerspace),
        pmos:get_area_anchor("innerguardring").tr:translate(0, _P.guardringwidth + _P.powerspace)
    )

    --tgate:add_area_anchor_bltr("clkp", pmos:get_area_anchor("topgatestrap").bl, pmos:get_area_anchor("topgatestrap").tr)
    --tgate:add_area_anchor_bltr("clkn", nmos:get_area_anchor("botgatestrap").bl, nmos:get_area_anchor("botgatestrap").tr)
    --tgate:add_port("input", generics.metalport(1), (pmos:get_area_anchor("sourcestrap").cl + nmos:get_area_anchor("sourcestrap").cl):translate(-inputconnoffset, 0))
    tgate:add_area_anchor_bltr("input",
        point.combine(
            pmos:get_area_anchor("sourcestrap").tr,
            nmos:get_area_anchor("sourcestrap").br
        ):translate(-inputconnoffset - _P.sdwidth, -_P.sdwidth / 2),
        point.combine(
            pmos:get_area_anchor("sourcestrap").tr,
            nmos:get_area_anchor("sourcestrap").br
        ):translate(-inputconnoffset, _P.sdwidth / 2)
    )
    tgate:add_area_anchor_bltr("output",
        point.combine(
            pmos:get_area_anchor("drainstrap").tr,
            nmos:get_area_anchor("drainstrap").br
        ):translate(outputconnoffset, -_P.sdwidth / 2),
        point.combine(
            pmos:get_area_anchor("drainstrap").tr,
            nmos:get_area_anchor("drainstrap").br
        ):translate(outputconnoffset + _P.sdwidth, _P.sdwidth / 2)
    )
end

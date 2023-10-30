function parameters()
    pcell.add_parameters(
        { "gatelength", technology.get_dimension("Minimum Gate Length") },
        { "gatespace", technology.get_dimension("Minimum Gate XSpace") },
        { "fingerwidth", technology.get_dimension("Minimum Gate Width") },
        { "buffingers", 2 },
        { "switchfingers", 8 },
        { "pfetvthtype", 3 },
        { "nfetvthtype", 1 },
        { "sdwidth", technology.get_dimension("Minimum M1 Width") },
        { "sdspace", technology.get_dimension("Minimum M1 Space") },
        { "gstrwidth", technology.get_dimension("Minimum M1 Width") },
        { "gstrspace", technology.get_dimension("Minimum M1 Space") },
        { "powerwidth", 3 * technology.get_dimension("Minimum M1 Width") },
        { "powerspace", 3 * technology.get_dimension("Minimum M1 Space") }
    )
end

function layout(switch, _P)
    local separation = 200
    local pmosbuf1 = pcell.create_layout("basic/mosfet", "pmosbuf1", {
        channeltype = "pmos",
        gatelength = _P.gatelength,
        gatespace = _P.gatespace,
        flippedwell = false,
        vthtype = _P.pfetvthtype,
        drawtopgate = true,
        topgatestrwidth = _P.gstrwidth,
        topgatestrspace = _P.powerwidth + _P.powerspace + _P.gstrspace,
        fingers = _P.buffingers,
        fwidth = _P.fingerwidth,
        connectsource = true,
        connectsourcemetal = 1,
        drawsourcevia = true,
        connectsourcewidth = _P.powerwidth,
        connectsourcespace = _P.powerspace,
        connectdrainmetal = 2,
        drawdrainvia = true,
        connectdraininline = true,
        gtopext = 1.5 * _P.powerspace + _P.powerwidth,
        gbotext = separation,
    })

    local nmosbuf1 = pcell.create_layout("basic/mosfet", "nmosbuf1", {
        channeltype = "nmos",
        gatelength = _P.gatelength,
        gatespace = _P.gatespace,
        flippedwell = true,
        vthtype = _P.nfetvthtype,
        drawbotgate = true,
        botgatestrwidth = _P.gstrwidth,
        botgatestrspace = _P.powerwidth + _P.powerspace + _P.gstrspace,
        fingers = _P.buffingers,
        fwidth = _P.fingerwidth,
        connectsource = true,
        connectsourcemetal = 1,
        drawsourcevia = true,
        connectsourcewidth = _P.powerwidth,
        connectsourcespace = _P.powerspace,
        connectdrain = true,
        connectdrainmetal = 2,
        drawdrainvia = true,
        connectdraininline = true,
        gbotext = 1.5 * _P.powerspace + _P.powerwidth,
        gtopext = separation,
        drawbotgcut = true,
        botgcutwidth = _P.gstrspace,
    })

    local pmosdummy1 = pcell.create_layout("basic/mosfet", "pmosdummy1", {
        channeltype = "pmos",
        gatelength = _P.gatelength,
        gatespace = _P.gatespace,
        flippedwell = false,
        vthtype = _P.pfetvthtype,
        fingers = 1,
        fwidth = _P.fingerwidth,
        drawtopgate = true,
        topgatestrwidth = _P.powerwidth,
        topgatestrspace = _P.powerspace,
        topgatestrapextendleft = (_P.gstrwidth + _P.gstrspace) / 2,
        topgatestrapextendright = (_P.gstrwidth + _P.gstrspace) / 2,
        gtopext = 1.5 * _P.powerspace + _P.powerwidth,
        drawbotgcut = true,
        botgcutwidth = 0.5 * _P.gstrspace,
        gbotext = separation,
    })
    local nmosdummy1 = pcell.create_layout("basic/mosfet", "nmosdummy1", {
        channeltype = "nmos",
        gatelength = _P.gatelength,
        gatespace = _P.gatespace,
        flippedwell = true,
        vthtype = _P.nfetvthtype,
        fingers = 1,
        fwidth = _P.fingerwidth,
        drawbotgate = true,
        botgatestrwidth = _P.powerwidth,
        botgatestrspace = _P.powerspace,
        botgatestrapextendleft = (_P.gstrwidth + _P.gstrspace) / 2,
        botgatestrapextendright = (_P.gstrwidth + _P.gstrspace) / 2,
        gbotext = _P.powerwidth + 1.5 * _P.powerspace,
        drawbotgcut = true,
        botgcutwidth = _P.gstrspace,
        gtopext = separation,
    })


    local pmosbuf2 = pcell.create_layout("basic/mosfet", "pmosbuf2", {
        channeltype = "pmos",
        gatelength = _P.gatelength,
        gatespace = _P.gatespace,
        flippedwell = false,
        vthtype = _P.pfetvthtype,
        drawtopgate = true,
        topgatestrwidth = _P.gstrwidth,
        topgatestrspace = _P.powerwidth + _P.powerspace + _P.gstrspace,
        fingers = _P.buffingers,
        fwidth = _P.fingerwidth,
        connectsource = true,
        connectsourcemetal = 1,
        connectsourcewidth = _P.powerwidth,
        connectsourcespace = _P.powerspace,
        connectdrainmetal = 3,
        drawdrainvia = true,
        connectdraininline = true,
        gtopext = 1.5 * _P.powerspace + _P.powerwidth,
        gbotext = separation,
    })

    local nmosbuf2 = pcell.create_layout("basic/mosfet", "nmosbuf2", {
        channeltype = "nmos",
        gatelength = _P.gatelength,
        gatespace = _P.gatespace,
        flippedwell = true,
        vthtype = _P.nfetvthtype,
        drawbotgate = true,
        botgatestrwidth = _P.gstrwidth,
        botgatestrspace = _P.powerwidth + _P.powerspace + _P.gstrspace,
        fingers = _P.buffingers,
        fwidth = _P.fingerwidth,
        connectsource = true,
        connectsourcemetal = 1,
        connectsourcewidth = _P.powerwidth,
        connectsourcespace = _P.powerspace,
        connectdrainmetal = 3,
        drawdrainvia = true,
        connectdraininline = true,
        gbotext = 1.5 * _P.powerspace + _P.powerwidth,
        drawbotgcut = true,
        botgcutwidth = _P.gstrspace,
        gtopext = separation,
    })

    local tgatepmos = pcell.create_layout("basic/mosfet", "tgatepmos", {
        channeltype = "pmos",
        gatelength = _P.gatelength,
        gatespace = _P.gatespace,
        flippedwell = false,
        vthtype = _P.pfetvthtype,
        drawbotgate = true,
        botgatestrwidth = _P.gstrwidth,
        botgatestrspace = _P.gstrspace,
        botgatestrapextendleft = (_P.gstrwidth + _P.gstrspace) / 2,
        botgatestrapextendright = (_P.gstrwidth + _P.gstrspace) / 2,
        fingers = _P.switchfingers,
        fwidth = _P.fingerwidth,
        connectsource = true,
        connectsourcemetal = 1,
        connectsourcewidth = 2 * _P.sdwidth,
        connectsourcespace = _P.sdspace,
        connectdrain = true,
        connectdrainmetal = 3,
        drawdrainvia = true,
        connectdraininline = true,
        gtopext = 1.5 * _P.powerspace + _P.powerwidth,
        gbotext = 1.5 * _P.gstrspace + _P.gstrwidth,
        drawbotgcut = true,
        botgcutwidth = 0.5 * _P.gstrspace,
    })

    local nmos1 = pcell.create_layout("basic/mosfet", "nmos1", {
        channeltype = "nmos",
        gatelength = _P.gatelength,
        gatespace = _P.gatespace,
        flippedwell = true,
        vthtype = _P.nfetvthtype,
        drawtopgate = true,
        topgatestrwidth = _P.gstrwidth,
        topgatestrspace = _P.gstrspace,
        topgatestrapextendleft = (_P.gstrwidth + _P.gstrspace) / 2,
        topgatestrapextendright = (_P.gstrwidth + _P.gstrspace) / 2,
        fingers = _P.switchfingers,
        fwidth = _P.fingerwidth,
        connectsource = true,
        connectsourcemetal = 1,
        drawsourcevia = true,
        connectsourcewidth = 2 * _P.sdwidth,
        connectsourcespace = _P.sdspace,
        connectdrain = true,
        connectdrainmetal = 3,
        drawdrainvia = true,
        connectdraininline = true,
        gtopext = 1.5 * _P.powerspace + _P.powerwidth,
        gbotext = 1.5 * _P.powerspace + _P.powerwidth,
        drawbotgcut = true,
        botgcutwidth = _P.gstrspace,
    })

    local pmosdummy2 = pmosdummy1:copy()
    local nmosdummy2 = nmosdummy1:copy()

    pmosbuf1:abut_area_anchor_top("gate1", nmosbuf1, "gate1")
    pmosdummy1:align_bottom(pmosbuf1)
    pmosdummy1:abut_right(pmosbuf1)
    nmosdummy1:align_bottom(nmosbuf1)
    nmosdummy1:abut_right(nmosbuf1)
    pmosbuf2:align_bottom(pmosdummy1)
    pmosbuf2:abut_right(pmosdummy1)
    nmosbuf2:align_bottom(nmosdummy1)
    nmosbuf2:abut_right(nmosdummy1)
    pmosdummy2:align_bottom(pmosbuf2)
    pmosdummy2:abut_right(pmosbuf2)
    nmosdummy2:align_bottom(nmosbuf2)
    nmosdummy2:abut_right(nmosbuf2)
    tgatepmos:align_bottom(pmosdummy2)
    tgatepmos:abut_right(pmosdummy2)
    nmos1:align_bottom(nmosdummy2)
    nmos1:abut_right(nmosdummy2)

    switch:merge_into(nmosbuf1)
    switch:merge_into(pmosbuf1)
    switch:merge_into(nmosdummy1)
    switch:merge_into(pmosdummy1)
    switch:merge_into(nmosbuf2)
    switch:merge_into(pmosbuf2)
    switch:merge_into(pmosdummy2)
    switch:merge_into(nmosdummy2)
    switch:merge_into(nmos1)
    switch:merge_into(tgatepmos)

    --[[
    -- connect buffer1 and 2
    geometry.rectanglebltr(switch, generics.metal(2),
        nmosbuf1:get_area_anchor("sourcedrain2").tl,
        pmosbuf1:get_area_anchor("sourcedrain2").br
    )
    geometry.viabltr(switch, 1, 2,
        pmosbuf2:get_area_anchor("botgatestrap").bl,
        pmosbuf2:get_area_anchor("botgatestrap").tr
    )
    geometry.rectanglebltr(switch, generics.metal(2),
        point.combine_12(pmosbuf1:get_area_anchor("sourcedrain2").br, pmosbuf2:get_area_anchor("botgatestrap").bl),
        pmosbuf2:get_area_anchor("botgatestrap").tl
    )

    -- connect buf2 and switches
    geometry.rectanglebltr(switch, generics.metal(3),
        nmosbuf2:get_area_anchor("sourcedrain2").tl,
        pmosbuf2:get_area_anchor("sourcedrain2").br
    )
    geometry.viabltr(switch, 1, 3,
        nmos1:get_area_anchor("topgatestrap").bl,
        nmos1:get_area_anchor("topgatestrap").tl:translate_x(2 * (_P.gatelength + _P.gatespace) + _P.sdwidth)
    )
    geometry.rectanglebltr(switch, generics.metal(1),
        pmosbuf2:get_area_anchor("botgatestrap").br,
        tgatepmos:get_area_anchor("botgatestrap").tl
    )
    geometry.rectanglebltr(switch, generics.metal(3),
        point.combine_12(pmosbuf2:get_area_anchor("sourcedrain2").br, nmos1:get_area_anchor("topgatestrap").bl),
        nmos1:get_area_anchor("topgatestrap").tl
    )

    -- connect switches drains and source
    geometry.rectanglebltr(switch, generics.metal(3),
        nmos1:get_area_anchor("sourcedrain8").tl,
        tgatepmos:get_area_anchor("sourcedrain8").br
    )

    -- connect input
    geometry.viabltr(switch, 1, 2,
        tgatepmos:get_area_anchor("sourcedrain-1").bl,
        tgatepmos:get_area_anchor("sourcedrain-1").tr
    )
    geometry.viabltr(switch, 1, 2,
        nmos1:get_area_anchor("sourcedrain-1").bl,
        nmos1:get_area_anchor("sourcedrain-1").tr
    )
    geometry.rectanglebltr(switch, generics.metal(2),
        nmos1:get_area_anchor("sourcedrain-1").tl,
        tgatepmos:get_area_anchor("sourcedrain-1").br
    )

    ---- port metal and anchor
    ---- sample
    --geometry.viabltr(switch, 1, 2,
    --    pmosbuf1:get_area_anchor("botgatestrap").bl:translate( - _P.sdspace, 0),
    --    pmosbuf1:get_area_anchor("botgatestrap").tl
    --)
    --switch:add_area_anchor_bltr("sample",
    --    pmosbuf1:get_area_anchor("botgatestrap").bl:translate( - _P.sdspace, 0),
    --    pmosbuf1:get_area_anchor("botgatestrap").tl
    --)

    ---- vout
    --geometry.path(switch, generics.metal(3),{
    --    nmos1:get_area_anchor("sourcedrain8").bl,
    --    tgatepmos:get_area_anchor("sourcedrain8").tl
    --}, 100)
    --switch:add_area_anchor_bltr("vout", nmos1:get_area_anchor("sourcedrain8").bl:translate( -50, 0), tgatepmos:get_area_anchor("sourcedrain8").tl:translate( 50, 0))

    -- add ports
    switch:add_port("VDD", generics.metalport(1), pmosbuf1:get_area_anchor("sourcestrap").bl)
    switch:add_port("VSS", generics.metalport(1), nmosbuf1:get_area_anchor("sourcestrap").bl)
    switch:add_port("sample", generics.metalport(1), pmosbuf1:get_area_anchor("botgatestrap").bl)
    switch:add_port("vin", generics.metalport(1), nmos1:get_area_anchor("sourcestrap").bl)
    switch:add_port("vout", generics.metalport(3), tgatepmos:get_area_anchor("sourcedrain8").bl)

    -- anchors and alignment box
    switch:add_area_anchor_bltr("VDD", pmosbuf1:get_anchor("sourcestrapbl"), pmosdummy2:get_anchor("topgatestraptr"))
    switch:add_area_anchor_bltr("VSS", nmosbuf1:get_anchor("sourcestrapbl"), nmosdummy2:get_anchor("botgatestraptr"))
    switch:add_area_anchor_bltr("vinup", tgatepmos:get_anchor("sourcestrapbl"), tgatepmos:get_anchor("sourcestraptr"))
    switch:add_area_anchor_bltr("vindown", nmos1:get_anchor("sourcestrapbl"), nmos1:get_anchor("sourcestraptr"))
    switch:set_alignment_box(
        nmosbuf1:get_anchor("sourcestrapbl"):translate(- 0.5 * _P.gatespace + 0.5 * _P.sdwidth - 10, - 0.5 * _P.powerspace),
        point.combine_12(tgatepmos:get_anchor("sourcedrainrighttr"), pmosbuf1:get_anchor("sourcestraptr")):translate( 0.5 * _P.gatespace - 0.5 * _P.sdwidth + 10, 0.5 * _P.powerspace)
    )
    --]]
end

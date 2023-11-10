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
    --buffer1
    local pmosbuf1 = pcell.create_layout("basic/mosfet", "pmosbuf1", {
        channeltype = "pmos",
        flippedwell = false,
        vthtype = _P.pfetvthtype,
        drawbotgate = true,
        botgatestrwidth = _P.gstrwidth,
        botgatestrspace = 2 * _P.gstrspace + _P.gstrwidth,
        fingers = _P.buffingers,
        fingerwidth = _P.fingerwidth,
        connectsource = true,
        connectsourcemetal = 1,
        drawsourcevia = true,
        connectsourcewidth = _P.powerwidth,
        connectsourcespace =  _P.powerspace,
        connectdrainmetal = 2,
        drawdrainvia = true,
        connectdraininline = true,
        extendimplantbot = - _P.gstrwidth - _P.gstrspace / 2,
        extendvthbot = - _P.gstrwidth - _P.gstrspace / 2,
        extendwellbot = - _P.gstrwidth - _P.gstrspace / 2,
        gtopext = 1.5 * _P.powerspace + _P.powerwidth,
        gbotext = _P.gstrspace + _P.gstrwidth,
    })

    local nmosbuf1 = pcell.create_layout("basic/mosfet", "nmosbuf1", {
        channeltype = "nmos",
        flippedwell = true,
        vthtype = _P.nfetvthtype,
        drawtopgate = true,
        topgatestrwidth = _P.gstrwidth,
        topgatestrspace = _P.gstrspace,
        topgatestrapextendleft = (_P.gstrwidth + _P.gstrspace) / 2,
        topgatestrapextendright = (_P.gstrwidth + _P.gstrspace) / 2,
        fingers = _P.buffingers,
        fingerwidth = _P.fingerwidth,
        connectsource = true,
        connectsourcemetal = 1,
        drawsourcevia = true,
        connectsourcewidth = _P.powerwidth,
        connectsourcespace = _P.powerspace,
        --        connectdrain = true,
        connectdrainmetal = 2,
        drawdrainvia = true,
        connectdraininline = true,
        extendimplanttop = _P.gstrspace / 2,
        extendvthtop = _P.gstrspace / 2,
        extendwelltop = _P.gstrspace / 2,
        gbotext = 1.5 * _P.powerspace + _P.powerwidth,
        drawbotgcut = true,
        botgcutwidth = _P.gstrspace,
    })

    --dummy1
    local pmosdummy1 = pcell.create_layout("basic/mosfet", "pmosdummy1", {
        channeltype = "pmos",
        flippedwell = false,
        vthtype = _P.pfetvthtype,
        fingers = 1,
        fingerwidth = _P.fingerwidth,
        drawtopgate = true,
        topgatestrwidth = _P.powerwidth,
        topgatestrspace = _P.powerspace,
        topgatestrapextendleft = (_P.gstrwidth + _P.gstrspace) / 2,
        topgatestrapextendright = (_P.gstrwidth + _P.gstrspace) / 2,
        gtopext = 1.5 * _P.powerspace + _P.powerwidth,
        gbotext = 1.5 * _P.gstrspace + _P.gstrwidth,
        drawbotgcut = true,
        botgcutwidth = 0.5 * _P.gstrspace,
    })
    local nmosdummy1 = pcell.create_layout("basic/mosfet", "nmosdummy1", {
        channeltype = "nmos",
        flippedwell = true,
        vthtype = _P.nfetvthtype,
        fingers = 1,
        fingerwidth = _P.fingerwidth,
        drawbotgate = true,
        botgatestrwidth = _P.powerwidth,
        botgatestrspace = _P.powerspace,
        botgatestrapextendleft = (_P.gstrwidth + _P.gstrspace) / 2,
        botgatestrapextendright = (_P.gstrwidth + _P.gstrspace) / 2,
        gtopext = 1.5 * _P.gstrspace + _P.gstrwidth,
        gbotext = _P.powerwidth + 1.5 * _P.powerspace,
        drawbotgcut = true,
        botgcutwidth = _P.gstrspace,
    })

    --buffer2
    local pmosbuf2 = pcell.create_layout("basic/mosfet", "pmosbuf2", {
        channeltype = "pmos",
        flippedwell = false,
        vthtype = _P.pfetvthtype,
        drawbotgate = true,
        botgatestrwidth = _P.gstrwidth,
        botgatestrspace = _P.gstrspace,
        botgatestrapextendleft = (_P.gstrwidth + _P.gstrspace) / 2,
        botgatestrapextendright = (_P.gstrwidth + _P.gstrspace) / 2,
        fingers = _P.buffingers,
        fingerwidth = _P.fingerwidth,
        connectsource = true,
        connectsourcemetal = 1,
        connectsourcewidth = _P.powerwidth,
        connectsourcespace = _P.powerspace,
        connectdrainmetal = 2,
        drawdrainvia = true,
        connectdraininline = true,
        extendimplantbot = _P.gstrspace / 2,
        extendvthbot = _P.gstrspace / 2,
        extendwellbot = _P.gstrspace / 2,
        gtopext = 1.5 * _P.powerspace + _P.powerwidth,
        gbotext = _P.gstrspace + _P.gstrwidth,
    })

    local nmosbuf2 = pcell.create_layout("basic/mosfet", "nmosbuf2", {
        channeltype = "nmos",
        flippedwell = true,
        vthtype = _P.nfetvthtype,
        drawtopgate = true,
        topgatestrwidth = _P.gstrwidth,
        topgatestrspace = 2 * _P.gstrspace + _P.gstrwidth,
        topgatestrapextendleft = (_P.gstrwidth + _P.gstrspace) / 2,
        topgatestrapextendright = (_P.gstrwidth + _P.gstrspace) / 2,
        fingers = _P.buffingers,
        fingerwidth = _P.fingerwidth,
        connectsource = true,
        connectsourcemetal = 1,
        connectsourcewidth = _P.powerwidth,
        connectsourcespace = _P.powerspace,
        connectdrainmetal = 2,
        drawdrainvia = true,
        connectdraininline = true,
        extendimplanttop = - _P.gstrwidth - _P.gstrspace / 2,
        extendvthtop = - _P.gstrwidth - _P.gstrspace / 2,
        extendwelltop = - _P.gstrwidth - _P.gstrspace / 2,
        gbotext = 1.5 * _P.powerspace + _P.powerwidth,
        drawbotgcut = true,
        botgcutwidth = _P.gstrspace,
    })

    --dummy2
    local pmosdummy2 = pmosdummy1:copy()
    local nmosdummy2 = nmosdummy1:copy()

    --switches
    local pmos1 = pcell.create_layout("basic/mosfet", "pmos1", {
        channeltype = "pmos",
        flippedwell = false,
        vthtype = _P.pfetvthtype,
        drawbotgate = true,
        botgatestrwidth = _P.gstrwidth,
        botgatestrspace = _P.gstrspace,
        botgatestrapextendleft = (_P.gstrwidth + _P.gstrspace) / 2,
        botgatestrapextendright = (_P.gstrwidth + _P.gstrspace) / 2,
        fingers = _P.switchfingers,
        fingerwidth = _P.fingerwidth,
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
        flippedwell = true,
        vthtype = _P.nfetvthtype,
        drawtopgate = true,
        topgatestrwidth = _P.gstrwidth,
        topgatestrspace = _P.gstrspace,
        topgatestrapextendleft = (_P.gstrwidth + _P.gstrspace) / 2,
        topgatestrapextendright = (_P.gstrwidth + _P.gstrspace) / 2,
        fingers = _P.switchfingers,
        fingerwidth = _P.fingerwidth,
        connectsource = true,
        connectsourcemetal = 1,
        drawsourcevia = true,
        connectsourcewidth = 2 * _P.sdwidth,
        connectsourcespace = _P.sdspace,
        connectdrain = true,
        connectdrainmetal = 3,
        drawdrainvia = true,
        connectdraininline = true,
        extendimplanttop = - 4 *_P.gstrspace,
        extendvthtop = - 4 *_P.gstrspace,
        extendwelltop = - 4 *_P.gstrspace,
        gtopext = 1.5 * _P.powerspace + _P.powerwidth,
        gbotext = 1.5 * _P.powerspace + _P.powerwidth,
        drawbotgcut = true,
        botgcutwidth = _P.gstrspace,
    })

    pmosbuf1:align_area_anchor_top("botgatestrap", nmosbuf1, "topgatestrap")
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
    pmos1:align_bottom(pmosdummy2)
    pmos1:abut_right(pmosdummy2)
    nmos1:align_bottom(nmosdummy2)
    nmos1:abut_right(nmosdummy2)

    --connect buffer1 and 2
    geometry.rectanglebltr(switch, generics.metal(2),
        nmosbuf1:get_area_anchor("sourcedrain2").tl,
        pmosbuf1:get_area_anchor("sourcedrain2").br
    )
    --geometry.viabltr(switch, 1, 2,
    --    point.combine_12(nmosdummy1:get_area_anchor("sourcedrain1").tl, pmosbuf2:get_area_anchor("botgatestrap").bl),
    --    nmosbuf2:get_area_anchor("topgatestrap").tl
    --)
    geometry.rectanglebltr(switch, generics.metal(2),
        point.combine_12(pmosbuf1:get_area_anchor("sourcedrain2").br, pmosbuf2:get_area_anchor("botgatestrap").bl),
        pmosbuf2:get_area_anchor("botgatestrap").tl
    )

    --[[
    --connect buf2 and switches
    geometry.path(switch, generics.metal(2),{
        pmosbuf2:get_anchor("sourcedrain2bc"),
        nmosbuf2:get_anchor("sourcedrain2bc")
    }, _P.sdwidth)
    geometry.viabltr(switch, 1, 2,
    point.combine_12(nmosbuf2:get_anchor("sourcedrain2cr"),nmos1:get_anchor("topgatestrapbl")),
    nmos1:get_anchor("topgatestraptl")
    )
    geometry.path(switch, generics.metal(1),{
        pmosbuf2:get_anchor("botgatestrapcr"),
        pmos1:get_anchor("botgatestrapcl")
    }, _P.sdwidth)

    --connect switches drains and source
    geometry.path(switch, generics.metal(3),{
        pmos1:get_anchor("sourcedrain8cc"),
        nmos1:get_anchor("sourcedrain8cc")
    }, _P.sdwidth)
    geometry.viabltr(switch, 1, 2,
    pmos1:get_anchor("sourcedrainrightbl"),
    pmos1:get_anchor("sourcedrainrighttr")
    )
    geometry.viabltr(switch, 1, 2,
    nmos1:get_anchor("sourcedrainrightbl"),
    nmos1:get_anchor("sourcedrainrighttr")
    )
    geometry.path(switch, generics.metal(2),{
        pmos1:get_anchor("sourcedrainrightbc"),
        nmos1:get_anchor("sourcedrainrighttc")
    }, _P.sdwidth)

    --port metal and anchor
    --sample
    geometry.viabltr(switch, 1, 2,
    pmosbuf1:get_anchor("botgatestrapbl"):translate( - _P.sdspace, 0),
    pmosbuf1:get_anchor("botgatestraptl")
    )
    switch:add_anchor_area_bltr("sample",
    pmosbuf1:get_anchor("botgatestrapbl"):translate( - _P.sdspace, 0),
    pmosbuf1:get_anchor("botgatestraptl")
    )

    --vout
    geometry.path(switch, generics.metal(3),{
        nmos1:get_anchor("sourcedrain8bc"),
        pmos1:get_anchor("sourcedrain8tc")
    }, 100)
    switch:add_anchor_area_bltr("vout", nmos1:get_anchor("sourcedrain8bc"):translate( -50, 0), pmos1:get_anchor("sourcedrain8tc"):translate( 50, 0))
    --]]

    switch:merge_into(nmosbuf1:flatten())
    switch:merge_into(pmosbuf1:flatten())
    switch:merge_into(nmosdummy1:flatten())
    switch:merge_into(pmosdummy1:flatten())
    switch:merge_into(nmosbuf2:flatten())
    switch:merge_into(pmosbuf2:flatten())
    switch:merge_into(pmosdummy2:flatten())
    switch:merge_into(nmosdummy2:flatten())
    switch:merge_into(nmos1:flatten())
    switch:merge_into(pmos1:flatten())

    --[[
    -- add ports
    switch:add_port("VDD", generics.metalport(1), pmosbuf1:get_anchor("sourcestrapcc"))
    switch:add_port("VSS", generics.metalport(1), nmosbuf1:get_anchor("sourcestrapcc"))
    switch:add_port("sample", generics.metalport(2), pmosbuf1:get_anchor("botgatestrapcl"))
    switch:add_port("vin", generics.metalport(4), nmos1:get_anchor("sourcestrapcc"))
    switch:add_port("vout", generics.metalport(3), pmos1:get_anchor("sourcedrain8cc"))

    --anchors and alignment box
    switch:add_anchor_area_bltr("VDD", pmosbuf1:get_anchor("sourcestrapbl"), pmosdummy2:get_anchor("topgatestraptr"))
    switch:add_anchor_area_bltr("VSS", nmosbuf1:get_anchor("sourcestrapbl"), nmosdummy2:get_anchor("botgatestraptr"))
    switch:add_anchor_area_bltr("vinup", pmos1:get_anchor("sourcestrapbl"), pmos1:get_anchor("sourcestraptr"))
    switch:add_anchor_area_bltr("vindown", nmos1:get_anchor("sourcestrapbl"), nmos1:get_anchor("sourcestraptr"))
    switch:set_alignment_box(
        nmosbuf1:get_anchor("sourcestrapbl"):translate(- 0.5 * _P.gatespace + 0.5 * _P.sdwidth - 10, - 0.5 * _P.powerspace),
        point.combine_12(pmos1:get_anchor("sourcedrainrighttr"), pmosbuf1:get_anchor("sourcestraptr")):translate( 0.5 * _P.gatespace - 0.5 * _P.sdwidth + 10, 0.5 * _P.powerspace)
    )
    --]]
end

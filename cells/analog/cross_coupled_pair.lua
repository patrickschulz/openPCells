function parameters()
    pcell.add_parameters(
        { "gatelength", 0 },
        { "gatespace", 0 },
        { "gatestrapwidth", 0 },
        { "gatestrapspace", 0 },
        { "gateext", 0 },
        { "sdwidth", 0 },
        { "oxidetype", 1 },
        { "mosfetmarker", 1 },
        { "pvthtype", 1 },
        { "nvthtype", 1 },
        { "activedummywidth", 0 },
        { "activedummyspace", 0 },
        { "powerwidth", 0 },
        { "powerspace", 0 },
        { "fingersperside", 4 },
        { "pmosfingerwidth", 0 },
        { "nmosfingerwidth", 0 },
        { "middledummyfingers", 2 },
        { "outerdummyfingers", 2 },
        { "outputoffset", 0 },
        { "drainstrapspace", 0 },
        { "crossingoffset", 0 },
        { "drawpsubguardring", true },
        { "guardring_width", 0 },
        { "guardring_xspace", 0 },
        { "guardring_yspace", 0 },
        { "guardring_xspacetomosfet", 0 },
        { "guardring_yspacetomosfet", 0 },
        { "guardring_soiopenextension", 0 },
        { "guardring_implantextension", 0 },
        { "guardring_wellextension", 0 },
        { "inlinedrainstrap", false },
        { "topviawidth", 0 },
        { "crossingmetal", 5 },
        { "drainmetal", 7 },
        { "vtailshift", 0 },
        { "vtailwidth", 0 },
        { "vtailmetal", 5 },
        { "vtaillinewidth", 0 },
        { "vtaillinespace", 0 },
        { "fetpowermetal", 3 },
        { "vssmetal", 5 },
        { "vssshift", 0 },
        { "vsswidth", 0 },
        { "vsslinewidth", 0 },
        { "vsslinespace", 0 }
    )
end

function layout(ccp, _P)
    local leftright = object.create("_leftright")

    local baseopt = {
        gatelength = _P.gatelength,
        gatespace = _P.gatespace,
        oxidetype = _P.oxidetype,
        mosfetmarker = _P.mosfetmarker,
        drawtopactivedummy = true,
        topactivedummywidth = _P.activedummywidth,
        topactivedummyspace = _P.activedummyspace,
        drawbottomactivedummy = true,
        bottomactivedummywidth = _P.activedummywidth,
        bottomactivedummyspace = _P.activedummyspace,
        sdwidth = _P.sdwidth,
        topgatewidth = _P.gatestrapwidth,
        topgatespace = _P.gatestrapspace,
        botgatewidth = _P.gatestrapwidth,
        botgatespace = _P.gatestrapspace,
        connectsource = true,
        connectsourcewidth = _P.powerwidth,
        connectsourcespace = _P.powerspace,
        gtopext = _P.gatestrapwidth + _P.gatestrapspace + _P.gateext,
        gbotext = _P.gatestrapwidth + _P.gatestrapspace + _P.gateext,
        extendvthtypeleft = (_P.gatelength + _P.gatespace) / 2,
        extendvthtyperight = (_P.gatelength + _P.gatespace) / 2,
        extendimplantleft = (_P.gatelength + _P.gatespace) / 2,
        extendimplantright = (_P.gatelength + _P.gatespace) / 2,
        extendimplanttop = _P.activedummywidth + _P.activedummyspace + 100 - _P.gatestrapwidth - _P.gatestrapspace - _P.gateext,
        extendimplantbottom = _P.activedummywidth + _P.activedummyspace + 100 - _P.gatestrapwidth - _P.gatestrapspace - _P.gateext,
        extendwellleft = (_P.gatelength + _P.gatespace) / 2,
        extendwellright = (_P.gatelength + _P.gatespace) / 2,
        extendoxidetypeleft = (_P.gatelength + _P.gatespace) / 2,
        extendoxidetyperight = (_P.gatelength + _P.gatespace) / 2,
        lvsmarker = 2,
    }

    local nfetmiddledummy = pcell.create_layout("basic/mosfet", "_nfetmiddledummy", util.add_options(baseopt, {
        channeltype = "nmos",
        flippedwell = true,
        fingerwidth = _P.nmosfingerwidth,
        fingers = _P.middledummyfingers,
        drawbotgate = true,
        connectdrain = true,
        connectdraininverse = true,
        connectdrainwidth = _P.powerwidth,
        connectdrainspace = _P.powerspace,
        botgatewidth = _P.gatestrapwidth,
        botgatespace = _P.powerspace,
    }))
    leftright:merge_into(nfetmiddledummy)
    -- anchor for left/right alignment
    leftright:add_area_anchor_bltr("middlesourcedrain",
        nfetmiddledummy:get_area_anchor("sourcedrain1").bl,
        nfetmiddledummy:get_area_anchor("sourcedrain1").tr
    )

    local pfetmiddledummy = pcell.create_layout("basic/mosfet", "_pfetmiddledummy", util.add_options(baseopt, {
        channeltype = "pmos",
        flippedwell = true,
        fingerwidth = _P.pmosfingerwidth,
        fingers = _P.middledummyfingers,
        drawtopgate = true,
        connectdrain = true,
        connectdraininverse = true,
        connectdrainwidth = _P.powerwidth,
        connectdrainspace = _P.powerspace,
        topgatewidth = _P.gatestrapwidth,
        topgatespace = _P.powerspace,
    }))
    pfetmiddledummy:align_area_anchor("bottomactivedummy", nfetmiddledummy, "topactivedummy")
    pfetmiddledummy:translate_y(2 * _P.guardring_yspacetomosfet + _P.guardring_width + _P.activedummywidth)
    leftright:merge_into(pfetmiddledummy)

    local nfet = pcell.create_layout("basic/mosfet", "_nfet", util.add_options(baseopt, {
        channeltype = "nmos",
        flippedwell = true,
        fingerwidth = _P.nmosfingerwidth,
        fingers = _P.fingersperside,
        drawtopgatevia = true,
        topgatemetal = 5,
        topgateleftextension = (_P.gatelength + _P.gatespace) / 2,
        topgaterightextension = (_P.gatelength + _P.gatespace) / 2,
        drawtopgate = true,
        connectdrain = true,
        connectdraininline = _P.inlinedrainstrap,
        connectdrainwidth = _P.gatestrapwidth,
        --connectdrainspace = -_P.gatestrapwidth,
        connectdrainspace = _P.drainstrapspace,
        connectdraininlineoffset = (_P.nmosfingerwidth - _P.gatestrapwidth) / 2,
        connectdrainleftext = _P.gatelength + _P.gatespace,
        connectdrainrightext = _P.gatelength + _P.gatespace,
        sourcestartmetal = 1,
        sourceendmetal = _P.fetpowermetal,
        drawdrainvia = true,
        --drainmetal = _P.crossingmetal,
        drainmetal = _P.drainmetal,
        --drainviasize = _P.nmosfingerwidth - (_P.inlinedrainstrap and 0 or _P.gatestrapwidth),
        drainviaalign = "bottom",
        splitdrainvias = true,
    }))
    nfet:align_area_anchor("sourcedrain1", nfetmiddledummy, "sourcedrain-1")
    leftright:merge_into(nfet)
    local pfet = pcell.create_layout("basic/mosfet", "_pfet", util.add_options(baseopt, {
        channeltype = "pmos",
        flippedwell = true,
        fingerwidth = _P.pmosfingerwidth,
        fingers = _P.fingersperside,
        drawbotgate = true,
        drawbotgatevia = true,
        botgatemetal = 5,
        botgateleftextension = (_P.gatelength + _P.gatespace) / 2,
        botgaterightextension = (_P.gatelength + _P.gatespace) / 2,
        connectdrain = true,
        connectdraininline = _P.inlinedrainstrap,
        connectdrainwidth = _P.gatestrapwidth,
        --connectdrainspace = -_P.gatestrapwidth,
        connectdrainspace = _P.drainstrapspace,
        connectdraininlineoffset = (_P.pmosfingerwidth - _P.gatestrapwidth) / 2,
        connectdrainleftext = _P.gatelength + _P.gatespace,
        connectdrainrightext = _P.gatelength + _P.gatespace,
        sourcestartmetal = 1,
        sourceendmetal = _P.fetpowermetal,
        drawdrainvia = true,
        --drainmetal = _P.crossingmetal,
        drainmetal = _P.drainmetal,
        --drainviasize = _P.pmosfingerwidth - (_P.inlinedrainstrap and 0 or _P.gatestrapwidth),
        drainviaalign = "top",
        splitdrainvias = true,
    }))
    pfet:align_area_anchor("sourcedrain1", pfetmiddledummy, "sourcedrain-1")
    leftright:merge_into(pfet)

    -- add left/right dummies
    local nfetleftrightdummy = pcell.create_layout("basic/mosfet", "_nfetleftrightdummy", util.add_options(baseopt, {
        channeltype = "nmos",
        flippedwell = true,
        fingerwidth = _P.nmosfingerwidth,
        fingers = _P.outerdummyfingers,
        drawbotgate = true,
        connectdrain = true,
        connectdraininverse = true,
        connectdrainwidth = _P.powerwidth,
        connectdrainspace = _P.powerspace,
        botgatewidth = _P.gatestrapwidth,
        botgatespace = _P.powerspace,
        drawrightstopgate = true,
    }))
    nfetleftrightdummy:align_area_anchor("sourcedrain1", nfet, "sourcedrain-1")
    leftright:merge_into(nfetleftrightdummy)
    local pfetleftrightdummy = pcell.create_layout("basic/mosfet", "_pfetleftrightdummy", util.add_options(baseopt, {
        channeltype = "pmos",
        flippedwell = true,
        fingerwidth = _P.pmosfingerwidth,
        fingers = _P.outerdummyfingers,
        connectdrain = true,
        connectdraininverse = true,
        connectdrainwidth = _P.powerwidth,
        connectdrainspace = _P.powerspace,
        drawtopgate = true,
        topgatewidth = _P.gatestrapwidth,
        topgatespace = _P.powerspace,
        drawrightstopgate = true,
    }))
    pfetleftrightdummy:align_area_anchor("sourcedrain1", pfet, "sourcedrain-1")
    leftright:merge_into(pfetleftrightdummy)

    -- add outer dummies
    local outernfetdummy = pcell.create_layout("basic/mosfet", "_outernfetdummy", util.add_options(baseopt, {
        channeltype = "nmos",
        flippedwell = true,
        fingerwidth = _P.nmosfingerwidth,
        fingers = 0,
        drawleftstopgate = true,
        drawrightstopgate = true,
        drawtopactivedummy = false,
        drawbottomactivedummy = false,
        drawsourcedrain = "none",
        connectsource = false,
    }))
    outernfetdummy:align_top(nfet)
    outernfetdummy:abut_right(nfetleftrightdummy)
    outernfetdummy:translate_x(2 * (_P.gatelength + _P.gatespace))
    leftright:merge_into(outernfetdummy)
    local outerpfetdummy = pcell.create_layout("basic/mosfet", "_outerpfetdummy", util.add_options(baseopt, {
        channeltype = "pmos",
        flippedwell = true,
        fingerwidth = _P.pmosfingerwidth,
        fingers = 0,
        drawleftstopgate = true,
        drawrightstopgate = true,
        drawtopactivedummy = false,
        drawbottomactivedummy = false,
        drawsourcedrain = "none",
        connectsource = false,
    }))
    outerpfetdummy:align_top(pfet)
    outerpfetdummy:abut_right(pfetleftrightdummy)
    outerpfetdummy:translate_x(2 * (_P.gatelength + _P.gatespace))
    leftright:merge_into(outerpfetdummy)

    leftright:inherit_alignment_box(pfet)
    leftright:inherit_alignment_box(outerpfetdummy)
    leftright:inherit_alignment_box(nfet)
    leftright:inherit_alignment_box(outernfetdummy)

    -- copy active anchor from outer dummy for guardring alignment
    leftright:inherit_area_anchor_as(pfet, "topactivedummy", "pfettopactivedummy")
    leftright:inherit_area_anchor_as(pfet, "bottomactivedummy", "pfetbottomactivedummy")
    leftright:inherit_area_anchor_as(nfet, "topactivedummy", "nfettopactivedummy")
    leftright:inherit_area_anchor_as(nfet, "bottomactivedummy", "nfetbottomactivedummy")
    leftright:inherit_area_anchor_as(outernfetdummy, "active", "outernfetdummyactive")
    leftright:inherit_area_anchor_as(outerpfetdummy, "active", "outerpfetdummyactive")

    -- output connection
    leftright:add_area_anchor_bltr("output",
        point.create(
            nfet:get_area_anchor("drainstrap").l + _P.outputoffset,
            (nfet:get_area_anchor("drainstrap").b + pfet:get_area_anchor("drainstrap").t) / 2 - _P.topviawidth / 2
        ),
        point.create(
            nfet:get_area_anchor("drainstrap").r,
            (nfet:get_area_anchor("drainstrap").b + pfet:get_area_anchor("drainstrap").t) / 2 + _P.topviawidth / 2
        )
    )
    geometry.viabltr(leftright, _P.drainmetal, 8,
        leftright:get_area_anchor("output").bl,
        leftright:get_area_anchor("output").tr
    )
    geometry.rectanglebltr(leftright, generics.metal(_P.drainmetal),
        leftright:get_area_anchor("output").bl:translate_x(-_P.outputoffset),
        leftright:get_area_anchor("output").tr
    )

    -- extra drain metal and vias
    geometry.rectanglebltr(leftright, generics.metal(_P.crossingmetal - 1),
        nfet:get_area_anchor("drainstrap").bl,
        nfet:get_area_anchor("drainstrap").tr
    )
    geometry.rectanglebltr(leftright, generics.metal(_P.crossingmetal - 1),
        pfet:get_area_anchor("drainstrap").bl,
        pfet:get_area_anchor("drainstrap").tr
    )
    geometry.rectanglebltr(leftright, generics.metal(_P.crossingmetal),
        nfet:get_area_anchor("drainstrap").bl,
        nfet:get_area_anchor("drainstrap").tr
    )
    geometry.rectanglebltr(leftright, generics.metal(_P.crossingmetal),
        pfet:get_area_anchor("drainstrap").bl,
        pfet:get_area_anchor("drainstrap").tr
    )
    geometry.viabltr(leftright, _P.crossingmetal - 1, _P.drainmetal,
        nfet:get_area_anchor("drainstrap").bl,
        nfet:get_area_anchor("drainstrap").tr
    )
    geometry.viabltr(leftright, _P.crossingmetal - 1, _P.drainmetal,
        pfet:get_area_anchor("drainstrap").bl,
        pfet:get_area_anchor("drainstrap").tr
    )

    leftright:add_area_anchor_bltr("pgate", pfet:get_area_anchor("botgatestrap").bl, pfet:get_area_anchor("botgatestrap").tr)
    leftright:add_area_anchor_bltr("ngate", nfet:get_area_anchor("topgatestrap").bl, nfet:get_area_anchor("topgatestrap").tr)
    leftright:add_area_anchor_bltr("pdrain", pfet:get_area_anchor("drainstrap").bl, pfet:get_area_anchor("drainstrap").tr)
    leftright:add_area_anchor_bltr("ndrain", nfet:get_area_anchor("drainstrap").bl, nfet:get_area_anchor("drainstrap").tr)
    leftright:inherit_area_anchor_as(pfet, "sourcestrap", "ibiasin")
    leftright:inherit_area_anchor_as(nfet, "sourcestrap", "vssin")

    local right = leftright:copy()
    local left = leftright:copy()
    left:mirror_at_yaxis()
    left:align_area_anchor("middlesourcedrain", right, "middlesourcedrain")
    ccp:merge_into(right)
    ccp:merge_into(left)

    -- copy anchors
    ccp:add_area_anchor_bltr("ibiasin",
        left:get_area_anchor("ibiasin").bl,
        right:get_area_anchor("ibiasin").tr
    )
    ccp:add_area_anchor_bltr("vssin",
        left:get_area_anchor("vssin").bl,
        right:get_area_anchor("vssin").tr
    )
    ccp:inherit_area_anchor_as(left, "output", "leftoutput")
    ccp:inherit_area_anchor_as(right, "output", "rightoutput")

    -- crossing:
    geometry.polygon(ccp, generics.metal(_P.crossingmetal), {
        left:get_area_anchor("pgate").br,
        point.create(
            (left:get_area_anchor("pgate").l + right:get_area_anchor("pgate").r) / 2 - _P.gatestrapwidth / 2 + _P.crossingoffset / 2,
            right:get_area_anchor("pgate").b
        ),
        point.create(
            (left:get_area_anchor("pgate").r + right:get_area_anchor("pgate").l) / 2 - _P.gatestrapwidth / 2 + _P.crossingoffset / 2,
            right:get_area_anchor("pdrain").b
        ),
        right:get_area_anchor("pdrain").bl,
        right:get_area_anchor("pdrain").tl,
        point.create(
            (left:get_area_anchor("pgate").r + right:get_area_anchor("pgate").l) / 2 + _P.gatestrapwidth / 2 + _P.crossingoffset / 2,
            right:get_area_anchor("pdrain").t
        ),
        point.create(
            (left:get_area_anchor("pgate").l + right:get_area_anchor("pgate").r) / 2 + _P.gatestrapwidth / 2 + _P.crossingoffset / 2,
            right:get_area_anchor("pgate").t
        ),
        left:get_area_anchor("pgate").tr,
    })
    geometry.polygon(ccp, generics.metal(_P.crossingmetal - 1), {
        right:get_area_anchor("pgate").bl,
        point.create(
            (left:get_area_anchor("pgate").l + right:get_area_anchor("pgate").r) / 2 + _P.gatestrapwidth / 2 - _P.crossingoffset / 2,
            left:get_area_anchor("pgate").b
        ),
        point.create(
            (left:get_area_anchor("pgate").r + right:get_area_anchor("pgate").l) / 2 + _P.gatestrapwidth / 2 - _P.crossingoffset / 2,
            left:get_area_anchor("pdrain").b
        ),
        left:get_area_anchor("pdrain").br,
        left:get_area_anchor("pdrain").tr,
        point.create(
            (left:get_area_anchor("pgate").r + right:get_area_anchor("pgate").l) / 2 - _P.gatestrapwidth / 2 - _P.crossingoffset / 2,
            left:get_area_anchor("pdrain").t
        ),
        point.create(
            (left:get_area_anchor("pgate").l + right:get_area_anchor("pgate").r) / 2 - _P.gatestrapwidth / 2 - _P.crossingoffset / 2,
            left:get_area_anchor("pgate").t
        ),
        right:get_area_anchor("pgate").tl,
    })
    geometry.polygon(ccp, generics.metal(_P.crossingmetal), {
        left:get_area_anchor("ngate").br,
        point.create(
            (left:get_area_anchor("ngate").l + right:get_area_anchor("ngate").r) / 2 + _P.gatestrapwidth / 2 - _P.crossingoffset / 2,
            right:get_area_anchor("ngate").b
        ),
        point.create(
            (left:get_area_anchor("ngate").l + right:get_area_anchor("ngate").r) / 2 + _P.gatestrapwidth / 2 - _P.crossingoffset / 2,
            right:get_area_anchor("ndrain").b
        ),
        right:get_area_anchor("ndrain").bl,
        right:get_area_anchor("ndrain").tl,
        point.create(
            (left:get_area_anchor("ngate").l + right:get_area_anchor("ngate").r) / 2 - _P.gatestrapwidth / 2 - _P.crossingoffset / 2,
            right:get_area_anchor("ndrain").t
        ),
        point.create(
            (left:get_area_anchor("ngate").l + right:get_area_anchor("ngate").r) / 2 - _P.gatestrapwidth / 2 - _P.crossingoffset / 2,
            right:get_area_anchor("ngate").t
        ),
        left:get_area_anchor("ngate").tr,
    })
    geometry.polygon(ccp, generics.metal(_P.crossingmetal - 1), {
        right:get_area_anchor("ngate").bl,
        point.create(
            (left:get_area_anchor("ngate").l + right:get_area_anchor("ngate").r) / 2 - _P.gatestrapwidth / 2 + _P.crossingoffset / 2,
            left:get_area_anchor("ngate").b
        ),
        point.create(
            (left:get_area_anchor("ngate").l + right:get_area_anchor("ngate").r) / 2 - _P.gatestrapwidth / 2 + _P.crossingoffset / 2,
            left:get_area_anchor("ndrain").b
        ),
        left:get_area_anchor("ndrain").br,
        left:get_area_anchor("ndrain").tr,
        point.create(
            (left:get_area_anchor("ngate").l + right:get_area_anchor("ngate").r) / 2 + _P.gatestrapwidth / 2 + _P.crossingoffset / 2,
            left:get_area_anchor("ndrain").t
        ),
        point.create(
            (left:get_area_anchor("ngate").l + right:get_area_anchor("ngate").r) / 2 + _P.gatestrapwidth / 2 + _P.crossingoffset / 2,
            left:get_area_anchor("ngate").t
        ),
        right:get_area_anchor("ngate").tl,
    })

    -- bias current landing pad
    ccp:add_area_anchor_bltr("ibias",
        ccp:get_area_anchor("ibiasin").bl:translate_y(_P.vtailshift),
        ccp:get_area_anchor("ibiasin").br:translate_y(_P.vtailshift + _P.vtailwidth)
    )
    geometry.rectanglebltr(ccp, generics.metal(_P.vtailmetal),
        ccp:get_area_anchor("ibias").bl,
        ccp:get_area_anchor("ibias").tr
    )
    geometry.viabltr(ccp, 1, _P.vtailmetal,
        ccp:get_area_anchor("ibiasin").bl,
        ccp:get_area_anchor("ibiasin").tr
    )
    geometry.rectanglevlines_width_space(ccp, generics.metal(_P.vtailmetal),
        ccp:get_area_anchor("ibias").bl,
        ccp:get_area_anchor("ibiasin").tr,
        _P.vtaillinewidth,
        _P.vtaillinespace
    )

    -- vss landing pad
    ccp:add_area_anchor_bltr("vss",
        ccp:get_area_anchor("vssin").bl:translate_y(
            -_P.vssshift - _P.vsswidth),
        ccp:get_area_anchor("vssin").br:translate_y(-_P.vssshift)
    )
    geometry.rectanglebltr(ccp, generics.metal(_P.vssmetal),
        ccp:get_area_anchor("vss").bl,
        ccp:get_area_anchor("vss").tr
    )
    geometry.viabltr(ccp, 1, _P.vssmetal,
        ccp:get_area_anchor("vssin").bl,
        ccp:get_area_anchor("vssin").tr
    )
    geometry.rectanglevlines_width_space(ccp, generics.metal(_P.vssmetal),
        ccp:get_area_anchor("vss").tl,
        ccp:get_area_anchor("vssin").br,
        _P.vsslinewidth,
        _P.vsslinespace
    )

    -- inner pwell guardring
    layouthelpers.place_guardring(
        ccp,
        point.create(
            left:get_area_anchor("outerpfetdummyactive").l,
            left:get_area_anchor("pfetbottomactivedummy").b
        ),
        point.create(
            right:get_area_anchor("outerpfetdummyactive").r,
            right:get_area_anchor("pfettopactivedummy").t
        ),
        _P.guardring_xspacetomosfet, _P.guardring_yspacetomosfet,
        "pwellguardring_",
        {
            ringwidth = _P.guardring_width,
            contype = "p",
            soiopenextension = _P.guardring_soiopenextension,
            implantextension = _P.guardring_implantextension,
            fit = false,
            fillimplant = true,
        }
    )

    -- nwell guardring
    layouthelpers.place_guardring_with_hole(
        ccp,
        point.create(
            ccp:get_area_anchor("pwellguardring_outerboundary").l,
            left:get_area_anchor("nfetbottomactivedummy").b
        ),
        point.create(
            ccp:get_area_anchor("pwellguardring_outerboundary").r,
            ccp:get_area_anchor("pwellguardring_outerboundary").t
        ),
        ccp:get_area_anchor("pwellguardring_outerboundary").bl,
        ccp:get_area_anchor("pwellguardring_outerboundary").tr,
        _P.guardring_xspacetomosfet, _P.guardring_yspacetomosfet,
        _P.guardring_xspacetomosfet - _P.guardring_wellextension,
        _P.guardring_yspacetomosfet - _P.guardring_wellextension,
        "nwellguardring_",
        {
            ringwidth = _P.guardring_width,
            contype = "n",
            soiopenextension = _P.guardring_soiopenextension,
            implantextension = _P.guardring_implantextension,
            wellextension = _P.guardring_wellextension,
            drawdeepwell = true,
            deepwelloffset = 150,
            fit = false,
        }
    )
    -- lvs device marker
    geometry.rectanglebltr(ccp, generics.other("lvsmarker2"),
        ccp:get_area_anchor("nwellguardring_outerboundary").bl,
        ccp:get_area_anchor("nwellguardring_outerboundary").tr
    )

    local env = {
        smallgroundmesh = {
            width = 500
        }
    }
    if _P.drawpsubguardring then
        layouthelpers.place_guardring_quantized(
            ccp,
            ccp:get_area_anchor("nwellguardring_outerboundary").bl,
            ccp:get_area_anchor("nwellguardring_outerboundary").tr,
            _P.guardring_xspace, _P.guardring_yspace,
            2 * env.smallgroundmesh.width,
            env.smallgroundmesh.width,
            "psubguardring_",
            {
                ringwidth = env.smallgroundmesh.width,
                contype = "p",
                soiopenextension = _P.guardring_soiopenextension,
                implantextension = _P.guardring_implantextension,
                fit = true,
            }
        )
        geometry.unequal_ring_pts(ccp, generics.other("nimplant"),
            ccp:get_area_anchor("psubguardring_innerimplant").bl,
            ccp:get_area_anchor("psubguardring_innerimplant").tr,
            ccp:get_area_anchor("nwellguardring_outerimplant").bl,
            ccp:get_area_anchor("nwellguardring_outerimplant").tr
        )
        geometry.unequal_ring_pts(ccp, generics.other("soiopen"),
            ccp:get_area_anchor("psubguardring_innerimplant").bl,
            ccp:get_area_anchor("psubguardring_innerimplant").tr,
            ccp:get_area_anchor("nwellguardring_outerimplant").bl,
            ccp:get_area_anchor("nwellguardring_outerimplant").tr
        )
    end

    if not _P.drawpsubguardring then
        ccp:clear_alignment_box()
        ccp:inherit_alignment_box(uppernwelluardring)
        ccp:inherit_alignment_box(lowernwelluardring)
    end

    local connwidth = 200
    geometry.rectanglebltr(ccp, generics.metal(1),
        point.create(
            ccp:get_area_anchor("psubguardring_innerboundary").l,
            (ccp:get_area_anchor("pwellguardring_outerboundary").b + ccp:get_area_anchor("pwellguardring_outerboundary").t) / 2 - connwidth / 2
        ),
        point.create(
            ccp:get_area_anchor("pwellguardring_outerboundary").l,
            (ccp:get_area_anchor("pwellguardring_outerboundary").b + ccp:get_area_anchor("pwellguardring_outerboundary").t) / 2 + connwidth / 2
        )
    )
    geometry.rectanglebltr(ccp, generics.metal(1),
        point.create(
            ccp:get_area_anchor("pwellguardring_outerboundary").r,
            (ccp:get_area_anchor("pwellguardring_outerboundary").b + ccp:get_area_anchor("pwellguardring_outerboundary").t) / 2 - connwidth / 2
        ),
        point.create(
            ccp:get_area_anchor("psubguardring_innerboundary").r,
            (ccp:get_area_anchor("pwellguardring_outerboundary").b + ccp:get_area_anchor("pwellguardring_outerboundary").t) / 2 + connwidth / 2
        )
    )

    ccp:add_area_anchor_bltr("guardringtopsegment",
        point.create(
            ccp:get_area_anchor("psubguardring_outerboundary").l,
            ccp:get_area_anchor("psubguardring_innerboundary").t
        ),
        point.create(
            ccp:get_area_anchor("psubguardring_outerboundary").r,
            ccp:get_area_anchor("psubguardring_outerboundary").t
        )
    )
    ccp:add_area_anchor_bltr("guardringbottomsegment",
        point.create(
            ccp:get_area_anchor("psubguardring_outerboundary").l,
            ccp:get_area_anchor("psubguardring_outerboundary").b
        ),
        point.create(
            ccp:get_area_anchor("psubguardring_outerboundary").r,
            ccp:get_area_anchor("psubguardring_innerboundary").b
        )
    )
    ccp:add_area_anchor_bltr("guardring",
        ccp:get_area_anchor("guardringbottomsegment").bl,
        ccp:get_area_anchor("guardringtopsegment").tr
    )

    -- add ports (multiple ports for symmetry for layout extraction)
    ccp:add_port("vss", generics.metalport(1), ccp:get_area_anchor("psubguardring_outerboundary").bl)
    ccp:add_port("vss", generics.metalport(1), ccp:get_area_anchor("psubguardring_outerboundary").br)
    ccp:add_port("vss", generics.metalport(1), ccp:get_area_anchor("psubguardring_outerboundary").tl)
    ccp:add_port("vss", generics.metalport(1), ccp:get_area_anchor("psubguardring_outerboundary").tr)
    ccp:add_port("vss", generics.metalport(_P.vssmetal),
        point.create(
            (ccp:get_area_anchor("vss").l + ccp:get_area_anchor("vss").r) / 2,
            ccp:get_area_anchor("vss").b
        )
    )
    ccp:add_port("vtail", generics.metalport(5),
        point.create(
            (ccp:get_area_anchor("ibias").l + ccp:get_area_anchor("ibias").r) / 2,
            ccp:get_area_anchor("ibias").t
        )
    )
    ccp:add_port("vleft", generics.metalport(8),
        point.create(
            left:get_area_anchor("output").l,
            (left:get_area_anchor("output").b + left:get_area_anchor("output").t) / 2
        )
    )
    ccp:add_port("vright", generics.metalport(8),
        point.create(
            right:get_area_anchor("output").r,
            (right:get_area_anchor("output").b + right:get_area_anchor("output").t) / 2
        )
    )

    -- excludes
    for metal = 1, technology.resolve_metal(-1) do
        geometry.rectanglebltr(ccp,
            generics.metalexclude(metal),
            ccp:get_area_anchor("psubguardring_outerboundary").bl,
            ccp:get_area_anchor("psubguardring_outerboundary").tr
        )
    end

    -- layer boundaries
    ccp:add_layer_boundary(generics.metal(1),
        util.rectangle_to_polygon(
            ccp:get_area_anchor("psubguardring_outerboundary").bl,
            ccp:get_area_anchor("psubguardring_outerboundary").tr
        )
    )
    ccp:add_layer_boundary(generics.metal(_P.vtailmetal),
        util.rectangle_to_polygon(
            ccp:get_area_anchor("ibias").tl,
            ccp:get_area_anchor("ibiasin").tr
        )
    )
    ccp:add_layer_boundary(generics.metal(_P.vssmetal),
        util.rectangle_to_polygon(
            ccp:get_area_anchor("vss").tl,
            ccp:get_area_anchor("vssin").tr
        )
    )
    for metal = 2, technology.resolve_metal(-1) do
        ccp:add_layer_boundary(generics.metal(metal),
            util.rectangle_to_polygon(
                ccp:get_area_anchor("nwellguardring_outerboundary").bl,
                ccp:get_area_anchor("nwellguardring_outerboundary").tr
            )
        )
    end

    -- center ccp
    local diff = point.xaverage(
        ccp:get_alignment_anchor("outerbl"),
        ccp:get_alignment_anchor("outertr")
    )
    ccp:translate_x(-diff)
end

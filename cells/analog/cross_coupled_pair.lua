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
        { "channeltype", "nmos", posvals = set("nmos", "pmos") },
        { "flippedwell", false },
        { "vthtype", 1 },
        { "activedummywidth", 0 },
        { "activedummyspace", 0 },
        { "powerwidth", 0 },
        { "powerspace", 0 },
        { "fingersperside", 4 },
        { "fingerwidth", 0 },
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
        { "gatestrappos", "top", posvals = set("top", "bottom") },
        { "gatemetal", 5 },
        { "crossingmetal", 5 },
        { "drainmetal", 7 },
        { "fetpowermetal", 3 }
    )
end

function layout(ccp, _P)
    local leftright = object.create("_leftright")

    local flipcontacts
    if _P.channeltype == "nmos" then
        if _P.gatestrappos == "top" then
            flipcontacts = false
        else
            flipcontacts = true
        end
    else
        if _P.gatestrappos == "top" then
            flipcontacts = true
        else
            flipcontacts = false
        end
    end
    local baseopt = {
        channeltype = _P.channeltype,
        vthtype = _P.vthtype,
        flippedwell = _P.flippedwell,
        gatelength = _P.gatelength,
        gatespace = _P.gatespace,
        fingerwidth = _P.fingerwidth,
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
        topgatespace = _P.powerspace,
        botgatewidth = _P.gatestrapwidth,
        botgatespace = _P.powerspace,
        connectsource = true,
        connectsourceinverse = flipcontacts,
        connectsourcewidth = _P.powerwidth,
        connectsourcespace = _P.powerspace,
        gtopext = _P.gatestrapwidth + _P.powerspace + _P.gateext,
        gbotext = _P.gatestrapwidth + _P.powerspace + _P.gateext,
        extendvthtypeleft = (_P.gatelength + _P.gatespace) / 2,
        extendvthtyperight = (_P.gatelength + _P.gatespace) / 2,
        extendimplantleft = (_P.gatelength + _P.gatespace) / 2,
        extendimplantright = (_P.gatelength + _P.gatespace) / 2,
        extendimplanttop = _P.activedummywidth + _P.activedummyspace + 100 - _P.gatestrapwidth - _P.powerspace - _P.gateext,
        extendimplantbottom = _P.activedummywidth + _P.activedummyspace + 100 - _P.gatestrapwidth - _P.powerspace - _P.gateext,
        extendwellleft = (_P.gatelength + _P.gatespace) / 2,
        extendwellright = (_P.gatelength + _P.gatespace) / 2,
        extendoxidetypeleft = (_P.gatelength + _P.gatespace) / 2,
        extendoxidetyperight = (_P.gatelength + _P.gatespace) / 2,
        lvsmarker = 2,
    }

    local fetmiddledummy = pcell.create_layout("basic/mosfet", "_fetmiddledummy", util.add_options(baseopt, {
        fingers = _P.middledummyfingers,
        drawbotgate = _P.gatestrappos == "top",
        drawtopgate = _P.gatestrappos == "bottom",
        connectdrain = true,
        connectdraininverse = not flipcontacts,
        connectdrainwidth = _P.powerwidth,
        connectdrainspace = _P.powerspace,
    }))
    leftright:merge_into(fetmiddledummy)
    -- anchor for left/right alignment
    leftright:add_area_anchor_bltr("middlesourcedrain",
        fetmiddledummy:get_area_anchor("sourcedrain1").bl,
        fetmiddledummy:get_area_anchor("sourcedrain1").tr
    )

    local fet = pcell.create_layout("basic/mosfet", "_fet", util.add_options(baseopt, {
        fingers = _P.fingersperside,
        drawtopgate = _P.gatestrappos == "top",
        drawtopgatevia = _P.gatestrappos == "top",
        topgatemetal = _P.crossingmetal,
        topgateleftextension = (_P.gatelength + _P.gatespace) / 2,
        topgaterightextension = (_P.gatelength + _P.gatespace) / 2,
        drawbotgate = _P.gatestrappos == "bottom",
        drawbotgatevia = _P.gatestrappos == "bottom",
        botgatemetal = _P.crossingmetal,
        botgateleftextension = (_P.gatelength + _P.gatespace) / 2,
        botgaterightextension = (_P.gatelength + _P.gatespace) / 2,
        connectdrain = true,
        connectdraininline = _P.inlinedrainstrap,
        connectdrainwidth = _P.gatestrapwidth,
        connectdrainspace = _P.drainstrapspace,
        connectdraininlineoffset = (_P.fingerwidth - _P.gatestrapwidth) / 2,
        connectdrainleftext = _P.gatelength + _P.gatespace,
        connectdrainrightext = _P.gatelength + _P.gatespace,
        sourcestartmetal = 1,
        sourceendmetal = _P.fetpowermetal,
        drawdrainvia = true,
        drainmetal = _P.drainmetal,
        drainviaalign = "bottom",
        splitdrainvias = true,
    }))
    fet:align_area_anchor("sourcedrain1", fetmiddledummy, "sourcedrain-1")
    leftright:merge_into(fet)

    -- add left/right dummies
    local fetleftrightdummy = pcell.create_layout("basic/mosfet", "_fetleftrightdummy", util.add_options(baseopt, {
        fingers = _P.outerdummyfingers,
        drawbotgate = _P.gatestrappos == "top",
        drawtopgate = _P.gatestrappos == "bottom",
        connectdrain = true,
        connectdraininverse = not flipcontacts,
        connectdrainwidth = _P.powerwidth,
        connectdrainspace = _P.powerspace,
        drawrightstopgate = true,
    }))
    fetleftrightdummy:align_area_anchor("sourcedrain1", fet, "sourcedrain-1")
    leftright:merge_into(fetleftrightdummy)

    -- add outer dummies
    local outerfetdummy = pcell.create_layout("basic/mosfet", "_outerfetdummy", util.add_options(baseopt, {
        fingers = 0,
        drawleftstopgate = true,
        drawrightstopgate = true,
        drawtopactivedummy = false,
        drawbottomactivedummy = false,
        drawsourcedrain = "none",
        connectsource = false,
    }))
    outerfetdummy:align_top(fet)
    outerfetdummy:abut_right(fetleftrightdummy)
    outerfetdummy:translate_x(2 * (_P.gatelength + _P.gatespace))
    leftright:merge_into(outerfetdummy)

    leftright:add_area_anchor_bltr("active",
        fetmiddledummy:get_area_anchor("active").bl,
        outerfetdummy:get_area_anchor("active").tr
    )
    leftright:add_area_anchor_bltr("topactivedummy",
        fetmiddledummy:get_area_anchor("topactivedummy").bl,
        fetleftrightdummy:get_area_anchor("topactivedummy").tr
    )
    leftright:add_area_anchor_bltr("bottomactivedummy",
        fetmiddledummy:get_area_anchor("bottomactivedummy").bl,
        fetleftrightdummy:get_area_anchor("bottomactivedummy").tr
    )
    leftright:add_area_anchor_bltr("outerdummyactive",
        outerfetdummy:get_area_anchor("active").bl,
        outerfetdummy:get_area_anchor("active").tr
    )

    leftright:inherit_area_anchor(fet, "drainstrap")
    leftright:inherit_area_anchor_as(fet, "sourcestrap", "common")
    if _P.gatestrappos == "top" then
        leftright:inherit_area_anchor_as(fet, "topgatestrap", "gate")
    else
        leftright:inherit_area_anchor_as(fet, "botgatestrap", "gate")
    end

    local right = leftright:copy()
    local left = leftright:copy()
    left:mirror_at_yaxis()
    left:align_area_anchor("middlesourcedrain", right, "middlesourcedrain")
    ccp:merge_into(right)
    ccp:merge_into(left)

    ccp:add_area_anchor_bltr("active",
        left:get_area_anchor("active").bl,
        right:get_area_anchor("active").tr
    )

    ccp:add_area_anchor_bltr("topactivedummy",
        left:get_area_anchor("topactivedummy").bl,
        right:get_area_anchor("topactivedummy").tr
    )
    ccp:add_area_anchor_bltr("bottomactivedummy",
        left:get_area_anchor("bottomactivedummy").bl,
        right:get_area_anchor("bottomactivedummy").tr
    )
    ccp:add_area_anchor_bltr("leftouterdummyactive",
        left:get_area_anchor("outerdummyactive").bl,
        left:get_area_anchor("outerdummyactive").tr
    )
    ccp:add_area_anchor_bltr("rightouterdummyactive",
        right:get_area_anchor("outerdummyactive").bl,
        right:get_area_anchor("outerdummyactive").tr
    )

    ccp:inherit_area_anchor_as(left, "drainstrap", "leftdrainstrap")
    ccp:inherit_area_anchor_as(right, "drainstrap", "rightdrainstrap")
    ccp:add_area_anchor_bltr("common",
        left:get_area_anchor("common").bl,
        right:get_area_anchor("common").tr
    )

    ccp:inherit_area_anchor_as(left, "gate", "leftgate")
    ccp:inherit_area_anchor_as(right, "gate", "rightgate")

    -- crossing:
    if _P.gatestrappos == "top" then
        geometry.polygon(ccp, generics.metal(_P.crossingmetal), {
            ccp:get_area_anchor("leftgate").br,
            point.create(
                (ccp:get_area_anchor("leftgate").l + ccp:get_area_anchor("rightgate").r) / 2 + _P.gatestrapwidth / 2 - _P.crossingoffset / 2,
                ccp:get_area_anchor("rightgate").b
            ),
            point.create(
                (ccp:get_area_anchor("leftgate").l + ccp:get_area_anchor("rightgate").r) / 2 + _P.gatestrapwidth / 2 - _P.crossingoffset / 2,
                ccp:get_area_anchor("rightdrainstrap").b
            ),
            ccp:get_area_anchor("rightdrainstrap").bl,
            ccp:get_area_anchor("rightdrainstrap").tl,
            point.create(
                (ccp:get_area_anchor("leftgate").l + ccp:get_area_anchor("rightgate").r) / 2 - _P.gatestrapwidth / 2 - _P.crossingoffset / 2,
                ccp:get_area_anchor("rightdrainstrap").t
            ),
            point.create(
                (ccp:get_area_anchor("leftgate").l + ccp:get_area_anchor("rightgate").r) / 2 - _P.gatestrapwidth / 2 - _P.crossingoffset / 2,
                ccp:get_area_anchor("rightgate").t
            ),
            ccp:get_area_anchor("leftgate").tr,
        })
        geometry.polygon(ccp, generics.metal(_P.crossingmetal - 1), {
            ccp:get_area_anchor("rightgate").bl,
            point.create(
                (ccp:get_area_anchor("leftgate").l + ccp:get_area_anchor("rightgate").r) / 2 - _P.gatestrapwidth / 2 + _P.crossingoffset / 2,
                ccp:get_area_anchor("leftgate").b
            ),
            point.create(
                (ccp:get_area_anchor("leftgate").l + ccp:get_area_anchor("rightgate").r) / 2 - _P.gatestrapwidth / 2 + _P.crossingoffset / 2,
                ccp:get_area_anchor("leftdrainstrap").b
            ),
            ccp:get_area_anchor("leftdrainstrap").br,
            ccp:get_area_anchor("leftdrainstrap").tr,
            point.create(
                (ccp:get_area_anchor("leftgate").l + ccp:get_area_anchor("rightgate").r) / 2 + _P.gatestrapwidth / 2 + _P.crossingoffset / 2,
                ccp:get_area_anchor("leftdrainstrap").t
            ),
            point.create(
                (ccp:get_area_anchor("leftgate").l + ccp:get_area_anchor("rightgate").r) / 2 + _P.gatestrapwidth / 2 + _P.crossingoffset / 2,
                ccp:get_area_anchor("leftgate").t
            ),
            ccp:get_area_anchor("rightgate").tl,
        })
    else
        geometry.polygon(ccp, generics.metal(_P.crossingmetal), {
            ccp:get_area_anchor("leftgate").br,
            point.create(
                (ccp:get_area_anchor("leftgate").l + ccp:get_area_anchor("rightgate").r) / 2 - _P.gatestrapwidth / 2 + _P.crossingoffset / 2,
                ccp:get_area_anchor("rightgate").b
            ),
            point.create(
                (ccp:get_area_anchor("leftgate").r + ccp:get_area_anchor("rightgate").l) / 2 - _P.gatestrapwidth / 2 + _P.crossingoffset / 2,
                ccp:get_area_anchor("rightdrainstrap").b
            ),
            ccp:get_area_anchor("rightdrainstrap").bl,
            ccp:get_area_anchor("rightdrainstrap").tl,
            point.create(
                (ccp:get_area_anchor("leftgate").r + ccp:get_area_anchor("rightgate").l) / 2 + _P.gatestrapwidth / 2 + _P.crossingoffset / 2,
                ccp:get_area_anchor("rightdrainstrap").t
            ),
            point.create(
                (ccp:get_area_anchor("leftgate").l + ccp:get_area_anchor("rightgate").r) / 2 + _P.gatestrapwidth / 2 + _P.crossingoffset / 2,
                ccp:get_area_anchor("rightgate").t
            ),
            ccp:get_area_anchor("leftgate").tr,
        })
        geometry.polygon(ccp, generics.metal(_P.crossingmetal - 1), {
            ccp:get_area_anchor("rightgate").bl,
            point.create(
                (ccp:get_area_anchor("leftgate").l + ccp:get_area_anchor("rightgate").r) / 2 + _P.gatestrapwidth / 2 - _P.crossingoffset / 2,
                ccp:get_area_anchor("leftgate").b
            ),
            point.create(
                (ccp:get_area_anchor("leftgate").r + ccp:get_area_anchor("rightgate").l) / 2 + _P.gatestrapwidth / 2 - _P.crossingoffset / 2,
                ccp:get_area_anchor("leftdrainstrap").b
            ),
            ccp:get_area_anchor("leftdrainstrap").br,
            ccp:get_area_anchor("leftdrainstrap").tr,
            point.create(
                (ccp:get_area_anchor("leftgate").r + ccp:get_area_anchor("rightgate").l) / 2 - _P.gatestrapwidth / 2 - _P.crossingoffset / 2,
                ccp:get_area_anchor("leftdrainstrap").t
            ),
            point.create(
                (ccp:get_area_anchor("leftgate").l + ccp:get_area_anchor("rightgate").r) / 2 - _P.gatestrapwidth / 2 - _P.crossingoffset / 2,
                ccp:get_area_anchor("leftgate").t
            ),
            ccp:get_area_anchor("rightgate").tl,
        })
    end
end

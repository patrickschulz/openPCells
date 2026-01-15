function parameters()
    pcell.add_parameters(
        { "gatelength",  technology.get_dimension("Minimum Gate Length") },
        { "gatespace", technology.get_dimension("Minimum Gate XSpace", "Minimum Gate Space") },
        { "gatestrapwidth", technology.get_dimension("Minimum Gate Contact Region Size") },
        { "gateext", technology.get_dimension("Minimum Gate Extension") },
        { "sdwidth", technology.get_dimension("Minimum Source/Drain Contact Region Size") },
        { "oxidetype", 1 },
        { "mosfetmarker", 1 },
        { "channeltype", "nmos", posvals = set("nmos", "pmos") },
        { "flippedwell", false },
        { "vthtype", 1 },
        { "drawactivedummies", false },
        { "activedummywidth", technology.get_dimension("Minimum Active Width") },
        { "activedummyspace", technology.get_dimension("Minimum Active Space") },
        { "gatestrapspace", technology.get_dimension("Minimum M1 Space") },
        { "powerwidth", technology.get_dimension("Minimum M1 Width") },
        { "powerspace", technology.get_dimension("Minimum M1 Space") },
        { "fingersperside", 4 },
        { "fingerwidth", technology.get_dimension("Minimum Gate Width") },
        { "middledummyfingersperside", 2 },
        { "outerdummyfingers", 2 },
        { "drainstrapspace", technology.get_dimension("Minimum M1 Width") },
        { "crossingoffset", technology.get_dimension("Minimum M1 Space") },
        { "inlinedrainstrap", false },
        { "crossingmetal", 3 },
        { "drainmetal", 4 },
        { "fetpowermetal", 3 }
    )
end

local function _get_metal_width(metal)
    local metalstr = string.format("Minimum M%d Width", metal)
        local viastr
    if metal > 1 then
        viastr = string.format("Minimum M%dM%d Viawidth", metal - 1, metal)
    end
    return technology.get_dimension_max(metalstr, viastr)
end

function process_parameters(_P)
    local t = {}
    t.gatestrapwidth = _get_metal_width(_P.crossingmetal)
    t.sdwidth = _get_metal_width(_P.drainmetal)
    return t
end

function check(_P)
    if _P.drainmetal <= _P.crossingmetal then
        return false, string.format("drainmetal must be strictly larger than crossingmetal, got %d and %d", _P.drainmetal, _P.crossingmetal)
    end
    return true
end

function layout(ccp, _P)
    local leftright = object.create("_leftright")

    local flipcontacts = false
    --[[
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
    --]]
    local topnotbotgate = _P.channeltype == "nmos"
    -- FIXME: adapt for pmos and 'gatestrappos' == "bottom"
    local topgatewidth = topnotbotgate and _P.gatestrapwidth or _P.powerwidth
    local topgatespace = topnotbotgate and _P.gatestrapspace or _P.powerspace
    local botgatewidth = topnotbotgate and _P.powerwidth or _P.gatestrapwidth
    local botgatespace = topnotbotgate and _P.powerspace or _P.gatestrapspace
    local baseopt = {
        channeltype = _P.channeltype,
        vthtype = _P.vthtype,
        flippedwell = _P.flippedwell,
        gatelength = _P.gatelength,
        gatespace = _P.gatespace,
        fingerwidth = _P.fingerwidth,
        oxidetype = _P.oxidetype,
        mosfetmarker = _P.mosfetmarker,
        drawtopactivedummy = _P.drawactivedummies,
        topactivedummywidth = _P.activedummywidth,
        topactivedummyspace = _P.activedummyspace,
        drawbottomactivedummy = _P.drawactivedummies,
        bottomactivedummywidth = _P.activedummywidth,
        bottomactivedummyspace = _P.activedummyspace,
        sdwidth = _P.sdwidth,
        topgatewidth = topgatewidth,
        topgatespace = topgatespace,
        botgatewidth = botgatewidth,
        botgatespace = botgatespace,
        connectsource = true,
        sourcemetal = 1,
        connectsourceinverse = flipcontacts,
        connectsourcewidth = _P.powerwidth,
        connectsourcespace = _P.powerspace,
        gtopext = _P.gatestrapwidth + _P.powerspace + _P.gateext,
        gbotext = _P.gatestrapwidth + _P.powerspace + _P.gateext,
        --extendvthtypeleft = (_P.gatelength + _P.gatespace) / 2,
        --extendvthtyperight = (_P.gatelength + _P.gatespace) / 2,
        --extendimplantleft = (_P.gatelength + _P.gatespace) / 2,
        --extendimplantright = (_P.gatelength + _P.gatespace) / 2,
        --extendimplanttop = _P.activedummywidth + _P.activedummyspace + 100 - _P.gatestrapwidth - _P.powerspace - _P.gateext,
        --extendimplantbottom = _P.activedummywidth + _P.activedummyspace + 100 - _P.gatestrapwidth - _P.powerspace - _P.gateext,
        --extendwellleft = (_P.gatelength + _P.gatespace) / 2,
        --extendwellright = (_P.gatelength + _P.gatespace) / 2,
        --extendoxidetypeleft = (_P.gatelength + _P.gatespace) / 2,
        --extendoxidetyperight = (_P.gatelength + _P.gatespace) / 2,
    }

    local fetmiddledummy = pcell.create_layout("basic/mosfet", "_fetmiddledummy", util.add_options(baseopt, {
        fingers = _P.middledummyfingersperside,
        drawbotgate = topnotbotgate,
        drawtopgate = not topnotbotgate,
        connectdrain = true,
        connectdraininverse = true,
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
        drawtopgate = topnotbotgate,
        topgatemetal = _P.crossingmetal,
        topgateleftextension = (_P.gatelength + _P.gatespace) / 2,
        topgaterightextension = (_P.gatelength + _P.gatespace) / 2,
        drawbotgate = not topnotbotgate,
        --botgatemetal = _P.crossingmetal,
        botgatemetal = 1,
        botgateleftextension = (_P.gatelength + _P.gatespace) / 2,
        botgaterightextension = (_P.gatelength + _P.gatespace) / 2,
        connectdrain = true,
        connectdraininline = _P.inlinedrainstrap,
        connectdrainwidth = _P.gatestrapwidth,
        connectdrainspace = topgatespace + _P.gatestrapwidth + _P.drainstrapspace,
        connectdraininlineoffset = (_P.fingerwidth - _P.gatestrapwidth) / 2,
        connectdrainleftext = _P.gatelength + _P.gatespace,
        connectdrainrightext = _P.gatelength + _P.gatespace,
        sourcemetal = 1,
        drawdrainvia = true,
        drainstartmetal = _P.crossingmetal - 1,
        drainendmetal = _P.drainmetal,
        drainviaalign = "bottom",
        splitdrainvias = true,
    }))
    fet:align_area_anchor("sourcedrain1", fetmiddledummy, "sourcedrain-1")
    leftright:merge_into(fet)
    -- place via on drain strap to lower crossing metal
    geometry.viabarebltr(leftright, _P.crossingmetal - 1, _P.drainmetal,
        fet:get_area_anchor("drainstrap").bl,
        fet:get_area_anchor("drainstrap").tr
    )

    -- add left/right dummies
    local fetleftrightdummy = pcell.create_layout("basic/mosfet", "_fetleftrightdummy", util.add_options(baseopt, {
        fingers = _P.outerdummyfingers,
        drawbotgate = topnotbotgate,
        drawtopgate = not topnotbotgate,
        connectdrain = true,
        connectdraininverse = true,
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
    if _P.drawactivedummies then
        leftright:add_area_anchor_bltr("topactivedummy",
            fetmiddledummy:get_area_anchor("topactivedummy").bl,
            fetleftrightdummy:get_area_anchor("topactivedummy").tr
        )
        leftright:add_area_anchor_bltr("bottomactivedummy",
            fetmiddledummy:get_area_anchor("bottomactivedummy").bl,
            fetleftrightdummy:get_area_anchor("bottomactivedummy").tr
        )
    end
    leftright:add_area_anchor_bltr("outerdummyactive",
        outerfetdummy:get_area_anchor("active").bl,
        outerfetdummy:get_area_anchor("active").tr
    )

    leftright:inherit_area_anchor(fet, "drainstrap")
    leftright:inherit_area_anchor_as(fet, "sourcestrap", "common")
    if topnotbotgate then
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

    if _P.drawactivedummies then
        ccp:add_area_anchor_bltr("topactivedummy",
            left:get_area_anchor("topactivedummy").bl,
            right:get_area_anchor("topactivedummy").tr
        )
        ccp:add_area_anchor_bltr("bottomactivedummy",
            left:get_area_anchor("bottomactivedummy").bl,
            right:get_area_anchor("bottomactivedummy").tr
        )
    end
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
    if topnotbotgate then
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

function parameters()
    pcell.add_parameters(
        { "ifingers", 4, posvals = even() },
        { "ofingers", 4, posvals = even() },
        { "stackmethod", "horizontal", posvals = set("horizontal", "vertical") },
        --{ "interdigitate", false }
        { "channeltype", "nmos" },
        { "vthtype", 1 },
        { "oxidetype", 1 },
        { "flippedwell", false },
        { "fingerwidth", technology.get_dimension("Minimum Gate Width") },
        { "diodefingerwidth", technology.get_dimension("Minimum Gate Width"), follow = "fingerwidth" },
        { "sourcefingerwidth", technology.get_dimension("Minimum Gate Width"), follow = "fingerwidth" },
        { "sourcedrainsize", technology.get_dimension("Minimum Gate Width"), follow = "fingerwidth" },
        { "gatelength",  technology.get_dimension("Minimum Gate Length") },
        { "gatespace", technology.get_dimension("Minimum Gate XSpace", "Minimum Gate Space") },
        { "diodemetal",  1 },
        { "outputmetal",  2 },
        { "sdwidth", technology.get_dimension("Minimum Source/Drain Contact Region Size") },
        { "gatestrapwidth", technology.get_dimension("Minimum Gate Contact Region Size") },
        { "gatestrapspace", technology.get_dimension("Minimum M1 Space") },
        { "gatestrapleftext", 0 },
        { "gatestraprightext", 0 },
        { "sourcedrainstrapwidth", technology.get_dimension("Minimum M1 Width") },
        { "sourcedrainstrapspace", technology.get_dimension("Minimum M1 Space") },
        { "drawguardring", false },
        { "guardringwidth", technology.get_dimension("Minimum Active Contact Region Size") },
        { "guardringminxsep", 0 },
        { "guardringminysep", 0 },
        { "guardringfillimplant", true },
        { "guardringfillwell", true },
        { "guardringdrawoxidetype", true },
        { "guardringfilloxidetype", true },
        { "guardringoxidetype", 1, follow = "oxidetype" },
        { "guardringwellinnerextension", technology.get_dimension("Minimum Well Extension") },
        { "guardringwellouterextension", technology.get_dimension("Minimum Well Extension") },
        { "guardringimplantinnerextension", technology.get_dimension("Minimum Implant Extension") },
        { "guardringimplantouterextension", technology.get_dimension("Minimum Implant Extension") },
        { "guardringsoiopeninnerextension", technology.get_optional_dimension("Minimum Soiopen Extension", 0) },
        { "guardringsoiopenouterextension", technology.get_optional_dimension("Minimum Soiopen Extension", 0) },
        { "guardringoxidetypeinnerextension", technology.get_dimension("Minimum Oxide Extension") },
        { "guardringoxidetypeouterextension", technology.get_dimension("Minimum Oxide Extension") }
    )
end

function check(_P)
    if _P.stackmethod == "horizontal" then
        if _P.ofingers ~= _P.ifingers then
        end
    else -- _P.stackmethod == "vertical"
        if _P.diodefingerwidth ~= _P.sourcefingerwidth then
            return
                false,
                string.format(
                    "input and output finger widths must be equal when the stacking is horizontal (got: %d and %d)",
                    _P.diodefingerwidth,
                    _P.sourcefingerwidth
                )
        end
    end
    return true
end

function layout(currentmirror, _P)
    local baseopt = {
        channeltype = _P.channeltype,
        oxidetype = _P.oxidetype,
        vthtype = _P.vthtype,
        flippedwell = _P.flippedwell,
        gatelength = _P.gatelength,
        gatespace = _P.gatespace,
        sourcemetal = 1,
        connectsource = true,
        connectsourcewidth = _P.sourcedrainstrapwidth,
        connectsourcespace = _P.sourcedrainstrapspace,
        connectdrainwidth = _P.sourcedrainstrapwidth,
        drawtopgate = _P.channeltype == "nmos",
        drawbotgate = _P.channeltype == "pmos",
        sdwidth = _P.sdwidth,
        sourcesize = _P.sourcedrainsize,
        drainsize = _P.sourcedrainsize,
        sourcealign = "center",
        drainalign = "center",
        topgateleftextension = _P.gatestrapleftext,
        topgaterightextension = _P.gatestraprightext,
        botgateleftextension = _P.gatestrapleftext,
        botgaterightextension = _P.gatestraprightext,
    }
    local diode = pcell.create_layout("basic/mosfet", "diode", util.add_options(baseopt, {
        fingers = _P.ifingers,
        fingerwidth = _P.diodefingerwidth,
        diodeconnected = true,
        connectdrain = _P.diodemetal > 1,
        drainmetal = _P.diodemetal,
        connectdrainspace = _P.sourcedrainstrapspace,
    }))
    local sourcehalf = pcell.create_layout("basic/mosfet", "sourcehalf", util.add_options(baseopt, {
        fingers = _P.ofingers / 2,
        fingerwidth = _P.sourcefingerwidth,
        drainmetal = _P.outputmetal,
        connectdrain = true,
        connectdrainspace = _P.sourcedrainstrapspace
                          + enable(_P.diodemetal > 1, _P.sourcedrainstrapwidth + _P.sourcedrainstrapspace),
    }))
    if _P.stackmethod == "horizontal" then
        local leftsource = sourcehalf:copy()
        local rightsource = sourcehalf:copy()
        leftsource:abut_left(diode)
        rightsource:abut_right(diode)
        currentmirror:merge_into(diode)
        currentmirror:merge_into(leftsource)
        currentmirror:merge_into(rightsource)

        -- connect gates
        local gatepos
        if _P.channeltype == "pmos" then
            gatepos = "bot"
        else
            gatepos = "top"
        end
        geometry.rectanglebltr(currentmirror, generics.metal(1),
            leftsource:get_area_anchor_fmt("%sgatestrap", gatepos).br,
            rightsource:get_area_anchor_fmt("%sgatestrap", gatepos).tl
        )

        -- connect left/right sources
        geometry.rectanglebltr(currentmirror, generics.metal(_P.outputmetal),
            leftsource:get_area_anchor("drainstrap").br,
            rightsource:get_area_anchor("drainstrap").tl
        )
    else -- _P.stackmethod == "vertical"
        local bottomsource = sourcehalf:copy()
        local topsource = sourcehalf:copy()
        bottomsource:abut_bottom(diode)
        topsource:abut_top(diode)
        currentmirror:merge_into(diode)
        currentmirror:merge_into(leftsource)
        currentmirror:merge_into(rightsource)
        -- FIXME: missing gate connectoin
    end

    if _P.drawguardring then
        local bl
        local tr
        if _P.stackmethod == "horizontal" then
            bl = leftsource:get_area_anchor("active").bl
            tr = rightsource:get_area_anchor("active").tr
        else -- _P.stackmethod == "vertical"
            bl = bottomsource:get_area_anchor("active").bl
            tr = topsource:get_area_anchor("active").tr
        end
        local holewidth = point.xdistance_abs(bl, tr)
        local holeheight = point.ydistance_abs(bl, tr)
        local guardring = pcell.create_layout("auxiliary/guardring", "guardring", {
            contype = _P.flippedwell and (_P.channeltype == "nmos" and "n" or "p") or (_P.channeltype == "nmos" and "p" or "n"),
            ringwidth = _P.guardringwidth,
            holewidth = holewidth + guardringxsep + guardringxsep,
            holeheight = holeheight + guardringysep + guardringysep,
            fillwell = _P.guardringfillwell,
            fillinnerimplant = _P.guardringfillimplant,
            innerimplantpolarity = _P.channeltype == "nmos" and "n" or "p",
            drawoxidetype = _P.guardringdrawoxidetype,
            filloxidetype = _P.guardringfilloxidetype,
            oxidetype = _P.guardringoxidetype,
            wellinnerextension = _P.guardringwellinnerextension,
            wellouterextension = _P.guardringwellouterextension,
            implantinnerextension = _P.guardringimplantinnerextension,
            implantouterextension = _P.guardringimplantouterextension,
            soiopeninnerextension = _P.guardringsoiopeninnerextension,
            soiopenouterextension = _P.guardringsoiopenouterextension,
        })
        guardring:move_point(guardring:get_area_anchor("innerboundary").bl, bl)
        guardring:translate(-guardringxsep, -guardringysep)
        cell:merge_into(guardring)
        cell:add_area_anchor_bltr("outerguardring",
            guardring:get_area_anchor("outerboundary").bl,
            guardring:get_area_anchor("outerboundary").tr
        )
        cell:add_area_anchor_bltr("innerguardring",
            guardring:get_area_anchor("innerboundary").bl,
            guardring:get_area_anchor("innerboundary").tr
        )
    end
end

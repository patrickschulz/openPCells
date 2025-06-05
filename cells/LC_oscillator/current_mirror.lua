function layout(currentmirror, _P, env)
    local _E = env.oscillator.currentmirror

    local lsbref = object.create("current_mirror_output_lsb")
    local baseoptions = {
        channeltype = "pmos",
        vthtype = _E.pdiodevthtype,
        oxidetype = 2,
        flippedwell = _E.pdiodeflippedwell,
        sdwidth = _E.sdwidth,
        sdviawidth = _E.sdwidth,
        sdmetalwidth = 1 * _E.sdwidth,
        connectsource = true,
        connectsourceboth = true,
        sourcemetal = _E.powermetal,
        connectsourcewidth = _E.strapwidth,
        connectsourcespace = (_E.separation - _E.strapwidth) / 2,
        connectdrainwidth = _E.strapwidth,
        connectdrainspace = (_E.separation - _E.strapwidth) / 2,
        drawbotgate = true,
        botgatewidth = _E.gatestrapwidth,
        botgatespace = _E.gatestrapspace,
        botgateleftextension = _E.diodesourcegatespace / 2,
        botgaterightextension = _E.diodesourcegatespace / 2,
        drawtopgate = true,
        topgatewidth = _E.gatestrapwidth,
        topgatespace = _E.gatestrapspace,
        topgateleftextension = _E.diodesourcegatespace / 2,
        topgaterightextension = _E.diodesourcegatespace / 2,
        drawsourcestrap = false,
        drawdrainstrap = false,
        extendallleft = divevenup(_E.diodesourcegatelength + _E.diodesourcegatespace, 2),
        extendallright = divevenup(_E.diodesourcegatelength + _E.diodesourcegatespace, 2),
        extendalltop = (_E.separation + _E.gatestrapwidth) / 2 + 100,
        extendallbottom = (_E.separation + _E.gatestrapwidth) / 2 + 100,
        implantaligntopwithactive = true,
        implantalignbottomwithactive = true,
        oxidetypealigntopwithactive = true,
        oxidetypealignbottomwithactive = true,
        vthtypealigntopwithactive = true,
        vthtypealignbottomwithactive = true,
        --drawtopgatecut = true,
        topgatecutheight = 90,
        topgatecutspace = (_E.separation - 90) / 2,
        topgatecutleftext = _E.diodesourcegatespace / 2,
        topgatecutrightext = _E.diodesourcegatespace / 2,
        --drawbotgatecut = true,
        botgatecutheight = 90,
        botgatecutspace = (_E.separation - 90) / 2,
        botgatecutleftext = _E.diodesourcegatespace / 2,
        botgatecutrightext = _E.diodesourcegatespace / 2,
        --gtopext = _E.separation / 2 + _E.gatestrapspace / 2,
        --gbotext = _E.separation / 2 + _E.gatestrapspace / 2,
    }
    local source = pcell.create_layout("basic/mosfet", "source", util.add_options(baseoptions, {
        gatelength = _E.diodesourcegatelength,
        gatespace = _E.diodesourcegatespace,
        fingerwidth = _E.diodesourcefingerwidth,
        fingers = _E.lsbfingers,
        sdmetalwidth = (_E.diodesourcegatelength + _E.diodesourcegatespace) / 2,
        connectsourceboth = true,
        connectdrain = true,
        connectdrainboth = true,
        drainmetal = _E.innerdrainmetal,
        drawdrainstrap = true,
    }))
    local sourcedummy = pcell.create_layout("basic/mosfet", "sourcedummy", util.add_options(baseoptions, {
        gatelength = _E.diodesourcegatelength,
        gatespace = _E.diodesourcegatespace,
        fingerwidth = _E.diodesourcefingerwidth,
        fingers = _E.lsbdummyfingers,
        sdmetalwidth = (_E.diodesourcegatelength + _E.diodesourcegatespace) / 2,
        connectsourceboth = true,
        connectdrain = true,
        connectdrainboth = true,
        drainmetal = _E.powermetal,
    }))
    local cascode = pcell.create_layout("basic/mosfet", "cascode", util.add_options(baseoptions, {
        gatelength = _E.cascodegatelength,
        gatespace = _E.cascodegatespace,
        fingerwidth = _E.cascodefingerwidth,
        fingers = _E.lsbcascodefingers,
        sdmetalwidth = divevenup(_E.cascodegatelength + _E.cascodegatespace, 2),
        drawsourcevia = true,
        sourcemetal = _E.inneroutputmetal,
        connectsource = true,
        connectdrain = true,
        connectdrainboth = true,
        connectdraininverse = true,
        drainmetal = _E.innerdrainmetal,
        drawdrainstrap = true,
        topgateleftextension = _E.hascascode and _E.cascodegatespace / 2 or 0,
        topgaterightextension = _E.hascascode and _E.cascodegatespace / 2 or 0,
        botgateleftextension = _E.hascascode and _E.cascodegatespace / 2 or 0,
        botgaterightextension = _E.hascascode and _E.cascodegatespace / 2 or 0,
    }))
    local cascodeleftdummy = pcell.create_layout("basic/mosfet", "cascodeleftdummy", util.add_options(baseoptions, {
        gatelength = _E.cascodegatelength,
        gatespace = _E.cascodegatespace,
        fingerwidth = _E.cascodefingerwidth,
        fingers = _E.lsbcascodedummyfingers,
        sdmetalwidth = divevenup(_E.cascodegatelength + _E.cascodegatespace, 2),
        connectdrain = true,
        connectdrainboth = true,
        drainmetal = _E.powermetal,
        drawlastsourcevia = false,
    }))
    local cascoderightdummy = pcell.create_layout("basic/mosfet", "cascoderightdummy", util.add_options(baseoptions, {
        gatelength = _E.cascodegatelength,
        gatespace = _E.cascodegatespace,
        fingerwidth = _E.cascodefingerwidth,
        fingers = _E.lsbcascodedummyfingers,
        sdmetalwidth = divevenup(_E.cascodegatelength + _E.cascodegatespace, 2),
        connectdrain = true,
        connectdrainboth = true,
        drainmetal = _E.powermetal,
        drawfirstsourcevia = false,
        topgateleftextension = 0,
        topgaterightextension = 0,
        botgateleftextension = 0,
        botgaterightextension = 0,
    }))
    local sourcediode = pcell.create_layout("basic/mosfet", "current_mirror_output_sourcediode", util.add_options(baseoptions, {
        gatelength = _E.diodesourcegatelength,
        gatespace = _E.diodesourcegatespace,
        fingerwidth = _E.diodesourcefingerwidth,
        fingers = _E.pdiodefingersperrow,
        sdmetalwidth = (_E.diodesourcegatelength + _E.diodesourcegatespace) / 2,
        diodeconnected = true,
        drawsourcestrap = true,
        connectdrain = true,
        connectdrainboth = true,
        drawdrainstrap = true,
        drainmetal = _E.innermetal,
        connectdrainwidth = _E.strapwidth,
        connectdrainspace = (_E.separation - _E.strapwidth) / 2,
        connectsourceleftext = 2 * (_E.diodesourcegatelength + _E.diodesourcegatespace),
        connectsourcerightext = 2 * (_E.diodesourcegatelength + _E.diodesourcegatespace),
        drawextratopstrap = true,
        extratopstrapmetal = 2,
        extratopstrapwidth = _E.strapwidth,
        extratopstrapspace = (_E.separation - _E.strapwidth) / 2,
        extratopstrapleftalign = 2,
        extratopstraprightalign = _E.pdiodefingersperrow - 1,
        drawextrabotstrap = true,
        extrabotstrapmetal = 2,
        extrabotstrapwidth = _E.strapwidth,
        extrabotstrapspace = (_E.separation - _E.strapwidth) / 2,
        extrabotstrapleftalign = 2,
        extrabotstraprightalign = 2,
    }))
    local sourcediodedummy = pcell.create_layout("basic/mosfet", "current_mirror_output_sourcediodedummy", util.add_options(baseoptions, {
        gatelength = _E.diodesourcegatelength,
        gatespace = _E.diodesourcegatespace,
        fingerwidth = _E.diodesourcefingerwidth,
        fingers = 2,
        sdmetalwidth = (_E.diodesourcegatelength + _E.diodesourcegatespace) / 2,
        connectsource = false,
        connectdrain = false,
        sourcemetal = 1,
        drainmetal = _E.powermetal,
        connectdrain = true,
        connectdraininverse = true,
        topgatewidth = _E.gatestrapwidth,
        topgatespace = (_E.separation - _E.gatestrapwidth) / 2,
        botgatewidth = _E.gatestrapwidth,
        botgatespace = (_E.separation - _E.gatestrapwidth) / 2,
        drawtopgatecut = false,
        drawbotgatecut = false,
    }))
    local cascodediode = pcell.create_layout("basic/mosfet", "current_mirror_output_cascodediode", util.add_options(baseoptions, {
        gatelength = _E.cascodegatelength,
        gatespace = _E.cascodegatespace,
        fingerwidth = _E.cascodefingerwidth,
        fingers = _E.lsbcascodefingers / _E.lsbfingers * _E.pdiodefingersperrow,
        sdmetalwidth = divevenup(_E.cascodegatelength + _E.cascodegatespace, 2),
        diodeconnected = not _E.hascalibration,
        diodeconnectedreversed = true,
        sourcemetal = 3,
        connectsource = true,
        drawsourcestrap = true,
        connectdrain = true,
        drainmetal = _E.innermetal,
        connectdrainboth = true,
        shortdevice = _E.hascalibration,
        shortdevicerightoffset = 1,
        drawextratopstrap = true,
        extratopstrapmetal = _E.inneroutputmetal,
        extratopstrapwidth = _E.strapwidth,
        extratopstrapspace = (_E.separation - _E.strapwidth) / 2,
        extratopstrapleftextension = 2 * (_E.cascodegatelength + _E.cascodegatespace),
        extratopstraprightextension = 2 * (_E.cascodegatelength + _E.cascodegatespace),
        drawextrabotstrap = true,
        extrabotstrapmetal = _E.inneroutputmetal,
        extrabotstrapwidth = _E.strapwidth,
        extrabotstrapspace = (_E.separation - _E.strapwidth) / 2,
        extrabotstrapleftextension = 2 * (_E.cascodegatelength + _E.cascodegatespace),
        extrabotstraprightextension = 2 *(_E.cascodegatelength + _E.cascodegatespace),
        topgateleftextension = _E.hascascode and _E.cascodegatespace / 2 or 0,
        topgaterightextension = _E.hascascode and _E.cascodegatespace / 2 or 0,
        botgateleftextension = _E.hascascode and _E.cascodegatespace / 2 or 0,
        botgaterightextension = _E.hascascode and _E.cascodegatespace / 2 or 0,
    }))
    local cascodediodedummy = pcell.create_layout("basic/mosfet", "current_mirror_output_cascodediodedummy", util.add_options(baseoptions, {
        gatelength = _E.cascodegatelength,
        gatespace = _E.cascodegatespace,
        fingerwidth = _E.cascodefingerwidth,
        fingers = 2,
        sdmetalwidth = divevenup(_E.cascodegatelength + _E.cascodegatespace, 2),
        connectsource = false,
        connectdrain = false,
        sourcemetal = 1,
        drainmetal = 2,
        topgatewidth = _E.gatestrapwidth,
        topgatespace = (_E.separation - _E.gatestrapwidth) / 2,
        botgatewidth = _E.gatestrapwidth,
        botgatespace = (_E.separation - _E.gatestrapwidth) / 2,
        drawtopgatecut = false,
        drawbotgatecut = false,
    }))

    -- place source
    lsbref:merge_into(source)

    -- place cascode
    cascode:align_area_anchor_y("drainstrap", source, "drainstrap")
    cascode:align_area_anchor_x(
        string.format("sourcedrain%d", _E.lsbcascodefingers / 2 + 1),
        source,
        string.format("sourcedrain%d", _E.lsbfingers / 2 + 1)
    )
    lsbref:merge_into(cascode)

    -- place dummies
    if _E.lsbdummyfingers > 0 then
        local sourceleftdummy = sourcedummy:copy()
        local sourcerightdummy = sourcedummy:copy()
        sourceleftdummy:align_top(source)
        sourcerightdummy:align_top(source)
        sourceleftdummy:abut_left(source)
        sourcerightdummy:abut_right(source)
        lsbref:merge_into(sourceleftdummy)
        lsbref:merge_into(sourcerightdummy)
        source = sourceleftdummy
        source = sourcerightdummy
    end
    if _E.lsbcascodedummyfingers > 0 then
        cascodeleftdummy:align_top(cascode)
        cascoderightdummy:align_top(cascode)
        cascodeleftdummy:abut_left(cascode)
        cascoderightdummy:abut_right(cascode)
        lsbref:merge_into(cascodeleftdummy)
        lsbref:merge_into(cascoderightdummy)
        cascode = cascodeleftdummy
        cascode = cascoderightdummy
    end

    -- add anchors
    lsbref:add_area_anchor_bltr("sourceleftsourcedrain",
        source:get_area_anchor("sourcedrainmetal1").bl,
        source:get_area_anchor("sourcedrainmetal1").tr
    )
    lsbref:add_area_anchor_bltr("sourcerightsourcedrain",
        source:get_area_anchor("sourcedrainmetal-1").bl,
        source:get_area_anchor("sourcedrainmetal-1").tr
    )
    lsbref:add_area_anchor_bltr("cascodeleftsourcedrain",
        cascode:get_area_anchor("sourcedrainmetal1").bl,
        cascode:get_area_anchor("sourcedrainmetal1").tr
    )
    lsbref:add_area_anchor_bltr("cascoderightsourcedrain",
        cascode:get_area_anchor("sourcedrainmetal-1").bl,
        cascode:get_area_anchor("sourcedrainmetal-1").tr
    )
    lsbref:add_area_anchor_bltr("sourcetopstrap",
        source:get_area_anchor("sourcestrap").bl,
        source:get_area_anchor("sourcestrap").tr
    )
    lsbref:add_area_anchor_bltr("cascodetopstrap",
        cascode:get_area_anchor("sourcestrap").bl,
        cascode:get_area_anchor("sourcestrap").tr
    )
    lsbref:add_area_anchor_bltr("cascodebotstrap",
        cascode:get_area_anchor("othersourcestrap").bl,
        cascode:get_area_anchor("othersourcestrap").tr
    )
    lsbref:set_alignment_box(
        cascode:get_area_anchor("sourcedrainmetal1").bl .. cascode:get_area_anchor("othersourcestrap").bl,
        source:get_area_anchor("sourcedrainmetal-1").br .. source:get_area_anchor("sourcestrap").tr,
        cascode:get_area_anchor("sourcedrainmetal1").br .. cascode:get_area_anchor("othersourcestrap").tl,
        source:get_area_anchor("sourcedrainmetal-1").bl .. source:get_area_anchor("sourcestrap").br
    )

    -- add power rails
    geometry.rectanglebltr(lsbref, generics.metal(_E.powermetal),
        source:get_area_anchor("sourcestrap").bl,
        source:get_area_anchor("sourcestrap").tr
    )
    geometry.rectanglebltr(lsbref, generics.metal(_E.powermetal),
        source:get_area_anchor("othersourcestrap").bl,
        source:get_area_anchor("othersourcestrap").tr
    )
    geometry.rectanglebltr(lsbref, generics.metal(_E.powermetal),
        cascode:get_area_anchor("othersourcestrap").bl,
        cascode:get_area_anchor("othersourcestrap").tr
    )

    -- add output rails
    geometry.rectanglebltr(lsbref, generics.metal(_E.inneroutputmetal),
        cascode:get_area_anchor("sourcestrap").bl,
        cascode:get_area_anchor("sourcestrap").tr
    )
    geometry.rectanglebltr(lsbref, generics.metal(_E.inneroutputmetal),
        cascode:get_area_anchor("othersourcestrap").bl,
        cascode:get_area_anchor("othersourcestrap").tr
    )

    -- add vdd connections
    local plwidth, _plheight, plspace, ploffset, plnumlines = geometry.rectanglevlines_width_space_settings(
        point.create(
            (lsbref:get_alignment_anchor("outerbl"):getx() + lsbref:get_alignment_anchor("innerbl"):getx()) / 2,
            lsbref:get_alignment_anchor("outerbl"):gety()
        ),
        point.create(
            (lsbref:get_alignment_anchor("outertr"):getx() + lsbref:get_alignment_anchor("innertr"):getx()) / 2,
            lsbref:get_alignment_anchor("outertr"):gety()
        ),
        _E.powerlinewidth, _E.powerlinespace
    )
    for i = 1, plnumlines do
        local shift = ploffset + (i - 1) * (plwidth + plspace)
        local x = (lsbref:get_alignment_anchor("outerbl"):getx() + lsbref:get_alignment_anchor("innerbl"):getx()) / 2
        lsbref:add_area_anchor_bltr(string.format("powerline_%d", i),
            point.create(
                shift + x,
                cascode:get_area_anchor("othersourcestrap").b
            ),
            point.create(
                shift + x + plwidth,
                source:get_area_anchor("sourcestrap").t
            )
        )
        geometry.rectanglebltr(lsbref, generics.metal(_E.powermetal + 1),
            lsbref:get_area_anchor(string.format("powerline_%d", i)).bl,
            lsbref:get_area_anchor(string.format("powerline_%d", i)).tr
        )
        geometry.viabltr(lsbref, _E.powermetal, _E.powermetal + 1,
            point.create(
                lsbref:get_area_anchor(string.format("powerline_%d", i)).l,
                source:get_area_anchor("sourcestrap").b
            ),
            point.create(
                lsbref:get_area_anchor(string.format("powerline_%d", i)).r,
                source:get_area_anchor("sourcestrap").t
            )
        )
        geometry.viabltr(lsbref, _E.powermetal, _E.powermetal + 1,
            point.create(
                lsbref:get_area_anchor(string.format("powerline_%d", i)).l,
                source:get_area_anchor("othersourcestrap").b
            ),
            point.create(
                lsbref:get_area_anchor(string.format("powerline_%d", i)).r,
                source:get_area_anchor("othersourcestrap").t
            )
        )
        geometry.viabltr(lsbref, _E.powermetal, _E.powermetal + 1,
            point.create(
                lsbref:get_area_anchor(string.format("powerline_%d", i)).l,
                cascode:get_area_anchor("othersourcestrap").b
            ),
            point.create(
                lsbref:get_area_anchor(string.format("powerline_%d", i)).r,
                cascode:get_area_anchor("othersourcestrap").t
            )
        )
    end
    -- strengthen power grid, also helps with density
    for i = 1, _E.lsbfingers + 1, 2 do
        geometry.rectanglebltr(lsbref, generics.metal(_E.powermetal),
            point.create(
                source:get_area_anchor(string.format("sourcedrainmetal%d", i)).l,
                cascode:get_area_anchor("othersourcestrap").t
            ),
            point.create(
                source:get_area_anchor(string.format("sourcedrainmetal%d", i)).r,
                cascode:get_area_anchor("sourcestrap").b
            )
        )
    end

    -- add configuration bit lines
    if _E.hascalibration then
        local linewidth = _E.bitlinewidth
        local linespace = _E.bitlinespace
        local yshift = ((_E.separation - 2 * _E.gatestrapwidth - 2 * _E.gatestrapspace) - (_E.numbits + 1) * linewidth - _E.numbits * linespace) / 2
        local extension = (_E.cascodegatespace - _E.sdwidth) / 2 + _E.sdwidth / 2
        for i = 1, _E.numbits + 1 do
            geometry.rectanglebltr(lsbref, generics.metal(_E.gatebitlinemetal),
                cascode:get_area_anchor("botgatestrap").bl:translate(-extension, -yshift - (i - 1) * (linewidth + linespace) - linewidth),
                cascode:get_area_anchor("botgatestrap").br:translate(extension, -yshift - (i - 1) * (linewidth + linespace))
            )
            lsbref:add_area_anchor_bltr(string.format("bitline_%d", i),
                cascode:get_area_anchor("botgatestrap").bl:translate(-extension, -yshift - (i - 1) * (linewidth + linespace) - linewidth),
                cascode:get_area_anchor("botgatestrap").br:translate(extension, -yshift - (i - 1) * (linewidth + linespace))
            )
        end
        lsbref:add_area_anchor_bltr("configgate",
            cascode:get_area_anchor("botgatestrap").bl,
            cascode:get_area_anchor("botgatestrap").tr
        )
        lsbref:add_area_anchor_bltr("otherconfiggate",
            cascode:get_area_anchor("topgatestrap").bl,
            cascode:get_area_anchor("topgatestrap").tr
        )
        lsbref:add_area_anchor_bltr("sourcegate",
            source:get_area_anchor("sourcestrap").bl,
            source:get_area_anchor("sourcestrap").tr
        )
    end

    -- left/right diodes
    local dioderef = object.create("current_mirror_diode")
    dioderef:merge_into(sourcediode)
    cascodediode:align_area_anchor_y("otherdrainstrap", sourcediode, "drainstrap")
    cascodediode:align_area_anchor_x("sourcedrainmetal-1", sourcediode, "sourcedrainmetal-1")
    dioderef:merge_into(cascodediode)

    local sourcediodeleftdummy = sourcediodedummy:copy()
    local sourcedioderightdummy = sourcediodedummy:copy()
    sourcediodeleftdummy:align_area_anchor_y("active", sourcediode, "active")
    sourcediodeleftdummy:align_area_anchor_x("sourcedrainmetal-1", sourcediode, "sourcedrainmetal1")
    sourcedioderightdummy:align_area_anchor_y("active", sourcediode, "active")
    sourcedioderightdummy:align_area_anchor_x("sourcedrainmetal1", sourcediode, "sourcedrainmetal-1")
    dioderef:merge_into(sourcediodeleftdummy)
    dioderef:merge_into(sourcedioderightdummy)

    local cascodediodeleftdummy = cascodediodedummy:copy()
    local cascodedioderightdummy = cascodediodedummy:copy()
    cascodediodeleftdummy:align_area_anchor_y("active", cascodediode, "active")
    cascodediodeleftdummy:align_area_anchor_x("sourcedrainmetal-1", cascodediode, "sourcedrainmetal1")
    cascodedioderightdummy:align_area_anchor_y("active", cascodediode, "active")
    cascodedioderightdummy:align_area_anchor_x("sourcedrainmetal1", cascodediode, "sourcedrainmetal-1")
    dioderef:merge_into(cascodediodeleftdummy)
    dioderef:merge_into(cascodedioderightdummy)

    -- connect cascode dummy to vdd
    geometry.rectanglebltr(dioderef, generics.metal(2),
        point.create(
            cascodediodeleftdummy:get_area_anchor("sourcedrainmetal2").l,
            cascodediodeleftdummy:get_area_anchor("botgatestrap").b
        ),
        point.create(
            sourcediodeleftdummy:get_area_anchor("sourcedrainmetal2").r,
            sourcediodeleftdummy:get_area_anchor("topgatestrap").t
        )
    )
    geometry.viabltr(dioderef, 1, 2,
        point.create(
            sourcediodeleftdummy:get_area_anchor("sourcedrainmetal2").l,
            sourcediodeleftdummy:get_area_anchor("topgatestrap").b
        ),
        point.create(
            sourcediodeleftdummy:get_area_anchor("sourcedrainmetal2").r,
            sourcediodeleftdummy:get_area_anchor("topgatestrap").t
        )
    )
    geometry.viabltr(dioderef, 1, 2,
        point.create(
            cascodediodeleftdummy:get_area_anchor("sourcedrainmetal2").l,
            cascodediodeleftdummy:get_area_anchor("topgatestrap").b
        ),
        point.create(
            cascodediodeleftdummy:get_area_anchor("sourcedrainmetal2").r,
            cascodediodeleftdummy:get_area_anchor("topgatestrap").t
        )
    )
    geometry.viabltr(dioderef, 1, 2,
        point.create(
            cascodediodeleftdummy:get_area_anchor("sourcedrainmetal2").l,
            cascodediodeleftdummy:get_area_anchor("botgatestrap").b
        ),
        point.create(
            cascodediodeleftdummy:get_area_anchor("sourcedrainmetal2").r,
            cascodediodeleftdummy:get_area_anchor("botgatestrap").t
        )
    )
    geometry.rectanglebltr(dioderef, generics.metal(2),
        point.create(
            cascodedioderightdummy:get_area_anchor("sourcedrainmetal2").l,
            cascodedioderightdummy:get_area_anchor("botgatestrap").b
        ),
        point.create(
            sourcedioderightdummy:get_area_anchor("sourcedrainmetal2").r,
            sourcedioderightdummy:get_area_anchor("topgatestrap").t
        )
    )
    geometry.viabltr(dioderef, 1, 2,
        point.create(
            sourcedioderightdummy:get_area_anchor("sourcedrainmetal2").l,
            sourcedioderightdummy:get_area_anchor("topgatestrap").b
        ),
        point.create(
            sourcedioderightdummy:get_area_anchor("sourcedrainmetal2").r,
            sourcedioderightdummy:get_area_anchor("topgatestrap").t
        )
    )
    geometry.viabltr(dioderef, 1, 2,
        point.create(
            cascodedioderightdummy:get_area_anchor("sourcedrainmetal2").l,
            cascodedioderightdummy:get_area_anchor("topgatestrap").b
        ),
        point.create(
            cascodedioderightdummy:get_area_anchor("sourcedrainmetal2").r,
            cascodedioderightdummy:get_area_anchor("topgatestrap").t
        )
    )
    geometry.viabltr(dioderef, 1, 2,
        point.create(
            cascodedioderightdummy:get_area_anchor("sourcedrainmetal2").l,
            cascodedioderightdummy:get_area_anchor("botgatestrap").b
        ),
        point.create(
            cascodedioderightdummy:get_area_anchor("sourcedrainmetal2").r,
            cascodedioderightdummy:get_area_anchor("botgatestrap").t
        )
    )


    -- extend gate metal
    geometry.rectanglebltr(dioderef, generics.metal(1),
        sourcediode:get_area_anchor("topgatestrap").bl:translate_x(-2 * (_E.diodesourcegatelength + _E.diodesourcegatespace)),
        sourcediode:get_area_anchor("topgatestrap").tr:translate_x(2 * (_E.diodesourcegatelength + _E.diodesourcegatespace))
    )
    geometry.rectanglebltr(dioderef, generics.metal(1),
        sourcediode:get_area_anchor("botgatestrap").bl:translate_x(-2 * (_E.diodesourcegatelength + _E.diodesourcegatespace)),
        sourcediode:get_area_anchor("botgatestrap").tr:translate_x(2 * (_E.diodesourcegatelength + _E.diodesourcegatespace))
    )
    geometry.rectanglebltr(dioderef, generics.metal(1),
        cascodediode:get_area_anchor("topgatestrap").bl:translate_x(-2 * (_E.diodesourcegatelength + _E.diodesourcegatespace)),
        cascodediode:get_area_anchor("topgatestrap").tr:translate_x(2 * (_E.diodesourcegatelength + _E.diodesourcegatespace))
    )
    geometry.rectanglebltr(dioderef, generics.metal(1),
        cascodediode:get_area_anchor("botgatestrap").bl:translate_x(-2 * (_E.diodesourcegatelength + _E.diodesourcegatespace)),
        cascodediode:get_area_anchor("botgatestrap").tr:translate_x(2 * (_E.diodesourcegatelength + _E.diodesourcegatespace))
    )

    -- extra ibias input metal
    geometry.rectanglebltr(dioderef, generics.metal(3),
        sourcediode:get_area_anchor("extratopstrap").bl,
        sourcediode:get_area_anchor("extratopstrap").tr
    )

    -- extra connections
    for i = 2, _E.pdiodefingersperrow + 1, 2 do
        geometry.rectanglebltr(dioderef, generics.metal(3),
            point.create(
                sourcediode:get_area_anchor(string.format("sourcedrainmetal%d", i)).l,
                sourcediode:get_area_anchor("extrabotstrap").t
            ),
            point.create(
                sourcediode:get_area_anchor(string.format("sourcedrainmetal%d", i)).r,
                sourcediode:get_area_anchor("extratopstrap").b
            )
        )
    end

    -- extra vdd connections
    if _E.hascascode then
        geometry.rectanglebltr(dioderef, generics.metal(_E.powermetal),
            cascodediode:get_area_anchor("extrabotstrap").bl,
            cascodediode:get_area_anchor("extrabotstrap").tr
        )
        for i = 1, _E.pdiodefingersperrow + 1, 2 do
            geometry.rectanglebltr(dioderef, generics.metal(_E.powermetal),
                point.create(
                    sourcediode:get_area_anchor(string.format("sourcedrainmetal%d", i)).l,
                    cascodediode:get_area_anchor("extrabotstrap").t
                ),
                point.create(
                    sourcediode:get_area_anchor(string.format("sourcedrainmetal%d", i)).r,
                    cascodediode:get_area_anchor("extratopstrap").b
                )
            )
        end
    end

    dioderef:add_area_anchor_bltr("diodeleftsourcedrain",
        sourcediode:get_area_anchor("sourcedrainmetal1").bl,
        sourcediode:get_area_anchor("sourcedrainmetal1").tr
    )
    dioderef:add_area_anchor_bltr("dioderightsourcedrain",
        sourcediode:get_area_anchor("sourcedrainmetal-1").bl,
        sourcediode:get_area_anchor("sourcedrainmetal-1").tr
    )
    dioderef:add_area_anchor_bltr("cascodeleftsourcedrain",
        cascodediode:get_area_anchor("sourcedrainmetal1").bl,
        cascodediode:get_area_anchor("sourcedrainmetal1").tr
    )
    dioderef:add_area_anchor_bltr("cascoderightsourcedrain",
        cascodediode:get_area_anchor("sourcedrainmetal-1").bl,
        cascodediode:get_area_anchor("sourcedrainmetal-1").tr
    )
    dioderef:set_alignment_box(
        cascodediodeleftdummy:get_area_anchor("sourcedrainmetal1").bl .. cascode:get_area_anchor("othersourcestrap").bl,
        sourcedioderightdummy:get_area_anchor("sourcedrainmetal-1").br .. source:get_area_anchor("sourcestrap").tr,
        cascodediodeleftdummy:get_area_anchor("sourcedrainmetal1").br .. cascode:get_area_anchor("othersourcestrap").tl,
        sourcedioderightdummy:get_area_anchor("sourcedrainmetal-1").bl .. source:get_area_anchor("sourcestrap").br
    )
    dioderef:add_area_anchor_bltr("sourcediodetopgatestrap",
        sourcediode:get_area_anchor("topgatestrap").bl,
        sourcediode:get_area_anchor("topgatestrap").tr
    )
    dioderef:add_area_anchor_bltr("sourcediodebotgatestrap",
        sourcediode:get_area_anchor("botgatestrap").bl,
        sourcediode:get_area_anchor("botgatestrap").tr
    )
    if not _E.hascascode then
        dioderef:add_area_anchor_bltr("ibiasinputtop",
            sourcediode:get_area_anchor("topgatestrap").bl,
            sourcediode:get_area_anchor("topgatestrap").tr
        )
        dioderef:add_area_anchor_bltr("ibiasinputbottom",
            sourcediode:get_area_anchor("botgatestrap").bl,
            sourcediode:get_area_anchor("botgatestrap").tr
        )
    else
        dioderef:add_area_anchor_bltr("ibiasinputtop",
            cascodediode:get_area_anchor("topgatestrap").bl,
            cascodediode:get_area_anchor("topgatestrap").tr
        )
        dioderef:add_area_anchor_bltr("ibiasinputbottom",
            cascodediode:get_area_anchor("botgatestrap").bl,
            cascodediode:get_area_anchor("botgatestrap").tr
        )
    end
    dioderef:add_area_anchor_bltr("ibiastop",
        sourcediode:get_area_anchor("otherdrainstrap").bl,
        sourcediode:get_area_anchor("otherdrainstrap").tr
    )
    dioderef:add_area_anchor_bltr("diodedrainstrap",
        sourcediode:get_area_anchor("drainstrap").bl,
        sourcediode:get_area_anchor("drainstrap").tr
    )
    dioderef:add_area_anchor_bltr("diodeotherdrainstrap",
        sourcediode:get_area_anchor("otherdrainstrap").bl,
        sourcediode:get_area_anchor("otherdrainstrap").tr
    )
    dioderef:add_area_anchor_bltr("cascodetopgatestrap",
        cascodediode:get_area_anchor("topgatestrap").bl,
        cascodediode:get_area_anchor("topgatestrap").tr
    )
    dioderef:add_area_anchor_bltr("cascodebotgatestrap",
        cascodediode:get_area_anchor("botgatestrap").bl,
        cascodediode:get_area_anchor("botgatestrap").tr
    )
    dioderef:add_area_anchor_bltr("cascodeextratopstrap",
        cascodediode:get_area_anchor("extratopstrap").bl,
        cascodediode:get_area_anchor("extratopstrap").tr
    )
    dioderef:add_area_anchor_bltr("cascodeextrabotstrap",
        cascodediode:get_area_anchor("extrabotstrap").bl,
        cascodediode:get_area_anchor("extrabotstrap").tr
    )
    for finger = 2, _E.pdiodefingersperrow, 2 do
        dioderef:add_area_anchor_bltr(string.format("diodesourcedrain%d", finger),
            sourcediode:get_area_anchor(string.format("sourcedrainmetal%d", finger)).bl,
            sourcediode:get_area_anchor(string.format("sourcedrainmetal%d", finger)).tr
        )
    end
    -- add vdd connections
    local diodeplwidth, _diodeplheight, diodeplspace, diodeploffset, diodeplnumlines = geometry.rectanglevlines_width_space_settings(
        point.create(
            (dioderef:get_alignment_anchor("outerbl"):getx() + dioderef:get_alignment_anchor("innerbl"):getx()) / 2,
            dioderef:get_alignment_anchor("outerbl"):gety()
        ),
        point.create(
            (dioderef:get_alignment_anchor("outertr"):getx() + dioderef:get_alignment_anchor("innertr"):getx()) / 2,
            dioderef:get_alignment_anchor("outertr"):gety()
        ),
        _E.powerlinewidth, _E.powerlinespace
    )
    for i = 1, diodeplnumlines do
        local shift = diodeploffset + (i - 1) * (diodeplwidth + diodeplspace)
        local x = (dioderef:get_alignment_anchor("outerbl"):getx() + dioderef:get_alignment_anchor("innerbl"):getx()) / 2
        dioderef:add_area_anchor_bltr(string.format("powerline_%d", i),
            point.create(
                shift + x,
                cascode:get_area_anchor("othersourcestrap").b
            ),
            point.create(
                shift + x + diodeplwidth,
                source:get_area_anchor("sourcestrap").t
            )
        )
        geometry.rectanglebltr(dioderef, generics.metal(_E.powermetal + 1),
            dioderef:get_area_anchor(string.format("powerline_%d", i)).bl,
            dioderef:get_area_anchor(string.format("powerline_%d", i)).tr
        )
        geometry.viabltr(dioderef, _E.powermetal, _E.powermetal + 1,
            point.create(
                dioderef:get_area_anchor(string.format("powerline_%d", i)).l,
                source:get_area_anchor("sourcestrap").b
            ),
            point.create(
                dioderef:get_area_anchor(string.format("powerline_%d", i)).r,
                source:get_area_anchor("sourcestrap").t
            )
        )
        geometry.viabltr(dioderef, _E.powermetal, _E.powermetal + 1,
            point.create(
                dioderef:get_area_anchor(string.format("powerline_%d", i)).l,
                source:get_area_anchor("othersourcestrap").b
            ),
            point.create(
                dioderef:get_area_anchor(string.format("powerline_%d", i)).r,
                source:get_area_anchor("othersourcestrap").t
            )
        )
        geometry.viabltr(dioderef, _E.powermetal, _E.powermetal + 1,
            point.create(
                dioderef:get_area_anchor(string.format("powerline_%d", i)).l,
                cascode:get_area_anchor("othersourcestrap").b
            ),
            point.create(
                dioderef:get_area_anchor(string.format("powerline_%d", i)).r,
                cascode:get_area_anchor("othersourcestrap").t
            )
        )
    end

    local half = object.create("current_mirror_half")

    local rows = {}

    local numperrow = 4
    for rownum = 1, _E.rows do
        rows[rownum] = {
            lsbcells = {},
        }
        -- first half of current sources
        for column = 1, _E.columns / 2 do
            local lsb = half:add_child(lsbref, string.format("lsb_%d_%d", rownum, column))
            if column == 1 then
                if rownum == 1 then
                    -- do nothing for the first cell
                else
                    lsb:align_left(rows[rownum - 1].lsbcells[1])
                    lsb:abut_bottom(rows[rownum - 1].lsbcells[1])
                end
            else
                lsb:align_top(rows[rownum].lsbcells[column - 1])
                lsb:abut_right(rows[rownum].lsbcells[column - 1])
            end
            rows[rownum].lsbcells[column] = lsb
        end
        local diode = half:add_child(dioderef, string.format("leftdiode_%d", rownum))
        diode:abut_right(rows[rownum].lsbcells[_E.columns / 2])
        diode:align_top(rows[rownum].lsbcells[_E.columns / 2])
        rows[rownum].diode = diode
        -- second half of current sources
        for column = 1, _E.columns / 2 do
            local index = _E.columns / 2 + column
            local lsb = half:add_child(lsbref, string.format("lsb_%d_%d", rownum, index))
            if column == 1 then
                lsb:abut_right(rows[rownum].diode)
                lsb:align_top(rows[rownum].diode)
            else
                lsb:align_top(rows[rownum].lsbcells[index - 1])
                lsb:abut_right(rows[rownum].lsbcells[index - 1])
            end
            rows[rownum].lsbcells[index] = lsb
        end
    end

    -- connect internal lsb nodes (FIXME: this does not connect ALL of them)
    for row = 1, _E.rows do
        geometry.rectanglebltr(half, generics.metal(2),
            rows[row].lsbcells[1]:get_area_anchor("sourcetopstrap").bl,
            rows[row].lsbcells[_E.columns / 2]:get_area_anchor("sourcetopstrap").tr
        )
        geometry.rectanglebltr(half, generics.metal(2),
            rows[row].lsbcells[1]:get_area_anchor("cascodetopstrap").bl,
            rows[row].lsbcells[_E.columns / 2]:get_area_anchor("cascodetopstrap").tr
        )
        geometry.rectanglebltr(half, generics.metal(2),
            rows[row].lsbcells[1]:get_area_anchor("cascodebotstrap").bl,
            rows[row].lsbcells[_E.columns / 2]:get_area_anchor("cascodebotstrap").tr
        )
        geometry.rectanglebltr(half, generics.metal(2),
            rows[row].lsbcells[_E.columns / 2 + 1]:get_area_anchor("sourcetopstrap").bl,
            rows[row].lsbcells[_E.columns]:get_area_anchor("sourcetopstrap").tr
        )
        geometry.rectanglebltr(half, generics.metal(2),
            rows[row].lsbcells[_E.columns / 2 + 1]:get_area_anchor("cascodetopstrap").bl,
            rows[row].lsbcells[_E.columns]:get_area_anchor("cascodetopstrap").tr
        )
        geometry.rectanglebltr(half, generics.metal(2),
            rows[row].lsbcells[_E.columns / 2 + 1]:get_area_anchor("cascodebotstrap").bl,
            rows[row].lsbcells[_E.columns]:get_area_anchor("cascodebotstrap").tr
        )
    end

    half:add_area_anchor_bltr("ibias",
        point.create(
            (rows[1].diode:get_area_anchor("ibiastop").l + rows[1].diode:get_area_anchor("ibiastop").r) / 2 - env.ibias.width / 2,
            rows[1].diode:get_area_anchor("ibiastop").b
        ),
        point.create(
            (rows[1].diode:get_area_anchor("ibiastop").l + rows[1].diode:get_area_anchor("ibiastop").r) / 2 + env.ibias.width / 2,
            rows[1].diode:get_area_anchor("ibiastop").t
        )
    )

    -- connect bit lines to gates
    if _E.hascalibration then
        local bitindices = {}
        for i = 1, (2^_E.numbits - 1) do
            bitindices[i] = math.floor(math.log(i, 2)) + 1
        end
        -- insert one dummy bit
        table.insert(bitindices, 1, 0)
        for rownum = 1, _E.rows do
            for column = 1, _E.columns do
                local bitindex = column + (rownum - 1) * _E.columns
                local lineindex = bitindices[bitindex] + 1
                -- add metal 1 filling
                for i = 1, _E.numbits + 1 do
                    if i ~= lineindex then
                        geometry.rectanglebltr(half, generics.metal(1),
                            rows[rownum].lsbcells[column]:get_area_anchor("configgate").bl:translate_y(-yshift - (i - 1) * (linewidth + linespace) - linewidth),
                            point.combine(
                                rows[rownum].lsbcells[column]:get_area_anchor("configgate").bl,
                                rows[rownum].lsbcells[column]:get_area_anchor("configgate").br
                            ):translate(-200, -yshift - (i - 1) * (linewidth + linespace))
                        )
                        geometry.rectanglebltr(half, generics.metal(1),
                            point.combine(
                                rows[rownum].lsbcells[column]:get_area_anchor("configgate").bl,
                                rows[rownum].lsbcells[column]:get_area_anchor("configgate").br
                            ):translate(200, -yshift - (i - 1) * (linewidth + linespace) - linewidth),
                            rows[rownum].lsbcells[column]:get_area_anchor("configgate").br:translate_y(-yshift - (i - 1) * (linewidth + linespace))
                        )
                    end
                    geometry.rectanglebltr(half, generics.metal(1),
                        rows[rownum].lsbcells[column]:get_area_anchor("otherconfiggate").tl:translate_y(yshift + (i - 1) * (linewidth + linespace)),
                        point.combine(
                            rows[rownum].lsbcells[column]:get_area_anchor("otherconfiggate").tl,
                            rows[rownum].lsbcells[column]:get_area_anchor("otherconfiggate").tr
                        ):translate(-200, yshift + (i - 1) * (linewidth + linespace) + linewidth)
                    )
                    geometry.rectanglebltr(half, generics.metal(1),
                        point.combine(
                            rows[rownum].lsbcells[column]:get_area_anchor("otherconfiggate").tl,
                            rows[rownum].lsbcells[column]:get_area_anchor("otherconfiggate").tr
                        ):translate(200, yshift + (i - 1) * (linewidth + linespace)),
                        rows[rownum].lsbcells[column]:get_area_anchor("otherconfiggate").tr:translate_y(yshift + (i - 1) * (linewidth + linespace) + linewidth)
                    )
                end
                geometry.viabltr(half, 1, 2,
                    rows[rownum].lsbcells[column]:get_area_anchor("configgate").bl:translate_y(-yshift - (lineindex - 1) * (linewidth + linespace) - linewidth),
                    rows[rownum].lsbcells[column]:get_area_anchor("configgate").br:translate_y(-yshift - (lineindex - 1) * (linewidth + linespace))
                )
                geometry.rectanglebltr(half, generics.metal(1),
                    point.combine(
                        rows[rownum].lsbcells[column]:get_area_anchor("configgate").bl,
                        rows[rownum].lsbcells[column]:get_area_anchor("configgate").br
                    ):translate(-100, -yshift - (lineindex - 1) * (linewidth + linespace)),
                    point.combine(
                        rows[rownum].lsbcells[column]:get_area_anchor("configgate").bl,
                        rows[rownum].lsbcells[column]:get_area_anchor("configgate").br
                    ):translate_x(100)
                )
            end
            -- connect cascodediodes to vdd
            local lineindex = 1
            geometry.viabltr(half, 1, 2,
                rows[rownum].leftdiode:get_area_anchor("cascodebotgatestrap").bl:translate_y(-yshift - (lineindex - 1) * (linewidth + linespace) - linewidth),
                rows[rownum].leftdiode:get_area_anchor("cascodebotgatestrap").br:translate_y(-yshift - (lineindex - 1) * (linewidth + linespace))
            )
            geometry.rectanglebltr(half, generics.metal(1),
                point.combine(
                    rows[rownum].leftdiode:get_area_anchor("cascodebotgatestrap").bl,
                    rows[rownum].leftdiode:get_area_anchor("cascodebotgatestrap").br
                ):translate(-100, -yshift - (lineindex - 1) * (linewidth + linespace)),
                point.combine(
                    rows[rownum].leftdiode:get_area_anchor("cascodebotgatestrap").bl,
                    rows[rownum].leftdiode:get_area_anchor("cascodebotgatestrap").br:translate_x(100)
                )
            )
            local lineindex = 1
            geometry.viabltr(half, 1, 2,
                rows[rownum].rightdiode:get_area_anchor("cascodebotgatestrap").bl:translate_y(-yshift - (lineindex - 1) * (linewidth + linespace) - linewidth),
                rows[rownum].rightdiode:get_area_anchor("cascodebotgatestrap").br:translate_y(-yshift - (lineindex - 1) * (linewidth + linespace))
            )
            geometry.rectanglebltr(half, generics.metal(1),
                point.combine(
                    rows[rownum].rightdiode:get_area_anchor("cascodebotgatestrap").bl,
                    rows[rownum].rightdiode:get_area_anchor("cascodebotgatestrap").br
                ):translate(-100, -yshift - (lineindex - 1) * (linewidth + linespace)),
                point.combine(
                    rows[rownum].rightdiode:get_area_anchor("cascodebotgatestrap").bl,
                    rows[rownum].rightdiode:get_area_anchor("cascodebotgatestrap").br:translate_x(100)
                )
            )
            for i = 1, _E.numbits + 1 do
                if i ~= 1 then
                    geometry.rectanglebltr(half, generics.metal(1),
                        rows[rownum].leftdiode:get_area_anchor("cascodebotgatestrap").bl:translate_y(-yshift - (i - 1) * (linewidth + linespace) - linewidth),
                        point.combine(
                            rows[rownum].leftdiode:get_area_anchor("cascodebotgatestrap").bl,
                            rows[rownum].leftdiode:get_area_anchor("cascodebotgatestrap").br
                        ):translate(-200, -yshift - (i - 1) * (linewidth + linespace))
                    )
                    geometry.rectanglebltr(half, generics.metal(1),
                        point.combine(
                            rows[rownum].leftdiode:get_area_anchor("cascodebotgatestrap").bl,
                            rows[rownum].leftdiode:get_area_anchor("cascodebotgatestrap").br
                        ):translate(200, -yshift - (i - 1) * (linewidth + linespace) - linewidth),
                        rows[rownum].leftdiode:get_area_anchor("cascodebotgatestrap").br:translate_y(-yshift - (i - 1) * (linewidth + linespace))
                    )
                    geometry.rectanglebltr(half, generics.metal(1),
                        rows[rownum].rightdiode:get_area_anchor("cascodebotgatestrap").bl:translate_y(-yshift - (i - 1) * (linewidth + linespace) - linewidth),
                        point.combine(
                            rows[rownum].rightdiode:get_area_anchor("cascodebotgatestrap").bl,
                            rows[rownum].rightdiode:get_area_anchor("cascodebotgatestrap").br
                        ):translate(-200, -yshift - (i - 1) * (linewidth + linespace))
                    )
                    geometry.rectanglebltr(half, generics.metal(1),
                        point.combine(
                            rows[rownum].rightdiode:get_area_anchor("cascodebotgatestrap").bl,
                            rows[rownum].rightdiode:get_area_anchor("cascodebotgatestrap").br
                        ):translate(200, -yshift - (i - 1) * (linewidth + linespace) - linewidth),
                        rows[rownum].rightdiode:get_area_anchor("cascodebotgatestrap").br:translate_y(-yshift - (i - 1) * (linewidth + linespace))
                    )
                end
                geometry.rectanglebltr(half, generics.metal(1),
                    rows[rownum].leftdiode:get_area_anchor("cascodetopgatestrap").tl:translate_y(yshift + (i - 1) * (linewidth + linespace)),
                    point.combine(
                        rows[rownum].leftdiode:get_area_anchor("cascodetopgatestrap").tl,
                        rows[rownum].leftdiode:get_area_anchor("cascodetopgatestrap").tr
                    ):translate(-200, yshift + (i - 1) * (linewidth + linespace) + linewidth)
                )
                geometry.rectanglebltr(half, generics.metal(1),
                    point.combine(
                        rows[rownum].leftdiode:get_area_anchor("cascodetopgatestrap").tl,
                        rows[rownum].leftdiode:get_area_anchor("cascodetopgatestrap").tr
                    ):translate(200, yshift + (i - 1) * (linewidth + linespace)),
                    rows[rownum].leftdiode:get_area_anchor("cascodetopgatestrap").tr:translate_y(yshift + (i - 1) * (linewidth + linespace) + linewidth)
                )
                geometry.rectanglebltr(half, generics.metal(1),
                    rows[rownum].rightdiode:get_area_anchor("cascodetopgatestrap").tl:translate_y(yshift + (i - 1) * (linewidth + linespace)),
                    point.combine(
                        rows[rownum].rightdiode:get_area_anchor("cascodetopgatestrap").tl,
                        rows[rownum].rightdiode:get_area_anchor("cascodetopgatestrap").tr
                    ):translate(-200, yshift + (i - 1) * (linewidth + linespace) + linewidth)
                )
                geometry.rectanglebltr(half, generics.metal(1),
                    point.combine(
                        rows[rownum].rightdiode:get_area_anchor("cascodetopgatestrap").tl,
                        rows[rownum].rightdiode:get_area_anchor("cascodetopgatestrap").tr
                    ):translate(200, yshift + (i - 1) * (linewidth + linespace)),
                    rows[rownum].rightdiode:get_area_anchor("cascodetopgatestrap").tr:translate_y(yshift + (i - 1) * (linewidth + linespace) + linewidth)
                )
            end
        end
    end

    -- global (half) bit lines
    if _E.hascalibration then
        for bit = 1, _E.numbits + 1 do
            half:add_area_anchor_bltr(string.format("leftbitline_%d", bit),
                rows[_E.rows].leftdiode:get_area_anchor("cascodeextrabotstrap").bl
                    :translate(-_E.busoffset - (bit - 1) * (linewidth + linespace) - linewidth, -1000),
                (rows[_E.rows].leftdiode:get_area_anchor("cascodeextrabotstrap").bl .. rows[1].lsbcells[1]
                    :get_area_anchor("sourcegate").tl):translate(-_E.busoffset - (bit - 1) * (linewidth + linespace), _E.busshift + (bit - 1) * (linewidth + linespace))
            )
            half:add_area_anchor_bltr(string.format("rightbitline_%d", bit),
                rows[_E.rows].rightdiode:get_area_anchor("cascodeextrabotstrap").br
                    :translate(_E.busoffset + (bit - 1) * (linewidth + linespace), -1000),
                (rows[_E.rows].rightdiode:get_area_anchor("cascodeextrabotstrap").br .. rows[1].lsbcells[1]:get_area_anchor("sourcegate").tl)
                    :translate(_E.busoffset + (bit - 1) * (linewidth + linespace) + linewidth, _E.busshift + (bit - 1) * (linewidth + linespace))
            )
            geometry.rectanglebltr(half, generics.metal(_E.innerbitlinesmetal),
                half:get_area_anchor(string.format("leftbitline_%d", bit)).bl,
                half:get_area_anchor(string.format("leftbitline_%d", bit)).tr
            )
            geometry.rectanglebltr(half, generics.metal(_E.innerbitlinesmetal),
                half:get_area_anchor(string.format("rightbitline_%d", bit)).bl,
                half:get_area_anchor(string.format("rightbitline_%d", bit)).tr
            )
            for rownum = 1, _E.rows do
                geometry.rectanglebltr(half, generics.metal(_E.gatebitlinemetal),
                    half:get_area_anchor(string.format("leftbitline_%d", bit)).bl .. rows[rownum].lsbcells[1]:get_area_anchor(string.format("bitline_%d", bit)).bl,
                    half:get_area_anchor(string.format("rightbitline_%d", bit)).br .. rows[rownum].lsbcells[1]:get_area_anchor(string.format("bitline_%d", bit)).tl
                )
                geometry.viabltr(half, _E.gatebitlinemetal, _E.innerbitlinesmetal,
                    half:get_area_anchor(string.format("leftbitline_%d", bit)).bl .. rows[rownum].lsbcells[1]:get_area_anchor(string.format("bitline_%d", bit)).bl,
                    (half:get_area_anchor(string.format("leftbitline_%d", bit)).br .. rows[rownum].lsbcells[1]:get_area_anchor(string.format("bitline_%d", bit)).tl):translate_y(2 * linewidth)
                )
                geometry.viabltr(half, _E.gatebitlinemetal, _E.innerbitlinesmetal,
                    half:get_area_anchor(string.format("rightbitline_%d", bit)).bl .. rows[rownum].lsbcells[1]:get_area_anchor(string.format("bitline_%d", bit)).bl,
                    (half:get_area_anchor(string.format("rightbitline_%d", bit)).br .. rows[rownum].lsbcells[1]:get_area_anchor(string.format("bitline_%d", bit)).tl):translate_y(2 * linewidth)
                )
            end
            half:add_area_anchor_bltr(string.format("bitline_%d", bit),
                half:get_area_anchor(string.format("leftbitline_%d", bit)).tl,
                half:get_area_anchor(string.format("rightbitline_%d", bit)).tr:translate_y(_E.bitlinewidth)
            )
            geometry.rectanglebltr(half, generics.metal(_E.innerbitlinesmetal),
                half:get_area_anchor(string.format("bitline_%d", bit)).bl,
                half:get_area_anchor(string.format("bitline_%d", bit)).tr
            )
        end
    end

    -- guardring
    -- FIXME: use layouthelpers.place_guardring?
    local holewidth = point.xdistance_abs(
        rows[_E.rows].lsbcells[1]:get_area_anchor("cascodeleftsourcedrain").bl,
        rows[_E.rows].lsbcells[_E.columns]:get_area_anchor("cascoderightsourcedrain").br
    ) + _E.sdwidth + 2 * _E.guardring.xspacetomosfet
    local holeheight = point.ydistance_abs(
        rows[_E.rows].lsbcells[1]:get_area_anchor("cascodeleftsourcedrain").bl,
        rows[1].lsbcells[1]:get_area_anchor("sourceleftsourcedrain").tl
    ) + 2 * _E.guardring.yspacetomosfet
    if _E.hascalibration and _E.guardring.yspaceconsiderbitlines then
        holeheight = holeheight + 2 * (_E.gatestrapwidth + _E.gatestrapspace) + yshift + (_E.numbits + 1) * (linewidth + linespace) - linespace
    end
    local nwellguardring = pcell.create_layout("auxiliary/guardring", "nwellguardring", {
        holewidth = holewidth,
        holeheight = holeheight,
        ringwidth = _E.guardring.width,
        contype = "n",
        implantextension = _E.guardring.implantextension,
        wellextension = _E.guardring.wellextension,
        soiopenextension = _E.guardring.soiopenextension,
    })
    nwellguardring:move_point(nwellguardring:get_area_anchor("innerboundary").bl, rows[_E.rows].lsbcells[1]:get_area_anchor("cascodeleftsourcedrain").bl)
    nwellguardring:translate_x(-_E.guardring.xspacetomosfet)
    nwellguardring:translate_y(-_E.guardring.yspacetomosfet)
    if _E.hascalibration and _E.guardring.yspaceconsiderbitlines then
        nwellguardring:translate_y(-_E.gatestrapwidth - _E.gatestrapspace - yshift - (_E.numbits + 1) * (linewidth + linespace) + linespace)
    end
    half:merge_into(nwellguardring)

    -- add global bit lines connector
    if _E.hascalibration then
        local buswidth = env.oscillator.buswidth
        local busspace = env.oscillator.busspace
        local busstartx = half:get_area_anchor("bitline_1").r - 3 * (buswidth + busspace)
        local busendy = half:get_area_anchor(string.format("bitline_%d", _E.numbits + 1)).t + 2000
        for bit = 1, _E.numbits + 1 do
            geometry.viabltr(half, _E.innerbitlinesmetal, _E.outerbitlinesmetal,
                point.create(
                    busstartx - (bit - 1) * (buswidth + busspace) - 2 * buswidth,
                    half:get_area_anchor(string.format("bitline_%d", bit)).b
                ),
                point.create(
                    busstartx - (bit - 1) * (buswidth + busspace),
                    half:get_area_anchor(string.format("bitline_%d", bit)).t
                )
            )
            geometry.rectanglebltr(half, generics.metal(_E.outerbitlinesmetal),
                point.create(
                    busstartx - (bit - 1) * (buswidth + busspace) - buswidth,
                    half:get_area_anchor(string.format("bitline_%d", bit)).b
                ),
                point.create(
                    busstartx - (bit - 1) * (buswidth + busspace),
                    busendy
                )
            )
        end
        half:add_anchor("bustarget",
            point.create(
                busstartx - (_E.numbits - 1) / 2 * (buswidth + busspace) - buswidth - busspace / 2,
                busendy
            )
        )
    end

    -- lvs marker for MOSFETs
    geometry.rectanglebltr(half, generics.other(string.format("lvsmarker%d", 2)),
        nwellguardring:get_area_anchor("outerwell").bl,
        nwellguardring:get_area_anchor("outerwell").tr
    )

    -- boundary of half layout
    -- the boundary's size is a multiple of the decap cellsize for better placement
    local boundary = nwellguardring:get_boundary()
    local xmin = util.polygon_xmin(boundary)
    local xmax = util.polygon_xmax(boundary)
    local ymin = util.polygon_ymin(boundary)
    local ymax = util.polygon_ymax(boundary)
    local boundarywidth = xmax - xmin
    local boundaryxfactor = math.ceil(boundarywidth / env.decap.cellsize)
    if boundaryxfactor % 2 == 0 then -- boundaryxfactor must be odd
        boundaryxfactor = boundaryxfactor + 1
    end
    local griddedboundarywidth = env.decap.cellsize * boundaryxfactor
    local boundaryxoffset = (griddedboundarywidth - boundarywidth) / 2
    local boundaryheight = ymax - ymin
    local boundaryyfactor = math.ceil(boundaryheight / env.decap.cellsize)
    local griddedboundaryheight = env.decap.cellsize * boundaryyfactor
    local boundaryyoffset = (griddedboundaryheight - boundaryheight) / 2
    half:set_boundary_rectangular(
        point.create(xmin - boundaryxoffset, ymin - boundaryyoffset),
        point.create(xmax + boundaryxoffset, ymax + boundaryyoffset)
    )
    half:set_alignment_box(
        point.create(xmin - boundaryxoffset, ymin - boundaryyoffset),
        point.create(xmax + boundaryxoffset, ymax + boundaryyoffset)
    )

    -- add power rail anchors
    for i = 1, diodeplnumlines do
        half:add_area_anchor_bltr(
            string.format("powerline_%d", _E.columns / 2 * plnumlines + i),
            rows[_E.rows].diode:get_area_anchor(string.format("powerline_%d", i)).bl .. nwellguardring:get_area_anchor("bottomsegment").bl,
            rows[1].diode:get_area_anchor(string.format("powerline_%d", i)).tr .. nwellguardring:get_area_anchor("topsegment").tr
        )
    end
    for column = 1, _E.columns / 2 do
        for i = 1, plnumlines do
            local indexleft = (column - 1) * plnumlines + i
            local indexright = (_E.columns / 2 + column - 1) * plnumlines + diodeplnumlines + i -- +1 for diode power line (FIXME)
            half:add_area_anchor_bltr(
                string.format("powerline_%d", indexleft),
                rows[_E.rows].lsbcells[column]:get_area_anchor(string.format("powerline_%d", i)).bl ..
                nwellguardring:get_area_anchor("bottomsegment").bl,
                rows[1].lsbcells[column]:get_area_anchor(string.format("powerline_%d", i)).tr ..
                nwellguardring:get_area_anchor("topsegment").tr
            )
            half:add_area_anchor_bltr(
                string.format("powerline_%d", indexright),
                rows[_E.rows].lsbcells[_E.columns / 2 + column]:get_area_anchor(string.format("powerline_%d", i)).bl ..
                nwellguardring:get_area_anchor("bottomsegment").bl,
                rows[1].lsbcells[_E.columns / 2 + column]:get_area_anchor(string.format("powerline_%d", i)).tr ..
                nwellguardring:get_area_anchor("topsegment").tr
            )
        end
    end

    -- connect powerlines to guardring
    local numpowerlines = _E.columns * plnumlines + diodeplnumlines
    for column = 1, numpowerlines do
        if not (column > _E.columns / 2 * plnumlines and column <= _E.columns / 2 * plnumlines + diodeplnumlines) then
            geometry.rectanglebltr(half, generics.metal(_E.powermetal + 1),
                half:get_area_anchor(string.format("powerline_%d", column)).bl,
                half:get_area_anchor(string.format("powerline_%d", column)).tr
            )
            geometry.viabltr(half, 1, _E.powermetal + 1,
                half:get_area_anchor(string.format("powerline_%d", column)).bl .. nwellguardring:get_area_anchor("bottomsegment").bl,
                half:get_area_anchor(string.format("powerline_%d", column)).br .. nwellguardring:get_area_anchor("bottomsegment").tl
            )
            if column ~= (numpowerlines - 1) / 2 + 1 then -- skip upper via for diode, as ibias is connected there
                geometry.viabltr(half, 1, _E.powermetal + 1,
                    half:get_area_anchor(string.format("powerline_%d", column)).bl .. nwellguardring:get_area_anchor("topsegment").bl,
                    half:get_area_anchor(string.format("powerline_%d", column)).br .. nwellguardring:get_area_anchor("topsegment").tl
                )
            end
        end
    end

    -- place top-level vdd connection
    -- FIXME: this code can be simplified by using some functions
    local vddbl = half:get_area_anchor(string.format("powerline_%d", 1)).bl
    local vddtr = half:get_area_anchor(string.format("powerline_%d", numpowerlines)).tr
    local diff = point.xdistance_abs(vddbl, vddtr)
    local correction = diff - env.decap.cellsize * math.floor(diff / env.decap.cellsize)
    local vddbl_ongrid = vddbl:copy()
    local vddtr_ongrid = vddtr:copy()
    local correction_left, correction_right = evenodddiv2(correction)
    vddbl_ongrid:translate_x( correction_left)
    vddtr_ongrid:translate_x(-correction_right)
    local metaldefs = {
        {
            metal = 7,
            width = 1000,
            space = 1000,
        },
        {
            metal = 8,
            width = 2400,
            space = 2400,
        },
    }
    local prevanchors = {}
    prevanchors[1] = {}
    for i = 1, numpowerlines do
        table.insert(prevanchors[1], {
            blx = half:get_area_anchor(string.format("powerline_%d", i)).bl:getx(),
            trx = half:get_area_anchor(string.format("powerline_%d", i)).br:getx(),
        })
    end
    for i, def in ipairs(metaldefs) do
        if i == 1 then -- special treatment for lines connecting to the LSB powerlines
            local width, height, space, shift, numlines = geometry.rectanglehlines_height_space_settings(vddbl, vddtr, def.width, def.space)
            geometry.rectanglearray(half, generics.metal(def.metal),
                width, height,
                vddbl:getx(), vddbl:gety() + shift,
                1, numlines,
                0, height + space
            );
            prevanchors[i + 1] = {}
            for v = 1, numlines do
                for column, prev in ipairs(prevanchors[i]) do
                    local vbl = point.create(prev.blx, vddbl:gety() + shift + (v - 1) * (height + space))
                    local vtr = point.create(prev.trx, vddbl:gety() + shift + (v - 1) * (height + space) + height)
                    geometry.viabltr(half, def.metal - 1, def.metal,
                        vbl, vtr
                    );
                end
                table.insert(prevanchors[i + 1], {
                    bly = vddbl:gety() + shift + (v - 1) * (height + space),
                    try = vddbl:gety() + shift + (v - 1) * (height + space) + height,
                })
            end
        elseif i % 2 == 1 then
            local width, height, space, shift, numlines = geometry.rectanglehlines_height_space_settings(vddbl_ongrid, vddtr_ongrid, def.width, def.space)
            geometry.rectanglearray(half, generics.metal(def.metal),
                width, height,
                vddbl_ongrid:getx(), vddbl_ongrid:gety() + shift,
                1, numlines,
                0, height + space
            );
            prevanchors[i + 1] = {}
            for v = 1, numlines do
                for column, prev in ipairs(prevanchors[i]) do
                    local vbl = point.create(prev.blx, vddbl_ongrid:gety() + shift + (v - 1) * (height + space))
                    local vtr = point.create(prev.trx, vddbl_ongrid:gety() + shift + (v - 1) * (height + space) + height)
                    geometry.viabltr(half, def.metal - 1, def.metal,
                        vbl, vtr
                    );
                end
                table.insert(prevanchors[i + 1], {
                    bly = vddbl_ongrid:gety() + shift + (v - 1) * (height + space),
                    try = vddbl_ongrid:gety() + shift + (v - 1) * (height + space) + height,
                })
            end
        else
            local width, height, space, shift, numlines = geometry.rectanglevlines_width_space_settings(vddbl_ongrid, vddtr_ongrid, def.width, def.space)
            geometry.rectanglearray(half, generics.metal(def.metal),
                width, height,
                vddbl_ongrid:getx() + shift, vddbl_ongrid:gety(),
                numlines, 1,
                width + space, 0
            );
            prevanchors[i + 1] = {}
            for v = 1, numlines do
                for column, prev in ipairs(prevanchors[i]) do
                    local vbl = point.create(vddbl_ongrid:getx() + shift + (v - 1) * (width + space),         prev.bly)
                    local vtr = point.create(vddbl_ongrid:getx() + shift + (v - 1) * (width + space) + width, prev.try)
                    geometry.viabltr(half, def.metal - 1, def.metal,
                        vbl, vtr
                    );
                end
                table.insert(prevanchors[i + 1], {
                    blx = vddbl_ongrid:getx() + shift + (v - 1) * (width + space),
                    trx = vddbl_ongrid:getx() + shift + (v - 1) * (width + space) + width,
                })
            end
        end
    end
    -- connect to powergrid
    local tmstarty = half:get_alignment_anchor("outerbl"):gety()
    local numtopmetalpowerlines = #prevanchors[#prevanchors]
    for index, prev in ipairs(prevanchors[#prevanchors]) do
        half:add_area_anchor_bltr(string.format("topmetalpowerline_%d", index),
            point.create(prev.blx, vddbl_ongrid:gety()),
            point.create(prev.trx, vddtr_ongrid:gety())
        )
        for i = 1, boundaryyfactor do
            local yshift = tmstarty + env.decap.cellsize / 2 + (i - 1) * env.decap.cellsize
            local vbl = point.create(prev.blx, yshift - env.decap.gridmetalwidths[1].vdd / 2)
            local vtr = point.create(prev.trx, yshift + env.decap.gridmetalwidths[1].vdd / 2)
            geometry.viabltr(half, 8, 9, vbl, vtr)
        end
    end

    -- metal excludes (FIXME: place filling)
    for metal = 1, technology.resolve_metal(-2) do
        geometry.rectanglebltr(half,
            generics.metalexclude(metal),
            nwellguardring:get_area_anchor("outerboundary").bl,
            nwellguardring:get_area_anchor("outerboundary").tr
        )
    end

    -- add nwell guard ring anchors
    half:add_area_anchor_bltr("nwellguardringboundary",
        nwellguardring:get_area_anchor("bottomsegment").bl,
        nwellguardring:get_area_anchor("topsegment").tr
    )

    -- add output
    half:add_area_anchor_bltr("output",
        rows[_E.rows].lsbcells[1]:get_area_anchor("cascodebotstrap").bl:translate_x(-_E.outputshift - _E.outputwidth),
        rows[1].lsbcells[1]:get_area_anchor("cascodetopstrap").tl:translate_x(-_E.outputshift)
    )
    if _E.inneroutputmetal ~= _E.outeroutputmetal then
        geometry.viabltr(half, _E.inneroutputmetal, _E.outeroutputmetal,
            half:get_area_anchor("output").bl,
            half:get_area_anchor("output").tr
        )
    else
        geometry.rectanglebltr(half, generics.metal(_E.inneroutputmetal),
            half:get_area_anchor("output").bl,
            half:get_area_anchor("output").tr
        )
    end

    -- connect all outputs
    for rownum = 1, _E.rows do
        geometry.rectanglebltr(half, generics.metal(_E.inneroutputmetal),
            point.combine_12(
                half:get_area_anchor("output").br,
                rows[rownum].lsbcells[1]:get_area_anchor("cascodetopstrap").bl
            ),
            rows[rownum].lsbcells[1]:get_area_anchor("cascodetopstrap").tl
        )
        geometry.rectanglebltr(half, generics.metal(_E.inneroutputmetal),
            point.combine_12(
                half:get_area_anchor("output").br,
                rows[rownum].lsbcells[1]:get_area_anchor("cascodebotstrap").bl
            ),
            rows[rownum].lsbcells[1]:get_area_anchor("cascodebotstrap").tl
        )
    end

    -- ibias vias
    geometry.rectanglebltr(half, generics.metal(_E.biasinputmetal),
        half:get_area_anchor("ibias").tl,
        half:get_area_anchor("ibias").tr:translate_y(_E.ibiasviashift)
    )
    geometry.viabltr(half, _E.biasinputmetal, 8,
        half:get_area_anchor("ibias").tl:translate_y(_E.ibiasviashift),
        half:get_area_anchor("ibias").tr:translate_y(_E.ibiasviashift + _E.ibiasviaheight)
    )

    -- fill empty areas
    if not env.disableallfill then
        local fillexcludes = {
            [8] = {
                util.rectangle_to_polygon(
                    point.create(
                        half:get_alignment_anchor("outerbl"):getx(),
                        util.fix_to_grid_lower(half:get_area_anchor(string.format("topmetalpowerline_%d", 1)).b, env.decap.cellsize)
                    ),
                    point.create(
                        half:get_alignment_anchor("outertr"):getx(),
                        half:get_area_anchor(string.format("topmetalpowerline_%d", 1)).b
                    ),
                    env.boundaryextensions[8].x,
                    env.boundaryextensions[8].x,
                    env.boundaryextensions[8].y,
                    env.boundaryextensions[8].y
                ),
                util.rectangle_to_polygon(
                    half:get_area_anchor(string.format("topmetalpowerline_%d", 1)).bl,
                    half:get_area_anchor(string.format("topmetalpowerline_%d", numtopmetalpowerlines)).tr,
                    env.boundaryextensions[8].x,
                    env.boundaryextensions[8].x,
                    env.boundaryextensions[8].y,
                    env.boundaryextensions[8].y
                ),
                util.rectangle_to_polygon(
                    point.create(
                        half:get_area_anchor("output").l,
                        half:get_alignment_anchor("outerbl"):gety()
                    ),
                    half:get_area_anchor("output").tr,
                    env.boundaryextensions[8].x,
                    env.boundaryextensions[8].x,
                    env.boundaryextensions[8].y,
                    env.boundaryextensions[8].y
                ),
            },
        }
        for metal = 1, _E.biasinputmetal do
            if not fillexcludes[metal] then fillexcludes[metal] = {} end
            table.insert(fillexcludes[metal],
                util.rectangle_to_polygon(
                    half:get_area_anchor("nwellguardringboundary").bl,
                    half:get_area_anchor("nwellguardringboundary").tr,
                    env.boundaryextensions[1].x,
                    env.boundaryextensions[1].x,
                    env.boundaryextensions[1].y,
                    env.boundaryextensions[1].y
                )
            )
        end
        for metal = _E.inneroutputmetal, 7 do
            if not fillexcludes[metal] then fillexcludes[metal] = {} end
            table.insert(fillexcludes[metal], 
                util.rectangle_to_polygon(
                    point.create(
                        half:get_area_anchor("output").l,
                        half:get_area_anchor("nwellguardringboundary").b
                    ),
                    point.create(
                        half:get_area_anchor("nwellguardringboundary").r,
                        half:get_area_anchor("output").t
                    ),
                    env.boundaryextensions[7].x,
                    env.boundaryextensions[7].x,
                    env.boundaryextensions[7].y,
                    env.boundaryextensions[7].y
                )
            )
            table.insert(fillexcludes[metal], 
                util.rectangle_to_polygon(
                    point.create(
                        half:get_area_anchor("nwellguardringboundary").l,
                        half:get_area_anchor("output").t
                    ),
                    point.create(
                        half:get_area_anchor("nwellguardringboundary").r,
                        half:get_area_anchor("nwellguardringboundary").t
                    ),
                    env.boundaryextensions[7].x,
                    env.boundaryextensions[7].x,
                    env.boundaryextensions[7].y,
                    env.boundaryextensions[7].y
                )
            )
        end
        for metal = _E.biasinputmetal, 8 do
            if not fillexcludes[metal] then fillexcludes[metal] = {} end
            table.insert(fillexcludes[metal], 
                util.rectangle_to_polygon(
                    half:get_area_anchor("ibias").tl:translate_y(_E.ibiasviashift),
                    half:get_area_anchor("ibias").tr:translate_y(_E.ibiasviashift + _E.ibiasviaheight),
                    env.boundaryextensions[7].x,
                    env.boundaryextensions[7].x,
                    env.boundaryextensions[7].y,
                    env.boundaryextensions[7].y
                )
            )
        end
        for metal = 1, 8 do
            local fillboundary = util.rectangle_to_polygon(
                half:get_alignment_anchor("outerbl"):translate(
                    0,
                    env.boundaryextensions[metal].y
                ),
                half:get_alignment_anchor("outertr"):translate(
                    -env.boundaryextensions[metal].x - env.decapgroundextension[metal],
                    -env.boundaryextensions[metal].y - env.decapgroundextension[metal]
                )
            )
            geometry.rectangle_fill_in_boundary(half, generics.metal(metal),
                env.emptyfillsizes[metal].width,
                env.emptyfillsizes[metal].height,
                env.emptyfillsizes[metal].xpitch,
                env.emptyfillsizes[metal].ypitch,
                0, 0, -- start shifts
                fillboundary,
                fillexcludes[metal]
            )
        end
    end

    -- end of half layout

    local righthalf = currentmirror:add_child(half, "righthalf")
    local lefthalf = currentmirror:add_child(half, "lefthalf")
    lefthalf:mirror_at_yaxis()
    lefthalf:move_point_x(
        lefthalf:get_alignment_anchor("outertr"),
        point.create(-(env.oscillator.resonator.outerdiameter + 2 * env.oscillator.resonator.fillextension) / 2 , 0)
    )
    righthalf:move_point_x(
        righthalf:get_alignment_anchor("outerbl"),
        point.create((env.oscillator.resonator.outerdiameter + 2 * env.oscillator.resonator.fillextension) / 2 , 0)
    )

    -- add vdd anchors
    currentmirror:inherit_area_anchor_as(lefthalf, "powerline_1", "leftpowerline_1")
    currentmirror:inherit_area_anchor_as(righthalf, "powerline_1", "rightpowerline_1")

    -- add output anchor
    currentmirror:inherit_area_anchor_as(lefthalf, "output", "leftoutput")
    currentmirror:inherit_area_anchor_as(righthalf, "output", "rightoutput")

    -- add global bit lines anchors
    if _E.hascalibration then
        for bit = 1, _E.numbits + 1 do
            currentmirror:add_area_anchor_bltr(string.format("leftbitline_%d", bit),
                lefthalf:get_area_anchor(string.format("bitline_%d", bit)).bl,
                lefthalf:get_area_anchor(string.format("bitline_%d", bit)).tr
            )
            currentmirror:add_area_anchor_bltr(string.format("rightbitline_%d", bit),
                righthalf:get_area_anchor(string.format("bitline_%d", bit)).bl,
                righthalf:get_area_anchor(string.format("bitline_%d", bit)).tr
            )
        end
    end

    -- bus targets
    if _E.hascalibration then
        currentmirror:inherit_anchor_as(lefthalf, "bustarget", "leftbustarget")
        currentmirror:inherit_anchor_as(righthalf, "bustarget", "rightbustarget")
    end

    -- ibias anchor (used for alignment of digital bus)
    -- FIXME: this should be handled differently (outside in the toplevel cell)
    currentmirror:add_area_anchor_bltr("ibiasleft",
        lefthalf:get_area_anchor("ibias").bl,
        lefthalf:get_area_anchor("ibias").tr
    )
    currentmirror:add_area_anchor_bltr("ibiasright",
        righthalf:get_area_anchor("ibias").bl,
        righthalf:get_area_anchor("ibias").tr
    )

    -- target anchors for ibias current routing
    currentmirror:add_anchor("ibiasinleft",
        point.combine(
            lefthalf:get_area_anchor("ibias").tl,
            lefthalf:get_area_anchor("ibias").tr
        ):translate_y(_E.ibiasviashift + _E.ibiasviaheight)
    )
    currentmirror:add_anchor("ibiasinright",
        point.combine(
            righthalf:get_area_anchor("ibias").tl,
            righthalf:get_area_anchor("ibias").tr
        ):translate_y(_E.ibiasviashift + _E.ibiasviaheight)
    )

    -- alignment box
    currentmirror:inherit_alignment_box(lefthalf)
    currentmirror:inherit_alignment_box(righthalf)

    -- boundaries
    local leftboundary = lefthalf:get_boundary()
    local xmin = util.polygon_xmin(leftboundary)
    local ymin = util.polygon_ymin(leftboundary)
    local rightboundary = righthalf:get_boundary()
    local xmax = util.polygon_xmax(rightboundary)
    local ymax = util.polygon_ymax(rightboundary)
    currentmirror:set_boundary_rectangular(
        point.create(xmin, ymin),
        point.create(xmax, ymax)
    )
    currentmirror:add_area_anchor_bltr("boundary",
        point.create(xmin, ymin),
        point.create(xmax, ymax)
    )
    for metal = 1, _E.maxboundarymetal do
        currentmirror:add_layer_boundary(
            generics.metal(metal),
            util.rectangle_to_polygon(
                lefthalf:get_area_anchor("nwellguardringboundary").bl,
                lefthalf:get_area_anchor("nwellguardringboundary").tr,
                env.boundaryextensions[metal].x, env.boundaryextensions[metal].x, env.boundaryextensions[metal].y, env.boundaryextensions[metal].y
            )
        )
        currentmirror:add_layer_boundary(
            generics.metal(metal),
            util.rectangle_to_polygon(
                righthalf:get_area_anchor("nwellguardringboundary").bl,
                righthalf:get_area_anchor("nwellguardringboundary").tr,
                env.boundaryextensions[metal].x, env.boundaryextensions[metal].x, env.boundaryextensions[metal].y, env.boundaryextensions[metal].y
            )
        )
    end
    if _E.hascalibration then
        currentmirror:add_layer_boundary(
            generics.metal(_E.innerbitlinesmetal),
            util.rectangle_to_polygon(
                righthalf:get_area_anchor(string.format("leftbitline_%d", _E.numbits + 1)).bl,
                righthalf:get_area_anchor(string.format("rightbitline_%d", _E.numbits + 1)).tr,
                env.boundaryextensions[3].x, env.boundaryextensions[3].x, env.boundaryextensions[3].y, env.boundaryextensions[3].y
            )
        )
        currentmirror:add_layer_boundary(
            generics.metal(_E.innerbitlinesmetal),
            util.rectangle_to_polygon(
                lefthalf:get_area_anchor(string.format("rightbitline_%d", _E.numbits + 1)).bl,
                lefthalf:get_area_anchor(string.format("leftbitline_%d", _E.numbits + 1)).tr,
                env.boundaryextensions[3].x, env.boundaryextensions[3].x, env.boundaryextensions[3].y, env.boundaryextensions[3].y
            )
        )
    end

    -- ports
    currentmirror:add_port("ibiasleft", generics.metalport(8), currentmirror:get_anchor("ibiasinleft"), 1000)
    currentmirror:add_port("ibiasright", generics.metalport(8), currentmirror:get_anchor("ibiasinright"), 1000)
    currentmirror:add_port("iout", generics.metalport(_E.outeroutputmetal), currentmirror:get_area_anchor("leftoutput").br, 1000)
    currentmirror:add_port("iout", generics.metalport(_E.outeroutputmetal), currentmirror:get_area_anchor("rightoutput").bl, 1000)
    currentmirror:add_port("vdd1v8", generics.metalport(6), currentmirror:get_area_anchor("leftpowerline_1").br, 1000)
    currentmirror:add_port("vdd1v8", generics.metalport(6), currentmirror:get_area_anchor("rightpowerline_1").bl, 1000)
    currentmirror:add_port("vss", generics.otherport("pwell"), point.create(0, 0), 1000)
end

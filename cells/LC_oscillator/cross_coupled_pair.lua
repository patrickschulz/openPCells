function requirements()
    if technology.get_number_of_metals() < 8 then
        return false, "this cell requires a metal stack with at least 8 metals"
    end
    return true
end

function parameters()
    pcell.add_parameters(
        { "gatelength", technology.get_dimension("Minimum Gate Length") },
        { "gatespace", technology.get_dimension("Minimum Gate Space", "Minimum Gate XSpace") },
        { "gatestrapwidth", technology.get_dimension("Minimum M5 Width") },
        { "gateext", technology.get_optional_dimension("Minimum Gate Extension", 0) },
        { "sdwidth", technology.get_dimension("Minimum M7 Width") },
        { "oxidetype", 1 },
        { "mosfetmarker", 1 },
        { "pvthtype", 1 },
        { "nvthtype", 1 },
        { "drawactivedummies", false },
        { "activedummywidth", 0, posvals = even() },
        { "activedummyspace", 0 },
        { "powerwidth", technology.get_dimension("Minimum M4M5 Viawidth") },
        { "powerspace", technology.get_dimension("Minimum M5 Space") },
        { "fingersperside", 4, posvals = even() },
        { "pmosfingerwidth", technology.get_dimension("Analog Gate Width", "Minimum Gate Width") },
        { "nmosfingerwidth", technology.get_dimension("Analog Gate Width", "Minimum Gate Width") },
        { "middledummyfingersperside", 1 },
        { "outerdummyfingers", 0 },
        { "outputoffset", 0 },
        { "outputminwidth", technology.get_dimension("Minimum M7M8 Viawidth") },
        { "crossingoffset", 0 },
        { "drawpsubguardring", true },
        { "quantize_psub_guardring", false },
        { "psubguardring_ringwidth", technology.get_dimension("Minimum Active Contact Region Size") },
        { "psubguardring_quantized_gridsize", technology.get_dimension("Minimum Active Contact Region Size"), follow = "psubguardring_ringwidth" },
        { "guardring_width", technology.get_dimension("Minimum Active Contact Region Size"), posvals = even() },
        { "guardring_xspace", technology.get_dimension("Minimum Active Space") },
        { "guardring_yspace", technology.get_dimension("Minimum Active Space") },
        { "guardring_xspacetomosfet", technology.get_dimension("Minimum Active Space") },
        { "guardring_yspacetomosfet", technology.get_dimension("Minimum Active Space"), posvals = even() },
        { "guardring_soiopenextension", technology.get_dimension("Minimum Soiopen Extension") },
        { "guardring_implantextension", technology.get_dimension("Minimum Implant Extension") },
        { "guardring_wellextension", technology.get_dimension("Minimum Well Extension") },
        { "guardring_deepwelloffset", 0 },
        { "guardring_interconnwidth", technology.get_dimension("Minimum M1 Width"), posvals = even() },
        { "connectguardrings", true },
        { "mindrainstrapspace", technology.get_dimension("Minimum M3 Space") },
        { "inlinedrainstrap", false },
        { "topviawidth", technology.get_dimension("Minimum M7M8 Viawidth"), posvals = even() },
        { "crossingmetal", 5 },
        { "drainmetal", 7 },
        { "outputmetal", 8 },
        { "vtailshift", technology.get_dimension("Minimum M5 Space") },
        { "vtailwidth", technology.get_dimension("Minimum M5 Width") },
        { "vtailmetal", 5 },
        { "vtaillinewidth", technology.get_dimension("Minimum M5 Width") },
        { "vtaillinespace", technology.get_dimension("Minimum M5 Space") },
        { "fetpowermetal", 3 },
        { "vssmetal", 5 },
        { "vssshift", technology.get_dimension("Minimum M5 Space") },
        { "vsswidth", technology.get_dimension("Minimum M5 Width") },
        { "vsslinewidth", technology.get_dimension("Minimum M5 Width") },
        { "vsslinespace", technology.get_dimension("Minimum M5 Space") }
    )
end

function check(_P)
    if _P.inlinedrainstrap then
        return false, "'inlinedrainstrap' is currently not properly supported"
    end
    return true
end

function layout(ccp, _P)
    local drainstrapspace = (2 * _P.guardring_yspacetomosfet + _P.guardring_width) / 2 - _P.topviawidth / 2
    if _P.drawactivedummies then
        drainstrapspace = drainstrapspace + (_P.activedummywidth) / 2 + _P.activedummyspace
    end
    if drainstrapspace < _P.mindrainstrapspace then
        drainstrapspace = _P.mindrainstrapspace
    end

    local commonoptions = {
        gatelength = _P.gatelength,
        gatespace = _P.gatespace,
        fingersperside = _P.fingersperside,
        oxidetype = _P.oxidetype,
        gatestrapwidth = _P.gatestrapwidth,
        sdwidth = _P.sdwidth,
        middledummyfingersperside = _P.middledummyfingersperside,
        outerdummyfingers = _P.outerdummyfingers,
        mosfetmarker = _P.mosfetmarker,
        powerwidth = _P.powerwidth,
        powerspace = _P.powerspace,
        inlinedrainstrap = _P.inlinedrainstrap,
        drawactivedummies = _P.drawactivedummies,
        activedummywidth = _P.activedummywidth,
        activedummyspace = _P.activedummyspace,
        drainstrapspace = drainstrapspace,
        gateext = _P.gateext,
        crossingoffset = _P.crossingoffset,
        crossingmetal = _P.crossingmetal,
        drainmetal = _P.drainmetal,
        fetpowermetal = _P.fetpowermetal,
    }

    local nfets = pcell.create_layout("analog/cross_coupled_pair", "_ccp", util.add_options(commonoptions, {
        channeltype = "nmos",
        fingerwidth = _P.nmosfingerwidth,
        vthtype = _P.nvthtype,
    }))

    local pfets = pcell.create_layout("analog/cross_coupled_pair", "_ccp", util.add_options(commonoptions, {
        channeltype = "pmos",
        fingerwidth = _P.pmosfingerwidth,
        vthtype = _P.pvthtype,
    }))

    ccp:merge_into(nfets)
    if _P.drawactivedummies then
        pfets:align_area_anchor_top("bottomactivedummy", nfets, "topactivedummy")
        pfets:translate_y(2 * _P.guardring_yspacetomosfet + _P.guardring_width + _P.activedummywidth)
    else
        pfets:abut_area_anchor_top("active", nfets, "active")
        pfets:translate_y(2 * _P.guardring_yspacetomosfet + _P.guardring_width)
    end
    ccp:merge_into(pfets)

    -- copy active anchors for guardring alignment
    ccp:inherit_area_anchor_as(pfets, "active", "pfetactive")
    ccp:inherit_area_anchor_as(nfets, "active", "nfetactive")
    if _P.drawactivedummies then
        ccp:inherit_area_anchor_as(pfets, "topactivedummy", "pfettopactivedummy")
        ccp:inherit_area_anchor_as(pfets, "bottomactivedummy", "pfetbottomactivedummy")
        ccp:inherit_area_anchor_as(nfets, "topactivedummy", "nfettopactivedummy")
        ccp:inherit_area_anchor_as(nfets, "bottomactivedummy", "nfetbottomactivedummy")
    end
    ccp:inherit_area_anchor_as(pfets, "leftouterdummyactive", "leftouterpfetdummyactive")
    ccp:inherit_area_anchor_as(pfets, "rightouterdummyactive", "rightouterpfetdummyactive")
    ccp:inherit_area_anchor_as(nfets, "leftouterdummyactive", "leftouternfetdummyactive")
    ccp:inherit_area_anchor_as(nfets, "rightouterdummyactive", "rightouternfetdummyactive")

    -- output connection
    local outputwidth = point.xdistance_abs(
        nfets:get_area_anchor("leftdrainstrap").bl,
        nfets:get_area_anchor("leftdrainstrap").tr
    )
    local outputextension = 0
    if outputwidth - _P.outputoffset < _P.outputminwidth then
        outputextension = _P.outputminwidth - (outputwidth - _P.outputoffset)
    end
    ccp:add_area_anchor_bltr("leftoutput",
        point.create(
            nfets:get_area_anchor("leftdrainstrap").l - outputextension,
            (nfets:get_area_anchor("leftdrainstrap").b + pfets:get_area_anchor("leftdrainstrap").t) / 2 - _P.topviawidth / 2
        ),
        point.create(
            nfets:get_area_anchor("leftdrainstrap").r - _P.outputoffset,
            (nfets:get_area_anchor("leftdrainstrap").b + pfets:get_area_anchor("leftdrainstrap").t) / 2 + _P.topviawidth / 2
        )
    )
    ccp:add_area_anchor_bltr("rightoutput",
        point.create(
            nfets:get_area_anchor("rightdrainstrap").l + _P.outputoffset,
            (nfets:get_area_anchor("rightdrainstrap").b + pfets:get_area_anchor("rightdrainstrap").t) / 2 - _P.topviawidth / 2
        ),
        point.create(
            nfets:get_area_anchor("rightdrainstrap").r + outputextension,
            (nfets:get_area_anchor("rightdrainstrap").b + pfets:get_area_anchor("rightdrainstrap").t) / 2 + _P.topviawidth / 2
        )
    )
    geometry.viabltr(ccp, _P.drainmetal, _P.outputmetal,
        ccp:get_area_anchor("leftoutput").bl,
        ccp:get_area_anchor("leftoutput").tr
    )
    geometry.rectanglebltr(ccp, generics.metal(_P.drainmetal),
        ccp:get_area_anchor("leftoutput").bl,
        ccp:get_area_anchor("leftoutput").tr:translate_x(_P.outputoffset)
    )
    geometry.viabltr(ccp, _P.drainmetal, _P.outputmetal,
        ccp:get_area_anchor("rightoutput").bl,
        ccp:get_area_anchor("rightoutput").tr
    )
    geometry.rectanglebltr(ccp, generics.metal(_P.drainmetal),
        ccp:get_area_anchor("rightoutput").bl:translate_x(-_P.outputoffset),
        ccp:get_area_anchor("rightoutput").tr
    )

    ccp:inherit_area_anchor_as(pfets, "common", "ibiasin")
    ccp:inherit_area_anchor_as(nfets, "common", "vssin")

    -- bias current landing pad
    ccp:add_area_anchor_bltr("ibias",
        ccp:get_area_anchor("ibiasin").tl:translate_y(_P.vtailshift),
        ccp:get_area_anchor("ibiasin").tr:translate_y(_P.vtailshift + _P.vtailwidth)
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
        ccp:get_area_anchor("vssin").bl:translate_y(-_P.vssshift - _P.vsswidth),
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
    local igbtarget
    local igttarget
    if _P.drawactivedummies then
        igbtarget = "pfetbottomactivedummy"
        igttarget = "pfettopactivedummy"
    else
        igbtarget = "pfetactive"
        igttarget = "pfetactive"
    end
    layouthelpers.place_guardring(
        ccp,
        point.create(
            ccp:get_area_anchor("leftouternfetdummyactive").l,
            ccp:get_area_anchor(igbtarget).b
        ),
        point.create(
            ccp:get_area_anchor("rightouternfetdummyactive").r,
            ccp:get_area_anchor(igttarget).t
        ),
        _P.guardring_xspacetomosfet, _P.guardring_yspacetomosfet,
        "pwellguardring_",
        {
            ringwidth = _P.guardring_width,
            contype = "p",
            soiopeninnerextension = _P.guardring_soiopenextension,
            soiopenouterextension = _P.guardring_soiopenextension,
            implantinnerextension = _P.guardring_implantextension,
            implantouterextension = _P.guardring_implantextension,
            fit = false,
            innerimplantpolarity = "p",
            fillinnerimplant = true,
        }
    )

    -- nwell guardring
    local ngtarget
    if _P.drawactivedummies then
        ngtarget = "nfetbottomactivedummy"
    else
        ngtarget = "nfetactive"
    end
    layouthelpers.place_guardring_with_hole(
        ccp,
        point.create(
            ccp:get_area_anchor("pwellguardring_outerboundary").l,
            ccp:get_area_anchor(ngtarget).b
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
            soiopeninnerextension = _P.guardring_soiopenextension,
            soiopenouterextension = _P.guardring_soiopenextension,
            implantinnerextension = _P.guardring_implantextension,
            implantouterextension = _P.guardring_implantextension,
            wellinnerextension = _P.guardring_wellextension,
            wellouterextension = _P.guardring_wellextension,
            drawdeepwell = true,
            deepwelloffset = _P.guardring_deepwelloffset,
            fit = false,
        }
    )

    -- lvs device marker
    geometry.rectanglebltr(ccp, generics.marker("lvs", 2),
        ccp:get_area_anchor("nwellguardring_outerboundary").bl,
        ccp:get_area_anchor("nwellguardring_outerboundary").tr
    )

    -- outer psub guardring
    if _P.drawpsubguardring then
        if _P.quantize_psub_guardring then
            layouthelpers.place_guardring_quantized(
                ccp,
                ccp:get_area_anchor("nwellguardring_outerboundary").bl,
                ccp:get_area_anchor("nwellguardring_outerboundary").tr,
                _P.guardring_xspace, _P.guardring_yspace,
                _P.psubguardring_quantized_gridsize,
                _P.psubguardring_quantized_gridsize,
                "psubguardring_",
                {
                    ringwidth = _P.psubguardring_ringwidth,
                    contype = "p",
                    soiopeninnerextension = _P.guardring_soiopenextension,
                    soiopenouterextension = _P.guardring_soiopenextension,
                    implantinnerextension = _P.guardring_implantextension,
                    implantouterextension = _P.guardring_implantextension,
                    fit = true,
                }
            )
        else
            layouthelpers.place_guardring(
                ccp,
                ccp:get_area_anchor("nwellguardring_outerboundary").bl,
                ccp:get_area_anchor("nwellguardring_outerboundary").tr,
                _P.guardring_xspace, _P.guardring_yspace,
                "psubguardring_",
                {
                    ringwidth = _P.psubguardring_ringwidth,
                    contype = "p",
                    soiopeninnerextension = _P.guardring_soiopenextension,
                    soiopenouterextension = _P.guardring_soiopenextension,
                    implantinnerextension = _P.guardring_implantextension,
                    implantouterextension = _P.guardring_implantextension,
                    fit = false,
                }
            )
        end
        geometry.unequal_ring_pts(ccp, generics.implant("n"),
            ccp:get_area_anchor("psubguardring_innerimplant").bl,
            ccp:get_area_anchor("psubguardring_innerimplant").tr,
            ccp:get_area_anchor("nwellguardring_outerimplant").bl,
            ccp:get_area_anchor("nwellguardring_outerimplant").tr
        )
        geometry.unequal_ring_pts(ccp, generics.feol("soiopen"),
            ccp:get_area_anchor("psubguardring_innerimplant").bl,
            ccp:get_area_anchor("psubguardring_innerimplant").tr,
            ccp:get_area_anchor("nwellguardring_outerimplant").bl,
            ccp:get_area_anchor("nwellguardring_outerimplant").tr
        )
    end

    -- alignment box without psubguardring
    if not _P.drawpsubguardring then
        ccp:clear_alignment_box()
        ccp:inherit_alignment_box(uppernwelluardring)
        ccp:inherit_alignment_box(lowernwelluardring)
    end

    -- connect guardrings
    if _P.drawpsubguardring and _P.connectguardrings then
        geometry.rectanglebltr(ccp, generics.metal(1),
            point.create(
                ccp:get_area_anchor("psubguardring_innerboundary").l,
                (ccp:get_area_anchor("pwellguardring_outerboundary").b + ccp:get_area_anchor("pwellguardring_outerboundary").t) / 2 - _P.guardring_interconnwidth / 2
            ),
            point.create(
                ccp:get_area_anchor("pwellguardring_outerboundary").l,
                (ccp:get_area_anchor("pwellguardring_outerboundary").b + ccp:get_area_anchor("pwellguardring_outerboundary").t) / 2 + _P.guardring_interconnwidth / 2
            )
        )
        geometry.rectanglebltr(ccp, generics.metal(1),
            point.create(
                ccp:get_area_anchor("pwellguardring_outerboundary").r,
                (ccp:get_area_anchor("pwellguardring_outerboundary").b + ccp:get_area_anchor("pwellguardring_outerboundary").t) / 2 - _P.guardring_interconnwidth / 2
            ),
            point.create(
                ccp:get_area_anchor("psubguardring_innerboundary").r,
                (ccp:get_area_anchor("pwellguardring_outerboundary").b + ccp:get_area_anchor("pwellguardring_outerboundary").t) / 2 + _P.guardring_interconnwidth / 2
            )
        )
    end

    -- psub guardring anchor
    if _P.drawpsubguardring then
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
    end

    -- add ports (multiple ports for symmetry for layout extraction)
    if _P.drawpsubguardring then
        ccp:add_port("vss", generics.metalport(1), ccp:get_area_anchor("psubguardring_outerboundary").bl)
        ccp:add_port("vss", generics.metalport(1), ccp:get_area_anchor("psubguardring_outerboundary").br)
        ccp:add_port("vss", generics.metalport(1), ccp:get_area_anchor("psubguardring_outerboundary").tl)
        ccp:add_port("vss", generics.metalport(1), ccp:get_area_anchor("psubguardring_outerboundary").tr)
    end
    ccp:add_port("vss", generics.metalport(_P.vssmetal),
        point.create(
            (ccp:get_area_anchor("vss").l + ccp:get_area_anchor("vss").r) / 2,
            ccp:get_area_anchor("vss").b
        )
    )
    ccp:add_port("vtail", generics.metalport(_P.vtailmetal),
        point.create(
            (ccp:get_area_anchor("ibias").l + ccp:get_area_anchor("ibias").r) / 2,
            ccp:get_area_anchor("ibias").t
        )
    )
    ccp:add_port("vleft", generics.metalport(_P.outputmetal),
        point.create(
            ccp:get_area_anchor("leftoutput").l,
            (ccp:get_area_anchor("leftoutput").b + ccp:get_area_anchor("leftoutput").t) / 2
        )
    )
    ccp:add_port("vright", generics.metalport(_P.outputmetal),
        point.create(
            ccp:get_area_anchor("rightoutput").r,
            (ccp:get_area_anchor("rightoutput").b + ccp:get_area_anchor("rightoutput").t) / 2
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

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
    local nfets = pcell.create_layout("analog/cross_coupled_pair", "_ccp", {
        channeltype = "nmos",
        gatestrappos = "top",
        fingersperside = _P.fingersperside,
        fingerwidth = _P.nmosfingerwidth,
        middledummyfingers = _P.middledummyfingers,
        outerdummyfingers = _P.outerdummyfingers,
        gatelength = _P.gatelength,
        gatespace = _P.gatespace,
        oxidetype = _P.oxidetype,
        mosfetmarker = _P.mosfetmarker,
        vthtype = _P.nvthtype,
        activedummywidth = _P.activedummywidth,
        activedummyspace = _P.activedummyspace,
        outputoffset = _P.outputoffset,
        gatestrapwidth = _P.gatestrapwidth,
        gatestrapspace = _P.gatestrapspace,
        drainstrapspace = _P.drainstrapspace,
        powerwidth = _P.powerwidth,
        powerspace = _P.powerspace,
        gateext = _P.gateext,
        sdwidth = _P.sdwidth,
        crossingoffset = _P.crossingoffset,
        drawpsubguardring = _P.drawpsubguardring,
        inlinedrainstrap = _P.inlinedrainstrap,
        topviawidth = _P.topviawidth,
        crossingmetal = _P.crossingmetal,
        drainmetal = _P.drainmetal,
        fetpowermetal = _P.fetpowermetal,
        guardring_width = _P.guardring_width,
        guardring_xspace = _P.guardring_xspace,
        guardring_yspace = _P.guardring_yspace,
        guardring_xspacetomosfet = _P.guardring_xspacetomosfet,
        guardring_yspacetomosfet = _P.guardring_yspacetomosfet,
        guardring_wellextension = _P.guardring_wellextension,
        guardring_implantextension = _P.guardring_implantextension,
        guardring_soiopenextension = _P.guardring_soiopenextension,
    })

    local pfets = pcell.create_layout("analog/cross_coupled_pair", "_ccp", {
        channeltype = "pmos",
        gatestrappos = "bottom",
        fingersperside = _P.fingersperside,
        fingerwidth = _P.pmosfingerwidth,
        middledummyfingers = _P.middledummyfingers,
        outerdummyfingers = _P.outerdummyfingers,
        gatelength = _P.gatelength,
        gatespace = _P.gatespace,
        oxidetype = _P.oxidetype,
        mosfetmarker = _P.mosfetmarker,
        vthtype = _P.pvthtype,
        activedummywidth = _P.activedummywidth,
        activedummyspace = _P.activedummyspace,
        outputoffset = _P.outputoffset,
        gatestrapwidth = _P.gatestrapwidth,
        gatestrapspace = _P.gatestrapspace,
        drainstrapspace = _P.drainstrapspace,
        powerwidth = _P.powerwidth,
        powerspace = _P.powerspace,
        gateext = _P.gateext,
        sdwidth = _P.sdwidth,
        crossingoffset = _P.crossingoffset,
        drawpsubguardring = _P.drawpsubguardring,
        inlinedrainstrap = _P.inlinedrainstrap,
        topviawidth = _P.topviawidth,
        crossingmetal = _P.crossingmetal,
        drainmetal = _P.drainmetal,
        fetpowermetal = _P.fetpowermetal,
        guardring_width = _P.guardring_width,
        guardring_xspace = _P.guardring_xspace,
        guardring_yspace = _P.guardring_yspace,
        guardring_xspacetomosfet = _P.guardring_xspacetomosfet,
        guardring_yspacetomosfet = _P.guardring_yspacetomosfet,
        guardring_wellextension = _P.guardring_wellextension,
        guardring_implantextension = _P.guardring_implantextension,
        guardring_soiopenextension = _P.guardring_soiopenextension,
    })

    ccp:merge_into(nfets)
    pfets:abut_area_anchor_top("bottomactivedummy", nfets, "topactivedummy")
    pfets:translate_y(2 * _P.guardring_yspacetomosfet + _P.guardring_width + _P.activedummywidth)
    ccp:merge_into(pfets)

    -- copy active anchors for guardring alignment
    ccp:inherit_area_anchor_as(pfets, "active", "pfetactive")
    ccp:inherit_area_anchor_as(pfets, "active", "nfetactive")
    ccp:inherit_area_anchor_as(pfets, "topactivedummy", "pfettopactivedummy")
    ccp:inherit_area_anchor_as(pfets, "bottomactivedummy", "pfetbottomactivedummy")
    ccp:inherit_area_anchor_as(nfets, "topactivedummy", "nfettopactivedummy")
    ccp:inherit_area_anchor_as(nfets, "bottomactivedummy", "nfetbottomactivedummy")
    ccp:inherit_area_anchor_as(pfets, "leftouterdummyactive", "leftouterpfetdummyactive")
    ccp:inherit_area_anchor_as(pfets, "rightouterdummyactive", "rightouterpfetdummyactive")
    ccp:inherit_area_anchor_as(nfets, "leftouterdummyactive", "leftouternfetdummyactive")
    ccp:inherit_area_anchor_as(nfets, "rightouterdummyactive", "rightouternfetdummyactive")

    -- output connection
    ccp:add_area_anchor_bltr("leftoutput",
        point.create(
            nfets:get_area_anchor("leftdrainstrap").l,
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
            nfets:get_area_anchor("rightdrainstrap").r,
            (nfets:get_area_anchor("rightdrainstrap").b + pfets:get_area_anchor("rightdrainstrap").t) / 2 + _P.topviawidth / 2
        )
    )
    geometry.viabltr(ccp, _P.drainmetal, 8,
        ccp:get_area_anchor("leftoutput").bl,
        ccp:get_area_anchor("leftoutput").tr
    )
    geometry.rectanglebltr(ccp, generics.metal(_P.drainmetal),
        ccp:get_area_anchor("leftoutput").bl,
        ccp:get_area_anchor("leftoutput").tr:translate_x(_P.outputoffset)
    )
    geometry.viabltr(ccp, _P.drainmetal, 8,
        ccp:get_area_anchor("rightoutput").bl,
        ccp:get_area_anchor("rightoutput").tr
    )
    geometry.rectanglebltr(ccp, generics.metal(_P.drainmetal),
        ccp:get_area_anchor("rightoutput").bl:translate_x(-_P.outputoffset),
        ccp:get_area_anchor("rightoutput").tr
    )

    -- extra drain metal and vias
    geometry.rectanglebltr(ccp, generics.metal(_P.crossingmetal - 1),
        nfets:get_area_anchor("leftdrainstrap").bl,
        nfets:get_area_anchor("leftdrainstrap").tr
    )
    geometry.rectanglebltr(ccp, generics.metal(_P.crossingmetal - 1),
        pfets:get_area_anchor("leftdrainstrap").bl,
        pfets:get_area_anchor("leftdrainstrap").tr
    )
    geometry.rectanglebltr(ccp, generics.metal(_P.crossingmetal),
        nfets:get_area_anchor("leftdrainstrap").bl,
        nfets:get_area_anchor("leftdrainstrap").tr
    )
    geometry.rectanglebltr(ccp, generics.metal(_P.crossingmetal),
        pfets:get_area_anchor("leftdrainstrap").bl,
        pfets:get_area_anchor("leftdrainstrap").tr
    )
    geometry.viabltr(ccp, _P.crossingmetal - 1, _P.drainmetal,
        nfets:get_area_anchor("leftdrainstrap").bl,
        nfets:get_area_anchor("leftdrainstrap").tr
    )
    geometry.viabltr(ccp, _P.crossingmetal - 1, _P.drainmetal,
        pfets:get_area_anchor("leftdrainstrap").bl,
        pfets:get_area_anchor("leftdrainstrap").tr
    )
    geometry.rectanglebltr(ccp, generics.metal(_P.crossingmetal - 1),
        nfets:get_area_anchor("rightdrainstrap").bl,
        nfets:get_area_anchor("rightdrainstrap").tr
    )
    geometry.rectanglebltr(ccp, generics.metal(_P.crossingmetal - 1),
        pfets:get_area_anchor("rightdrainstrap").bl,
        pfets:get_area_anchor("rightdrainstrap").tr
    )
    geometry.rectanglebltr(ccp, generics.metal(_P.crossingmetal),
        nfets:get_area_anchor("rightdrainstrap").bl,
        nfets:get_area_anchor("rightdrainstrap").tr
    )
    geometry.rectanglebltr(ccp, generics.metal(_P.crossingmetal),
        pfets:get_area_anchor("rightdrainstrap").bl,
        pfets:get_area_anchor("rightdrainstrap").tr
    )
    geometry.viabltr(ccp, _P.crossingmetal - 1, _P.drainmetal,
        nfets:get_area_anchor("rightdrainstrap").bl,
        nfets:get_area_anchor("rightdrainstrap").tr
    )
    geometry.viabltr(ccp, _P.crossingmetal - 1, _P.drainmetal,
        pfets:get_area_anchor("rightdrainstrap").bl,
        pfets:get_area_anchor("rightdrainstrap").tr
    )

    ccp:inherit_area_anchor_as(pfets, "common", "ibiasin")
    ccp:inherit_area_anchor_as(nfets, "common", "vssin")

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
            ccp:get_area_anchor("leftouternfetdummyactive").l,
            ccp:get_area_anchor("pfetbottomactivedummy").b
        ),
        point.create(
            ccp:get_area_anchor("rightouternfetdummyactive").r,
            ccp:get_area_anchor("pfettopactivedummy").t
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
    layouthelpers.place_guardring_with_hole(
        ccp,
        point.create(
            ccp:get_area_anchor("pwellguardring_outerboundary").l,
            ccp:get_area_anchor("nfetbottomactivedummy").b
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
            deepwelloffset = 150,
            fit = false,
        }
    )

    -- lvs device marker
    geometry.rectanglebltr(ccp, generics.marker("lvs", 2),
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
                soiopeninnerextension = _P.guardring_soiopenextension,
                soiopenouterextension = _P.guardring_soiopenextension,
                implantinnerextension = _P.guardring_implantextension,
                implantouterextension = _P.guardring_implantextension,
                fit = true,
            }
        )
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
            ccp:get_area_anchor("leftoutput").l,
            (ccp:get_area_anchor("leftoutput").b + ccp:get_area_anchor("leftoutput").t) / 2
        )
    )
    ccp:add_port("vright", generics.metalport(8),
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

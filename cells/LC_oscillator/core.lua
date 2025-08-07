function parameters()
    pcell.add_parameters(
        { "inductor_metal", -1 },
        { "inductor_tracewidth", 0 },
        { "inductor_separation", 0 },
        { "connector_tracewidth", 0 },
        { "connector_separation", 0 },
        { "connector_extension", 0 },
        { "place_currentmirror", false },
        { "place_fixed_capacitor", true },
        { "place_CDAC", true },
        { "ccp_gatelength", 0 },
        { "ccp_gatespace", 0 },
        { "ccp_gatestrapwidth", 0 },
        { "ccp_gatestrapspace", 0 },
        { "ccp_gateext", 0 },
        { "ccp_sdwidth", 0 },
        { "ccp_oxidetype", 1 },
        { "ccp_mosfetmarker", 1 },
        { "ccp_pvthtype", 1 },
        { "ccp_nvthtype", 1 },
        { "ccp_activedummywidth", 0 },
        { "ccp_activedummyspace", 0 },
        { "ccp_powerwidth", 0 },
        { "ccp_powerspace", 0 },
        { "ccp_fingersperside", 4 },
        { "ccp_pmosfingerwidth", 0 },
        { "ccp_nmosfingerwidth", 0 },
        { "ccp_middledummyfingers", 2 },
        { "ccp_outerdummyfingers", 2 },
        { "ccp_outputoffset", 0 },
        { "ccp_drainstrapspace", 0 },
        { "ccp_crossingoffset", 0 },
        { "ccp_drawpsubguardring", true },
        { "ccp_biasrouting_xshift", 0 },
        { "currentmirror_output_width", 200 },
        { "currentmirror_outeroutput_metal", 5 },
        { "guardring_width", 0 },
        { "guardring_xspace", 0 },
        { "guardring_yspace", 0 },
        { "guardring_xspacetomosfet", 0 },
        { "guardring_yspacetomosfet", 0 },
        { "guardring_soiopenextension", 0 },
        { "guardring_implantextension", 0 },
        { "guardring_wellextension", 0 },
        { "ccp_inlinedrainstrap", false },
        { "ccp_topviawidth", 0 },
        { "ccp_crossingmetal", 5 },
        { "ccp_drainmetal", 7 },
        { "ccp_vtailshift", 0 },
        { "ccp_vtailwidth", 0 },
        { "ccp_vtailmetal", 5 },
        { "ccp_vtaillinewidth", 0 },
        { "ccp_vtaillinespace", 0 },
        { "ccp_fetpowermetal", 3 },
        { "ccp_vssmetal", 5 },
        { "ccp_vssshift", 0 },
        { "ccp_vsswidth", 0 },
        { "ccp_vsslinewidth", 0 },
        { "ccp_vsslinespace", 0 },
        { "varbank_base_fingerwidth", 1000 },
        { "varbank_base_gatelength", 400 },
        { "varbank_base_dummygatelength", 300 },
        { "varbank_base_sourcedrainspacetogate", 200 },
        { "varbank_base_topplateviawidth", 800 },
        { "varbank_base_topplatewidth", 800 },
        { "varbank_base_connectsourcedraininline", 200 },
        { "varbank_base_sourcedrainmetal", 3 },
        { "varbank_base_channeltype", "nmos" },
        { "varbank_base_oxidetype", 1 },
        { "varbank_base_vthtype", 1 },
        { "varbank_base_flippedwell", false },
        { "varbank_base_bitlinemetal", 4 },
        { "varbank_base_gatestrapwidth", 300 },
        { "varbank_base_gatestrapspace", 300 },
        { "varbank_base_lsbleftrightseparation", 800 },
        { "varbank_base_lsbtopbottomseparation", 800 },
        { "varbank_base_sdwidth", 300 },
        { "varbank_base_sourcedrainstrapwidth", 300 },
        { "varbank_base_sourcedrainstrapspace", 300 },
        { "varbank_numh", 4 },
        { "varbank_numv", 4 },
        { "varbank_additionalctrlmetals", 3 },
        { "varbank_additionalctrllines", 3 },
        { "varbank_innerctrllinewidth", 300 },
        { "varbank_ctrlmetal", 3 },
        { "varbank_ctrlwidth", 300 },
        { "varbank_ctrlxshift", 500 },
        { "fixed_capacitor_firstmetal", 3 },
        { "fixed_capacitor_lastmetal", 5 },
        { "fixed_capacitor_fingers", 8 },
        { "fixed_capacitor_fingerwidth", 100 },
        { "fixed_capacitor_fingerspace", 100 },
        { "fixed_capacitor_fingerheight", 2000 },
        { "fixed_capacitor_fingeroffset", 200 },
        { "fixed_capacitor_railwidth", 200 },
        { "fixed_capacitor_rext", 0 },
        { "fixed_capacitor_viaxsize", 200 },
        { "fixed_capacitor_viaysize", 200 },
        { "finefillmetals", { 1, 2 } },
        { "smallgroundmesh_width", 500 },
        { "smallgroundmesh_mpt_fillwidth", 106 },
        { "smallgroundmesh_mpt_holewidth", 420 },
        { "smallgroundmesh_regular_holewidth", 400 },
        { "boundaryextensions", {} }
    )
end

local function _insert_extra_boundary(excludes, layer, polygon)
    if not excludes[layer] then
        excludes[layer] = {}
    end
    table.insert(excludes[layer], polygon)
end

local _fill_with_structure_mpt = function(cell, layer, totalwidth, width, fillwidth)
    local bl = point.create(-fillwidth / 2, -fillwidth / 2)
    local tr = point.create( fillwidth / 2,  fillwidth / 2)
    geometry.rectanglebltr(cell, layer, bl, tr)
    geometry.ring(cell, layer, point.create(0, 0), totalwidth, totalwidth, width / 2)
    cell:set_alignment_box(
        point.create(-totalwidth / 2, -totalwidth / 2),
        point.create( totalwidth / 2,  totalwidth / 2)
    )
end

local _fill_with_structure = function(cell, layer, totalwidth, width)
    geometry.ring(cell, layer, point.create(0, 0), totalwidth, totalwidth, width / 2)
    cell:set_alignment_box(
        point.create(-totalwidth / 2, -totalwidth / 2),
        point.create( totalwidth / 2,  totalwidth / 2)
    )
end

local _insert_singular_layer_boundary = function(excludes, cell, layer)
    if cell:has_layer_boundary(layer) then
        local boundaries = cell:get_layer_boundary(layer)
        for _, boundary in ipairs(boundaries) do
            table.insert(excludes, boundary)
        end
    else
        table.insert(excludes, cell:get_boundary())
    end
end

function layout(core, _P)
    -- connector
    local connectorref = pcell.create_layout("./connector", "oscillator_connector", {
        metal = _P.inductor_metal,
        inductor_tracewidth = _P.inductor_tracewidth,
        inductor_separation = _P.inductor_separation,
        trace_tracewidth = _P.connector_tracewidth,
        trace_separation = _P.connector_separation,
        extension = _P.connector_extension,
        drawfillexcludes = true,
    })
    local connector = core:add_child(connectorref, "connector")
    connector:abut_bottom_origin()
    for i = 1, technology.resolve_metal(-1) do
        core:add_layer_boundary(generics.metal(i), connector:get_boundary())
    end

    -- current mirror
    local currentmirror
    if _P.place_currentmirror then
        local currentmirrorref = pcell.create_layout_env("./current_mirror", "oscillator_current_mirror", nil, env)
        currentmirror = core:add_child(currentmirrorref, "current_mirror")
        currentmirror:abut_top_origin()
        for i = 1, technology.resolve_metal(-1) do
            core:add_layer_boundary(generics.metal(i), currentmirror:get_boundary())
        end
        core:inherit_anchor(currentmirror, "ibiasinleft")
        core:inherit_anchor(currentmirror, "ibiasinright")
        core:add_anchor("leftbusalign", currentmirror:get_alignment_anchor("outerbl"))
        core:add_anchor("rightbusalign", currentmirror:get_alignment_anchor("outerbr"))
        core:add_anchor("topbusalign", currentmirror:get_area_anchor("boundary").tl)
    end

    -- cross-coupled pair
    local ccpref = pcell.create_layout("./cross_coupled_pair", "oscillator_cross_coupled_pair", {
        gatelength = _P.ccp_gatelength,
        gatespace = _P.ccp_gatespace,
        gatestrapwidth = _P.ccp_gatestrapwidth,
        gatestrapspace = _P.ccp_gatestrapspace,
        gateext = _P.ccp_gateext,
        sdwidth = _P.ccp_sdwidth,
        oxidetype = _P.ccp_oxidetype,
        mosfetmarker = _P.ccp_mosfetmarker,
        pvthtype = _P.ccp_pvthtype,
        nvthtype = _P.ccp_nvthtype,
        activedummywidth = _P.ccp_activedummywidth,
        activedummyspace = _P.ccp_activedummyspace,
        powerwidth = _P.ccp_powerwidth,
        powerspace = _P.ccp_powerspace,
        fingersperside = _P.ccp_fingersperside,
        pmosfingerwidth = _P.ccp_pmosfingerwidth,
        nmosfingerwidth = _P.ccp_nmosfingerwidth,
        middledummyfingers = _P.ccp_middledummyfingers,
        outerdummyfingers = _P.ccp_outerdummyfingers,
        outputoffset = _P.ccp_outputoffset,
        drainstrapspace = _P.ccp_drainstrapspace,
        crossingoffset = _P.ccp_crossingoffset,
        drawpsubguardring = _P.ccp_drawpsubguardring,
        guardring_width = _P.guardring_width,
        guardring_xspace = _P.guardring_xspace,
        guardring_yspace = _P.guardring_yspace,
        guardring_xspacetomosfet = _P.guardring_xspacetomosfet,
        guardring_yspacetomosfet = _P.guardring_yspacetomosfet,
        guardring_soiopenextension = _P.guardring_soiopenextension,
        guardring_implantextension = _P.guardring_implantextension,
        guardring_wellextension = _P.guardring_wellextension,
        inlinedrainstrap = _P.ccp_inlinedrainstrap,
        topviawidth = _P.ccp_topviawidth,
        crossingmetal = _P.ccp_crossingmetal,
        drainmetal = _P.ccp_drainmetal,
        vtailshift = _P.ccp_vtailshift,
        vtailwidth = _P.ccp_vtailwidth,
        vtailmetal = _P.ccp_vtailmetal,
        vtaillinewidth = _P.ccp_vtaillinewidth,
        vtaillinespace = _P.ccp_vtaillinespace,
        fetpowermetal = _P.ccp_fetpowermetal,
        vssmetal = _P.ccp_vssmetal,
        vssshift = _P.ccp_vssshift,
        vsswidth = _P.ccp_vsswidth,
        vsslinewidth = _P.ccp_vsslinewidth,
        vsslinespace = _P.ccp_vsslinespace,
    })
    local ccp = core:add_child(ccpref, "cross_coupled_pair")
    ccp:flipy()
    ccp:align_top_origin()

    -- varactor bank
    local varbankref = pcell.create_layout("./varbank", "oscillator_varbank", {
        -- FIXME: pass to higher cells
        psub_guardring_ringwidth = 500,
        psub_guardring_xspace = 500,
        psub_guardring_yspace = 500,
        boundaryextensions = _P.boundaryextensions,
        base_fingerwidth = _P.varbank_base_fingerwidth,
        base_gatelength = _P.varbank_base_gatelength,
        base_dummygatelength = _P.varbank_base_dummygatelength,
        base_sourcedrainspacetogate = _P.varbank_base_sourcedrainspacetogate,
        base_topplateviawidth = _P.varbank_base_topplateviawidth,
        base_topplatewidth = _P.varbank_base_topplatewidth,
        base_connectsourcedraininline = _P.varbank_base_connectsourcedraininline,
        base_sourcedrainmetal = _P.varbank_base_sourcedrainmetal,
        base_channeltype = _P.varbank_base_channeltype,
        base_oxidetype = _P.varbank_base_oxidetype,
        base_vthtype = _P.varbank_base_vthtype,
        base_flippedwell = _P.varbank_base_flippedwell,
        base_bitlinemetal = _P.varbank_base_bitlinemetal,
        base_gatestrapwidth = _P.varbank_base_gatestrapwidth,
        base_gatestrapspace = _P.varbank_base_gatestrapspace,
        base_lsbleftrightseparation = _P.varbank_base_lsbleftrightseparation,
        base_lsbtopbottomseparation = _P.varbank_base_lsbtopbottomseparation,
        base_sdwidth = _P.varbank_base_sdwidth,
        base_sourcedrainstrapwidth = _P.varbank_base_sourcedrainstrapwidth,
        base_sourcedrainstrapspace = _P.varbank_base_sourcedrainstrapspace,
        numh = _P.varbank_numh,
        numv = _P.varbank_numv,
        additionalctrlmetals = _P.varbank_additionalctrlmetals,
        additionalctrllines = _P.varbank_additionalctrllines,
        innerctrllinewidth = _P.varbank_innerctrllinewidth,
        ctrlmetal = _P.varbank_ctrlmetal,
        ctrlwidth = _P.varbank_ctrlwidth,
        ctrlxshift = _P.varbank_ctrlxshift,
    })
    local varbank = core:add_child(varbankref, "varbank")
    varbank:abut_bottom(ccp)

    -- CDAC
    local cdac
    if _P.place_CDAC then
        local cdacref = pcell.create_layout("./cdac", "cdac", {
            numcells = 127,
            switchfingerwidth = 100,
            gatelength = 20,
            gatespace = 84,
            sdviaextension = 100,
            innerfingers = 1,
            fingerwidth = 50,
            fingerspace = 50,
            fingerlength = 8000,
            firstmetal = 4,
            lastmetal = 7,
            railwidth = 60,
            capspace = 300,
            vsslinewidth = 60,
            vsslinespace = 200,
        })
        cdac = core:add_child(cdacref, "cdac")
        cdac:abut_bottom(varbank)
    end

    -- fixed capacitor
    local fixed_capacitor
    if _P.place_fixed_capacitor then
        local fixed_capacitorref = pcell.create_layout("./fixed_capacitor", "fixed_capacitor", {
            fingers = _P.fixed_capacitor_fingers,
            firstmetal = _P.fixed_capacitor_firstmetal,
            lastmetal = _P.fixed_capacitor_lastmetal,
            fingers = _P.fixed_capacitor_fingers,
            fingerwidth = _P.fixed_capacitor_fingerwidth,
            fingerspace = _P.fixed_capacitor_fingerspace,
            fingerheight = _P.fixed_capacitor_fingerheight,
            fingeroffset = _P.fixed_capacitor_fingeroffset,
            railwidth = _P.fixed_capacitor_railwidth,
            rext = _P.fixed_capacitor_rext,
            viaxsize = _P.fixed_capacitor_viaxsize,
            viaysize = _P.fixed_capacitor_viaysize,
            boundaryextensions = _P.boundaryextensions
        })
        fixed_capacitor = core:add_child(fixed_capacitorref, "fixed_capacitor")
        --fixed_capacitor:abut_bottom(resonator)
    end

    -- FIXME: tail capacitor

    -- create excludes for connector filling
    local extraexcludes = {}

    -- connect cross-coupled pair to currentmirror
    local ccpbiaspts
    if _P.place_currentmirror then
        ccpbiaspts = {
            point.create(
                (currentmirror:get_area_anchor("leftoutput").l + currentmirror:get_area_anchor("leftoutput").r) / 2,
                currentmirror:get_area_anchor("leftoutput").b
            ),
            point.create(
                (currentmirror:get_area_anchor("leftoutput").l + currentmirror:get_area_anchor("leftoutput").r) / 2,
                -_P.currentmirror_output_width / 2
            ),
            point.create(
                ccp:get_area_anchor("ibias").l - _P.ccp_biasrouting_xshift,
                -_P.currentmirror_output_width / 2
            ),
        }
        geometry.path(core,
            generics.metal(_P.currentmirror_outeroutput_metal),
            ccpbiaspts,
            _P.currentmirror_output_width
        )
        geometry.path(core,
            generics.metal(_P.currentmirror_outeroutput_metal),
            util.xmirror(ccpbiaspts),
            _P.currentmirror_output_width
        )
        _insert_extra_boundary(extraexcludes,
            _P.currentmirror_outeroutput_metal,
            geometry.path_points_to_polygon(ccpbiaspts, _P.currentmirror_output_width)
        )
        _insert_extra_boundary(extraexcludes,
            _P.currentmirror_outeroutput_metal,
            geometry.path_points_to_polygon(util.xmirror(ccpbiaspts), _P.currentmirror_output_width)
        )
        core:add_layer_boundary(
            generics.metal(_P.currentmirror_outeroutput_metal),
            geometry.path_points_to_polygon(ccpbiaspts, env.decap.cellsize)
        )
        core:add_layer_boundary(
            generics.metal(_P.currentmirror_outeroutput_metal),
            geometry.path_points_to_polygon(util.xmirror(ccpbiaspts), env.decap.cellsize)
        )
    else -- connect cross-coupled pair to vdd
    end
    local ccpbiaspts2 = {
        point.create(
            ccp:get_area_anchor("ibias").l - _P.ccp_biasrouting_xshift,
            -_P.currentmirror_output_width / 2
        ),
        point.create(
            ccp:get_area_anchor("ibias").l - _P.ccp_biasrouting_xshift,
            (ccp:get_area_anchor("ibias").b + ccp:get_area_anchor("ibias").t) / 2
        ),
        point.create(
            ccp:get_area_anchor("ibias").l,
            (ccp:get_area_anchor("ibias").b + ccp:get_area_anchor("ibias").t) / 2
        ),
    }
    geometry.path(core,
        generics.metal(_P.ccp_vtailmetal),
        ccpbiaspts2,
        _P.currentmirror_output_width
    )
    geometry.path(core,
        generics.metal(_P.ccp_vtailmetal),
        util.xmirror(ccpbiaspts2),
        _P.currentmirror_output_width
    )
    _insert_extra_boundary(extraexcludes,
        _P.ccp_vtailmetal,
        geometry.path_points_to_polygon(ccpbiaspts2, 2 * _P.currentmirror_output_width)
    )
    _insert_extra_boundary(extraexcludes,
        _P.ccp_vtailmetal,
        geometry.path_points_to_polygon(util.xmirror(ccpbiaspts2), 2 * _P.currentmirror_output_width)
    )
    if _P.ccp_vtailmetal ~= _P.currentmirror_outeroutput_metal then
        local vialbl, vialtr = util.make_rectangle(
            point.create(
                ccp:get_area_anchor("ibias").l - _P.ccp_biasrouting_xshift,
                -_P.currentmirror_output_width / 2
            ),
            _P.currentmirror_output_width,
            _P.currentmirror_output_width
        )
        geometry.viabltr(core,
            _P.ccp_vtailmetal,
            _P.currentmirror_outeroutput_metal,
            vialbl, vialtr
        )
        local viarbl, viartr = util.make_rectangle(
            point.create(
                ccp:get_area_anchor("ibias").r + _P.ccp_biasrouting_xshift,
                -_P.currentmirror_output_width / 2
            ),
            _P.currentmirror_output_width,
            _P.currentmirror_output_width
        )
        geometry.viabltr(core,
            _P.ccp_vtailmetal,
            _P.currentmirror_outeroutput_metal,
            viarbl, viartr
        )
        for i = _P.ccp_vtailmetal, _P.currentmirror_outeroutput_metal do
            _insert_extra_boundary(extraexcludes,
                i,
                util.rectangle_to_polygon(
                    vialbl, vialtr,
                    env.boundaryextensions[i].x, env.boundaryextensions[i].x,
                    env.boundaryextensions[i].y, env.boundaryextensions[i].y
                )
            )
            _insert_extra_boundary(extraexcludes,
                i,
                util.rectangle_to_polygon(
                    viarbl, viartr,
                    env.boundaryextensions[i].x, env.boundaryextensions[i].x,
                    env.boundaryextensions[i].y, env.boundaryextensions[i].y
                )
            )
        end
    end

    --[==[
    -- connect cross-coupled pair to vss
    core:add_area_anchor_bltr("vssline",
        point.create(
            -env.oscillator.gridfactor * env.decap.cellsize, 
            0
        ),
        point.create(
            env.oscillator.gridfactor * env.decap.cellsize,
            1200
        )
    )
    geometry.rectanglebltr(core, generics.metal(9),
        core:get_area_anchor("vssline").bl,
        core:get_area_anchor("vssline").tr
    )
    geometry.viabltr(core, env.oscillator.crosscoupledpair.vssmetal, 8,
        ccp:get_area_anchor("vss").bl,
        ccp:get_area_anchor("vss").tr
    )
    geometry.viabltr(core, 8, 9,
        point.create(
            (ccp:get_area_anchor("vss").l + ccp:get_area_anchor("vss").r) / 2 - 1200,
            -1200
        ),
        point.create(
            (ccp:get_area_anchor("vss").l + ccp:get_area_anchor("vss").r) / 2 + 1200,
            1200
        )
    )
    _insert_extra_boundary(extraexcludes,
        env.oscillator.crosscoupledpair.vssmetal,
        util.rectangle_to_polygon(
            ccp:get_area_anchor("vss").bl,
            ccp:get_area_anchor("vss").tr .. point.create(0, -env.oscillator.crosscoupledpair.vsslinewidth),
            0, 0, env.boundaryextensions[3].y, env.boundaryextensions[3].y
        )
    )
    _insert_extra_boundary(extraexcludes,
        env.oscillator.crosscoupledpair.vssmetal,
        util.rectangle_to_polygon(
            point.create(-env.oscillator.gridfactor * env.decap.cellsize, 0 - env.oscillator.crosscoupledpair.vsslinewidth),
            point.create( env.oscillator.gridfactor * env.decap.cellsize, 0),
            0, 0, env.boundaryextensions[3].y, env.boundaryextensions[3].y
        )
    )

    -- place metal below inductor metal for subblock connections
    geometry.viabltr(core, 9, 10,
        point.create(
            connector:get_area_anchor("leftline").l,
            connector:get_area_anchor("leftline").b
        ),
        point.create(
            connector:get_area_anchor("leftline").r,
            ccp:get_area_anchor("leftoutput").t
        )
    )
    geometry.viabltr(core, 9, 10,
        point.create(
            connector:get_area_anchor("rightline").l,
            connector:get_area_anchor("rightline").b
        ),
        point.create(
            connector:get_area_anchor("rightline").r,
            ccp:get_area_anchor("rightoutput").t
        )
    )

    -- connect cross-coupled pair to resonator
    geometry.viabltr(core, 8, 9,
        point.create(
            connector:get_area_anchor("leftline").l,
            ccp:get_area_anchor("leftoutput").t - env.oscillator.connectorviawidth
        ),
        point.create(
            connector:get_area_anchor("leftline").r,
            ccp:get_area_anchor("leftoutput").t
        )
    )
    geometry.viabltr(core, 8, 9,
        point.create(
            connector:get_area_anchor("rightline").l,
            ccp:get_area_anchor("rightoutput").t - env.oscillator.connectorviawidth
        ),
        point.create(
            connector:get_area_anchor("rightline").r,
            ccp:get_area_anchor("rightoutput").t
        )
    )
    geometry.rectanglepoints(core, generics.metal(8),
        connector:get_area_anchor("leftline").br .. ccp:get_area_anchor("leftoutput").bl,
        ccp:get_area_anchor("leftoutput").tl
    )
    geometry.rectanglepoints(core, generics.metal(8),
        ccp:get_area_anchor("rightoutput").br,
        connector:get_area_anchor("rightline").bl .. ccp:get_area_anchor("rightoutput").tl
    )

    -- connect varbank to resonator
    core:add_area_anchor_bltr("leftvarbankvia",
        point.create(
            connector:get_area_anchor("leftline").l,
            (varbank:get_area_anchor("lefttopplate").b + varbank:get_area_anchor("righttopplate").t) / 2 - env.oscillator.connectorviawidth / 2
        ),
        point.create(
            connector:get_area_anchor("leftline").r,
            (varbank:get_area_anchor("lefttopplate").b + varbank:get_area_anchor("righttopplate").t) / 2 + env.oscillator.connectorviawidth / 2
        )
    )
    core:add_area_anchor_bltr("rightvarbankvia",
        point.create(
            connector:get_area_anchor("rightline").l,
            (varbank:get_area_anchor("lefttopplate").b + varbank:get_area_anchor("righttopplate").t) / 2 - env.oscillator.connectorviawidth / 2
        ),
        point.create(
            connector:get_area_anchor("rightline").r,
            (varbank:get_area_anchor("lefttopplate").b + varbank:get_area_anchor("righttopplate").t) / 2 + env.oscillator.connectorviawidth / 2
        )
    )
    geometry.viabltr(core, 8, 9,
        core:get_area_anchor("leftvarbankvia").bl,
        core:get_area_anchor("leftvarbankvia").tr
    )
    geometry.viabltr(core, 8, 9,
        core:get_area_anchor("rightvarbankvia").bl,
        core:get_area_anchor("rightvarbankvia").tr
    )
    geometry.polygon(core, generics.metal(8), {
        point.create(
            varbank:get_area_anchor("lefttopplate").l,
            varbank:get_area_anchor("lefttopplate").b
        ),
        point.create(
            (
                connector:get_area_anchor("leftline").l +
                connector:get_area_anchor("leftline").r
            ) / 2 - env.oscillator.varactorbase.topplatewidth / 2 + 3000,
            varbank:get_area_anchor("lefttopplate").b
        ),
        point.create(
            (
                connector:get_area_anchor("leftline").l +
                connector:get_area_anchor("leftline").r
            ) / 2 - env.oscillator.varactorbase.topplatewidth / 2 + 3000,
            (
                core:get_area_anchor("leftvarbankvia").b +
                core:get_area_anchor("leftvarbankvia").t
            ) / 2 - env.oscillator.varactorbase.topplatewidth / 2
        ),
        point.create(
            (
                connector:get_area_anchor("leftline").l +
                connector:get_area_anchor("leftline").r
            ) / 2 - env.oscillator.varactorbase.topplatewidth / 2,
            (
                core:get_area_anchor("leftvarbankvia").b +
                core:get_area_anchor("leftvarbankvia").t
            ) / 2 - env.oscillator.varactorbase.topplatewidth / 2
        ),
        point.create(
            (
                connector:get_area_anchor("leftline").l +
                connector:get_area_anchor("leftline").r
            ) / 2 - env.oscillator.varactorbase.topplatewidth / 2,
            (
                core:get_area_anchor("leftvarbankvia").b +
                core:get_area_anchor("leftvarbankvia").t
            ) / 2 + env.oscillator.varactorbase.topplatewidth / 2
        ),
        point.create(
            (
                connector:get_area_anchor("leftline").l +
                connector:get_area_anchor("leftline").r
            ) / 2 + env.oscillator.varactorbase.topplatewidth / 2 + 3000,
            (
                core:get_area_anchor("leftvarbankvia").b +
                core:get_area_anchor("leftvarbankvia").t
            ) / 2 + env.oscillator.varactorbase.topplatewidth / 2
        ),
        point.create(
            (
                connector:get_area_anchor("leftline").l +
                connector:get_area_anchor("leftline").r
            ) / 2 + env.oscillator.varactorbase.topplatewidth / 2 + 3000,
            varbank:get_area_anchor("lefttopplate").t
        ),
        point.create(
            varbank:get_area_anchor("lefttopplate").l,
            varbank:get_area_anchor("lefttopplate").t
        ),
    })
    geometry.polygon(core, generics.metal(8), {
        point.create(
            varbank:get_area_anchor("righttopplate").r,
            varbank:get_area_anchor("righttopplate").t
        ),
        point.create(
            (
                connector:get_area_anchor("rightline").l +
                connector:get_area_anchor("rightline").r
            ) / 2 + env.oscillator.varactorbase.topplatewidth / 2 - 3000,
            varbank:get_area_anchor("righttopplate").t
        ),
        point.create(
            (
                connector:get_area_anchor("rightline").l +
                connector:get_area_anchor("rightline").r
            ) / 2 + env.oscillator.varactorbase.topplatewidth / 2 - 3000,
            (
                core:get_area_anchor("rightvarbankvia").b +
                core:get_area_anchor("rightvarbankvia").t
            ) / 2 + env.oscillator.varactorbase.topplatewidth / 2
        ),
        point.create(
            (
                connector:get_area_anchor("rightline").l +
                connector:get_area_anchor("rightline").r
            ) / 2,
            (
                core:get_area_anchor("rightvarbankvia").b +
                core:get_area_anchor("rightvarbankvia").t
            ) / 2 + env.oscillator.varactorbase.topplatewidth / 2
        ),
        point.create(
            (
                connector:get_area_anchor("rightline").l +
                connector:get_area_anchor("rightline").r
            ) / 2,
            (
                core:get_area_anchor("rightvarbankvia").b +
                core:get_area_anchor("rightvarbankvia").t
            ) / 2 - env.oscillator.varactorbase.topplatewidth / 2
        ),
        point.create(
            (
                connector:get_area_anchor("rightline").l +
                connector:get_area_anchor("rightline").r
            ) / 2 - env.oscillator.varactorbase.topplatewidth / 2 - 3000,
            (
                core:get_area_anchor("rightvarbankvia").b +
                core:get_area_anchor("rightvarbankvia").t
            ) / 2 - env.oscillator.varactorbase.topplatewidth / 2
        ),
        point.create(
            (
                connector:get_area_anchor("rightline").l +
                connector:get_area_anchor("rightline").r
            ) / 2 - env.oscillator.varactorbase.topplatewidth / 2 - 3000,
            varbank:get_area_anchor("righttopplate").b
        ),
        point.create(
            varbank:get_area_anchor("righttopplate").r,
            varbank:get_area_anchor("righttopplate").b
        ),
    })

    core:inherit_anchor(varbank, "vctrl")

    -- connect varactor to resonator (vctrl)
    -- FIXME: shielding?
    core:add_anchor("vctrl_left",
        point.create(
            connector:get_area_anchor("leftline").l - env.oscillator.vctrlxshift,
            connector:get_area_anchor("leftline").b + env.decap.cellsize / 2
        )
    )
    core:add_anchor("vctrl_right",
        point.create(
            connector:get_area_anchor("rightline").r + env.oscillator.vctrlxshift,
            connector:get_area_anchor("rightline").b + env.decap.cellsize / 2
        )
    )
    core:add_anchor("vctrl_left_cp_target",
        point.create(
            core:get_anchor("vctrl_left"):getx(),
            core:get_anchor("vctrl"):gety()
        )
    )
    core:add_anchor("vctrl_right_cp_target",
        point.create(
            core:get_anchor("vctrl_right"):getx(),
            core:get_anchor("vctrl"):gety()
        )
    )
    -- add excludes for cp target via
    local cplexcludebl, cplexcludetr = util.make_rectangle(
        core:get_anchor("vctrl_left_cp_target"),
        env.SSPLL.chargepumpfilterconnectionwidth,
        env.SSPLL.chargepumpfilterconnectionwidth
    )
    _insert_extra_boundary(extraexcludes,
        env.SSPLL.chargepumpfilterconnectionmetal,
        util.rectangle_to_polygon(
            cplexcludebl, cplexcludetr,
            env.boundaryextensions[env.SSPLL.chargepumpfilterconnectionmetal].x,
            env.boundaryextensions[env.SSPLL.chargepumpfilterconnectionmetal].x,
            env.boundaryextensions[env.SSPLL.chargepumpfilterconnectionmetal].y,
            env.boundaryextensions[env.SSPLL.chargepumpfilterconnectionmetal].y
        )
    )
    local cprexcludebl, cprexcludetr = util.make_rectangle(
        core:get_anchor("vctrl_right_cp_target"),
        env.SSPLL.chargepumpfilterconnectionwidth,
        env.SSPLL.chargepumpfilterconnectionwidth
    )
    _insert_extra_boundary(extraexcludes,
        env.SSPLL.chargepumpfilterconnectionmetal,
        util.rectangle_to_polygon(
            cprexcludebl, cprexcludetr,
            env.boundaryextensions[env.SSPLL.chargepumpfilterconnectionmetal].x,
            env.boundaryextensions[env.SSPLL.chargepumpfilterconnectionmetal].x,
            env.boundaryextensions[env.SSPLL.chargepumpfilterconnectionmetal].y,
            env.boundaryextensions[env.SSPLL.chargepumpfilterconnectionmetal].y
        )
    )
    -- add excludes for outer ctrl connection
    local cplexcludebl, cplexcludetr = util.make_rectangle(
        core:get_anchor("vctrl_left_cp_target"),
        env.oscillator.varactor.ctrlwidth,
        env.oscillator.varactor.ctrlwidth
    )
    _insert_extra_boundary(extraexcludes,
        env.oscillator.varactor.ctrlmetal,
        util.rectangle_to_polygon(
            cplexcludebl, cplexcludetr,
            env.boundaryextensions[env.oscillator.varactor.ctrlmetal].x,
            env.boundaryextensions[env.oscillator.varactor.ctrlmetal].x,
            env.boundaryextensions[env.oscillator.varactor.ctrlmetal].y,
            env.boundaryextensions[env.oscillator.varactor.ctrlmetal].y
        )
    )
    local cprexcludebl, cprexcludetr = util.make_rectangle(
        core:get_anchor("vctrl_right_cp_target"),
        env.oscillator.varactor.ctrlwidth,
        env.oscillator.varactor.ctrlwidth
    )
    _insert_extra_boundary(extraexcludes,
        env.oscillator.varactor.ctrlmetal,
        util.rectangle_to_polygon(
            cprexcludebl, cprexcludetr,
            env.boundaryextensions[env.oscillator.varactor.ctrlmetal].x,
            env.boundaryextensions[env.oscillator.varactor.ctrlmetal].x,
            env.boundaryextensions[env.oscillator.varactor.ctrlmetal].y,
            env.boundaryextensions[env.oscillator.varactor.ctrlmetal].y
        )
    )
    local ctrlpathpts = {
        core:get_anchor("vctrl"),
        core:get_anchor("vctrl_left_cp_target"),
        core:get_anchor("vctrl_left"):translate_y(env.oscillator.varactor.ctrlwidth / 2),
    }
    geometry.path(core, generics.metal(env.oscillator.varactor.ctrlmetal), ctrlpathpts, env.oscillator.varactor.ctrlwidth)
    geometry.path(core, generics.metal(env.oscillator.varactor.ctrlmetal), util.xmirror(ctrlpathpts), env.oscillator.varactor.ctrlwidth)
    _insert_extra_boundary(extraexcludes,
        env.oscillator.varactor.ctrlmetal,
        geometry.path_points_to_polygon(ctrlpathpts, 2 * env.oscillator.varactor.ctrlwidth)
    )
    _insert_extra_boundary(extraexcludes,
        env.oscillator.varactor.ctrlmetal,
        geometry.path_points_to_polygon(util.xmirror(ctrlpathpts), 2 * env.oscillator.varactor.ctrlwidth)
    )
    for metal = env.oscillator.varactor.ctrlmetal, env.oscillator.outerctrlmetal do
        local lbl, ltr = util.make_rectangle(
            core:get_anchor("vctrl_left"),
            env.oscillator.outerctrlwidth,
            env.oscillator.outerctrlwidth
        )
        _insert_extra_boundary(extraexcludes,
            metal,
            util.rectangle_to_polygon(
                lbl, ltr,
                env.boundaryextensions[metal].x, env.boundaryextensions[metal].x,
                env.boundaryextensions[metal].y, env.boundaryextensions[metal].y
            )
        )
        local rbl, rtr = util.make_rectangle(
            core:get_anchor("vctrl_right"),
            env.oscillator.outerctrlwidth,
            env.oscillator.outerctrlwidth
        )
        _insert_extra_boundary(extraexcludes,
            metal,
            util.rectangle_to_polygon(
                rbl, rtr,
                env.boundaryextensions[metal].x, env.boundaryextensions[metal].x,
                env.boundaryextensions[metal].y, env.boundaryextensions[metal].y
            )
        )
    end

    -- digital bus: frequency calibration for varbank (start of bus because of the filling)
    core:add_anchor("leftfreqbusin",
        point.create(
            -env.oscillator.gridfactor * env.decap.cellsize,
            -env.decap.cellsize / 2
        )
    )
    core:add_anchor("rightfreqbusin",
        point.create(
            env.oscillator.gridfactor * env.decap.cellsize,
            -env.decap.cellsize / 2
        )
    )
    local leftbuspts = {
        varbank:get_anchor("leftbusin"),
        point.create(
            connector:get_area_anchor("leftline").l - env.oscillator.freqbusxshift,
            varbank:get_anchor("leftbusin"):gety()
        ),
        point.create(
            connector:get_area_anchor("leftline").l - env.oscillator.freqbusxshift,
            -env.decap.cellsize / 2
        ),
        core:get_anchor("leftfreqbusin")
    }
    layouthelpers.place_bus(
        core,
        generics.metal(4),
        util.xmirror(leftbuspts),
        env.oscillator.varbank.numbits + 1,
        env.oscillator.buswidth, env.oscillator.busspace
    )
    local leftbustarget = geometry.path_points_to_polygon(
        leftbuspts,
        (env.oscillator.varbank.numbits + 2) * (env.oscillator.buswidth + env.oscillator.busspace)
    )
    _insert_extra_boundary(extraexcludes, 4, util.xmirror(leftbustarget))

    -- digital ports
    local buspitch = env.oscillator.buswidth + env.oscillator.busspace
    if env.oscillator.currentmirror.hascalibation then
        -- FIXME: this is old
        if env.oscillator.placecurrentmirror then
            core:add_bus_port("ibias_cal",
                generics.metalport(4),
                point.create(0, buslabelstarty),
                env.oscillator.currentmirror.numbits - 1, 0,
                0, -- xshift
                buspitch, -- yshift
                800
            )
        end
        buslabelstarty = buslabelstarty + env.oscillator.currentmirror.numbits * buspitch
        core:add_port(
            "vdd",
            generics.metalport(4),
            point.create(0, buslabelstarty),
            500
        )
        buslabelstarty = buslabelstarty + buspitch
    end
    core:add_port("vss",
        generics.metalport(4),
        varbank:get_area_anchor(string.format("bitline_%d", 1)).bl,
        800
    )
    core:add_bus_port("freq",
        generics.metalport(4),
        varbank:get_area_anchor(string.format("bitline_%d", 2)).bl,
        0, env.oscillator.varbank.numbits - 1,
        0, -- xshift
        -buspitch, -- yshift
        800
    )

    for i = 1, env.oscillator.varbank.numbits do
        core:add_anchor(string.format("freq_%d", i),
            point.create(
                core:get_anchor("rightfreqbusin"):getx(),
                core:get_anchor("rightfreqbusin"):gety() + (i - 1 - env.oscillator.varbank.numbits / 2) * (env.oscillator.buswidth + env.oscillator.busspace)
            )
        )
    end
    core:add_anchor("freq_vss",
        point.create(
            core:get_anchor("rightfreqbusin"):getx(),
            core:get_anchor("rightfreqbusin"):gety() + (env.oscillator.varbank.numbits + 1 - 1 - env.oscillator.varbank.numbits / 2) * (env.oscillator.buswidth + env.oscillator.busspace)
        )
    )
    --]==]

    -- fine vssmesh fill
    -- this is not disabled by env.disableallfill since it is
    -- part of the proper electrical functionality:
    -- vss guardrings are conncected through this mesh
    local meshtarget = util.rectangle_to_polygon(
        point.create(
            -20000,
            -20000
            ---env.oscillator.gridfactor * env.decap.cellsize,
            ---env.oscillator.resonator.extension
        ),
        point.create(
            --env.oscillator.gridfactor * env.decap.cellsize,
            20000,
            0
        )
    )
    -- FIXME: remove hard-coded values
    local filllayer = _P.finefillmetals
    for _, layer in ipairs(filllayer) do
        local fillcell = object.create_pseudo()
        if technology.has_multiple_patterning(layer) then
            _fill_with_structure_mpt(
                fillcell,
                generics.metal(layer),
                _P.smallgroundmesh_width,
                _P.smallgroundmesh_width - _P.smallgroundmesh_mpt_holewidth,
                _P.smallgroundmesh_mpt_fillwidth
            )
        else
            _fill_with_structure(fillcell,
                generics.metal(layer),
                _P.smallgroundmesh_width,
                _P.smallgroundmesh_width - _P.smallgroundmesh_regular_holewidth
            )
        end
        local fillexcludes = {}
        _insert_singular_layer_boundary(fillexcludes, ccp, generics.metal(layer))
        _insert_singular_layer_boundary(fillexcludes, varbank, generics.metal(layer))
        placement.place_within_boundary_merge(core, fillcell, meshtarget, fillexcludes)
    end

    --[==[
    -- active core region, used in higher cells for metal filling
    core:add_area_anchor_bltr("activecoreregion",
        point.create(
            -env.oscillator.gridfactor * env.decap.cellsize,
            -env.oscillator.resonator.extension
        ),
        point.create(
            env.oscillator.gridfactor * env.decap.cellsize,
            0
        )
    )

    core:inherit_area_anchor_as(connector, "leftline", "connector_leftline")
    core:inherit_area_anchor_as(connector, "rightline", "connector_rightline")
    core:inherit_area_anchor_as(connector, "leftline", "outp")
    core:inherit_area_anchor_as(connector, "rightline", "outn")

    -- voutp/voutn port
    core:add_port_with_anchor("voutp", generics.metalport(10),
        connector:get_area_anchor("leftline").bl,
        2000
    )
    core:add_port_with_anchor("voutn", generics.metalport(10),
        connector:get_area_anchor("rightline").br,
        2000
    )

    -- vtail port (for debugging)
    if env.oscillator.placecurrentmirror then
        core:add_port("vtail", generics.metalport(_P.ccp_vtailmetal),
            point.create(
                (ccp:get_area_anchor("ibias").l + ccp:get_area_anchor("ibias").r) / 2,
                ccp:get_area_anchor("ibias").b
            ),
            2000
        )
    else
        core:add_port("vtail", generics.metalport(_P.currentmirror_outeroutput_metal),
            point.create(
                ccp:get_area_anchor("ibias").l - _P.ccp_biasrouting_xshift,
                (ccp:get_area_anchor("ibias").b + ccp:get_area_anchor("ibias").t) / 2 + env.oscillator.ccpbiasroutingyshift
            ),
            2000
        )
        core:add_port("vtail", generics.metalport(_P.currentmirror_outeroutput_metal),
            point.create(
                ccp:get_area_anchor("ibias").r + _P.ccp_biasrouting_xshift,
                (ccp:get_area_anchor("ibias").b + ccp:get_area_anchor("ibias").t) / 2 + env.oscillator.ccpbiasroutingyshift
            ),
            2000
        )
    end

    -- vtune port
    core:add_port("vtune", generics.metalport(env.oscillator.varactor.ctrlmetal),
        core:get_anchor("vctrl"),
        200
    )

    -- ibias ports
    if env.oscillator.placecurrentmirror then
        core:add_port_with_anchor("ibiasleft", generics.metalport(8),
            currentmirror:get_anchor("ibiasinleft"),
            2000
        )
        core:add_port_with_anchor("ibiasright", generics.metalport(8),
            currentmirror:get_anchor("ibiasinright"),
            2000
        )
    end

    -- vss
    core:add_port_with_anchor("vss", generics.metalport(9),
        point.create(
            env.oscillator.gridfactor * env.decap.cellsize, 
            1200
        ),
        2000
    )
    core:add_port_with_anchor("vss", generics.metalport(9),
        point.create(
            -env.oscillator.gridfactor * env.decap.cellsize, 
            1200
        ),
        2000
    )
    core:add_port_with_anchor("vss", generics.metalport(1),
        point.create(
            -30000,
            0
        ),
        200
    )
    core:add_port_with_anchor("vss", generics.metalport(1),
        point.create(
            30000,
            0
        ),
        200
    )

    -- vdd (FIXME: remove hard-coded values)
    if env.oscillator.placecurrentmirror then
        core:add_port_with_anchor("vdd", generics.metalport(9),
            point.create(-77300, 14830),
            2000
        )
        core:add_port_with_anchor("vdd", generics.metalport(9),
            point.create(77300, 14830),
            2000
        )
    end

    -- fill connector
    local fillref = object.create("oscillator_fill")
    if not env.disableallfill and env.oscillator.connector.drawmetalfill then
        local shiftsigns = { { 0, 0 }, { 1, 0 }, { 0, 1 }, { 1, 1 } }
        for i, fillmetal in ipairs(env.oscillator.connector.fillmetals) do
            local xshiftamount = (env.oscillator.connector.fillmetalwidth[i] + env.oscillator.connector.fillxspace[i]) / 2
            local yshiftamount = (env.oscillator.connector.fillmetalheight[i] + env.oscillator.connector.fillyspace[i]) / 2
            local shiftentry = shiftsigns[((i - 1) % #shiftsigns) + 1]
            local xshift = shiftentry[1] * xshiftamount
            local yshift = shiftentry[2] * yshiftamount
            local fillarea = {
                point.create(-env.SSPLL.decapopeningnum / 2 * env.decap.cellsize + env.boundaryextensions[fillmetal].x, -env.oscillator.resonator.extension),
                point.create(-env.SSPLL.decapopeningnum / 2 * env.decap.cellsize + env.boundaryextensions[fillmetal].x, util.fix_to_grid_higher(-env.oscillator.resonator.extension, env.decap.cellsize)),
                point.create(-env.oscillator.gridfactor * env.decap.cellsize + env.boundaryextensions[fillmetal].x, util.fix_to_grid_higher(-env.oscillator.resonator.extension, env.decap.cellsize)),
                point.create(-env.oscillator.gridfactor * env.decap.cellsize + env.boundaryextensions[fillmetal].x, 0),
                point.create( env.oscillator.gridfactor * env.decap.cellsize - env.boundaryextensions[fillmetal].x, 0),
                point.create( env.oscillator.gridfactor * env.decap.cellsize - env.boundaryextensions[fillmetal].x, util.fix_to_grid_higher(-env.oscillator.resonator.extension, env.decap.cellsize)),
                point.create( env.SSPLL.decapopeningnum / 2 * env.decap.cellsize - env.boundaryextensions[fillmetal].x, util.fix_to_grid_higher(-env.oscillator.resonator.extension, env.decap.cellsize)),
                point.create( env.SSPLL.decapopeningnum / 2 * env.decap.cellsize - env.boundaryextensions[fillmetal].x, -env.oscillator.resonator.extension),
            }
            local fillfunc = env.oscillator.connector.fillasdrawing and generics.metal or generics.metalfill
            local mptfillfunc = env.oscillator.connector.fillasdrawing and generics.mptmetal or generics.mptmetalfill
            local fillexcludes = {}
            if env.oscillator.resonator.placefixedcapacitor then
                env.functions.insert_singular_layer_boundary(fillexcludes, fixed_capacitor, generics.metal(fillmetal))
            end
            env.functions.insert_singular_layer_boundary(fillexcludes, ccp, generics.metal(fillmetal))
            env.functions.insert_singular_layer_boundary(fillexcludes, varbank, generics.metal(fillmetal))
            -- exclude for tail current routing
            if env.oscillator.placecurrentmirror then
                env.functions.insert_singular_layer_boundary(fillexcludes, currentmirror, generics.metal(fillmetal))
                if fillmetal == _P.currentmirror_outeroutput_metal then
                    table.insert(fillexcludes, geometry.path_points_to_polygon(ccpbiaspts, 2 * _P.currentmirror_output_width))
                    table.insert(fillexcludes, geometry.path_points_to_polygon(util.xmirror(ccpbiaspts), 2 * _P.currentmirror_output_width))
                end
            end
            for _, exclude in ipairs(extraexcludes[fillmetal] or {}) do
                table.insert(fillexcludes, exclude)
            end
            if technology.has_multiple_patterning(fillmetal) then
                local num = technology.multiple_patterning_number(fillmetal)
                for i = 1, num do
                    geometry.rectangle_fill_in_boundary(fillref,
                        mptfillfunc(fillmetal, i),
                        env.oscillator.connector.fillmetalwidth[i],
                        env.oscillator.connector.fillmetalheight[i],
                        num * (env.oscillator.connector.fillxspace[i] + env.oscillator.connector.fillmetalwidth[i]),
                        env.oscillator.connector.fillyspace[i] + env.oscillator.connector.fillmetalheight[i],
                        (i - 1) * (env.oscillator.connector.fillxspace[i] + env.oscillator.connector.fillmetalwidth[i]) + xshift, yshift,
                        fillarea,
                        fillexcludes
                    )
                end
            else
                geometry.rectangle_fill_in_boundary(fillref,
                    fillfunc(fillmetal),
                    env.oscillator.connector.fillmetalwidth[i],
                    env.oscillator.connector.fillmetalheight[i],
                    env.oscillator.connector.fillxspace[i] + env.oscillator.connector.fillmetalwidth[i],
                    env.oscillator.connector.fillyspace[i] + env.oscillator.connector.fillmetalheight[i],
                    xshift, yshift,
                    fillarea,
                    fillexcludes
                )
            end
        end
    end
    core:add_child(fillref, "oscillator_fill")

    core:inherit_boundary(connector)
    --]==]
end


function parameters()
    pcell.add_parameters(
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
        ----
        { "resonator_inductor_metal", -1 },
        { "resonator_inductor_tracewidth", 5000 },
        { "resonator_inductor_tracespace", 5000 },
        { "resonator_inductor_turns", 1 },
        { "resonator_inductor_innerdiameter", 80000 },
        { "resonator_inductor_separation", 10000 },
        { "resonator_connector_tracewidth", 5000 },
        { "resonator_connector_traceseparation", 10000 },
        { "resonator_drawfillexcludes", true },
        { "resonator_dlfgroundshield", false },
        { "resonator_dlfgroundshieldwidth", 100 },
        { "resonator_dlfgroundshieldspace", 100 },
        { "resonator_dlfgroundshieldfillouteroffset", 500 },
        { "resonator_dlfgroundshieldvmetal", 1 },
        { "resonator_dlfgroundshieldhmetal", 2 },
        { "resonator_drawmetalfill", true },
        { "resonator_fillmetals", { 1, 2 } },
        { "resonator_fillmetalwidth", 100 },
        { "resonator_fillmetalheight", 100 },
        { "resonator_fillxspace", 100 },
        { "resonator_fillyspace", 100 },
        { "resonator_metalfillouteroffset", 500 },
        { "resonator_drawtopmetalfill", true },
        { "resonator_topmetalfillouteroffset", 2000 },
        { "resonator_topmetalfill", { } },
        { "resonator_usecircularinductor", false },
        { "resonator_circularinductorgrid", 100 },
        { "resonator_fillextension", 8000 },
        { "resonator_fillasdrawing", true },
        { "resonator_breakinductor", false },
        { "resonator_placeresonator", true },
        { "resonator_drawlvsresistor", false },
        { "resonator_fillinneroffset", 2000 },
        { "resonator_fillcenteroffset", 2000 },
        { "resonator_fillinductorcenter", true },
        { "resonator_drawactivefill", true },
        { "resonator_activewidth", 500 },
        { "resonator_activeheight", 500 },
        { "resonator_activexspace", 500 },
        { "resonator_activeyspace", 500 },
        { "resonator_activefillouteroffset", 500 },
        { "resonator_dopingmarkeroffset", 500 },
        { "resonator_markeroffset", 1000 },
        { "resonator_lvslayers", {} },
        { "resonator_connector_extension", 10000 },
        { "resonator_place_fixed_capacitor", true },
        { "resonator_fixed_capacitor_firstmetal", 3 },
        { "resonator_fixed_capacitor_lastmetal", 5 },
        { "resonator_fixed_capacitor_fingers", 8 },
        { "resonator_fixed_capacitor_fingerwidth", 100 },
        { "resonator_fixed_capacitor_fingerspace", 100 },
        { "resonator_fixed_capacitor_fingerheight", 2000 },
        { "resonator_fixed_capacitor_fingeroffset", 200 },
        { "resonator_fixed_capacitor_railwidth", 200 },
        { "resonator_fixed_capacitor_rext", 0 },
        { "resonator_fixed_capacitor_viaxsize", 2500 },
        { "resonator_fixed_capacitor_viaysize", 2500 },
        { "resonator_separation", 0 },
        { "disable_all_fill", false }
    )
end

function layout(oscillator, _P)
    local boundaryextensions = {}
    for metal = 1, technology.resolve_metal(-1) do
        boundaryextensions[metal] = { x = 0, y = 0 }
    end
    -- resonator
    local resonatorref = pcell.create_layout("./resonator", "resonator", {
        turns = _P.resonator_inductor_turns,
        inductormetal = _P.resonator_inductor_metal,
        tracewidth = _P.resonator_inductor_tracewidth,
        tracespace = _P.resonator_inductor_tracespace,
        innerdiameter = _P.resonator_inductor_innerdiameter,
        separation = _P.resonator_inductor_separation,
        drawfillexcludes = _P.resonator_drawfillexcludes,
        dlfgroundshield = _P.resonator_dlfgroundshield,
        dlfgroundshieldwidth = _P.resonator_dlfgroundshieldwidth,
        dlfgroundshieldspace = _P.resonator_dlfgroundshieldspace,
        dlfgroundshieldfillouteroffset = _P.resonator_dlfgroundshieldfillouteroffset,
        dlfgroundshieldvmetal = _P.resonator_dlfgroundshieldvmetal,
        dlfgroundshieldhmetal = _P.resonator_dlfgroundshieldhmetal,
        drawmetalfill = not _P.disable_all_fill and _P.resonator_drawmetalfill,
        fillmetals = _P.resonator_fillmetals,
        fillmetalwidth = _P.resonator_fillmetalwidth,
        fillmetalheight = _P.resonator_fillmetalheight,
        fillxspace = _P.resonator_fillxspace,
        fillyspace = _P.resonator_fillyspace,
        metalfillouteroffset = _P.resonator_metalfillouteroffset,
        drawtopmetalfill = not _P.disable_all_fill and _P.resonator_drawtopmetalfill,
        topmetalfillouteroffset = _P.resonator_topmetalfillouteroffset,
        topmetalfill = {
            { layer = -1, width = 2000, space = 6000 },
            { layer = -2, width = 1800, space = 4200 },
            { layer = -3, width = 1800, space = 4200 },
            { layer = -4, width = 1200, space = 3000 },
        },
        usecircularinductor = _P.resonator_usecircularinductor,
        circularinductorgrid = _P.resonator_circularinductorgrid,
        fillextension = _P.resonator_fillextension,
        fillasdrawing = _P.resonator_fillasdrawing,
        breakinductor = _P.resonator_breakinductor,
        placeresonator = _P.resonator_placeresonator,
        drawlvsresistor = _P.resonator_drawlvsresistor,
        fillinneroffset = _P.resonator_fillinneroffset,
        fillcenteroffset = _P.resonator_fillcenteroffset,
        fillinductorcenter = _P.resonator_fillinductorcenter,
        drawactivefill = not _P.disable_all_fill and _P.resonator_drawactivefill,
        activewidth = _P.resonator_activewidth,
        activeheight = _P.resonator_activeheight,
        activexspace = _P.resonator_activexspace,
        activeyspace = _P.resonator_activeyspace,
        activefillouteroffset = _P.resonator_activefillouteroffset,
        dopingmarkeroffset = _P.resonator_dopingmarkeroffset,
        markeroffset = _P.resonator_markeroffset,
    })
    local resonator = oscillator:add_child(resonatorref, "resonator")
    resonator:align_bottom_origin()

    -- active core
    local coreref = pcell.create_layout("./core", "oscillator_core", {
        ccp_gatelength = _P.ccp_gatelength,
        ccp_gatespace = _P.ccp_gatespace,
        ccp_gatestrapwidth = _P.ccp_gatestrapwidth,
        ccp_gatestrapspace = _P.ccp_gatestrapspace,
        ccp_gateext = _P.ccp_gateext,
        ccp_sdwidth = _P.ccp_sdwidth,
        ccp_oxidetype = _P.ccp_oxidetype,
        ccp_mosfetmarker = _P.ccp_mosfetmarker,
        ccp_pvthtype = _P.ccp_pvthtype,
        ccp_nvthtype = _P.ccp_nvthtype,
        ccp_activedummywidth = _P.ccp_activedummywidth,
        ccp_activedummyspace = _P.ccp_activedummyspace,
        ccp_powerwidth = _P.ccp_powerwidth,
        ccp_powerspace = _P.ccp_powerspace,
        ccp_fingersperside = _P.ccp_fingersperside,
        ccp_pmosfingerwidth = _P.ccp_pmosfingerwidth,
        ccp_nmosfingerwidth = _P.ccp_nmosfingerwidth,
        ccp_middledummyfingers = _P.ccp_middledummyfingers,
        ccp_outerdummyfingers = _P.ccp_outerdummyfingers,
        ccp_outputoffset = _P.ccp_outputoffset,
        ccp_drainstrapspace = _P.ccp_drainstrapspace,
        ccp_crossingoffset = _P.ccp_crossingoffset,
        ccp_drawpsubguardring = _P.ccp_drawpsubguardring,
        guardring_width = _P.guardring_width,
        guardring_xspace = _P.guardring_xspace,
        guardring_yspace = _P.guardring_yspace,
        guardring_xspacetomosfet = _P.guardring_xspacetomosfet,
        guardring_yspacetomosfet = _P.guardring_yspacetomosfet,
        guardring_soiopenextension = _P.guardring_soiopenextension,
        guardring_implantextension = _P.guardring_implantextension,
        guardring_wellextension = _P.guardring_wellextension,
        ccp_inlinedrainstrap = _P.ccp_inlinedrainstrap,
        ccp_topviawidth = _P.ccp_topviawidth,
        ccp_crossingmetal = _P.ccp_crossingmetal,
        ccp_drainmetal = _P.ccp_drainmetal,
        ccp_vtailshift = _P.ccp_vtailshift,
        ccp_vtailwidth = _P.ccp_vtailwidth,
        ccp_vtailmetal = _P.ccp_vtailmetal,
        ccp_vtaillinewidth = _P.ccp_vtaillinewidth,
        ccp_vtaillinespace = _P.ccp_vtaillinespace,
        ccp_fetpowermetal = _P.ccp_fetpowermetal,
        ccp_vssmetal = _P.ccp_vssmetal,
        ccp_vssshift = _P.ccp_vssshift,
        ccp_vsswidth = _P.ccp_vsswidth,
        ccp_vsslinewidth = _P.ccp_vsslinewidth,
        ccp_vsslinespace = _P.ccp_vsslinespace,
        inductor_metal = _P.resonator_inductor_metal,
        inductor_tracewidth = _P.resonator_inductor_tracewidth,
        inductor_separation = _P.resonator_inductor_separation,
        connector_tracewidth = _P.resonator_connector_tracewidth,
        connector_separation = _P.resonator_connector_traceseparation,
        connector_extension = _P.resonator_connector_extension,
        place_fixed_capacitor = _P.resonator_place_fixed_capacitor,
        fixed_capacitor_firstmetal = _P.resonator_fixed_capacitor_firstmetal,
        fixed_capacitor_lastmetal = _P.resonator_fixed_capacitor_lastmetal,
        fixed_capacitor_fingers = _P.resonator_fixed_capacitor_fingers,
        fixed_capacitor_fingerwidth = _P.resonator_fixed_capacitor_fingerwidth,
        fixed_capacitor_fingerspace = _P.resonator_fixed_capacitor_fingerspace,
        fixed_capacitor_fingerheight = _P.resonator_fixed_capacitor_fingerheight,
        fixed_capacitor_fingeroffset = _P.resonator_fixed_capacitor_fingeroffset,
        fixed_capacitor_railwidth = _P.resonator_fixed_capacitor_railwidth,
        fixed_capacitor_rext = _P.resonator_fixed_capacitor_rext,
        fixed_capacitor_viaxsize = _P.resonator_fixed_capacitor_viaxsize,
        fixed_capacitor_viaysize = _P.resonator_fixed_capacitor_viaysize,
        boundaryextensions = boundaryextensions
    })
    local core = oscillator:add_child(coreref, "core")
    --core:align_top_origin()

    --[==[
    geometry.rectanglebltr(oscillator, generics.metal(9),
        point.create(
            resonator:get_area_anchor("boundary").l,
            core:get_area_anchor("vssline").b
        ),
        point.create(
            resonator:get_area_anchor("boundary").r,
            core:get_area_anchor("vssline").t
        )
    )

    -- vctrl lines
    oscillator:add_anchor("vctrl_left",
        point.create(
            -(env.oscillator.meshfillwidth / 2) - env.decap.cellsize,
            util.fix_to_grid_higher(core:get_anchor("vctrl_left"):gety(), env.decap.cellsize) - env.decap.cellsize / 2
        )
    )
    oscillator:add_anchor("vctrl_right",
        point.create(
            (env.oscillator.meshfillwidth / 2) + env.decap.cellsize,
            util.fix_to_grid_higher(core:get_anchor("vctrl_right"):gety(), env.decap.cellsize) - env.decap.cellsize / 2
        )
    )
    local leftvctrlpts = geometry.path_points_to_polygon({
        oscillator:get_anchor("vctrl_left"),
        point.create(
            core:get_anchor("vctrl_left"):getx(),
            oscillator:get_anchor("vctrl_left"):gety()
        ),
        core:get_anchor("vctrl_left"),
    }, env.oscillator.outerctrlwidth)
    local rightvctrlpts = geometry.path_points_to_polygon({
        oscillator:get_anchor("vctrl_right"),
        point.create(
            core:get_anchor("vctrl_right"):getx(),
            oscillator:get_anchor("vctrl_right"):gety()
        ),
        core:get_anchor("vctrl_right"),
    }, env.oscillator.outerctrlwidth)
    for metal = env.oscillator.varactor.ctrlmetal, env.oscillator.outerctrlmetal do
        local lbl, ltr = util.make_rectangle(
            core:get_anchor("vctrl_left"),
            env.oscillator.outerctrlwidth,
            env.oscillator.outerctrlwidth
        )
        local rbl, rtr = util.make_rectangle(core:get_anchor("vctrl_right"),
            env.oscillator.outerctrlwidth,
            env.oscillator.outerctrlwidth
        )
        oscillator:add_layer_boundary(generics.metal(metal),
            util.rectangle_to_polygon(
                lbl, ltr,
                env.boundaryextensions[metal].x, env.boundaryextensions[metal].x,
                env.boundaryextensions[metal].y, env.boundaryextensions[metal].y
            )
        )
        oscillator:add_layer_boundary(generics.metal(metal),
            util.rectangle_to_polygon(
                rbl, rtr,
                env.boundaryextensions[metal].x, env.boundaryextensions[metal].x,
                env.boundaryextensions[metal].y, env.boundaryextensions[metal].y
            )
        )
    end
    if env.oscillator.outerctrlmetal ~= env.oscillator.varactor.ctrlmetal then
        geometry.viabltr(oscillator, env.oscillator.varactor.ctrlmetal, env.oscillator.outerctrlmetal,
            util.make_rectangle(core:get_anchor("vctrl_left"),
                env.oscillator.outerctrlwidth,
                env.oscillator.outerctrlwidth
            )
        )
        geometry.viabltr(oscillator, env.oscillator.varactor.ctrlmetal, env.oscillator.outerctrlmetal,
            util.make_rectangle(core:get_anchor("vctrl_right"),
                env.oscillator.outerctrlwidth,
                env.oscillator.outerctrlwidth
            )
        )
    end
    geometry.polygon(oscillator, generics.metal(env.oscillator.outerctrlmetal), leftvctrlpts)
    geometry.polygon(oscillator, generics.metal(env.oscillator.outerctrlmetal), rightvctrlpts)
    oscillator:add_layer_boundary(generics.metal(env.oscillator.outerctrlmetal), leftvctrlpts)
    oscillator:add_layer_boundary(generics.metal(env.oscillator.outerctrlmetal), rightvctrlpts)
    oscillator:inherit_layer_boundary(core, generics.metal(1))
    oscillator:inherit_layer_boundary(core, generics.metal(2))
    oscillator:inherit_anchor(core, "vctrl_left_cp_target")
    oscillator:inherit_anchor(core, "vctrl_right_cp_target")

    -- ibias routing for current mirror
    local ibiasinoffset = 0
    local ibiastarget = core:get_anchor("ibiasinleft")
    local leftibiaspts = {
        point.create(
            -env.decap.cellsize / 2,
            env.oscillator.ytop + env.oscillator.topextradecaps * env.decap.cellsize - env.decap.cellsize / 2
        ),
        point.create(
            -env.decap.cellsize / 2,
            env.oscillator.ytop + 1 * env.decap.cellsize - env.decap.cellsize / 2
        ),
        point.create(
            core:get_anchor("ibiasinleft"):getx(),
            env.oscillator.ytop + 1 * env.decap.cellsize - env.decap.cellsize / 2
        ),
        point.create(
            core:get_anchor("ibiasinleft"):getx(),
            core:get_anchor("ibiasinleft"):gety() + ibiasinoffset
        ),
    }
    geometry.path(oscillator, generics.metal(8), leftibiaspts, env.ibias.width)
    geometry.path(oscillator, generics.metal(8), util.xmirror(leftibiaspts), env.ibias.width)
    -- ibias ports
    oscillator:add_port_with_anchor("ibiasleft", generics.metalport(8),
        leftibiaspts[1],
        2000
    )
    oscillator:add_port_with_anchor("ibiasright", generics.metalport(8),
        leftibiaspts[1]:xmirror(),
        2000
    )
    -- ibias excludes
    oscillator:add_layer_boundary(generics.metal(8), geometry.path_points_to_polygon(leftibiaspts, env.ibias.width))
    oscillator:add_layer_boundary(generics.metal(8), geometry.path_points_to_polygon(util.xmirror(leftibiaspts), env.ibias.width))

    -- number of bits in calibration bus
    local busbits
    if env.oscillator.currentmirror.hascalibation then
        busbits = env.oscillator.varbank.numbits + 1 + env.oscillator.currentmirror.numbits + 1
    else
        busbits = env.oscillator.varbank.numbits + 1
    end

    -- digital bus: frequency calibration for varbank
    local freqbusshift
    if env.oscillator.currentmirror.hascalibation then
        freqbusshift = -(busbits - 1) * env.oscillator.busspace / 2 - (busbits - 1) * env.oscillator.buswidth / 2 + (env.oscillator.varbank.numbits + 1 - 1) * (env.oscillator.buswidth + env.oscillator.busspace) / 2
    else
        freqbusshift = 0
    end
    local shift = (env.oscillator.meshisodd and 1 or 1.5) * env.decap.cellsize
    leftbuspts = {
        core:get_anchor("leftfreqbusin"),
        point.create(
            core:get_anchor("leftbusalign"):getx() - shift - env.decap.cellsize / 2,
            util.fix_to_grid_higher(core:get_anchor("leftfreqbusin"):gety(), env.decap.cellsize) - env.decap.cellsize / 2
        ),
    }
    layouthelpers.place_bus(
        oscillator,
        generics.metal(4),
        util.xmirror(leftbuspts),
        env.oscillator.varbank.numbits + 1,
        env.oscillator.buswidth, env.oscillator.busspace
    )
    -- add layer boundary for bus routing
    -- fix all points to the grid
    -- this is needed as the bus might not be placed centered to the decaps
    -- (since it is assembled from multiple sub-busses)
    for _, pt in ipairs(leftbuspts) do
        pt:fix(env.decap.cellsize / 2)
    end
    local leftbustarget = geometry.path_points_to_polygon(leftbuspts, env.decap.cellsize)
    oscillator:add_layer_boundary(generics.metal(4), util.xmirror(leftbustarget))

    --[[ FIXME: this is not up to date
    -- digital bus: ibias calibration
    if env.oscillator.currentmirror.hascalibation then
        local ibiasbusshift =
            (busbits - 1) * (env.oscillator.buswidth + env.oscillator.busspace) / 2
            - (env.oscillator.currentmirror.numbits + 1 - 1) * (env.oscillator.buswidth + env.oscillator.busspace) / 2
        if env.oscillator.placecurrentmirror then
            local ibiascaltarget = currentmirror:get_anchor("leftbustarget")
            local ibiasleftbuspts = {
                ibiascaltarget,
                point.create(
                    ibiascaltarget:getx(),
                    util.fix_to_grid_higher(currentmirror:get_area_anchor("leftbitline_1").b, env.decap.cellsize) + env.decap.cellsize / 2 - ibiasbusshift
                ),
                point.create(
                    util.fix_to_grid_abs_higher((currentmirror:get_area_anchor("ibiasleft").l + currentmirror:get_area_anchor("ibiasleft").r) / 2, env.decap.cellsize) - env.decap.cellsize / 2 + ibiasbusshift,
                    util.fix_to_grid_higher(currentmirror:get_area_anchor("ibiasleft").t, env.decap.cellsize) + env.decap.cellsize - env.decap.cellsize / 2 - ibiasbusshift
                ),
                point.create(
                    util.fix_to_grid_abs_higher((currentmirror:get_area_anchor("ibiasleft").l + currentmirror:get_area_anchor("ibiasleft").r) / 2, env.decap.cellsize) - env.decap.cellsize / 2 + ibiasbusshift,
                    env.oscillator.ytop + env.decap.cellsize / 2 - ibiasbusshift
                ),
                point.create(
                    0,
                    env.oscillator.ytop + env.decap.cellsize / 2 - ibiasbusshift
                ),
            }
            layouthelpers.place_bus(
                core,
                generics.metal(4),
                ibiasleftbuspts,
                env.oscillator.currentmirror.numbits + 1,
                env.oscillator.buswidth, env.oscillator.busspace
            )
            layouthelpers.place_bus(
                core,
                generics.metal(4),
                util.xmirror(ibiasleftbuspts),
                env.oscillator.currentmirror.numbits + 1,
                env.oscillator.buswidth, env.oscillator.busspace
            )
        end
    end
    --]]

    -- full decap placement
    local filltargetbl = point.create(
        -env.oscillator.meshfillwidth / 2 - env.decap.cellsize,
        -util.fix_to_grid_abs_lower(env.oscillator.resonator.extension, env.decap.cellsize)
    )
    local filltargettr = point.create(
        env.oscillator.meshfillwidth / 2 + env.decap.cellsize,
        env.oscillator.resonator.outerdiameter + 2 * env.oscillator.resonator.fillextension + env.oscillator.topextradecaps * env.decap.cellsize
    )
    if not env.disableallfill then
        local excludes = {}
        local filltarget = util.rectangle_to_polygon(filltargetbl, filltargettr)
        env.functions.insert_full_blocker(excludes, resonator:get_boundary())
        for i = 1, 8 do
            env.functions.insert_layer_exclude_optional(excludes, core, generics.metal(i))
            env.functions.insert_layer_exclude_optional(excludes, oscillator, generics.metal(i))
        end
        env.functions.insert_exclude(excludes, leftvctrlpts, { generics.viacut(8, 9) })
        env.functions.insert_exclude(excludes, rightvctrlpts, { generics.viacut(8, 9) })
        placement.place_within_layer_boundaries(
            oscillator,
            env.cell_lookup_tables.decap_oscillator,
            "decap",
            filltarget,
            env.decap.cellsize, env.decap.cellsize, -- cell pitch
            excludes
        )
    end
    oscillator:set_alignment_box(filltargetbl, filltargettr)

    -- top metal powergrid
    if not env.disableallfill then
        local pgexcludes = {}
        table.insert(pgexcludes, resonator:get_boundary())
        table.insert(pgexcludes, core:get_boundary())
        local startpt = point.create(
            -env.oscillator.meshfillwidth / 2 - env.decap.cellsize / 2,
            -util.fix_to_grid_abs_lower(env.oscillator.resonator.extension, env.decap.cellsize) + env.decap.cellsize / 2 + env.decap.cellsize
        )
        local pggrid = placement.calculate_grid(
            startpt,
            point.create(
                env.oscillator.meshfillwidth / 2 + env.decap.cellsize / 2,
                env.oscillator.resonator.outerdiameter + 2 * env.oscillator.resonator.fillextension + env.oscillator.topextradecaps * env.decap.cellsize - env.decap.cellsize / 2
            ),
            env.decap.cellsize,
            env.decap.cellsize,
            pgexcludes
        )
        placement.place_boundary_grid(
            oscillator,
            env.boundary_grids.powergrid,
            startpt,
            pggrid,
            env.decap.cellsize,
            env.decap.cellsize,
            "powergrid"
        )
        -- extend metal 10 lines:
        placement.place_within_boundary(
            oscillator,
            env.object_handles.vssconnectorcell_vertical,
            "vssconnectorcell",
            util.rectangle_to_polygon(
                point.create(
                    -env.oscillator.meshfillwidth / 2 - env.decap.cellsize,
                    -util.fix_to_grid_abs_lower(env.oscillator.resonator.extension, env.decap.cellsize)
                ),
                point.create(
                    env.oscillator.meshfillwidth / 2 + env.decap.cellsize,
                    -util.fix_to_grid_abs_lower(env.oscillator.resonator.extension, env.decap.cellsize) + env.decap.cellsize
                )
            ),
            {
                util.rectangle_to_polygon(
                    point.create(
                        resonator:get_area_anchor("boundary").l,
                        core:get_area_anchor("activecoreregion").b
                    ),
                    point.create(
                        resonator:get_area_anchor("boundary").r,
                        core:get_area_anchor("activecoreregion").t
                    )
                )
            }
        )
    end

    -- place topmetal exclude
    geometry.rectanglebltr(oscillator, generics.metalexclude(-1),
        oscillator:get_alignment_anchor("outerbl"),
        oscillator:get_alignment_anchor("outertr")
    )

    -- additional layer boundaries
    for metal = 8, 10 do
        oscillator:add_layer_boundary(generics.metal(metal),
            util.rectangle_to_polygon(
                point.create(
                    core:get_area_anchor("connector_leftline").l - 2 * env.boundaryextensions[metal].x,
                    -util.fix_to_grid_abs_higher(env.oscillator.resonator.extension, env.decap.cellsize)
                ),
                point.create(
                    core:get_area_anchor("connector_rightline").r + 2 * env.boundaryextensions[metal].x,
                    0
                )
            )
        )
    end

    -- ports
    -- digital ports
    local buslabelstarty = env.oscillator.ytop + env.decap.cellsize / 2 - (busbits - 1) * (env.oscillator.busspace + env.oscillator.buswidth) / 2
    oscillator:add_anchor("buslabelstart", point.create(0, buslabelstarty))
    local buspitch = env.oscillator.buswidth + env.oscillator.busspace
    if env.oscillator.currentmirror.hascalibation then
        if env.oscillator.placecurrentmirror then
            oscillator:add_bus_port("ibias_cal",
                generics.metalport(4),
                point.create(0, buslabelstarty),
                env.oscillator.currentmirror.numbits - 1, 0,
                0, -- xshift
                buspitch, -- yshift
                800
            )
        end
        buslabelstarty = buslabelstarty + env.oscillator.currentmirror.numbits * buspitch
    end
    if env.oscillator.currentmirror.hascalibation then
        oscillator:add_port(
            "vdd",
            generics.metalport(4),
            point.create(0, buslabelstarty),
            500
        )
        buslabelstarty = buslabelstarty + buspitch
    end
    buslabelstarty = -12320
    oscillator:add_port("vss",
        generics.metalport(4),
        point.create(0, buslabelstarty),
        800
    )
    buslabelstarty = buslabelstarty - buspitch
    oscillator:add_bus_port("freq",
        generics.metalport(4),
        point.create(0, buslabelstarty),
        0, env.oscillator.varbank.numbits - 1,
        0, -- xshift
        -buspitch, -- yshift
        800
    )

    -- add anchors for frequency calibration connection in higher levels
    for i = 1, env.oscillator.varbank.numbits do
        oscillator:inherit_anchor(core, string.format("freq_%d", i))
    end
    oscillator:inherit_anchor(core, "freq_vss")

    -- active core region, used in higher cells for metal filling
    oscillator:inherit_area_anchor(core, "activecoreregion")

    -- voutp/voutn
    oscillator:add_port_with_anchor("voutp", generics.metalport(10),
        core:get_anchor("voutp"),
        2000
    )
    oscillator:add_port_with_anchor("voutn", generics.metalport(10),
        core:get_anchor("voutn"),
        2000
    )

    -- resonator boundary (for toplevel filling)
    oscillator:inherit_area_anchor_as(resonator, "boundary", "resonator_boundary")

    -- output anchors
    oscillator:inherit_area_anchor(core, "outp")
    oscillator:inherit_area_anchor(core, "outn")

    -- vtune port
    oscillator:add_port("vtune", generics.metalport(env.oscillator.outerctrlmetal),
        oscillator:get_anchor("vctrl_left"),
        2000
    )
    oscillator:add_port("vtune", generics.metalport(env.oscillator.outerctrlmetal),
        oscillator:get_anchor("vctrl_right"),
        2000
    )

    -- vss
    oscillator:add_port_with_anchor("vss", generics.metalport(10),
        oscillator:get_alignment_anchor("outertl"),
        2000
    )
    oscillator:add_port_with_anchor("vss", generics.metalport(10),
        oscillator:get_alignment_anchor("outertr"),
        2000
    )

    -- vdd
    oscillator:add_port_with_anchor("vdd", generics.metalport(11),
        oscillator:get_alignment_anchor("outertl"):translate(env.decap.cellsize / 2, -env.decap.cellsize / 2),
        2000
    )
    oscillator:add_port_with_anchor("vdd", generics.metalport(11),
        oscillator:get_alignment_anchor("outertr"):translate(-env.decap.cellsize / 2, -env.decap.cellsize / 2),
        2000
    )
    --]==]
end


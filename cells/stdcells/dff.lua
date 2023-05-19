--[[
                             |\                            |\
                             | \ Inverter                  | \ Inverter
                        |----|  o----|                |----|  o----|
         |\ Clocked     |    | /     |                |    | /     |       |\
         | \ Inverter   |    |/      |        /       |    |/      |       | \
    D o--|  o-----------*            *-------o -------*            *-------|  o----o Q
         | /            |      /|    |  Transmission  |      /|    |       | /
         |/             |     / |    |      Gate      |     / |    |       |/
                        |----o  |----|                |----o  |----|
                              \ | Clocked                   \ | Clocked
                               \| Inverter                   \| Inverter


          clk                 ~clk          ~clk            clk
--]]

function parameters()
    pcell.add_parameters(
        -- FIXME: add more transistor finger width control
        { "pwidthoffset", 0 },
        { "nwidthoffset", 0 },
        { "clockpolarity", "positive", posvals = set("positive", "negative") },
        { "enable_Q", true },
        { "enable_QN", false },
        { "enable_set", false },
        { "enable_reset", false },
        { "cinvlatch1separationdummies", 1 },
        { "tgatelatch2separationdummies", 1 },
        { "latch2outbufseparationdummies", 1 }
    )
end

function check(_P)
    if _P.enable_set and _P.enable_reset then
        return nil, "sorry, this dff implementation currently does not support simultaneous set and reset pins"
    end
    if _P.cinvlatch1separationdummies < 1 then
        return nil, "there must be at least one finger as separation dummy between the clocked inverter and the first latch"
    end
    if _P.tgatelatch2separationdummies < 1 then
        return nil, "there must be at least one finger as separation dummy between the latches and surrounding sub-circuits"
    end
    if _P.latch2outbufseparationdummies < 1 then
        return nil, "there must be at least one finger as separation dummy between the latches and surrounding sub-circuits"
    end
    return true
end

function layout(dff, _P)
    local bp = pcell.get_parameters("stdcells/base")

    local xpitch = bp.gspace + bp.glength
    local yrpitch = bp.routingwidth + bp.routingspace

    -- define transistor templates
    -- this is used to assign names to gates and source/drain regions
    -- this makes it easy to add gates in-between, for instance for a reset functionality
    -- the p/n-contact is placed *left* of a gate contact
    local scdef = {
        clockbuf = {
            { name = "input1", gate = "lower", pcontact = "power", ncontact = "power", },
            { name = "dummy1", gate = "dummy", pcontact = "inner", ncontact = "inner", },
            { name = "input2", gate = "lower", pcontact = "power", ncontact = "power", },
            { name = "dummy2", gate = "dummy", pcontact = "inner", ncontact = "inner", },
        },
        cinv = {
            { name = "nmos",   gate = _P.clockpolarity == "positive" and "lower" or "center", pcontact = "power", ncontact = "power", },
            { name = "pmos",   gate = _P.clockpolarity == "positive" and "center" or "lower", pcontact = "power", ncontact = "outer", },
            { name = "input",  gate = "upper",  pcontact = "unused",  ncontact = "outer", },
            { name = "dummy1", gate = "dummy",  pcontact = "outer", ncontact = "outer", },
        },
        latch1 = {
            { name = "cinvinput", gate = "lower", pcontact = "outer", ncontact = "outer", },
            { name = "pmos",      gate = _P.clockpolarity == "positive" and "lower" or "center", pcontact = "unused",  ncontact = "outer", },
            { name = "nmos",      gate = _P.clockpolarity == "positive" and "center" or "lower", pcontact = "power", ncontact = "outer", },
            { name = "invinput",  gate = "upper",  pcontact = "power", ncontact = "power", },
        },
        tgate = {
            { name = "nmos",   gate = _P.clockpolarity == "positive" and "center" or "lower", pcontact = "inner", ncontact = "inner", },
            { name = "pmos",   gate = _P.clockpolarity == "positive" and "lower" or "center", pcontact = "inner", ncontact = "outer", },
            { name = "dummy1", gate = "dummy",  pcontact = "outer", ncontact = "outer", },
        },
        latch2 = {
            { name = "cinvinput", gate = "lower",  pcontact = "outer", ncontact = "outer", },
            { name = "pmos",      gate = _P.clockpolarity == "positive" and "center" or "lower", pcontact = "unused",  ncontact = "outer", },
            { name = "nmos",      gate = _P.clockpolarity == "positive" and "lower" or "center", pcontact = "power", ncontact = "outer", },
            { name = "invinput",  gate = "upper",  pcontact = "power", ncontact = "power", },
            { name = "dummy1",    gate = "dummy",  pcontact = "inner", ncontact = "inner", },
        },
        buffer = {
            { name = "input", gate = "center", pcontact = "power", ncontact = "power", },
            { name = "dummy", gate = "dummy",  pcontact = "inner", ncontact = "inner", },
        },
    }

    -- modify subcircuits template (reset, set, etc.)
    for i = 1, _P.cinvlatch1separationdummies - 1 do
        local entry = {
            name = string.format("dummy%d", i + 1),
            gate = "dummy",
            pcontact = "outer",
            ncontact = "outer",
        }
        table.insert(scdef.cinv, entry)
    end
    for i = 1, _P.tgatelatch2separationdummies - 1 do
        local entry = {
            name = string.format("dummy%d", i + 1),
            gate = "dummy",
            pcontact = "outer",
            ncontact = "outer",
        }
        table.insert(scdef.tgate, entry)
    end
    for i = 1, _P.latch2outbufseparationdummies - 1 do
        local entry = {
            name = string.format("dummy%d", i + 1),
            gate = "dummy",
            pcontact = "outer",
            ncontact = "outer",
        }
        table.insert(scdef.latch2, entry)
    end

    -- put subcircuits in the right order
    local scorder = {
        "clockbuf",
        "cinv",
        "latch1",
        "tgate",
        "latch2",
        "buffer",
    }
    local subcircuits = {}
    for _, scname in ipairs(scorder) do
        local entry = {
            name = scname,
            entries = scdef[scname]
        }
        table.insert(subcircuits, entry)
    end

    -- parse subcircuit definition and create gate/drain/source positions for basic/cmos
    local gatecontactpos = {}
    local pcontactpos = {}
    local ncontactpos = {}
    local indexmap = {}
    local index = 1
    for _, subcircuit in ipairs(subcircuits) do
        for _, entry in ipairs(subcircuit.entries) do
            gatecontactpos[index] = entry.gate
            pcontactpos[index] = entry.pcontact
            ncontactpos[index] = entry.ncontact
            indexmap[string.format("%s%s", subcircuit.name, entry.name)] = index
            index = index + 1
        end
    end
    -- add final contact
    table.insert(pcontactpos, "power")
    table.insert(ncontactpos, "power")

    local harness = pcell.create_layout("stdcells/harness", "mosfets", {
        pwidthoffset = _P.pwidthoffset,
        nwidthoffset = _P.nwidthoffset,
        gatecontactpos = gatecontactpos,
        pcontactpos = pcontactpos,
        ncontactpos = ncontactpos,
    })
    dff:exchange(harness)

    -- easy anchor access functions
    local gate = function(identifier)
        if not indexmap[identifier] then
            cellerror(string.format("did not find gate anchor entry '%s'", identifier))
        end
        return dff:get_area_anchor(string.format("G%d", indexmap[identifier]))
    end
    local sourcedrainleft = function(fet, identifier)
        if not indexmap[identifier] then
            cellerror(string.format("did not find source/drain anchor entry '%s'", identifier))
        end
        return dff:get_area_anchor(string.format("%sSD%d", fet, indexmap[identifier]))
    end
    local sourcedrainright = function(fet, identifier)
        if not indexmap[identifier] then
            cellerror(string.format("did not find source/drain anchor entry '%s'", identifier))
        end
        return dff:get_area_anchor(string.format("%sSD%d", fet, indexmap[identifier] + 1))
    end

    -- general base anchors for y-alignment
    local gcenterbase = dff:get_area_anchor("Gcenterbase")
    local glowerbase = dff:get_area_anchor("Glowerbase")
    local gupperbase = dff:get_area_anchor("Gupperbase")

    local spacing = bp.sdwidth / 2 + bp.routingspace

    -- clock buffer input port landing
    geometry.rectanglebltr(dff, generics.metal(1),
        gate("clockbufinput1").bl:translate(-xpitch, 0),
        gate("clockbufinput1").bl:translate( xpitch - spacing, bp.routingwidth)
    )
    -- clock buffer ~clk via
    geometry.viabltr(dff, 1, 2,
        gate("clockbufinput2").bl:translate(-xpitch, 0),
        gate("clockbufinput2").bl:translate( xpitch - spacing, bp.routingwidth)
    )
    -- clock buffer ~clk drain connections
    geometry.path_cshape(dff, generics.metal(1),
        sourcedrainright("p", "clockbufinput1").br:translate(0, bp.sdwidth / 2),
        sourcedrainright("n", "clockbufinput1").tr:translate(0, -bp.sdwidth / 2),
        sourcedrainright("p", "clockbufinput1").br:translate(xpitch / 2, 0),
        bp.sdwidth
    )
    -- clock buffer clk drain connections
    geometry.path_cshape(dff, generics.metal(1),
        sourcedrainright("p", "clockbufinput2").br:translate(0, bp.sdwidth / 2),
        sourcedrainright("n", "clockbufinput2").tr:translate(0, -bp.sdwidth / 2),
        sourcedrainright("p", "clockbufinput2").br:translate(xpitch / 2, 0),
        bp.sdwidth
    )

    -- clk M2 bar
    geometry.viabltr(dff, 1, 2,
        gate("cinvpmos").bl:translate(-1 * xpitch, 0),
        gate("cinvpmos").tl:translate( 2 * xpitch - spacing, 0)
    )
    geometry.rectanglebltr(dff, generics.metal(2),
        (gate("cinvpmos").bl .. gcenterbase.bl):translate_x(-2 * xpitch),
        gate("latch2cinvinput").tr:translate(3 * xpitch + bp.glength / 2, yrpitch)
    )
    -- ~clk M2 bar
    geometry.rectanglebltr(dff, generics.metal(2),
        (gate("clockbufinput2").bl .. glowerbase.bl):translate_x(-xpitch),
        gate("latch2cinvinput").tr:translate_x(3 * xpitch + bp.glength / 2)
    )

    -- cinv clk connection
    geometry.rectanglebltr(dff, generics.metal(1),
        gate("clockbufdummy2").bl .. dff:get_area_anchor("Gcenterbase").bl,
        (gate("cinvdummy1").bl .. dff:get_area_anchor("Gcenterbase").tl):translate_x(-spacing)
    )

    -- cinv ~clk connection
    geometry.viabltr(dff, 1, 2,
        gate("cinvnmos").bl,
        gate("cinvnmos").tl:translate_x( 3 * xpitch - spacing)
    )

    -- D input port landing
    geometry.viabltr(dff, 1, 2,
        gate("clockbufinput1").bl:translate(-xpitch,           2 * (bp.routingwidth + bp.routingspace)),
        gate("clockbufinput1").tl:translate( xpitch - spacing, 2 * (bp.routingwidth + bp.routingspace))
    )
    -- cinv D connection
    geometry.viabltr(dff, 1, 2,
        gate("cinvinput").bl:translate_x(-2 * xpitch),
        gate("cinvinput").tl:translate_x( 1 * xpitch - spacing)
    )
    geometry.rectanglebltr(dff, generics.metal(2),
        gate("clockbufinput1").bl:translate(-xpitch,           2 * (bp.routingwidth + bp.routingspace)),
        gate("cinvinput").tl:translate_x( 1 * xpitch - spacing)
    )

    -- cinv short nmos
    geometry.rectanglebltr(dff, generics.metal(1),
        sourcedrainleft("n", "cinvpmos").br,
        sourcedrainright("n", "cinvpmos").bl:translate_y(bp.sdwidth)
    )

    -- short dummy between cinv and first latch cinv
    geometry.rectanglebltr(dff, generics.metal(1),
        sourcedrainleft("p", "cinvdummy1").tr:translate_y(-bp.sdwidth),
        sourcedrainright("p", string.format("cinvdummy%d", _P.cinvlatch1separationdummies)).tl
    )
    geometry.rectanglebltr(dff, generics.metal(1),
        sourcedrainleft("n", "cinvdummy1").br,
        sourcedrainright("n", string.format("cinvdummy%d", _P.cinvlatch1separationdummies)).bl:translate_y(bp.sdwidth)
    )

    -- short nmos in first latch (set layout)
    -- FIXME: there is a pmos short in latch 1 further down, can this be merged?
    if _P.enable_set then
        geometry.rectanglebltr(dff, generics.metal(1),
            sourcedrainleft("n", "latch1nmos").br,
            sourcedrainright("n", "latch1nmos").bl:translate_y(bp.sdwidth)
        )
    end

    -- connect first latch cinv drains
    geometry.rectanglebltr(dff, generics.metal(1),
        sourcedrainright("n", string.format("cinvdummy%d", math.ceil(_P.cinvlatch1separationdummies / 2))).tl,
        sourcedrainright("p", string.format("cinvdummy%d", math.ceil(_P.cinvlatch1separationdummies / 2))).br
    )

    -- first latch / transmission gate clk bar vias
    geometry.rectanglebltr(dff, generics.metal(1),
        gate("latch1pmos").br,
        gate("tgatepmos").tl
    )
    geometry.viabltr(dff, 1, 2,
        point.combine(
            gate("latch1pmos").bl,
            gate("tgatepmos").bl
        ):translate_x(-xpitch - bp.glength / 2),
        point.combine(
            gate("latch1pmos").tl,
            gate("tgatepmos").tl
        ):translate_x( xpitch + bp.glength / 2)
    )
    if not _P.enable_set and not _P.enable_reset then
        geometry.rectanglebltr(dff, generics.metal(1),
            gate("latch1nmos").br,
            gate("tgatenmos").tl
        )
        geometry.viabltr(dff, 1, 2,
            point.combine(
                gate("latch1nmos").bl,
                gate("tgatenmos").bl
            ):translate_x(-xpitch - bp.glength / 2),
            point.combine(
                gate("latch1nmos").tl,
                gate("tgatenmos").tl
            ):translate_x( xpitch + bp.glength / 2)
        )
    else
        -- FIXME
        --geometry.viabltr(dff, 1, 2,
        --    gate("cinv2EN"):translate(-bp.glength / 2, -bp.routingwidth / 2),
        --    gate("cinv2EN"):translate( bp.glength / 2, bp.routingwidth / 2)
        --)
        --geometry.viabltr(dff, 1, 2,
        --    gate(15 + clkshift):translate(-bp.glength / 2, -bp.routingwidth / 2),
        --    gate(15 + clkshift):translate( bp.glength / 2, bp.routingwidth / 2)
        --)
    end

    -- first latch short nmos or pmos
    -- FIXME: currently only pmos, under which conditions does this change?
    geometry.rectanglebltr(dff, generics.metal(1),
        sourcedrainleft("n", "latch1pmos").br,
        sourcedrainright("n", "latch1pmos").bl:translate_y(bp.sdwidth)
    )

    -- first latch inverter connect drains to gate of first latch cinv
    geometry.path(dff, generics.metal(1),
        geometry.path_points_xy(sourcedrainright("n", "latch1invinput").tr:translate(0, -bp.sdwidth / 2), {
            gate("latch1cinvinput").bl:translate_x(bp.sdwidth / 2)
    }), bp.sdwidth)

    -- first latch cinv drain to inv gate
    geometry.path(dff, generics.metal(1),
        geometry.path_points_xy(gate("latch1invinput").bl:translate_y(bp.sdwidth / 2), {
            -xpitch,
            (bp.routingwidth + bp.routingspace) / (bp.numinnerroutes % 2 == 0 and 2 or 1),
            sourcedrainright("p", "cinvdummy1").bl:translate_x(bp.sdwidth / 2)
    }), bp.sdwidth)

    -- first latch inverter connect drains
    -- (this also connects the drain of the pmos set transistor)
    local sdcorrection = _P.enable_reset and 1 or 0
    geometry.path_cshape(dff, generics.metal(1),
        sourcedrainleft("p", "tgatenmos").br:translate_y( bp.sdwidth / 2),
        sourcedrainleft("n", "tgatenmos").tr:translate_y(-bp.sdwidth / 2),
        gate(string.format("tgatedummy%d", 1)).bl:translate_x(bp.sdwidth / 2),
        bp.sdwidth
    )

    -- short transistors in transmission gate
    geometry.rectanglebltr(dff, generics.metal(1),
        sourcedrainleft("n", "tgatepmos").bl,
        sourcedrainright("n", string.format("tgatedummy%d", _P.tgatelatch2separationdummies)).bl:translate_y(bp.sdwidth)
    )
    if _P.tgatelatch2separationdummies > 2 then
        --geometry.rectanglebltr(dff, generics.metal(3),
        --    sourcedrainright("p", "tgatedummy1").br,
        --    sourcedrainleft("p", string.format("tgatedummy%d", _P.tgatelatch2separationdummies)).bl:translate_y(bp.sdwidth)
        --)
    end

    -- short dummy between cinv and second latch cinv
    geometry.rectanglebltr(dff, generics.metal(1),
        sourcedrainleft("p", "tgatedummy1").tl:translate_y(-bp.sdwidth),
        sourcedrainright("p", string.format("tgatedummy%d", _P.tgatelatch2separationdummies)).tl
    )

    -- short nmos in second latch (set layout)
    if _P.enable_set then
        geometry.rectanglebltr(dff, generics.metal(3),
            sourcedrain("n", "cc", 21 + resetshift):translate(0, -bp.sdwidth / 2),
            sourcedrain("n", "cc", 22 + resetshift):translate(0, bp.sdwidth / 2)
        )
    end

    -- connect second latch cinv / transmission gate drains
    geometry.rectanglebltr(dff, generics.metal(1),
        sourcedrainright("n", string.format("tgatedummy%d", math.ceil(_P.tgatelatch2separationdummies / 2))).tl,
        sourcedrainright("p", string.format("tgatedummy%d", math.ceil(_P.tgatelatch2separationdummies / 2))).br
    )

    -- second latch clk bar vias
    geometry.viabltr(dff, 1, 2,
        gate("latch2cinvinput").bl:translate_x(1 * xpitch - bp.glength / 2),
        gate("latch2cinvinput").tr:translate_x(3 * xpitch + bp.glength / 2)
    )
    geometry.viabltr(dff, 1, 2,
        gate("latch2cinvinput").bl:translate(1 * xpitch - bp.glength / 2, yrpitch),
        gate("latch2cinvinput").tr:translate(3 * xpitch + bp.glength / 2, yrpitch)
    )

    -- second latch short nmos or pmos
    geometry.rectanglebltr(dff, generics.metal(1),
        sourcedrainleft("n", "latch2pmos").br,
        sourcedrainright("n", "latch2pmos").bl:translate_y(bp.sdwidth)
    )

    -- second latch inverter connect drains to gate of second latch cinv
    geometry.path(dff, generics.metal(1),
        geometry.path_points_xy(sourcedrainright("n", "latch2invinput").tr:translate(0, -bp.sdwidth / 2), {
            gate("latch2cinvinput").bl:translate_x(bp.sdwidth / 2)
    }), bp.sdwidth)

    -- second latch cinv drain to inv gate
    geometry.path(dff, generics.metal(1),
        geometry.path_points_xy(gate("latch2invinput").bl:translate_y(bp.sdwidth / 2), {
            -xpitch,
            (bp.routingwidth + bp.routingspace) / (bp.numinnerroutes % 2 == 0 and 2 or 1),
            sourcedrainright("p", string.format("tgatedummy%d", _P.tgatelatch2separationdummies)).bl:translate_x(bp.sdwidth / 2)
    }), bp.sdwidth)

    -- second latch inverter connect drains
    -- (this also connects the drain of the pmos set transistor)
    local sdcorrection = _P.enable_reset and 1 or 0
    geometry.path_cshape(dff, generics.metal(1),
        sourcedrainright("p", "latch2invinput").br:translate_y( bp.sdwidth / 2),
        sourcedrainright("n", "latch2invinput").tr:translate_y(-bp.sdwidth / 2),
        gate("bufferinput").bl:translate_x(-xpitch + bp.sdwidth / 2),
        bp.sdwidth
    )

    -- output inverter connect gate
    geometry.rectanglebltr(dff, generics.metal(1),
        gate("bufferinput").bl:translate_x(-xpitch + bp.sdwidth / 2),
        gate("bufferinput").tl
    )

    -- output Q inverter connect drains
    geometry.path_cshape(dff, generics.metal(1),
        sourcedrainright("p", "bufferinput").br:translate_y(bp.sdwidth / 2),
        sourcedrainright("n", "bufferinput").tr:translate_y(-bp.sdwidth / 2),
        gate("bufferinput").tl:translate(xpitch + bp.sdwidth / 2, 0),
        bp.sdwidth
    )

    -- output QN inverter connect drains and gate
    if _P.enable_QN then
        geometry.rectanglebltr(dff, generics.metal(1),
            gate("outinv2"):translate(-xpitch, -bp.sdwidth / 2),
            gate("outinv2"):translate(bp.glength / 2,  bp.sdwidth / 2)
        )
        geometry.path_cshape(dff, generics.metal(1),
            sourcedrain("p", "bc", 24 + 2 * setshift + 3 * resetshift):translate(0, bp.sdwidth / 2),
            sourcedrain("n", "tc", 24 + 2 * setshift + 3 * resetshift):translate(0, -bp.sdwidth / 2),
            gate("outinv2"):translate(xpitch, 0),
            bp.sdwidth
        )
    end

    -- set bar and M1/M2 vias
    if _P.enable_set then
        geometry.rectanglebltr(dff, generics.metal(2),
            --gate("tgateEN"):translate(0, -bp.routingwidth / 2),
            gate(13):translate(0, -bp.routingwidth / 2),
            gate(22):translate(0, bp.routingwidth / 2)
        )
        geometry.viabltr(dff, 1, 2,
            gate("tgateEN"):translate(-xpitch - bp.glength / 2, -bp.routingwidth / 2),
            gate("tgateEN"):translate( xpitch + bp.glength / 2, bp.routingwidth / 2)
        )
        geometry.viabltr(dff, 1, 2,
            gate(22):translate(-xpitch - bp.glength / 2, -bp.routingwidth / 2),
            gate(22):translate( xpitch + bp.glength / 2, bp.routingwidth / 2)
        )
    end

    -- reset bar and M1/M2 vias
    if _P.enable_reset then
        --geometry.rectanglebltr(dff, generics.metal(2),
        --    gate(12):translate(0, -bp.routingwidth / 2),
        --    gate(21):translate(0, bp.routingwidth / 2)
        --)
        --geometry.viabltr(dff, 1, 2,
        --    gate(12):translate(-xpitch - bp.glength / 2, -bp.routingwidth / 2),
        --    gate(12):translate( xpitch + bp.glength / 2, bp.routingwidth / 2)
        --)
        --geometry.viabltr(dff, 1, 2,
        --    gate(21):translate(-xpitch - bp.glength / 2, -bp.routingwidth / 2),
        --    gate(21):translate( xpitch + bp.glength / 2, bp.routingwidth / 2)
        --)
    end

    -- ports
    dff:add_port("VDD", generics.metalport(1), dff:get_area_anchor("PRp").bl)
    dff:add_port("VSS", generics.metalport(1), dff:get_area_anchor("PRn").bl)
    dff:add_port("CLK", generics.metalport(1), gate("clockbufinput1").bl)
    dff:add_port("D", generics.metalport(1), gate("clockbufinput1").bl:translate_y(2 * (bp.routingwidth + bp.routingspace)))
    if _P.enable_Q then
        dff:add_port("Q", generics.metalport(1), gate("bufferinput").bl:translate_x(xpitch))
    end
    if _P.enable_QN then
        dff:add_port("QN", generics.metalport(1), gate("outinv2"):translate(xpitch, 0))
    end
    if _P.enable_set then
        dff:add_port("SET", generics.metalport(2), point.combine(gate("tgateEN"), gate(22)))
    end
    if _P.enable_reset then
        --dff:add_port("RST", generics.metalport(2), point.combine(gate(12), gate(21)))
    end
end

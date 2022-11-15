--[[
                             |\                            |\
                             | \ Inverter                  | \ Inverter
                        |----|  O----|                |----|  O----|
         |\ Clocked     |    | /     |                |    | /     |       |\
         | \ Inverter   |    |/      |        /       |    |/      |       | \
    D o--|  O-----------*            *-------o -------*            *-------|  O----o Q
         | /            |      /|    |  Transmission  |      /|    |       | /
         |/             |     / |    |      Gate      |     / |    |       |/
                        |----O  |----|                |----O  |----|
                              \ | Clocked                   \ | Clocked
                               \| Inverter                   \| Inverter


          clk                 ~clk          ~clk            clk
--]]

function parameters()
    pcell.reference_cell("stdcells/base")
    pcell.reference_cell("stdcells/harness")
    pcell.reference_cell("stdcells/not_gate")
    pcell.add_parameters(
        -- FIXME: add more transistor width control
        { "pwidth", 2 * tech.get_dimension("Minimum Gate Width") },
        { "nwidth", 2 * tech.get_dimension("Minimum Gate Width") },
        { "clockpolarity", "positive", posvals = set("positive", "negative") },
        { "enable_Q", true },
        { "enable_QN", false },
        { "enable_set", false },
        { "enable_reset", false },
        { "latchspacerdummy", 1 }
    )
    pcell.check_expression("not (enable_set and enable_reset)", "sorry, this dff implementation currently does not support simultaneous set and reset pins")
end

function layout(dff, _P)
    local bp = pcell.get_parameters("stdcells/base")

    local xpitch = bp.gspace + bp.glength
    local yrpitch = bp.routingwidth + bp.routingspace

    local gatepos = "center"
    if _P.enable_set or _P.enable_reset then
        gatepos = "upper"
    end
    local gatecontactpos = {
        "lower", "dummy", "lower", "dummy", -- clock buffer
        "lower", "center", "upper",         -- cinv
        "dummy",
        "lower", "lower", gatepos,          -- first latch cinv
        "upper",                            -- first latch inv
        gatepos, "lower",                   -- transmission gate
        "dummy",
        "lower", gatepos, "lower",          -- second latch cinv
        "upper",                            -- second latch inv
        "dummy",
        "center",                           -- output inverter
    }
    local clkshift = _P.clockpolarity == "positive" and 0 or 1
    if _P.clockpolarity == "negative" then
        gatecontactpos[5] = "center"
        gatecontactpos[6] = "lower"
        gatecontactpos[10] = gatepos
        gatecontactpos[11] = "lower"
        gatecontactpos[13] = "lower"
        gatecontactpos[14] = gatepos
        gatecontactpos[17] = "lower"
        gatecontactpos[18] = gatepos
    end
    local pcontactpos = {
        "power", "inner", "power", "inner",      -- clock buffer
        "power", "power", nil, "outer",          -- cinv 
        "outer", nil, "power", "power", "inner", -- first latch
        "inner", "outer",                        -- transmission gate
        "outer", nil, "power", "power", "inner", -- first latch
        "power", "inner",                        -- output inverter
    }
    local ncontactpos = {
        "power", "inner", "power", "inner",          -- clock buffer
        "power", "outer", "outer", "outer",          -- cinv 
        "outer", "outer", "outer", "power", "inner", -- first latch
        "outer", "outer",                            -- transmission gate
        "outer", "outer", "outer", "power", "inner", -- first latch
        "power", "inner",                            -- output inverter
    }

    if _P.enable_QN then
        table.insert(gatecontactpos, "dummy")
        table.insert(gatecontactpos, "center")
        table.insert(pcontactpos, "power")
        table.insert(pcontactpos, "inner")
        table.insert(ncontactpos, "power")
        table.insert(ncontactpos, "inner")
    end

    if _P.enable_set then
        -- first latch
        table.insert(gatecontactpos, 12, "center")
        table.insert(pcontactpos, 12, "inner")
        table.insert(ncontactpos, 12, nil)
        table.insert(gatecontactpos, 12, "dummy")
        table.insert(pcontactpos, 12, "power")
        table.insert(ncontactpos, 12, "outer")
        ncontactpos[13] = "outer"
        -- second latch
        table.insert(gatecontactpos, 21, "center")
        table.insert(pcontactpos, 21, "inner")
        table.insert(ncontactpos, 21, nil)
        table.insert(gatecontactpos, 21, "dummy")
        table.insert(pcontactpos, 21, "power")
        table.insert(ncontactpos, 21, "outer")
        ncontactpos[22] = "outer"
    end
    if _P.enable_reset then
        -- first latch
        table.insert(gatecontactpos, 12, "center")
        table.insert(gatecontactpos, 14, "dummy")
        table.insert(pcontactpos, 13, "inner")
        table.insert(ncontactpos, 13, nil)
        table.insert(pcontactpos, 14, "power")
        table.insert(ncontactpos, 14, "inner")
        -- second latch
        table.insert(gatecontactpos, 21, "center")
        table.insert(pcontactpos, 22, "inner")
        table.insert(ncontactpos, 22, nil)
        -- change source/drain connections in transmission gate
        --pcontactpos[14] = "power"
        --ncontactpos[15] = "outer"
        -- change drain connection of second latch inverter
        pcontactpos[23] = "power"
    end

    -- finish dff gates
    --table.insert(gatecontactpos, 1, "dummy")
    --table.insert(pcontactpos, 1, "power")
    --table.insert(ncontactpos, 1, "power")
    table.insert(gatecontactpos, "dummy")
    table.insert(pcontactpos, "power")
    table.insert(ncontactpos, "power")

    local harness = pcell.create_layout("stdcells/harness", "mosfets", {
        pwidth = _P.pwidth,
        nwidth = _P.nwidth,
        gatecontactpos = gatecontactpos,
        pcontactpos = pcontactpos,
        ncontactpos = ncontactpos,
    })
    dff:merge_into_shallow(harness)

    local setshift = _P.enable_set and 2 or 0
    local resetshift = _P.enable_reset and 1 or 0

    -- easy anchor access functions
    local _gateidx = function(num) return harness:get_anchor(string.format("G%dcc", num)) end
    local _gatestr = function(identifier)
        local lut = {
            clkinv1 = 1,
            clkinv2 = 3,
            cinv1EN = 5 + clkshift,
            cinv1EP = 6 - clkshift,
            cinv1I = 7,
            cinv2I = 9,
            cinv2EP = 10 + clkshift,
            cinv2EN = 11 - clkshift,
            inv1 = 12 + setshift + resetshift,
            tgateEN = 13,
            tgateEP = 14 - clkshift + setshift + 2 * resetshift,
            cinv3I = 16 + setshift + 2 * resetshift,
            cinv3EP = 17 + clkshift + setshift + 2 * resetshift,
            cinv3EN = 18 - clkshift + setshift + 2 * resetshift,
            inv2 = 19 + 2 * setshift + 3 * resetshift,
            outinv1 = 21 + 2 * setshift + 3 * resetshift,
            outinv2 = 23 + 2 * setshift + 3 * resetshift,
        }
        return _gateidx(lut[identifier])
    end
    local gate = function(identifier)
        if type(identifier) == "string" then
            return _gatestr(identifier)
        else
            return _gateidx(identifier)
        end
    end
    local sourcedrain = function(fet, pos, num) return harness:get_anchor(string.format("%sSD%d%s", fet, num, pos)) end

    local spacing = bp.sdwidth / 2 + bp.routingspace
    -- clock buffer input port landing
    geometry.rectanglebltr(dff, generics.metal(1),
        _gatestr("clkinv1"):translate(-xpitch, -bp.routingwidth / 2),
        _gatestr("clkinv1"):translate( xpitch - spacing, bp.routingwidth / 2)
    )
    -- clock buffer ~clk via
    geometry.viabltr(dff, 1, 2,
        _gatestr("clkinv2"):translate(-xpitch, -bp.routingwidth / 2),
        _gatestr("clkinv2"):translate( xpitch - spacing, bp.routingwidth / 2)
    )
    -- clock buffer ~clk drain connections
    geometry.path(dff, generics.metal(1),
        geometry.path_points_xy(sourcedrain("p", "bc", 2):translate(0, bp.sdwidth / 2), {
            xpitch / 2,
            sourcedrain("n", "tc", 2):translate(0, -bp.sdwidth / 2)
    }), bp.sdwidth)
    -- clock buffer clk drain connections
    geometry.path(dff, generics.metal(1),
        geometry.path_points_xy(sourcedrain("p", "bc", 4):translate(0, bp.sdwidth / 2), {
            xpitch / 2,
            sourcedrain("n", "tc", 4):translate(0, -bp.sdwidth / 2)
    }), bp.sdwidth)

    -- clk M2 bar
    geometry.viabltr(dff, 1, 2,
        _gatestr("cinv1EP"):translate((-2 + clkshift) * xpitch, -bp.routingwidth / 2),
        _gatestr("cinv1EP"):translate(( 2 + clkshift) * xpitch - spacing, bp.routingwidth / 2)
    )
    geometry.path(dff, generics.metal(2),
        geometry.path_points_xy(_gatestr("cinv1EP"):translate((-2 + clkshift) * xpitch, 0), {
            5 * xpitch,
            _gatestr("cinv3EP"):translate(xpitch - spacing, 0)
    }), bp.routingwidth)
    -- ~clk M2 bar
    geometry.rectanglebltr(dff, generics.metal(2), 
        _gatestr("clkinv2"):translate(-xpitch, -bp.routingwidth / 2),
        _gatestr("cinv3EN"):translate(xpitch - spacing, bp.routingwidth / 2)
    )

    -- cinv clk connection
    geometry.rectanglebltr(dff, generics.metal(1),
        _gatestr("cinv1EP"):translate((-2 + clkshift) * xpitch, -bp.routingwidth / 2),
        _gatestr("cinv1EP"):translate(( 2 + clkshift) * xpitch - spacing, bp.routingwidth / 2)
    )

    -- cinv ~clk connection
    geometry.viabltr(dff, 1, 2,
        _gatestr("cinv1EN"):translate((-1 - clkshift) * xpitch + spacing, -bp.routingwidth / 2),
        _gatestr("cinv1EN"):translate(( 3 - clkshift) * xpitch - spacing, bp.routingwidth / 2)
    )

    -- D input port landing
    geometry.viabltr(dff, 1, 2,
        _gatestr("clkinv1"):translate(-xpitch,           2 * (bp.routingwidth + bp.routingspace) - bp.routingwidth / 2),
        _gatestr("clkinv1"):translate( xpitch - spacing, 2 * (bp.routingwidth + bp.routingspace) + bp.routingwidth / 2)
    )
    -- cinv D connection
    geometry.viabltr(dff, 1, 2,
        _gatestr("cinv1I"):translate(-3 * xpitch + spacing, -bp.routingwidth / 2),
        _gatestr("cinv1I"):translate( 1 * xpitch - spacing, bp.routingwidth / 2)
    )
    geometry.rectanglebltr(dff, generics.metal(2), 
        _gatestr("clkinv1"):translate(-xpitch, 2 * (bp.routingwidth + bp.routingspace) - bp.routingwidth / 2), 
        _gatestr("cinv1I"):translate( 1 * xpitch - spacing, bp.routingwidth / 2)
    )

    -- cinv short nmos
    geometry.rectanglebltr(dff, generics.metal(1), 
        sourcedrain("n", "cc", 6):translate(0, -bp.sdwidth / 2),
        sourcedrain("n", "cc", 7):translate(0, bp.sdwidth / 2)
    )

    -- short dummy between cinv and first latch cinv
    geometry.rectanglebltr(dff, generics.metal(1), 
        sourcedrain("p", "cc", 8):translate(0, -bp.sdwidth / 2),
        sourcedrain("p", "cc", 9):translate(0, bp.sdwidth / 2)
    )
    geometry.rectanglebltr(dff, generics.metal(1), 
        sourcedrain("n", "cc", 8):translate(0, -bp.sdwidth / 2),
        sourcedrain("n", "cc", 9):translate(0, bp.sdwidth / 2)
    )

    -- short nmos in first latch (set layout)
    if _P.enable_set then
        geometry.rectanglebltr(dff, generics.metal(1), 
            sourcedrain("n", "cc", 12):translate(0, -bp.sdwidth / 2),
            sourcedrain("n", "cc", 13):translate(0, bp.sdwidth / 2)
        )
    end

    -- connect first latch cinv drains
    geometry.rectanglebltr(dff, generics.metal(1), 
        sourcedrain("n", "cc", 9):translate(-bp.sdwidth / 2, 0),
        sourcedrain("p", "cc", 9):translate( bp.sdwidth / 2, 0)
    )

    -- first latch / transmission gate clk bar vias
    geometry.rectanglebltr(dff, generics.metal(1), 
        _gatestr("cinv2EP"):translate(0, -bp.routingwidth / 2),
        _gatestr("tgateEP"):translate(0, bp.routingwidth / 2)
    )
    geometry.viabltr(dff, 1, 2,
        point.combine(
            _gatestr("cinv2EP"),
            _gatestr("tgateEP")
        ):translate(-xpitch - bp.glength / 2, -bp.routingwidth / 2),
        point.combine(
            _gatestr("cinv2EP"),
            _gatestr("tgateEP")
        ):translate( xpitch + bp.glength / 2, bp.routingwidth / 2)
    )
    if not _P.enable_set and not _P.enable_reset then
        geometry.rectanglebltr(dff, generics.metal(1), 
            _gatestr("cinv2EN"):translate(0, -bp.sdwidth / 2),
            gate(13 + clkshift + setshift + 2 * resetshift):translate(0, bp.sdwidth / 2)
        )
        geometry.viabltr(dff, 1, 2,
            point.combine(
                _gatestr("cinv2EN"),
                gate(13 + clkshift + setshift + 2 * resetshift)
            ):translate(-xpitch - bp.glength / 2, -bp.routingwidth / 2),
            point.combine(
                _gatestr("cinv2EN"),
                gate(13 + clkshift + setshift + 2 * resetshift)
            ):translate( xpitch + bp.glength / 2, bp.routingwidth / 2)
        )
    else
        geometry.viabltr(dff, 1, 2,
            _gatestr("cinv2EN"):translate(-bp.glength / 2, -bp.routingwidth / 2),
            _gatestr("cinv2EN"):translate( bp.glength / 2, bp.routingwidth / 2)
        )
        geometry.viabltr(dff, 1, 2,
            gate(15 + clkshift):translate(-bp.glength / 2, -bp.routingwidth / 2),
            gate(15 + clkshift):translate( bp.glength / 2, bp.routingwidth / 2)
        )
    end

    -- first latch short nmos or pmos
    geometry.rectanglebltr(dff, generics.metal(1), 
        sourcedrain("n", "cc", 10):translate(0, -bp.routingwidth / 2),
        sourcedrain("n", "cc", 11):translate(0, bp.routingwidth / 2)
    )

    -- first latch inverter connect drains to gate of first latch cinv
    geometry.path(dff, generics.metal(1),
        geometry.path_points_xy(sourcedrain("n", "tc", 13 + setshift + resetshift):translate(0, -bp.sdwidth / 2), {
            gate(9):translate(0, bp.sdwidth / 2)
    }), bp.sdwidth)

    -- first latch cinv drain to inv gate
    geometry.path(dff, generics.metal(1),
        geometry.path_points_xy( _gatestr("inv1"), {
            -xpitch - resetshift / 2 * xpitch,
            (bp.routingwidth + bp.routingspace) / (bp.numinnerroutes % 2 == 0 and 2 or 1),
            sourcedrain("p", "bc", 9)
    }), bp.sdwidth)

    -- first latch inverter connect drains
    -- (this also connects the drain of the pmos set transistor)
    local sdcorrection = _P.enable_reset and 1 or 0
    geometry.path_cshape(dff, generics.metal(1),
        sourcedrain("p", "bc", 13 + setshift + resetshift - sdcorrection):translate(0, bp.sdwidth / 2),
        sourcedrain("n", "tc", 13 + setshift + resetshift):translate(0, -bp.sdwidth / 2),
        gate(14 + setshift + 2 * resetshift):translate(xpitch, 0),
        bp.sdwidth
    )

    -- short transistors in transmission gate
    -- pmos does not need to be shorted, this is done while connecting nmos/pmos drains of the latch inverter
    geometry.rectanglebltr(dff, generics.metal(1), 
        sourcedrain("n", "cc", 14 + setshift + 2 * resetshift):translate(0, -bp.sdwidth / 2),
        sourcedrain("n", "cc", 15 + setshift + 2 * resetshift):translate(0, bp.sdwidth / 2)
    )

    -- short dummy between cinv and second latch cinv
    geometry.rectanglebltr(dff, generics.metal(1), 
        sourcedrain("p", "cc", 15 + setshift + 2 * resetshift):translate(0, -bp.sdwidth / 2),
        sourcedrain("p", "cc", 16 + setshift + 2 * resetshift):translate(0, bp.sdwidth / 2)
    )
    geometry.rectanglebltr(dff, generics.metal(1), 
        sourcedrain("n", "cc", 15 + setshift + 2 * resetshift):translate(0, -bp.sdwidth / 2),
        sourcedrain("n", "cc", 16 + setshift + 2 * resetshift):translate(0, bp.sdwidth / 2)
    )

    -- short nmos in second latch (set layout)
    if _P.enable_set then
        geometry.rectanglebltr(dff, generics.metal(1), 
            sourcedrain("n", "cc", 21 + resetshift):translate(0, -bp.sdwidth / 2),
            sourcedrain("n", "cc", 22 + resetshift):translate(0, bp.sdwidth / 2)
        )
    end

    -- connect second latch cinv / transmission gate drains
    geometry.rectanglebltr(dff, generics.metal(1), 
        sourcedrain("n", "cc", 16 + setshift + 2 * resetshift):translate(-bp.sdwidth / 2, 0),
        sourcedrain("p", "cc", 16 + setshift + 2 * resetshift):translate( bp.sdwidth / 2, 0)
    )

    -- second latch clk bar vias
    geometry.viabltr(dff, 1, 2,
        gate(17 + setshift + 2 * resetshift):translate((clkshift - 1) * xpitch - bp.glength / 2, -bp.routingwidth / 2),
        gate(17 + setshift + 2 * resetshift):translate((clkshift + 1) * xpitch + bp.glength / 2, bp.routingwidth / 2)
    )
    geometry.viabltr(dff, 1, 2,
        gate(18 + setshift + 2 * resetshift):translate((-clkshift - 1) * xpitch - bp.glength / 2, -bp.routingwidth / 2),
        gate(18 + setshift + 2 * resetshift):translate((-clkshift + 1) * xpitch + bp.glength / 2, bp.routingwidth / 2)
    )

    -- second latch short nmos or pmos
    geometry.rectanglebltr(dff, generics.metal(1), 
        sourcedrain("n", "cc", 17 + setshift + 2 * resetshift):translate(0, -bp.sdwidth / 2),
        sourcedrain("n", "cc", 18 + setshift + 2 * resetshift):translate(0, bp.sdwidth / 2)
    )

    -- second latch inverter connect drains to gate of second latch cinv
    geometry.path(dff, generics.metal(1),
        geometry.path_points_xy(sourcedrain("n", "tc", 20 + 2 * setshift + 3 * resetshift):translate(0, -bp.sdwidth / 2), {
            _gatestr("cinv3I"):translate(0, bp.sdwidth / 2)
    }), bp.sdwidth)

    -- second latch cinv drain to inv gate
    geometry.path(dff, generics.metal(1),
        geometry.path_points_xy( _gatestr("inv2"), {
            -xpitch - resetshift / 2 * xpitch,
            (bp.routingwidth + bp.routingspace) / (bp.numinnerroutes % 2 == 0 and 2 or 1),
            sourcedrain("p", "bc", 16 + setshift + 2 * resetshift)
    }), bp.sdwidth)

    -- second latch inverter connect drains
    -- (this also connects the drain of the pmos set transistor)
    local sdcorrection = _P.enable_reset and 1 or 0
    geometry.path_cshape(dff, generics.metal(1),
        sourcedrain("p", "bc", 20 + 2 * setshift + 3 * resetshift - sdcorrection):translate(0, bp.sdwidth / 2),
        sourcedrain("n", "tc", 20 + 2 * setshift + 3 * resetshift):translate(0, -bp.sdwidth / 2),
        _gatestr("inv2"):translate(xpitch, 0),
        bp.sdwidth
    )

    -- output inverter connect gate
    geometry.rectanglebltr(dff, generics.metal(1), 
        _gatestr("outinv1"):translate(-xpitch, -bp.sdwidth / 2),
        _gatestr("outinv1"):translate(bp.glength / 2,  bp.sdwidth / 2)
    )

    -- output Q inverter connect drains
    geometry.path_cshape(dff, generics.metal(1),
        sourcedrain("p", "bc", 22 + 2 * setshift + 3 * resetshift):translate(0, bp.sdwidth / 2),
        sourcedrain("n", "tc", 22 + 2 * setshift + 3 * resetshift):translate(0, -bp.sdwidth / 2),
        _gatestr("outinv1"):translate(xpitch, 0),
        bp.sdwidth
    )

    -- output QN inverter connect drains and gate
    if _P.enable_QN then
        geometry.rectanglebltr(dff, generics.metal(1), 
            _gatestr("outinv2"):translate(-xpitch, -bp.sdwidth / 2),
            _gatestr("outinv2"):translate(bp.glength / 2,  bp.sdwidth / 2)
        )
        geometry.path_cshape(dff, generics.metal(1),
            sourcedrain("p", "bc", 24 + 2 * setshift + 3 * resetshift):translate(0, bp.sdwidth / 2),
            sourcedrain("n", "tc", 24 + 2 * setshift + 3 * resetshift):translate(0, -bp.sdwidth / 2),
            _gatestr("outinv2"):translate(xpitch, 0),
            bp.sdwidth
        )
    end

    -- set bar and M1/M2 vias
    if _P.enable_set then
        geometry.rectanglebltr(dff, generics.metal(2),
            _gatestr("tgateEN"):translate(0, -bp.routingwidth / 2),
            gate(22):translate(0, bp.routingwidth / 2)
        )
        geometry.viabltr(dff, 1, 2,
            _gatestr("tgateEN"):translate(-xpitch - bp.glength / 2, -bp.routingwidth / 2),
            _gatestr("tgateEN"):translate( xpitch + bp.glength / 2, bp.routingwidth / 2)
        )
        geometry.viabltr(dff, 1, 2,
            gate(22):translate(-xpitch - bp.glength / 2, -bp.routingwidth / 2),
            gate(22):translate( xpitch + bp.glength / 2, bp.routingwidth / 2)
        )
    end

    -- reset bar and M1/M2 vias
    if _P.enable_reset then
        geometry.rectanglebltr(dff, generics.metal(2),
            gate(12):translate(0, -bp.routingwidth / 2),
            gate(21):translate(0, bp.routingwidth / 2)
        )
        geometry.viabltr(dff, 1, 2,
            gate(12):translate(-xpitch - bp.glength / 2, -bp.routingwidth / 2),
            gate(12):translate( xpitch + bp.glength / 2, bp.routingwidth / 2)
        )
        geometry.viabltr(dff, 1, 2,
            gate(21):translate(-xpitch - bp.glength / 2, -bp.routingwidth / 2),
            gate(21):translate( xpitch + bp.glength / 2, bp.routingwidth / 2)
        )
    end

    -- ports
    dff:add_port("VDD", generics.metalport(1), harness:get_anchor("top"))
    dff:add_port("VSS", generics.metalport(1), harness:get_anchor("bottom"))
    dff:add_port("CLK", generics.metalport(1), _gatestr("clkinv1"))
    dff:add_port("D", generics.metalport(1), _gatestr("clkinv1"):translate(0, 2 * (bp.routingwidth + bp.routingspace)))
    if _P.enable_Q then
        dff:add_port("Q", generics.metalport(1), _gatestr("outinv1"):translate(xpitch, 0))
    end
    if _P.enable_QN then
        dff:add_port("QN", generics.metalport(1), _gatestr("outinv2"):translate(xpitch, 0))
    end
    if _P.enable_set then
        dff:add_port("SET", generics.metalport(2), point.combine(_gatestr("tgateEN"), gate(22)))
    end
    if _P.enable_reset then
        dff:add_port("RST", generics.metalport(2), point.combine(gate(12), gate(21)))
    end

    -- alignment box
    dff:inherit_alignment_box(harness)
end

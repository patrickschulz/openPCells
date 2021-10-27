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
    pcell.add_parameter("clockpolarity", "positive", { posvals = set("positive", "negative") })
    pcell.add_parameter("enable_Q", true)
    pcell.add_parameter("enable_QN", false)
    pcell.add_parameter("enable_set", false)
    pcell.add_parameter("enable_reset", false)
    pcell.check_expression("not (enable_set and enable_reset)", "sorry, this dff implementation currently does not support simultaneous set and reset pins")
end

function layout(dff, _P)
    local bp = pcell.get_parameters("stdcells/base")

    local xpitch = bp.gspace + bp.glength
    local yrpitch = bp.gstwidth + bp.gstspace

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

    local harness = pcell.create_layout("stdcells/harness", {
        fingers = #gatecontactpos,
        gatecontactpos = gatecontactpos,
        pcontactpos = pcontactpos,
        ncontactpos = ncontactpos,
    })
    dff:merge_into_shallow(harness)

    local setshift = _P.enable_set and 2 or 0
    local resetshift = _P.enable_reset and 1 or 0

    -- easy anchor access functions
    local gate = function(num) return harness:get_anchor(string.format("G%d", num)) end
    local sourcedrain = function(fet, pos, num) return harness:get_anchor(string.format("%sSD%s%d", fet, pos, num)) end

    local spacing = bp.sdwidth / 2 + bp.gstspace
    -- clock buffer input port landing
    dff:merge_into_shallow(geometry.rectanglebltr(generics.metal(1),
        gate(1):translate(-xpitch, -bp.gstwidth / 2),
        gate(1):translate( xpitch - spacing, bp.gstwidth / 2)
    ))
    -- clock buffer ~clk via
    dff:merge_into_shallow(geometry.rectanglebltr(generics.via(1, 2, { lastbare = true }),
        gate(3):translate(-xpitch, -bp.gstwidth / 2),
        gate(3):translate( xpitch - spacing, bp.gstwidth / 2)
    ))
    -- clock buffer ~clk drain connections
    dff:merge_into_shallow(geometry.path(generics.metal(1),
        geometry.path_points_xy(sourcedrain("p", "i", 2):translate(0, bp.sdwidth / 2), {
            xpitch / 2,
            sourcedrain("n", "i", 2):translate(0, -bp.sdwidth / 2)
    }), bp.sdwidth))
    -- clock buffer clk drain connections
    dff:merge_into_shallow(geometry.path(generics.metal(1),
        geometry.path_points_xy(sourcedrain("p", "i", 4):translate(0, bp.sdwidth / 2), {
            xpitch / 2,
            sourcedrain("n", "i", 4):translate(0, -bp.sdwidth / 2)
    }), bp.sdwidth))

    -- clk M2 bar
    dff:merge_into_shallow(geometry.rectanglebltr(generics.via(1, 2, { bare = true }),
        gate(6 - clkshift):translate((-2 + clkshift) * xpitch, -bp.gstwidth / 2),
        gate(6 - clkshift):translate(( 2 + clkshift) * xpitch - spacing, bp.gstwidth / 2)
    ))
    dff:merge_into_shallow(geometry.path(generics.metal(2),
        geometry.path_points_xy(gate(6 - clkshift):translate((-2 + clkshift) * xpitch, 0), {
            5 * xpitch,
            gate(17 + clkshift + setshift + 2 * resetshift):translate(xpitch - spacing, 0)
    }), bp.sdwidth))
    -- ~clk M2 bar
    dff:merge_into_shallow(geometry.rectanglebltr(generics.metal(2), 
        gate(3):translate(-xpitch, -bp.gstwidth / 2),
        gate(18 - clkshift + setshift + 2 * resetshift):translate(xpitch - spacing, bp.gstwidth / 2)
    ))

    -- cinv clk connection
    dff:merge_into_shallow(geometry.rectanglebltr(generics.metal(1),
        gate(6 - clkshift):translate((-2 + clkshift) * xpitch, -bp.gstwidth / 2),
        gate(6 - clkshift):translate(( 2 + clkshift) * xpitch - spacing, bp.gstwidth / 2)
    ))

    -- cinv ~clk connection
    dff:merge_into_shallow(geometry.rectanglebltr(generics.via(1, 2, { lastbare = true }), 
        gate(5 + clkshift):translate((-1 - clkshift) * xpitch + spacing, -bp.gstwidth / 2),
        gate(5 + clkshift):translate(( 3 - clkshift) * xpitch - spacing, bp.gstwidth / 2)
    ))

    -- D input port landing
    dff:merge_into_shallow(geometry.rectanglebltr(generics.via(1, 2, { lastbare = true }),
        gate(1):translate(-xpitch,           2 * (bp.gstwidth + bp.gstspace) - bp.gstwidth / 2),
        gate(1):translate( xpitch - spacing, 2 * (bp.gstwidth + bp.gstspace) + bp.gstwidth / 2)
    ))
    -- cinv D connection
    dff:merge_into_shallow(geometry.rectanglebltr(generics.via(1, 2, { lastbare = true }), 
        gate(7):translate(-3 * xpitch + spacing, -bp.gstwidth / 2),
        gate(7):translate( 1 * xpitch - spacing, bp.gstwidth / 2)
    ))
    dff:merge_into_shallow(geometry.rectanglebltr(generics.metal(2), 
        gate(1):translate(-xpitch, 2 * (bp.gstwidth + bp.gstspace) - bp.gstwidth / 2), 
        gate(7):translate( 1 * xpitch - spacing, bp.gstwidth / 2)
    ))

    -- cinv short nmos
    dff:merge_into_shallow(geometry.rectanglebltr(generics.metal(1), 
        sourcedrain("n", "c", 6):translate(0, -bp.sdwidth / 2),
        sourcedrain("n", "c", 7):translate(0, bp.sdwidth / 2)
    ))

    -- short dummy between cinv and first latch cinv
    dff:merge_into_shallow(geometry.rectanglebltr(generics.metal(1), 
        sourcedrain("p", "c", 8):translate(0, -bp.sdwidth / 2),
        sourcedrain("p", "c", 9):translate(0, bp.sdwidth / 2)
    ))
    dff:merge_into_shallow(geometry.rectanglebltr(generics.metal(1), 
        sourcedrain("n", "c", 8):translate(0, -bp.sdwidth / 2),
        sourcedrain("n", "c", 9):translate(0, bp.sdwidth / 2)
    ))

    -- short nmos in first latch (set layout)
    if _P.enable_set then
        dff:merge_into_shallow(geometry.rectanglebltr(generics.metal(1), 
            sourcedrain("n", "c", 12):translate(0, -bp.sdwidth / 2),
            sourcedrain("n", "c", 13):translate(0, bp.sdwidth / 2)
        ))
    end

    -- connect first latch cinv drains
    dff:merge_into_shallow(geometry.rectanglebltr(generics.metal(1), 
        sourcedrain("n", "c", 9):translate(-bp.sdwidth / 2, 0),
        sourcedrain("p", "c", 9):translate( bp.sdwidth / 2, 0)
    ))

    -- first latch / transmission gate clk bar vias
    dff:merge_into_shallow(geometry.rectanglebltr(generics.metal(1), 
        gate(10 + clkshift):translate(0, -bp.sdwidth / 2),
        gate(14 - clkshift + setshift + 2 * resetshift):translate(0, bp.sdwidth / 2)
    ))
    dff:merge_into_shallow(geometry.rectanglebltr(generics.via(1, 2), 
        point.combine(
            gate(10 + clkshift),
            gate(14 - clkshift + setshift + 2 * resetshift)
        ):translate(-xpitch - bp.glength / 2, -bp.sdwidth / 2),
        point.combine(
            gate(10 + clkshift),
            gate(14 - clkshift + setshift + 2 * resetshift)
        ):translate( xpitch + bp.glength / 2, bp.sdwidth / 2)
    ))
    if not _P.enable_set and not _P.enable_reset then
        dff:merge_into_shallow(geometry.rectanglebltr(generics.metal(1), 
            gate(11 - clkshift):translate(0, -bp.sdwidth / 2),
            gate(13 + clkshift + setshift + 2 * resetshift):translate(0, bp.sdwidth / 2)
        ))
        dff:merge_into_shallow(geometry.rectanglebltr(generics.via(1, 2), 
            point.combine(
                gate(11 - clkshift),
                gate(13 + clkshift + setshift + 2 * resetshift)
            ):translate(-xpitch - bp.glength / 2, -bp.sdwidth / 2),
            point.combine(
                gate(11 - clkshift),
                gate(13 + clkshift + setshift + 2 * resetshift)
            ):translate( xpitch + bp.glength / 2, bp.sdwidth / 2)
        ))
    else
        dff:merge_into_shallow(geometry.rectanglebltr(generics.via(1, 2), 
            gate(11 - clkshift):translate(-bp.glength / 2, -bp.sdwidth / 2),
            gate(11 - clkshift):translate( bp.glength / 2, bp.sdwidth / 2)
        ))
        dff:merge_into_shallow(geometry.rectanglebltr(generics.via(1, 2), 
            gate(15 + clkshift):translate(-bp.glength / 2, -bp.sdwidth / 2),
            gate(15 + clkshift):translate( bp.glength / 2, bp.sdwidth / 2)
        ))
    end

    -- first latch short nmos or pmos
    dff:merge_into_shallow(geometry.rectanglebltr(generics.metal(1), 
        sourcedrain("n", "c", 10):translate(0, -bp.sdwidth / 2),
        sourcedrain("n", "c", 11):translate(0, bp.sdwidth / 2)
    ))

    -- first latch inverter connect drains to gate of first latch cinv
    dff:merge_into_shallow(geometry.path(generics.metal(1),
        geometry.path_points_xy(sourcedrain("n", "i", 13 + setshift + resetshift):translate(0, -bp.sdwidth / 2), {
            gate(9):translate(0, bp.sdwidth / 2)
    }), bp.sdwidth))

    -- first latch cinv drain to inv gate
    dff:merge_into_shallow(geometry.path(generics.metal(1),
        geometry.path_points_xy( gate(12 + setshift + resetshift), {
            -xpitch - resetshift / 2 * xpitch,
            (bp.gstwidth + bp.gstspace) / (bp.numinnerroutes % 2 == 0 and 2 or 1),
            sourcedrain("p", "i", 9)
    }), bp.sdwidth))

    -- first latch inverter connect drains
    -- (this also connects the drain of the pmos set transistor)
    local sdcorrection = _P.enable_reset and 1 or 0
    dff:merge_into_shallow(geometry.path_c_shape(generics.metal(1),
        sourcedrain("p", "i", 13 + setshift + resetshift - sdcorrection):translate(0, bp.sdwidth / 2),
        gate(14 + setshift + 2 * resetshift):translate(xpitch, 0),
        sourcedrain("n", "i", 13 + setshift + resetshift):translate(0, -bp.sdwidth / 2),
        bp.sdwidth
    ))

    -- short transistors in transmission gate
    -- pmos does not need to be shorted, this is done while connecting nmos/pmos drains of the latch inverter
    dff:merge_into_shallow(geometry.rectanglebltr(generics.metal(1), 
        sourcedrain("n", "c", 14 + setshift + 2 * resetshift):translate(0, -bp.sdwidth / 2),
        sourcedrain("n", "c", 15 + setshift + 2 * resetshift):translate(0, bp.sdwidth / 2)
    ))

    -- short dummy between cinv and second latch cinv
    dff:merge_into_shallow(geometry.rectanglebltr(generics.metal(1), 
        sourcedrain("p", "c", 15 + setshift + 2 * resetshift):translate(0, -bp.sdwidth / 2),
        sourcedrain("p", "c", 16 + setshift + 2 * resetshift):translate(0, bp.sdwidth / 2)
    ))
    dff:merge_into_shallow(geometry.rectanglebltr(generics.metal(1), 
        sourcedrain("n", "c", 15 + setshift + 2 * resetshift):translate(0, -bp.sdwidth / 2),
        sourcedrain("n", "c", 16 + setshift + 2 * resetshift):translate(0, bp.sdwidth / 2)
    ))

    -- short nmos in second latch (set layout)
    if _P.enable_set then
        dff:merge_into_shallow(geometry.rectanglebltr(generics.metal(1), 
            sourcedrain("n", "c", 21 + resetshift):translate(0, -bp.sdwidth / 2),
            sourcedrain("n", "c", 22 + resetshift):translate(0, bp.sdwidth / 2)
        ))
    end

    -- connect second latch cinv / transmission gate drains
    dff:merge_into_shallow(geometry.rectanglebltr(generics.metal(1), 
        sourcedrain("n", "c", 16 + setshift + 2 * resetshift):translate(-bp.sdwidth / 2, 0),
        sourcedrain("p", "c", 16 + setshift + 2 * resetshift):translate( bp.sdwidth / 2, 0)
    ))

    -- second latch clk bar vias
    dff:merge_into_shallow(geometry.rectanglebltr(generics.via(1, 2), 
        gate(17 + setshift + 2 * resetshift):translate((clkshift - 1) * xpitch - bp.glength / 2, -bp.sdwidth / 2),
        gate(17 + setshift + 2 * resetshift):translate((clkshift + 1) * xpitch + bp.glength / 2, bp.sdwidth / 2)
    ))
    dff:merge_into_shallow(geometry.rectanglebltr(generics.via(1, 2), 
        gate(18 + setshift + 2 * resetshift):translate((-clkshift - 1) * xpitch - bp.glength / 2, -bp.sdwidth / 2),
        gate(18 + setshift + 2 * resetshift):translate((-clkshift + 1) * xpitch + bp.glength / 2, bp.sdwidth / 2)
    ))

    -- second latch short nmos or pmos
    dff:merge_into_shallow(geometry.rectanglebltr(generics.metal(1), 
        sourcedrain("n", "c", 17 + setshift + 2 * resetshift):translate(0, -bp.sdwidth / 2),
        sourcedrain("n", "c", 18 + setshift + 2 * resetshift):translate(0, bp.sdwidth / 2)
    ))

    -- second latch inverter connect drains to gate of second latch cinv
    dff:merge_into_shallow(geometry.path(generics.metal(1),
        geometry.path_points_xy(sourcedrain("n", "i", 20 + 2 * setshift + 3 * resetshift):translate(0, -bp.sdwidth / 2), {
            gate(16 + setshift + 2 * resetshift):translate(0, bp.sdwidth / 2)
    }), bp.sdwidth))

    -- second latch cinv drain to inv gate
    dff:merge_into_shallow(geometry.path(generics.metal(1),
        geometry.path_points_xy( gate(19 + 2 * setshift + 3 * resetshift), {
            -xpitch - resetshift / 2 * xpitch,
            (bp.gstwidth + bp.gstspace) / (bp.numinnerroutes % 2 == 0 and 2 or 1),
            sourcedrain("p", "i", 16 + setshift + 2 * resetshift)
    }), bp.sdwidth))

    -- second latch inverter connect drains
    -- (this also connects the drain of the pmos set transistor)
    local sdcorrection = _P.enable_reset and 1 or 0
    dff:merge_into_shallow(geometry.path_c_shape(generics.metal(1),
        sourcedrain("p", "i", 20 + 2 * setshift + 3 * resetshift - sdcorrection):translate(0, bp.sdwidth / 2),
        gate(19 + 2 * setshift + 3 * resetshift):translate(xpitch, 0),
        sourcedrain("n", "i", 20 + 2 * setshift + 3 * resetshift):translate(0, -bp.sdwidth / 2),
        bp.sdwidth
    ))

    -- output inverter connect gate
    dff:merge_into_shallow(geometry.rectanglebltr(generics.metal(1), 
        gate(21 + 2 * setshift + 3 * resetshift):translate(-xpitch, -bp.sdwidth / 2),
        gate(21 + 2 * setshift + 3 * resetshift):translate(bp.glength / 2,  bp.sdwidth / 2)
    ))

    -- output Q inverter connect drains
    dff:merge_into_shallow(geometry.path_c_shape(generics.metal(1),
        sourcedrain("p", "i", 22 + 2 * setshift + 3 * resetshift):translate(0, bp.sdwidth / 2),
        gate(21 + 2 * setshift + 3 * resetshift):translate(xpitch, 0),
        sourcedrain("n", "i", 22 + 2 * setshift + 3 * resetshift):translate(0, -bp.sdwidth / 2),
        bp.sdwidth
    ))

    -- output QN inverter connect drains and gate
    if _P.enable_QN then
        dff:merge_into_shallow(geometry.rectanglebltr(generics.metal(1), 
            gate(23 + 2 * setshift + 3 * resetshift):translate(-xpitch, -bp.sdwidth / 2),
            gate(23 + 2 * setshift + 3 * resetshift):translate(bp.glength / 2,  bp.sdwidth / 2)
        ))
        dff:merge_into_shallow(geometry.path_c_shape(generics.metal(1),
            sourcedrain("p", "i", 24 + 2 * setshift + 3 * resetshift):translate(0, bp.sdwidth / 2),
            gate(23 + 2 * setshift + 3 * resetshift):translate(xpitch, 0),
            sourcedrain("n", "i", 24 + 2 * setshift + 3 * resetshift):translate(0, -bp.sdwidth / 2),
            bp.sdwidth
        ))
    end

    -- set bar and M1/M2 vias
    if _P.enable_set then
        dff:merge_into_shallow(geometry.rectanglebltr(generics.metal(2),
            gate(13):translate(0, -bp.gstwidth / 2),
            gate(22):translate(0, bp.gstwidth / 2)
        ))
        dff:merge_into_shallow(geometry.rectanglebltr(generics.via(1, 2), 
            gate(13):translate(-xpitch - bp.glength / 2, -bp.sdwidth / 2),
            gate(13):translate( xpitch + bp.glength / 2, bp.sdwidth / 2)
        ))
        dff:merge_into_shallow(geometry.rectanglebltr(generics.via(1, 2), 
            gate(22):translate(-xpitch - bp.glength / 2, -bp.sdwidth / 2),
            gate(22):translate( xpitch + bp.glength / 2, bp.sdwidth / 2)
        ))
    end

    -- reset bar and M1/M2 vias
    if _P.enable_reset then
        dff:merge_into_shallow(geometry.rectanglebltr(generics.metal(2),
            gate(12):translate(0, -bp.gstwidth / 2),
            gate(21):translate(0, bp.gstwidth / 2)
        ))
        dff:merge_into_shallow(geometry.rectanglebltr(generics.via(1, 2), 
            gate(12):translate(-xpitch - bp.glength / 2, -bp.sdwidth / 2),
            gate(12):translate( xpitch + bp.glength / 2, bp.sdwidth / 2)
        ))
        dff:merge_into_shallow(geometry.rectanglebltr(generics.via(1, 2), 
            gate(21):translate(-xpitch - bp.glength / 2, -bp.sdwidth / 2),
            gate(21):translate( xpitch + bp.glength / 2, bp.sdwidth / 2)
        ))
    end

    -- ports
    dff:add_port("VDD", generics.metal(1), harness:get_anchor("top"))
    dff:add_port("VSS", generics.metal(1), harness:get_anchor("bottom"))
    dff:add_port("CLK", generics.metal(1), gate(1))
    dff:add_port("D", generics.metal(1), gate(1):translate(0, 2 * (bp.gstwidth + bp.gstspace)))
    if _P.enable_Q then
        dff:add_port("Q", generics.metal(1), gate(21 + 2 * setshift + 3 * resetshift):translate(xpitch, 0))
    end
    if _P.enable_QN then
        dff:add_port("QN", generics.metal(1), gate(23 + 2 * setshift + 3 * resetshift):translate(xpitch, 0))
    end
    if _P.enable_set then
        dff:add_port("SET", generics.metal(2), point.combine(gate(13), gate(22)))
    end
    if _P.enable_reset then
        dff:add_port("RST", generics.metal(2), point.combine(gate(12), gate(21)))
    end

    -- alignment box
    dff:inherit_alignment_box(harness)
end

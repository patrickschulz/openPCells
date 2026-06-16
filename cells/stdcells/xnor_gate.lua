--[[
    VDD ----*-----------------------*
            |                       |
            |                       |
         |--|                    |--|
   ~B --o|                  A --o| 
         |--|                    |--|
            *-----------------------*
         |--|                    |--|
    B --o|                 ~A --o| 
         |--|                    |--|
            |                       |
            *-----------------------*-------o A XNOR B
            |                       |
         |--|                    |--|
    B ---|                 ~B ---| 
         |--|                    |--|
            |                       |
         |--|                    |--|
   ~A ---|                  A ---| 
         |--|                    |--|
            |                       |
            |                       |
    VSS ----*-----------------------*
--]]

--[[
Implementation:
    * PMOS devices from left to right
        1) A-inverter
        2) dummy
        3) dummy
        4) B-inverter
        5) A set gate
        6) dummy (shorted)
        7) ~B set gate
        8) dummy
--]]

function parameters()
    pcell.add_parameter("fingers", 1, { posvals = set(1) })
    pcell.add_parameter("shiftoutput", 0)
    pcell.inherit_parameters("stdcells/base")
end

-- FIXME: this layout is copied from the xor implementation (hence: it implements an xor)
function layout(gate, _P)
    local xpitch = _P.gatespace + _P.gatelength

    local baseparameters = {}
    for name, value in pairs(_P) do
        if pcell.has_parameter("stdcells/harness", name) then
            baseparameters[name] = value
        end
    end
    local harness = pcell.create_layout("stdcells/harness", "mosfets", util.add_options(baseparameters, {
        gatecontactpos = { "lower1", "dummy", "dummy", "upper1", "lower1", "center", "center", "dummy", "upper1", "center", "lower1" },
        pcontactpos = { "power", "inner", "power", "inner", "power", "outer", "outer", "outer", "full", "unused", "power", "power" },
        ncontactpos = { "power", "inner", "power", "inner", "power", "power", "unused", "outer", "full", "outer", "outer", "power" },
    }))
    gate:merge_into(harness)
    gate:inherit_alignment_box(harness)

    ---[[
    -- short pmos
    geometry.rectanglebltr(gate, generics.metal(1), 
        harness:get_area_anchor("pSD6").tr:translate(0, -_P.sdwidth),
        harness:get_area_anchor("pSD7").tl
    )
    geometry.rectanglebltr(gate, generics.metal(1), 
        harness:get_area_anchor("pSD8").tr:translate(0, -_P.sdwidth),
        harness:get_area_anchor("pSD9").tl
    )

    -- short nmos
    geometry.rectanglebltr(gate, generics.metal(1), 
        harness:get_area_anchor("nSD10").br,
        harness:get_area_anchor("nSD11").bl:translate(0, _P.sdwidth)
    )
    geometry.rectanglebltr(gate, generics.metal(1), 
        harness:get_area_anchor("nSD8").br,
        harness:get_area_anchor("nSD9").bl:translate(0, _P.sdwidth)
    )

    -- output connection
    geometry.path_cshape(gate, generics.metal(1),
        harness:get_area_anchor("pSD9").br:translate(0, _P.sdwidth / 2),
        harness:get_area_anchor("nSD9").tr:translate(0, -_P.sdwidth / 2),
        harness:get_area_anchor("G11").bl:translate(xpitch, 0),
        _P.sdwidth
    )

    -- A
    geometry.rectanglebltr(gate, generics.metal(2),
        harness:get_area_anchor("G1").br,
        harness:get_area_anchor("G11").tl
    )
    geometry.viabltr(gate, 1, 2,
        harness:get_area_anchor("G1").bl,
        harness:get_area_anchor("G1").tr
    )
    geometry.viabltr(gate, 1, 2,
        harness:get_area_anchor("G5").bl,
        harness:get_area_anchor("G5").tr
    )
    geometry.viabltr(gate, 1, 2,
        harness:get_area_anchor("G11").bl,
        harness:get_area_anchor("G11").tr
    )

    -- B
    geometry.rectanglebltr(gate, generics.metal(2),
        point.combine_12(harness:get_area_anchor("G1").tr, harness:get_area_anchor("G9").bl),
        harness:get_area_anchor("G9").tl
    )
    geometry.viabltr(gate, 1, 2,
        point.combine_12(harness:get_area_anchor("G1").bl, harness:get_area_anchor("G4").bl),
        point.combine_12(harness:get_area_anchor("G1").br, harness:get_area_anchor("G4").tl)
    )
    geometry.viabltr(gate, 1, 2,
        harness:get_area_anchor("G4").bl,
        harness:get_area_anchor("G4").tr
    )
    geometry.viabltr(gate, 1, 2,
        harness:get_area_anchor("G9").bl,
        harness:get_area_anchor("G9").tr
    )

    -- not A
    geometry.path_cshape(gate, generics.metal(1),
        harness:get_area_anchor("pSD2").br:translate(0, _P.sdwidth / 2),
        harness:get_area_anchor("nSD2").tr:translate(0, -_P.sdwidth / 2),
        harness:get_area_anchor("G2").bl,
        _P.sdwidth
    )

    -- not B
    geometry.path_cshape(gate, generics.metal(1),
        harness:get_area_anchor("pSD4").br:translate(0, _P.sdwidth / 2),
        harness:get_area_anchor("nSD4").tr:translate(0, -_P.sdwidth / 2),
        harness:get_area_anchor("G7").bl,
        _P.sdwidth
    )

    geometry.rectanglebltr(gate, generics.metal(1),
        point.combine_12(harness:get_area_anchor("G2").tr, harness:get_area_anchor("G6").bl),
        harness:get_area_anchor("G6").tl
    )
    geometry.rectanglebltr(gate, generics.metal(2),
        harness:get_area_anchor("G6").br,
        harness:get_area_anchor("G10").tl
    )
    geometry.viabltr(gate, 1, 2,
        harness:get_area_anchor("G6").bl,
        harness:get_area_anchor("G6").tr
    )
    geometry.viabltr(gate, 1, 2,
        harness:get_area_anchor("G10").bl,
        harness:get_area_anchor("G10").tr
    )

    gate:add_port_with_anchor("A", generics.metalport(1), harness:get_area_anchor("G1").bl)
    gate:add_port_with_anchor("B", generics.metalport(1), point.combine_12(harness:get_area_anchor("G1").bl, harness:get_area_anchor("G4").bl))
    gate:add_port_with_anchor("O", generics.metalport(1), harness:get_area_anchor("G10").bl:translate(2 * xpitch, 0))
    gate:add_port_with_anchor("VDD", generics.metalport(1), harness:get_area_anchor("PRp").bl)
    gate:add_port_with_anchor("VSS", generics.metalport(1), harness:get_area_anchor("PRn").bl)
    --]]
end

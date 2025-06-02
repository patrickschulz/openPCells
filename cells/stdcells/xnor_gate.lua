
-- FIXME: this is just a copy of the xor_gate
--[[
    VDD ----*-----------------------*
            |                       |
            |                       |
          |-|                     |-|
    A ---o|                ~A ---o|
          |-|                     |-|
            |                       |
          |-|                     |-|
   ~B ---o|                 B ---o|
          |-|                     |-|
            |                       |
            *-----------------------*-------o A XOR B
            |                       |
          |-|                     |-|
   ~B ----|                 B ----|
          |-|                     |-|
            |                       |
          |-|                     |-|
   ~A ----|                 A ----|
          |-|                     |-|
            |                       |
            |                       |
    VSS ----*-----------------------*
--]]

function parameters()
    pcell.add_parameter("fingers", 1, { posvals = set(1) })
    pcell.add_parameter("shiftoutput", 0)
    pcell.inherit_parameters("stdcells/base")
end

function layout(gate, _P)
    local xpitch = _P.gatespace + _P.gatelength

    local block = object.create_pseudo()

    local baseparameters = {}
    for name, value in pairs(_P) do
        if pcell.has_parameter("stdcells/harness", name) then
            baseparameters[name] = value
        end
    end
    local harness = pcell.create_layout("stdcells/harness", "mosfets", util.add_options(baseparameters, {
        gatecontactpos = { "lower1", "center", "center", "upper1", "center", "lower1" },
        pcontactpos = { "power", "outer", "outer", "outer", nil, "power", "power" },
        ncontactpos = { "power", "power", nil, "inner", "outer", "outer", "power" },
    }))
    gate:merge_into(harness)

    -- gate contact metal blobs (DRC)
    geometry.rectanglebltr(block,generics.metal(1), 
        harness:get_area_anchor("G2").bl:translate(-_P.gatelength / 2, -_P.routingwidth / 2), 
        point.combine_12(harness:get_area_anchor("G2").bl, harness:get_area_anchor("G4").bl):translate(_P.gatelength / 2, _P.routingwidth / 2)
    )
    geometry.rectanglebltr(block, generics.metal(1), 
        point.combine_12(harness:get_area_anchor("G3").bl, harness:get_area_anchor("G2").bl):translate(-_P.gatelength / 2, -_P.routingwidth / 2),
        point.combine_12(harness:get_area_anchor("G3").bl, harness:get_area_anchor("G4").bl):translate( _P.gatelength / 2,  _P.routingwidth / 2)
    )

    -- short pmos
    geometry.rectanglebltr(block, generics.metal(1), 
        harness:get_area_anchor("pSD2").bl:translate(0, -_P.sdwidth / 2), 
        harness:get_area_anchor("pSD3").bl:translate(0,  _P.sdwidth / 2)
    )

    -- short nmos
    geometry.rectanglebltr(block, generics.metal(1), 
        harness:get_area_anchor("nSD5").bl:translate(0, -_P.sdwidth / 2), 
        harness:get_area_anchor("nSD6").bl:translate(0,  _P.sdwidth / 2)
    )

    -- place block
    for i = 1, _P.fingers do
        local shift = 4 * (i - 1) - (_P.fingers - 1)
        if i % 2 == 0 then
            --gate:merge_into(block:copy():flipx():translate(-shift * xpitch, 0))
            gate:merge_into(block:copy())
        else
            --gate:merge_into(block:copy():translate(-shift * xpitch, 0))
            gate:merge_into(block:copy())
        end
    end

    gate:inherit_alignment_box(harness)

    -- inverter B
    local invb = pcell.create_layout("stdcells/not_gate", "invb", { inputpos = "upper1" })
    invb:abut_left(gate)
    gate:merge_into(invb)
    gate:inherit_alignment_box(invb)

    -- inverter A
    local inva = pcell.create_layout("stdcells/not_gate", "inva", { inputpos = "lower1", shiftoutput = xpitch / 2 })
    inva:abut_left(invb)
    gate:merge_into(inva)
    gate:inherit_alignment_box(inva)

    -- output connection
    geometry.path(gate, generics.metal(1), geometry.path_points_xy(
        harness:get_area_anchor("pSD4").bl, {
            point.combine_12(harness:get_area_anchor("pSD4").bl, invb:get_area_anchor("OTRi")):translate(xpitch, _P.sdwidth / 2),
            harness:get_area_anchor("G6").bl:translate(xpitch, 0),
            0, -- toggle xy
            harness:get_area_anchor("nSD4").bl:translate(0, -_P.sdwidth / 2)
        }), _P.sdwidth)

    -- B
    geometry.path(gate, generics.metal(2), {
        point.combine_12(inva:get_anchor("I"), invb:get_anchor("I")),
        harness:get_area_anchor("G4").bl
        }, _P.sdwidth)
    -- not A
    geometry.path(gate, generics.metal(1), geometry.path_points_xy(
        point.combine_12(inva:get_anchor("O"), harness:get_area_anchor("G1").bl), {
            invb:get_anchor("I"):translate(xpitch, 0),
            harness:get_area_anchor("G2").bl:translate(0, -_P.sdwidth / 2),
        }), _P.sdwidth)
    geometry.path(gate, generics.metal(1), geometry.path_points_xy(
        invb:get_area_anchor("OT").Ri:translate(0, _P.sdwidth / 2), { 
            harness:get_area_anchor("G3").bl,
            0, -- toggle xy
            point.combine_12(harness:get_area_anchor("G2").bl, harness:get_area_anchor("G1").bl),
            invb:get_area_anchor("OB").Ri:translate(0, -_P.sdwidth / 2)
        }), _P.sdwidth)
    geometry.path(gate, generics.metal(2), {
        inva:get_anchor("I"),
        harness:get_area_anchor("G1").bl
    }, _P.sdwidth)
    geometry.path(gate, generics.metal(2), geometry.path_points_yx(
        point.combine_12(invb:get_anchor("O"), inva:get_anchor("I")), {
            -_P.routingwidth - _P.routingspace,
            harness:get_area_anchor("G6").bl
        }), _P.sdwidth)
    geometry.path(gate, generics.metal(2), {
        harness:get_area_anchor("G2").bl,
        harness:get_area_anchor("G5").bl,
        }, _P.sdwidth)

    -- M1 -> M2 vias
    geometry.viabltr(gate, 1, 2,
        point.combine_12(inva:get_anchor("I"), invb:get_anchor("I")):translate(-xpitch - _P.routingwidth / 2 - _P.routingspace, -_P.sdwidth / 2),
        point.combine_12(inva:get_anchor("I"), invb:get_anchor("I")):translate( xpitch + _P.routingwidth / 2 + _P.routingspace,  _P.sdwidth / 2)
    )
    geometry.viabltr(gate, 1, 2,
        inva:get_anchor("I"):translate(-xpitch - _P.routingwidth / 2 - _P.routingspace, -_P.sdwidth / 2),
        inva:get_anchor("I"):translate( xpitch + _P.routingwidth / 2 + _P.routingspace,  _P.sdwidth / 2)
    )
    geometry.viabltr(gate, 1, 2,
        invb:get_anchor("I"):translate(-xpitch - _P.routingwidth / 2 - _P.routingspace, -_P.sdwidth / 2),
        invb:get_anchor("I"):translate( xpitch + _P.routingwidth / 2 + _P.routingspace,  _P.sdwidth / 2)
    )

    geometry.viabltr(gate, 1, 2,
        harness:get_area_anchor("G1").bl:translate(-xpitch - math.max(_P.gatelength, _P.routingwidth) / 2 - _P.routingspace, -_P.sdwidth / 2),
        harness:get_area_anchor("G1").bl:translate( xpitch + _P.routingwidth / 2 + _P.routingspace, _P.sdwidth / 2)
    )
    geometry.viabltr(gate, 1, 2,
        harness:get_area_anchor("G2").bl:translate(-math.max(_P.gatelength, _P.routingwidth) / 2, -_P.sdwidth / 2),
        harness:get_area_anchor("G2").bl:translate( math.max(_P.gatelength, _P.routingwidth) / 2,  _P.sdwidth / 2)
    )

    geometry.viabltr(gate, 1, 2,
        harness:get_area_anchor("G6").bl:translate(-_P.routingwidth / 2, -_P.routingwidth / 2),
        point.combine_12(harness:get_area_anchor("G6").bl, harness:get_area_anchor("G4").bl):translate( _P.routingwidth / 2,  _P.routingwidth / 2)
    )
    geometry.viabltr(gate, 1, 2,
        harness:get_area_anchor("G5").bl:translate(-2 * xpitch + math.max(_P.gatelength, _P.routingwidth) / 2 + _P.routingspace, -_P.sdwidth / 2),
        harness:get_area_anchor("G5").bl:translate( 1 * xpitch - math.max(_P.gatelength, _P.routingwidth) / 2 - _P.routingspace,  _P.sdwidth / 2)
    )
    geometry.viabltr(gate, 1, 2,
        harness:get_area_anchor("G4").bl:translate(-1 * xpitch + math.max(_P.gatelength, _P.routingwidth) / 2 + _P.routingspace, -_P.sdwidth / 2),
        harness:get_area_anchor("G4").bl:translate( 2 * xpitch - math.max(_P.gatelength, _P.routingwidth) / 2 - _P.routingspace,  _P.sdwidth / 2)
    )

    gate:add_port_with_anchor("A", generics.metalport(1), inva:get_anchor("I"))
    gate:add_port_with_anchor("B", generics.metalport(1), point.combine_12(inva:get_anchor("I"), invb:get_anchor("I")))
    gate:add_port_with_anchor("O", generics.metalport(1), point.create(3 * xpitch + _P.shiftoutput, 0))
    gate:add_port("VDD", generics.metalport(1), harness:get_area_anchor("PRp").bl)
    gate:add_port("VSS", generics.metalport(1), harness:get_area_anchor("PRn").bl)
end

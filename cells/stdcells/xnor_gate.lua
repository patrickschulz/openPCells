
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
end

function layout(gate, _P)
    local bp = pcell.get_parameters("stdcells/base")
    local xpitch = bp.gspace + bp.glength

    local block = object.create_pseudo()

    local harness = pcell.create_layout("stdcells/harness", "mosfets", {
        drawgatecontacts = true,
        gatecontactpos = { "lower", "center", "center", "upper", "center", "lower" },
        pcontactpos = { "power", "outer", "outer", "outer", nil, "power", "power" },
        ncontactpos = { "power", "power", nil, "inner", "outer", "outer", "power" },
    })
    gate:merge_into(harness)

    -- gate contact metal blobs (DRC)
    geometry.rectanglebltr(block,generics.metal(1), 
        harness:get_area_anchor("G2").bl:translate(-bp.glength / 2, -bp.routingwidth / 2), 
        point.combine_12(harness:get_area_anchor("G2").bl, harness:get_area_anchor("G4").bl):translate(bp.glength / 2, bp.routingwidth / 2)
    )
    geometry.rectanglebltr(block, generics.metal(1), 
        point.combine_12(harness:get_area_anchor("G3").bl, harness:get_area_anchor("G2").bl):translate(-bp.glength / 2, -bp.routingwidth / 2),
        point.combine_12(harness:get_area_anchor("G3").bl, harness:get_area_anchor("G4").bl):translate( bp.glength / 2,  bp.routingwidth / 2)
    )

    -- short pmos
    geometry.rectanglebltr(block, generics.metal(1), 
        harness:get_area_anchor("pSD2").bl:translate(0, -bp.sdwidth / 2), 
        harness:get_area_anchor("pSD3").bl:translate(0,  bp.sdwidth / 2)
    )

    -- short nmos
    geometry.rectanglebltr(block, generics.metal(1), 
        harness:get_area_anchor("nSD5").bl:translate(0, -bp.sdwidth / 2), 
        harness:get_area_anchor("nSD6").bl:translate(0,  bp.sdwidth / 2)
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
    local invb = pcell.create_layout("stdcells/not_gate", "invb", { inputpos = "upper" })
    invb:align_left(gate)
    gate:merge_into(invb)
    gate:inherit_alignment_box(invb)

    -- inverter A
    pcell.push_overwrites("stdcells/base", { compact = false })
    local inva = pcell.create_layout("stdcells/not_gate", "inva", { inputpos = "lower", shiftoutput = xpitch / 2 })
    inva:align_left(invb)
    gate:merge_into(inva)
    gate:inherit_alignment_box(inva)
    pcell.pop_overwrites("stdcells/base")

    -- output connection
    geometry.path(gate, generics.metal(1), geometry.path_points_xy(
        harness:get_area_anchor("pSD4").bl, {
            point.combine_12(harness:get_area_anchor("pSD4").bl, invb:get_area_anchor("OTRi")):translate(xpitch, bp.sdwidth / 2),
            harness:get_area_anchor("G6").bl:translate(xpitch, 0),
            0, -- toggle xy
            harness:get_area_anchor("nSD4").bl:translate(0, -bp.sdwidth / 2)
        }), bp.sdwidth)

    -- B
    geometry.path(gate, generics.metal(2), {
        point.combine_12(inva:get_anchor("I"), invb:get_anchor("I")),
        harness:get_area_anchor("G4").bl
        }, bp.sdwidth)
    -- not A
    geometry.path(gate, generics.metal(1), geometry.path_points_xy(
        point.combine_12(inva:get_anchor("O"), harness:get_area_anchor("G1").bl), {
            invb:get_anchor("I"):translate(xpitch, 0),
            harness:get_area_anchor("G2").bl:translate(0, -bp.sdwidth / 2),
        }), bp.sdwidth)
    geometry.path(gate, generics.metal(1), geometry.path_points_xy(
        invb:get_area_anchor("OT").Ri:translate(0, bp.sdwidth / 2), { 
            harness:get_area_anchor("G3").bl,
            0, -- toggle xy
            point.combine_12(harness:get_area_anchor("G2").bl, harness:get_area_anchor("G1").bl),
            invb:get_area_anchor("OB").Ri:translate(0, -bp.sdwidth / 2)
        }), bp.sdwidth)
    geometry.path(gate, generics.metal(2), {
        inva:get_anchor("I"),
        harness:get_area_anchor("G1").bl
    }, bp.sdwidth)
    geometry.path(gate, generics.metal(2), geometry.path_points_yx(
        point.combine_12(invb:get_anchor("O"), inva:get_anchor("I")), {
            -bp.routingwidth - bp.routingspace,
            harness:get_area_anchor("G6").bl
        }), bp.sdwidth)
    geometry.path(gate, generics.metal(2), {
        harness:get_area_anchor("G2").bl,
        harness:get_area_anchor("G5").bl,
        }, bp.sdwidth)

    -- M1 -> M2 vias
    geometry.viabltr(gate, 1, 2,
        point.combine_12(inva:get_anchor("I"), invb:get_anchor("I")):translate(-xpitch - bp.routingwidth / 2 - bp.routingspace, -bp.sdwidth / 2),
        point.combine_12(inva:get_anchor("I"), invb:get_anchor("I")):translate( xpitch + bp.routingwidth / 2 + bp.routingspace,  bp.sdwidth / 2)
    )
    geometry.viabltr(gate, 1, 2,
        inva:get_anchor("I"):translate(-xpitch - bp.routingwidth / 2 - bp.routingspace, -bp.sdwidth / 2),
        inva:get_anchor("I"):translate( xpitch + bp.routingwidth / 2 + bp.routingspace,  bp.sdwidth / 2)
    )
    geometry.viabltr(gate, 1, 2,
        invb:get_anchor("I"):translate(-xpitch - bp.routingwidth / 2 - bp.routingspace, -bp.sdwidth / 2),
        invb:get_anchor("I"):translate( xpitch + bp.routingwidth / 2 + bp.routingspace,  bp.sdwidth / 2)
    )

    geometry.viabltr(gate, 1, 2,
        harness:get_area_anchor("G1").bl:translate(-xpitch - math.max(bp.glength, bp.routingwidth) / 2 - bp.routingspace, -bp.sdwidth / 2),
        harness:get_area_anchor("G1").bl:translate( xpitch + bp.routingwidth / 2 + bp.routingspace, bp.sdwidth / 2)
    )
    geometry.viabltr(gate, 1, 2,
        harness:get_area_anchor("G2").bl:translate(-math.max(bp.glength, bp.routingwidth) / 2, -bp.sdwidth / 2),
        harness:get_area_anchor("G2").bl:translate( math.max(bp.glength, bp.routingwidth) / 2,  bp.sdwidth / 2)
    )

    geometry.viabltr(gate, 1, 2,
        harness:get_area_anchor("G6").bl:translate(-bp.routingwidth / 2, -bp.routingwidth / 2),
        point.combine_12(harness:get_area_anchor("G6").bl, harness:get_area_anchor("G4").bl):translate( bp.routingwidth / 2,  bp.routingwidth / 2)
    )
    geometry.viabltr(gate, 1, 2,
        harness:get_area_anchor("G5").bl:translate(-2 * xpitch + math.max(bp.glength, bp.routingwidth) / 2 + bp.routingspace, -bp.sdwidth / 2),
        harness:get_area_anchor("G5").bl:translate( 1 * xpitch - math.max(bp.glength, bp.routingwidth) / 2 - bp.routingspace,  bp.sdwidth / 2)
    )
    geometry.viabltr(gate, 1, 2,
        harness:get_area_anchor("G4").bl:translate(-1 * xpitch + math.max(bp.glength, bp.routingwidth) / 2 + bp.routingspace, -bp.sdwidth / 2),
        harness:get_area_anchor("G4").bl:translate( 2 * xpitch - math.max(bp.glength, bp.routingwidth) / 2 - bp.routingspace,  bp.sdwidth / 2)
    )

    gate:add_port("A", generics.metalport(1), inva:get_anchor("I"))
    gate:add_port("B", generics.metalport(1), point.combine_12(inva:get_anchor("I"), invb:get_anchor("I")))
    gate:add_port("O", generics.metalport(1), point.create(3 * xpitch + _P.shiftoutput, 0))
    gate:add_port("VDD", generics.metalport(1), harness:get_area_anchor("PRp").bl)
    gate:add_port("VSS", generics.metalport(1), harness:get_area_anchor("PRn").bl)
end

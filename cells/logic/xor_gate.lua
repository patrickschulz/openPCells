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
    pcell.reference_cell("logic/base")
    pcell.add_parameter("fingers", 1, { posvals = set(1) })
    pcell.add_parameter("shiftoutput", 0)
end

function layout(gate, _P)
    local bp = pcell.get_parameters("logic/base")
    local xpitch = bp.gspace + bp.glength
    local routingshift = bp.sdwidth / 2 + (bp.separation - 2 * bp.sdwidth) / 6

    local block = object.create()

    pcell.push_overwrites("logic/base", { leftdummies = 0 })
    local harness = pcell.create_layout("logic/harness", { 
        fingers = 6 * _P.fingers, 
        drawgatecontacts = false,
        pcontactpos = { "power", "outer", "outer", "inner", nil, "power", "power" },
        ncontactpos = { "power", "power", nil, "inner", "outer", "outer", "power" }
    })
    gate:merge_into(harness)
    pcell.pop_overwrites("logic/base")

    -- gate contacts
    block:merge_into(geometry.rectangle(generics.contact("gate"), bp.glength, bp.gstwidth):translate(-5 * xpitch / 2, -routingshift))
    block:merge_into(geometry.rectangle(generics.contact("gate"), bp.glength, bp.gstwidth):translate(-3 * xpitch / 2, -routingshift))
    block:merge_into(geometry.rectangle(generics.contact("gate"), bp.glength, bp.gstwidth):translate(-xpitch / 2, 0))
    block:merge_into(geometry.rectangle(generics.metal(1), bp.glength, 2 * routingshift + bp.sdwidth):translate(-xpitch / 2, 0))
    block:merge_into(geometry.rectangle(generics.contact("gate"), bp.glength, bp.gstwidth):translate( xpitch / 2,  routingshift))
    block:merge_into(geometry.rectangle(generics.metal(1), bp.glength, 2 * routingshift + bp.sdwidth):translate(-3 * xpitch / 2, 0))
    block:merge_into(geometry.rectangle(generics.contact("gate"), bp.glength, bp.gstwidth):translate( 3 * xpitch / 2, -routingshift))
    block:merge_into(geometry.rectangle(generics.contact("gate"), bp.glength, bp.gstwidth):translate( 5 * xpitch / 2, -routingshift))

    -- short pmos
    block:merge_into(geometry.rectangle(generics.metal(1), xpitch, bp.sdwidth):translate(-3 * xpitch / 2, bp.separation / 2 + 3 * bp.pwidth / 4))

    -- short nmos
    block:merge_into(geometry.rectangle(generics.metal(1), xpitch, bp.sdwidth):translate(3 * xpitch / 2, -bp.separation / 2 - 3 * bp.nwidth / 4))

    -- output connection
    block:merge_into(geometry.path(generics.metal(1), {
        point.create(0, bp.separation / 2 + bp.sdwidth / 2),
        point.create(3 * xpitch + _P.shiftoutput, bp.separation / 2 + bp.sdwidth / 2),
        point.create(3 * xpitch + _P.shiftoutput, -bp.separation / 2 - bp.sdwidth / 2),
        point.create(0, -bp.separation / 2 - bp.sdwidth / 2),
    }, bp.sdwidth))

    -- place block
    for i = 1, _P.fingers do
        local shift = 4 * (i - 1) - (_P.fingers - 1)
        if i % 2 == 0 then
            gate:merge_into(block:copy():flipx():translate(-shift * xpitch, 0))
        else
            gate:merge_into(block:copy():translate(-shift * xpitch, 0))
        end
    end

    gate:inherit_alignment_box(harness)

    -- inverter A
    pcell.push_overwrites("logic/base", { leftdummies = 0, rightdummies = 1, connectoutput = false })
    local invb = pcell.create_layout("logic/not_gate", { shiftinput = routingshift })
    invb:move_anchor("right", gate:get_anchor("left"))
    gate:merge_into_update_alignmentbox(invb)
    pcell.pop_overwrites("logic/base")

    -- inverter B
    pcell.push_overwrites("logic/base", { rightdummies = 1, compact = false })
    local inva = pcell.create_layout("logic/not_gate", { shiftinput = -routingshift, shiftoutput = xpitch / 2 })
    inva:move_anchor("right", invb:get_anchor("left"))
    gate:merge_into_update_alignmentbox(inva)
    pcell.pop_overwrites("logic/base")

    -- B
    gate:merge_into(geometry.path(generics.metal(2), geometry.path_points_xy(
        point.combine_12(inva:get_anchor("I"), invb:get_anchor("I")),
        { point.create(xpitch / 2, routingshift) }
        ), bp.sdwidth))
    -- not A
    gate:merge_into(geometry.path(generics.metal(1), geometry.path_points_xy(
        inva:get_anchor("O"):translate(0, -routingshift), { 
            2 * xpitch, 
            point.create(-3 * xpitch / 2 - bp.glength / 2 + bp.sdwidth / 2, routingshift), 
            -2 * routingshift - bp.sdwidth / 2
        }), bp.sdwidth))
    gate:merge_into(geometry.path(generics.metal(1), geometry.path_points_xy(
        invb:get_anchor("OTR"), { 
            point.create(-xpitch / 2 - bp.glength / 2 + bp.sdwidth / 2, routingshift), 
            0, -- toggle xy
            invb:get_anchor("OBR") 
        }), bp.sdwidth))
    gate:merge_into(geometry.path(generics.metal(2), geometry.path_points_xy(
        inva:get_anchor("I"), { 
            point.create(-5 * xpitch / 2, -routingshift), 
        }), bp.sdwidth))
    gate:merge_into(geometry.path(generics.metal(2), geometry.path_points_yx(
        point.create(-4 * xpitch, -routingshift + bp.sdwidth / 2), {
            -bp.separation / 2 + routingshift - bp.sdwidth,
            point.create(5 * xpitch / 2, routingshift + bp.sdwidth / 2) 
        }), bp.sdwidth))
    gate:merge_into(geometry.path(generics.metal(2), {
        point.create(-3 * xpitch / 2, -routingshift),
        point.create( 3 * xpitch / 2, -routingshift),
        }, bp.sdwidth))

    ---- M1 -> M2 vias
    gate:merge_into(geometry.rectangle(generics.via(1, 2), xpitch, bp.sdwidth)
        :translate(point.combine_12(inva:get_anchor("I"), invb:get_anchor("I"))))
    gate:merge_into(geometry.rectangle(generics.via(1, 2), xpitch, bp.sdwidth)
        :translate(inva:get_anchor("I")))
    gate:merge_into(geometry.rectangle(generics.via(1, 2), xpitch, bp.sdwidth)
        :translate(invb:get_anchor("I")))

    gate:merge_into(geometry.rectangle(generics.via(1, 2), xpitch, bp.sdwidth)
        :translate(-5 * xpitch / 2, -routingshift))
    gate:merge_into(geometry.rectangle(generics.via(1, 2), bp.glength, bp.sdwidth)
        :translate(-3 * xpitch / 2, -routingshift))

    gate:merge_into(geometry.rectangle(generics.via(1, 2), math.max(bp.glength, bp.sdwidth), 2 * routingshift + bp.sdwidth)
        :translate(5 * xpitch / 2, 0))
    gate:merge_into(geometry.rectangle(generics.via(1, 2), 2 * bp.glength + bp.gspace, bp.sdwidth)
        :translate(xpitch, -routingshift))
    gate:merge_into(geometry.rectangle(generics.via(1, 2), 2 * bp.glength + bp.gspace, bp.sdwidth)
        :translate(xpitch, routingshift))

    gate:add_port("A", generics.metal(1), inva:get_anchor("I"))
    gate:add_port("B", generics.metal(1), point.combine_12(inva:get_anchor("I"), invb:get_anchor("I")))
    gate:add_port("Z", generics.metal(1), point.create(3 * xpitch + _P.shiftoutput, 0))
    gate:add_port("VDD", generics.metal(1), point.create(-2 * xpitch, bp.separation / 2 + bp.pwidth + bp.powerspace + bp.powerwidth / 2))
    gate:add_port("VSS", generics.metal(1), point.create(-2 * xpitch, -bp.separation / 2 - bp.nwidth - bp.powerspace - bp.powerwidth / 2))
    
    -- center cell
    gate:translate(2 * xpitch, 0)
end

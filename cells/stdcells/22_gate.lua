--[[
    A1 ---- GATE1
            GATE1
    A2 ---- GATE1 ---- GATE3 
                       GATE3 ---- O
    B1 ---- GATE2 ---- GATE3
            GATE2
    B2 ---- GATE2
--]]

function parameters() 
    pcell.add_parameters(
        { "flipconnection", false },
        { "gate1", "and_gate" },
        { "gate2", "and_gate" },
        { "gate3", "nor_gate" }
    )
end

function layout(gate, _P)
    local bp = pcell.get_parameters("stdcells/base");
    local separation = bp.numinnerroutes * bp.routingwidth + (bp.numinnerroutes + 1) * bp.routingspace

    -- isolation dummy
    local isogateref = pcell.create_layout("stdcells/isogate", "isogate")

    -- gate 1
    local gate1ref = pcell.create_layout(string.format("stdcells/%s", _P.gate1), "gate1")
    local gate1 = gate:add_child(gate1ref, "gate1")

    local isogate1 = gate:add_child(isogateref, "isogate1")
    isogate1:abut_right(gate1)

    -- gate 2
    local gate2ref = pcell.create_layout(string.format("stdcells/%s", _P.gate2), "gate2")
    local gate2 = gate:add_child(gate2ref, "gate2")
    gate2:abut_right(isogate1)

    local isogate2 = gate:add_child(isogateref, "isogate2")
    isogate2:abut_right(gate2)

    -- gate 3
    local gate3ref = pcell.create_layout(string.format("stdcells/%s", _P.gate3), "gate3")
    local gate3 = gate:add_child(gate3ref, "gate3")
    gate3:abut_right(isogate2)

    -- draw connections
    geometry.path(gate, generics.metal(2), 
        geometry.path_points_yx(gate1:get_anchor("O"), {
            gate1:get_anchor("O"):translate(0, (_P.flipconnection and -1 or 1) * (separation / 2 + bp.sdwidth / 2)),
            0, -- toggle xy
            gate3:get_anchor("B")
    }), bp.sdwidth)
    geometry.viabltr(
        gate, 1, 2, 
        gate1:get_anchor("O"):translate(-bp.sdwidth / 2, -bp.sdwidth / 2),
        gate1:get_anchor("O"):translate( bp.sdwidth / 2,  bp.sdwidth / 2)
    )
    geometry.viabltr(
        gate, 1, 2, 
        gate3:get_anchor("B"):translate(-bp.sdwidth / 2, -bp.sdwidth / 2),
        gate3:get_anchor("B"):translate( bp.sdwidth / 2,  bp.sdwidth / 2)
    )

    geometry.path(gate, generics.metal(1), 
        geometry.path_points_yx(gate2:get_anchor("O"), {
        gate3:get_anchor("A")
    }), bp.sdwidth)

    -- alignmentbox
    gate:inherit_alignment_box(gate1)
    gate:inherit_alignment_box(gate3)

    -- draw ports
    gate:add_port("A1", generics.metalport(1), gate1:get_anchor("A"))
    gate:add_port("A2", generics.metalport(1), gate1:get_anchor("B"))
    gate:add_port("B1", generics.metalport(1), gate2:get_anchor("A"))
    gate:add_port("B2", generics.metalport(1), gate2:get_anchor("B"))
    gate:add_port("O", generics.metalport(1), gate3:get_anchor("O"))
    gate:add_port("VDD", generics.metalport(1), isogate1:get_anchor("VDD"))
    gate:add_port("VSS", generics.metalport(1), isogate1:get_anchor("VSS"))
end

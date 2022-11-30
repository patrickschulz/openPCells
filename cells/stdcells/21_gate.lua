--[[ 
A  --------------- GATE2
                   GATE2 ---- O
B2 ----- GATE1 --- GATE2
         GATE1
B1 ----- GATE1
]]
function parameters() 
    pcell.add_parameters(
        { "gate1", "nand_gate" },
        { "gate2", "nor_gate" }
    )
end

function layout(gate, _P)
    local bp = pcell.get_parameters("stdcells/base");

    local gate1ref = pcell.create_layout(string.format("stdcells/%s", _P.gate1), "gate1")
    local gate1 = gate:add_child(gate1ref, "gate1")

    local gate2ref = pcell.create_layout(string.format("stdcells/%s", _P.gate2), "gate2")
    local gate2 = gate:add_child(gate2ref, "gate2")
    gate2:move_anchor("left", gate1:get_anchor("right"))

    gate:inherit_alignment_box(gate1)
    gate:inherit_alignment_box(gate2)

    -- draw connections
    geometry.path(gate, generics.metal(1), 
        geometry.path_points_yx(gate1:get_anchor("O"), {
        gate2:get_anchor("B")
        }), 
    bp.sdwidth)

    --draw ports
    gate:add_port("A", generics.metalport(1), gate2:get_anchor("A"))
    gate:add_port("B1", generics.metalport(1), gate1:get_anchor("A"))
    gate:add_port("B2", generics.metalport(1), gate1:get_anchor("B"))
    gate:add_port("O", generics.metalport(1), gate2:get_anchor("O"))
    gate:add_port("VDD", generics.metalport(1), gate1:get_anchor("VDD"))
    gate:add_port("VSS", generics.metalport(1), gate1:get_anchor("VSS"))
end

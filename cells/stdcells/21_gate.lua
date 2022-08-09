--[[ 
A  --------------- GATE2
                   GATE2 ---- O
B2 ----- GATE1 --- GATE2
         GATE1
B1 ----- GATE1
]]
function parameters() 
    pcell.reference_cell("stdcells/base") 
    pcell.reference_cell("stdcells/harness") 
    pcell.add_parameters(
        { "gate1", "nand_gate" },
        { "gate2", "nor_gate" }
    )
end

function layout(gate, _P)
    local bp = pcell.get_parameters("stdcells/base");

    local isogateref = pcell.create_layout("stdcells/isogate")
    local isogatename = pcell.add_cell_reference(isogateref, "isogate")
    local isogate = gate:add_child(isogatename)

    local gate1ref = pcell.create_layout(string.format("stdcells/%s", _P.gate1))
    local gate1name = pcell.add_cell_reference(gate1ref, "gate1")
    local gate1 = gate:add_child(gate1name)
    gate1:move_anchor("right", isogate:get_anchor("left"))

    local gate2ref = pcell.create_layout(string.format("stdcells/%s", _P.gate2))
    local gate2name = pcell.add_cell_reference(gate2ref, "gate2")
    local gate2 = gate:add_child(gate2name)
    gate2:move_anchor("left", isogate:get_anchor("right"))

    gate:inherit_alignment_box(gate1)
    gate:inherit_alignment_box(gate2)

    -- draw connections
    geometry.path(gate, generics.metal(1), 
        geometry.path_points_yx(gate1:get_anchor("O"), {
        gate2:get_anchor("B")
        }), 
    bp.sdwidth)

    --draw ports
    gate:add_port("A", generics.metal(1), gate2:get_anchor("A"))
    gate:add_port("B1", generics.metal(1), gate1:get_anchor("A"))
    gate:add_port("B2", generics.metal(1), gate1:get_anchor("B"))
    gate:add_port("O", generics.metal(1), gate2:get_anchor("O"))
    gate:add_port("VDD", generics.metal(1), isogate:get_anchor("VDD"))
    gate:add_port("VSS", generics.metal(1), isogate:get_anchor("VSS"))
end

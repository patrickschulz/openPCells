--[[ 
A  --------------- GATE2
                   GATE2 ---- Z
B2 ----- GATE1 --- GATE2
         GATE1
B1 ----- GATE1
]]
function parameters() 
    pcell.reference_cell("logic/base") 
    pcell.add_parameters(
        { "gate1", "nand_gate" },
        { "gate2", "nor_gate" }
    )
end

function layout(gate, _P)
    local bp = pcell.get_parameters("logic/base");

    local isogate = pcell.create_layout("logic/isogate")
    gate:merge_into_update_alignmentbox(isogate)

    pcell.push_overwrites("logic/base", { rightdummies = 0 })
    local gate1 = pcell.create_layout(string.format("logic/%s", _P.gate1)):move_anchor("right", isogate:get_anchor("left"))
    gate:merge_into_update_alignmentbox(gate1)
    pcell.pop_overwrites("logic/base")

    pcell.push_overwrites("logic/base", { leftdummies = 0 })
    local gate2 = pcell.create_layout(string.format("logic/%s", _P.gate2)):move_anchor("left", isogate:get_anchor("right"))
    gate:merge_into_update_alignmentbox(gate2)
    pcell.pop_overwrites("logic/base")

    -- draw connections
    gate:merge_into(geometry.path_yx(generics.metal(1), {
        gate1:get_anchor("Z"), gate2:get_anchor("B")
    }, bp.sdwidth))

    --draw ports
    gate:add_port("A", generics.metal(1), gate2:get_anchor("A"))
    gate:add_port("B1", generics.metal(1), gate1:get_anchor("A"))
    gate:add_port("B2", generics.metal(1), gate1:get_anchor("B"))
    gate:add_port("Z", generics.metal(1), gate2:get_anchor("Z"))
    gate:add_port("VDD", generics.metal(1), isogate:get_anchor("VDD"))
    gate:add_port("VSS", generics.metal(1), isogate:get_anchor("VSS"))
end

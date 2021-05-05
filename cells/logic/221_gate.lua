--[[
        C1 ---- GATE1 
                GATE1 
        C2 ---- GATE1 ---- GATE3
                           GATE3 ---- GATE4
        A  --------------- GATE3      GATE4
                                      GATE4 ---- Z
        B1 ---- GATE2                 GATE4
                GATE2 --------------- GATE4
        B2 ---- GATE2
]] -- 
function parameters() 
    pcell.reference_cell("logic/base") 
    pcell.add_parameter("flipconnection", false)
    pcell.add_parameters(
        { "gate1", "or_gate" },
        { "gate2", "and_gate" },
        { "gate3", "or_gate" },
        { "gate4", "nand_gate" }
    )
end

function layout(gate, _P)
    local bp = pcell.get_parameters("logic/base");
    local separation = bp.numinnerroutes * bp.gstwidth + (bp.numinnerroutes + 1) * bp.gstspace

    -- gate 1
    pcell.push_overwrites("logic/base", { rightdummies = 0 })
    local gate1 = pcell.create_layout(string.format("logic/%s", _P.gate1))
    gate:merge_into_update_alignmentbox(gate1)
    pcell.pop_overwrites("logic/base")

    local isogate = pcell.create_layout("logic/isogate")
    isogate:move_anchor("left", gate1:get_anchor("right"))
    gate:merge_into(isogate:copy())

    -- gate 3
    pcell.push_overwrites("logic/base", { leftdummies = 0, rightdummies = 0 })
    local gate3 = pcell.create_layout(string.format("logic/%s", _P.gate3)):move_anchor("left", isogate:get_anchor("right"))
    gate:merge_into_update_alignmentbox(gate3)
    pcell.pop_overwrites("logic/base")

    isogate:move_anchor("left", gate3:get_anchor("right"))
    gate:merge_into(isogate:copy())

    -- gate 2
    pcell.push_overwrites("logic/base", {leftdummies = 0, rightdummies = 0})
    local gate2 = pcell.create_layout(string.format("logic/%s", _P.gate2)):move_anchor("left", isogate:get_anchor("right"))
    gate:merge_into_update_alignmentbox(gate2)
    pcell.pop_overwrites("logic/base")

    isogate:move_anchor("left", gate2:get_anchor("right"))
    gate:merge_into(isogate:copy())

    -- gate 4
    pcell.push_overwrites("logic/base", { leftdummies = 0 })
    local gate4 = pcell.create_layout(string.format("logic/%s", _P.gate4)):move_anchor("left", isogate:get_anchor("right"))
    gate:merge_into_update_alignmentbox(gate4)
    pcell.pop_overwrites("logic/base")

    -- draw connections
    gate:merge_into(geometry.path_yx(generics.metal(1), {
        gate1:get_anchor("Z"), gate3:get_anchor("B")
    }, bp.sdwidth))
    gate:merge_into(geometry.path_yx(generics.metal(1), {
        gate2:get_anchor("Z"), gate4:get_anchor("B")
    }, bp.sdwidth))
    gate:merge_into(geometry.path(generics.metal(2), 
        geometry.path_points_yx(gate3:get_anchor("Z"), {
            (_P.flipconnection and -1 or 1) * (separation / 2 + bp.sdwidth / 2),
            gate4:get_anchor("A")
    }), bp.sdwidth))
    gate:merge_into(geometry.rectangle(generics.via(1, 2), bp.sdwidth, bp.sdwidth):translate( gate3:get_anchor("Z")))
    gate:merge_into(geometry.rectangle(generics.via(1, 2), bp.sdwidth, bp.sdwidth):translate( gate4:get_anchor("A")))

    -- ports
    gate:add_port("A", generics.metal(1), gate3:get_anchor("A"))
    gate:add_port("B1", generics.metal(1), gate2:get_anchor("A"))
    gate:add_port("B2", generics.metal(1), gate2:get_anchor("B"))
    gate:add_port("C1", generics.metal(1), gate1:get_anchor("A"))
    gate:add_port("C2", generics.metal(1), gate1:get_anchor("B"))
    gate:add_port("Z", generics.metal(1), gate4:get_anchor("Z"))
    gate:add_port("VDD", generics.metal(1), isogate:get_anchor("VDD"))
    gate:add_port("VSS", generics.metal(1), isogate:get_anchor("VSS"))
end

--[[ 
CO = A & B
S = A XOR B
--]]
function parameters()
    pcell.reference_cell("logic/base")
end

function layout(gate, _P)
    local bp = pcell.get_parameters("logic/base");

    local xpitch = bp.gspace + bp.glength

    andgate = pcell.create_layout("logic/and_gate")
    gate:merge_into_update_alignmentbox(andgate)

    xorgate = pcell.create_layout("logic/xor_gate"):move_anchor("left", andgate:get_anchor("right"))
    gate:merge_into_update_alignmentbox(xorgate)

    gate:merge_into(geometry.path(generics.metal(2), {
        andgate:get_anchor("B"), xorgate:get_anchor("B")
    }, bp.sdwidth))
    gate:merge_into(geometry.rectangle(generics.via(1, 2), bp.sdwidth, bp.sdwidth):translate(andgate:get_anchor("A")))

    gate:merge_into(geometry.path_xy(generics.metal(2), {
        andgate:get_anchor("A"), xorgate:get_anchor("A")
    }, bp.sdwidth))
    gate:merge_into(geometry.rectangle(generics.via(1, 2), bp.sdwidth, bp.sdwidth):translate(andgate:get_anchor("B")))
    gate:merge_into(geometry.rectangle(generics.via(1, 2), bp.sdwidth, bp.sdwidth):translate(xorgate:get_anchor("B")))

    --[[
    gate:add_port("A", generics.metal(1), andgate:get_anchor("A"))
    gate:add_port("B", generics.metal(1), andgate:get_anchor("B"))
    gate:add_port("COUT", generics.metal(1), andgate:get_anchor("Z"))
    gate:add_port("S", generics.metal(1), xorgate:get_anchor("Z"))
    --]]
end

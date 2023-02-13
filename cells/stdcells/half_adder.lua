--[[ 
CO = A & B
S = A XOR B
--]]
function layout(gate, _P)
    local bp = pcell.get_parameters("stdcells/base");

    local andgate = pcell.create_layout("stdcells/and_gate", "and_gate")
    gate:merge_into(andgate)
    gate:inherit_alignment_box(andgate)

    local isogate = pcell.create_layout("stdcells/isogate", "isogate")
    isogate:align_right(andgate)
    gate:merge_into(isogate:copy())

    local xorgate = pcell.create_layout("stdcells/xor_gate", "xorgate")
    xorgate:align_right(isogate)
    gate:merge_into(xorgate)
    gate:inherit_alignment_box(xorgate)

    geometry.path(gate, generics.metal(2), 
        geometry.path_points_xy(andgate:get_anchor("A"), {
        xorgate:get_anchor("A")
    }), bp.sdwidth)
    geometry.viabltr(gate, 1, 2, 
        andgate:get_anchor("A"):translate(-bp.sdwidth / 2, -bp.sdwidth / 2),
        andgate:get_anchor("A"):translate( bp.sdwidth / 2,  bp.sdwidth / 2)
    )

    geometry.path(gate, generics.metal(2), {
        andgate:get_anchor("B"), xorgate:get_anchor("B")
    }, bp.sdwidth)
    geometry.viabltr(gate, 1, 2, 
        andgate:get_anchor("B"):translate(-bp.sdwidth / 2, -bp.sdwidth / 2),
        andgate:get_anchor("B"):translate( bp.sdwidth / 2,  bp.sdwidth / 2)
    )

    gate:add_port("A", generics.metalport(1), andgate:get_anchor("A"))
    gate:add_port("B", generics.metalport(1), andgate:get_anchor("B"))
    gate:add_port("COUT", generics.metalport(1), andgate:get_anchor("O"))
    gate:add_port("S", generics.metalport(1), xorgate:get_anchor("O"))
end

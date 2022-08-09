--[[ 
CO = A & B
S = A XOR B
--]]
function parameters()
    pcell.reference_cell("stdcells/base")
    pcell.reference_cell("stdcells/harness")
end

function layout(gate, _P)
    local bp = pcell.get_parameters("stdcells/base");

    local andgate = pcell.create_layout("stdcells/and_gate")
    gate:merge_into_shallow(andgate)
    gate:inherit_alignment_box(andgate)

    local isogate = pcell.create_layout("stdcells/isogate")
    isogate:move_anchor("left", andgate:get_anchor("right"))
    gate:merge_into_shallow(isogate:copy())

    local xorgate = pcell.create_layout("stdcells/xor_gate"):move_anchor("left", isogate:get_anchor("right"))
    gate:merge_into_shallow(xorgate)
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

    gate:add_port("A", generics.metal(1), andgate:get_anchor("A"))
    gate:add_port("B", generics.metal(1), andgate:get_anchor("B"))
    gate:add_port("COUT", generics.metal(1), andgate:get_anchor("O"))
    gate:add_port("S", generics.metal(1), xorgate:get_anchor("O"))
end

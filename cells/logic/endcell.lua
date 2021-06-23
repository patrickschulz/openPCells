function parameters()
    pcell.reference_cell("logic/base")
end

function layout(cell, _P)
    local bp = pcell.get_parameters("logic/base")
    local xpitch = bp.gspace + bp.glength
    local separation = bp.numinnerroutes * bp.gstwidth + (bp.numinnerroutes + 1) * bp.gstspace

    cell:merge_into_shallow(geometry.multiple_x(
        geometry.rectangle(generics.other("gate"), bp.glength, separation + bp.pwidth + bp.nwidth),
        5, xpitch
    ))
end

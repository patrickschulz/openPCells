function layout(cell, _P)
    local bp = pcell.get_parameters("stdcells/base")
    local xpitch = bp.gatespace + bp.gatelength
    local separation = bp.numinnerroutes * bp.routingwidth + (bp.numinnerroutes + 1) * bp.routingspace

    --geometry.rectangle(cell, generics.other("gate"), bp.gatelength, separation + bp.pwidth + bp.nwidth, 0, 0, 5, 1, xpitch, 0)
end

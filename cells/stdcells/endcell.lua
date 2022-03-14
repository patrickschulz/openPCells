function parameters()
    pcell.reference_cell("stdcells/base")
end

function layout(cell, _P)
    local bp = pcell.get_parameters("stdcells/base")
    local xpitch = bp.gspace + bp.glength
    local separation = bp.numinnerroutes * bp.gstwidth + (bp.numinnerroutes + 1) * bp.gstspace

    geometry.multiple_x(
        function(x)
            geometry.rectangle(cell, generics.other("gate"), bp.glength, separation + bp.pwidth + bp.nwidth, x, 0)
        end,
        5, xpitch
    )
end

function parameters()
    pcell.add_parameters(
        { "numbits", 8 },
        { "numregs", 8 },
        { "nummerge", 2 },
        { "hmetal", 1 },
        { "hwidth", technology.get_dimension("Minimum M1 Width") },
        { "hspace", technology.get_dimension("Minimum M1 Space") },
        { "vmetal", 2 },
        { "vwidth", technology.get_dimension("Minimum M2 Width") },
        { "vspace", technology.get_dimension("Minimum M2 Space") },
        { "viaext", 200 }
    )
end

function layout(bus, _P)
    -- vertical lines
    for merge = 1, _P.nummerge do
        local mergexshift = (merge - 1) * _P.numregs * _P.numbits * (_P.vwidth + _P.vspace)
        local mergeyshift = (merge - 1) * (_P.vwidth + _P.vspace)
        for reg = 1, _P.numregs do
            local regxshift = (reg - 1) * _P.numbits * (_P.vwidth + _P.vspace)
            local regyshift = _P.nummerge * (reg - 1) * _P.numbits * (_P.vwidth + _P.vspace)
            for bit = 1, _P.numbits do
                local bitxshift = (bit - 1) * (_P.vwidth + _P.vspace)
                local bityshift = _P.nummerge * (bit - 1) * (_P.vwidth + _P.vspace)
                local xshift = mergexshift + regxshift + bitxshift
                local yshift = mergeyshift + regyshift + bityshift
                geometry.rectanglebltr(bus, generics.metal(_P.vmetal),
                    point.create(xshift, -2000),
                    point.create(xshift + _P.vwidth, yshift + _P.vwidth)
                )
            end
        end
    end
    -- horizontal lines
    for merge = 1, _P.nummerge do
        local mergexshift = (merge - 1) * _P.numregs * _P.numbits * (_P.vwidth + _P.vspace)
        local mergeyshift = (merge - 1) * (_P.vwidth + _P.vspace)
        for reg = 1, _P.numregs do
            local regxshift = (reg - 1) * _P.numbits * (_P.hwidth + _P.hspace)
            local regyshift = _P.nummerge * (reg - 1) * _P.numbits * (_P.hwidth + _P.hspace)
            for bit = 1, _P.numbits do
                local bitxshift = (bit - 1) * (_P.hwidth + _P.hspace)
                local bityshift = _P.nummerge * (bit - 1) * (_P.hwidth + _P.hspace)
                local xshift = mergexshift + regxshift + bitxshift
                local yshift = mergeyshift + regyshift + bityshift
                geometry.rectanglebltr(bus, generics.metal(_P.hmetal),
                    point.create(-2000, yshift),
                    point.create(xshift + _P.hwidth, yshift + _P.hwidth)
                )
            end
        end
    end

    -- vias
    for merge = 1, _P.nummerge do
        local mergexshift = (merge - 1) * _P.numregs * _P.numbits * (_P.vwidth + _P.vspace)
        local mergeyshift = (merge - 1) * (_P.vwidth + _P.vspace)
        for reg = 1, _P.numregs do
            local regxshift = (reg - 1) * _P.numbits * (_P.hwidth + _P.hspace)
            local regyshift = _P.nummerge * (reg - 1) * _P.numbits * (_P.hwidth + _P.hspace)
            for bit = 1, _P.numbits do
                local bitxshift = (bit - 1) * (_P.hwidth + _P.hspace)
                local bityshift = _P.nummerge * (bit - 1) * (_P.hwidth + _P.hspace)
                local xshift = mergexshift + regxshift + bitxshift
                local yshift = mergeyshift + regyshift + bityshift
                local viaxext = 0
                local viayext = 0
                if merge <= _P.nummerge / 2 then
                    viaxext = 2 * _P.viaext
                else
                    viayext = 2 * _P.viaext
                end
                geometry.viabltr(bus, _P.vmetal, _P.hmetal,
                    point.create(xshift - viaxext, yshift - viayext),
                    point.create(xshift + _P.hwidth, yshift + _P.hwidth)
                )
            end
        end
    end
end

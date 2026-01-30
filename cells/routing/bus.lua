function parameters()
    pcell.add_parameters(
        { "numbits", 8 },
        { "numregs", 8 },
        { "nummerge", 1 },
        { "invert", false },
        { "expand_all", false },
        { "vregshift", 0 },
        { "hregshift", 0 },
        { "hmetal", 1 },
        { "hwidth", technology.get_dimension("Minimum M1 Width") },
        { "hspace", technology.get_dimension("Minimum M1 Space") },
        { "hext", 0 },
        { "hposition", "right", posvals = set("left", "right") },
        { "vmetal", 2 },
        { "vwidth", technology.get_dimension("Minimum M2 Width") },
        { "vspace", technology.get_dimension("Minimum M2 Space") },
        { "vext", 0 },
        { "vposition", "top", posvals = set("bottom", "top") },
        { "viamode", "horizontal", posvals = set("horizontal", "vertical") },
        { "viaext", technology.get_dimension_max("Minimum M1 Width", "Minimum M2 Width") },
        { "shift_bus_for_vias", true }
    )
end

function process_parameters(_P)
    local t = {}
    local maxmetal = math.max(_P.hmetal, _P.vmetal)

    technology.get_dimension(
    t.hwidth = technology.get_dimension_max(
        string.format("Minimum M%d Width", _P.hmetal),
        string.format("Minimum M%dM%d Viawidth", maxmetal - 1, maxmetal)
    )
    t.hspace = technology.get_dimension(string.format("Minimum M%d Space", _P.hmetal))
    t.vwidth = technology.get_dimension_max(
        string.format("Minimum M%d Width", _P.vmetal),
        string.format("Minimum M%dM%d Viawidth", maxmetal - 1, maxmetal)
    )
    t.vspace = technology.get_dimension(string.format("Minimum M%d Space", _P.vmetal))
    t.viaext = technology.get_dimension_max(
        string.format("Minimum M%d Width", _P.hmetal),
        string.format("Minimum M%d Width", _P.vmetal),
        string.format("Minimum M%dM%d Viawidth", maxmetal - 1, maxmetal)
    )
    t.hext = 2 * t.viaext
    return t
end

function check(_P)
    if not _P.shift_bus_for_vias and _P.vregshift == 0 then
        return false, "'shift_bus_for_vias == false' is currently only supported for a non-zero 'vregshift'. If 'vregshift' is not set high enough, unchecked shorts can occure."
    end
    return true
end

function layout(bus, _P)
    local totalvsize
    if _P.vregshift > 0 then
        totalvsize = _P.nummerge * (_P.numregs - 1) * _P.vregshift + _P.numbits * (_P.vwidth + _P.vspace) - _P.vspace
    else
        totalvsize = _P.nummerge * _P.numregs * _P.numbits * (_P.vwidth + _P.vspace) - _P.vspace
    end
    if _P.shift_bus_for_vias then
        totalvsize = totalvsize + (_P.nummerge - 1) * (_P.vwidth + _P.vspace)
    end
    if _P.hregshift > 0 then
        totalhsize = _P.nummerge * (_P.numregs - 1) * _P.hregshift + _P.numbits * (_P.hwidth + _P.hspace) - _P.hspace
    else
        totalhsize = _P.nummerge * _P.numregs * _P.numbits * (_P.hwidth + _P.hspace) - _P.hspace
    end
    local lefttop_or_rightbottom = _P.hposition == "left" and _P.vposition == "top"

    -- vertical lines
    for merge = 1, _P.nummerge do
        local mergexshift = (merge - 1) * _P.numregs * _P.numbits * (_P.vwidth + _P.vspace)
        if _P.shift_bus_for_vias then
            mergexshift = mergexshift + (merge - 1) * 2 * _P.viaext
        end
        local mergeyshift = (merge - 1) * (_P.hwidth + _P.hspace)
        for reg = 1, _P.numregs do
            local regxshift
            if _P.vregshift > 0 then
                regxshift = (reg - 1) * _P.vregshift
            else
                regxshift = (reg - 1) * _P.numbits * (_P.vwidth + _P.vspace)
            end
            local regyshift
            if _P.hregshift > 0 then
                regyshift = (reg - 1) * _P.hregshift
            else
                regyshift = (reg - 1) * _P.numbits * (_P.hwidth + _P.hspace)
            end
            for bit = 1, _P.numbits do
                local xbit = bit
                local ybit
                if _P.invert then
                    ybit = _P.numbits - bit + 1
                else
                    ybit = bit
                end
                local bitxshift = (xbit - 1) * (_P.vwidth + _P.vspace)
                local bityshift = _P.nummerge * (ybit - 1) * (_P.hwidth + _P.hspace)
                local xshift = mergexshift + regxshift + bitxshift
                local yshift = mergeyshift + regyshift + bityshift
                if _P.expand_all then
                    yshift = 0
                end
                if _P.vposition == "bottom" then
                    geometry.rectanglebltr(bus, generics.metal(_P.vmetal),
                        point.create(xshift, -_P.vext),
                        point.create(xshift + _P.vwidth, yshift + _P.hwidth)
                    )
                else -- _P.vposition == "top"
                    geometry.rectanglebltr(bus, generics.metal(_P.vmetal),
                        point.create(xshift, yshift + _P.hwidth),
                        point.create(xshift + _P.vwidth, totalhsize + _P.vext)
                    )
                end
            end
        end
    end

    -- horizontal lines
    for merge = 1, _P.nummerge do
        local mergexshift = (merge - 1) * _P.numregs * _P.numbits * (_P.vwidth + _P.vspace)
        if _P.shift_bus_for_vias then
            mergexshift = mergexshift + (merge - 1) * 2 * _P.viaext
        end
        local mergeyshift = (merge - 1) * (_P.hwidth + _P.hspace)
        for reg = 1, _P.numregs do
            local regxshift
            if _P.vregshift > 0 then
                regxshift = (reg - 1) * _P.vregshift
            else
                regxshift = (reg - 1) * _P.numbits * (_P.vwidth + _P.vspace)
            end
            local regyshift
            if _P.hregshift > 0 then
                regyshift = (reg - 1) * _P.hregshift
            else
                regyshift = (reg - 1) * _P.numbits * (_P.hwidth + _P.hspace)
            end
            for bit = 1, _P.numbits do
                local xbit = bit
                local ybit
                if _P.invert then
                    ybit = _P.numbits - bit + 1
                else
                    ybit = bit
                end
                local bitxshift = (xbit - 1) * (_P.vwidth + _P.vspace)
                local bityshift = _P.nummerge * (ybit - 1) * (_P.hwidth + _P.hspace)
                local xshift = mergexshift + regxshift + bitxshift
                local yshift = mergeyshift + regyshift + bityshift
                if _P.hposition == "left" then
                    geometry.rectanglebltr(bus, generics.metal(_P.hmetal),
                        point.create(0 - _P.hext, yshift),
                        point.create(xshift + _P.vwidth, yshift + _P.hwidth)
                    )
                else -- _P.hposition == "right"
                    geometry.rectanglebltr(bus, generics.metal(_P.hmetal),
                        point.create(xshift + _P.vwidth, yshift),
                        point.create(totalvsize + _P.hext, yshift + _P.hwidth)
                    )
                end
            end
        end
    end

    -- vias
    for merge = 1, _P.nummerge do
        local mergexshift = (merge - 1) * _P.numregs * _P.numbits * (_P.vwidth + _P.vspace)
        if _P.shift_bus_for_vias then
            mergexshift = mergexshift + (merge - 1) * 2 * _P.viaext
        end
        local mergeyshift = (merge - 1) * (_P.hwidth + _P.hspace)
        for reg = 1, _P.numregs do
            local regxshift
            if _P.vregshift > 0 then
                regxshift = (reg - 1) * _P.vregshift
            else
                regxshift = (reg - 1) * _P.numbits * (_P.vwidth + _P.vspace)
            end
            local regyshift
            if _P.hregshift > 0 then
                regyshift = (reg - 1) * _P.hregshift
            else
                regyshift = (reg - 1) * _P.numbits * (_P.hwidth + _P.hspace)
            end
            for bit = 1, _P.numbits do
                local xbit = bit
                local ybit
                if _P.invert then
                    ybit = _P.numbits - bit + 1
                else
                    ybit = bit
                end
                local bitxshift = (xbit - 1) * (_P.vwidth + _P.vspace)
                local bityshift = _P.nummerge * (ybit - 1) * (_P.hwidth + _P.hspace)
                local xshift = mergexshift + regxshift + bitxshift
                local yshift = mergeyshift + regyshift + bityshift
                local viaxext = 0
                local viaxshift = 0
                local viayext = 0
                local viayshift = 0
                if _P.viamode == "horizontal" then
                    viaxext = 2 * _P.viaext
                    if _P.vposition == "bottom" then
                        viaxshift = 0
                    else
                        viaxshift = 2 * _P.viaext
                    end
                else
                    viayext = 2 * _P.viaext
                    if _P.hposition == "left" then
                        viayshift = 0
                    else
                        viayshift = 2 * _P.viaext
                    end
                end
                geometry.viabltr(bus, _P.vmetal, _P.hmetal,
                    point.create(xshift + viaxshift - viaxext, yshift + viayshift - viayext),
                    point.create(xshift + viaxshift + _P.vwidth, yshift + viayshift + _P.hwidth)
                )
            end
        end
    end
end

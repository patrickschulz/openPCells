function parameters()
    pcell.add_parameters(
        { "ringmetals", { -1 } },
        { "numrings", 2 },
        { "ringwidths", { 20000, 20000 } },
        { "ringspacings", { 10000 } },
        { "chipwidth", 1000000 },
        { "chipheight", 1000000 },
        { "ringoffset", 0 },
        { "chamferoffset", 10000 }
    )
end

function check(_P)
    if #_P.ringwidths ~= #_P.ringspacings + 1 then
        return false, string.format(
            "'ringwidths' must have exactly one entry more than 'ringspacings', got %d and %d",
            #_P.ringwidths, #_P.ringspacings
        )
    end
    return true
end

function layout(ring, _P)
    geometry.rectanglebltr(ring, generics.outline(),
        point.create(0, 0),
        point.create(_P.chipwidth, _P.chipheight)
    )
    local offset = _P.ringoffset
    local chamferoffset = _P.chamferoffset
    for i = 1, #_P.ringwidths do
        chamferoffset = chamferoffset + math.floor((1 - math.tan(math.pi / 8)) * _P.ringwidths[i] / 2)
        if i < #_P.ringwidths then
            chamferoffset = chamferoffset + math.floor((1 - math.tan(math.pi / 8)) * _P.ringspacings[i])
        end
    end
    for i = 1, #_P.ringwidths do
        offset = offset + _P.ringwidths[i] / 2
        if i > 1 then
            chamferoffset = chamferoffset - math.floor((1 - math.tan(math.pi / 8)) * _P.ringwidths[i] / 2)
        end
        for _, metal in ipairs(_P.ringmetals) do
            geometry.path(ring, generics.metal(metal), {
                point.create(offset, chamferoffset + offset + _P.ringwidths[i]),
                point.create(offset, _P.chipheight - chamferoffset - offset),
                point.create(chamferoffset + offset, _P.chipheight - offset),
                point.create(_P.chipwidth - chamferoffset - offset, _P.chipheight - offset),
                point.create(_P.chipwidth - offset, _P.chipheight - chamferoffset - offset),
                point.create(_P.chipwidth - offset, chamferoffset + offset),
                point.create(_P.chipwidth - offset - chamferoffset, offset),
                point.create(offset + chamferoffset, offset),
                point.create(offset, chamferoffset + offset),
                point.create(offset, chamferoffset + offset + _P.ringwidths[i]),
            }, _P.ringwidths[i])
        end
        offset = offset + _P.ringwidths[i] / 2
        if i < #_P.ringwidths then
            offset = offset + _P.ringspacings[i]
        end
        chamferoffset = chamferoffset - math.floor((1 - math.tan(math.pi / 8)) * _P.ringwidths[i] / 2)
        if i < #_P.ringwidths then
            chamferoffset = chamferoffset - math.floor((1 - math.tan(math.pi / 8)) * _P.ringspacings[i])
        end
    end
end

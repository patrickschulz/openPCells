function parameters()
    pcell.add_parameters(
        { "padpitch", 100000 },
        { "leftpads", { "P" }, },
        { "leftpadnames", { "_" }, },
        { "rightpads", { "P" }, },
        { "rightpadnames", { "_" }, },
        { "toppads", { "P" }, },
        { "toppadnames", { "_" }, },
        { "bottompads", { "P" }, },
        { "bottompadnames", { "_" }, },
        { "leftoffset", 200000 },
        { "rightoffset", 200000 },
        { "topoffset", 200000 },
        { "bottomoffset", 200000 }
    )
end

function check(_P)
    if #_P.leftpads ~= #_P.leftpadnames then
        return false, string.format("the number of 'left' pads does not match the number of the 'left' pad names: %d vs. %d", #_P.leftpads, #_P.leftpadnames)
    end
    if #_P.rightpads ~= #_P.rightpadnames then
        return false, string.format("the number of 'right' pads does not match the number of the 'right' pad names: %d vs. %d", #_P.rightpads, #_P.rightpadnames)
    end
    if #_P.toppads ~= #_P.toppadnames then
        return false, string.format("the number of 'top' pads does not match the number of the 'top' pad names: %d vs. %d", #_P.toppads, #_P.toppadnames)
    end
    if #_P.bottompads ~= #_P.bottompadnames then
        return false, string.format("the number of 'bottom' pads does not match the number of the 'bottom' pad names: %d vs. %d", #_P.bottompads, #_P.bottompadnames)
    end
    return true
end

function layout(padring, _P)
    local left = pcell.create_layout("auxiliary/pads", "left", {
        padpitch = _P.padpitch,
        padconfig = _P.leftpads,
        padnames = _P.leftpadnames,
        orientation = "vertical"
    })
    left:translate_x(-_P.leftoffset)
    padring:merge_into_with_ports(left)
    for _, padname in ipairs(_P.leftpadnames) do
        -- add boundary
        padring:inherit_area_anchor(left, string.format("padboundary_%s", padname))
        -- add center (for labels)
        padring:add_anchor(string.format("padcenter_%s", padname),
            point.combine(
                padring:get_area_anchor(string.format("padboundary_%s", padname)).bl,
                padring:get_area_anchor(string.format("padboundary_%s", padname)).tr
            )
        )
    end
    local right = pcell.create_layout("auxiliary/pads", "right", {
        padpitch = _P.padpitch,
        padconfig = _P.rightpads,
        padnames = _P.rightpadnames,
        orientation = "vertical"
    })
    right:translate_x(_P.rightoffset)
    padring:merge_into_with_ports(right)
    for _, padname in ipairs(_P.rightpadnames) do
        -- add boundary
        padring:inherit_area_anchor(right, string.format("padboundary_%s", padname))
        -- add center (for labels)
        padring:add_anchor(string.format("padcenter_%s", padname),
            point.combine(
                padring:get_area_anchor(string.format("padboundary_%s", padname)).bl,
                padring:get_area_anchor(string.format("padboundary_%s", padname)).tr
            )
        )
    end
    local top = pcell.create_layout("auxiliary/pads", "top", {
        padpitch = _P.padpitch,
        padconfig = _P.toppads,
        padnames = _P.toppadnames,
        orientation = "horizontal"
    })
    top:translate_y(_P.topoffset)
    padring:merge_into_with_ports(top)
    for _, padname in ipairs(_P.toppadnames) do
        -- add boundary
        padring:inherit_area_anchor(top, string.format("padboundary_%s", padname))
        -- add center (for labels)
        padring:add_anchor(string.format("padcenter_%s", padname),
            point.combine(
                padring:get_area_anchor(string.format("padboundary_%s", padname)).bl,
                padring:get_area_anchor(string.format("padboundary_%s", padname)).tr
            )
        )
    end
    local bottom = pcell.create_layout("auxiliary/pads", "bottom", {
        padpitch = _P.padpitch,
        padconfig = _P.bottompads,
        padnames = _P.bottompadnames,
        orientation = "horizontal"
    })
    bottom:translate_y(-_P.bottomoffset)
    padring:merge_into_with_ports(bottom)
    for _, padname in ipairs(_P.bottompadnames) do
        -- add boundary
        padring:inherit_area_anchor(bottom, string.format("padboundary_%s", padname))
        -- add center (for labels)
        padring:add_anchor(string.format("padcenter_%s", padname),
            point.combine(
                padring:get_area_anchor(string.format("padboundary_%s", padname)).bl,
                padring:get_area_anchor(string.format("padboundary_%s", padname)).tr
            )
        )
    end
end

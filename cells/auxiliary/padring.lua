function info()
    local lines = {
        "This cell constructs a simple padring (only the top-metal pads, not ESD structures, no supply rings). It is designed mainly for planning purposes.",
        "The pads are configured by specifying four sides: left, right, top and bottom.",
        "The pad specification (e.g. 'leftpads') should be a table where every entry identifies one pad type.",
        "The possible types are 'P' (power pads/general purpose pads), 'G' (ground pads for RF structures such as GSG) and 'S' (signal pads for RF structures such as GSG).",
        "The sizes of the pads can then be cofigured with the corresponding P/G/S parameters, for instance for 'P' pads there are 'Ppadwidth' and 'Ppadheight'.",
        "The distance between the pads is defined by their size and the 'padpitch', so this cell assumes equal-pitch placement for all pads.",
        "The pads can also be named by setting 'usepadnames' to 'true' and supplying the 'leftpadnames', 'rightpadnames', 'toppadnames', and 'bottompadnames'.",
    }
    return table.concat(lines, "\n")
end

function parameters()
    pcell.add_parameters(
        { "padpitch", 100000 },
        { "leftpads", { "P", "P", "P", "P", "P", "P", "P", "P", }, },
        { "leftpadnames", { "P1", "P2", "P3", "P4", "P5", "P6", "P7", "P8", }, },
        { "rightpads", { "P", "P", "P", "P", "P", "P", "P", "P", }, },
        { "rightpadnames", { "P17", "P18", "P19", "P20", "P21", "P22", "P23", "P24", }, },
        { "toppads", { "P", "P", "P", "P", "P", "P", "P", "P", }, },
        { "toppadnames", { "P9", "P10", "P11", "P12", "P13", "P14", "P15", "P16", }, },
        { "bottompads", { "P", "P", "P", "P", "P", "P", "P", "P", }, },
        { "bottompadnames", { "P25", "P26", "P27", "P28", "P29", "P30", "P31", "P32", }, },
        { "leftoffset", 0 },
        { "rightoffset", 0 },
        { "topoffset", 0 },
        { "bottomoffset", 0 },
        { "labelsizehint", 10000 },
        { "Spadwidth", 50000 },
        { "Spadheight", 54000 },
        { "Spadopeningxoffset", 5000 },
        { "Spadopeningyoffset", 5000 },
        { "Gpadwidth", 60000 },
        { "Gpadheight", 80000 },
        { "Gpadopeningxoffset", 5000 },
        { "Gpadopeningyoffset", 5000 },
        { "Ppadwidth", 60000 },
        { "Ppadheight", 80000 },
        { "Ppadopeningxoffset", 5000 },
        { "Ppadopeningyoffset", 5000 },
        { "usepadnames", false }
    )
end

function check(_P)
    if _P.usepadnames and (#_P.leftpads ~= #_P.leftpadnames) then
        return false, string.format("the number of 'left' pads does not match the number of the 'left' pad names: %d vs. %d", #_P.leftpads, #_P.leftpadnames)
    end
    if _P.usepadnames and (#_P.rightpads ~= #_P.rightpadnames) then
        return false, string.format("the number of 'right' pads does not match the number of the 'right' pad names: %d vs. %d", #_P.rightpads, #_P.rightpadnames)
    end
    if _P.usepadnames and (#_P.toppads ~= #_P.toppadnames) then
        return false, string.format("the number of 'top' pads does not match the number of the 'top' pad names: %d vs. %d", #_P.toppads, #_P.toppadnames)
    end
    if _P.usepadnames and (#_P.bottompads ~= #_P.bottompadnames) then
        return false, string.format("the number of 'bottom' pads does not match the number of the 'bottom' pad names: %d vs. %d", #_P.bottompads, #_P.bottompadnames)
    end
    return true
end

function layout(padring, _P)
    local left = pcell.create_layout("auxiliary/pads", "left", {
        padpitch = _P.padpitch,
        padconfig = _P.leftpads,
        padnames = _P.leftpadnames,
        padconfigisreversed = true,
        orientation = "vertical",
        labelsizehint = _P.labelsizehint,
        Spadwidth = _P.Spadwidth,
        Spadheight = _P.Spadheight,
        Spadopeningxoffset = _P.Spadopeningxoffset,
        Spadopeningyoffset = _P.Spadopeningyoffset,
        Gpadwidth = _P.Gpadwidth,
        Gpadheight = _P.Gpadheight,
        Gpadopeningxoffset = _P.Gpadopeningxoffset,
        Gpadopeningyoffset = _P.Gpadopeningyoffset,
        Ppadwidth = _P.Ppadwidth,
        Ppadheight = _P.Ppadheight,
        Ppadopeningxoffset = _P.Ppadopeningxoffset,
        Ppadopeningyoffset = _P.Ppadopeningyoffset,
    })
    local leftoffset = -math.max(#_P.toppads, #_P.bottompads + 1) * _P.padpitch / 2
    left:translate_x(leftoffset - _P.leftoffset)
    padring:merge_into_with_ports(left)
    if _P.usepadnames then
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
    end
    local right = pcell.create_layout("auxiliary/pads", "right", {
        padpitch = _P.padpitch,
        padconfig = _P.rightpads,
        padnames = _P.rightpadnames,
        orientation = "vertical",
        labelsizehint = _P.labelsizehint,
        Spadwidth = _P.Spadwidth,
        Spadheight = _P.Spadheight,
        Spadopeningxoffset = _P.Spadopeningxoffset,
        Spadopeningyoffset = _P.Spadopeningyoffset,
        Gpadwidth = _P.Gpadwidth,
        Gpadheight = _P.Gpadheight,
        Gpadopeningxoffset = _P.Gpadopeningxoffset,
        Gpadopeningyoffset = _P.Gpadopeningyoffset,
        Ppadwidth = _P.Ppadwidth,
        Ppadheight = _P.Ppadheight,
        Ppadopeningxoffset = _P.Ppadopeningxoffset,
        Ppadopeningyoffset = _P.Ppadopeningyoffset,
    })
    local rightoffset = math.max(#_P.toppads, #_P.bottompads + 1) * _P.padpitch / 2
    right:translate_x(rightoffset + _P.rightoffset)
    padring:merge_into_with_ports(right)
    if _P.usepadnames then
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
    end
    local top = pcell.create_layout("auxiliary/pads", "top", {
        padpitch = _P.padpitch,
        padconfig = _P.toppads,
        padnames = _P.toppadnames,
        padconfigisreversed = true,
        orientation = "horizontal",
        labelsizehint = _P.labelsizehint,
        Spadwidth = _P.Spadwidth,
        Spadheight = _P.Spadheight,
        Spadopeningxoffset = _P.Spadopeningxoffset,
        Spadopeningyoffset = _P.Spadopeningyoffset,
        Gpadwidth = _P.Gpadwidth,
        Gpadheight = _P.Gpadheight,
        Gpadopeningxoffset = _P.Gpadopeningxoffset,
        Gpadopeningyoffset = _P.Gpadopeningyoffset,
        Ppadwidth = _P.Ppadwidth,
        Ppadheight = _P.Ppadheight,
        Ppadopeningxoffset = _P.Ppadopeningxoffset,
        Ppadopeningyoffset = _P.Ppadopeningyoffset,
    })
    local topoffset = math.max(#_P.leftpads, #_P.rightpads + 1) * _P.padpitch / 2
    top:translate_y(topoffset + _P.topoffset)
    padring:merge_into_with_ports(top)
    if _P.usepadnames then
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
    end
    local bottom = pcell.create_layout("auxiliary/pads", "bottom", {
        padpitch = _P.padpitch,
        padconfig = _P.bottompads,
        padnames = _P.bottompadnames,
        orientation = "horizontal",
        labelsizehint = _P.labelsizehint,
        Spadwidth = _P.Spadwidth,
        Spadheight = _P.Spadheight,
        Spadopeningxoffset = _P.Spadopeningxoffset,
        Spadopeningyoffset = _P.Spadopeningyoffset,
        Gpadwidth = _P.Gpadwidth,
        Gpadheight = _P.Gpadheight,
        Gpadopeningxoffset = _P.Gpadopeningxoffset,
        Gpadopeningyoffset = _P.Gpadopeningyoffset,
        Ppadwidth = _P.Ppadwidth,
        Ppadheight = _P.Ppadheight,
        Ppadopeningxoffset = _P.Ppadopeningxoffset,
        Ppadopeningyoffset = _P.Ppadopeningyoffset,
    })
    local bottomoffset = -math.max(#_P.leftpads, #_P.rightpads + 1) * _P.padpitch / 2
    bottom:translate_y(bottomoffset - _P.bottomoffset)
    padring:merge_into_with_ports(bottom)
    if _P.usepadnames then
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
end

function parameters()
    pcell.add_parameters(
        { "padconfig(Pad Configuration; G, S or P)",            { "P", "P", "P" }, argtype = "strtable" },
        { "padnames(Pad Names)",                                { "a", "b", "c" }, argtype = "strtable" },
        { "padconfigisreversed",                                false },
        { "Spadwidth(Width of S-Pad)",                          50000 },
        { "Spadheight(Height of S-Pad)",                        54000 },
        { "Spadopeningxoffset(x-Offset of S-Pad Opening)",      5000 },
        { "Spadopeningyoffset(y-Offset of S-Pad Opening)",      5000 },
        { "Gpadwidth(Width of G-Pad)",                          60000 },
        { "Gpadheight(Height of G-Pad)",                        80000 },
        { "Gpadopeningxoffset(x-Offset of G-Pad Opening)",      5000 },
        { "Gpadopeningyoffset(y-Offset of G-Pad Opening)",      5000 },
        { "Ppadwidth(Width of P-Pad)",                          60000 },
        { "Ppadheight(Height of P-Pad)",                        80000 },
        { "Ppadopeningxoffset(x-Offset of P-Pad Opening)",      5000 },
        { "Ppadopeningyoffset(y-Offset of P-Pad Opening)",      5000 },
        { "padpitch(Pitch between Pads)",                       100000 },
        { "orientation(Pad Orientation)",                       "horizontal", posvals = set("horizontal", "vertical") },
        { "alignment(Pad Alignment)",                           "center", posvals = set("center", "top/left", "bottom/right") },
        { "labelsizehint(Label Size Hint)",                     10000 }
    )
end

function layout(pads, _P)
    local Spad = pcell.create_layout("auxiliary/pad", "Spad", {
        orientation = _P.orientation,
        alignment = _P.alignment,
        padwidth = _P.Spadwidth,
        padheight = _P.Spadheight,
        padopeningxoffset = _P.Spadopeningxoffset,
        padopeningyoffset = _P.Spadopeningyoffset,
    })

    local Gpad = pcell.create_layout("auxiliary/pad", "Gpad", {
        orientation = _P.orientation,
        alignment = _P.alignment,
        padwidth = _P.Gpadwidth,
        padheight = _P.Gpadheight,
        padopeningxoffset = _P.Gpadopeningxoffset,
        padopeningyoffset = _P.Gpadopeningyoffset,
    })

    local Ppad = pcell.create_layout("auxiliary/pad", "Ppad", {
        orientation = _P.orientation,
        alignment = _P.alignment,
        padwidth = _P.Ppadwidth,
        padheight = _P.Ppadheight,
        padopeningxoffset = _P.Ppadopeningxoffset,
        padopeningyoffset = _P.Ppadopeningyoffset,
    })

    local numpads = #_P.padconfig
    local startindex = _P.padconfigisreversed and 1 or numpads
    local endindex = _P.padconfigisreversed and numpads or 1
    local increment = _P.padconfigisreversed and 1 or -1
    local i = 1
    for padindex = startindex, endindex, increment do
        local padtype = _P.padconfig[padindex]
        local x, y
        if _P.orientation == "horizontal" then
            if _P.alignment == "top/left" then
                x = (i - 1) * _P.padpitch - (numpads - 1) * _P.padpitch / 2
            elseif _P.alignment == "bottom/right" then
                x = (i - 1) * _P.padpitch - (numpads - 1) * _P.padpitch / 2
            else -- center
                x = (i - 1) * _P.padpitch - (numpads - 1) * _P.padpitch / 2
            end
            y = 0
        else -- vertical
            x = 0
            y = (i - 1) * _P.padpitch - (numpads - 1) * _P.padpitch / 2
        end
        local pad
        if padtype == "S" then
            pad = Spad:copy()
        elseif padtype == "G" then
            pad = Gpad:copy()
        else
            pad = Ppad:copy()
        end
        pad:translate(x, y)
        pads:merge_into(pad)
        pads:inherit_area_anchor_as(pad, "boundary", string.format("padboundary_%i", i))
        pads:inherit_area_anchor_as(pad, "boundary", string.format("padboundary_%s", _P.padnames[padindex]))
        pads:add_port_with_anchor(
            string.format("%s", _P.padnames[padindex]),
            generics.metalport(-1),
            point.combine(
                pad:get_area_anchor("boundary").bl,
                pad:get_area_anchor("boundary").tr
            ),
            _P.labelsizehint
        )
        i = i + 1
    end
end

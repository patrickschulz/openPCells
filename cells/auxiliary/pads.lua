function parameters()
    pcell.add_parameters(
        { "padconfig(Pad Configuration; G, S or P)",      { "P", "P", "P" }, argtype = "strtable" },
        { "padnames(Pad Names)",                          { "a", "b", "c" }, argtype = "strtable" },
        { "Spadwidth(Width of S-Pad)",                   50000 },
        { "Spadheight(Height of S-Pad)",                 54000 },
        { "Spadopeningwidth(Width of S-Pad Opening)",    40000 },
        { "Spadopeningheight(Height of S-Pad Opening)",  44000 },
        { "Gpadwidth(Width of G-Pad)",                   60000 },
        { "Gpadheight(Height of G-Pad)",                 80000 },
        { "Gpadopeningwidth(Width of G-Pad Opening)",    50000 },
        { "Gpadopeningheight(Height of G-Pad Opening)",  70000 },
        { "Ppadwidth(Width of P-Pad)",                   60000 },
        { "Ppadheight(Height of P-Pad)",                 80000 },
        { "Ppadopeningwidth(Width of P-Pad Opening)",    50000 },
        { "Ppadopeningheight(Height of P-Pad Opening)",  70000 },
        { "padpitch(Pitch between Pads)",               100000 },
        { "orientation(Pad Orientation)",               "horizontal", posvals = set("horizontal", "vertical") },
        { "alignment(Pad Alignment)",                   "center", posvals = set("center", "top/left", "bottom/right") }
    )
end

function layout(pads, _P)
    pcell.push_overwrites("auxiliary/pad", { 
        orientation = _P.orientation,
        alignment = _P.alignment
    })
    pcell.push_overwrites("auxiliary/pad", { 
        padwidth = _P.Spadwidth, 
        padheight = _P.Spadheight, 
        padopeningwidth = _P.Spadopeningwidth, 
        padopeningheight = _P.Spadopeningheight,
    })
    local Spad = pcell.create_layout("auxiliary/pad", "Spad")
    pcell.pop_overwrites("auxiliary/pad")

    pcell.push_overwrites("auxiliary/pad", { 
        padwidth = _P.Gpadwidth, 
        padheight = _P.Gpadheight, 
        padopeningwidth = _P.Gpadopeningwidth, 
        padopeningheight = _P.Gpadopeningheight,
    })
    local Gpad = pcell.create_layout("auxiliary/pad", "Gpad")
    pcell.pop_overwrites("auxiliary/pad")

    pcell.push_overwrites("auxiliary/pad", { 
        padwidth = _P.Ppadwidth, 
        padheight = _P.Ppadheight, 
        padopeningwidth = _P.Ppadopeningwidth, 
        padopeningheight = _P.Ppadopeningheight,
    })
    local Ppad = pcell.create_layout("auxiliary/pad", "Ppad")
    pcell.pop_overwrites("auxiliary/pad")
    pcell.pop_overwrites("auxiliary/pad")

    local numpads = #_P.padconfig
    for i, padtype in ipairs(_P.padconfig) do
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
        pads:inherit_area_anchor_as(pad, "boundary", string.format("padboundary_%s", _P.padnames[i]))
        pads:add_port(
            string.format("%s", _P.padnames[i]),
            generics.metalport(-1),
            point.combine(
                pad:get_area_anchor("boundary").bl,
                pad:get_area_anchor("boundary").tr
            )
        )
    end
end

function parameters()
    pcell.add_parameters(
        { "padwidth(Width of Pad)",                   60000 },
        { "padheight(Height of Pad)",                 80000 },
        { "padopeningwidth(Width of Pad Opening)",    50000 },
        { "padopeningheight(Height of Pad Opening)",  70000 },
        { "orientation(Pad Orientation)",         "horizontal", posvals = set("horizontal", "vertical") },
        { "alignment(Pad Alignment)",                 "center", posvals = set("center", "top/left", "bottom/right") }
    )
end

function layout(pad, _P)
    local metal, marker
    local xshift, yshift = 0, 0
    if _P.alignment == "top/left" then
        xshift = (_P.orientation == "vertical") and _P.padheight / 2 or 0
        yshift = (_P.orientation == "horizontal") and -_P.padheight / 2 or 0
    elseif _P.alignment == "bottom/right" then
        xshift = (_P.orientation == "vertical") and -_P.padheight / 2 or 0
        yshift = (_P.orientation == "horizontal") and _P.padheight / 2 or 0
    end
    if _P.orientation == "horizontal" then
        metal = geometry.rectangle(generics.metal(-1), _P.padwidth, _P.padheight)
        marker = geometry.rectangle(generics.other("padopening"), _P.padopeningwidth, _P.padopeningheight)
    else -- vertical
        metal = geometry.rectangle(generics.metal(-1), _P.padheight, _P.padwidth)
        marker = geometry.rectangle(generics.other("padopening"), _P.padopeningheight, _P.padopeningwidth)
    end
    metal:translate(xshift, yshift)
    marker:translate(xshift, yshift)
    pad:merge_into_shallow(metal)
    pad:merge_into_shallow(marker)
    pad:add_anchor("center", point.create(0, 0))
end

function parameters()
    pcell.add_parameters(
        { "padwidth(Width of Pad)",                         60000 },
        { "padheight(Height of Pad)",                       80000 },
        { "padopeningxoffset(x-Offset of Pad Opening)",      5000 },
        { "padopeningyoffset(y-Offset of Pad Opening)",      5000 },
        { "orientation(Pad Orientation)",                   "horizontal", posvals = set("horizontal", "vertical") },
        { "alignment(Pad Alignment)",                       "center", posvals = set("center", "top/left", "bottom/right") }
    )
end

function check(_P)
    if _P.padopeningxoffset < 0 then
        return false, "padopeningxoffset must be positive or 0"
    end
    if _P.padopeningyoffset < 0 then
        return false, "padopeningyoffset must be positive or 0"
    end
    return true
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
        pad:add_area_anchor_bltr("boundary",
            point.create(xshift, yshift),
            point.create(xshift + _P.padwidth, yshift + _P.padheight)
        )
        pad:add_area_anchor_bltr("padopeningboundary",
            point.create(xshift + _P.padopeningxoffset, yshift + _P.padopeningyoffset),
            point.create(xshift + _P.padwidth - _P.padopeningxoffset, yshift + _P.padheight - _P.padopeningyoffset)
        )
    else -- vertical
        pad:add_area_anchor_bltr("boundary",
            point.create(xshift, yshift),
            point.create(xshift + _P.padheight, yshift + _P.padwidth)
        )
        pad:add_area_anchor_bltr("padopeningboundary",
            point.create(xshift + _P.padopeningyoffset, yshift + _P.padopeningxoffset),
            point.create(xshift + _P.padheight - _P.padopeningyoffset, yshift + _P.padwidth - _P.padopeningxoffset)
        )
    end
    geometry.rectanglebltr(pad, generics.metal(-1),
        pad:get_area_anchor("boundary").bl,
        pad:get_area_anchor("boundary").tr
    )
    geometry.rectanglebltr(pad, generics.other("padopening"),
        pad:get_area_anchor("padopeningboundary").bl,
        pad:get_area_anchor("padopeningboundary").tr
    )
end

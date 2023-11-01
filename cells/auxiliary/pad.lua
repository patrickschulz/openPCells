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

function check(_P)
    if _P.padopeningwidth > _P.padwidth then
        return false, string.format("padopeningwidth can't be larger than padwidth (%d vs %d)", _P.padopeningwidth, _P.padwidth)
    end
    if _P.padopeningheight > _P.padheight then
        return false, string.format("padopeningheight can't be larger than padheight (%d vs %d)", _P.padopeningheight, _P.padheight)
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
            point.create(xshift + (_P.padwidth - _P.padopeningwidth) / 2, yshift + (_P.padheight - _P.padopeningheight) / 2),
            point.create(xshift + (_P.padwidth - _P.padopeningwidth) / 2 + _P.padopeningwidth, yshift + (_P.padheight - _P.padopeningheight) / 2 + _P.padopeningheight)
        )
    else -- vertical
        pad:add_area_anchor_bltr("boundary",
            point.create(xshift, yshift),
            point.create(xshift + _P.padheight, yshift + _P.padwidth)
        )
        pad:add_area_anchor_bltr("padopeningboundary",
            point.create(xshift + (_P.padheight - _P.padopeningheight) / 2, yshift + (_P.padwidth - _P.padopeningwidth) / 2),
            point.create(xshift + (_P.padheight - _P.padopeningheight) / 2 + _P.padopeningheight, yshift + (_P.padwidth - _P.padopeningwidth) / 2 + _P.padopeningwidth)
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

local M = {}

function M.place_welltap(cell, bl, tr, options)
    local welltap = pcell.create_layout(
        "auxiliary/welltap",
        "_welltap",
        util.add_options(options or {}, {
            width = point.xdistance_abs(bl, tr),
            height = point.ydistance_abs(bl, tr),
        })
    )
    welltap:move_point(welltap:get_area_anchor("boundary").bl, bl)
    cell:merge_into(welltap)
    cell:inherit_alignment_box(welltap)
end

function M.place_guardring(cell, bl, tr, xspace, yspace, anchorprexif, options)
    local guardring = pcell.create_layout(
        "auxiliary/guardring",
        "_guardring",
        util.add_options(options or {}, {
            holewidth = point.xdistance_abs(bl, tr) + 2 * xspace,
            holeheight = point.ydistance_abs(bl, tr) + 2 * yspace,
        })
    )
    guardring:move_point(guardring:get_anchor("innerbottomleft"), bl)
    guardring:translate(-xspace, -yspace)
    cell:merge_into(guardring)
    cell:inherit_alignment_box(guardring)
    cell:inherit_anchor_as(guardring, "outerbottomleft",    string.format("%souterbottomleft", anchorprefix))
    cell:inherit_anchor_as(guardring, "outerbottomright",   string.format("%souterbottomright", anchorprefix))
    cell:inherit_anchor_as(guardring, "outertopleft",       string.format("%soutertopleft", anchorprefix))
    cell:inherit_anchor_as(guardring, "outertopright",      string.format("%soutertopright", anchorprefix))
    cell:inherit_anchor_as(guardring, "innerbottomleft",    string.format("%souterbottomleft", anchorprefix))
    cell:inherit_anchor_as(guardring, "innerbottomright",   string.format("%souterbottomright", anchorprefix))
    cell:inherit_anchor_as(guardring, "innertopleft",       string.format("%soutertopleft", anchorprefix))
    cell:inherit_anchor_as(guardring, "innertopright",      string.format("%soutertopright", anchorprefix))
end

function M.place_guardring_with_hole(cell, bl, tr, holebl, holetr, xspace, yspace, welloffset, anchorprefix, options)
    local guardring = pcell.create_layout(
        "auxiliary/guardring",
        "_guardring",
        util.add_options(options or {}, {
            holewidth = point.xdistance_abs(bl, tr) + 2 * xspace,
            holeheight = point.ydistance_abs(bl, tr) + 2 * yspace,
            fillwell = true,
            fillwelldrawhole = true,
            fillwellholeoffsettop = yspace - point.ydistance(holetr, tr) - welloffset,
            fillwellholeoffsetbottom = yspace - point.ydistance(bl, holebl) - welloffset,
            fillwellholeoffsetleft = xspace - point.xdistance(bl, holebl) - welloffset,
            fillwellholeoffsetright = xspace - point.xdistance(holetr, tr) - welloffset,
        })
    )
    guardring:move_point(guardring:get_anchor("innerbottomleft"), bl)
    guardring:translate(-xspace, -yspace)
    cell:merge_into(guardring)
    cell:inherit_alignment_box(guardring)
    cell:inherit_anchor_as(guardring, "outerbottomleft",    string.format("%souterbottomleft", anchorprefix))
    cell:inherit_anchor_as(guardring, "outerbottomright",   string.format("%souterbottomright", anchorprefix))
    cell:inherit_anchor_as(guardring, "outertopleft",       string.format("%soutertopleft", anchorprefix))
    cell:inherit_anchor_as(guardring, "outertopright",      string.format("%soutertopright", anchorprefix))
    cell:inherit_anchor_as(guardring, "innerbottomleft",    string.format("%souterbottomleft", anchorprefix))
    cell:inherit_anchor_as(guardring, "innerbottomright",   string.format("%souterbottomright", anchorprefix))
    cell:inherit_anchor_as(guardring, "innertopleft",       string.format("%soutertopleft", anchorprefix))
    cell:inherit_anchor_as(guardring, "innertopright",      string.format("%soutertopright", anchorprefix))
end

return M

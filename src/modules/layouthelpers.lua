local M = {}

function M.place_guardring(cell, bl, tr, xspace, yspace, options)
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
end

function M.place_guardring_with_hole(cell, bl, tr, holebl, holetr, xspace, yspace, options)
    local welloffset = 100
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
end

return M

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

return M

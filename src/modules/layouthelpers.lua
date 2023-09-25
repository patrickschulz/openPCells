local M = {}

function M.fit_guardring(bl, tr, xspace, yspace)
    return {
        alignanchor = "innerbottomleft",
        aligntarget = bl,
        holewidth = point.xdistance_abs(bl, tr) + 2 * xspace,
        holeheight = point.ydistance_abs(bl, tr) + 2 * yspace,
        xshift = -xspace,
        yshift = -yspace,
    }
end

return M

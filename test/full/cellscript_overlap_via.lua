local cell = object.create("overlap_via_test")

local basex
local basey

-- small via
basex = 300
basey = 0
geometry.rectanglebltr(cell, generics.metal(1),
    point.create(basex - 70, basey - 130),
    point.create(basex + 70, basey + 130)
)
geometry.rectanglebltr(cell, generics.metal(2),
    point.create(basex - 130, basey - 70),
    point.create(basex + 130, basey + 70)
)
geometry.viabarebltrov(cell, 1, 2,
    point.create(basex - 70, basey - 130),
    point.create(basex + 70, basey + 130),
    point.create(basex - 130, basey - 70),
    point.create(basex + 130, basey + 70)
)

-- small via
basex = -300
basey = 0
geometry.rectanglebltr(cell, generics.metal(1),
    point.create(basex - 130, basey - 70),
    point.create(basex + 130, basey + 70)
)
geometry.rectanglebltr(cell, generics.metal(2),
    point.create(basex - 70, basey - 130),
    point.create(basex + 70, basey + 130)
)
geometry.viabarebltrov(cell, 1, 2,
    point.create(basex - 130, basey - 70),
    point.create(basex + 130, basey + 70),
    point.create(basex - 70, basey - 130),
    point.create(basex + 70, basey + 130)
)

-- large via, non-bare
basex = 0
basey = -500
geometry.rectanglebltr(cell, generics.metal(1),
    point.create(basex - 2000, basey - 400),
    point.create(basex + 2000, basey + 200)
)
geometry.rectanglebltr(cell, generics.metal(2),
    point.create(basex - 200, basey - 2000),
    point.create(basex + 200, basey + 300)
)
geometry.viabltrov(cell, 1, 2,
    point.create(basex - 2000, basey - 400),
    point.create(basex + 2000, basey + 200),
    point.create(basex - 200, basey - 2000),
    point.create(basex + 200, basey + 300)
)

-- via from common-centroid test
basex = 0
basey = 500
geometry.rectanglebltr(cell, generics.metal(1),
    point.create(basex - 140, basey - 0),
    point.create(basex + 140, basey + 1200)
)
geometry.rectanglebltr(cell, generics.metal(2),
    point.create(basex - 2000, basey + 400),
    point.create(basex + 2000, basey + 800)
)
geometry.viabltrov(cell, 1, 2,
    point.create(basex - 140, basey - 0),
    point.create(basex + 140, basey + 1200),
    point.create(basex - 2000, basey + 400),
    point.create(basex + 2000, basey + 800)
)

return cell

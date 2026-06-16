-- translate all objects in all possible ways (full and proxy objects)
local cell = object.create("testflatten")
cell:translate(2, 2)

cell:add_port("topport", generics.metal(1), point.create(0, 0))

-- create level -1 cell, translate
local sub = object.create("sub")
sub:translate(4, 4)

-- create level -2 cell, translate, add shape, translate again, add port, translate again
local subsub = object.create("subsub")
subsub:translate(8, 8)
geometry.rectanglebltr(subsub, generics.metal(1), point.create(-50, -50), point.create(50, 50))
subsub:translate(16, 16)
subsub:add_port("subsubport", generics.metal(1), point.create(0, 0))
subsub:translate(32, 32)

-- add level -2 child to level -1, translate child, translate cell
local subsubchild = sub:add_child(subsub, "subsub")
subsubchild:translate(64, 64)
sub:translate(128, 128)

-- add shape to level -1, translate
geometry.rectanglebltr(sub, generics.metal(2), point.create(-50, -50), point.create(50, 50))
sub:translate(256, 256)

-- add level -1 to toplevel, translate child, translate toplevel
local subchild = cell:add_child(sub, "sub")
subchild:translate(512, 512)
cell:translate(1024, 1024)

local shift = 16 + 32 + 64 + 128 + 256 + 512 + 1024
geometry.rectanglebltr(cell, generics.outline(),
    point.create(
        -50 + shift,
        -50 + shift
    ),
    point.create(
        50 + shift,
        50 + shift
    )
)

shift = 256 + 512 + 1024
geometry.rectanglebltr(cell, generics.outline(),
    point.create(
        -50 + shift,
        -50 + shift
    ),
    point.create(
        50 + shift,
        50 + shift
    )
)

cell:flatten(true) -- flatten ports

return cell

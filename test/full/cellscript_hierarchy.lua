-- translate all objects in all possible ways (full and proxy objects)
local cell = object.create("testflatten")
cell:translate(10, 10)

-- create level -1 cell, translate
local sub = object.create("sub")
sub:translate(20, 20)

-- create level -2 cell, translate, add shape, translate again, add port, translate again
local subsub = object.create("subsub")
subsub:translate(40, 40)
geometry.rectanglebltr(subsub, generics.metal(1), point.create(-50, -50), point.create(50, 50))
subsub:translate(80, 80)
subsub:add_port("subsubport", generics.metal(1), point.create(0, 0))
subsub:translate(160, 160)

-- add level -2 child to level -1, translate child, translate cell
local subsubchild = sub:add_child(subsub, "subsub")
subsubchild:translate(320, 320)
sub:translate(640, 640)

-- add shape to level -1, translate
geometry.rectanglebltr(sub, generics.metal(2), point.create(-50, -50), point.create(50, 50))
sub:translate(1280, 1280)

-- add level -1 to toplevel, translate child, translate toplevel
local subchild = cell:add_child(sub, "sub")
subchild:translate(2560, 2560)
cell:translate(5120, 5120)

return cell

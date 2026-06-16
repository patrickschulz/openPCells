local cell = object.create("bounding_box_test")

geometry.rectanglebltr(cell, generics.metal(1), point.create(0, 0), point.create(100, 100))
geometry.rectanglebltr(cell, generics.metal(1), point.create(-50, -84), point.create(24, 32))
geometry.rectanglebltr(cell, generics.metal(1), point.create(18, -2), point.create(142, 76))
geometry.rectanglebltr(cell, generics.metal(1), point.create(12, -30), point.create(55, -9))

local bounding_box = cell:get_bounding_box()

geometry.rectanglebltr(cell, generics.outline(), bounding_box.bl, bounding_box.tr)

return cell

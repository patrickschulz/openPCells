local cell = object.create("testanchors")

local subref = object.create("sub")
geometry.rectanglebltr(subref, generics.metal(1), point.create(0, 0), point.create(100, 100))
subref:add_area_anchor_bltr("area", point.create(0, 0), point.create(100, 100))

local sub = cell:add_child(subref, "sub")
sub:translate(400, 400)
sub:rotate_90_left()
sub:translate(200, 200)

geometry.rectanglebltr(cell, generics.metal(2), sub:get_area_anchor("area").bl, sub:get_area_anchor("area").tr)

return cell

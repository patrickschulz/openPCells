local cell = object.create("layer_occupation_test")

geometry.rectanglebltr(cell, generics.metal(1), point.create(0, 0), point.create(100, 100))
geometry.rectanglebltr(cell, generics.metal(2), point.create(-40, -70), point.create(20, 40))

local all_occupation = cell:get_layer_occupation()
local m1_occupation = cell:get_layer_occupation(generics.metal(1))
local m2_occupation = cell:get_layer_occupation(generics.metal(2))
local m1m2_occupation = cell:get_layer_occupation({ generics.metal(1), generics.metal(2) })

geometry.rectanglebltr(cell, generics.outline(), m1_occupation.bl, m1_occupation.tr)
geometry.rectanglebltr(cell, generics.outline(), m2_occupation.bl, m2_occupation.tr)
geometry.rectanglebltr(cell, generics.outline(), all_occupation.bl, all_occupation.tr)
geometry.rectanglebltr(cell, generics.outline(), m1m2_occupation.bl, m1m2_occupation.tr)

return cell

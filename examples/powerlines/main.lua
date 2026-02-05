local cell = object.create("cell")

-- place shapes that should not be covered
geometry.rectanglebltr(cell, generics.metal(1), point.create(4000, 1000), point.create(6000, 2000))
geometry.rectanglebltr(cell, generics.metal(1), point.create(8000, 1000), point.create(9000, 2000))
geometry.rectanglebltr(cell, generics.metal(1), point.create(4000, 2000), point.create(6000, 3000))
geometry.rectanglebltr(cell, generics.metal(1), point.create(4500, 2000), point.create(6500, 3000))
geometry.rectanglebltr(cell, generics.metal(1), point.create(5000, 2000), point.create(7000, 3000))
geometry.rectanglebltr(cell, generics.metal(1), point.create(2000, 5000), point.create(7000, 6000))
geometry.rectanglebltr(cell, generics.metal(1), point.create(0, 7000), point.create(10000, 8000))
geometry.rectanglebltr(cell, generics.metal(1), point.create(9000, 9000), point.create(11000, 11000))
geometry.rectanglebltr(cell, generics.metal(1), point.create(-1000, 9000), point.create(1000, 11000))
geometry.rectanglebltr(cell, generics.metal(2), point.create(1000, 1000), point.create(2000, 2000))
geometry.rectanglebltr(cell, generics.metal(2), point.create(1000, 4000), point.create(2000, 5000))
geometry.rectanglebltr(cell, generics.metal(2), point.create(1000, 8000), point.create(2000, 9000))
geometry.rectanglebltr(cell, generics.metal(2), point.create(1000, 12000), point.create(2000, 13000))
geometry.rectanglebltr(cell, generics.metal(2), point.create(3000, 2000), point.create(4000, 3000))
geometry.rectanglebltr(cell, generics.metal(2), point.create(3000, 3500), point.create(4000, 4000))
geometry.path(cell, generics.metal(2), { point.create(4500, 3500), point.create(4500, 4500), point.create(6500, 4500), point.create(6500, 7000) }, 200)

local m1excludes = cell:get_shape_outlines(generics.metal(1), 200)
local m2excludes = cell:get_shape_outlines(generics.metal(2), 200)

local target = {
    bl = point.create(0, 0),
    tr = point.create(10000, 10000)
}

geometry.rectanglebltr(cell, generics.outline(), target.bl, target.tr)

local nets = { "vdd", "vss" }

local hnets = layouthelpers.place_hlines(
    cell,
    target.bl, target.tr,
    generics.metal(1),
    500, 500,
    400,
    nets,
    m1excludes
)

local vnets = layouthelpers.place_vlines(
    cell,
    target.bl, target.tr,
    generics.metal(2),
    500, 500,
    400,
    nets,
    m2excludes
)

layouthelpers.place_vias(
    cell,
    hnets, vnets
)

return cell

local cell = object.create("cell")

-- place shape that should not be covered
geometry.rectanglebltr(cell, generics.metal(1), point.create(4000, 1000), point.create(6000, 2000))
geometry.rectanglebltr(cell, generics.metal(2), point.create(1000, 1000), point.create(2000, 2000))
geometry.rectanglebltr(cell, generics.metal(2), point.create(1000, 4000), point.create(2000, 5000))
geometry.rectanglebltr(cell, generics.metal(2), point.create(1000, 8000), point.create(2000, 9000))

local m1excludes = cell:get_shape_outlines(generics.metal(1), 200)
local m2excludes = cell:get_shape_outlines(generics.metal(2), 200)

local target = {
    bl = point.create(0, 0),
    tr = point.create(10000, 10000)
}

geometry.rectanglebltr(cell, generics.outline(), target.bl, target.tr)

local hnets = layouthelpers.place_hlines_excludes(
    cell,
    target.bl, target.tr,
    generics.metal(1),
    500, 500,
    { "vdd", "vss" },
    m1excludes
)

local vnets = layouthelpers.place_vlines_excludes(
    cell,
    target.bl, target.tr,
    generics.metal(2),
    500, 500,
    { "vdd", "vss" },
    m2excludes
)

layouthelpers.place_vias(
    cell,
    1, 2,
    hnets, vnets
)

return cell

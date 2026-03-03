--math.randomseed(1)

local cell = object.create("cell")

-- place shapes that should not be covered
local numshapes = 300000
for i = 1, numshapes do
    local xoffset = 1000 * math.random(1, 1000)
    local yoffset = 1000 * math.random(1, 1000)
    local xsize = 10 * math.random(1, 100)
    local ysize = 10 * math.random(1, 100)
    local bl = point.create(xoffset, yoffset)
    local tr = point.create(xoffset + xsize, yoffset + ysize)
    geometry.rectanglebltr(cell, generics.metal(1), bl, tr)
end

local m1excludes = cell:get_shape_outlines(generics.metal(1), 200)

local target = {
    bl = point.create(0, 0),
    tr = point.create(1000 * 1000, 1000 * 1000)
}

geometry.rectanglebltr(cell, generics.outline(), target.bl, target.tr)

for _, e in ipairs(m1excludes) do
    geometry.polygon(cell, generics.special(), e)
end

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
    nets
)

layouthelpers.place_vias(
    cell,
    hnets, vnets,
    nil, nil,
    true
)

return cell

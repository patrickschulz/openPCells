local cell = object.create("toplevel")

local pathpts = {
    point.create(2500, 0),
    point.create(2500, 2000),
    point.create(4500, 2000),
    point.create(4500, 4000),
    point.create(2500, 6000),
    point.create(2000, 6000),
    point.create(2000, 3000),
    point.create(1000, 3000),
}
geometry.path_polygon(cell, generics.metal(1), pathpts, 200)
geometry.rectanglebltr(cell, generics.metal(1),
    point.create(500, 500),
    point.create(1500, 1500)
)

local excludes = cell:get_shape_outlines(generics.metal(1))
local exclude_offset = 200
for i = 1, #excludes do
    local exclude = excludes[i]
    local new = util.offset_polygon(exclude, exclude_offset)
    excludes[i] = new
end

for i = 1, #excludes do
    geometry.polygon(cell, generics.special(), excludes[i])
end

geometry.rectangle_fill_in_boundary(cell, generics.metal(1),
    100, 100,
    200, 200,
    0, 0,
    util.rectangle_to_polygon(point.create(0, 0), point.create(7000, 7000)),
    excludes
)

return cell

local external = pcell.create_layout_from_script("cellscript.lua")

local cell = object.create("toplevel")

-- collect the shape outlines from the cell
local excludes = external:get_shape_outlines(generics.metal(1))
-- add an offset (spacing)
local exclude_offset = 200
for i = 1, #excludes do
    local exclude = excludes[i]
    local new = util.offset_polygon(exclude, exclude_offset)
    excludes[i] = new
end

-- show the excludes in the layout
for i = 1, #excludes do
    geometry.polygon(cell, generics.special(), excludes[i])
end

-- create the rectangular fill on M1 with excludes
geometry.rectangle_fill_in_boundary(cell, generics.metal(1),
    100, 100, -- width/height
    200, 200, -- xpitch/ypitch
    0, 0, -- start offsets (x/y)
    util.rectangle_to_polygon(point.create(0, 0), point.create(7000, 7000)), -- target area
    excludes -- table with exclusion polygons
)
-- rectangular fill on M2 without excludes, uses a different start offset
geometry.rectangle_fill_in_boundary(cell, generics.metal(2),
    100, 100, -- width/height
    200, 200, -- xpitch/ypitch
    100, 100, -- start offsets (x/y)
    util.rectangle_to_polygon(point.create(0, 0), point.create(7000, 7000))
)

return cell

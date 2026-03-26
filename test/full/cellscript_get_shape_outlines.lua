local cell = object.create("cell")

local sub = object.create("sub")
geometry.rectanglebltr(sub, generics.metal(1),
    point.create(100, 100),
    point.create(500, 500)
)
geometry.rectanglebltr(sub, generics.metal(1),
    point.create(400, 100),
    point.create(600, 300)
)

local subhandle = object.create_object_handle(cell, sub)
local sub1 = cell:add_child(subhandle, "sub1")
sub1:translate(-500, -500)
local sub2 = cell:add_child(subhandle, "sub2")
sub2:rotate_90_right()
local subarray = cell:add_child_array(subhandle, "subarray", 10, 1, 1200, 0)

local outlines = cell:get_shape_outlines(generics.metal(1))
for _, outline in ipairs(outlines) do
    geometry.polygon(cell, generics.metal(2), outline)
end

return cell

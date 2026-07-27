--math.randomseed(1)

local cell = object.create("cell")

-- place shapes that should not be covered
local minxpos = 0
local maxxpos = 100000
local minypos = 0
local maxypos = 100000
local minwidth = 2
local maxwidth = 100
local widthfactor = 10
local minheight = 2
local maxheight = 100
local heightfactor = 10
local numshapes = 400
for i = 1, numshapes do
    local xoffset = math.random(minxpos, maxxpos)
    local yoffset = math.random(minypos, maxypos)
    local xsize = widthfactor * math.random(minwidth, maxwidth)
    local ysize = heightfactor * math.random(minheight, maxheight)
    local bl = point.create(xoffset, yoffset)
    local tr = point.create(xoffset + xsize, yoffset + ysize)
    geometry.rectanglebltr(cell, generics.metal(1), bl, tr)
end

-- get excludes for shapes
local m1excludes = cell:get_shape_outlines(generics.metal(1), 200)

-- target area
local target = {
    bl = point.create(0, 0),
    tr = point.create(maxxpos, maxypos)
}

-- show outline of target area
geometry.rectanglebltr(cell, generics.outline(), target.bl, target.tr)

geometry.rectangle_fill_in_boundary(
    cell,
    generics.metal(1),
    100, 100,
    200, 200,
    0, 0,
    util.rectangle_to_polygon(target.bl, target.tr),
    m1excludes
)

return cell

--math.randomseed(1)

print("running 'huge.lua' power grid example. This will take a few seconds")

local cell = object.create("cell")

-- place shapes that should not be covered
local minxpos = 0
local maxxpos = 1000000
local minypos = 0
local maxypos = 1000000
local minwidth = 2
local maxwidth = 100
local widthfactor = 10
local minheight = 2
local maxheight = 100
local heightfactor = 10
local numshapes = 1000000
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

-- show excludes
for _, e in ipairs(m1excludes) do
    geometry.polygon(cell, generics.special(), e)
end

-- nets for line placement
local nets = { "vdd", "vss" }

-- horizontal lines on metal 1
local hnets = layouthelpers.place_hlines(
    cell,
    target.bl, target.tr,
    generics.metal(1),
    500, 500,
    400,
    nets,
    m1excludes
)

-- vertical lines on metal 2
local vnets = layouthelpers.place_vlines(
    cell,
    target.bl, target.tr,
    generics.metal(2),
    500, 500,
    400,
    nets
)

-- place vias between horizontal and vertical lines
layouthelpers.place_vias(
    cell,
    hnets, vnets,
    nil, nil, -- no net filter, no excludes
    true
)

return cell

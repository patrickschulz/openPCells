local cell = object.create("toplevel")

local fillcell = object.create("fillcell")
geometry.rectanglebltr(fillcell, generics.other("activefill"),
    point.create(-100, -100),
    point.create( 100,  100)
)
fillcell:set_alignment_box(
    point.create(-200, -200),
    point.create( 200,  200)
)

local filltargetbl = point.create(-2000, -1000)
local filltargettr = point.create( 1000,  10000)
local filltarget = util.rectangle_to_polygon(filltargetbl, filltargettr)

local excludes = {
    util.rectangle_to_polygon(
        point.create(-200, -200),
        point.create(200, 200)
    )
}

for _, exclude in ipairs(excludes) do
    geometry.polygon(cell, generics.special(), exclude)
end

--placement.place_within_boundary(cell, fillcell, "fill", filltarget, excludes)
--placement.place_within_rectangular_boundary(cell, fillcell, "fill", filltargetbl, filltargettr)
geometry.rectangle_fill_in_boundary(cell, generics.metal(1), 100, 100, 200, 200, 0, 0, filltarget, excludes)
geometry.rectanglebltr(cell, generics.special(), filltargetbl, filltargettr)

return cell

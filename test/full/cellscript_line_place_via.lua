local cell = object.create("cell")

cell:add_area_anchor_bltr("guardring1", point.create(0, 0), point.create(1200, 200))
cell:add_area_anchor_bltr("guardring2", point.create(1000, 0), point.create(2800, 200))
cell:add_net_shape("VDD", cell:get_area_anchor("guardring1").bl, cell:get_area_anchor("guardring1").tr, generics.metal(1))
cell:add_net_shape("VDD", cell:get_area_anchor("guardring2").bl, cell:get_area_anchor("guardring2").tr, generics.metal(1))
geometry.rectangleareaanchor(cell, generics.metal(1), "guardring1")
geometry.rectangleareaanchor(cell, generics.metal(1), "guardring2")

local vlines = layouthelpers.place_vlines(
    cell,
    point.create(-500, -500),
    point.create(2500, 1000),
    generics.metal(2),
    500, 500,
    0, -- minheight
    { "VDD" }
)

local netshapes = cell:get_net_shapes("VDD", generics.metal(1))

layouthelpers.place_vias(cell, 1, 2, netshapes, vlines, nil, true)
--layouthelpers.place_vias(cell, 1, 2, netshapes, vlines)

return cell

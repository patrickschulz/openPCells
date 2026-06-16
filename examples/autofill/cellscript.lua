local cell = object.create("cell")

-- create a few shapes to show the autofill
geometry.path_polygon(cell, generics.metal(1), {
    point.create(2500, 0),
    point.create(2500, 2000),
    point.create(4500, 2000),
    point.create(4500, 4000),
    point.create(2500, 6000),
    point.create(2000, 6000),
    point.create(2000, 3000),
    point.create(1000, 3000),
}, 200)
geometry.rectanglebltr(cell, generics.metal(1),
    point.create(500, 500),
    point.create(1500, 1500)
)

return cell

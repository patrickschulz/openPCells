local cell = object.create("toplevel")

geometry.rectanglebltr(cell, generics.metal(1),
    point.create(-100, -100),
    point.create( 100,  100)
)
cell:add_port("test", generics.metal(1), point.create(0, 0))

return cell

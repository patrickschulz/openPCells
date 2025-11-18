local cell = object.create("toplevel")
cell:translate(50, 50)

geometry.rectanglebltr(cell, generics.metal(1), point.create(-50, -50), point.create(50, 50))

cell:add_port("port", generics.metalport(1), point.create(0, 0))

cell:translate(100, 100)

return cell

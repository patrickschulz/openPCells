local cell = object.create("testname")

-- add dummy shape or otherwise the cell is empty
geometry.rectanglebltr(cell, generics.premapped({ gds = { layer = 0, purpose = 0 } }), point.create(0, 0), point.create(100, 100))

return cell

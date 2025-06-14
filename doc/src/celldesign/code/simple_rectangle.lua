-- create cell to collect all shapes
local cell = object.create("toplevel")

-- define parameters
local width = 100
local height = 100

-- create rectangle
geometry.rectanglebltr(
    cell,
    generics.metal(1),
    point.create(0, 0),
    point.create(width, height)
)

-- return created cell
return cell

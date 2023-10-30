local cell = object.create("logo")

local grid = 1000
local scale = 5
local allow45 = true

local function _pt(x, y)
    return point.create(x * scale, y * scale)
end

geometry.curve(cell, generics.metal(-1), _pt(0, 0), {
	curve.lineto(_pt(13000, 0)),
	curve.lineto(_pt(16000, 28000)),
	curve.lineto(_pt(3000, 28000)),
	curve.lineto(_pt(0, 0)),
}, grid, allow45)

geometry.curve(cell, generics.metal(-1), _pt(35000, -4000), {
	curve.cubicto(_pt(40000, -4000), _pt(50000, -4000), _pt(51000, 10000)),
	curve.lineto(_pt(54000, 41000)),
	curve.lineto(_pt(39000, 41000)),
	curve.lineto(_pt(35000, -4000)),
}, grid, allow45)


geometry.curve(cell, generics.metal(-1), _pt(21000, 31000), {
	curve.lineto(_pt(19000, 10000)),
	curve.cubicto(_pt(18000, 0), _pt(28000, -4000), _pt(32000, -4000)),
	curve.lineto(_pt(36000, 37000)),
	curve.cubicto(_pt(36000, 39000), _pt(35000, 45000), _pt(29000, 45000)),
	curve.lineto(_pt(-6000, 45000)),
	curve.cubicto(_pt(-15000, 45000), _pt(-15000, 31000), _pt(-6000, 31000)),
	curve.lineto(_pt(21000, 31000)),
}, grid, allow45)

return cell

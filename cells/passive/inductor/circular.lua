--[[
This pcell draws one turn of a circular inductor.
As circles are usually not possible in mainstream technologies, the shape is approximated by a line-drawing algorithm.
The inductor is defined by two radii, one for the main loop and the second one for the exiting (aux).
--]]
function parameters()
    pcell.add_parameters(
        { "radius(Radius)",                        40000 },
        { "cornerradius(Corner Radius)",           14000 },
        { "width(Width)",                           6000 },
        { "separation(Line Separation)",            6000 },
        { "extension(Line Extension)",             40000 },
        { "grid(Grid)",                              200 },
        { "metalnum(Conductor Metal)",     -1, "integer" },
        { "allow45(Allow Angles with 45 Degrees)",  true }
    )
end

function check(_P)
    if not (_P.width % _P.grid == 0) then
        return false, "width must fit on grid"
    end
    if not (_P.radius % _P.grid == 0) then
        return false, "radius must fit on grid"
    end
    if not ((-0.5 * _P.separation - _P.cornerradius) % _P.grid == 0) then
        return false, "can't fit points on grid with this separation and cornerradius"
    end
    return true
end

function layout(inductor, _P)
    -- calculate center of auxiliary circle
    local xc = 0.5 * _P.separation + _P.cornerradius
    local yc = -_P.grid * math.floor(math.sqrt((_P.radius - _P.width / 2 + _P.cornerradius)^2 - xc^2) / _P.grid)

    -- circle points
    local maininner = graphics.quartercircle(4, point.create(0, 0), _P.radius - _P.width / 2, _P.grid, _P.allow45)
    local auxinner  = graphics.quartercircle(2, point.create(xc, yc), _P.cornerradius, _P.grid, _P.allow45)
    local mainouter = graphics.quartercircle(4, point.create(0, 0), _P.radius + _P.width / 2, _P.grid, _P.allow45)
    local auxouter  = graphics.quartercircle(2, point.create(xc, yc), _P.cornerradius - _P.width, _P.grid, _P.allow45)

    -- meeting points
    local xminner = xc * (_P.radius - _P.width / 2) / (_P.cornerradius + _P.radius - _P.width / 2)
    local xmouter = xc * (_P.radius + _P.width / 2) / (_P.cornerradius + _P.radius - _P.width / 2)

    -- inner part
    local inner = {}
    util.merge_forwards(inner, util.filter_backward(auxinner, function(pt) return pt:getx() < xminner end))
    util.merge_forwards(inner, util.filter_forward(maininner, function(pt) return pt:getx() >= xminner end))
    util.merge_backwards(inner, util.ymirror(maininner))
    util.merge_backwards(inner, util.xmirror(inner))

    -- outer part
    local outer = {}
    util.merge_forwards(outer, util.filter_backward(auxouter, function(pt) return pt:getx() < xmouter end))
    util.merge_forwards(outer, util.filter_forward(mainouter, function(pt) return pt:getx() >= xmouter end))
    util.merge_backwards(outer, util.ymirror(mainouter))
    util.merge_backwards(outer, util.xmirror(outer))

    -- assemble points
    local pts = {}
    util.merge_forwards(pts, outer)
    util.merge_backwards(pts, inner)

    -- create polygon
    geometry.polygon(inductor, generics.metal(_P.metalnum), pts)
end

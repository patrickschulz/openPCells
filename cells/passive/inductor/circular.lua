--[[
This pcell draws one turn of a circular inductor.
As circles are usually not possible in mainstream technologies, the shape is approximated by a line-drawing algorithm.
The inductor is defined by two radii, one for the main loop and the second one for the exiting (aux).
--]]
function parameters()
    pcell.add_parameters(
        { "radius(Radius)",                                         40000 },
        { "cornerradius(Corner Radius)",                            14000 },
        { "width(Width)",                                            6000 },
        { "separation(Line Separation)",                             6000 },
        { "extension(Line Extension)",                              40000 },
        { "grid(Grid)",                                               200 },
        { "metalnum(Conductor Metal)",     -1,                  "integer" },
        { "allow45(Allow Angles with 45 Degrees)",                   true },
        { "drawlvsresistor(Draw LVS Resistor)",                     false },
        { "lvsreswidth(LVS Resistor Width)",                         1000 },
        { "boundaryouterextension(Boundary Outer Extension)",        3000 },
        { "boundaryinnerextension(Boundary Inner Extension)",        3000 },
        { "fillboundary(Fill Boundary)",                             true },
        { "rectangularboundary(Rectangular Boundary)",              false },
        { "breaklines(Break Conductor Lines)",                      false }
    )
end

local function _scale_tanpi8(num)
    return math.floor(num * 5741 / 13860) -- rational approximation of tan(pi / 8)
end

local function _get_outline(radius, width, cornerradius, extension, separation, grid, allow45, breaktrace)
    -- calculate center of auxiliary circle
    local xc = 0.5 * separation + cornerradius
    local yc = -grid * math.floor(math.sqrt((radius - width / 2 + cornerradius)^2 - xc^2) / grid)

    -- circle points
    local maininner = graphics.quartercircle(4, point.create(0, 0), radius - width / 2, grid, allow45)
    local auxinner  = graphics.quartercircle(2, point.create(xc, yc), cornerradius, grid, allow45)
    local mainouter = graphics.quartercircle(4, point.create(0, 0), radius + width / 2, grid, allow45)
    local auxouter  = graphics.quartercircle(2, point.create(xc, yc), cornerradius - width, grid, allow45)

    -- meeting points
    local xminner = xc * (radius - width / 2) / (cornerradius + radius - width / 2)
    local xmouter = xc * (radius + width / 2) / (cornerradius + radius - width / 2)

    -- inner part
    local inner = {}
    table.insert(inner, point.create(separation / 2, -radius - width / 2 - extension))
    util.merge_forwards(inner, util.filter_backward(auxinner, function(pt) return pt:getx() < xminner end))
    util.merge_forwards(inner, util.filter_forward(maininner, function(pt) return pt:getx() >= xminner end))
    util.merge_backwards(inner, util.ymirror(maininner))
    if breaktrace then
        inner[#inner]:translate_x(1)
    end

    -- outer part
    local outer = {}
    table.insert(outer, point.create(separation / 2 + width, -radius - width / 2 - extension))
    util.merge_forwards(outer, util.filter_backward(auxouter, function(pt) return pt:getx() < xmouter end))
    util.merge_forwards(outer, util.filter_forward(mainouter, function(pt) return pt:getx() >= xmouter end))
    util.merge_backwards(outer, util.ymirror(mainouter))
    if breaktrace then
        outer[#outer]:translate_x(1)
    end

    -- assemble points
    local pts = {}
    util.merge_forwards(pts, outer)
    util.merge_backwards(pts, inner)
    return pts
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
    -- FIXME: this check seems to be broken (caused false-positives)
    --if (_P.grid * math.floor(math.sqrt((_P.radius - _P.width / 2 + _P.cornerradius)^2 - (0.5 * _P.separation + _P.cornerradius)^2) / _P.grid)) > _P.radius + _P.width / 2 + _P.extension then
    --    return false, "extension must be large enough to ensure that the rectangular feed lines don't intersect with the circular connectors"
    --end
    return true
end

function layout(inductor, _P)
    local pts = _get_outline(_P.radius, _P.width, _P.cornerradius, _P.extension, _P.separation, _P.grid, _P.allow45, _P.breaklines)

    -- create polygon
    geometry.polygon(inductor, generics.metal(_P.metalnum), pts)
    geometry.polygon(inductor, generics.metal(_P.metalnum), util.xmirror(pts))

    -- input lines anchors
    local lastradius = _P.radius
    inductor:add_area_anchor_bltr("leftline",
        point.create(-_P.separation / 2 - _P.width, -(lastradius + _P.width / 2 + _P.extension)),
        point.create(-_P.separation / 2, -lastradius - _P.width / 2)
    )
    inductor:add_area_anchor_bltr("rightline",
        point.create( _P.separation / 2, -(lastradius + _P.width / 2 + _P.extension)),
        point.create( _P.separation / 2 + _P.width, -lastradius - _P.width / 2)
    )

    -- alignment box
    inductor:set_alignment_box(
        point.create(-_P.radius - _P.width / 2, -_P.radius - _P.width / 2 - _P.extension),
        point.create( _P.radius + _P.width / 2,  _P.radius + _P.width / 2)
    )

    -- boundary
    if _P.rectangularboundary then
        inductor:set_boundary_rectangular(
            point.create(-_P.radius - _P.width / 2 - _P.boundaryouterextension, -_P.radius - _P.width / 2 - _P.boundaryouterextension),
            point.create( _P.radius + _P.width / 2 + _P.boundaryouterextension,  _P.radius + _P.width / 2 + _P.boundaryouterextension)
        )
    else
        local outerradius = _P.radius + _P.width / 2 + _P.boundaryouterextension
        local outerr = _scale_tanpi8(outerradius)
        local innerradius = _P.radius - _P.width / 2 - _P.boundaryinnerextension
        local innerr = _scale_tanpi8(innerradius)
        local outerpathpts = {}
        local outerappend = util.make_insert_xy(outerpathpts)
        -- left
        outerappend(-outerr + _scale_tanpi8(_P.width / 2),  outerradius)
        outerappend(-outerr,  outerradius)
        outerappend(-outerradius,  outerr)
        outerappend(-outerradius, -outerr)
        outerappend(-outerr, -outerradius)
        outerappend(-outerr + _scale_tanpi8(_P.width / 2), -outerradius)
        if not _P.fillboundary then
            outerappend(0, -outerradius)
            outerappend(0, -innerradius)
            outerappend(-innerr + _scale_tanpi8(_P.width / 2), -innerradius)
            outerappend(-innerr, -innerradius)
            outerappend(-innerradius, -innerr)
            outerappend(-innerradius,  innerr)
            outerappend(-innerr,  innerradius)
        end
        -- right
        if not _P.fillboundary then
            outerappend( innerr,  innerradius)
            outerappend( innerradius,  innerr)
            outerappend( innerradius, -innerr)
            outerappend( innerr, -innerradius)
            outerappend(0, -innerradius)
            outerappend(0, -outerradius)
        end
        outerappend( outerr + _scale_tanpi8(_P.width / 2), -outerradius)
        outerappend( outerr, -outerradius)
        outerappend( outerradius, -outerr)
        outerappend( outerradius,  outerr)
        outerappend( outerr,  outerradius)
        outerappend( outerr + _scale_tanpi8(_P.width / 2),  outerradius)
        inductor:set_boundary(outerpathpts)
    end
    -- add layer boundaries
    local innerlayerboundary = graphics.coarse_circle(_P.radius - _P.width / 2 - _P.boundaryinnerextension, 32, -math.pi / 2)
    local outerlayerboundary = graphics.coarse_circle(_P.radius + _P.width / 2 + _P.boundaryouterextension, 32, -math.pi / 2)
    local layerboundary = {}
    util.merge_forwards(layerboundary, innerlayerboundary)
    util.merge_backwards(layerboundary, outerlayerboundary)
    inductor:add_layer_boundary(generics.metal(_P.metalnum), layerboundary)
end

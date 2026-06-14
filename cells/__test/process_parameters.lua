function parameters()
    pcell.add_parameters(
        { "p1", 0 },
        { "p2", 0 }
    )
end

function process_parameters(_P, explicit)
    dprint(explicit)
    -- simple follower parameter
    if not explicit.p2 then
        _P.p2 = _P.p1
    end
end

function layout(cell, _P)
    if _P.p1 > 0 then
        geometry.rectanglebltr(cell, generics.metal(1), point.create(0, 0), point.create(_P.p1, _P.p1))
    end
    if _P.p2 > 0 then
        geometry.rectanglebltr(cell, generics.metal(2), point.create(0, 0), point.create(_P.p2, _P.p2))
    end
end

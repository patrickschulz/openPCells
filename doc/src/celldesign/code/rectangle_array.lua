function parameters()
    pcell.add_parameters(
        { "width",  100 },
        { "height", 100 },
        { "pitch",  200 },
        { "rep",     10 }
    )
end

function layout(obj, _P)
    -- first naive attempt (don't use!)
    for x = 1, _P.rep do
        for y = 1, _P.rep do
            local o = geometry.rectangle(
                obj,
                generics.metal(1), _P.width, _P.height,
                (x - 1) * _P.pitch - (_P.rep - 1) * _P.pitch / 2,
                (y - 1) * _P.pitch - (_P.rep - 1) * _P.pitch / 2
            )
        end
    end

    -- better approach
    geometry.rectangle(obj,
        generics.metal(1), _P.width, _P.height,
        0, 0,
        _P.rep, _P.rep, _P.pitch, _P.pitch
    )
end

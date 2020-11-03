function parameters()
    pcell.add_parameters(
        { "width",  100 },
        { "height", 100 },
        { "pitch",  200 },
        { "rep",     10 }
    )
end

function layout(obj, _P)
    -- first naive (and wrong) attempt (don't use!)
    for i = 1, P.rep do
        for j = 1, P.rep do
            local o = geometry.rectangle(
                generics.metal(1), P.width, P.height
            )
            obj:merge_into(o)
        end
    end

    -- better approach
    obj:merge_into(geometry.multiple(
        geometry.rectangle(generics.metal(1), P.width, P.height),
        P.rep, P.rep, P.pitch, P.pitch
    ))
end

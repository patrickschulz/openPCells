function parameters()
    pcell.add_parameters(
        { "width",  1.0 },
        { "height", 1.0 },
        { "pitch",  2.0 },
        { "rep",    10  }
    )
end

function layout()
    local P = pcell.get_params()

    -- create the main object
    local obj = object.create()

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
    local obj = geometry.multiple(
        geometry.rectangle(generics.metal(1), P.width, P.height),
        P.rep, P.rep, P.pitch, P.pitch
    )

    -- return the object
    return obj
end

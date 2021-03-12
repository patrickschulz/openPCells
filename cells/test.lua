function parameters()
    --[[
    pcell.add_parameters(
        { "foo", 100, posvals = even() },
        { "bar", 100, posvals = set(100, 200) }
    )
    --]]
end

function layout(cell, _P)
    --cell:merge_into(geometry.rectangle(generics.metal(1), _P.foo , _P.foo))
    --cell:merge_into(geometry.rectangle(generics.metal(1), _P.bar , _P.bar))
    cell:merge_into(geometry.rectangle(generics.via(1, 2), 500, 500))
end

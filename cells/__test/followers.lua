function parameters()
    pcell.add_parameters(
        { "a", 0, follow = "b" },
        { "b", 0, follow = "c" },
        { "c", 0, follow = "a" }
    )
end

function layout(cell, _P)

end

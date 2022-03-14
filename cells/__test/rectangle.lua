function parameters()
end

function layout(cell, _P)
    geometry.rectangle(cell, generics.metal(1), 50, 50, 0,  50)
    --geometry.rectangle(cell, generics.metal(1), 50, 50):translate(0, -50)
    --cell:add_anchor("A", point.create(0, 75))
end

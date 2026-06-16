local cell = object.create("cell")

for metal = 1, technology.resolve_metal(-2) do
    geometry.viabltr(cell, metal, metal + 1,
        point.create(0, 0),
        point.create(
            technology.get_dimension(string.format("Minimum M%dM%d Viawidth", metal, metal + 1)),
            technology.get_dimension(string.format("Minimum M%dM%d Viawidth", metal, metal + 1))
        )
    )
end

return cell

local cell = object.create("cell")

geometry.viabltr(cell, 1, 2,
    point.create(0, 0),
    point.create(
        technology.get_dimension("Minimum M1M2 Viawidth"),
        technology.get_dimension("Minimum M1M2 Viawidth")
    )
)

geometry.viabltr(cell, 2, 3,
    point.create(0, 0),
    point.create(
        technology.get_dimension("Minimum M2M3 Viawidth"),
        technology.get_dimension("Minimum M2M3 Viawidth")
    )
)

geometry.viabltr(cell, 3, 4,
    point.create(0, 0),
    point.create(
        technology.get_dimension("Minimum M3M4 Viawidth"),
        technology.get_dimension("Minimum M3M4 Viawidth")
    )
)

return cell

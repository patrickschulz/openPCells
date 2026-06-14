local cell = object.create("overlap_via_test_fail")

geometry.rectanglebltr(cell, generics.metal(1),
    point.create(-70, -130),
    point.create( 70,  130)
)
geometry.rectanglebltr(cell, generics.metal(2),
    point.create(-130, -70),
    point.create( 120,  70)
)
geometry.viabarebltrov(cell, 1, 2,
    point.create(-70, -130),
    point.create( 70,  130),
    point.create(-130, -70),
    point.create( 120,  70)
)

return cell

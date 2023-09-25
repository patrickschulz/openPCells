local cell = object.create("pineapple")

cell:merge_into(pcell.create_layout("auxiliary/svg2layout", "_svg", {
    filename = "pineapple.svg",
    --filename = "test.svg",
    scale = 10,
    allow45 = true,
}))

return cell

local cell = object.create("pineapple")

cell:merge_into(pcell.create_layout("auxiliary/svg2layout", "_svg", {
    filename = "pineapple.svg",
    scale = 1,
    grid = 1,
    allow45 = true,
}))

return cell

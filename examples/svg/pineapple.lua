local cell = object.create("pineapple")

cell:merge_into(pcell.create_layout("auxiliary/svg2layout", "_svg", {
    filename = "pineapple1.svg",
    scale = 1000,
    allow45 = true,
}))

return cell

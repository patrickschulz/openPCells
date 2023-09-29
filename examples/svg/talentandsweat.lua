local cell = object.create("pineapple")

cell:merge_into(pcell.create_layout("auxiliary/svg2layout", "_svg", {
    filename = "talentandsweat.svg",
    scale = 120,
    grid = 1,
    allow45 = true,
    inverty = true,
}))

return cell

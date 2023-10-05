local cell = object.create("gilfoyle")

cell:merge_into(pcell.create_layout("auxiliary/svg2layout", "_svg", {
    filename = "gilfoyle.svg",
    scale = 10,
    grid = 1,
    allow45 = true,
    inverty = true,
}))

return cell

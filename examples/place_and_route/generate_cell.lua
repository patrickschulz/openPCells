local cellname = args[1]
pcell.push_overwrites("basic/mosfet", { actext = 250 })
pcell.push_overwrites("stdcells/base", {
    glength = 100,
    gspace = 150,
    sdwidth = 60,
    pnumtracks = 4,
    nnumtracks = 4,
    numinnerroutes = 3,
    powerwidth = 200,
    routingwidth = 84,
    routingspace = 84,
    drawtopbotwelltaps = false,
})
return pcell.create_layout(string.format("verilogimport/%s", cellname), "cell")

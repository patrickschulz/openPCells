local separation = 420
local powerwidth = 200

return pcell.create_layout("pll/c2mos_frequency_divider", "divider", {
    divisionfactor = 1,
    gatelength = 20,
    gatespace = 84,
    sdwidth = 44,
    powerwidth = powerwidth,
    separation = separation,
    powerspace = (separation - powerwidth) / 2,
    clockfingers = 40,
    inputfingers = 32,
    latchoutersepfingers = 10,
    latchinnersepfingers = 2,
    latchfingers = 6,
    outerdummies = 2,
    clockviaextension = 120,
    drawleftstopgate = true,
    drawrightstopgate = true,
})

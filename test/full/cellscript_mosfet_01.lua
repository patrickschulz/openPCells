local cell = object.create("toplevel")

local commonopts = {
    fingers = 8,
    topgateadjustforsdstraps = true,
    botgateadjustforsdstraps = true,
    sourcemetal = 2,
    drainmetal = 3,
    drawguardring = true,
}

local nmos1 = pcell.create_layout("basic/mosfet", "nmos1", util.add_options(commonopts, {
    channeltype = "nmos",
    drawtopgate = true,
    connectsource = true,
    connectdrain = true,
    instancename = "nmos1",
}))
cell:merge_into(nmos1)

local nmos2 = pcell.create_layout("basic/mosfet", "nmos2", util.add_options(commonopts, {
    channeltype = "nmos",
    drawbotgate = true,
    connectsource = true,
    connectdrain = true,
    instancename = "nmos2",
}))
nmos2:align_bottom(nmos1)
nmos2:place_right(nmos1)
cell:merge_into(nmos2)

local nmos3 = pcell.create_layout("basic/mosfet", "nmos3", util.add_options(commonopts, {
    channeltype = "nmos",
    drawbotgate = true,
    connectsource = true,
    connectsourceinverse = true,
    connectdrain = true,
    instancename = "nmos3",
}))
nmos3:align_bottom(nmos2)
nmos3:place_right(nmos2)
cell:merge_into(nmos3)

local nmos4 = pcell.create_layout("basic/mosfet", "nmos4", util.add_options(commonopts, {
    channeltype = "nmos",
    drawbotgate = true,
    connectsource = true,
    connectdrain = true,
    connectdraininverse = true,
    instancename = "nmos4",
}))
nmos4:align_bottom(nmos3)
nmos4:place_right(nmos3)
cell:merge_into(nmos4)

local nmos5 = pcell.create_layout("basic/mosfet", "nmos5", util.add_options(commonopts, {
    channeltype = "nmos",
    drawbotgate = true,
    connectsource = true,
    connectsourceinverse = true,
    connectdrain = true,
    connectdraininverse = true,
    instancename = "nmos5",
}))
nmos5:align_bottom(nmos4)
nmos5:place_right(nmos4)
cell:merge_into(nmos5)

local nmos6 = pcell.create_layout("basic/mosfet", "nmos6", util.add_options(commonopts, {
    channeltype = "nmos",
    drawbotgate = true,
    connectsource = true,
    connectsourceboth = true,
    connectdrain = true,
    instancename = "nmos6",
}))
nmos6:align_bottom(nmos5)
nmos6:place_right(nmos5)
cell:merge_into(nmos6)

local nmos7 = pcell.create_layout("basic/mosfet", "nmos7", util.add_options(commonopts, {
    channeltype = "nmos",
    drawbotgate = true,
    connectsource = true,
    connectsourceboth = true,
    connectdrain = true,
    connectdrainboth = true,
    instancename = "nmos7",
}))
nmos7:align_bottom(nmos6)
nmos7:place_right(nmos6)
cell:merge_into(nmos7)

local nmos8 = pcell.create_layout("basic/mosfet", "nmos8", util.add_options(commonopts, {
    channeltype = "nmos",
    drawbotgate = true,
    connectsource = true,
    connectsourceboth = true,
    connectdrain = true,
    connectdrainboth = true,
    connectdrainleftext = 200,
    connectdrainrightext = 200,
    instancename = "nmos8",
}))
nmos8:align_bottom(nmos7)
nmos8:place_right(nmos7)
cell:merge_into(nmos8)

local pmos1 = pcell.create_layout("basic/mosfet", "pmos1", util.add_options(commonopts, {
    channeltype = "pmos",
    drawtopgate = true,
    connectsource = true,
    connectdrain = true,
    instancename = "pmos1",
}))
pmos1:align_left(nmos1)
pmos1:place_top(nmos1)
pmos1:translate_y(500)
cell:merge_into(pmos1)

local pmos2 = pcell.create_layout("basic/mosfet", "pmos2", util.add_options(commonopts, {
    channeltype = "pmos",
    drawbotgate = true,
    connectsource = true,
    connectdrain = true,
    instancename = "pmos2",
}))
pmos2:align_bottom(pmos1)
pmos2:place_right(pmos1)
cell:merge_into(pmos2)

local pmos3 = pcell.create_layout("basic/mosfet", "pmos3", util.add_options(commonopts, {
    channeltype = "pmos",
    drawbotgate = true,
    connectsource = true,
    connectsourceinverse = true,
    connectdrain = true,
    instancename = "pmos3",
}))
pmos3:align_bottom(pmos2)
pmos3:place_right(pmos2)
cell:merge_into(pmos3)

local pmos4 = pcell.create_layout("basic/mosfet", "pmos4", util.add_options(commonopts, {
    channeltype = "pmos",
    drawbotgate = true,
    connectsource = true,
    connectdrain = true,
    connectdraininverse = true,
    instancename = "pmos4",
}))
pmos4:align_bottom(pmos3)
pmos4:place_right(pmos3)
cell:merge_into(pmos4)

local pmos5 = pcell.create_layout("basic/mosfet", "pmos5", util.add_options(commonopts, {
    channeltype = "pmos",
    drawbotgate = true,
    connectsource = true,
    connectsourceinverse = true,
    connectdrain = true,
    connectdraininverse = true,
    instancename = "pmos5",
}))
pmos5:align_bottom(pmos4)
pmos5:place_right(pmos4)
cell:merge_into(pmos5)

local pmos6 = pcell.create_layout("basic/mosfet", "pmos6", util.add_options(commonopts, {
    channeltype = "pmos",
    drawbotgate = true,
    connectsource = true,
    connectsourceboth = true,
    connectdrain = true,
    instancename = "pmos6",
}))
pmos6:align_bottom(pmos5)
pmos6:place_right(pmos5)
cell:merge_into(pmos6)

local pmos7 = pcell.create_layout("basic/mosfet", "pmos7", util.add_options(commonopts, {
    channeltype = "pmos",
    drawbotgate = true,
    connectsource = true,
    connectsourceboth = true,
    connectdrain = true,
    connectdrainboth = true,
    instancename = "pmos7",
}))
pmos7:align_bottom(pmos6)
pmos7:place_right(pmos6)
cell:merge_into(pmos7)

local pmos8 = pcell.create_layout("basic/mosfet", "pmos8", util.add_options(commonopts, {
    channeltype = "pmos",
    drawbotgate = true,
    connectsource = true,
    connectsourceboth = true,
    connectsourceleftext = 200,
    connectsourcerightext = 200,
    connectdrain = true,
    connectdrainboth = true,
    instancename = "pmos8",
}))
pmos8:align_bottom(pmos7)
pmos8:place_right(pmos7)
cell:merge_into(pmos8)

return cell

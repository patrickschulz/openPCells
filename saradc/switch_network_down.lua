local cell = object.create("toplevel")

local buffingers = 2
local switchfingers = 8
local gatelength = 20
local gatespace = 84
local fingerwidth = 500
local nfetvthtype = 1
local pfetvthtype = 3
local sdwidth = 40
local sdspace = 80


local swdown7 = pcell.create_layout("SAR_ADC/switch_network_down", "swdown7", {
	buffingers = buffingers,
	switchfingers = switchfingers,
	gatelength = gatelength,
	gatespace = gatespace,
	fingerwidth = fingerwidth,
	nfetvthtype = nfetvthtype,
	pfetvthtype = pfetvthtype,
	sdwidth = sdwidth,
	sdspace = sdspace,
	gstrwidth = sdwidth,
	gstrspace = sdspace,
	powerwidth = 3 * sdwidth,
	powerspace = 3 * sdspace
})

cell:merge_into_shallow(swdown7:flatten())

--[[

cell:add_port("VDD", generics.metalport(1), swdown7:get_anchor("VDD"))
cell:add_port("VSS", generics.metalport(1), swdown7:get_anchor("VSS"))
cell:add_port("sample", generics.metalport(1), swdown7:get_anchor("sample"))
cell:add_port("vin", generics.metalport(3), swdown7:get_anchor("vin"))
cell:add_port("vout", generics.metalport(3), swdown7:get_anchor("vout"))
cell:add_port("data", generics.metalport(1), swdown7:get_anchor("data"))
cell:add_port("REF", generics.metalport(2), swdown7:get_anchor("REF"))
cell:add_port("GND", generics.metalport(2), swdown7:get_anchor("GND"))
cell:add_port("VSS", generics.otherport("nwell"), point.create(0, -1500))
--]]

return swdown7






--[[
local cell = object.create("toplevel")

local buffingers = 2
local switchfingers = 8
local gatelength = 20
local gatespace = 84
local fingerwidth = 500
local nfetvthtype = 1
local pfetvthtype = 3
local sdwidth = 40
local sdspace = 80

local gstrwidth = sdwidth
local gstrspace = sdspace
local powerwidth = 3 * sdwidth
local powerspace = 3 * sdspace

--buffer1 
local pmosbuf1 = pcell.create_layout("basic/mosfet", "pmosbuf1", {
        channeltype = "pmos",
        flippedwell = false,
        vthtype = pfetvthtype,
        drawbotgate = true,
        botgatestrwidth = gstrwidth,
        botgatestrspace = gstrspace,
	botgateextendhalfspace = true,
        fingers = buffingers,
        fwidth = fingerwidth,
        connectsource = true,
        connsourcemetal = 1,
        connsourcewidth = powerwidth,
        connsourcespace = powerspace,
--        connectdrain = true,
        conndrainmetal = 2,
        drawdrainvia = true,
        conndraininline = true,
        extendimplantbot = gstrspace / 2,
        extendvthbot = gstrspace / 2,
	extendwellbot = gstrspace / 2,
	gtopext = 2 * powerspace + powerwidth,
        gbotext = gstrspace + gstrwidth,
--        drawleftstopgate = true,
--        leftpolylines = { { 20, 84 }, { 32, 100 } },
    })

local nmosbuf1 = pcell.create_layout("basic/mosfet", "nmosbuf1", {
        channeltype = "nmos",
        flippedwell = true,
        vthtype = nfetvthtype,
        drawtopgate = true,
        topgatestrwidth = gstrwidth,
        topgatestrspace = 2 * gstrspace + gstrwidth,
	topgateextendhalfspace = true,
        fingers = buffingers,
        fwidth = fingerwidth,
        connectsource = true,
        connsourcemetal = 1,
        connsourcewidth = powerwidth,
        connsourcespace = powerspace,
--        connectdrain = true,
        conndrainmetal = 2,
        drawdrainvia = true,
        conndraininline = true,
        extendimplanttop = - gstrwidth - gstrspace / 2,
        extendvthtop = - gstrwidth - gstrspace / 2,
	extendwelltop = - gstrwidth - gstrspace / 2,
	gbotext = 2 * powerspace + powerwidth,
--        drawleftstopgate = true,
--        leftpolylines = { { 20, 84 }, { 32, 100 } },
    })

--dummy1
local pmosdummy1 = pcell.create_layout("basic/mosfet", "pmosdummy1", {
        channeltype = "pmos",
        flippedwell = _false,
        vthtype = pfetvthtype,
	fingers = 1, 
        fwidth = fingerwidth,
        drawtopgate = true,
        topgatestrwidth = powerwidth,
        topgatestrspace = powerspace,
	topgateextendhalfspace = true,
        gtopext = 2 * powerspace + powerwidth,
	gbotext = 1.5 * gstrspace + gstrwidth,
        drawbotgcut = true,
    })
local nmosdummy1 = pcell.create_layout("basic/mosfet", "nmosdummy1", {
	channeltype = "nmos",
        flippedwell = true,
        vthtype = nfetvthtype,
        fingers = 1,
        fwidth = fingerwidth,
        drawbotgate = true,
        botgatestrwidth = powerwidth,
        botgatestrspace = powerspace,
	botgateextendhalfspace = true,
	gtopext = 1.5 * gstrspace + gstrwidth,
        gbotext = powerwidth + 2 * powerspace,

    })

--buffer2
local pmosbuf2 = pcell.create_layout("basic/mosfet", "pmosbuf2", {
        channeltype = "pmos",
        flippedwell = false,
        vthtype = pfetvthtype,
        drawbotgate = true,
        botgatestrwidth = gstrwidth,
        botgatestrspace = 2 * gstrspace + gstrwidth,
	topgateextendhalfspace = true,
        fingers = buffingers,
        fwidth = fingerwidth,
        connectsource = true,
        connsourcemetal = 1,
        drawsourcevia = true,
        connsourcewidth = powerwidth,
        connsourcespace = powerspace,
--        connectdrain = true,
        conndrainmetal = 2,
        drawdrainvia = true,
        conndraininline = true,
        extendimplantbot = - gstrwidth - gstrspace / 2,
        extendvthbot = - gstrwidth - gstrspace / 2,
	extendwellbot = - gstrwidth - gstrspace / 2,
	gtopext = 2 * powerspace + powerwidth,
        gbotext = gstrspace + gstrwidth,
--        drawleftstopgate = true,
--        leftpolylines = { { 20, 84 }, { 32, 100 } },
    })

local nmosbuf2 = pcell.create_layout("basic/mosfet", "nmosbuf2", {
        channeltype = "nmos",
        flippedwell = true,
        vthtype = nfetvthtype,
        drawtopgate = true,
        topgatestrwidth = gstrwidth,
        topgatestrspace = gstrspace,
	topgateextendhalfspace = true,
        fingers = buffingers,
        fwidth = fingerwidth,
        connectsource = true,
        connsourcemetal = 1,
        drawsourcevia = true,
        connsourcewidth = powerwidth,
        connsourcespace = powerspace,
--        connectdrain = true,
        conndrainmetal = 2,
        drawdrainvia = true,
        conndraininline = true,
        extendimplanttop = gstrspace / 2,
        extendvthtop = gstrspace / 2,
	extendwelltop = gstrspace / 2,
	gbotext = 2 * powerspace + powerwidth,
--        drawleftstopgate = true,
--        leftpolylines = { { 20, 84 }, { 32, 100 } },
    })


--dummy2
local pmosdummy2 = pmosdummy1:copy()
local nmosdummy2 = nmosdummy1:copy()

--sample_bb as gate
local pmosvd = pcell.create_layout("basic/mosfet", "pmosvd", {
        channeltype = "pmos",
        flippedwell = false,
        vthtype = pfetvthtype,
        drawbotgate = true,
        botgatestrwidth = gstrwidth,
        botgatestrspace = gstrspace,
	botgateextendhalfspace = true,
        fingers = switchfingers,
        fwidth = fingerwidth,
        connectsource = true,
        connsourcemetal = 1,
        connsourcewidth = 2 * sdwidth,
        connsourcespace = sdspace,
        connectdrain = true,
        conndrainmetal = 2,
        drawdrainvia = true,
        conndraininline = true,
        extendimplantbot = gstrspace / 2,
        extendvthbot = gstrspace / 2,
	extendwellbot = gstrspace / 2,
	gtopext = 2 * powerspace + powerwidth,
        gbotext = gstrspace + gstrwidth,
--        drawleftstopgate = true,
--        leftpolylines = { { 20, 84 }, { 32, 100 } },
    })

local nmosvin = pcell.create_layout("basic/mosfet", "nmosvin", {
        channeltype = "nmos",
        flippedwell = true,
        vthtype = nfetvthtype,
        drawtopgate = true,
        topgatestrwidth = gstrwidth,
        topgatestrspace = 2 * gstrspace + gstrwidth,
	topgateextendhalfspace = true,
        fingers = switchfingers,
        fwidth = fingerwidth,
        connectsource = true,
        connsourcemetal = 1,
        connsourcewidth = 2 * sdwidth,
        connsourcespace = sdspace,
        connectdrain = true,
        conndrainmetal = 2,
        drawdrainvia = true,
        conndraininline = true,
        extendimplanttop = - gstrwidth - gstrspace / 2,
        extendvthtop = - gstrwidth - gstrspace / 2,
	extendwelltop = - gstrwidth - gstrspace / 2,
	gbotext = 2 * powerspace + powerwidth,
--        drawleftstopgate = true,
--        leftpolylines = { { 20, 84 }, { 32, 100 } },
    })

--dummy3
local pmosdummy3 = pmosdummy1:copy()
local nmosdummy3 = nmosdummy1:copy()

--sample_b as gate
local pmosvin = pcell.create_layout("basic/mosfet", "pmosvin", {
        channeltype = "pmos",
        flippedwell = false,
        vthtype = pfetvthtype,
        drawbotgate = true,
        botgatestrwidth = gstrwidth,
        botgatestrspace = 2 * gstrspace + gstrwidth,
	topgateextendhalfspace = true,
        fingers = switchfingers,
        fwidth = fingerwidth,
        connectsource = true,
        connsourcemetal = 1,
        drawsourcevia = true,
        connsourcewidth = 2 * sdwidth,
        connsourcespace = sdspace,
        connectdrain = true,
        conndrainmetal = 2,
        drawdrainvia = true,
        conndraininline = true,
        extendimplantbot = - gstrwidth - gstrspace / 2,
        extendvthbot = - gstrwidth - gstrspace / 2,
	extendwellbot = - gstrwidth - gstrspace / 2,
	gtopext = 2 * powerspace + powerwidth,
        gbotext = gstrspace + gstrwidth,
--        drawleftstopgate = true,
--        leftpolylines = { { 20, 84 }, { 32, 100 } },
    })

local nmosvd = pcell.create_layout("basic/mosfet", "nmosvd", {
        channeltype = "nmos",
        flippedwell = true,
        vthtype = nfetvthtype,
        drawtopgate = true,
        topgatestrwidth = gstrwidth,
        topgatestrspace = gstrspace,
	topgateextendhalfspace = true,
        fingers = switchfingers,
        fwidth = fingerwidth,
        connectsource = true,
        connsourcemetal = 1,
        drawsourcevia = true,
        connsourcewidth = 2 * sdwidth,
        connsourcespace = sdspace,
        connectdrain = true,
        conndrainmetal = 2,
        drawdrainvia = true,
        conndraininline = true,
        extendimplanttop = gstrspace / 2,
        extendvthtop = gstrspace / 2,
	extendwelltop = gstrspace / 2,
	gbotext = 2 * powerspace + powerwidth,
--        drawleftstopgate = true,
--        leftpolylines = { { 20, 84 }, { 32, 100 } },
    })


--dummy4
local pmosdummy4 = pmosdummy1:copy()
local nmosdummy4 = nmosdummy1:copy()

--switch data
local pmosrefin = pmosvd:copy()
local nmosgndin = nmosvin:copy()

--dummy5
local pmosdummy5 = pmosdummy1:copy()
local nmosdummy5 = nmosdummy1:copy()

--buffer3
local pmosbuf3 = pcell.create_layout("basic/mosfet", "pmosvin", {
        channeltype = "pmos",
        flippedwell = false,
        vthtype = pfetvthtype,
        drawbotgate = true,
        botgatestrwidth = gstrwidth,
        botgatestrspace = 2 * gstrspace + gstrwidth,
	topgateextendhalfspace = true,
        fingers = buffingers,
        fwidth = fingerwidth,
        connectsource = true,
        connsourcemetal = 1,
        drawsourcevia = true,
        connsourcewidth = powerwidth,
        connsourcespace = powerspace,
        connectdrain = true,
        conndrainmetal = 2,
        drawdrainvia = true,
        conndraininline = true,
        extendimplantbot = - gstrwidth - gstrspace / 2,
        extendvthbot = - gstrwidth - gstrspace / 2,
	extendwellbot = - gstrwidth - gstrspace / 2,
	gtopext = 2 * powerspace + powerwidth,
        gbotext = gstrspace + gstrwidth,
--        drawleftstopgate = true,
--        leftpolylines = { { 20, 84 }, { 32, 100 } },
    })

local nmosbuf3 = pcell.create_layout("basic/mosfet", "nmosvd", {
        channeltype = "nmos",
        flippedwell = true,
        vthtype = nfetvthtype,
        drawtopgate = true,
        topgatestrwidth = gstrwidth,
        topgatestrspace = gstrspace,
	topgateextendhalfspace = true,
        fingers = buffingers,
        fwidth = fingerwidth,
        connectsource = true,
        connsourcemetal = 1,
        drawsourcevia = true,
        connsourcewidth = powerwidth,
        connsourcespace = powerspace,
        connectdrain = true,
        conndrainmetal = 2,
        drawdrainvia = true,
        conndraininline = true,
        extendimplanttop = gstrspace / 2,
        extendvthtop = gstrspace / 2,
	extendwelltop = gstrspace / 2,
	gbotext = 2 * powerspace + powerwidth,
--        drawleftstopgate = true,
--        leftpolylines = { { 20, 84 }, { 32, 100 } },
    })



nmosbuf1:move_anchor("topgatestrapcc", pmosbuf1:get_anchor("botgatestrapcc"))
pmosdummy1:move_anchor("sourcedrainleftcc", pmosbuf1:get_anchor("sourcedrainrightcc"))
nmosdummy1:move_anchor("sourcedrainleftcc", nmosbuf1:get_anchor("sourcedrainrightcc"))
pmosbuf2:move_anchor("sourcedrainleftcc", pmosdummy1:get_anchor("sourcedrainrightcc"))
nmosbuf2:move_anchor("topgatestrapcc", pmosbuf2:get_anchor("botgatestrapcc"))
pmosdummy2:move_anchor("sourcedrainleftcc", pmosbuf2:get_anchor("sourcedrainrightcc"))
nmosdummy2:move_anchor("sourcedrainleftcc", nmosbuf2:get_anchor("sourcedrainrightcc"))

pmosvd:move_anchor("sourcedrainleftcc", pmosdummy2:get_anchor("sourcedrainrightcc"))
nmosvin:move_anchor("sourcedrainleftcc", nmosdummy2:get_anchor("sourcedrainrightcc"))
pmosdummy3:move_anchor("sourcedrainleftcc", pmosvd:get_anchor("sourcedrainrightcc"))
nmosdummy3:move_anchor("sourcedrainleftcc", nmosvin:get_anchor("sourcedrainrightcc"))

pmosvin:move_anchor("sourcedrainleftcc", pmosdummy3:get_anchor("sourcedrainrightcc"))
nmosvd:move_anchor("sourcedrainleftcc", nmosdummy3:get_anchor("sourcedrainrightcc"))
pmosdummy4:move_anchor("sourcedrainleftcc", pmosvin:get_anchor("sourcedrainrightcc"))
nmosdummy4:move_anchor("sourcedrainleftcc", nmosvd:get_anchor("sourcedrainrightcc"))

pmosrefin:move_anchor("sourcedrainleftcc", pmosdummy4:get_anchor("sourcedrainrightcc"))
nmosgndin:move_anchor("sourcedrainleftcc", nmosdummy4:get_anchor("sourcedrainrightcc"))
pmosdummy5:move_anchor("sourcedrainleftcc", pmosrefin:get_anchor("sourcedrainrightcc"))
nmosdummy5:move_anchor("sourcedrainleftcc", nmosgndin:get_anchor("sourcedrainrightcc"))

pmosbuf3:move_anchor("sourcedrainleftcc", pmosdummy5:get_anchor("sourcedrainrightcc"))
nmosbuf3:move_anchor("sourcedrainleftcc", nmosdummy5:get_anchor("sourcedrainrightcc"))

--connect VDD VSS
geometry.path(pmosbuf1, generics.metal(1),{
	pmosbuf1:get_anchor("sourcestrapcr"), 
	pmosdummy5:get_anchor("topgatestrapcr")
    }, powerwidth)

geometry.path(nmosbuf1, generics.metal(1),{
	nmosbuf1:get_anchor("sourcestrapcr"), 
	nmosdummy5:get_anchor("botgatestrapcr")
    }, powerwidth)

--connect buffer1 and 2
geometry.path(pmosbuf1, generics.metal(2),{
	pmosbuf1:get_anchor("sourcedrain2bc"), 
	nmosbuf1:get_anchor("sourcedrain2bc")
    }, sdwidth)
geometry.viabltr(nmosdummy1, 1, 2, 
	point.combine_12(nmosdummy1:get_anchor("sourcedrainlefttl"),pmosbuf2:get_anchor("botgatestrapbl")),
	nmosbuf2:get_anchor("topgatestraptl")
    )
geometry.path(pmosbuf1, generics.metal(2),{
	point.combine_12(pmosbuf1:get_anchor("sourcedrain2tr"),pmosbuf2:get_anchor("botgatestrapcr")),
	nmosbuf2:get_anchor("topgatestrapcl")
    }, sdwidth)

--connect sample_b and sample_bb 
geometry.path(pmosbuf2, generics.metal(2),{
	pmosbuf2:get_anchor("sourcedrain2bc"), 
	nmosbuf2:get_anchor("sourcedrain2bc")
    }, sdwidth)
geometry.viabltr(nmosdummy2, 1, 2, 
	point.combine_12(nmosdummy2:get_anchor("sourcedrainlefttl"),pmosvd:get_anchor("botgatestrapbl")),
	nmosvin:get_anchor("topgatestraptl")
    )
geometry.path(pmosbuf2, generics.metal(2),{
	point.combine_12(pmosbuf2:get_anchor("sourcedrain2tr"),pmosvd:get_anchor("botgatestrapcr")),
	nmosvin:get_anchor("topgatestrapcl")
    }, sdwidth)
geometry.path(nmosbuf2, generics.metal(1),{
	nmosbuf2:get_anchor("topgatestrapcr"),
	nmosvd:get_anchor("topgatestrapcl")
    }, sdwidth)

--connect drain of transgate
geometry.path(pmosvd, generics.metal(2),{
	pmosvd:get_anchor("sourcedrain2cr"), 
	pmosvin:get_anchor("sourcedrain2cl")
    }, sdwidth)
geometry.path(nmosvin, generics.metal(2),{
	nmosvin:get_anchor("sourcedrain2cr"), 
	nmosvd:get_anchor("sourcedrain2cl")
    }, sdwidth)
geometry.path(pmosvd, generics.metal(2),{
	pmosvd:get_anchor("sourcedrainrightcc"):translate(0.5 * gatespace + 0.5 * gatelength, 0), 
	nmosvin:get_anchor("sourcedrainrightcc"):translate(0.5 * gatespace + 0.5 * gatelength, 0)
    }, sdwidth)
geometry.path(pmosrefin, generics.metal(2),{
	pmosrefin:get_anchor("sourcedrain2bc"), 
	nmosgndin:get_anchor("sourcedrain2tc")
    }, sdwidth)
geometry.path_cshape(nmosgndin, generics.metal(2),
	nmosgndin:get_anchor("sourcedrain2bc"), 
	nmosvd:get_anchor("sourcestrapcr"), 
	point.combine_12(nmosgndin:get_anchor("sourcedrain2bc"),nmosvd:get_anchor("sourcestrapcr")), 
    sdwidth)


--connect source of transgate
geometry.viabltr(pmosvd, 1, 3, 
	pmosvd:get_anchor("sourcestrapbl"),
	pmosvd:get_anchor("sourcestraptr")
    )
geometry.viabltr(nmosvd, 1, 3, 
	nmosvd:get_anchor("sourcestrapbl"),
	nmosvd:get_anchor("sourcestraptr")
    )
geometry.viabltr(pmosvin, 1, 4, 
	pmosvin:get_anchor("sourcestrapbc"),
	pmosvin:get_anchor("sourcestraptr")
    )
geometry.viabltr(nmosvin, 1, 4, 
	nmosvin:get_anchor("sourcestrapbl"),
	nmosvin:get_anchor("sourcestraptc")
    )
geometry.path(pmosvd, generics.metal(2),{
	pmosvd:get_anchor("sourcedrain2cr"), 
	pmosvin:get_anchor("sourcedrain2cl")
    }, sdwidth)

geometry.path_cshape(pmosvd, generics.metal(3),
	pmosvd:get_anchor("sourcestrapcr"), 
	nmosvd:get_anchor("sourcestrapbl"), 
	nmosvd:get_anchor("sourcestrapbl"), 
    2 * sdwidth)
geometry.path_cshape(pmosvin, generics.metal(4),
	pmosvin:get_anchor("sourcestrapcc"), 
	nmosvin:get_anchor("sourcestrapbc"), 
	nmosvin:get_anchor("sourcestrapbc"), 
    2 * sdwidth)

--connect buffer3
geometry.path(pmosbuf3, generics.metal(2),{
	pmosbuf3:get_anchor("sourcedrain2bc"), 
	nmosbuf3:get_anchor("sourcedrain2bc")
    }, sdwidth)
geometry.viabltr(pmosrefin, 1, 2, 
	pmosrefin:get_anchor("botgatestrapbc"),
	pmosrefin:get_anchor("botgatestraptr")
    )
geometry.path(pmosrefin, generics.metal(2),{
	point.combine_12(pmosbuf3:get_anchor("sourcedrain2bc"),pmosrefin:get_anchor("botgatestrapcr")),
	pmosrefin:get_anchor("botgatestrapcr")
    }, sdwidth)


cell:merge_into_shallow(nmosbuf1:flatten())
cell:merge_into_shallow(pmosbuf1:flatten())
cell:merge_into_shallow(pmosdummy1:flatten())
cell:merge_into_shallow(nmosdummy1:flatten())
cell:merge_into_shallow(nmosbuf2:flatten())
cell:merge_into_shallow(pmosbuf2:flatten())
cell:merge_into_shallow(pmosdummy2:flatten())
cell:merge_into_shallow(nmosdummy2:flatten())
cell:merge_into_shallow(nmosvin:flatten())
cell:merge_into_shallow(pmosvin:flatten())
cell:merge_into_shallow(pmosdummy3:flatten())
cell:merge_into_shallow(nmosdummy3:flatten())
cell:merge_into_shallow(nmosvd:flatten())
cell:merge_into_shallow(pmosvd:flatten())
cell:merge_into_shallow(pmosdummy4:flatten())
cell:merge_into_shallow(nmosdummy4:flatten())
cell:merge_into_shallow(nmosgndin:flatten())
cell:merge_into_shallow(pmosrefin:flatten())
cell:merge_into_shallow(pmosdummy5:flatten())
cell:merge_into_shallow(nmosdummy5:flatten())
cell:merge_into_shallow(nmosbuf3:flatten())
cell:merge_into_shallow(pmosbuf3:flatten())

--add port
cell:add_port("VDD", generics.metalport(1), pmosbuf1:get_anchor("sourcestrapcc"))
cell:add_port("VSS", generics.metalport(1), nmosbuf1:get_anchor("sourcestrapcc"))
cell:add_port("sample", generics.metalport(1), pmosbuf1:get_anchor("botgatestrapcc"))
cell:add_port("vin", generics.metalport(1), nmosvin:get_anchor("sourcestrapcc"))
cell:add_port("vout", generics.metalport(1), nmosvd:get_anchor("sourcedrain2cc"))
cell:add_port("data", generics.metalport(1), pmosbuf3:get_anchor("botgatestrapcc"))
cell:add_port("REF", generics.metalport(1), pmosrefin:get_anchor("sourcestrapcc"))
cell:add_port("GND", generics.metalport(1), nmosgndin:get_anchor("sourcestrapcc"))
cell:add_port("VSS", generics.otherport("nwell"), point.create(0, -1500))

return cell

--]]

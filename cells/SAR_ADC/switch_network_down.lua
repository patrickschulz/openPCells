function parameters()
    pcell.add_parameters(
        { "gatelength", technology.get_dimension("Minimum Gate Length") },
        { "gatespace", technology.get_dimension("Minimum Gate XSpace") },
        { "fingerwidth", technology.get_dimension("Minimum Gate Width") },
        { "buffingers", 2 },
        { "switchfingers", 8 },
        { "pfetvthtype", 3 },
        { "nfetvthtype", 1 },
        { "sdwidth", technology.get_dimension("Minimum M1 Width") },
        { "sdspace", technology.get_dimension("Minimum M1 Space") },
        { "gstrwidth", technology.get_dimension("Minimum M1 Width") },
        { "gstrspace", technology.get_dimension("Minimum M1 Space") },
        { "powerwidth", 3 * technology.get_dimension("Minimum M1 Width") },
        { "powerspace", 3 * technology.get_dimension("Minimum M1 Space") }
    )
end

function layout(switch, _P)
	--buffer1
	local pmosbuf1 = pcell.create_layout("basic/mosfet", "pmosbuf1", {
		channeltype = "pmos",
		flippedwell = false,
		vthtype = _P.pfetvthtype,
		drawbotgate = true,
		botgatestrwidth = _P.gstrwidth,
		botgatestrspace = _P.gstrspace,
		botgateextendhalfspace = true,
		fingers = _P.buffingers,
		fingerwidth = _P.fingerwidth,
		connectsource = true,
		connsourcemetal = 1,
		connsourcewidth = _P.powerwidth,
		connsourcespace = _P.powerspace,
		conndrainmetal = 2,
		drawdrainvia = true,
		conndraininline = true,
		extendimplantbot = _P.gstrspace / 2,
		extendvthbot = _P.gstrspace / 2,
		extendwellbot = _P.gstrspace / 2,
		gtopext = 1.5 * _P.powerspace + _P.powerwidth,
		gbotext = _P.gstrspace + _P.gstrwidth,
	    })

	local nmosbuf1 = pcell.create_layout("basic/mosfet", "nmosbuf1", {
		channeltype = "nmos",
		flippedwell = true,
		vthtype = _P.nfetvthtype,
		drawtopgate = true,
		topgatestrwidth = _P.gstrwidth,
		topgatestrspace = 2 * _P.gstrspace + _P.gstrwidth,
		topgateextendhalfspace = true,
		fingers = _P.buffingers,
		fingerwidth = _P.fingerwidth,
		connectsource = true,
		connsourcemetal = 1,
		connsourcewidth = _P.powerwidth,
		connsourcespace = _P.powerspace,
		conndrainmetal = 2,
		drawdrainvia = true,
		conndraininline = true,
		extendimplanttop = - _P.gstrwidth - _P.gstrspace / 2,
		extendvthtop = - _P.gstrwidth - _P.gstrspace / 2,
		extendwelltop = - _P.gstrwidth - _P.gstrspace / 2,
		gbotext = 1.5 * _P.powerspace + _P.powerwidth,
		drawbotgcut = true,
		cutheight = _P.gstrspace,
	    })

	--dummy1
	local pmosdummy1 = pcell.create_layout("basic/mosfet", "pmosdummy1", {
		channeltype = "pmos",
		flippedwell = _false,
		vthtype = _P.pfetvthtype,
		fingers = 1,
		fingerwidth = _P.fingerwidth,
		drawtopgate = true,
		topgatestrwidth = _P.powerwidth,
		topgatestrspace = _P.powerspace,
		topgateextendhalfspace = true,
		gtopext = 1.5 * _P.powerspace + _P.powerwidth,
		gbotext = 1.5 * _P.gstrspace + _P.gstrwidth,
		drawbotgcut = true,
		cutheight = _P.gstrspace,
	    })
	local nmosdummy1 = pcell.create_layout("basic/mosfet", "nmosdummy1", {
		channeltype = "nmos",
		flippedwell = true,
		vthtype = _P.nfetvthtype,
		fingers = 1,
		fingerwidth = _P.fingerwidth,
		drawbotgate = true,
		botgatestrwidth = _P.powerwidth,
		botgatestrspace = _P.powerspace,
		botgateextendhalfspace = true,
		gtopext = 1.5 * _P.gstrspace + _P.gstrwidth,
		gbotext = _P.powerwidth + 1.5 * _P.powerspace,
		drawbotgcut = true,
		cutheight = _P.gstrspace,
	    })

	--buffer2
	local pmosbuf2 = pcell.create_layout("basic/mosfet", "pmosbuf2", {
		channeltype = "pmos",
		flippedwell = false,
		vthtype = _P.pfetvthtype,
		drawbotgate = true,
		botgatestrwidth = _P.gstrwidth,
		botgatestrspace = 2 * _P.gstrspace + _P.gstrwidth,
		topgateextendhalfspace = true,
		fingers = _P.buffingers,
		fingerwidth = _P.fingerwidth,
		connectsource = true,
		connsourcemetal = 1,
		drawsourcevia = true,
		connsourcewidth = _P.powerwidth,
		connsourcespace = _P.powerspace,
		conndrainmetal = 2,
		drawdrainvia = true,
		conndraininline = true,
		extendimplantbot = - _P.gstrwidth - _P.gstrspace / 2,
		extendvthbot = - _P.gstrwidth - _P.gstrspace / 2,
		extendwellbot = - _P.gstrwidth - _P.gstrspace / 2,
		gtopext = 1.5 * _P.powerspace + _P.powerwidth,
		gbotext = _P.gstrspace + _P.gstrwidth,
	    })

	local nmosbuf2 = pcell.create_layout("basic/mosfet", "nmosbuf2", {
		channeltype = "nmos",
		flippedwell = true,
		vthtype = _P.nfetvthtype,
		drawtopgate = true,
		topgatestrwidth = _P.gstrwidth,
		topgatestrspace = _P.gstrspace,
		topgateextendhalfspace = true,
		fingers = _P.buffingers,
		fingerwidth = _P.fingerwidth,
		connectsource = true,
		connsourcemetal = 1,
		drawsourcevia = true,
		connsourcewidth = _P.powerwidth,
		connsourcespace = _P.powerspace,
		conndrainmetal = 2,
		drawdrainvia = true,
		conndraininline = true,
		extendimplanttop = _P.gstrspace / 2,
		extendvthtop = _P.gstrspace / 2,
		extendwelltop = _P.gstrspace / 2,
		gbotext = 1.5 * _P.powerspace + _P.powerwidth,
		drawbotgcut = true,
		cutheight = _P.gstrspace,
	    })


	--dummy2
	local pmosdummy2 = pmosdummy1:copy()
	local nmosdummy2 = nmosdummy1:copy()

	--sample_bb as gate
	local pmosvd = pcell.create_layout("basic/mosfet", "pmosvd", {
		channeltype = "pmos",
		flippedwell = false,
		vthtype = _P.pfetvthtype,
		drawbotgate = true,
		botgatestrwidth = _P.gstrwidth,
		botgatestrspace = _P.gstrspace,
		botgateextendhalfspace = true,
		fingers = _P.switchfingers,
		fingerwidth = _P.fingerwidth,
		connectsource = true,
		connsourcemetal = 1,
		connsourcewidth = 2 * _P.sdwidth,
		connsourcespace = _P.sdspace,
		connectdrain = true,
		conndrainmetal = 2,
		drawdrainvia = true,
		conndraininline = true,
		extendimplantbot = _P.gstrspace / 2,
		extendvthbot = _P.gstrspace / 2,
		extendwellbot = _P.gstrspace / 2,
		gtopext = 1.5 * _P.powerspace + _P.powerwidth,
		gbotext = _P.gstrspace + _P.gstrwidth,
		drawextrasourcestrap = true,
		extrasourcestrapwidth = _P.powerwidth,
		extrasourcestrapspace = _P.powerspace,
	    })

	local nmosvin = pcell.create_layout("basic/mosfet", "nmosvin", {
		channeltype = "nmos",
		flippedwell = true,
		vthtype = _P.nfetvthtype,
		drawtopgate = true,
		topgatestrwidth = _P.gstrwidth,
		topgatestrspace = 2 * _P.gstrspace + _P.gstrwidth,
		topgateextendhalfspace = true,
		fingers = _P.switchfingers,
		fingerwidth = _P.fingerwidth,
		connectsource = true,
		connsourcemetal = 1,
		connsourcewidth = 2 * _P.sdwidth,
		connsourcespace = _P.sdspace,
		connectdrain = true,
		conndrainmetal = 2,
		drawdrainvia = true,
		conndraininline = true,
		extendimplanttop = - _P.gstrwidth - _P.gstrspace / 2,
		extendvthtop = - _P.gstrwidth - _P.gstrspace / 2,
		extendwelltop = - _P.gstrwidth - _P.gstrspace / 2,
		gbotext = 1.5 * _P.powerspace + _P.powerwidth,
		drawextrasourcestrap = true,
		extrasourcestrapwidth = _P.powerwidth,
		extrasourcestrapspace = _P.powerspace,
		drawbotgcut = true,
		cutheight = _P.gstrspace,
	    })

	--dummy3
	local pmosdummy3 = pmosdummy1:copy()
	local nmosdummy3 = nmosdummy1:copy()

	--sample_b as gate
	local pmosvin = pcell.create_layout("basic/mosfet", "pmosvin", {
		channeltype = "pmos",
		flippedwell = false,
		vthtype = _P.pfetvthtype,
		drawbotgate = true,
		botgatestrwidth = _P.gstrwidth,
		botgatestrspace = 2 * _P.gstrspace + _P.gstrwidth,
		topgateextendhalfspace = true,
		fingers = _P.switchfingers,
		fingerwidth = _P.fingerwidth,
		connectsource = true,
		connsourcemetal = 1,
		drawsourcevia = true,
		connsourcewidth = 2 * _P.sdwidth,
		connsourcespace = _P.sdspace,
		connectdrain = true,
		conndrainmetal = 2,
		drawdrainvia = true,
		conndraininline = true,
		extendimplantbot = - _P.gstrwidth - _P.gstrspace / 2,
		extendvthbot = - _P.gstrwidth - _P.gstrspace / 2,
		extendwellbot = - _P.gstrwidth - _P.gstrspace / 2,
		gtopext = 1.5 * _P.powerspace + _P.powerwidth,
		gbotext = _P.gstrspace + _P.gstrwidth,
		drawextrasourcestrap = true,
		extrasourcestrapwidth = _P.powerwidth,
		extrasourcestrapspace = _P.powerspace,
	    })

	local nmosvd = pcell.create_layout("basic/mosfet", "nmosvd", {
		channeltype = "nmos",
		flippedwell = true,
		vthtype = _P.nfetvthtype,
		drawtopgate = true,
		topgatestrwidth = _P.gstrwidth,
		topgatestrspace = _P.gstrspace,
		topgateextendhalfspace = true,
		fingers = _P.switchfingers,
		fingerwidth = _P.fingerwidth,
		connectsource = true,
		connsourcemetal = 1,
		drawsourcevia = true,
		connsourcewidth = 2 * _P.sdwidth,
		connsourcespace = _P.sdspace,
		connectdrain = true,
		conndrainmetal = 2,
		drawdrainvia = true,
		conndraininline = true,
		extendimplanttop = _P.gstrspace / 2,
		extendvthtop = _P.gstrspace / 2,
		extendwelltop = _P.gstrspace / 2,
		gbotext = 1.5 * _P.powerspace + _P.powerwidth,
		drawextrasourcestrap = true,
		extrasourcestrapwidth = _P.powerwidth,
		extrasourcestrapspace = _P.powerspace,
		drawbotgcut = true,
		cutheight = _P.gstrspace,
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
	local pmosbuf3 = pmosbuf2:copy()
	local nmosbuf3 = nmosbuf2:copy()



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


	--connect buffer1 and 2
	geometry.path(pmosbuf1, generics.metal(2),{
		pmosbuf1:get_anchor("sourcedrain2bc"),
		nmosbuf1:get_anchor("sourcedrain2bc")
	    }, _P.sdwidth)
	geometry.viabltr(nmosdummy1, 1, 2,
		point.combine_12(nmosdummy1:get_anchor("sourcedrainlefttl"),pmosbuf2:get_anchor("botgatestrapbl")),
		nmosbuf2:get_anchor("topgatestraptl")
	    )
	geometry.path(pmosbuf1, generics.metal(2),{
		point.combine_12(pmosbuf1:get_anchor("sourcedrain2tr"),pmosbuf2:get_anchor("botgatestrapcr")),
		nmosbuf2:get_anchor("topgatestrapcl")
	    }, _P.sdwidth)

	--connect sample_b and sample_bb
	geometry.path(pmosbuf2, generics.metal(2),{
		pmosbuf2:get_anchor("sourcedrain2bc"),
		nmosbuf2:get_anchor("sourcedrain2bc")
	    }, _P.sdwidth)
	geometry.viabltr(nmosdummy2, 1, 2,
		point.combine_12(nmosdummy2:get_anchor("sourcedrainlefttl"),pmosvd:get_anchor("botgatestrapbl")),
		nmosvin:get_anchor("topgatestraptl")
	    )
	geometry.path(pmosbuf2, generics.metal(2),{
		point.combine_12(pmosbuf2:get_anchor("sourcedrain2tr"),pmosvd:get_anchor("botgatestrapcr")),
		nmosvin:get_anchor("topgatestrapcl")
	    }, _P.sdwidth)
	geometry.path(nmosbuf2, generics.metal(1),{
		nmosbuf2:get_anchor("topgatestrapcr"),
		nmosvd:get_anchor("topgatestrapcl")
	    }, _P.sdwidth)

	--connect drain of transgate
	geometry.path(pmosvd, generics.metal(2),{
		pmosvd:get_anchor("sourcedrain2cr"),
		pmosvin:get_anchor("sourcedrain2cl")
	    }, _P.sdwidth)
	geometry.path(nmosvin, generics.metal(2),{
		nmosvin:get_anchor("sourcedrain2cr"),
		nmosvd:get_anchor("sourcedrain2cl")
	    }, _P.sdwidth)
	geometry.path(pmosvd, generics.metal(2),{
		pmosvd:get_anchor("sourcedrainrightcc"):translate(0.5 * _P.gatespace + 0.5 * _P.gatelength, 0),
		nmosvin:get_anchor("sourcedrainrightcc"):translate(0.5 * _P.gatespace + 0.5 * _P.gatelength, 0)
	    }, _P.sdwidth)
	geometry.path(pmosrefin, generics.metal(2),{
		pmosrefin:get_anchor("sourcedrain2bc"),
		nmosgndin:get_anchor("sourcedrain2tc")
	    }, _P.sdwidth)
	geometry.path_cshape(nmosgndin, generics.metal(2),
		nmosgndin:get_anchor("sourcedrain2bc"),
		nmosvd:get_anchor("sourcestrapcr"),
		point.combine_12(nmosgndin:get_anchor("sourcedrain2bc"),nmosvd:get_anchor("sourcestrapcr")),
	    _P.sdwidth)


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
	    }, _P.sdwidth)

	geometry.path_cshape(pmosvd, generics.metal(3),
		pmosvd:get_anchor("sourcestrapcr"),
		nmosvd:get_anchor("sourcestrapbl"),
		nmosvd:get_anchor("sourcestrapbl"),
	    2 * _P.sdwidth)
	geometry.path_cshape(pmosvin, generics.metal(4),
		pmosvin:get_anchor("sourcestrapcc"),
		nmosvin:get_anchor("sourcestrapbc"),
		nmosvin:get_anchor("sourcestrapbc"),
	    2 * _P.sdwidth)

	--connect buffer3
	geometry.path(pmosbuf3, generics.metal(2),{
		pmosbuf3:get_anchor("sourcedrain2bc"),
		nmosbuf3:get_anchor("sourcedrain2bc")
	    }, _P.sdwidth)
	geometry.viabltr(pmosrefin, 1, 2,
		pmosrefin:get_anchor("botgatestrapbc"),
		pmosrefin:get_anchor("botgatestraptr")
	    )
	geometry.path(pmosrefin, generics.metal(2),{
		point.combine_12(pmosbuf3:get_anchor("sourcedrain2bc"),pmosrefin:get_anchor("botgatestrapcr")),
		pmosrefin:get_anchor("botgatestrapcr")
	    }, _P.sdwidth)

	-- port metal
	--sample
	geometry.viabltr(switch, 1, 2,
		pmosbuf1:get_anchor("botgatestrapbl"):translate( - _P.sdspace, 0),
		pmosbuf1:get_anchor("botgatestraptl")
	    )

	--data
	geometry.viabltr(switch, 1, 3,
		pmosbuf3:get_anchor("botgatestrapbr"),
		pmosbuf3:get_anchor("botgatestraptr"):translate(  1.5 * _P.sdspace, 0)
	    )
	-- vin
	geometry.path(pmosvin, generics.metal(4),{
		pmosvin:get_anchor("sourcestraptc"),
		pmosvin:get_anchor("sourcestraptc"):translate(0, 3 * _P.sdspace)
	    },  _P.sdwidth)
	-- vout
	geometry.path(pmosvin, generics.metal(2),{
		pmosvd:get_anchor("botgatestrapcr"):translate(0.5 * _P.gatespace, 0),
		point.combine_12(nmosvd:get_anchor("topgatestrapcr"),pmosvd:get_anchor("botgatestrapcr"))
	    }, _P.sdwidth)
	geometry.viabltr(pmosvin, 1, 3,
		point.combine_12(nmosvd:get_anchor("topgatestrapcc"),pmosvd:get_anchor("botgatestrapbc")),
		point.combine_12(nmosvd:get_anchor("topgatestrapcr"),pmosvd:get_anchor("botgatestraptc"))
	    )
	geometry.path_cshape(switch, generics.metal(3),
		point.combine_12(nmosvd:get_anchor("topgatestrapcr"),pmosvd:get_anchor("botgatestrapcc")),
		nmosgndin:get_anchor("sourcestrapbr"):translate(  2 * _P.sdwidth, - 2 * _P.sdspace),
		nmosgndin:get_anchor("sourcestrapbr"):translate(  2 * _P.sdwidth, - 2 * _P.sdspace),
	    _P.sdwidth)
	-- REF
	geometry.viabltr(pmosvin, 1, 5,
		pmosrefin:get_anchor("sourcestrapbl"),
		pmosrefin:get_anchor("sourcestraptc")
	    )
	geometry.path(pmosrefin, generics.metal(5),{
		pmosrefin:get_anchor("sourcestraptl"),
		nmosgndin:get_anchor("sourcestrapbl"):translate(0, - 4 * _P.sdspace)
	    },  _P.sdwidth)
	-- GND
	geometry.viabltr(nmosgndin, 1, 5,
		nmosgndin:get_anchor("sourcestrapbc"),
		nmosgndin:get_anchor("sourcestraptr")
	    )
	geometry.path(nmosgndin, generics.metal(5),{
		nmosgndin:get_anchor("sourcestrapbr"),
		pmosrefin:get_anchor("sourcestraptr"):translate(0,  4 * _P.sdspace)
	    },  _P.sdwidth)



	switch:merge_into_shallow(nmosbuf1:flatten())
	switch:merge_into_shallow(pmosbuf1:flatten())
	switch:merge_into_shallow(pmosdummy1:flatten())
	switch:merge_into_shallow(nmosdummy1:flatten())
	switch:merge_into_shallow(nmosbuf2:flatten())
	switch:merge_into_shallow(pmosbuf2:flatten())
	switch:merge_into_shallow(pmosdummy2:flatten())
	switch:merge_into_shallow(nmosdummy2:flatten())
	switch:merge_into_shallow(nmosvin:flatten())
	switch:merge_into_shallow(pmosvin:flatten())
	switch:merge_into_shallow(pmosdummy3:flatten())
	switch:merge_into_shallow(nmosdummy3:flatten())
	switch:merge_into_shallow(nmosvd:flatten())
	switch:merge_into_shallow(pmosvd:flatten())
	switch:merge_into_shallow(pmosdummy4:flatten())
	switch:merge_into_shallow(nmosdummy4:flatten())
	switch:merge_into_shallow(nmosgndin:flatten())
	switch:merge_into_shallow(pmosrefin:flatten())
	switch:merge_into_shallow(pmosdummy5:flatten())
	switch:merge_into_shallow(nmosdummy5:flatten())
	switch:merge_into_shallow(nmosbuf3:flatten())
	switch:merge_into_shallow(pmosbuf3:flatten())


    	-- add ports
	switch:add_port("VDD", generics.metalport(1), pmosbuf1:get_anchor("sourcestrapcc"))
	switch:add_port("VSS", generics.metalport(1), nmosbuf1:get_anchor("sourcestrapcc"))
	switch:add_port("sample", generics.metalport(2), pmosbuf1:get_anchor("botgatestrapcl"))
	switch:add_port("vin", generics.metalport(4), pmosvin:get_anchor("sourcestrapcc"))
	switch:add_port("vout", generics.metalport(3), point.combine_12(nmosgndin:get_anchor("topgatestrapcc"),pmosvd:get_anchor("botgatestrapcc")))
	switch:add_port("data", generics.metalport(3), pmosrefin:get_anchor("botgatestrapcr"))
	switch:add_port("REF", generics.metalport(5), pmosrefin:get_anchor("sourcestrapcl"))
	switch:add_port("GND", generics.metalport(5), nmosgndin:get_anchor("sourcestrapcr"))

    	-- add anchors and alignment box
	switch:add_anchor_area_bltr("VDD",
		pmosbuf1:get_anchor("sourcestrapbl"),
		pmosbuf3:get_anchor("sourcestraptr")
	)
	switch:add_anchor_area_bltr("VSS",
		nmosbuf1:get_anchor("sourcestrapbl"),
		nmosbuf3:get_anchor("sourcestraptr")
	)
	switch:add_anchor_area_bltr("sample",
		pmosbuf1:get_anchor("botgatestrapbl"):translate( - _P.sdspace, 0),
		pmosbuf1:get_anchor("botgatestraptl")
	)
	switch:add_anchor_area_bltr("data",
		pmosbuf3:get_anchor("botgatestrapbr"),
		pmosbuf3:get_anchor("botgatestraptr"):translate( 1.5 * _P.sdspace, 0)
	)
	switch:add_anchor_area_bltr("vin",
		pmosvin:get_anchor("sourcestraptc"):translate(- 0.5 * _P.sdwidth, 0),
		pmosvin:get_anchor("sourcestraptc"):translate( 0.5 * _P.sdwidth, 3 * _P.sdspace)
	)
	switch:add_anchor_area_bltr("vout",
		nmosgndin:get_anchor("sourcestrapbr"):translate(  1.5 * _P.sdwidth, - 2 * _P.sdspace),
		nmosgndin:get_anchor("sourcestrapbr"):translate(  2.5 * _P.sdwidth, 0)
	)
	switch:add_anchor_area_bltr("REF",
		nmosgndin:get_anchor("sourcestrapbl"):translate(- 0.5 * _P.sdwidth, - 4 * _P.sdspace),
		pmosrefin:get_anchor("sourcestraptl"):translate( 0.5 * _P.sdwidth, 0)
	)
	switch:add_anchor_area_bltr("GND",
		nmosgndin:get_anchor("sourcestrapbr"):translate(- 0.5 * _P.sdwidth, 0),
		pmosrefin:get_anchor("sourcestraptr"):translate(0.5 * _P.sdwidth,  4 * _P.sdspace)

	)
	switch:set_alignment_box(
		nmosbuf1:get_anchor("sourcestrapbl"):translate(- 0.5 * _P.gatespace + 0.5 * _P.sdwidth - 10, - 0.5 * _P.powerspace),
		pmosbuf3:get_anchor("sourcestraptr"):translate( 0.5 * _P.gatespace - 0.5 * _P.sdwidth + 10, 0.5 * _P.powerspace)
	)
end

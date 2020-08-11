return function(args)
    pcell.setup(args)
    local oxidetype  = pcell.process_args("oxidetype", "0.9")
    local pvthtype   = pcell.process_args("pvthtype", "slvt")
    local nvthtype   = pcell.process_args("nvthtype", "slvt")
    local pwidth     = pcell.process_args("pwidth", 1)
    local nwidth     = pcell.process_args("nwidth", 1)
    local glength    = pcell.process_args("glength", 0.2)
    local gext	     = pcell.process_args("gext", 0.1)
    local sdwidth    = pcell.process_args("sdwidth", 0.06)
    local gspace	 = pcell.process_args("gspace", 0.14)
    local gstwidth   = pcell.process_args("gstwidth", 0.1)
    local fingers    = pcell.process_args("fingers", 4)
    local dummies    = pcell.process_args("dummies", 2)
    local separation = pcell.process_args("separation", 0.4)
    local ttypeext   = pcell.process_args("ttypeext", 0.1)
    local powerwidth = pcell.process_args("powerwidth", 0.2)
    local powerspace = pcell.process_args("powerspace", 0.5)
    local conngate   = pcell.process_args("conngate", 1)
    local connmetal  = pcell.process_args("connmetal", 3)
    local connwidth  = pcell.process_args("connwidth", 0.1)
    local connoffset = pcell.process_args("connoffset", 1)
    pcell.check_args()

    local xpitch = gspace + glength
    local dummycontheight = 0.08

    local inverter = object.create()

    -- pfet
    local pmos = celllib.create("transistor",
        {
            channeltype = "pmos",
            fingers = fingers, gatelength = glength, fwidth = pwidth, fspace = gspace,
            sdwidth = sdwidth,
            gtopext = powerspace + dummycontheight, gbotext = 0.5 * separation,
            clipbot = true
        }
    ):translate(0,  0.5 * (pwidth + separation))
    inverter:merge_into(pmos)
    -- nfet
    local nmos = celllib.create("transistor",
        {
            channeltype = "nmos",
            fingers = fingers, gatelength = glength, fwidth = pwidth, fspace = gspace,
            sdwidth = sdwidth,
            gbotext = powerspace + dummycontheight, gtopext = 0.5 * separation,
            cliptop = true
        }
    ):translate(0, -0.5 * (pwidth + separation))
    inverter:merge_into(nmos)

    -- gate contacts
    inverter:merge_into(layout.multiple(
        layout.rectangle(generics.contact("gate"), glength, gstwidth),
        fingers, 1, xpitch, 0
    ))
    inverter:merge_into(layout.rectangle(generics.via(1, conngate), fingers * xpitch, gstwidth))

    -- dummy gate contacts
    for i = 1, dummies do
        inverter:merge_into(layout.multiple(
            layout.rectangle(generics.contact("gate"), glength, dummycontheight),
            1, 2, 0, separation + pwidth + nwidth + 2 * powerspace + dummycontheight
        ):translate((i + 0.5 * (fingers - 1)) * xpitch, 0.5 * (pwidth - nwidth)))
        inverter:merge_into(layout.multiple(
            layout.rectangle(generics.contact("gate"), glength, dummycontheight),
            1, 2, 0, separation + pwidth + nwidth + 2 * powerspace + dummycontheight
        ):translate(-(i + 0.5 * (fingers - 1)) * xpitch, 0.5 * (pwidth - nwidth)))
    end

    -- dummies
    for i = -1, 1, 2 do
        local pmosdummy = celllib.create("transistor",
            {
                channeltype = "pmos",
                fingers = dummies, gatelength = glength, fwidth = pwidth, fspace = gspace,
                sdwidth = sdwidth,
                gtopext = powerspace + dummycontheight, gbotext = 0.5 * separation,
                clipbot = true, botgcut = true
            }
        ):translate(i * 0.5 * (fingers + dummies) * xpitch, 0.5 * (pwidth + separation))
        inverter:merge_into(pmosdummy)
        local nmosdummy = celllib.create("transistor",
            {
                channeltype = "nmos",
                fingers = dummies, gatelength = glength, fwidth = pwidth, fspace = gspace,
                sdwidth = sdwidth,
                gbotext = powerspace + dummycontheight, gtopext = 0.5 * separation,
                cliptop = true, topgcut = true
            }
        ):translate(i * 0.5 * (fingers + dummies) * xpitch, -0.5 * (nwidth + separation))
        inverter:merge_into(nmosdummy)
    end

    -- connections
    inverter:merge_into(layout.multiple(
        layout.rectangle(generics.metal(1), sdwidth, powerspace),
        fingers / 2 + 1, 2,
        2 * xpitch, nwidth + pwidth + separation + powerspace
    ):translate(0, 0.5 * (pwidth - nwidth)))

    -- output connection
    inverter:merge_into(layout.multiple(
        layout.rectangle(generics.metal(connmetal), (fingers - 1 + connoffset) * xpitch, connwidth),
        1, 2, 0, 0.5 * (nwidth + pwidth) + separation
    ):translate(0.5 * (1 + connoffset) * xpitch, 0.25 * (pwidth - nwidth)))
    inverter:merge_into(layout.rectangle(
        generics.metal(connmetal), 
        connwidth, 0.5 * (nwidth + pwidth) + separation + connwidth
    ):translate((0.5 * fingers + connoffset) * xpitch, 0.25 * (pwidth - nwidth)))
    for i = 1, math.floor(fingers / 2) do
        inverter:merge_into(layout.rectangle(
            generics.via(1, connmetal), 
            sdwidth, pwidth
        ):translate((i - 0.25 * fingers - 0.5) * 2 * xpitch, 0.5 * (pwidth + separation)))
        inverter:merge_into(layout.rectangle(
            generics.via(1, connmetal), 
            sdwidth, nwidth
        ):translate((i - 0.25 * fingers - 0.5) * 2 * xpitch, -0.5 * (pwidth + separation)))
    end

    -- power rails
    inverter:merge_into(layout.rectangle(generics.metal(1),
        (fingers + 2 * dummies) * xpitch + sdwidth, powerwidth
    ):translate(0, -0.5 * separation - nwidth - 0.5 * powerwidth - powerspace))
    inverter:merge_into(layout.rectangle(generics.metal(1),
        (fingers + 2 * dummies) * xpitch + sdwidth, powerwidth
    ):translate(0, 0.5 * separation + pwidth + 0.5 * powerwidth + powerspace))

    -- connections
    --foreach(i list(-1 1)
    for i = -1, 1, 2 do
        inverter:merge_into(layout.multiple(
            layout.rectangle(generics.metal(1), sdwidth, powerspace),
            dummies + 1, 2, xpitch, nwidth + pwidth + separation + powerspace
        ):translate(i * 0.5 * (fingers + dummies) * xpitch, 0.5 * (pwidth - nwidth)))
    end

    return inverter
end

function parameters()
end

function layout(cell, _P, env)
    local Ninput = 8
    local Nfeedback = 16
    local Noutput = (44 - Ninput - Nfeedback - 2)
    local gatecontactpos = {}
    for i = 1, Ninput do
        gatecontactpos[i] = "center"
    end
    gatecontactpos[Ninput + 1] = "dummy"
    for i = 1, Nfeedback do
        gatecontactpos[Ninput + 1 + i] = "center"
    end
    gatecontactpos[Ninput + Nfeedback + 2] = "dummy"
    for i = 1, Noutput do
        gatecontactpos[Ninput + Nfeedback + 2 + i] = "center"
    end
    local sdcontactpos = {}
    for i = 1, Ninput, 4 do
        sdcontactpos[i + 0] = "power"
        sdcontactpos[i + 1] = "outer"
        sdcontactpos[i + 2] = "inner"
        sdcontactpos[i + 3] = "outer"
        sdcontactpos[i + 4] = "power"
    end
    for i = 1, Nfeedback, 2 do
        sdcontactpos[Ninput + 1 + i + 0] = "inner"
        sdcontactpos[Ninput + 1 + i + 1] = "outer"
        sdcontactpos[Ninput + 1 + i + 2] = "inner"
    end
    for i = 1, Noutput, 2 do
        sdcontactpos[Ninput + Nfeedback + 2 + i + 0] = "power"
        sdcontactpos[Ninput + Nfeedback + 2 + i + 1] = "inner"
        sdcontactpos[Ninput + Nfeedback + 2 + i + 2] = "power"
    end
    local cmosref = pcell.create_layout("basic/cmos", { 
        pwidth = env.gatewidth,
        nwidth = env.gatewidth,
        pvthtype = 3,
        nvthtype = 3,
        separation = 420,
        powerwidth = env.powerbarwidth,
        powerspace = env.powerbarspace,
        sdwidth = 60,
        gstwidth = 100,
        gatecontactpos = gatecontactpos,
        pcontactpos = sdcontactpos,
        ncontactpos = sdcontactpos,
    })

    -- input connections
    cmosref:merge_into_shallow(geometry.rectanglebltr(generics.via(1, 2),
        cmosref:get_anchor(string.format("Gll%d", 1)),
        cmosref:get_anchor(string.format("Gur%d", Ninput))
    ))
    cmosref:merge_into_shallow(geometry.rectanglebltr(generics.metal(1),
        cmosref:get_anchor(string.format("pSDi%d", 3)),
        cmosref:get_anchor(string.format("pSDi%d", Ninput - 1)):translate(5 * (200 + 140) / 2, 100)
    ))
    cmosref:merge_into_shallow(geometry.rectanglebltr(generics.metal(1),
        cmosref:get_anchor(string.format("nSDi%d", 3)):translate(0, -100),
        cmosref:get_anchor(string.format("nSDi%d", Ninput - 1)):translate(5 * (200 + 140) / 2, 0)
    ))
    cmosref:merge_into_shallow(geometry.rectanglebltr(generics.metal(1),
        cmosref:get_anchor(string.format("nSDi%d", Ninput - 1)):translate(5 * (200 + 140) / 2 - 50, -100),
        cmosref:get_anchor(string.format("pSDi%d", Ninput - 1)):translate(5 * (200 + 140) / 2 + 50, 100)
    ))
    cmosref:merge_into_shallow(geometry.rectanglebltr(generics.metal(2),
        cmosref:get_anchor(string.format("pSDo%d", 2)):translate(0, -100),
        cmosref:get_anchor(string.format("pSDo%d", Ninput + 5))
    ))
    cmosref:merge_into_shallow(geometry.rectanglebltr(generics.metal(2),
        cmosref:get_anchor(string.format("nSDo%d", 2)),
        cmosref:get_anchor(string.format("nSDo%d", Ninput + 5)):translate(0, 100)
    ))
    for i = 1, Ninput / 2 do
        cmosref:merge_into_shallow(geometry.rectanglebltr(generics.via(1, 2),
            cmosref:get_anchor(string.format("pSDi%d", 2 * i)):translate(-30, 0),
            cmosref:get_anchor(string.format("pSDo%d", 2 * i)):translate(30, 0)
        ))
        cmosref:merge_into_shallow(geometry.rectanglebltr(generics.via(1, 2),
            cmosref:get_anchor(string.format("nSDo%d", 2 * i)):translate(-30, 0),
            cmosref:get_anchor(string.format("nSDi%d", 2 * i)):translate(30, 0)
        ))
    end

    -- feedback connections
    cmosref:merge_into_shallow(geometry.rectanglebltr(generics.metal(1),
        point.combine(
            cmosref:get_anchor(string.format("nSDi%d", Ninput - 1)):translate(5 * (200 + 140) / 2, 0),
            cmosref:get_anchor(string.format("pSDi%d", Ninput - 1)):translate(5 * (200 + 140) / 2, 0)
        ) .. cmosref:get_anchor(string.format("Gll%d", Ninput + Nfeedback + 1)),
        cmosref:get_anchor(string.format("Gur%d", Ninput + Nfeedback + Noutput + 2))
    ))
    cmosref:merge_into_shallow(geometry.rectanglebltr(generics.metal(1),
        cmosref:get_anchor(string.format("pSDo%d", Ninput + 3)):translate(0, -100),
        cmosref:get_anchor(string.format("pSDo%d", Ninput + Nfeedback + 1))
    ))
    cmosref:merge_into_shallow(geometry.rectanglebltr(generics.metal(1),
        cmosref:get_anchor(string.format("nSDo%d", Ninput + 3)),
        cmosref:get_anchor(string.format("nSDo%d", Ninput + Nfeedback + 1)):translate(0, 100)
    ))
    cmosref:merge_into_shallow(geometry.rectanglebltr(generics.via(1, 2),
        cmosref:get_anchor(string.format("pSDo%d", Ninput + 3)):translate(0, -100),
        cmosref:get_anchor(string.format("pSDo%d", Ninput + 5))
    ))
    cmosref:merge_into_shallow(geometry.rectanglebltr(generics.via(1, 2),
        cmosref:get_anchor(string.format("nSDo%d", Ninput + 3)),
        cmosref:get_anchor(string.format("nSDo%d", Ninput + 5)):translate(0, 100)
    ))
    cmosref:merge_into_shallow(geometry.rectanglebltr(generics.metal(1),
        cmosref:get_anchor(string.format("pSDi%d", Ninput + 2)),
        cmosref:get_anchor(string.format("pSDi%d", Ninput + Nfeedback + 2)):translate(0, 100)
    ))
    cmosref:merge_into_shallow(geometry.rectanglebltr(generics.metal(1),
        cmosref:get_anchor(string.format("nSDi%d", Ninput + 2)):translate(0, -100),
        cmosref:get_anchor(string.format("nSDi%d", Ninput + Nfeedback + 2))
    ))
    for i = 3, Nfeedback // 2 do
        cmosref:merge_into_shallow(geometry.rectanglebltr(generics.metal(2),
            (cmosref:get_anchor(string.format("Gcc%d", Ninput + 2 * i)) .. cmosref:get_anchor(string.format("nSDi%d", Ninput + 2))):translate(-30, 0),
            (cmosref:get_anchor(string.format("Gcc%d", Ninput + 2 * i)) .. cmosref:get_anchor("PRplc")):translate(30, 0)
        ))
        cmosref:merge_into_shallow(geometry.rectanglebltr(generics.via(1, 2),
            (cmosref:get_anchor(string.format("Gcc%d", Ninput + 2 * i)) .. cmosref:get_anchor(string.format("nSDi%d", Ninput + 2))):translate(-200 / 2, -100),
            (cmosref:get_anchor(string.format("Gcc%d", Ninput + 2 * i)) .. cmosref:get_anchor(string.format("nSDi%d", Ninput + 2))):translate(200 / 2, 0)
        ))
        cmosref:merge_into_shallow(geometry.rectanglebltr(generics.metal(2),
            (cmosref:get_anchor(string.format("Gcc%d", Ninput + 1 + 2 * i)) .. cmosref:get_anchor("PRnuc")):translate(-30, 0),
            (cmosref:get_anchor(string.format("Gcc%d", Ninput + 1 + 2 * i)) .. cmosref:get_anchor(string.format("pSDi%d", Ninput + 2))):translate(30, 0)
        ))
        cmosref:merge_into_shallow(geometry.rectanglebltr(generics.via(1, 2),
            (cmosref:get_anchor(string.format("Gcc%d", Ninput + 1 + 2 * i)) .. cmosref:get_anchor(string.format("pSDi%d", Ninput + 2))):translate(-200 / 2, 0),
            (cmosref:get_anchor(string.format("Gcc%d", Ninput + 1 + 2 * i)) .. cmosref:get_anchor(string.format("pSDi%d", Ninput + 2))):translate(200 / 2, 100)
        ))
    end

    -- output connections
    cmosref:merge_into_shallow(geometry.rectanglebltr(generics.metal(2),
        cmosref:get_anchor(string.format("pSDi%d", Ninput + Nfeedback + 4)),
        cmosref:get_anchor(string.format("pSDi%d", Ninput + Nfeedback + Noutput + 2)):translate(2 * (200 + 140), 100)
    ))
    cmosref:merge_into_shallow(geometry.rectanglebltr(generics.metal(2),
        cmosref:get_anchor(string.format("nSDi%d", Ninput + Nfeedback + 4)):translate(0, -100),
        cmosref:get_anchor(string.format("nSDi%d", Ninput + Nfeedback + Noutput + 2)):translate(2 * (200 + 140), 0)
    ))
    cmosref:merge_into_shallow(geometry.rectanglebltr(generics.metal(2),
        cmosref:get_anchor(string.format("nSDi%d", Ninput + Nfeedback + Noutput + 2)):translate(2 * (200 + 140) - 50, -100),
        cmosref:get_anchor(string.format("pSDi%d", Ninput + Nfeedback + Noutput + 2)):translate(2 * (200 + 140) + 50, 100)
    ))
    for i = 1, Noutput / 2 do
        cmosref:merge_into_shallow(geometry.rectanglebltr(generics.via(1, 2),
            cmosref:get_anchor(string.format("pSDi%d", Ninput + Nfeedback + 2 + 2 * i)):translate(-30, 0),
            cmosref:get_anchor(string.format("pSDo%d", Ninput + Nfeedback + 2 + 2 * i)):translate(30, 0)
        ))
        cmosref:merge_into_shallow(geometry.rectanglebltr(generics.via(1, 2),
            cmosref:get_anchor(string.format("nSDo%d", Ninput + Nfeedback + 2 + 2 * i)):translate(-30, 0),
            cmosref:get_anchor(string.format("nSDi%d", Ninput + Nfeedback + 2 + 2 * i)):translate(30, 0)
        ))
    end

    cmosref:merge_into_shallow(geometry.rectanglebltr(generics.via(1, 2),
        cmosref:get_anchor("PRpll"),
        cmosref:get_anchor("PRpur")
    ))
    cmosref:merge_into_shallow(geometry.rectanglebltr(generics.via(1, 2),
        cmosref:get_anchor("PRnll"),
        cmosref:get_anchor("PRnur")
    ))

    local width = point.xdistance(cmosref:get_anchor("PRpur"), cmosref:get_anchor("PRpul"))
    cmosref:merge_into_shallow(pcell.create_layout("auxiliary/welltap", {
        contype = "p",
        width = width,
        height = 200,
        extension = 50,
    }):translate(cmosref:get_anchor("PRncc"):translate(0, -400)))

    local cmosname = pcell.add_cell_reference(cmosref, "cmos")
    local cmos = cell:add_child(cmosname):translate(0, 0)

    -- power grid vias
    env.place_power_vias("vdd", cell, 420 / 2 + env.gatewidth + env.powerbarspace + env.powerbarwidth / 2)
    env.place_power_vias("vss", cell, -420 / 2 - env.gatewidth - env.powerbarspace - env.powerbarwidth / 2)
    env.place_power_vias("vss", cell, -420 / 2 - env.gatewidth - env.powerbarspace - env.powerbarwidth / 2 - 400)
    env.place_power_vias("vdd", cell,  env.ypitch + env.guardringwidth / 2 + env.guardringspace + env.powerbarwidth / 2)
    env.place_power_vias("vdd", cell, -env.ypitch - env.guardringwidth / 2 - env.guardringspace - env.powerbarwidth / 2)

    local guardringref = pcell.create_layout("auxiliary/guardring", { 
        contype = "n", 
        ringwidth = env.guardringwidth, 
        width = (env.factor + 1) * env.fingers * (env.gatelength + env.gatespace) + 1000,
        height = 2 * env.ypitch + env.guardringwidth + 2 * env.guardringspace + env.powerbarwidth,
        drawdeepwell = true, 
        deepwelloffset = 150,
        fillwell = false,
    })
    local guardringname = pcell.add_cell_reference(guardringref, "guardring")
    local guardring = cell:add_child(guardringname)
    cell:merge_into_shallow(geometry.rectanglebltr(generics.other("nwell"),
        guardring:get_anchor("left"),
        guardring:get_anchor("topright")
    ))

    cell:add_anchor("in", cmosref:get_anchor(string.format("Gcl%d", 1)))
    cell:add_anchor("out", 
        point.combine(
            cmosref:get_anchor(string.format("nSDi%d", Ninput + Nfeedback + Noutput + 2)):translate(2 * (200 + 140) - 50, -100),
            cmosref:get_anchor(string.format("pSDi%d", Ninput + Nfeedback + Noutput + 2)):translate(2 * (200 + 140) + 50, 100)
        )
    )

    cell:inherit_alignment_box(guardring)
end

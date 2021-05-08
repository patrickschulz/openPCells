function parameters()
    pcell.reference_cell("basic/cmos")
    pcell.add_parameters(
        { "invfingers", 2 },
        { "numinv", 7 },
        { "pfingerwidth", 500 },
        { "nfingerwidth", 500 }
    )
end

function layout(oscillator, _P)
    local cbp = pcell.get_parameters("basic/cmos")

    local xpitch = cbp.glength + cbp.gspace

    -- place inverter cells
    local gatecontacts = {}
    for i = 1, 2 * _P.invfingers * _P.numinv do
        if (i % 4 == 2) or (i % 4 == 3) then
            gatecontacts[i] = "center"
        else
            gatecontacts[i] = "outer"
        end
    end
    local activecontacts = {}
    for i = 1, 2 * _P.invfingers * _P.numinv do
        if i % 4 == 3 then
            activecontacts[i] = "inner"
        elseif i % 4 == 1 then
            activecontacts[i] = "power"
        else
            activecontacts[i] = "outer"
        end
    end
    local mosarray = pcell.create_layout("basic/cmos", { 
        fingers = 2 * _P.invfingers * _P.numinv, 
        pwidth = _P.pfingerwidth,
        nwidth = _P.nfingerwidth,
        gatecontactpos = gatecontacts, 
        pcontactpos = activecontacts, 
        ncontactpos = activecontacts,
        pcontactheight = 300,
        ncontactheight = 300,
    })
    oscillator:merge_into(mosarray)

    -- place current mirror
    local currentmirror = pcell.create_layout("analog/currentmirror")
    currentmirror:translate(-5000, 0)
    --oscillator:merge_into(currentmirror)

    -- draw gate straps
    oscillator:merge_into(geometry.rectanglebltr(generics.metal(1), 
        mosarray:get_anchor("Gn1"):translate(0, -cbp.gstwidth / 2),
        mosarray:get_anchor(string.format("Gn%d", 2 * _P.invfingers * _P.numinv)):translate(0, cbp.gstwidth / 2)
    ))
    oscillator:merge_into(geometry.rectanglebltr(generics.metal(1), 
        mosarray:get_anchor("Gp1"):translate(0, -cbp.gstwidth / 2),
        mosarray:get_anchor(string.format("Gp%d", 2 * _P.invfingers * _P.numinv)):translate(0, cbp.gstwidth / 2)
    ))
    for i = 2, 2 * _P.invfingers * _P.numinv, 4 do
        oscillator:merge_into(geometry.rectanglebltr(generics.metal(1), 
            mosarray:get_anchor(string.format("G%d", i + 0)):translate(0, -cbp.gstwidth / 2),
            mosarray:get_anchor(string.format("G%d", i + 1)):translate(0,  cbp.gstwidth / 2)
        ))
    end

    -- draw inverter connections
    for i = 3, 2 * _P.invfingers * _P.numinv, 4 do
        oscillator:merge_into(geometry.rectanglebltr(generics.metal(1), 
            mosarray:get_anchor(string.format("pSDo%d", i - 1)):translate(0, -cbp.gstwidth),
            mosarray:get_anchor(string.format("pSDo%d", i + 1))
        ))
        oscillator:merge_into(geometry.rectanglebltr(generics.metal(1), 
            mosarray:get_anchor(string.format("nSDo%d", i - 1)):translate(0,  cbp.gstwidth),
            mosarray:get_anchor(string.format("nSDo%d", i + 1))
        ))
        oscillator:merge_into(geometry.path(generics.metal(1), geometry.path_points_xy(
            mosarray:get_anchor(string.format("pSDi%d", i)):translate(0, cbp.gstwidth / 2), {
                _P.invfingers * xpitch,
                mosarray:get_anchor(string.format("nSDi%d", i)):translate(0, -cbp.gstwidth / 2),
            }), cbp.gstwidth
        ))
        if i < 2 * _P.invfingers * (_P.numinv - 1) then
            oscillator:merge_into(geometry.path(generics.metal(1), {
                mosarray:get_anchor(string.format("G%d", i + 3)):translate(-3 * xpitch / 2, 0),
                mosarray:get_anchor(string.format("G%d", i + 3)),
            }, cbp.gstwidth))
        end
    end
end

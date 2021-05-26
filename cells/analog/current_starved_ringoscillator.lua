--[[

 Core:
 *****

    --------------------------------------
    |                                    |
    |                                    |
    |  |\   |\   |\   |\   |\   |\   |\  |
    ---| o--| o--| o--| o--| o--| o--| o--
       |/   |/   |/   |/   |/   |/   |/   

        \-------------v--------------/
                   'numinv'

 Inverter:
 *********
                       VDD
                        |
                    |---|
        vbiasp o---o|    
                    |---|
                        |
                    |---|
                ---o|    
                |   |---|
         in o---|       *---o out
                |   |---|
                ----|    
                    |---|
                        |
                    |---|
        vbiasn o----|    
                    |---|
                        |
                       VSS


    All transistors with 'invfingers' fingers


 Biasing:
 ********
                               
  VDD -----------------*--------*-----------------------
                       |        |                      |
                       |        |  'pmoszerofingers'   |
                       |        |   in series (nf = 1) |
                       |        |---|                  |
                       |            |o---              |
                       |        |---|   |              |
                       |        |       |              |
                       |        |---|   |              |
                       |            |o--*              |
                       |        |---|   |              |
                       |        |       |              |
                       |        |---|   |              |
                       |            |o--*              |
                       |        |---|   |              |
   'pmostunefingers'   |        |       |              |    'pmosdiodefingers'
                   |---|        |---|   |              |---| 
       vtune o----o|                |o--*---- VSS          |o--*-o vbiasp
                   |---|        |---|                  |---|   |
                       *---------                      |       |
                       |                               *--------
                       *--------    vbiasn             |
                       |       |       o               |
                       |---|   |       |           |---|
    'nmosdiodefingers'     |---*-------*-----------|     'nmoscurrentfingers'
                       |---|                       |---|
                       |                               |
  VSS -----------------*--------------------------------
                               
--]]
function parameters()
    pcell.reference_cell("basic/cmos")
    pcell.add_parameters(
        { "invfingers", 2, posvals = even() },
        { "numinv", 17, posvals = odd() },
        { "pmosdiodefingers",    2, posvals = even() },
        { "pmoszerofingers",     7   },
        { "pmostunefingers",     2, posvals = even() },
        { "nmoscurrentfingers",  2, posvals = even() },
        { "nmosdiodefingers",    4, posvals = even() },
        { "glength",             200 },
        { "gspace",              140 },
        { "pfingerwidth",        500 },
        { "nfingerwidth",        500 },
        { "separation",          400 },
        { "gstwidth",             60 },
        { "powerwidth",          120 },
        { "powerspace",           60 }
    )
end

function layout(oscillator, _P)
    local cbp = pcell.get_parameters("basic/cmos")
    local xpitch = _P.glength + _P.gspace

    pcell.push_overwrites("basic/cmos", {
        separation = _P.separation,
        glength = _P.glength,
        gspace = _P.gspace,
        pwidth = _P.pfingerwidth,
        nwidth = _P.nfingerwidth,
        powerwidth = _P.powerwidth,
        powerspace = _P.powerspace,
    })

    -- place inverter cells
    local vcogatecontacts = {}
    for i = 1, 2 * _P.invfingers * _P.numinv do
        if (i % 4 == 2) or (i % 4 == 3) then
            vcogatecontacts[i] = "center"
        else
            vcogatecontacts[i] = "outer"
        end
    end
    local vcoactivecontacts = {}
    for i = 1, 2 * _P.invfingers * _P.numinv do
        if i % 4 == 3 then
            vcoactivecontacts[i] = "inner"
        elseif i % 4 == 1 then
            vcoactivecontacts[i] = "power"
        else
            vcoactivecontacts[i] = "outer"
        end
    end
    local vcoarray = pcell.create_layout("basic/cmos", { 
        fingers = 2 * _P.invfingers * _P.numinv, 
        gatecontactpos = vcogatecontacts, 
        pcontactpos = vcoactivecontacts, 
        ncontactpos = vcoactivecontacts,
        pcontactheight = _P.pfingerwidth - 120,
        ncontactheight = _P.nfingerwidth - 120,
    })
    vcoarray:move_anchor("left")
    oscillator:merge_into(vcoarray)

    -- current mirror settings
    local cmgatecontacts = {}
    local cmfingers = math.max(_P.pmosdiodefingers + _P.pmoszerofingers + _P.pmostunefingers + 1, _P.nmoscurrentfingers + _P.nmosdiodefingers)
    for i = 1, cmfingers do
        cmgatecontacts[i] = "split"
    end
    local cmpactivecontacts = {}
    local cmnactivecontacts = {}
    -- pmos active contacts
    cmpactivecontacts[cmfingers + 1 - _P.pmosdiodefingers - _P.pmoszerofingers] = "inner"
    for i = 2, _P.pmosdiodefingers, 2 do
        cmpactivecontacts[cmfingers + 2 - i] = "inner"
        cmpactivecontacts[cmfingers + 1 - i] = "power"
    end
    for i = 2, _P.pmostunefingers, 2 do
        cmpactivecontacts[cmfingers - _P.pmosdiodefingers - _P.pmoszerofingers + 1 - i] = "inner"
        cmpactivecontacts[cmfingers - _P.pmosdiodefingers - _P.pmoszerofingers + 0 - i] = "power"
    end
    -- nmos active contacts
    for i = 2, _P.nmosdiodefingers + _P.nmoscurrentfingers, 2 do
        cmnactivecontacts[cmfingers + 2 - i] = "inner"
        cmnactivecontacts[cmfingers + 1 - i] = "power"
    end
    -- fill dummy contacts
    cmpactivecontacts[cmfingers - _P.pmosdiodefingers - _P.pmoszerofingers] = "power"
    for i = 1, cmfingers - _P.pmostunefingers - _P.pmoszerofingers - _P.pmosdiodefingers - 1 do
        cmpactivecontacts[i] = "power"
    end
    for i = 1, cmfingers - _P.nmosdiodefingers - _P.nmoscurrentfingers do
        cmnactivecontacts[i] = "power"
    end
    -- create current mirror layout
    local cmarray = pcell.create_layout("basic/cmos", { 
        fingers = cmfingers,
        gatecontactpos = cmgatecontacts, 
        pcontactpos = cmpactivecontacts, 
        ncontactpos = cmnactivecontacts,
        pcontactheight = _P.pfingerwidth - 120,
        ncontactheight = _P.nfingerwidth - 120,
    })
    cmarray:move_anchor("right", vcoarray:get_anchor("left"))
    oscillator:merge_into(cmarray)

    
    -- ** draw gate straps **
    -- * VCO *
    oscillator:merge_into(geometry.rectanglebltr(generics.metal(1), 
        vcoarray:get_anchor("Gn1"):translate(0, -_P.gstwidth / 2),
        vcoarray:get_anchor(string.format("Gn%d", 2 * _P.invfingers * _P.numinv)):translate(0, _P.gstwidth / 2)
    ))
    oscillator:merge_into(geometry.rectanglebltr(generics.metal(1), 
        vcoarray:get_anchor("Gp1"):translate(0, -_P.gstwidth / 2),
        vcoarray:get_anchor(string.format("Gp%d", 2 * _P.invfingers * _P.numinv)):translate(0, _P.gstwidth / 2)
    ))
    for i = 2, 2 * _P.invfingers * _P.numinv, 2 * _P.invfingers do
        oscillator:merge_into(geometry.rectanglebltr(generics.metal(1), 
            vcoarray:get_anchor(string.format("G%d", i + 0)):translate(0, -_P.gstwidth / 2),
            vcoarray:get_anchor(string.format("G%d", i + 4 * (_P.invfingers / 2 - 1) + 1)):translate(0,  _P.gstwidth / 2)
        ))
    end
    -- * bias *
    -- pmos diode
    oscillator:merge_into(geometry.rectanglebltr(generics.metal(1), 
        cmarray:get_anchor(string.format("Gu%d", cmfingers - _P.pmosdiodefingers + 1)):translate(0, -_P.gstwidth / 2),
        cmarray:get_anchor(string.format("Gu%d", cmfingers)):translate(0,  _P.gstwidth / 2)
    ))
    -- pmos zero current
    oscillator:merge_into(geometry.rectanglebltr(generics.metal(1), 
        cmarray:get_anchor(string.format("Gu%d", cmfingers - _P.pmosdiodefingers - _P.pmoszerofingers + 1)):translate(0,  _P.gstwidth / 2),
        cmarray:get_anchor(string.format("Gu%d", cmfingers - _P.pmosdiodefingers)):translate(0, -_P.gstwidth / 2)
    ))
    -- pmos tuning
    oscillator:merge_into(geometry.rectanglebltr(generics.metal(1), 
        cmarray:get_anchor(string.format("Gu%d", cmfingers - _P.pmosdiodefingers - _P.pmoszerofingers - _P.pmostunefingers)):translate(0,  _P.gstwidth / 2),
        cmarray:get_anchor(string.format("Gu%d", cmfingers - _P.pmosdiodefingers - _P.pmoszerofingers - 1)):translate(0, -_P.gstwidth / 2)
    ))
    -- nmos current mirror
    oscillator:merge_into(geometry.rectanglebltr(generics.metal(1), 
        cmarray:get_anchor(string.format("Gl%d", cmfingers - _P.nmoscurrentfingers - _P.nmosdiodefingers + 1)):translate(0, -_P.gstwidth / 2),
        cmarray:get_anchor(string.format("Gl%d", cmfingers)):translate(0,  _P.gstwidth / 2)
    ))
    -- pmos dummies
    if _P.pmosdiodefingers + _P.pmoszerofingers + _P.pmostunefingers + 1 < _P.nmoscurrentfingers + _P.nmosdiodefingers then
        oscillator:merge_into(geometry.rectanglebltr(generics.metal(1), 
            cmarray:get_anchor(string.format("Gu%d", 1)):translate(0, -_P.gstwidth / 2),
            cmarray:get_anchor(string.format("Gu%d", cmfingers - _P.pmosdiodefingers - _P.pmoszerofingers - _P.pmostunefingers - 1)):translate(0, _P.gstwidth / 2)
        ))
    end
    -- nmos dummies
    if _P.pmosdiodefingers + _P.pmoszerofingers + _P.pmostunefingers + 1 > _P.nmoscurrentfingers + _P.nmosdiodefingers then
        oscillator:merge_into(geometry.rectanglebltr(generics.metal(1), 
            cmarray:get_anchor(string.format("Gl%d", 1)):translate(0, -_P.gstwidth / 2),
            cmarray:get_anchor(string.format("Gl%d", cmfingers - _P.nmosdiodefingers - _P.nmoscurrentfingers)):translate(0, _P.gstwidth / 2)
        ))
    end

    -- draw bias source/drain connections
    for i = 2, _P.pmosdiodefingers, 2 do
        local index = cmfingers + 2 - i
        oscillator:merge_into(geometry.rectanglebltr(generics.metal(1), 
            cmarray:get_anchor(string.format("pSDi%d", index)):translate(-_P.gstwidth / 2, 0),
            point.combine_12(
                cmarray:get_anchor(string.format("pSDi%d", index)),
                cmarray:get_anchor(string.format("Gu%d", index))
            ):translate(_P.gstwidth / 2, 0)
        ))
    end
    for i = 2, _P.nmosdiodefingers, 2 do
        local index = cmfingers - _P.nmoscurrentfingers + 2 - i
        oscillator:merge_into(geometry.rectanglebltr(generics.metal(1), 
            cmarray:get_anchor(string.format("nSDi%d", index)):translate(-_P.gstwidth / 2, 0),
            point.combine_12(
                cmarray:get_anchor(string.format("nSDi%d", index)),
                cmarray:get_anchor(string.format("Gl%d", index))
            ):translate(_P.gstwidth / 2, 0)
        ))
    end
    for i = 2, cmfingers - _P.pmostunefingers - _P.pmoszerofingers - _P.pmosdiodefingers - 1 do
        oscillator:merge_into(geometry.rectanglebltr(generics.metal(1), 
            cmarray:get_anchor(string.format("pSDi%d", i)):translate(-_P.gstwidth / 2, 0),
            point.combine_12(
                cmarray:get_anchor(string.format("pSDi%d", i)),
                cmarray:get_anchor(string.format("Gu%d", i))
            ):translate(_P.gstwidth / 2, 0)
        ))
    end
    for i = 2, cmfingers - _P.nmosdiodefingers - _P.nmoscurrentfingers do
        oscillator:merge_into(geometry.rectanglebltr(generics.metal(1), 
            cmarray:get_anchor(string.format("nSDi%d", i)):translate(-_P.gstwidth / 2, 0),
            point.combine_12(
                cmarray:get_anchor(string.format("nSDi%d", i)),
                cmarray:get_anchor(string.format("Gl%d", i))
            ):translate(_P.gstwidth / 2, 0)
        ))
    end
    oscillator:merge_into(geometry.rectanglebltr(generics.metal(1), 
        cmarray:get_anchor(string.format("Gu%d", cmfingers - _P.pmosdiodefingers - _P.pmoszerofingers)):translate(-_P.gstwidth / 2, 0),
        point.combine_12(
            cmarray:get_anchor(string.format("Gu%d", cmfingers - _P.pmosdiodefingers - _P.pmoszerofingers)),
            cmarray:get_anchor("top")
        ):translate(_P.gstwidth / 2, 0)
    ))
    -- connect left pmos/nmos
    for i = 0, _P.pmostunefingers, 2 do
        local index = cmfingers - _P.pmosdiodefingers - _P.pmoszerofingers + 1 - i
        oscillator:merge_into(geometry.rectanglebltr(generics.via(1, 2), 
            cmarray:get_anchor(string.format("pSDi%d", index)):translate(-_P.gstwidth / 2, 0),
            cmarray:get_anchor(string.format("pSDo%d", index)):translate( _P.gstwidth / 2, 0)
        ))
    end
    oscillator:merge_into(geometry.path(generics.metal(2), geometry.path_points_xy(
        cmarray:get_anchor(string.format("pSDc%d", cmfingers - _P.pmosdiodefingers - _P.pmoszerofingers - _P.pmostunefingers + 1)), {
        cmarray:get_anchor(string.format("pSDc%d", cmfingers - _P.pmosdiodefingers - _P.pmoszerofingers + 1)),
        0, -- toggle xy
        cmarray:get_anchor(string.format("Gl%d", cmfingers - _P.nmoscurrentfingers)),
        vcoarray:get_anchor("Gn1")
    }), _P.gstwidth))
    oscillator:merge_into(geometry.rectangle(generics.via(1, 2), xpitch, _P.gstwidth)
        :translate(cmarray:get_anchor(string.format("Gl%d", cmfingers - _P.nmoscurrentfingers)))
    )
    oscillator:merge_into(geometry.rectangle(generics.via(1, 2), xpitch, _P.gstwidth)
        :translate(vcoarray:get_anchor("Gn1"))
    )
    -- connect right pmos/nmos
    oscillator:merge_into(geometry.rectanglebltr(generics.metal(2), 
        cmarray:get_anchor(string.format("nSDo%d", cmfingers)):translate(-_P.gstwidth / 2, 0),
        cmarray:get_anchor(string.format("pSDo%d", cmfingers)):translate( _P.gstwidth / 2, 0)
    ))
    oscillator:merge_into(geometry.path(generics.metal(2), geometry.path_points_yx(
        cmarray:get_anchor(string.format("pSDo%d", cmfingers)), {
            vcoarray:get_anchor("Gp1")
        }), _P.gstwidth
    ))
    oscillator:merge_into(geometry.rectangle(generics.via(1, 2), xpitch, _P.gstwidth)
        :translate(vcoarray:get_anchor("Gp1"))
    )
    if _P.pmosdiodefingers > 2 then
        oscillator:merge_into(geometry.path(generics.metal(2), {
            cmarray:get_anchor(string.format("pSDc%d", cmfingers - _P.pmosdiodefingers + 2)),
            cmarray:get_anchor(string.format("pSDc%d", cmfingers)),
        }, _P.gstwidth))
    end
    if _P.nmoscurrentfingers > 2 then
        oscillator:merge_into(geometry.path(generics.metal(2), {
            cmarray:get_anchor(string.format("nSDc%d", cmfingers - _P.nmoscurrentfingers + 2)),
            cmarray:get_anchor(string.format("nSDc%d", cmfingers)),
        }, _P.gstwidth))
    end
    for i = 2, _P.pmosdiodefingers, 2 do
        oscillator:merge_into(geometry.rectanglebltr(generics.via(1, 2), 
            cmarray:get_anchor(string.format("pSDi%d", cmfingers + 2 - i)):translate(-_P.gstwidth / 2, 0),
            cmarray:get_anchor(string.format("pSDo%d", cmfingers + 2 - i)):translate( _P.gstwidth / 2, 0)
        ))
    end
    for i = 2, _P.nmoscurrentfingers, 2 do
        oscillator:merge_into(geometry.rectanglebltr(generics.via(1, 2), 
            cmarray:get_anchor(string.format("nSDo%d", cmfingers + 2 - i)):translate(-_P.gstwidth / 2, 0),
            cmarray:get_anchor(string.format("nSDi%d", cmfingers + 2 - i)):translate( _P.gstwidth / 2, 0)
        ))
    end

    -- draw inverter connections
    for i = 3, 2 * _P.invfingers * _P.numinv, 4 do
        oscillator:merge_into(geometry.rectanglebltr(generics.metal(1), 
            vcoarray:get_anchor(string.format("pSDo%d", i - 1)):translate(0, -_P.gstwidth),
            vcoarray:get_anchor(string.format("pSDo%d", i + 1))
        ))
        oscillator:merge_into(geometry.rectanglebltr(generics.metal(1), 
            vcoarray:get_anchor(string.format("nSDo%d", i - 1)):translate(0,  _P.gstwidth),
            vcoarray:get_anchor(string.format("nSDo%d", i + 1))
        ))
        if _P.invfingers > 2 then
            oscillator:merge_into(geometry.rectanglebltr(generics.via(1, 2), 
                vcoarray:get_anchor(string.format("pSDo%d", i - 1)):translate(0, -_P.gstwidth),
                vcoarray:get_anchor(string.format("pSDo%d", i + 1))
            ))
            oscillator:merge_into(geometry.rectanglebltr(generics.via(1, 2), 
                vcoarray:get_anchor(string.format("nSDo%d", i - 1)):translate(0,  _P.gstwidth),
                vcoarray:get_anchor(string.format("nSDo%d", i + 1))
            ))
        end
        -- connect drains to gate of next inverter
        if i < 2 * _P.invfingers * (_P.numinv - 1) then
            oscillator:merge_into(geometry.path(generics.metal(1), {
                vcoarray:get_anchor(string.format("G%d", i + 3)):translate(3 * xpitch / 2, 0),
                vcoarray:get_anchor(string.format("G%d", i + 3)),
            }, _P.gstwidth))
        end
    end
    for i = 1, _P.numinv do
        -- connect current sources drains on M2
        if _P.invfingers > 2 then
            oscillator:merge_into(geometry.rectanglebltr(generics.metal(2), 
                vcoarray:get_anchor(string.format("pSDo%d", (i - 1) * 2 * _P.invfingers + 2)):translate(0, -_P.gstwidth),
                vcoarray:get_anchor(string.format("pSDo%d", (i - 1) * 2 * _P.invfingers + 2 * _P.invfingers))
            ))
            oscillator:merge_into(geometry.rectanglebltr(generics.metal(2), 
                vcoarray:get_anchor(string.format("nSDo%d", (i - 1) * 2 * _P.invfingers + 2)):translate(0, _P.gstwidth),
                vcoarray:get_anchor(string.format("nSDo%d", (i - 1) * 2 * _P.invfingers + 2 * _P.invfingers))
            ))
        end
        oscillator:merge_into(geometry.path(generics.metal(1), geometry.path_points_xy(
            vcoarray:get_anchor(string.format("pSDi%d", (i - 1) * 2 * _P.invfingers + 3)):translate(0, _P.gstwidth / 2), {
                2 * (_P.invfingers - 1) * xpitch,
                vcoarray:get_anchor(string.format("nSDi%d", (i - 1) * 2 * _P.invfingers + 3)):translate(0, -_P.gstwidth / 2),
            }), _P.gstwidth
        ))
    end

    -- feedback connection
    oscillator:merge_into(geometry.rectanglebltr(generics.metal(2), 
        vcoarray:get_anchor(string.format("G%d", 2 * _P.numinv * _P.invfingers - 1)):translate(3 * xpitch / 2, _P.gstwidth / 2),
        vcoarray:get_anchor(string.format("G%d", 2)):translate(-_P.glength / 2, -_P.gstwidth / 2)
    ))
    oscillator:merge_into(
        geometry.rectangle(generics.via(1, 2), _P.gstwidth, _P.separation + 2 * _P.gstwidth)
        :translate(vcoarray:get_anchor(string.format("G%d", 2 * _P.numinv * _P.invfingers - 1)):translate(3 * xpitch / 2, 0))
    )
    oscillator:merge_into(
        geometry.rectangle(generics.via(1, 2), 2 * _P.glength + _P.gspace, _P.gstwidth)
        :translate(vcoarray:get_anchor(string.format("G%d", 2)):translate(xpitch / 2, 0))
    )

    -- center oscillator
    oscillator:translate_flat((cmfingers - 2 * _P.numinv * _P.invfingers) * xpitch / 2, 0)

    -- place guardring
    local ringwidth = 200
    oscillator:merge_into(pcell.create_layout("auxiliary/guardring", { 
        contype = "p",
        fillwell = true,
        ringwidth = ringwidth,
        width = (cmfingers + 2 * _P.numinv * _P.invfingers + 4) * xpitch, 
        height = 6 * _P.separation + _P.pfingerwidth + _P.nfingerwidth + ringwidth
    }))
    oscillator:merge_into(pcell.create_layout("auxiliary/guardring", { 
        contype = "n",
        fillwell = false,
        drawdeepwell = true,
        ringwidth = ringwidth,
        width = (cmfingers + 2 * _P.numinv * _P.invfingers + 4) * xpitch + 2 * _P.separation + 2 * ringwidth,
        height = 8 * _P.separation + _P.pfingerwidth + _P.nfingerwidth + ringwidth + 2 * ringwidth
    }))
end

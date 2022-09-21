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
  'pmostunefingers'    |            |o--*              |
   in series (nf = 1)  |        |---|   |              |
                       |        |       |              |
                   |---|        |---|   |              |
               ---o|   |            |o--*              |
               |   |---|        |---|   |              |
               |       |        |       |              |    'pmosdiodefingers'
               |   |---|        |---|   |              |---| 
       vtune o-*--o|                |o--*---- VSS          |o--*-o vbiasp
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
    pcell.reference_cell("basic/mosfet")
    pcell.reference_cell("basic/cmos")
    pcell.add_parameters(
        { "invfingers",            2, posvals = even() },
        { "numinv",                3, posvals = odd() },
        { "pmosdiodefingers",      2, posvals = even() },
        { "pmoszerofingers",       7 },
        { "pmostunefingers",       2, posvals = even() },
        { "nmoscurrentfingers",    2, posvals = even() },
        { "nmosdiodefingers",      4, posvals = even() },
        { "pmosseparationfingers", 3 },
        { "mosdummieseverynth",    1 },
        { "glength",               tech.get_dimension("Minimum Gate Length") },
        { "gspace",                tech.get_dimension("Minimum Gate XSpace") },
        { "pfingerwidth",          2 * tech.get_dimension("Minimum Gate Width") },
        { "nfingerwidth",          2 * tech.get_dimension("Minimum Gate Width") },
        { "pfingercontactwidth",   tech.get_dimension("Minimum Gate Width") },
        { "nfingercontactwidth",   tech.get_dimension("Minimum Gate Width") },
        { "gstwidth",              tech.get_dimension("Minimum M1 Width") },
        { "gstspace",              tech.get_dimension("Minimum M1 Space") },
        { "powerwidth",            tech.get_dimension("Minimum M1 Width") },
        { "powerspace",            tech.get_dimension("Minimum M1 Space") },
        { "bufspacers",            2 },
        { "buffingers",            4 },
        { "drawguardrings",        true },
        { "guardringwidth",        200 },
        { "guardringspace",        300 }
    )
end

function layout(oscillator, _P)
    local cbp = pcell.get_parameters("basic/cmos")
    local xpitch = _P.glength + _P.gspace

    local separation = 3 * _P.gstwidth + 5 * _P.gstspace

    pcell.push_overwrites("basic/cmos", {
        gatelength = _P.glength,
        gatespace = _P.gspace,
        gstwidth = _P.gstwidth,
        sdwidth = _P.gstwidth,
        pwidth = _P.pfingerwidth,
        nwidth = _P.nfingerwidth,
        nvthtype = 1,
        pvthtype = 1,
        nmosflippedwell = false,
        pmosflippedwell = true,
        psdheight = _P.pfingercontactwidth,
        nsdheight = _P.nfingercontactwidth,
        psdpowerheight = _P.pfingercontactwidth,
        nsdpowerheight = _P.nfingercontactwidth,
        powerwidth = _P.powerwidth,
        ppowerspace = _P.powerspace,
        npowerspace = _P.powerspace,
        separation = separation,
        gatecontactsplitshift = _P.gstwidth + _P.gstspace,
        gateext = 2 * _P.powerwidth + 2 * _P.powerspace,
        outergstwidth = _P.gstwidth,
        outergstspace = _P.powerspace,
    })

    -- place inverter cells
    local invgatecontacts = {}
    for i = 1, 2 * _P.invfingers do
        if (i % 4 == 2) or (i % 4 == 3) then
            invgatecontacts[i] = "center"
        else
            invgatecontacts[i] = "outer"
        end
    end
    local invactivecontacts = {}
    for i = 1, 2 * _P.invfingers + 1 do
        if i % 4 == 3 then
            invactivecontacts[i] = "inner"
        elseif i % 4 == 1 then
            invactivecontacts[i] = "power"
        else
            invactivecontacts[i] = "outer"
        end
    end
    local inverterref = pcell.create_layout("basic/cmos", { 
        gatecontactpos = invgatecontacts, 
        pcontactpos = invactivecontacts, 
        ncontactpos = invactivecontacts,
    })
    -- current sources gate straps
    geometry.rectanglebltr(inverterref, generics.metal(1), 
        inverterref:get_anchor("Gn1cc"):translate(-xpitch / 2, -_P.gstwidth / 2),
        inverterref:get_anchor(string.format("Gn%dcc", 2 * _P.invfingers)):translate(xpitch / 2, _P.gstwidth / 2)
    )
    geometry.rectanglebltr(inverterref, generics.metal(1), 
        inverterref:get_anchor("Gp1cc"):translate(-xpitch / 2, -_P.gstwidth / 2),
        inverterref:get_anchor(string.format("Gp%dcc", 2 * _P.invfingers)):translate(xpitch / 2, _P.gstwidth / 2)
    )
    -- connect inverter gates
    geometry.rectanglebltr(inverterref, generics.metal(1), 
        inverterref:get_anchor(string.format("G%dbl", 2 + 0)),
        inverterref:get_anchor(string.format("G%dtr", 2 + 4 * (_P.invfingers / 2 - 1) + 1))
    )
    for i = 3, 2 * _P.invfingers, 4 do
        geometry.rectanglebltr(inverterref, generics.metal(1), 
            inverterref:get_anchor(string.format("pSD%dtr", i - 1)):translate(0, -_P.gstwidth),
            inverterref:get_anchor(string.format("pSD%dtl", i + 1))
        )
        geometry.rectanglebltr(inverterref, generics.metal(1), 
            inverterref:get_anchor(string.format("nSD%dbr", i - 1)),
            inverterref:get_anchor(string.format("nSD%dbl", i + 1)):translate(0,  _P.gstwidth)
        )
    end
    -- connect current sources drains on M2
    if _P.invfingers > 2 then
        geometry.rectanglebltr(inverterref, generics.metal(2), 
            inverterref:get_anchor(string.format("pSD%dtl", 2)):translate(0, -_P.gstwidth),
            inverterref:get_anchor(string.format("pSD%dtr", 2 * _P.invfingers))
        )
        geometry.rectanglebltr(inverterref, generics.metal(2), 
            inverterref:get_anchor(string.format("nSD%dbl", 2)),
            inverterref:get_anchor(string.format("nSD%dbr", 2 * _P.invfingers)):translate(0, _P.gstwidth)
        )
        for i = 3, 2 * _P.invfingers, 4 do
            geometry.viabltr(inverterref, 1, 2, 
                inverterref:get_anchor(string.format("pSD%dtl", i - 1)):translate(0, -_P.gstwidth),
                inverterref:get_anchor(string.format("pSD%dtr", i + 1))
            )
            geometry.viabltr(inverterref, 1, 2, 
                inverterref:get_anchor(string.format("nSD%dbl", i - 1)),
                inverterref:get_anchor(string.format("nSD%dbr", i + 1)):translate(0, _P.gstwidth)
            )
        end
    end
    geometry.path(inverterref, generics.metal(1), geometry.path_points_xy(
        inverterref:get_anchor(string.format("pSD%dbr", 3)):translate(0, _P.gstwidth / 2), {
            2 * (_P.invfingers - 1) * xpitch,
            inverterref:get_anchor(string.format("nSD%dtr", 3)):translate(0, -_P.gstwidth / 2),
        }), _P.gstwidth
    )
    inverterref:add_port("vin", generics.metalport(1), inverterref:get_anchor("G2cc"))
    inverterref:add_port("vout", generics.metalport(1), inverterref:get_anchor(string.format("G%dcc", 2 * _P.invfingers - 1)):translate(3 * xpitch / 2, 0))
    inverterref:add_port("vbiasp", generics.metalport(1), inverterref:get_anchor(string.format("Gp%dcc", 1)):translate(3 * xpitch / 2, 0))
    inverterref:add_port("vbiasn", generics.metalport(1), inverterref:get_anchor(string.format("Gn%dcc", 1)):translate(3 * xpitch / 2, 0))
    inverterref:add_port("vdd", generics.metalport(1), inverterref:get_anchor("PRpcc"))
    inverterref:add_port("vss", generics.metalport(1), inverterref:get_anchor("PRncc"))
    local invname = pcell.add_cell_reference(inverterref, "vco_inverter")
    local inverters = {}
    for i = 1, _P.numinv do
        inverters[i] = oscillator:add_child(invname)
        if i > 1 then
            inverters[i]:move_anchor("left", inverters[i - 1]:get_anchor("right"))
        end
    end

    -- current mirror settings
    local cmgatecontacts = {}
    local cmfingers = math.max(_P.pmosdiodefingers + _P.pmoszerofingers + _P.pmostunefingers + _P.pmosseparationfingers, _P.nmoscurrentfingers + _P.nmosdiodefingers)
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
    cmpactivecontacts[cmfingers + 1 - _P.pmosdiodefingers - _P.pmoszerofingers - _P.pmosseparationfingers] = "inner"
    cmpactivecontacts[cmfingers + 1 - _P.pmosdiodefingers - _P.pmoszerofingers - _P.pmosseparationfingers - _P.pmostunefingers] = "power"
    -- pmos separation fingers
    for i = 1, _P.pmosseparationfingers - 1 do
        cmpactivecontacts[cmfingers - _P.pmosdiodefingers - _P.pmoszerofingers - i + 1] = "power"
    end
    -- nmos active contacts
    for i = 2, _P.nmosdiodefingers + _P.nmoscurrentfingers, 2 do
        cmnactivecontacts[cmfingers + 2 - i] = "inner"
        cmnactivecontacts[cmfingers + 1 - i] = "power"
    end
    -- fill dummy contacts
    cmpactivecontacts[cmfingers - _P.pmosdiodefingers - _P.pmoszerofingers - _P.pmosseparationfingers - _P.pmostunefingers + 1] = "power"
    for i = 1, cmfingers - _P.pmostunefingers - _P.pmoszerofingers - _P.pmosdiodefingers - _P.pmosseparationfingers do
        cmpactivecontacts[i] = "power"
    end
    for i = 1, cmfingers - _P.nmosdiodefingers - _P.nmoscurrentfingers do
        cmnactivecontacts[i] = "power"
    end
    -- create current mirror layout
    local cmarray = pcell.create_layout("basic/cmos", { 
        gatecontactpos = cmgatecontacts, 
        pcontactpos = cmpactivecontacts, 
        ncontactpos = cmnactivecontacts,
    })
    -- pmos diode
    geometry.rectanglebltr(cmarray, generics.metal(1), 
        cmarray:get_anchor(string.format("Gupper%dbl", cmfingers - _P.pmosdiodefingers + 1)),
        cmarray:get_anchor(string.format("Gupper%dtr", cmfingers))
    )
    -- pmos zero current
    geometry.rectanglebltr(cmarray, generics.metal(1), 
        cmarray:get_anchor(string.format("Gupper%dbl", cmfingers - _P.pmosdiodefingers - _P.pmoszerofingers + 1)),
        cmarray:get_anchor(string.format("Gupper%dtr", cmfingers - _P.pmosdiodefingers))
    )
    -- pmos tuning
    geometry.rectanglebltr(cmarray, generics.metal(1), 
        cmarray:get_anchor(string.format("Gupper%dbl", cmfingers - _P.pmosdiodefingers - _P.pmoszerofingers - _P.pmostunefingers - _P.pmosseparationfingers + 1)),
        cmarray:get_anchor(string.format("Gupper%dtr", cmfingers - _P.pmosdiodefingers - _P.pmoszerofingers - _P.pmosseparationfingers))
    )
    -- nmos current mirror
    geometry.rectanglebltr(cmarray, generics.metal(1), 
        cmarray:get_anchor(string.format("Glower%dbl", cmfingers - _P.nmoscurrentfingers - _P.nmosdiodefingers + 1)),
        cmarray:get_anchor(string.format("Glower%dtr", cmfingers))
    )
    -- pmos dummies
    if _P.pmosdiodefingers + _P.pmoszerofingers + _P.pmostunefingers + 1 < _P.nmoscurrentfingers + _P.nmosdiodefingers then
        geometry.rectanglebltr(cmarray, generics.metal(1), 
            cmarray:get_anchor(string.format("Gupper%dbl", 1)),
            cmarray:get_anchor(string.format("Gupper%dtr", cmfingers - _P.pmosdiodefingers - _P.pmoszerofingers - _P.pmostunefingers - 1))
        )
    end
    -- nmos dummies
    if _P.pmosdiodefingers + _P.pmoszerofingers + _P.pmostunefingers + _P.pmosseparationfingers > _P.nmoscurrentfingers + _P.nmosdiodefingers then
        geometry.rectanglebltr(cmarray, generics.metal(1), 
            cmarray:get_anchor(string.format("Glower%dbl", 1)),
            cmarray:get_anchor(string.format("Glower%dtr", cmfingers - _P.nmosdiodefingers - _P.nmoscurrentfingers))
        )
    end
    -- draw bias source/drain connections
    for i = 2, _P.pmosdiodefingers, 2 do
        local index = cmfingers + 2 - i
        geometry.rectanglepoints(cmarray, generics.metal(2), 
            point.combine_12(
                cmarray:get_anchor(string.format("pSD%dbl", index)),
                cmarray:get_anchor(string.format("Gupper%dtc", index))
            ),
            cmarray:get_anchor(string.format("pSD%dbr", index))
        )
    end
    for i = 2, _P.nmosdiodefingers, 2 do
        local index = cmfingers - _P.nmoscurrentfingers + 2 - i
        geometry.rectanglebltr(cmarray, generics.metal(1), 
            cmarray:get_anchor(string.format("nSD%dtl", index)),
            point.combine_12(
                cmarray:get_anchor(string.format("nSD%dtr", index)),
                cmarray:get_anchor(string.format("Glower%dbc", index))
            )
        )
    end
    -- connect pmos zero gates to vss
    geometry.rectanglebltr(cmarray, generics.metal(1), 
        cmarray:get_anchor(string.format("Glower%dtc", cmfingers - _P.pmosdiodefingers - _P.pmoszerofingers // 2)):translate(-_P.gstwidth / 2, 0),
        cmarray:get_anchor(string.format("Gupper%dtc", cmfingers - _P.pmosdiodefingers - _P.pmoszerofingers // 2)):translate( _P.gstwidth / 2, 0)
    )
    for i = 2, cmfingers - _P.pmostunefingers - _P.pmoszerofingers - _P.pmosdiodefingers - _P.pmosseparationfingers, _P.mosdummieseverynth do
        geometry.rectanglebltr(cmarray, generics.metal(1), 
            point.combine_12(
                cmarray:get_anchor(string.format("pSD%dbl", i)),
                cmarray:get_anchor(string.format("Gupper%dtc", i))
            ),
            cmarray:get_anchor(string.format("pSD%dbr", i))
        )
    end
    for i = 2, cmfingers - _P.nmosdiodefingers - _P.nmoscurrentfingers, _P.mosdummieseverynth do
        geometry.rectanglebltr(cmarray, generics.metal(1), 
            cmarray:get_anchor(string.format("nSD%dtl", i)),
            point.combine_12(
                cmarray:get_anchor(string.format("nSD%dtr", i)),
                cmarray:get_anchor(string.format("Glower%dbc", i))
            )
        )
    end
    -- connect dummy pmos separation gate
    geometry.rectanglebltr(cmarray, generics.metal(1),
        cmarray:get_anchor(string.format("Gupper%dbl", cmfingers - _P.pmosdiodefingers - _P.pmoszerofingers - _P.pmosseparationfingers + 1)),
        cmarray:get_anchor(string.format("Gupper%dtr", cmfingers - _P.pmosdiodefingers - _P.pmoszerofingers))
    )
    -- connect dummy pmos separation gate to drain
    geometry.rectanglebltr(cmarray, generics.metal(1), 
        point.combine_12(
            cmarray:get_anchor(string.format("pSD%dbl", cmfingers - _P.pmosdiodefingers - _P.pmoszerofingers - _P.pmosseparationfingers // 2)),
            cmarray:get_anchor(string.format("Gupper%dtr", cmfingers - _P.pmosdiodefingers - _P.pmoszerofingers - _P.pmosseparationfingers // 2))
        ),
        cmarray:get_anchor(string.format("pSD%dbr", cmfingers - _P.pmosdiodefingers - _P.pmoszerofingers - _P.pmosseparationfingers // 2))
    )
    -- connect left pmos/nmos
    local index = cmfingers - _P.pmosdiodefingers - _P.pmoszerofingers - _P.pmosseparationfingers + 1
    geometry.viabltr(cmarray, 1, 2, 
        cmarray:get_anchor(string.format("pSD%dbl", index)),
        cmarray:get_anchor(string.format("pSD%dtr", index))
    )
    geometry.rectanglebltr(cmarray, generics.metal(2),
        point.combine_12(
            cmarray:get_anchor(string.format("pSD%dbl", cmfingers - _P.pmosdiodefingers - _P.pmoszerofingers - _P.pmosseparationfingers + 1)),
            cmarray:get_anchor(string.format("Glower%dbc", cmfingers - _P.nmoscurrentfingers))
        ),
        cmarray:get_anchor(string.format("pSD%dbr", index))
    )
    local index = cmfingers - _P.pmosdiodefingers - _P.pmoszerofingers + 1
    geometry.viabltr(cmarray, 1, 2, 
        cmarray:get_anchor(string.format("pSD%dbl", index)),
        cmarray:get_anchor(string.format("pSD%dtr", index))
    )
    geometry.rectanglebltr(cmarray, generics.metal(2),
        point.combine_12(
            cmarray:get_anchor(string.format("pSD%dbl", cmfingers - _P.pmosdiodefingers - _P.pmoszerofingers + 1)),
            cmarray:get_anchor(string.format("Glower%dbc", cmfingers - _P.nmoscurrentfingers))
        ),
        cmarray:get_anchor(string.format("pSD%dbr", cmfingers - _P.pmosdiodefingers - _P.pmoszerofingers + 1))
    )
    geometry.viabltr(cmarray, 1, 2,
        cmarray:get_anchor(string.format("nSD%dbl", cmfingers - _P.nmoscurrentfingers)),
        cmarray:get_anchor(string.format("nSD%dtr", cmfingers - _P.nmoscurrentfingers))
    )
    -- connect right pmos/nmos
    geometry.rectanglebltr(cmarray, generics.metal(2), 
        cmarray:get_anchor(string.format("nSD%dbl", cmfingers)),
        cmarray:get_anchor(string.format("pSD%dtr", cmfingers))
    )
    if _P.pmosdiodefingers > 2 then
        geometry.path(cmarray, generics.metal(2), {
            cmarray:get_anchor(string.format("pSD%dcc", cmfingers - _P.pmosdiodefingers + 2)),
            cmarray:get_anchor(string.format("pSD%dcc", cmfingers)),
        }, _P.gstwidth)
    end
    if _P.nmoscurrentfingers > 2 then
        geometry.path(cmarray, generics.metal(2), {
            cmarray:get_anchor(string.format("nSD%dcc", cmfingers - _P.nmoscurrentfingers + 2)),
            cmarray:get_anchor(string.format("nSD%dcc", cmfingers)),
        }, _P.gstwidth)
    end
    for i = 2, _P.pmosdiodefingers, 2 do
        geometry.viabltr(cmarray, 1, 2,
            cmarray:get_anchor(string.format("pSD%dbl", cmfingers + 2 - i)),
            cmarray:get_anchor(string.format("pSD%dtr", cmfingers + 2 - i))
        )
    end
    for i = 2, _P.nmoscurrentfingers, 2 do
        geometry.viabltr(cmarray, 1, 2,
            cmarray:get_anchor(string.format("nSD%dbl", cmfingers + 2 - i)),
            cmarray:get_anchor(string.format("nSD%dtr", cmfingers + 2 - i))
        )
    end
    local cmname = pcell.add_cell_reference(cmarray, "vco_currentmirror")
    local currentmirror = oscillator:add_child(cmname)
    currentmirror:move_anchor("right", inverters[1]:get_anchor("left"))

    -- create output buffer layout
    local buffergatecontacts = {}
    local bufferpactivecontacts = {}
    local buffernactivecontacts = {}
    for i = 1, _P.bufspacers do
        buffergatecontacts[i] = "dummy"
    end
    for i = 1, _P.buffingers do
        buffergatecontacts[_P.bufspacers + i] = "center"
    end
    for i = 1, _P.bufspacers + 1 do
        bufferpactivecontacts[i] = "power"
        buffernactivecontacts[i] = "power"
    end
    for i = 1, _P.buffingers + 1, 2 do
        bufferpactivecontacts[_P.bufspacers + i] = "power"
        bufferpactivecontacts[_P.bufspacers + i + 1] = "inner"
        buffernactivecontacts[_P.bufspacers + i] = "power"
        buffernactivecontacts[_P.bufspacers + i + 1] = "inner"
    end
    local bufferarray = pcell.create_layout("basic/cmos", { 
        gatecontactpos = buffergatecontacts, 
        pcontactpos = bufferpactivecontacts, 
        ncontactpos = buffernactivecontacts,
    })
    geometry.rectanglebltr(bufferarray,
        generics.metal(1),
        bufferarray:get_anchor(string.format("G%dbl", _P.bufspacers + 1)),
        bufferarray:get_anchor(string.format("G%dtr", _P.bufspacers + _P.buffingers))
    )
    geometry.path(bufferarray, generics.metal(1), 
        {
            bufferarray:get_anchor(string.format("pSD%dbr", _P.bufspacers + 2)):translate(0, _P.gstwidth / 2),
            bufferarray:get_anchor(string.format("pSD%dbr", _P.bufspacers + _P.buffingers)):translate(0, _P.gstwidth / 2),
            bufferarray:get_anchor(string.format("pSD%dbr", _P.bufspacers + _P.buffingers)):translate(2 * xpitch, _P.gstwidth / 2),
            bufferarray:get_anchor(string.format("nSD%dtr", _P.bufspacers + _P.buffingers)):translate(2 * xpitch, -_P.gstwidth / 2),
            bufferarray:get_anchor(string.format("nSD%dtr", _P.bufspacers + _P.buffingers)):translate(0, -_P.gstwidth / 2),
            bufferarray:get_anchor(string.format("nSD%dtr", _P.bufspacers + 2)):translate(0, -_P.gstwidth / 2)
        }, _P.gstwidth
    )
    local buffername = pcell.add_cell_reference(bufferarray, "vco_outputbuffer")
    local buffer = oscillator:add_child(buffername)
    buffer:move_anchor("left", inverters[_P.numinv]:get_anchor("right"))

    -- draw inverter connections
    for i = 1, _P.numinv - 1 do
        -- connect drains to gate of next inverter
        geometry.path(oscillator, generics.metal(1), 
            geometry.path_points_xy(
            point.combine_12(
                inverters[i]:get_anchor(string.format("pSD%dbr", 2 * _P.invfingers + 1)),
                inverters[i]:get_anchor(string.format("G%dcc", 2))
            ), { 2 * xpitch }), _P.gstwidth)
    end

    geometry.path(oscillator, generics.metal(2), geometry.path_points_yx(
        currentmirror:get_anchor(string.format("pSD%dtc", cmfingers)), {
            inverters[1]:get_anchor("Gp1cc")
        }), _P.gstwidth
    )
    geometry.viabltr(
        oscillator, 1, 2, 
        inverters[1]:get_anchor("Gp1bl"):translate(-_P.gspace / 2, 0),
        inverters[_P.numinv]:get_anchor(string.format("Gp%dtr", 2 * _P.invfingers)):translate(_P.gspace / 2, 0)
    )

    -- connect vbiasn to core
    geometry.path(oscillator, generics.metal(2), {
        point.combine_12(
            currentmirror:get_anchor(string.format("pSD%dbr", cmfingers - _P.pmosdiodefingers - _P.pmoszerofingers - _P.pmosseparationfingers + 1)),
            currentmirror:get_anchor(string.format("Glower%dcc", cmfingers - _P.nmoscurrentfingers))
        ),
        point.combine_12(
            currentmirror:get_anchor(string.format("nSD%dtc", cmfingers - _P.nmoscurrentfingers)),
            currentmirror:get_anchor(string.format("Glower%dcc", cmfingers - _P.nmoscurrentfingers))
        ),
        point.combine_12(
            currentmirror:get_anchor(string.format("nSD%dtc", cmfingers - _P.nmoscurrentfingers)),
            inverters[1]:get_anchor("Gn1cc")
        ),
        inverters[1]:get_anchor("Gn1cc")
    }, _P.gstwidth)
    geometry.viabltr(
        oscillator, 1, 2,
        inverters[1]:get_anchor("Gn1bl"):translate(-_P.gspace / 2, 0),
        inverters[_P.numinv]:get_anchor(string.format("Gn%dtr", 2 * _P.invfingers)):translate(_P.gspace / 2, 0)
    )

    -- feedback connection
    geometry.path(oscillator, generics.metal(2), {
            inverters[_P.numinv]:get_anchor(string.format("pSD%dbr", 2 * _P.invfingers + 1)) .. inverters[_P.numinv]:get_anchor(string.format("G%dcc", 2)),
            inverters[1]:get_anchor("G2cc"):translate(-_P.glength / 2, 0)
        }, _P.gstwidth
    )
    geometry.viabltr(oscillator, 1, 2,
        inverters[_P.numinv]:get_anchor(string.format("G%dbl", 2 * _P.invfingers - 1)):translate(xpitch + _P.glength + _P.gstwidth / 2, 0),
        buffer:get_anchor(string.format("G%dtr", _P.bufspacers + 1))
    )
    geometry.viabltr(
        oscillator, 1, 2,
        inverters[1]:get_anchor("G2cc"):translate(xpitch / 2, 0):translate(-_P.glength - _P.gspace / 2, -_P.gstwidth / 2),
        inverters[1]:get_anchor("G2cc"):translate(xpitch / 2, 0):translate( _P.glength + _P.gspace / 2,  _P.gstwidth / 2)
    )

    -- connect core to buffer
    geometry.rectanglebltr(oscillator, generics.metal(1),
        inverters[_P.numinv]:get_anchor(string.format("G%dbl", 2 * _P.invfingers - 1)):translate(xpitch + _P.glength + _P.gstwidth / 2, 0),
        buffer:get_anchor(string.format("G%dtr", _P.bufspacers + 1))
    )

    -- ports
    oscillator:add_port("vtune", generics.metalport(1), currentmirror:get_anchor("Gupper1cc"))
    oscillator:add_port("vout", generics.metalport(1), buffer:get_anchor(string.format("G%dcc", _P.bufspacers + _P.buffingers)):translate(3 * xpitch / 2, 0))
    oscillator:add_port("vdd", generics.metalport(1), currentmirror:get_anchor("PRpcc"))
    oscillator:add_port("vss", generics.metalport(1), currentmirror:get_anchor("PRncc"))

    -- center oscillator
    oscillator:translate((cmfingers + 1 - _P.numinv * 2 * _P.invfingers - _P.bufspacers - _P.buffingers) * xpitch / 2, 0)

    -- place guardring
    if _P.drawguardrings then
        local pguardringname = pcell.add_cell_reference(pcell.create_layout("auxiliary/guardring", { 
            contype = "p",
            fillwell = true,
            ringwidth = _P.guardringwidth,
            -- totalfingers + 2 for extra margin/spacing to guardring
            holewidth = (cmfingers + _P.numinv * 2 * _P.invfingers + _P.buffingers + _P.bufspacers + 2) * xpitch + 2 * _P.guardringspace, 
            holeheight = separation + _P.pfingerwidth + _P.nfingerwidth + 2 * (_P.powerspace + _P.powerwidth + _P.gstwidth + _P.powerspace + _P.guardringspace)
        }), "vco_pguardring")
        local nguardringname = pcell.add_cell_reference(pcell.create_layout("auxiliary/guardring", { 
            contype = "n",
            fillwell = false,
            drawdeepwell = true,
            ringwidth = _P.guardringwidth,
            -- totalfingers + 2 for extra margin/spacing to guardring
            holewidth = (cmfingers + 2 * _P.numinv * _P.invfingers + _P.buffingers + _P.bufspacers + 2) * xpitch + 2 * _P.guardringspace + 4 * _P.guardringwidth,
            holeheight = separation + _P.pfingerwidth + _P.nfingerwidth + 2 * (_P.powerspace + _P.powerwidth + _P.gstwidth + _P.powerspace + _P.guardringspace + 2 * _P.guardringwidth)
        }), "vco_nguardring")
        oscillator:add_child(pguardringname)
        oscillator:add_child(nguardringname)
    end

    pcell.pop_overwrites("basic/cmos")
end

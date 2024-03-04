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
    pcell.add_parameters(
        { "invfingers",            2, posvals = even() },
        { "numinv",                3, posvals = odd() },
        { "pmosdiodefingers",      4, posvals = even() },
        { "pmoszerofingers",       7 },
        { "pmostunefingers",       2 },
        { "pmosseparationfingers", 3 },
        { "nmoscurrentfingers",    2, posvals = even() },
        { "nmosdiodefingers",      4, posvals = even() },
        { "mosdummieseverynth",    1 },
        { "glength",               technology.get_dimension("Minimum Gate Length") },
        { "gspace",                technology.get_dimension("Minimum Gate XSpace") },
        { "pfingerwidth",          2 * technology.get_dimension("Minimum Gate Width") },
        { "nfingerwidth",          2 * technology.get_dimension("Minimum Gate Width") },
        { "pfingercontactwidth",   technology.get_dimension("Minimum Gate Width") },
        { "nfingercontactwidth",   technology.get_dimension("Minimum Gate Width") },
        { "gstwidth",              technology.get_dimension("Minimum M1 Width") },
        { "gstspace",              technology.get_dimension("Minimum M1 Space") },
        { "powerwidth",            technology.get_dimension("Minimum M1 Width") },
        { "powerspace",            technology.get_dimension("Minimum M1 Space") },
        { "bufspacers",            2 },
        { "buffingers",            4 },
        { "drawguardrings",        true },
        { "guardringwidth",        2 * technology.get_dimension("Minimum M1 Width") },
        { "guardringspace",        2 * technology.get_dimension("Minimum M1 Space") }
    )
end

function layout(oscillator, _P)
    local xpitch = _P.glength + _P.gspace

    local separation = 3 * _P.gstwidth + 4 * _P.gstspace

    local baseopt = {
        gatelength = _P.glength,
        gatespace = _P.gspace,
        gatestrapwidth = _P.gstwidth,
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
        pgateext = _P.powerwidth + _P.powerspace + _P.gstspace + _P.gstwidth,
        ngateext = _P.powerwidth + _P.powerspace + _P.gstspace + _P.gstwidth,
        outergatestrapwidth = _P.gstwidth,
        outergatestrapspace = _P.powerspace + _P.powerwidth + _P.gstspace,
    }

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
    local inverterref = pcell.create_layout("basic/cmos", "inverterref", util.add_options(baseopt, {
        gatecontactpos = invgatecontacts,
        pcontactpos = invactivecontacts,
        ncontactpos = invactivecontacts,
    }))
    -- connect inverter gates
    geometry.rectanglebltr(inverterref, generics.metal(1),
        inverterref:get_area_anchor(string.format("G%d", 2 + 0)).bl,
        inverterref:get_area_anchor(string.format("G%d", 2 + 4 * (_P.invfingers / 2 - 1) + 1)).tr
    )
    for i = 3, 2 * _P.invfingers, 4 do
        geometry.rectanglebltr(inverterref, generics.metal(1),
            inverterref:get_area_anchor(string.format("pSD%d", i - 1)).tr:translate(0, -_P.gstwidth),
            inverterref:get_area_anchor(string.format("pSD%d", i + 1)).tl
        )
        geometry.rectanglebltr(inverterref, generics.metal(1),
            inverterref:get_area_anchor(string.format("nSD%d", i - 1)).br,
            inverterref:get_area_anchor(string.format("nSD%d", i + 1)).bl:translate(0,  _P.gstwidth)
        )
    end
    -- connect current sources drains on M2
    if _P.invfingers > 2 then
        geometry.rectanglebltr(inverterref, generics.metal(2),
            inverterref:get_area_anchor(string.format("pSD%d", 2)).tl:translate(0, -_P.gstwidth),
            inverterref:get_area_anchor(string.format("pSD%d", 2 * _P.invfingers)).tr
        )
        geometry.rectanglebltr(inverterref, generics.metal(2),
            inverterref:get_area_anchor(string.format("nSD%d", 2)).bl,
            inverterref:get_area_anchor(string.format("nSD%d", 2 * _P.invfingers)).br:translate(0, _P.gstwidth)
        )
        for i = 3, 2 * _P.invfingers, 4 do
            geometry.viabltr(inverterref, 1, 2,
                inverterref:get_area_anchor(string.format("pSD%d", i - 1)).tl:translate(0, -_P.gstwidth),
                inverterref:get_area_anchor(string.format("pSD%d", i + 1)).tr
            )
            geometry.viabltr(inverterref, 1, 2,
                inverterref:get_area_anchor(string.format("nSD%d", i - 1)).bl,
                inverterref:get_area_anchor(string.format("nSD%d", i + 1)).br:translate(0, _P.gstwidth)
            )
        end
    end
    geometry.polygon(inverterref, generics.metal(1), {
        inverterref:get_area_anchor(string.format("pSD%d", 3)).br,
        (inverterref:get_area_anchor(string.format("G%d",  2 * _P.invfingers - 1)).br .. inverterref:get_area_anchor(string.format("pSD%d", 3)).br):translate(xpitch, 0),
        (inverterref:get_area_anchor(string.format("G%d",  2 * _P.invfingers - 1)).br .. inverterref:get_area_anchor(string.format("nSD%d", 3)).tr):translate(xpitch, 0),
        inverterref:get_area_anchor(string.format("nSD%d", 3)).tr,
        inverterref:get_area_anchor(string.format("nSD%d", 3)).tr:translate_y(-_P.gstwidth),
        (inverterref:get_area_anchor(string.format("G%d",  2 * _P.invfingers - 1)).br .. inverterref:get_area_anchor(string.format("nSD%d", 3)).tr):translate(xpitch + _P.gstwidth, -_P.gstwidth),
        (inverterref:get_area_anchor(string.format("G%d", 2 * _P.invfingers - 1)).br .. inverterref:get_area_anchor(string.format("pSD%d", 3)).br):translate(xpitch + _P.gstwidth, _P.gstwidth),
        inverterref:get_area_anchor(string.format("pSD%d", 3)).br:translate_y(_P.gstwidth),
    })

    inverterref:add_port("vin", generics.metalport(1), inverterref:get_area_anchor("G2").bl)
    inverterref:add_port("vout", generics.metalport(1), inverterref:get_area_anchor(string.format("G%d", 2 * _P.invfingers - 1)).br:translate(xpitch, 0))
    inverterref:add_port("vbiasp", generics.metalport(1), inverterref:get_area_anchor(string.format("Gp%d", 1)).bl:translate(3 * xpitch / 2, 0))
    inverterref:add_port("vbiasn", generics.metalport(1), inverterref:get_area_anchor(string.format("Gn%d", 1)).bl:translate(3 * xpitch / 2, 0))
    inverterref:add_port("vdd", generics.metalport(1), inverterref:get_area_anchor("PRp").bl)
    inverterref:add_port("vss", generics.metalport(1), inverterref:get_area_anchor("PRn").bl)

    local inverters = {}
    for i = 1, _P.numinv do
        inverters[i] = oscillator:add_child(inverterref, string.format("vco_inverter_%d", i))
        if i > 1 then
            inverters[i]:abut_right(inverters[i - 1])
        end
    end

    -- current mirror settings
    local cmfingers = math.max(_P.pmosdiodefingers + _P.pmoszerofingers + _P.pmostunefingers + _P.pmosseparationfingers, _P.nmoscurrentfingers + _P.nmosdiodefingers)
    local cmgatecontacts = util.fill_all_with(cmfingers, "split")
    local cmpactivecontacts = util.fill_all_with(cmfingers + 1, "unused")
    local cmnactivecontacts = util.fill_all_with(cmfingers + 1, "unused")
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
    local cmarray = pcell.create_layout("basic/cmos", "currentmirror", util.add_options(baseopt, {
        gatecontactpos = cmgatecontacts,
        pcontactpos = cmpactivecontacts,
        ncontactpos = cmnactivecontacts,
    }))
    -- pmos diode
    geometry.rectanglebltr(cmarray, generics.metal(1),
        cmarray:get_area_anchor(string.format("Gupper%d", cmfingers - _P.pmosdiodefingers + 1)).bl,
        cmarray:get_area_anchor(string.format("Gupper%d", cmfingers)).tr
    )
    -- pmos zero current
    geometry.rectanglebltr(cmarray, generics.metal(1),
        cmarray:get_area_anchor(string.format("Gupper%d", cmfingers - _P.pmosdiodefingers - _P.pmoszerofingers + 1)).bl,
        cmarray:get_area_anchor(string.format("Gupper%d", cmfingers - _P.pmosdiodefingers)).tr
    )
    -- pmos tuning
    geometry.rectanglebltr(cmarray, generics.metal(1),
        cmarray:get_area_anchor(string.format("Gupper%d", cmfingers - _P.pmosdiodefingers - _P.pmoszerofingers - _P.pmostunefingers - _P.pmosseparationfingers + 1)).bl,
        cmarray:get_area_anchor(string.format("Gupper%d", cmfingers - _P.pmosdiodefingers - _P.pmoszerofingers - _P.pmosseparationfingers)).tr
    )
    -- nmos current mirror
    geometry.rectanglebltr(cmarray, generics.metal(1),
        cmarray:get_area_anchor(string.format("Glower%d", cmfingers - _P.nmoscurrentfingers - _P.nmosdiodefingers + 1)).bl,
        cmarray:get_area_anchor(string.format("Glower%d", cmfingers)).tr
    )
    -- pmos dummies
    if _P.pmosdiodefingers + _P.pmoszerofingers + _P.pmostunefingers + 1 < _P.nmoscurrentfingers + _P.nmosdiodefingers then
        geometry.rectanglebltr(cmarray, generics.metal(1),
            cmarray:get_area_anchor(string.format("Gupper%d", 1)).bl,
            cmarray:get_area_anchor(string.format("Gupper%d", cmfingers - _P.pmosdiodefingers - _P.pmoszerofingers - _P.pmostunefingers - 1)).tr
        )
    end
    -- nmos dummies
    if _P.pmosdiodefingers + _P.pmoszerofingers + _P.pmostunefingers + _P.pmosseparationfingers > _P.nmoscurrentfingers + _P.nmosdiodefingers then
        geometry.rectanglebltr(cmarray, generics.metal(1),
            cmarray:get_area_anchor(string.format("Glower%d", 1)).bl,
            cmarray:get_area_anchor(string.format("Glower%d", cmfingers - _P.nmosdiodefingers - _P.nmoscurrentfingers)).tr
        )
    end
    -- draw bias source/drain connections
    for i = 2, _P.pmosdiodefingers, 2 do
        local index = cmfingers + 2 - i
        geometry.rectanglebltr(cmarray, generics.metal(1),
            cmarray:get_area_anchor(string.format("pSD%d", index)).bl .. cmarray:get_area_anchor(string.format("Gupper%d", index)).tl,
            cmarray:get_area_anchor(string.format("pSD%d", index)).br
        )
    end
    for i = 2, _P.nmosdiodefingers, 2 do
        local index = cmfingers - _P.nmoscurrentfingers + 2 - i
        geometry.rectanglebltr(cmarray, generics.metal(1),
            cmarray:get_area_anchor(string.format("nSD%d", index)).tl,
            point.combine_12(
                cmarray:get_area_anchor(string.format("nSD%d", index)).tr,
                cmarray:get_area_anchor(string.format("Glower%d", index)).bl
            )
        )
    end
    -- connect pmos zero gates to vss
    geometry.rectanglebltr(cmarray, generics.metal(1),
        cmarray:get_area_anchor(string.format("Glower%d", cmfingers - _P.pmosdiodefingers - _P.pmoszerofingers // 2)).tl:translate(-_P.gstwidth / 2, 0),
        cmarray:get_area_anchor(string.format("Gupper%d", cmfingers - _P.pmosdiodefingers - _P.pmoszerofingers // 2)).tl:translate( _P.gstwidth / 2, 0)
    )
    for i = 2, cmfingers - _P.pmostunefingers - _P.pmoszerofingers - _P.pmosdiodefingers - _P.pmosseparationfingers, _P.mosdummieseverynth do
        geometry.rectanglebltr(cmarray, generics.metal(1),
            point.combine_12(
                cmarray:get_area_anchor(string.format("pSD%d", i)).bl,
                cmarray:get_area_anchor(string.format("Gupper%d", i)).tl
            ),
            cmarray:get_area_anchor(string.format("pSD%d", i)).br
        )
    end
    for i = 2, cmfingers - _P.nmosdiodefingers - _P.nmoscurrentfingers, _P.mosdummieseverynth do
        geometry.rectanglebltr(cmarray, generics.metal(1),
            cmarray:get_area_anchor(string.format("nSD%d", i)).tl,
            point.combine_12(
                cmarray:get_area_anchor(string.format("nSD%d", i)).tr,
                cmarray:get_area_anchor(string.format("Glower%d", i)).bl
            )
        )
    end
    -- connect dummy pmos separation gate
    geometry.rectanglebltr(cmarray, generics.metal(1),
        cmarray:get_area_anchor(string.format("Gupper%d", cmfingers - _P.pmosdiodefingers - _P.pmoszerofingers - _P.pmosseparationfingers + 1)).bl,
        cmarray:get_area_anchor(string.format("Gupper%d", cmfingers - _P.pmosdiodefingers - _P.pmoszerofingers)).tr
    )
    -- connect dummy pmos separation gate to drain
    geometry.rectanglebltr(cmarray, generics.metal(1),
        point.combine_12(
            cmarray:get_area_anchor(string.format("pSD%d", cmfingers - _P.pmosdiodefingers - _P.pmoszerofingers - _P.pmosseparationfingers // 2)).bl,
            cmarray:get_area_anchor(string.format("Gupper%d", cmfingers - _P.pmosdiodefingers - _P.pmoszerofingers - _P.pmosseparationfingers // 2)).tr
        ),
        cmarray:get_area_anchor(string.format("pSD%d", cmfingers - _P.pmosdiodefingers - _P.pmoszerofingers - _P.pmosseparationfingers // 2)).br
    )
    -- connect left pmos/nmos
    local index = cmfingers - _P.pmosdiodefingers - _P.pmoszerofingers - _P.pmosseparationfingers + 1
    geometry.viabltr(cmarray, 1, 2,
        cmarray:get_area_anchor(string.format("pSD%d", index)).bl,
        cmarray:get_area_anchor(string.format("pSD%d", index)).tr
    )
    geometry.rectanglebltr(cmarray, generics.metal(2),
        point.combine_12(
            cmarray:get_area_anchor(string.format("pSD%d", cmfingers - _P.pmosdiodefingers - _P.pmoszerofingers - _P.pmosseparationfingers + 1)).bl,
            cmarray:get_area_anchor(string.format("Glower%d", cmfingers - _P.nmoscurrentfingers)).bl
        ),
        cmarray:get_area_anchor(string.format("pSD%d", index)).br
    )
    local index = cmfingers - _P.pmosdiodefingers - _P.pmoszerofingers + 1
    geometry.viabltr(cmarray, 1, 2,
        cmarray:get_area_anchor(string.format("pSD%d", index)).bl,
        cmarray:get_area_anchor(string.format("pSD%d", index)).tr
    )
    geometry.rectanglebltr(cmarray, generics.metal(2),
        point.combine_12(
            cmarray:get_area_anchor(string.format("pSD%d", cmfingers - _P.pmosdiodefingers - _P.pmoszerofingers + 1)).bl,
            cmarray:get_area_anchor(string.format("Glower%d", cmfingers - _P.nmoscurrentfingers)).bl
        ),
        cmarray:get_area_anchor(string.format("pSD%d", cmfingers - _P.pmosdiodefingers - _P.pmoszerofingers + 1)).br
    )
    geometry.viabltr(cmarray, 1, 2,
        cmarray:get_area_anchor(string.format("nSD%d", cmfingers - _P.nmoscurrentfingers)).bl,
        cmarray:get_area_anchor(string.format("nSD%d", cmfingers - _P.nmoscurrentfingers)).tr
    )
    -- connect right pmos/nmos
    geometry.rectanglebltr(cmarray, generics.metal(2),
        cmarray:get_area_anchor(string.format("nSD%d", cmfingers)).bl,
        cmarray:get_area_anchor(string.format("pSD%d", cmfingers)).tr
    )
    if _P.nmoscurrentfingers > 2 then
        geometry.rectanglebltr(cmarray, generics.metal(2),
            cmarray:get_area_anchor(string.format("nSD%d", cmfingers - _P.nmoscurrentfingers + 2)).br,
            cmarray:get_area_anchor(string.format("nSD%d", cmfingers)).bl:translate_y(_P.gstwidth)
        )
    end
    for i = 2, _P.pmosdiodefingers, 2 do
        geometry.viabltr(cmarray, 1, 2,
            cmarray:get_area_anchor(string.format("pSD%d", cmfingers + 2 - i)).bl,
            cmarray:get_area_anchor(string.format("pSD%d", cmfingers + 2 - i)).tr
        )
    end
    for i = 2, _P.nmoscurrentfingers, 2 do
        geometry.viabltr(cmarray, 1, 2,
            cmarray:get_area_anchor(string.format("nSD%d", cmfingers + 2 - i)).bl,
            cmarray:get_area_anchor(string.format("nSD%d", cmfingers + 2 - i)).tr
        )
    end
    local currentmirror = oscillator:add_child(cmarray, "vco_currentmirror")
    currentmirror:abut_left(inverters[1])

    -- create output buffer layout
    local buffergatecontacts = {}
    local bufferactivecontacts = {}
    for i = 1, _P.bufspacers do
        buffergatecontacts[i] = "dummy"
    end
    for i = 1, _P.buffingers do
        buffergatecontacts[_P.bufspacers + i] = "center"
    end
    for i = 1, _P.bufspacers + 1 do
        bufferactivecontacts[i] = "power"
    end
    for i = 1, _P.buffingers, 2 do
        bufferactivecontacts[_P.bufspacers + 1 + i] = "inner"
        bufferactivecontacts[_P.bufspacers + 1 + i + 1] = "power"
    end
    -- FIXME: add right dummies?
    local bufferarray = pcell.create_layout("basic/cmos", "buffer", {
        gatecontactpos = buffergatecontacts,
        pcontactpos = bufferactivecontacts,
        ncontactpos = bufferactivecontacts,
    })
    geometry.rectanglebltr(bufferarray,
        generics.metal(1),
        bufferarray:get_area_anchor(string.format("G%d", _P.bufspacers + 1)).bl,
        bufferarray:get_area_anchor(string.format("G%d", _P.bufspacers + _P.buffingers)).tr
    )
    geometry.polygon(bufferarray, generics.metal(1), {
        bufferarray:get_area_anchor(string.format("pSD%d", _P.bufspacers + 2)).br,
        (bufferarray:get_area_anchor(string.format("G%d", _P.bufspacers + _P.buffingers)).br .. bufferarray:get_area_anchor(string.format("pSD%d", _P.bufspacers + 2)).br):translate(xpitch, 0),
        (bufferarray:get_area_anchor(string.format("G%d", _P.bufspacers + _P.buffingers)).br .. bufferarray:get_area_anchor(string.format("nSD%d", _P.bufspacers + 2)).tr):translate(xpitch, 0),
        bufferarray:get_area_anchor(string.format("nSD%d", _P.bufspacers + 2)).tr,
        bufferarray:get_area_anchor(string.format("nSD%d", _P.bufspacers + 2)).tr:translate_y(-_P.gstwidth),
        (bufferarray:get_area_anchor(string.format("G%d", _P.bufspacers + _P.buffingers)).br .. bufferarray:get_area_anchor(string.format("nSD%d", _P.bufspacers + 2)).tr):translate(xpitch + _P.gstwidth, -_P.gstwidth),
        (bufferarray:get_area_anchor(string.format("G%d", _P.bufspacers + _P.buffingers)).br .. bufferarray:get_area_anchor(string.format("pSD%d", _P.bufspacers + 2)).br):translate(xpitch + _P.gstwidth, _P.gstwidth),
        bufferarray:get_area_anchor(string.format("pSD%d", _P.bufspacers + 2)).br:translate_y(_P.gstwidth),
    })

    local buffer = oscillator:add_child(bufferarray, "vco_outputbuffer")
    buffer:abut_right(inverters[_P.numinv])

    -- draw inverter connections
    for i = 1, _P.numinv - 1 do
        -- connect drains to gate of next inverter
        geometry.rectanglebltr(oscillator, generics.metal(1),
            inverters[i]:get_area_anchor(string.format("G%d", 2 * _P.invfingers - 1)).br:translate_x(xpitch + _P.gstwidth),
            inverters[i]:get_area_anchor(string.format("G%d", 2 * _P.invfingers - 1)).tl:translate_x(3 * xpitch)
        )
    end

    geometry.polygon(oscillator, generics.metal(2), {
        currentmirror:get_area_anchor(string.format("pSD%d", cmfingers)).tr,
        currentmirror:get_area_anchor(string.format("pSD%d", cmfingers)).tr .. inverters[1]:get_area_anchor("Gp1").bl,
        inverters[1]:get_area_anchor("Gp1").bl,
        inverters[1]:get_area_anchor("Gp1").tl,
        currentmirror:get_area_anchor(string.format("pSD%d", cmfingers)).tl .. inverters[1]:get_area_anchor("Gp1").tl,
        currentmirror:get_area_anchor(string.format("pSD%d", cmfingers)).tl,
    })
    -- place vias on outer bias gates (also connects gates)
    geometry.viabltr(
        oscillator, 1, 2,
        inverters[1]:get_area_anchor("Gp1").bl,
        inverters[_P.numinv]:get_area_anchor(string.format("Gp%d", 2 * _P.invfingers)).tr
    )

    -- connect vbiasn to core
    -- FIXME: split in two parts: one part in the current mirror and the last part in toplevel
    geometry.polygon(oscillator, generics.metal(2), {
        point.combine_12(
            currentmirror:get_area_anchor(string.format("pSD%d", cmfingers - _P.pmosdiodefingers - _P.pmoszerofingers - _P.pmosseparationfingers + 1)).br,
            currentmirror:get_area_anchor(string.format("Glower%d", cmfingers - _P.nmoscurrentfingers)).bl
        ),
        point.combine_12(
            currentmirror:get_area_anchor(string.format("nSD%d", cmfingers - _P.nmoscurrentfingers)).tl,
            currentmirror:get_area_anchor(string.format("Glower%d", cmfingers - _P.nmoscurrentfingers)).bl
        ),
        point.combine_12(
            currentmirror:get_area_anchor(string.format("nSD%d", cmfingers - _P.nmoscurrentfingers)).tl,
            inverters[1]:get_area_anchor("Gn1").bl
        ),
        inverters[1]:get_area_anchor("Gn1").bl,
        inverters[1]:get_area_anchor("Gn1").tl,
        point.combine_12(
            currentmirror:get_area_anchor(string.format("nSD%d", cmfingers - _P.nmoscurrentfingers)).tr,
            inverters[1]:get_area_anchor("Gn1").tl
        ),
        point.combine_12(
            currentmirror:get_area_anchor(string.format("nSD%d", cmfingers - _P.nmoscurrentfingers)).tr,
            currentmirror:get_area_anchor(string.format("Glower%d", cmfingers - _P.nmoscurrentfingers)).tl
        ),
        point.combine_12(
            currentmirror:get_area_anchor(string.format("pSD%d", cmfingers - _P.pmosdiodefingers - _P.pmoszerofingers - _P.pmosseparationfingers + 1)).br,
            currentmirror:get_area_anchor(string.format("Glower%d", cmfingers - _P.nmoscurrentfingers)).bl
        ):translate_y(_P.gstwidth),
    })
    -- place vias on outer bias gates (also connects gates)
    geometry.viabltr(
        oscillator, 1, 2,
        inverters[1]:get_area_anchor("Gn1").bl,
        inverters[_P.numinv]:get_area_anchor(string.format("Gn%d", 2 * _P.invfingers)).tr
    )

    -- feedback connection + vias
    geometry.rectanglebltr(oscillator, generics.metal(2),
        inverters[1]:get_area_anchor("G2").bl,
        buffer:get_area_anchor(string.format("G%d", _P.bufspacers + 1)).tr
    )
    geometry.viabltr(oscillator, 1, 2,
        inverters[_P.numinv]:get_area_anchor(string.format("G%d", 2 * _P.invfingers - 1)).bl:translate(xpitch + _P.glength + _P.gstwidth / 2, 0),
        buffer:get_area_anchor(string.format("G%d", _P.bufspacers + 1)).tr
    )
    -- FIXME: make bigger (ideally parameterized)
    geometry.viabltr(
        oscillator, 1, 2,
        inverters[1]:get_area_anchor("G2").bl,
        inverters[1]:get_area_anchor("G3").tr
    )

    -- connect core to buffer
    geometry.rectanglebltr(oscillator, generics.metal(1),
        inverters[_P.numinv]:get_area_anchor(string.format("G%d", 2 * _P.invfingers - 1)).bl:translate(xpitch + _P.glength + _P.gstwidth / 2, 0),
        buffer:get_area_anchor(string.format("G%d", _P.bufspacers + 1)).tr
    )

    -- ports
    oscillator:add_port("vtune", generics.metalport(1), currentmirror:get_area_anchor("Gupper1").bl)
    oscillator:add_port("vout", generics.metalport(1), buffer:get_area_anchor(string.format("G%d", _P.bufspacers + _P.buffingers)).bl:translate(3 * xpitch / 2, 0))
    oscillator:add_port("vdd", generics.metalport(1), currentmirror:get_area_anchor("PRp").bl)
    oscillator:add_port("vss", generics.metalport(1), currentmirror:get_area_anchor("PRn").bl)

    -- position oscillator
    oscillator:translate_x(point.xdistance(point.create(0, 0), currentmirror:get_area_anchor("PRn").bl))
    oscillator:translate_x(_P.guardringspace)
    oscillator:translate_y(point.ydistance(point.create(0, 0), currentmirror:get_area_anchor("PRn").bl))
    oscillator:translate_y(_P.gstwidth + _P.powerspace + _P.guardringspace)

    -- place guardring
    local guardringfingeroffset = 4
    local prwidth = (cmfingers + _P.numinv * 2 * _P.invfingers + _P.buffingers + _P.bufspacers + guardringfingeroffset) * xpitch + _P.gstwidth
    if _P.drawguardrings then
        local pguardringref = pcell.create_layout("auxiliary/guardring", "pguardring", {
            contype = "p",
            fillwell = true,
            ringwidth = _P.guardringwidth,
            holewidth = prwidth + 2 * _P.guardringspace,
            holeheight = separation + _P.pfingerwidth + _P.nfingerwidth + 2 * (_P.powerspace + _P.powerwidth + _P.gstwidth + _P.powerspace + _P.guardringspace)
        })
        local nguardringref = pcell.create_layout("auxiliary/guardring", "nguardring", {
            contype = "n",
            fillwell = false,
            drawdeepwell = true,
            ringwidth = _P.guardringwidth,
            holewidth = prwidth + 4 * _P.guardringspace + 2 * _P.guardringwidth,
            holeheight = separation + _P.pfingerwidth + _P.nfingerwidth + 2 * (_P.powerspace + _P.powerwidth + _P.gstwidth + _P.powerspace + _P.guardringspace + 2 * _P.guardringwidth)
        })
        local nguardring = oscillator:add_child(nguardringref, "nguardring")
        nguardring:translate_x(-guardringfingeroffset * xpitch / 2)
        local pguardring = oscillator:add_child(pguardringref, "pguardring")
        pguardring:align_left(nguardring)
        pguardring:align_bottom(nguardring)
        nguardring:translate(-_P.guardringwidth - _P.guardringspace, -_P.guardringwidth - _P.guardringspace)
    end
end

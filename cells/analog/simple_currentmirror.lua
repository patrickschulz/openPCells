--[[
  VDD --------------------------------------------------
                                                       |
                                                       |
                                                       |    'outputdiodefingers'
                     input                             |---| 
                       o                                   |o--*-o vbiasp
                       |                               |---|   |
                       v                               |       |
                       |                               *--------
                       *--------    vbiasn             |
                       |       |       o               |
                       |---|   |       |           |---|
   'inputdiodefingers'     |---*-------*-----------|     'currentfingers'
                       |---|                       |---|
                       |                               |
  VSS -----------------*--------------------------------
--]]
function parameters()
    pcell.add_parameters(
        { "inputpolarity", "n", posvals = set("n", "p") },
        { "outputdiodefingers",    4, posvals = even() },
        { "currentfingers",  4, posvals = even() },
        { "inputdiodefingers",    8, posvals = even() },
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

function layout(cell, _P)
    local xpitch = _P.glength + _P.gspace

    -- current mirror settings
    local gatecontacts = {}
    local fingers = math.max(_P.outputdiodefingers, _P.currentfingers + _P.inputdiodefingers)
    for i = 1, fingers do
        gatecontacts[i] = "split"
    end
    local pactivecontacts = {}
    local nactivecontacts = {}
    -- pmos active contacts
    for i = 2, _P.outputdiodefingers, 2 do
        pactivecontacts[fingers + 2 - i] = "inner"
        pactivecontacts[fingers + 1 - i] = "power"
    end
    pactivecontacts[fingers + 1] = "power"
    -- nmos active contacts
    for i = 2, _P.inputdiodefingers + _P.currentfingers, 2 do
        nactivecontacts[fingers + 2 - i] = "inner"
        nactivecontacts[fingers + 1 - i] = "power"
    end
    nactivecontacts[fingers + 1] = "power"
    -- fill dummy contacts
    for i = 1, fingers - _P.outputdiodefingers do
        pactivecontacts[i] = "power"
    end
    for i = 1, fingers - _P.inputdiodefingers - _P.currentfingers do
        nactivecontacts[i] = "power"
    end
    -- create current mirror layout
    local array = pcell.create_layout("basic/cmos", "mosfets", { 
        gatelength = _P.glength,
        gatespace = _P.gspace,
        separation = _P.separation,
        pwidth = _P.pfingerwidth,
        nwidth = _P.nfingerwidth,
        powerwidth = _P.powerwidth,
        powerspace = _P.powerspace,
        gatecontactpos = gatecontacts, 
        pcontactpos = _P.inputpolarity == "n" and pactivecontacts or nactivecontacts,
        ncontactpos = _P.inputpolarity == "n" and nactivecontacts or pactivecontacts,
        psdheight = _P.pfingerwidth - 120,
        nsdheight = _P.nfingerwidth - 120,
    })
    cell:merge_into(array)

    -- ** draw gate straps **
    -- output diode
    local goutsel = _P.inputpolarity == "n" and "uc" or "lc"
    local ginsel = _P.inputpolarity == "n" and "lc" or "uc"
    local sdoutsel = _P.inputpolarity == "n" and "p" or "n"
    local sdinsel = _P.inputpolarity == "n" and "n" or "p"
    geometry.rectanglebltr(cell, generics.metal(1), 
        array:get_anchor(string.format("G%s%d", goutsel, fingers - _P.outputdiodefingers + 1)):translate(0, -_P.gstwidth / 2),
        array:get_anchor(string.format("G%s%d", goutsel, fingers)):translate(0, _P.gstwidth / 2)
    )
    -- mirror transistor
    geometry.rectanglebltr(cell, generics.metal(1), 
        array:get_anchor(string.format("G%s%d", ginsel, fingers - _P.currentfingers - _P.inputdiodefingers + 1)):translate(0, -_P.gstwidth / 2),
        array:get_anchor(string.format("G%s%d", ginsel, fingers)):translate(0,  _P.gstwidth / 2)
    )
    -- output dummies
    if _P.outputdiodefingers < _P.currentfingers + _P.inputdiodefingers then
        geometry.rectanglebltr(cell, generics.metal(1), 
            array:get_anchor(string.format("G%s%d", goutsel, 1)):translate(0, -_P.gstwidth / 2),
            array:get_anchor(string.format("G%s%d", goutsel, fingers - _P.outputdiodefingers)):translate(0, _P.gstwidth / 2)
        )
    end
    -- input dummies
    if _P.outputdiodefingers > _P.currentfingers + _P.inputdiodefingers then
        geometry.rectanglebltr(cell, generics.metal(1), 
            array:get_anchor(string.format("G%s%d", ginsel, 1)):translate(0, -_P.gstwidth / 2),
            array:get_anchor(string.format("G%s%d", ginsel, fingers - _P.inputdiodefingers - _P.currentfingers)):translate(0, _P.gstwidth / 2)
        )
    end

    -- draw bias source/drain connections
    for i = 2, _P.outputdiodefingers, 2 do
        local index = fingers + 2 - i
        geometry.rectanglebltr(cell, generics.metal(1), 
            array:get_anchor(string.format("%sSDi%d", sdoutsel, index)):translate(-_P.gstwidth / 2, 0),
            point.combine_12(
                array:get_anchor(string.format("%sSDi%d", sdoutsel, index)),
                array:get_anchor(string.format("G%s%d", goutsel, index))
            ):translate(_P.gstwidth / 2, 0)
        )
    end
    for i = 2, _P.inputdiodefingers, 2 do
        local index = fingers - _P.currentfingers + 2 - i
        geometry.rectanglebltr(cell, generics.metal(1), 
            array:get_anchor(string.format("%sSDi%d", sdinsel, index)):translate(-_P.gstwidth / 2, 0),
            point.combine_12(
                array:get_anchor(string.format("%sSDi%d", sdinsel, index)),
                array:get_anchor(string.format("G%s%d", ginsel, index))
            ):translate(_P.gstwidth / 2, 0)
        )
    end
    for i = 2, fingers - _P.outputdiodefingers do
        geometry.rectanglebltr(cell, generics.metal(1), 
            array:get_anchor(string.format("%sSDi%d", sdoutsel, i)):translate(-_P.gstwidth / 2, 0),
            point.combine_12(
                array:get_anchor(string.format("%sSDi%d", sdoutsel, i)),
                array:get_anchor(string.format("G%s%d", goutsel, i))
            ):translate(_P.gstwidth / 2, 0)
        )
    end
    for i = 2, fingers - _P.inputdiodefingers - _P.currentfingers do
        geometry.rectanglebltr(cell, generics.metal(1), 
            array:get_anchor(string.format("%sSDi%d", sdinsel, i)):translate(-_P.gstwidth / 2, 0),
            point.combine_12(
                array:get_anchor(string.format("%sSDi%d", sdinsel, i)),
                array:get_anchor(string.format("G%s%d", ginsel, i))
            ):translate(_P.gstwidth / 2, 0)
        )
    end
    -- connect right pmos/nmos
    geometry.rectanglebltr(cell, generics.metal(2), 
        array:get_anchor(string.format("nSDo%d", fingers)):translate(-_P.gstwidth / 2, 0),
        array:get_anchor(string.format("pSDo%d", fingers)):translate( _P.gstwidth / 2, 0)
    )
    for i = 2, _P.outputdiodefingers, 2 do
        geometry.viabltr(cell, 1, 2, 
            array:get_anchor(string.format("pSDi%d", fingers + 2 - i)):translate(-_P.gstwidth / 2, 0),
            array:get_anchor(string.format("pSDo%d", fingers + 2 - i)):translate( _P.gstwidth / 2, 0)
        )
    end
    for i = 2, _P.currentfingers, 2 do
        geometry.viabltr(cell, 1, 2, 
            array:get_anchor(string.format("nSDo%d", fingers + 2 - i)):translate(-_P.gstwidth / 2, 0),
            array:get_anchor(string.format("nSDi%d", fingers + 2 - i)):translate( _P.gstwidth / 2, 0)
        )
    end
    if _P.outputdiodefingers > 2 then
        geometry.path(cell, generics.metal(2), {
            array:get_anchor(string.format("%sSDc%d", sdoutsel, fingers - _P.outputdiodefingers + 2)),
            array:get_anchor(string.format("%sSDc%d", sdoutsel, fingers)),
        }, _P.gstwidth)
    end
    if _P.currentfingers > 2 then
        geometry.path(cell, generics.metal(2), {
            array:get_anchor(string.format("%sSDc%d", sdinsel, fingers - _P.currentfingers + 2)),
            array:get_anchor(string.format("%sSDc%d", sdinsel, fingers)),
        }, _P.gstwidth)
    end
end

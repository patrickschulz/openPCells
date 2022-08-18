function parameters()
    pcell.add_parameters(
        { "fingers", 2 },
        { "pwidth", 2 * tech.get_dimension("Minimum Gate Width") },
        { "nwidth", 2 * tech.get_dimension("Minimum Gate Width") },
        { "gstwidth", tech.get_dimension("Minimum M1 Width") },
        { "gstspace", tech.get_dimension("Minimum M1 Space") },
        { "sdwidth", tech.get_dimension("Minimum M1 Width") }
    )
end

function layout(tgate, _P)
    local cmos = pcell.create_layout("basic/cmos", {
        separation = 3 * _P.gstwidth + 5 * _P.gstspace,
        pwidth = _P.pwidth,
        nwidth = _P.nwidth,
        gatecontactpos = util.fill_all_with(_P.fingers, "split"),
        ncontactpos = util.fill_odd_with(_P.fingers + 1, "inner", "power"),
        pcontactpos = util.fill_odd_with(_P.fingers + 1, "inner", "power"),
        gstwidth = _P.gstwidth,
        gstspace = _P.gstspace,
        gatecontactsplitshift = _P.gstwidth + _P.gstspace,
        separation = 3 * _P.gstspace + 2 * _P.gstwidth,
        powerwidth = _P.sdwidth,
        npowerspace = _P.gstspace,
        ppowerspace = _P.gstspace,
    })
    tgate:merge_into_shallow(cmos)
    geometry.rectanglebltr(tgate, generics.metal(1),
        cmos:get_anchor(string.format("Glower%dll", 1)),
        cmos:get_anchor(string.format("Glower%dur", _P.fingers))
    )
    geometry.rectanglebltr(tgate, generics.metal(1),
        cmos:get_anchor(string.format("Gupper%dll", 1)),
        cmos:get_anchor(string.format("Gupper%dur", _P.fingers))
    )
    geometry.path(tgate, generics.metal(1), {
        cmos:get_anchor(string.format("nSDi%d", 1)):translate(0, -_P.sdwidth / 2),
        cmos:get_anchor(string.format("nSDi%d", _P.fingers + 1)):translate(0, -_P.sdwidth / 2)
    }, _P.sdwidth)
    geometry.path(tgate, generics.metal(1), {
        cmos:get_anchor(string.format("pSDi%d", 1)):translate(0, _P.sdwidth / 2),
        cmos:get_anchor(string.format("pSDi%d", _P.fingers + 1)):translate(0, _P.sdwidth / 2)
    }, _P.sdwidth)
    geometry.cshape(tgate, generics.metal(1),
        cmos:get_anchor("PRpcl"),
        cmos:get_anchor("PRncl"),
        -200,
        _P.sdwidth
    )
    geometry.cshape(tgate, generics.metal(1),
        cmos:get_anchor(string.format("pSDi%d", _P.fingers + 1)):translate(0,  _P.sdwidth / 2),
        cmos:get_anchor(string.format("nSDi%d", _P.fingers + 1)):translate(0, -_P.sdwidth / 2),
        200,
        _P.sdwidth
    )

    tgate:add_anchor_area_bltr("clkp", cmos:get_anchor("Glower1ll"), cmos:get_anchor(string.format("Glower%dur", _P.fingers)))
    tgate:add_anchor_area_bltr("clkn", cmos:get_anchor("Gupper1ll"), cmos:get_anchor(string.format("Gupper%dur", _P.fingers)))
    tgate:add_port("input", generics.metalport(1), (cmos:get_anchor("PRpcl") + cmos:get_anchor("PRncl")):translate(-200, 0))
    tgate:add_port("output", generics.metalport(1), (cmos:get_anchor(string.format("pSDi%d", _P.fingers + 1)) + cmos:get_anchor(string.format("nSDi%d", _P.fingers + 1))):translate(200, 0))
end

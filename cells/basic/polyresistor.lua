function parameters()
    pcell.add_parameters(
        { "width", 40 },
        { "length", 500 },
        { "xspace", 120 },
        { "yspace", 400 },
        { "extension", 400 },
        { "contactheight", 200 },
        { "nxfingers", 1 },
        { "nyfingers", 1 },
        { "dummies", 0 },
        { "nonresdummies", 0 },
        { "extraextension", 200 },
        { "markextension", 200 },
        { "drawwell", false },
        { "conntype", "parallel", posvals = set("parallel", "series") }
    )
end

function layout(res, _P)
    local polyheight = _P.nyfingers * _P.length + (_P.nyfingers - 1) * _P.yspace + 2 * _P.extension
    -- poly strips
    res:merge_into_shallow(geometry.multiple_x(geometry.rectangle(generics.other("gate"), _P.width, polyheight), 
        _P.nxfingers + 2 * _P.dummies + 2 * _P.nonresdummies, _P.width + _P.xspace))
    -- contacts
    res:merge_into_shallow(geometry.multiple_xy(geometry.rectangle(generics.contact("gate", nil, true), 
        _P.width, _P.contactheight), _P.nxfingers, _P.nyfingers + 1, _P.width + _P.xspace, _P.length + _P.yspace))
    -- poly marker layer
    res:merge_into_shallow(geometry.multiple_y(geometry.rectangle(generics.other("polyres"), 
        (_P.nxfingers + 2 * _P.dummies) * (_P.width + _P.xspace) - _P.xspace + 2 * _P.markextension, _P.length), _P.nyfingers, _P.length + _P.yspace))
    -- implant and LVS marker layer
    res:merge_into_shallow(geometry.rectangle(generics.other("nres"), 
        (_P.nxfingers + 2 * _P.dummies + 2 * _P.nonresdummies) * (_P.width + _P.xspace) + 2 * _P.extraextension, polyheight + 2 * _P.extraextension))
    -- well
    if _P.drawwell then
        res:merge_into_shallow(geometry.rectangle(generics.other("nwell"), 
            (_P.nxfingers + 2 * _P.dummies + 2 * _P.nonresdummies) * (_P.width + _P.xspace) + 2 * _P.extraextension, polyheight + 2 * _P.extraextension))
    end

    -- connections
    local xpitch = _P.width + _P.xspace
    if _P.conntype == "parallel" then
        res:merge_into_shallow(geometry.multiple_y(geometry.rectanglebltr(generics.metal(1), 
            point.create(-(_P.nxfingers - 1) * xpitch / 2 - _P.width / 2, -_P.contactheight / 2),
            point.create( (_P.nxfingers - 1) * xpitch / 2 + _P.width / 2,  _P.contactheight / 2)
        ), 2, _P.length + _P.extension))
    else
        for i = 1, _P.nxfingers - 1 do
            if i % 2 == 1 then
                res:merge_into_shallow(geometry.rectangle(generics.metal(1), _P.xspace, _P.contactheight)
                :translate(-(_P.nxfingers - 2 * i) * (_P.width + _P.xspace) / 2, _P.nyfingers * (_P.length + _P.yspace) / 2))
            else
                res:merge_into_shallow(geometry.rectangle(generics.metal(1), _P.xspace, _P.contactheight)
                :translate(-(_P.nxfingers - 2 * i) * (_P.width + _P.xspace) / 2, -_P.nyfingers * (_P.length + _P.yspace) / 2))
            end
        end
    end

    -- alignment box
    res:set_alignment_box(
        point.create(-(_P.nxfingers - 1) * xpitch / 2 - xpitch / 2, -polyheight / 2 + _P.extension / 2),
        point.create( (_P.nxfingers - 1) * xpitch / 2 + xpitch / 2,  polyheight / 2 - _P.extension / 2)
    )

    -- ports and anchors
    res:add_anchor("plus", res:get_anchor("top"))
    res:add_anchor("minus", res:get_anchor("bottom"))
    res:add_anchor("topcontactleft", res:get_anchor("topleft"):translate(_P.xspace / 2, 0))
    res:add_anchor("topcontactright", res:get_anchor("topright"):translate(-_P.xspace / 2, 0))
    res:add_anchor("bottomcontactleft", res:get_anchor("bottomleft"):translate(_P.xspace / 2, 0))
    res:add_anchor("bottomcontactright", res:get_anchor("bottomright"):translate(-_P.xspace / 2, 0))
end

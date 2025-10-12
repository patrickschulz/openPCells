function parameters()
    pcell.add_parameters(
        { "width", technology.get_dimension("Minimum Gate Length") },
        { "length", technology.get_dimension("Minimum Gate Width") },
        { "xspace", technology.get_dimension("Minimum Gate Space", "Minimum Gate XSpace") },
        { "yspace", technology.get_dimension("Minimum Gate Space", "Minimum Gate XSpace") },
        { "extension", technology.get_dimension("Minimum Gate Extension") },
        { "contactheight", technology.get_dimension("Minimum Gate Contact Region Size") },
        { "nxfingers", 1 },
        { "nyfingers", 1 },
        { "leftdummies", 0 },
        { "rightdummies", 0 },
        { "drawdummycontacts", true },
        { "nonresdummies", 0 },
        { "extraextension", 200 },
        { "markercoverall", true },
        { "markextension", 200 },
        { "drawwell", false },
        { "welltype", "n", posvals = set("n", "p") },
        { "extendimplantx", 0 },
        { "extendimplanty", 0 },
        { "extendwellx", 0 },
        { "extendwelly", 0 },
        { "extendlvsmarkerx", 0 },
        { "extendlvsmarkery", 0 },
        { "conntype", "parallel", posvals = set("none", "parallel", "series") },
        { "invertseriesconnections", false },
        { "drawrotationmarker", false },
        { "resistortype", 1 },
        { "plusmetal", 1 },
        { "minusmetal", 1 }
    )
end

function layout(resistor, _P)
    local polyheight = _P.nyfingers * _P.length + (_P.nyfingers + 1) * _P.extension + (_P.nyfingers + 1) * _P.contactheight + 2 * _P.extraextension
    if _P.nyfingers > 1 then
        polyheight = polyheight + _P.extension + _P.contactheight
    end
    -- poly strips
    for x = 1, _P.nxfingers + _P.leftdummies + _P.rightdummies + 2 * _P.nonresdummies do
        if _P.yspace > 0 then
            for y = 1, _P.nyfingers do
                local yshift = (y - 1) * (_P.length + 2 * _P.extension + 2 * _P.contactheight + _P.yspace)
                geometry.rectanglebltr(
                    resistor, generics.gate(),
                    point.create((x - 1) * (_P.width + _P.xspace), yshift),
                    point.create((x - 1) * (_P.width + _P.xspace) + _P.width, yshift + _P.length + 2 * _P.extension + 2 * _P.contactheight)
                )
            end
        else
            geometry.rectanglebltr(
                resistor, generics.gate(),
                point.create((x - 1) * (_P.width + _P.xspace), 0),
                point.create((x - 1) * (_P.width + _P.xspace) + _P.width, polyheight)
            )
        end
    end

    -- contacts
    for x = 1, _P.nxfingers do
        if _P.yspace > 0 then
            for y = 1, _P.nyfingers do
                local yshift = (y - 1) * (_P.length + _P.contactheight + 2 * _P.extension + 2 * _P.yspace)
                geometry.contactbltr(resistor, "gate",
                    point.create((x + _P.leftdummies + _P.nonresdummies - 1) * (_P.width + _P.xspace), _P.extraextension + yshift),
                    point.create((x + _P.leftdummies + _P.nonresdummies - 1) * (_P.width + _P.xspace) + _P.width, _P.extraextension + yshift + _P.contactheight)
                )
                geometry.contactbltr(resistor, "gate",
                    point.create((x + _P.leftdummies + _P.nonresdummies - 1) * (_P.width + _P.xspace), _P.extraextension + yshift + _P.length + _P.contactheight + 2 * _P.extension),
                    point.create((x + _P.leftdummies + _P.nonresdummies - 1) * (_P.width + _P.xspace) + _P.width, _P.extraextension + yshift + _P.length + _P.contactheight + 2 * _P.extension + _P.contactheight)
                )
                resistor:add_area_anchor_bltr(string.format("contact_lower_%d_%d", x, y),
                    point.create((x + _P.leftdummies + _P.nonresdummies - 1) * (_P.width + _P.xspace), _P.extraextension + yshift),
                    point.create((x + _P.leftdummies + _P.nonresdummies - 1) * (_P.width + _P.xspace) + _P.width, _P.extraextension + yshift + _P.contactheight)
                )
                resistor:add_area_anchor_bltr(string.format("contact_lower_-%d_-%d", _P.nxfingers - x + 1, y),
                    point.create((x + _P.leftdummies + _P.nonresdummies - 1) * (_P.width + _P.xspace), _P.extraextension + yshift),
                    point.create((x + _P.leftdummies + _P.nonresdummies - 1) * (_P.width + _P.xspace) + _P.width, _P.extraextension + yshift + _P.contactheight)
                )
                resistor:add_area_anchor_bltr(string.format("contact_upper_%d_%d", x, y),
                    point.create((x + _P.leftdummies + _P.nonresdummies - 1) * (_P.width + _P.xspace), _P.extraextension + yshift + _P.length + _P.contactheight + 2 * _P.extension),
                    point.create((x + _P.leftdummies + _P.nonresdummies - 1) * (_P.width + _P.xspace) + _P.width, _P.extraextension + yshift + _P.length + _P.contactheight + 2 * _P.extension + _P.contactheight)
                )
                resistor:add_area_anchor_bltr(string.format("contact_upper_-%d_-%d", _P.nxfingers - x + 1, y),
                    point.create((x + _P.leftdummies + _P.nonresdummies - 1) * (_P.width + _P.xspace), _P.extraextension + yshift + _P.length + _P.contactheight + 2 * _P.extension),
                    point.create((x + _P.leftdummies + _P.nonresdummies - 1) * (_P.width + _P.xspace) + _P.width, _P.extraextension + yshift + _P.length + _P.contactheight + 2 * _P.extension + _P.contactheight)
                )
            end
        else
            for y = 1, _P.nyfingers + 1 do
                local yshift = (y - 1) * (_P.length + _P.contactheight + 2 * _P.extension)
                geometry.contactbltr(resistor, "gate",
                    point.create((x + _P.leftdummies + _P.nonresdummies - 1) * (_P.width + _P.xspace), _P.extraextension + yshift),
                    point.create((x + _P.leftdummies + _P.nonresdummies - 1) * (_P.width + _P.xspace) + _P.width, _P.extraextension + yshift + _P.contactheight),
                    string.format(
                        "resistor contact:\n    x parameters: width (%d)\n    y parameters: contactheight (%d)",
                        _P.width, _P.contactheight
                    )
                )
                resistor:add_area_anchor_bltr(string.format("contact_%d_%d", x, y),
                    point.create((x + _P.leftdummies + _P.nonresdummies - 1) * (_P.width + _P.xspace), _P.extraextension + yshift),
                    point.create((x + _P.leftdummies + _P.nonresdummies - 1) * (_P.width + _P.xspace) + _P.width, _P.extraextension + yshift + _P.contactheight)
                )
                resistor:add_area_anchor_bltr(string.format("contact_-%d_-%d", _P.nxfingers - x + 1, _P.nyfingers - y + 1),
                    point.create((x + _P.leftdummies + _P.nonresdummies - 1) * (_P.width + _P.xspace), _P.extraextension + yshift),
                    point.create((x + _P.leftdummies + _P.nonresdummies - 1) * (_P.width + _P.xspace) + _P.width, _P.extraextension + yshift + _P.contactheight)
                )
            end
        end
    end

    -- dummy contact
    if _P.drawdummycontacts then
        for x = 1, _P.leftdummies do
            if _P.yspace > 0 then
                for y = 1, _P.nyfingers do
                    local yshift = (y - 1) * (_P.length + _P.contactheight + 2 * _P.extension + 2 * _P.yspace)
                    geometry.contactbltr(resistor, "gate",
                        point.create((x + _P.nonresdummies - 1) * (_P.width + _P.xspace), _P.extraextension + yshift),
                        point.create((x + _P.nonresdummies - 1) * (_P.width + _P.xspace) + _P.width, _P.extraextension + yshift + _P.contactheight)
                    )
                    geometry.contactbltr(resistor, "gate",
                        point.create((x + _P.nonresdummies - 1) * (_P.width + _P.xspace), _P.extraextension + yshift + _P.length + _P.contactheight + 2 * _P.extension),
                        point.create((x + _P.nonresdummies - 1) * (_P.width + _P.xspace) + _P.width, _P.extraextension + yshift + _P.length + _P.contactheight + 2 * _P.extension + _P.contactheight)
                    )
                end
            else
                for y = 1, _P.nyfingers + 1 do
                    local yshift = (y - 1) * (_P.length + _P.contactheight + 2 * _P.extension)
                    geometry.contactbltr(resistor, "gate",
                        point.create((x + _P.nonresdummies - 1) * (_P.width + _P.xspace), _P.extraextension + yshift),
                        point.create((x + _P.nonresdummies - 1) * (_P.width + _P.xspace) + _P.width, _P.extraextension + yshift + _P.contactheight)
                    )
                    resistor:add_area_anchor_bltr(string.format("leftdummycontact_%d_%d", x, y),
                        point.create((x + _P.nonresdummies - 1) * (_P.width + _P.xspace), _P.extraextension + yshift),
                        point.create((x + _P.nonresdummies - 1) * (_P.width + _P.xspace) + _P.width, _P.extraextension + yshift + _P.contactheight)
                    )
                end
            end
        end
        for x = 1, _P.rightdummies do
            if _P.yspace > 0 then
                for y = 1, _P.nyfingers do
                    local yshift = (y - 1) * (_P.length + _P.contactheight + 2 * _P.extension + 2 * _P.yspace)
                    geometry.contactbltr(resistor, "gate",
                        point.create((x + _P.leftdummies + _P.nonresdummies + _P.nxfingers - 1) * (_P.width + _P.xspace), _P.extraextension + yshift),
                        point.create((x + _P.leftdummies + _P.nonresdummies + _P.nxfingers - 1) * (_P.width + _P.xspace) + _P.width, _P.extraextension + yshift + _P.contactheight)
                    )
                    geometry.contactbltr(resistor, "gate",
                        point.create((x + _P.leftdummies + _P.nonresdummies + _P.nxfingers - 1) * (_P.width + _P.xspace), _P.extraextension + yshift + _P.length + _P.contactheight + 2 * _P.extension),
                        point.create((x + _P.leftdummies + _P.nonresdummies + _P.nxfingers - 1) * (_P.width + _P.xspace) + _P.width, _P.extraextension + yshift + _P.length + _P.contactheight + 2 * _P.extension + _P.contactheight)
                    )
                end
            else
                for y = 1, _P.nyfingers + 1 do
                    local yshift = (y - 1) * (_P.length + _P.contactheight + 2 * _P.extension)
                    geometry.contactbltr(resistor, "gate",
                        point.create((x + _P.nonresdummies + _P.leftdummies + _P.nxfingers - 1) * (_P.width + _P.xspace), _P.extraextension + yshift),
                        point.create((x + _P.nonresdummies + _P.leftdummies + _P.nxfingers - 1) * (_P.width + _P.xspace) + _P.width, _P.extraextension + yshift + _P.contactheight)
                    )
                    resistor:add_area_anchor_bltr(string.format("rightdummycontact_%d_%d", x, y),
                        point.create((x + _P.nonresdummies + _P.leftdummies + _P.nxfingers - 1) * (_P.width + _P.xspace), _P.extraextension + yshift),
                        point.create((x + _P.nonresdummies + _P.leftdummies + _P.nxfingers - 1) * (_P.width + _P.xspace) + _P.width, _P.extraextension + yshift + _P.contactheight)
                    )
                end
            end
        end
    end

    -- poly marker layer
    if _P.markercoverall then
        for y = 1, _P.nyfingers do
            local yshift = (y - 1) * (_P.length + _P.contactheight + 2 * _P.extension + 2 * _P.yspace) + _P.contactheight + _P.extension
            geometry.rectanglebltr(resistor, generics.feol("silicideblocker"),
                point.create(_P.nonresdummies * (_P.width + _P.xspace) - _P.markextension, _P.extraextension + yshift),
                point.create((_P.nxfingers + _P.leftdummies + _P.rightdummies + _P.nonresdummies) * (_P.width + _P.xspace) - _P.xspace + _P.markextension, _P.extraextension + yshift + _P.length)
            )
        end
    else
        for x = 1, _P.nxfingers + _P.leftdummies + _P.rightdummies do
            local xshift = (x + _P.nonresdummies - 1) * (_P.width + _P.xspace)
            for y = 1, _P.nyfingers do
                geometry.rectanglebltr(resistor, generics.feol("silicideblocker"),
                    point.create(xshift - _P.markextension, _P.contactheight + _P.extension + (y - 1) * (_P.length + _P.yspace)),
                    point.create(xshift + _P.width + _P.markextension, _P.contactheight + _P.extension + (y - 1) * (_P.length + _P.yspace) + _P.length)
                )
            end
        end
    end
    -- implant
    geometry.rectanglebltr(resistor, generics.implant("n"),
        point.create((1 - 1) * (_P.width + _P.xspace) - _P.extendimplantx, -_P.extendimplanty),
        point.create((_P.nxfingers + _P.leftdummies + _P.rightdummies + 2 * _P.nonresdummies - 1) * (_P.width + _P.xspace) + _P.width + _P.extendimplantx, polyheight + _P.extendimplanty)
    )
    -- well
    if _P.drawwell then
        geometry.rectanglebltr(resistor, generics.well(_P.welltype),
            point.create((1 - 1) * (_P.width + _P.xspace) - _P.extendwellx, -_P.extendwelly),
            point.create((_P.nxfingers + _P.leftdummies + _P.rightdummies + 2 * _P.nonresdummies - 1) * (_P.width + _P.xspace) + _P.width + _P.extendwellx, polyheight + _P.extendwelly)
        )
    end
    -- LVS marker layer
    geometry.rectanglebltr(resistor, generics.marker("polyresistorlvs", _P.resistortype),
        point.create((1 + _P.nonresdummies - 1) * (_P.width + _P.xspace) - _P.extendlvsmarkerx, -_P.extendlvsmarkery),
        point.create((_P.nxfingers + _P.leftdummies + _P.rightdummies + _P.nonresdummies - 1) * (_P.width + _P.xspace) + _P.width + _P.extendlvsmarkerx, polyheight + _P.extendlvsmarkery)
    )
    -- LVS marker layer
    if _P.drawrotationmarker then
        geometry.rectanglebltr(resistor, generics.marker("rotation"),
            point.create((1 - 1) * (_P.width + _P.xspace) - _P.extendlvsmarkerx, -_P.extendlvsmarkery),
            point.create((_P.nxfingers + _P.leftdummies + _P.rightdummies + 2 * _P.nonresdummies - 1) * (_P.width + _P.xspace) + _P.width + _P.extendlvsmarkerx, polyheight + _P.extendlvsmarkery)
        )
    end

    -- connections
    local xpitch = _P.width + _P.xspace
    if _P.conntype == "parallel" then
        if _P.yspace > 0 then
            -- FIXME
        else
            for y = 1, _P.nyfingers + 1 do
                geometry.rectanglebltr(resistor, generics.metal(1),
                    resistor:get_area_anchor(string.format("contact_%d_%d", 1, y)).bl,
                    resistor:get_area_anchor(string.format("contact_%d_%d", _P.nxfingers, y)).tr
                )
            end
        end
    elseif _P.conntype == "series" then
        for x = 1, _P.nxfingers - 1 do
            local yindex
            if _P.invertseriesconnections then
                yindex = (x % 2 == 1) and 1 or 2
            else
                yindex = (x % 2 == 1) and 2 or 1
            end
            geometry.rectanglebltr(resistor, generics.metal(1),
                resistor:get_area_anchor(string.format("contact_%d_%d", x, yindex)).bl,
                resistor:get_area_anchor(string.format("contact_%d_%d", x + 1, yindex)).tr
            )
        end
    end

    -- alignment box
    resistor:set_alignment_box(
        point.create((1 + _P.leftdummies + _P.nonresdummies - 1) * (_P.width + _P.xspace) - _P.xspace / 2, -_P.yspace / 2),
        point.create((_P.nxfingers + _P.leftdummies + _P.nonresdummies - 1) * (_P.width + _P.xspace) + _P.xspace / 2 + _P.width, _P.nyfingers * (_P.length + _P.contactheight + 2 * _P.extension) + _P.contactheight + _P.yspace / 2)
    )

    -- ports and anchors
    if _P.drawdummycontacts and _P.leftdummies > 0 then
        resistor:add_area_anchor_bltr("leftdummyplus",
            resistor:get_area_anchor(string.format("leftdummycontact_%d_%d", 1, _P.nyfingers + 1)).bl,
            resistor:get_area_anchor(string.format("leftdummycontact_%d_%d", _P.leftdummies, _P.nyfingers + 1)).tr
        )
        resistor:add_area_anchor_bltr("leftdummyminus",
            resistor:get_area_anchor(string.format("leftdummycontact_%d_%d", 1, 1)).bl,
            resistor:get_area_anchor(string.format("leftdummycontact_%d_%d", _P.leftdummies, 1)).tr
        )
    end
    if _P.drawdummycontacts and _P.rightdummies > 0 then
        resistor:add_area_anchor_bltr("rightdummyplus",
            resistor:get_area_anchor(string.format("rightdummycontact_%d_%d", 1, _P.nyfingers + 1)).bl,
            resistor:get_area_anchor(string.format("rightdummycontact_%d_%d", _P.rightdummies, _P.nyfingers + 1)).tr
        )
        resistor:add_area_anchor_bltr("rightdummyminus",
            resistor:get_area_anchor(string.format("rightdummycontact_%d_%d", 1, 1)).bl,
            resistor:get_area_anchor(string.format("rightdummycontact_%d_%d", _P.rightdummies, 1)).tr
        )
    end
    if _P.conntype == "parallel" then
        resistor:add_area_anchor_bltr("plus",
            resistor:get_area_anchor(string.format("contact_%d_%d", 1, _P.nyfingers + 1)).bl,
            resistor:get_area_anchor(string.format("contact_%d_%d", _P.nxfingers, _P.nyfingers + 1)).tr
        )
        resistor:add_area_anchor_bltr("minus",
            resistor:get_area_anchor(string.format("contact_%d_%d", 1, 1)).bl,
            resistor:get_area_anchor(string.format("contact_%d_%d", _P.nxfingers, 1)).tr
        )
    else
        resistor:add_area_anchor_bltr("plus",
            resistor:get_area_anchor(string.format("contact_%d_%d", _P.nxfingers, 2)).bl,
            resistor:get_area_anchor(string.format("contact_%d_%d", _P.nxfingers, 2)).tr
        )
        resistor:add_area_anchor_bltr("minus",
            resistor:get_area_anchor(string.format("contact_%d_%d", 1, 1)).bl,
            resistor:get_area_anchor(string.format("contact_%d_%d", 1, 1)).tr
        )
    end
    if _P.plusmetal > 1 then
        geometry.viabltr(resistor, 1, _P.plusmetal,
            resistor:get_area_anchor("plus").bl,
            resistor:get_area_anchor("plus").tr
        )
    end
    if _P.minusmetal > 1 then
        geometry.viabltr(resistor, 1, _P.minusmetal,
            resistor:get_area_anchor("minus").bl,
            resistor:get_area_anchor("minus").tr
        )
    end
end

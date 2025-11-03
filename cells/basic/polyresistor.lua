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
        { "leftdummies", 2 },
        { "rightdummies", 2 },
        { "drawdummycontacts", true },
        { "nonresdummies", 0 },
        { "extraextension", 0 * 50 },
        { "silicideblocker_coverall", true },
        { "markextension", 200 },
        { "drawwell", false },
        { "welltype", "n", posvals = set("n", "p") },
        { "extendimplantx", technology.get_dimension("Minimum Implant Extension") },
        { "extendimplanty", technology.get_dimension("Minimum Implant Extension") },
        { "extendwellx", technology.get_dimension("Minimum Well Extension") },
        { "extendwelly", technology.get_dimension("Minimum Well Extension") },
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
    -- array pitch in y-direction
    local ypitch = _P.length + 2 * _P.extension + 2 * _P.contactheight + _P.yspace
    if _P.yspace == 0 then -- for merged resistors, there is one less contact
        ypitch = ypitch - _P.contactheight
    end

    -- y-size of all poly strips combined
    local totalpolyheight
    if _P.nyfingers > 1 then
        if _P.yspace > 0 then
            totalpolyheight = _P.nyfingers * ypitch - _P.yspace
        else
            totalpolyheight = _P.nyfingers * ypitch - _P.yspace + _P.contactheight + 2 * _P.extraextension
        end
    else
        totalpolyheight = _P.length + 2 * _P.contactheight + 2 * _P.extension + 2 * _P.extraextension
    end

    -- poly strips
    for x = 1, _P.nxfingers + _P.leftdummies + _P.rightdummies + 2 * _P.nonresdummies do
        if _P.yspace > 0 then
            for y = 1, _P.nyfingers do
                local yshift = (y - 1) * ypitch
                geometry.rectanglebltr(
                    resistor, generics.gate(),
                    point.create((x - 1) * (_P.width + _P.xspace), yshift),
                    point.create((x - 1) * (_P.width + _P.xspace) + _P.width, yshift + _P.length + 2 * _P.extension + 2 * _P.contactheight + 2 * _P.extraextension)
                )
            end
        else
            geometry.rectanglebltr(
                resistor, generics.gate(),
                point.create((x - 1) * (_P.width + _P.xspace), 0),
                point.create((x - 1) * (_P.width + _P.xspace) + _P.width, totalpolyheight)
            )
        end
    end

    -- contacts
    for x = 1, _P.nxfingers do
        if _P.yspace > 0 then
            for y = 1, _P.nyfingers do
                local yshift = (y - 1) * ypitch
                geometry.contactbarebltr(resistor, "gate",
                    point.create((x + _P.leftdummies + _P.nonresdummies - 1) * (_P.width + _P.xspace), _P.extraextension + yshift),
                    point.create((x + _P.leftdummies + _P.nonresdummies - 1) * (_P.width + _P.xspace) + _P.width, _P.extraextension + yshift + _P.contactheight)
                )
                geometry.contactbarebltr(resistor, "gate",
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
                local yshift = (y - 1) * ypitch
                geometry.contactbarebltr(resistor, "gate",
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
                    local yshift = (y - 1) * ypitch
                    geometry.contactbarebltr(resistor, "gate",
                        point.create((x + _P.nonresdummies - 1) * (_P.width + _P.xspace), _P.extraextension + yshift),
                        point.create((x + _P.nonresdummies - 1) * (_P.width + _P.xspace) + _P.width, _P.extraextension + yshift + _P.contactheight)
                    )
                    geometry.contactbarebltr(resistor, "gate",
                        point.create((x + _P.nonresdummies - 1) * (_P.width + _P.xspace), _P.extraextension + yshift + _P.length + _P.contactheight + 2 * _P.extension),
                        point.create((x + _P.nonresdummies - 1) * (_P.width + _P.xspace) + _P.width, _P.extraextension + yshift + _P.length + _P.contactheight + 2 * _P.extension + _P.contactheight)
                    )
                    resistor:add_area_anchor_bltr(string.format("leftdummycontact_lower_%d_%d", x, y),
                        point.create((x + _P.nonresdummies - 1) * (_P.width + _P.xspace), _P.extraextension + yshift),
                        point.create((x + _P.nonresdummies - 1) * (_P.width + _P.xspace) + _P.width, _P.extraextension + yshift + _P.contactheight)
                    )
                    resistor:add_area_anchor_bltr(string.format("leftdummycontact_upper_%d_%d", x, y),
                        point.create((x + _P.nonresdummies - 1) * (_P.width + _P.xspace), _P.extraextension + yshift + _P.length + 2 * _P.extension + _P.contactheight),
                        point.create((x + _P.nonresdummies - 1) * (_P.width + _P.xspace) + _P.width, _P.extraextension + yshift + _P.length + 2 * _P.extension + 2 * _P.contactheight)
                    )
                end
            else
                for y = 1, _P.nyfingers + 1 do
                    local yshift = (y - 1) * ypitch
                    geometry.contactbarebltr(resistor, "gate",
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
                    local yshift = (y - 1) * ypitch
                    geometry.contactbarebltr(resistor, "gate",
                        point.create((x + _P.leftdummies + _P.nonresdummies + _P.nxfingers - 1) * (_P.width + _P.xspace), _P.extraextension + yshift),
                        point.create((x + _P.leftdummies + _P.nonresdummies + _P.nxfingers - 1) * (_P.width + _P.xspace) + _P.width, _P.extraextension + yshift + _P.contactheight)
                    )
                    geometry.contactbarebltr(resistor, "gate",
                        point.create((x + _P.leftdummies + _P.nonresdummies + _P.nxfingers - 1) * (_P.width + _P.xspace), _P.extraextension + yshift + _P.length + _P.contactheight + 2 * _P.extension),
                        point.create((x + _P.leftdummies + _P.nonresdummies + _P.nxfingers - 1) * (_P.width + _P.xspace) + _P.width, _P.extraextension + yshift + _P.length + _P.contactheight + 2 * _P.extension + _P.contactheight)
                    )
                    resistor:add_area_anchor_bltr(string.format("rightdummycontact_lower_%d_%d", x, y),
                        point.create((x + _P.nonresdummies + _P.leftdummies + _P.nxfingers - 1) * (_P.width + _P.xspace), _P.extraextension + yshift),
                        point.create((x + _P.nonresdummies + _P.leftdummies + _P.nxfingers - 1) * (_P.width + _P.xspace) + _P.width, _P.extraextension + yshift + _P.contactheight)
                    )
                    resistor:add_area_anchor_bltr(string.format("rightdummycontact_upper_%d_%d", x, y),
                        point.create((x + _P.nonresdummies + _P.leftdummies + _P.nxfingers - 1) * (_P.width + _P.xspace), _P.extraextension + yshift + _P.length + 2 * _P.extension + _P.contactheight),
                        point.create((x + _P.nonresdummies + _P.leftdummies + _P.nxfingers - 1) * (_P.width + _P.xspace) + _P.width, _P.extraextension + yshift + _P.length + 2 * _P.extension + 2 * _P.contactheight)
                    )
                end
            else
                for y = 1, _P.nyfingers + 1 do
                    local yshift = (y - 1) * ypitch
                    geometry.contactbarebltr(resistor, "gate",
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

    -- silicide blocker
    if _P.silicideblocker_coverall then
        for y = 1, _P.nyfingers do
            local yshift = (y - 1) * ypitch
            local ystart = _P.extraextension + _P.contactheight + _P.extension
            geometry.rectanglebltr(resistor, generics.feol("silicideblocker"),
                point.create(_P.nonresdummies * (_P.width + _P.xspace) - _P.markextension, ystart + yshift),
                point.create((_P.nxfingers + _P.leftdummies + _P.rightdummies + _P.nonresdummies) * (_P.width + _P.xspace) - _P.xspace + _P.markextension, ystart + _P.length + yshift)
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
        point.create(
            (1 - 1) * (_P.width + _P.xspace) - _P.extendimplantx,
            -_P.extendimplanty
        ),
        point.create(
            (_P.nxfingers + _P.leftdummies + _P.rightdummies + 2 * _P.nonresdummies - 1) * (_P.width + _P.xspace) + _P.width + _P.extendimplantx,
            totalpolyheight + _P.extendimplanty
        )
    )
    -- well
    if _P.drawwell then
        geometry.rectanglebltr(resistor, generics.well(_P.welltype),
            point.create((1 - 1) * (_P.width + _P.xspace) - _P.extendwellx, -_P.extendwelly),
            point.create((_P.nxfingers + _P.leftdummies + _P.rightdummies + 2 * _P.nonresdummies - 1) * (_P.width + _P.xspace) + _P.width + _P.extendwellx, totalpolyheight + _P.extendwelly)
        )
    end
    -- LVS marker layer
    geometry.rectanglebltr(resistor, generics.marker("polyresistorlvs", _P.resistortype),
        point.create((1 + _P.nonresdummies - 1) * (_P.width + _P.xspace) - _P.extendlvsmarkerx, -_P.extendlvsmarkery),
        point.create((_P.nxfingers + _P.leftdummies + _P.rightdummies + _P.nonresdummies - 1) * (_P.width + _P.xspace) + _P.width + _P.extendlvsmarkerx, totalpolyheight + _P.extendlvsmarkery)
    )
    -- LVS marker layer
    if _P.drawrotationmarker then
        geometry.rectanglebltr(resistor, generics.marker("rotation"),
            point.create((1 - 1) * (_P.width + _P.xspace) - _P.extendlvsmarkerx, -_P.extendlvsmarkery),
            point.create((_P.nxfingers + _P.leftdummies + _P.rightdummies + 2 * _P.nonresdummies - 1) * (_P.width + _P.xspace) + _P.width + _P.extendlvsmarkerx, totalpolyheight + _P.extendlvsmarkery)
        )
    end

    -- connections
    if _P.conntype == "parallel" then
        if _P.yspace > 0 then
            for y = 1, _P.nyfingers do
                geometry.rectanglebltr(resistor, generics.metal(1),
                    resistor:get_area_anchor(string.format("contact_upper_%d_%d", 1, y)).bl,
                    resistor:get_area_anchor(string.format("contact_upper_%d_%d", _P.nxfingers, y)).tr
                )
                geometry.rectanglebltr(resistor, generics.metal(1),
                    resistor:get_area_anchor(string.format("contact_lower_%d_%d", 1, y)).bl,
                    resistor:get_area_anchor(string.format("contact_lower_%d_%d", _P.nxfingers, y)).tr
                )
            end
        else
            for y = 1, _P.nyfingers + 1 do
                geometry.rectanglebltr(resistor, generics.metal(1),
                    resistor:get_area_anchor(string.format("contact_%d_%d", 1, y)).bl,
                    resistor:get_area_anchor(string.format("contact_%d_%d", _P.nxfingers, y)).tr
                )
            end
        end
    elseif _P.conntype == "series" then
        if _P.yspace > 0 then
            for x = 1, _P.nxfingers - 1 do
                local yindex
                local contact
                if _P.invertseriesconnections then
                    yindex = (x % 2 == 1) and 1 or _P.nyfingers
                    contact = (x % 2 == 1) and "lower" or "upper"
                else
                    yindex = (x % 2 == 1) and _P.nyfingers or 1
                    contact = (x % 2 == 1) and "upper" or "lower"
                end
                -- end connections
                geometry.rectanglebltr(resistor, generics.metal(1),
                    resistor:get_area_anchor(string.format("contact_%s_%d_%d", contact, x, yindex)).bl,
                    resistor:get_area_anchor(string.format("contact_%s_%d_%d", contact, x + 1, yindex)).tr
                )
            end
            for x = 1, _P.nxfingers do
                -- in-between connections
                for y = 1, _P.nyfingers - 1 do
                    geometry.rectanglebltr(resistor, generics.metal(1),
                        resistor:get_area_anchor(string.format("contact_upper_%d_%d", x, y)).tl,
                        resistor:get_area_anchor(string.format("contact_lower_%d_%d", x, y + 1)).br
                    )
                end
            end
        else
            for x = 1, _P.nxfingers - 1 do
                local yindex
                if _P.invertseriesconnections then
                    yindex = (x % 2 == 1) and 1 or _P.nyfingers + 1
                else
                    yindex = (x % 2 == 1) and _P.nyfingers + 1 or 1
                end
                geometry.rectanglebltr(resistor, generics.metal(1),
                    resistor:get_area_anchor(string.format("contact_%d_%d", x, yindex)).bl,
                    resistor:get_area_anchor(string.format("contact_%d_%d", x + 1, yindex)).tr
                )
            end
        end
    end

    -- dummy connections
    if _P.drawdummycontacts then
        if _P.yspace > 0 then
            for y = 1, _P.nyfingers do
                if _P.leftdummies > 0 then
                    geometry.rectanglebltr(resistor, generics.metal(1),
                        resistor:get_area_anchor(string.format("leftdummycontact_lower_%d_%d", 1, y)).bl,
                        resistor:get_area_anchor(string.format("leftdummycontact_lower_%d_%d", _P.leftdummies, y)).tr
                    )
                    geometry.rectanglebltr(resistor, generics.metal(1),
                        resistor:get_area_anchor(string.format("leftdummycontact_upper_%d_%d", 1, y)).bl,
                        resistor:get_area_anchor(string.format("leftdummycontact_upper_%d_%d", _P.leftdummies, y)).tr
                    )
                end
                if _P.rightdummies > 1 then
                    geometry.rectanglebltr(resistor, generics.metal(1),
                        resistor:get_area_anchor(string.format("rightdummycontact_lower_%d_%d", 1, y)).bl,
                        resistor:get_area_anchor(string.format("rightdummycontact_lower_%d_%d", _P.rightdummies, y)).tr
                    )
                    geometry.rectanglebltr(resistor, generics.metal(1),
                        resistor:get_area_anchor(string.format("rightdummycontact_upper_%d_%d", 1, y)).bl,
                        resistor:get_area_anchor(string.format("rightdummycontact_upper_%d_%d", _P.rightdummies, y)).tr
                    )
                end
            end
        else
            for y = 1, _P.nyfingers + 1 do
                if _P.leftdummies > 1 then
                    geometry.rectanglebltr(resistor, generics.metal(1),
                        resistor:get_area_anchor(string.format("leftdummycontact_%d_%d", 1, y)).bl,
                        resistor:get_area_anchor(string.format("leftdummycontact_%d_%d", _P.leftdummies, y)).tr
                    )
                end
                if _P.rightdummies > 1 then
                    geometry.rectanglebltr(resistor, generics.metal(1),
                        resistor:get_area_anchor(string.format("rightdummycontact_%d_%d", 1, y)).bl,
                        resistor:get_area_anchor(string.format("rightdummycontact_%d_%d", _P.rightdummies, y)).tr
                    )
                end
            end
        end
    end

    -- alignment box
    resistor:set_alignment_box(
        point.create((1 + _P.leftdummies + _P.nonresdummies - 1) * (_P.width + _P.xspace) - _P.xspace / 2, -_P.yspace / 2),
        point.create((_P.nxfingers + _P.leftdummies + _P.nonresdummies - 1) * (_P.width + _P.xspace) + _P.xspace / 2 + _P.width, _P.nyfingers * (_P.length + _P.contactheight + 2 * _P.extension) + _P.contactheight + _P.yspace / 2)
    )

    -- ports and anchors
    if _P.drawdummycontacts and _P.leftdummies > 0 then
        if _P.yspace > 0 then
            resistor:add_area_anchor_bltr("leftdummyplus",
                resistor:get_area_anchor(string.format("leftdummycontact_upper_%d_%d", 1, _P.nyfingers)).bl,
                resistor:get_area_anchor(string.format("leftdummycontact_upper_%d_%d", _P.leftdummies, _P.nyfingers)).tr
            )
            resistor:add_area_anchor_bltr("leftdummyminus",
                resistor:get_area_anchor(string.format("leftdummycontact_lower_%d_%d", 1, 1)).bl,
                resistor:get_area_anchor(string.format("leftdummycontact_lower_%d_%d", _P.leftdummies, 1)).tr
            )
        else
            resistor:add_area_anchor_bltr("leftdummyplus",
                resistor:get_area_anchor(string.format("leftdummycontact_%d_%d", 1, _P.nyfingers + 1)).bl,
                resistor:get_area_anchor(string.format("leftdummycontact_%d_%d", _P.leftdummies, _P.nyfingers + 1)).tr
            )
            resistor:add_area_anchor_bltr("leftdummyminus",
                resistor:get_area_anchor(string.format("leftdummycontact_%d_%d", 1, 1)).bl,
                resistor:get_area_anchor(string.format("leftdummycontact_%d_%d", _P.leftdummies, 1)).tr
            )
        end
    end
    if _P.drawdummycontacts and _P.rightdummies > 0 then
        if _P.yspace > 0 then
            resistor:add_area_anchor_bltr("rightdummyplus",
                resistor:get_area_anchor(string.format("rightdummycontact_upper_%d_%d", 1, _P.nyfingers)).bl,
                resistor:get_area_anchor(string.format("rightdummycontact_upper_%d_%d", _P.rightdummies, _P.nyfingers)).tr
            )
            resistor:add_area_anchor_bltr("rightdummyminus",
                resistor:get_area_anchor(string.format("rightdummycontact_lower_%d_%d", 1, 1)).bl,
                resistor:get_area_anchor(string.format("rightdummycontact_lower_%d_%d", _P.rightdummies, 1)).tr
            )
        else
            resistor:add_area_anchor_bltr("rightdummyplus",
                resistor:get_area_anchor(string.format("rightdummycontact_%d_%d", 1, _P.nyfingers + 1)).bl,
                resistor:get_area_anchor(string.format("rightdummycontact_%d_%d", _P.rightdummies, _P.nyfingers + 1)).tr
            )
            resistor:add_area_anchor_bltr("rightdummyminus",
                resistor:get_area_anchor(string.format("rightdummycontact_%d_%d", 1, 1)).bl,
                resistor:get_area_anchor(string.format("rightdummycontact_%d_%d", _P.rightdummies, 1)).tr
            )
        end
    end
    if _P.conntype == "parallel" then
        if _P.yspace > 0 then
            resistor:add_area_anchor_bltr("plus",
                resistor:get_area_anchor(string.format("contact_upper_%d_%d", 1, _P.nyfingers)).bl,
                resistor:get_area_anchor(string.format("contact_upper_%d_%d", _P.nxfingers, _P.nyfingers)).tr
            )
            resistor:add_area_anchor_bltr("minus",
                resistor:get_area_anchor(string.format("contact_lower_%d_%d", 1, 1)).bl,
                resistor:get_area_anchor(string.format("contact_lower_%d_%d", _P.nxfingers, 1)).tr
            )
        else
            resistor:add_area_anchor_bltr("plus",
                resistor:get_area_anchor(string.format("contact_%d_%d", 1, _P.nyfingers + 1)).bl,
                resistor:get_area_anchor(string.format("contact_%d_%d", _P.nxfingers, _P.nyfingers + 1)).tr
            )
            resistor:add_area_anchor_bltr("minus",
                resistor:get_area_anchor(string.format("contact_%d_%d", 1, 1)).bl,
                resistor:get_area_anchor(string.format("contact_%d_%d", _P.nxfingers, 1)).tr
            )
        end
    else
        if _P.yspace > 0 then
            resistor:add_area_anchor_bltr("plus",
                resistor:get_area_anchor(string.format("contact_upper_%d_%d", _P.nxfingers, _P.nyfingers)).bl,
                resistor:get_area_anchor(string.format("contact_upper_%d_%d", _P.nxfingers, _P.nyfingers)).tr
            )
            resistor:add_area_anchor_bltr("minus",
                resistor:get_area_anchor(string.format("contact_lower_%d_%d", 1, 1)).bl,
                resistor:get_area_anchor(string.format("contact_lower_%d_%d", 1, 1)).tr
            )
        else
            resistor:add_area_anchor_bltr("plus",
                resistor:get_area_anchor(string.format("contact_%d_%d", _P.nxfingers, _P.nyfingers + 1)).bl,
                resistor:get_area_anchor(string.format("contact_%d_%d", _P.nxfingers, _P.nyfingers + 1)).tr
            )
            resistor:add_area_anchor_bltr("minus",
                resistor:get_area_anchor(string.format("contact_%d_%d", 1, 1)).bl,
                resistor:get_area_anchor(string.format("contact_%d_%d", 1, 1)).tr
            )
        end
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

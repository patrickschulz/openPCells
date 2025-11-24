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
        { "extraextension", 0 * 50 },
        { "silicideblocker_coverall", true },
        { "silicideblockerextendx", technology.get_optional_dimension("Minimum Silicideblocker Extension") },
        { "drawwell", false },
        { "welltype", "n", posvals = set("n", "p") },
        { "drawoxidetype", false },
        { "oxidetype_coverall", true },
        { "oxidetype", 1 },
        { "extendoxidetypex", 0 },
        { "extendoxidetypey", 0 },
        { "implanttype", "n", posvals = set("n", "p") },
        { "implant_coverall", true },
        { "extendimplantx", technology.get_dimension("Minimum Implant Extension") },
        { "extendimplanty", technology.get_dimension("Minimum Implant Extension") },
        { "drawresistancelevel", false },
        { "resistancelevel", 1 },
        { "resistancelevel_coverall", true },
        { "extendreslevelx", 0 },
        { "extendreslevely", 0 },
        { "extendwellx", technology.get_dimension("Minimum Well Extension") },
        { "extendwelly", technology.get_dimension("Minimum Well Extension") },
        { "extendlvsmarkerx", 0 },
        { "extendlvsmarkery", 0 },
        { "conntype", "parallel", posvals = set("none", "parallel", "series") },
        { "invertseriesconnections", false },
        { "drawrotationmarker", false },
        { "resistortype", 1 },
        { "plusmetal", 1 },
        { "minusmetal", 1 },
        { "drawguardring", false },
        { "guardring_ringwidth", technology.get_dimension("Minimum Active Width"), posvals = positive() },
        { "guardring_contype", "p", posvals = set("p", "n") },
        { "guardring_xsep", 0 },
        { "guardring_ysep", 0 },
        { "guardringwellinnerextension", technology.get_dimension("Minimum Well Extension") },
        { "guardringwellouterextension", technology.get_dimension("Minimum Well Extension") },
        { "guardringimplantinnerextension", technology.get_dimension("Minimum Implant Extension") },
        { "guardringimplantouterextension", technology.get_dimension("Minimum Implant Extension") },
        { "guardringsoiopeninnerextension", technology.get_optional_dimension("Minimum Soiopen Extension") },
        { "guardringsoiopenouterextension", technology.get_optional_dimension("Minimum Soiopen Extension") },
        { "guardringoxidetypeinnerextension", technology.get_dimension("Minimum Oxide Extension") },
        { "guardringoxidetypeouterextension", technology.get_dimension("Minimum Oxide Extension") },
        { "addlabel", false },
        { "labeltext", "" },
        { "labellayer", false }, -- nil is not possible due to internal pcell handling
        { "labelxshift", 0 },
        { "labelyshift", 0 },
        { "labelsizehint", 100 }
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

    if _P.addlabel then
        for x = 1, _P.nxfingers + _P.leftdummies + _P.rightdummies do
            for y = 1, _P.nyfingers do
                local yshift = (y - 1) * ypitch
                resistor:add_label(
                    _P.labeltext,
                    _P.labellayer,
                    point.create(
                        (x - 1) * (_P.width + _P.xspace) + _P.width / 2 + _P.labelxshift,
                        yshift + _P.extraextension + _P.contactheight + _P.extension + _P.labelyshift
                    ),
                    _P.labelsizehint
                )
            end
        end
    end

    local allanchors = {}

    local function _add_contact_anchor(resistor, name, bl, tr)
        table.insert(allanchors, name)
        resistor:add_area_anchor_bltr(name, bl, tr)
    end

    -- contacts
    for x = 1, _P.nxfingers do
        if _P.yspace > 0 then
            for y = 1, _P.nyfingers do
                local yshift = (y - 1) * ypitch
                geometry.contactbltr(resistor, "gate",
                    point.create((x + _P.leftdummies + _P.nonresdummies - 1) * (_P.width + _P.xspace), _P.extraextension + yshift),
                    point.create((x + _P.leftdummies + _P.nonresdummies - 1) * (_P.width + _P.xspace) + _P.width, _P.extraextension + yshift + _P.contactheight)
                )
                geometry.contactbltr(resistor, "gate",
                    point.create((x + _P.leftdummies + _P.nonresdummies - 1) * (_P.width + _P.xspace), _P.extraextension + yshift + _P.length + _P.contactheight + 2 * _P.extension),
                    point.create((x + _P.leftdummies + _P.nonresdummies - 1) * (_P.width + _P.xspace) + _P.width, _P.extraextension + yshift + _P.length + _P.contactheight + 2 * _P.extension + _P.contactheight)
                )
                _add_contact_anchor(resistor, string.format("contact_lower_%d_%d", x, y),
                    point.create((x + _P.leftdummies + _P.nonresdummies - 1) * (_P.width + _P.xspace), _P.extraextension + yshift),
                    point.create((x + _P.leftdummies + _P.nonresdummies - 1) * (_P.width + _P.xspace) + _P.width, _P.extraextension + yshift + _P.contactheight)
                )
                _add_contact_anchor(resistor, string.format("contact_lower_-%d_-%d", _P.nxfingers - x + 1, y),
                    point.create((x + _P.leftdummies + _P.nonresdummies - 1) * (_P.width + _P.xspace), _P.extraextension + yshift),
                    point.create((x + _P.leftdummies + _P.nonresdummies - 1) * (_P.width + _P.xspace) + _P.width, _P.extraextension + yshift + _P.contactheight)
                )
                _add_contact_anchor(resistor, string.format("contact_upper_%d_%d", x, y),
                    point.create((x + _P.leftdummies + _P.nonresdummies - 1) * (_P.width + _P.xspace), _P.extraextension + yshift + _P.length + _P.contactheight + 2 * _P.extension),
                    point.create((x + _P.leftdummies + _P.nonresdummies - 1) * (_P.width + _P.xspace) + _P.width, _P.extraextension + yshift + _P.length + _P.contactheight + 2 * _P.extension + _P.contactheight)
                )
                _add_contact_anchor(resistor, string.format("contact_upper_-%d_-%d", _P.nxfingers - x + 1, y),
                    point.create((x + _P.leftdummies + _P.nonresdummies - 1) * (_P.width + _P.xspace), _P.extraextension + yshift + _P.length + _P.contactheight + 2 * _P.extension),
                    point.create((x + _P.leftdummies + _P.nonresdummies - 1) * (_P.width + _P.xspace) + _P.width, _P.extraextension + yshift + _P.length + _P.contactheight + 2 * _P.extension + _P.contactheight)
                )
            end
        else
            for y = 1, _P.nyfingers + 1 do
                local yshift = (y - 1) * ypitch
                geometry.contactbltr(resistor, "gate",
                    point.create((x + _P.leftdummies + _P.nonresdummies - 1) * (_P.width + _P.xspace), _P.extraextension + yshift),
                    point.create((x + _P.leftdummies + _P.nonresdummies - 1) * (_P.width + _P.xspace) + _P.width, _P.extraextension + yshift + _P.contactheight),
                    string.format(
                        "resistor contact:\n    x parameters: width (%d)\n    y parameters: contactheight (%d)",
                        _P.width, _P.contactheight
                    )
                )
                _add_contact_anchor(resistor, string.format("contact_%d_%d", x, y),
                    point.create((x + _P.leftdummies + _P.nonresdummies - 1) * (_P.width + _P.xspace), _P.extraextension + yshift),
                    point.create((x + _P.leftdummies + _P.nonresdummies - 1) * (_P.width + _P.xspace) + _P.width, _P.extraextension + yshift + _P.contactheight)
                )
                _add_contact_anchor(resistor, string.format("contact_-%d_-%d", _P.nxfingers - x + 1, _P.nyfingers - y + 1),
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
                    geometry.contactbltr(resistor, "gate",
                        point.create((x + _P.nonresdummies - 1) * (_P.width + _P.xspace), _P.extraextension + yshift),
                        point.create((x + _P.nonresdummies - 1) * (_P.width + _P.xspace) + _P.width, _P.extraextension + yshift + _P.contactheight)
                    )
                    geometry.contactbltr(resistor, "gate",
                        point.create((x + _P.nonresdummies - 1) * (_P.width + _P.xspace), _P.extraextension + yshift + _P.length + _P.contactheight + 2 * _P.extension),
                        point.create((x + _P.nonresdummies - 1) * (_P.width + _P.xspace) + _P.width, _P.extraextension + yshift + _P.length + _P.contactheight + 2 * _P.extension + _P.contactheight)
                    )
                    _add_contact_anchor(resistor, string.format("leftdummycontact_lower_%d_%d", x, y),
                        point.create((x + _P.nonresdummies - 1) * (_P.width + _P.xspace), _P.extraextension + yshift),
                        point.create((x + _P.nonresdummies - 1) * (_P.width + _P.xspace) + _P.width, _P.extraextension + yshift + _P.contactheight)
                    )
                    _add_contact_anchor(resistor, string.format("leftdummycontact_upper_%d_%d", x, y),
                        point.create((x + _P.nonresdummies - 1) * (_P.width + _P.xspace), _P.extraextension + yshift + _P.length + 2 * _P.extension + _P.contactheight),
                        point.create((x + _P.nonresdummies - 1) * (_P.width + _P.xspace) + _P.width, _P.extraextension + yshift + _P.length + 2 * _P.extension + 2 * _P.contactheight)
                    )
                end
            else
                for y = 1, _P.nyfingers + 1 do
                    local yshift = (y - 1) * ypitch
                    geometry.contactbltr(resistor, "gate",
                        point.create((x + _P.nonresdummies - 1) * (_P.width + _P.xspace), _P.extraextension + yshift),
                        point.create((x + _P.nonresdummies - 1) * (_P.width + _P.xspace) + _P.width, _P.extraextension + yshift + _P.contactheight)
                    )
                    _add_contact_anchor(resistor, string.format("leftdummycontact_%d_%d", x, y),
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
                    geometry.contactbltr(resistor, "gate",
                        point.create((x + _P.leftdummies + _P.nonresdummies + _P.nxfingers - 1) * (_P.width + _P.xspace), _P.extraextension + yshift),
                        point.create((x + _P.leftdummies + _P.nonresdummies + _P.nxfingers - 1) * (_P.width + _P.xspace) + _P.width, _P.extraextension + yshift + _P.contactheight)
                    )
                    geometry.contactbltr(resistor, "gate",
                        point.create((x + _P.leftdummies + _P.nonresdummies + _P.nxfingers - 1) * (_P.width + _P.xspace), _P.extraextension + yshift + _P.length + _P.contactheight + 2 * _P.extension),
                        point.create((x + _P.leftdummies + _P.nonresdummies + _P.nxfingers - 1) * (_P.width + _P.xspace) + _P.width, _P.extraextension + yshift + _P.length + _P.contactheight + 2 * _P.extension + _P.contactheight)
                    )
                    _add_contact_anchor(resistor, string.format("rightdummycontact_lower_%d_%d", x, y),
                        point.create((x + _P.nonresdummies + _P.leftdummies + _P.nxfingers - 1) * (_P.width + _P.xspace), _P.extraextension + yshift),
                        point.create((x + _P.nonresdummies + _P.leftdummies + _P.nxfingers - 1) * (_P.width + _P.xspace) + _P.width, _P.extraextension + yshift + _P.contactheight)
                    )
                    _add_contact_anchor(resistor, string.format("rightdummycontact_upper_%d_%d", x, y),
                        point.create((x + _P.nonresdummies + _P.leftdummies + _P.nxfingers - 1) * (_P.width + _P.xspace), _P.extraextension + yshift + _P.length + 2 * _P.extension + _P.contactheight),
                        point.create((x + _P.nonresdummies + _P.leftdummies + _P.nxfingers - 1) * (_P.width + _P.xspace) + _P.width, _P.extraextension + yshift + _P.length + 2 * _P.extension + 2 * _P.contactheight)
                    )
                end
            else
                for y = 1, _P.nyfingers + 1 do
                    local yshift = (y - 1) * ypitch
                    geometry.contactbltr(resistor, "gate",
                        point.create((x + _P.nonresdummies + _P.leftdummies + _P.nxfingers - 1) * (_P.width + _P.xspace), _P.extraextension + yshift),
                        point.create((x + _P.nonresdummies + _P.leftdummies + _P.nxfingers - 1) * (_P.width + _P.xspace) + _P.width, _P.extraextension + yshift + _P.contactheight)
                    )
                    _add_contact_anchor(resistor, string.format("rightdummycontact_%d_%d", x, y),
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
                point.create(_P.nonresdummies * (_P.width + _P.xspace) - _P.silicideblockerextendx, ystart + yshift),
                point.create((_P.nxfingers + _P.leftdummies + _P.rightdummies + _P.nonresdummies) * (_P.width + _P.xspace) - _P.xspace + _P.silicideblockerextendx, ystart + _P.length + yshift)
            )
        end
    else
        for x = 1, _P.nxfingers + _P.leftdummies + _P.rightdummies do
            local xshift = (x + _P.nonresdummies - 1) * (_P.width + _P.xspace)
            for y = 1, _P.nyfingers do
                geometry.rectanglebltr(resistor, generics.feol("silicideblocker"),
                    point.create(xshift - _P.silicideblockerextendx, _P.contactheight + _P.extension + (y - 1) * (_P.length + _P.yspace)),
                    point.create(xshift + _P.width + _P.silicideblockerextendx, _P.contactheight + _P.extension + (y - 1) * (_P.length + _P.yspace) + _P.length)
                )
            end
        end
    end
    -- implant
    if _P.implant_coverall then
        geometry.rectanglebltr(resistor, generics.implant(_P.implanttype),
            point.create(
                (1 - 1) * (_P.width + _P.xspace) - _P.extendimplantx,
                -_P.extendimplanty
            ),
            point.create(
                (_P.nxfingers + _P.leftdummies + _P.rightdummies + 2 * _P.nonresdummies - 1) * (_P.width + _P.xspace) + _P.width + _P.extendimplantx,
                totalpolyheight + _P.extendimplanty
            )
        )
    else
        for _, anchor in ipairs(allanchors) do
            geometry.rectanglebltr(resistor, generics.implant(_P.implanttype),
                resistor:get_area_anchor(anchor).bl:translate(-_P.extendimplantx, -_P.extendimplanty),
                resistor:get_area_anchor(anchor).tr:translate(_P.extendimplantx, _P.extendimplanty)
            )
        end
    end
    -- oxidetype
    if _P.oxidetype_coverall then
        geometry.rectanglebltr(resistor, generics.oxide(_P.oxidetype),
            point.create(
                (1 - 1) * (_P.width + _P.xspace) - _P.extendoxidetypex,
                -_P.extendoxidetypey
            ),
            point.create(
                (_P.nxfingers + _P.leftdummies + _P.rightdummies + 2 * _P.nonresdummies - 1) * (_P.width + _P.xspace) + _P.width + _P.extendoxidetypex,
                totalpolyheight + _P.extendoxidetypey
            )
        )
    else
        for _, anchor in ipairs(allanchors) do
            geometry.rectanglebltr(resistor, generics.oxidetype(_P.oxidetype),
                resistor:get_area_anchor(anchor).bl:translate(-_P.extendoxidetypex, -_P.extendoxidetypey),
                resistor:get_area_anchor(anchor).tr:translate(_P.extendoxidetypex, _P.extendoxidetypey)
            )
        end
    end
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
    -- resistance level
    if _P.drawresistancelevel then
        if _P.resistancelevel_coverall then
            for y = 1, _P.nyfingers do
                local yshift = (y - 1) * ypitch
                local ystart = _P.extraextension + _P.contactheight + _P.extension
                geometry.rectanglebltr(resistor, generics.feol(string.format("resistancelevel%d", _P.resistancelevel)),
                    point.create(_P.nonresdummies * (_P.width + _P.xspace) - _P.extendreslevelx, ystart + yshift - _P.extendreslevely),
                    point.create((_P.nxfingers + _P.leftdummies + _P.rightdummies + _P.nonresdummies) * (_P.width + _P.xspace) - _P.xspace + _P.extendreslevelx, ystart + _P.length + yshift + _P.extendreslevely)
                )
            end
        else
            for x = 1, _P.nxfingers + _P.leftdummies + _P.rightdummies do
                local xshift = (x + _P.nonresdummies - 1) * (_P.width + _P.xspace)
                for y = 1, _P.nyfingers do
                    geometry.rectanglebltr(resistor, generics.feol(string.format("resistancelevel%d", _P.resistancelevel)),
                        point.create(xshift - _P.extendreslevelx, _P.contactheight + _P.extension + (y - 1) * (_P.length + _P.yspace) - _P.extendreslevely),
                        point.create(xshift + _P.width + _P.extendreslevelx, _P.contactheight + _P.extension + (y - 1) * (_P.length + _P.yspace) + _P.length + _P.extendreslevely)
                    )
                end
            end
        end
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
    else -- series
        if _P.yspace > 0 then
            if _P.nxfingers % 2 == 0 then
                resistor:add_area_anchor_bltr("plus",
                    resistor:get_area_anchor(string.format("contact_lower_%d_%d", _P.nxfingers, 1)).bl,
                    resistor:get_area_anchor(string.format("contact_lower_%d_%d", _P.nxfingers, 1)).tr
                )
            else
                resistor:add_area_anchor_bltr("plus",
                    resistor:get_area_anchor(string.format("contact_upper_%d_%d", _P.nxfingers, _P.nyfingers)).bl,
                    resistor:get_area_anchor(string.format("contact_upper_%d_%d", _P.nxfingers, _P.nyfingers)).tr
                )
            end
            resistor:add_area_anchor_bltr("minus",
                resistor:get_area_anchor(string.format("contact_lower_%d_%d", 1, 1)).bl,
                resistor:get_area_anchor(string.format("contact_lower_%d_%d", 1, 1)).tr
            )
        else
            if _P.nxfingers % 2 == 0 then
                resistor:add_area_anchor_bltr("plus",
                    resistor:get_area_anchor(string.format("contact_%d_%d", _P.nxfingers, 1)).bl,
                    resistor:get_area_anchor(string.format("contact_%d_%d", _P.nxfingers, 1)).tr
                )
            else
                resistor:add_area_anchor_bltr("plus",
                    resistor:get_area_anchor(string.format("contact_%d_%d", _P.nxfingers, _P.nyfingers + 1)).bl,
                    resistor:get_area_anchor(string.format("contact_%d_%d", _P.nxfingers, _P.nyfingers + 1)).tr
                )
            end
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

    -- guardring
    if _P.drawguardring then
        local holewidth =
            (_P.nxfingers + _P.leftdummies + _P.rightdummies) * _P.width +
            (_P.nxfingers + _P.leftdummies + _P.rightdummies - 1) * _P.xspace +
            2 * _P.guardring_xsep
        local holeheight = totalpolyheight + 2 * _P.guardring_ysep
        local guardring = pcell.create_layout("auxiliary/guardring", "_guardring", {
            contype = _P.guardring_contype,
            holewidth = holewidth,
            holeheight = holeheight,
            ringwidth = _P.guardring_ringwidth,
            fillwell = true,
            fillinnerimplant = _P.implant_coverall,
            innerimplantpolarity = _P.implanttype,
            drawoxidetype = _P.drawoxidetype,
            filloxidetype = _P.drawoxidetype,
            oxidetype = _P.oxidetype,
            wellinnerextension = _P.guardringwellinnerextension,
            wellouterextension = _P.guardringwellouterextension,
            implantinnerextension = _P.guardringimplantinnerextension,
            implantouterextension = _P.guardringimplantouterextension,
            soiopeninnerextension = _P.guardringsoiopeninnerextension,
            soiopenouterextension = _P.guardringsoiopenouterextension,
        })
        if _P.yspace > 0 then
            if _P.leftdummies > 0 then
                guardring:move_point(
                    guardring:get_area_anchor("innerboundary").bl,
                    resistor:get_area_anchor_fmt("leftdummycontact_lower_%d_%d", 1, 1).bl
                )
            else
                guardring:move_point(
                    guardring:get_area_anchor("innerboundary").bl,
                    resistor:get_area_anchor_fmt("contact_lower_%d_%d", 1, 1).bl
                )
            end
        else
            if _P.leftdummies > 0 then
                guardring:move_point(
                    guardring:get_area_anchor("innerboundary").bl,
                    resistor:get_area_anchor_fmt("leftdummycontact_%d_%d", 1, 1).bl
                )
            else
                guardring:move_point(
                    guardring:get_area_anchor("innerboundary").bl,
                    resistor:get_area_anchor_fmt("contact_%d_%d", 1, 1).bl
                )
            end
        end
        guardring:translate(-_P.guardring_xsep, -_P.extraextension - _P.guardring_ysep)
        resistor:merge_into(guardring)
    end
end

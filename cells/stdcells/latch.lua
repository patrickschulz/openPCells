function parameters()
    pcell.add_parameter("clockpolarity", "positive", { posvals = set("positive", "negative") })
    pcell.add_parameter("enableQ", true)
    pcell.add_parameter("enableQN", false)
    pcell.add_parameter("enable_reset", false)
    pcell.inherit_parameters("stdcells/base")
end

function layout(gate, _P)
    local xpitch = _P.gspace + _P.glength
    local yrpitch = _P.routingwidth + _P.routingspace

    local gatecontactpos = {
        "center", "center", "lower", "upper", "center", "dummy"
    }
    local pcontactpos = {
        "outer", "inner", "outer", "outer", "power",
    }
    local ncontactpos = {
        "outer", "inner", nil, "power", "power",
    }
    --[[
    if _P.clockpolarity == "negative" then
        gatecontactpos[1] = "upper"
        gatecontactpos[3] = "upper"
        gatecontactpos[5] = "upper"
        gatecontactpos[7] = "lower"
        pcontactpos[6] = "outer"
        ncontactpos[6] = "power"
        pcontactpos[7] = "outer"
        ncontactpos[7] = nil
    end
    --]]
    if _P.enable_reset then
        --table.insert(gatecontactpos, 11, "upper")
        --gatecontactpos[12] = "center"
        --gatecontactpos[13] = "lower"
        pcontactpos[7] = "inner"
        pcontactpos[8] = "inner"
        ncontactpos[7] = "inner"
        ncontactpos[8] = "inner"
        gatecontactpos[7] = "center"
        gatecontactpos[8] = "center"
    end

    local baseparameters = {}
    for name, value in pairs(_P) do
        if pcell.has_parameter("stdcells/harness", name) then
            baseparameters[name] = value
        end
    end
    local harness = pcell.create_layout("stdcells/harness", "mosfets", util.add_options(baseparameters, {
        --fingers = 20 + (_P.enableQN and 2 or 0) + (_P.enable_reset and 1 or 0),
        gatecontactpos = gatecontactpos,
        pcontactpos = pcontactpos,
        ncontactpos = ncontactpos,
    }))
    gate:merge_into(harness)

    local anchor = function(str, suffix) return harness:get_anchor(string.format("%s%s", str, suffix or "")) end

    local spacing = _P.sdwidth / 2 + _P.routingspace
    local yinvert = _P.clockpolarity == "positive" and 1 or -1

    local gateoffset = _P.enable_reset and 1 or 0

    geometry.path(gate, generics.metal(1), 
        geometry.path_points_xy(anchor("pSDc1"), {
            -xpitch / 2,
            anchor("nSDc1")
        }), _P.sdwidth
    )
    geometry.rectanglebltr(gate, generics.metal(1), 
        anchor("pSDc3"):translate(0, -_P.sdwidth / 2),
        anchor("pSDc4"):translate(0, _P.sdwidth / 2)
    )
    geometry.path(gate, generics.metal(1), 
        geometry.path_points_xy(anchor("pSDc2"), {
            anchor("G1cc"),
            0,
            anchor("nSDc2")
        }), _P.sdwidth
    )

    --[[
    gate:merge_into(geometry.path(generics.metal(1), 
        geometry.path_points_xy(anchor("pSDi8"):translate(0, _P.sdwidth / 2), {
            anchor("G1cc"),
            0,
            anchor("nSDi8"):translate(0, -_P.sdwidth / 2)
        }),
    _P.sdwidth))
    gate:merge_into(geometry.path(generics.metal(1), 
        geometry.path_points_yx(anchor("pSDo12"), {
            -_P.pwidth + _P.sdwidth / 2,
            anchor("G13cc"),
            0,
            anchor("nSDc13")
        }),
    _P.sdwidth))
    gate:merge_into(geometry.rectanglebltr(generics.metal(1), 
        anchor("pSDc10"):translate(0, -_P.sdwidth / 2),
        anchor("pSDc11"):translate(0, _P.sdwidth / 2)
    ))
    gate:merge_into(geometry.rectanglebltr(generics.metal(1), 
        anchor("nSDc11"):translate(0, -_P.sdwidth / 2),
        anchor("nSDc12"):translate(0, _P.sdwidth / 2)
    ))
    gate:merge_into(geometry.path(generics.metal(2), 
        geometry.path_points_yx(anchor("G13cc"), {
            anchor("G9cc"),
        }),
    _P.sdwidth))
    gate:merge_into(geometry.rectanglebltr(generics.via(1, 2), 
        anchor("G9cc"):translate(-_P.glength / 2, -_P.routingwidth / 2),
        anchor("G9cc"):translate( _P.glength / 2,  _P.routingwidth / 2)
    ))
    gate:merge_into(geometry.rectanglebltr(generics.via(1, 2), 
        anchor("G13cc"):translate(-_P.glength / 2, -_P.routingwidth / 2),
        anchor("G13cc"):translate( _P.glength / 2,  _P.routingwidth / 2)
    ))
    if _P.enable_reset then
        gate:add_port("RST", generics.metalport(1), anchor("G16cc"):translate(-xpitch / 2, 0))
    end
    gate:add_port("D", generics.metalport(1), anchor("G1cc"):translate(0, yinvert * 2 * (_P.routingwidth + _P.routingspace)))
    gate:add_port("CLK", generics.metalport(1), anchor("G1cc"))
    gate:add_port("VDD", generics.metalport(1), anchor("top"))
    gate:add_port("VSS", generics.metalport(1), anchor("bottom"))
    --]]
end

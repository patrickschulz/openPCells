function parameters()
    pcell.add_parameters(
        { "gatelength", technology.get_dimension("Minimum Gate Length"), argtype = "integer" },
        { "gatespace", technology.get_dimension("Minimum Gate XSpace"), argtype = "integer" },
        { "splitgates", false },
        { "gatestopextension", 0 },
        { "gatesbotextension", 0 },
        { "rows", {} },
        { "sdwidth", technology.get_dimension("Minimum M1 Width") },
        { "gatestrapwidth", technology.get_dimension("Minimum M1 Width") },
        { "gatestrapspace", technology.get_dimension("Minimum M1 Space") },
        { "powermetal", 1 },
        { "powerwidth", technology.get_dimension("Minimum M1 Width") },
        { "powerspace", technology.get_dimension("Minimum M1 Space") },
        { "separation", 0 },
        { "drawtopgatecut", false },
        { "topgatecutwidth", 0 },
        { "topgatecutspace", 0 },
        { "drawbotgatecut", false },
        { "botgatecutwidth", 0 },
        { "botgatecutspace", 0 },
        { "drawleftstopgate", false },
        { "drawrightstopgate", false },
        { "stopgatecutwidth", 0 },
        { "implantleftextension", 0 },
        { "implantrightextension", 0 },
        { "implanttopextension", 0 },
        { "implantbotextension", 0 },
        { "vthtypeleftextension", 0 },
        { "vthtyperightextension", 0 },
        { "vthtypetopextension", 0 },
        { "vthtypebotextension", 0 },
        { "leftpolylines", {} },
        { "rightpolylines", {} }
    )
end

function check(_P)
    local rowfingers = {}
    for rownum, row in ipairs(_P.rows) do
        local f = 0
        for devicenum, device in ipairs(row.devices) do
            if not device.fingers then
                return false, string.format("device %d in row %d has no finger specification", devicenum, rownum)
            end
            if device.fingers <= 0 then
                return false, string.format("device %d in row %d has zero or negative amount of fingers (%d)", devicenum, rownum, device.fingers)
            end
            if not math.tointeger(device.fingers) then
                return false, string.format("device %d in row %d has a non-integer number of fingers (%f). This is currently not supported", devicenum, rownum, device.fingers)
            end
            if device.fingers % 2 ~= 0 then
                return false, string.format("device %d in row %d has an odd number of fingers (%d). This is currently not supported", devicenum, rownum, device.fingers)
            end
            f = f + device.fingers
        end
        rowfingers[rownum] = f
    end
    local fingersperrow = rowfingers[1]
    for i = 2, #rowfingers do
        if fingersperrow ~= rowfingers[i] then
            return false, string.format("rows don't have the same number of fingers (first row has %d fingers, %d. row has %d fingers)", fingersperrow, i, rowfingers[i])
        end
    end

    local names = {}
    for rownum, row in ipairs(_P.rows) do
        if not row.channeltype then
            return false, string.format("row %d does not have a channeltype", rownum)
        end
        if not row.vthtype then
            return false, string.format("row %d does not have a threshold voltage type", rownum)
        end
        for devicenum, device in ipairs(row.devices) do
            if not device.name then
                return false, string.format("device %d in row %d does not have a name", devicenum, rownum)
            else
                if names[device.name] then
                    return false, string.format("device %d in row %d does not have a unique name ('%s')", devicenum, rownum, device.name)
                end
                names[device.name] = true
            end
            if device.connectsource then
                if not device.connectsourcewidth then
                    return false, string.format("device %d in row %d specified connectsource = true, but did not provide the strap width (connectsourcewidth)", devicenum, rownum)
                end
                if not device.connectsourcespace then
                    return false, string.format("device %d in row %d specified connectsource = true, but did not provide the strap spacing (connectsourcespace)", devicenum, rownum)
                end
            end
            if device.connectextrasource then
                if not device.connectextrasourcewidth then
                    return false, string.format("device %d in row %d specified connectextrasource = true, but did not provide the strap width (connectextrasourcewidth)", devicenum, rownum)
                end
                if not device.connectextrasourcespace then
                    return false, string.format("device %d in row %d specified connectextrasource = true, but did not provide the strap spacing (connectextrasourcespace)", devicenum, rownum)
                end
            end
            if device.connectdrain then
                if not device.connectdrainwidth then
                    return false, string.format("device %d in row %d specified connectdrain = true, but did not provide the strap width (connectdrainwidth)", devicenum, rownum)
                end
                if not device.connectdrainspace then
                    return false, string.format("device %d in row %d specified connectdrain = true, but did not provide the strap spacing (connectdrainspace)", devicenum, rownum)
                end
            end
            if device.connectextradrain then
                if not device.connectextradrainwidth then
                    return false, string.format("device %d in row %d specified connectextradrain = true, but did not provide the strap width (connectextradrainwidth)", devicenum, rownum)
                end
                if not device.connectextradrainspace then
                    return false, string.format("device %d in row %d specified connectextradrain = true, but did not provide the strap spacing (connectextradrainspace)", devicenum, rownum)
                end
            end
            if device.drawtopgate then
                if not device.topgatewidth then
                    return false, string.format("device %d in row %d specified drawtopgate = true, but did not provide the strap width (topgatewidth)", devicenum, rownum)
                end
                if not device.topgatespace then
                    return false, string.format("device %d in row %d specified drawtopgate = true, but did not provide the strap spacing (topgatespace)", devicenum, rownum)
                end
            end
            if device.drawbotgate then
                if not device.botgatewidth then
                    return false, string.format("device %d in row %d specified drawbotgate = true, but did not provide the strap width (botgatewidth)", devicenum, rownum)
                end
                if not device.botgatespace then
                    return false, string.format("device %d in row %d specified drawbotgate = true, but did not provide the strap spacing (botgatespace)", devicenum, rownum)
                end
            end
            if device.drawtopgatecut then
                if not device.topgatecutwidth then
                    return false, string.format("device %d in row %d specified drawtopgatecut = true, but did not provide the cut width (topgatecutwidth)", devicenum, rownum)
                end
                if not device.topgatecutspace then
                    return false, string.format("device %d in row %d specified drawtopgatecut = true, but did not provide the cut spacing (topgatecutspace)", devicenum, rownum)
                end
            end
            if device.drawbotgatecut then
                if not device.botgatecutwidth then
                    return false, string.format("device %d in row %d specified drawbotgatecut = true, but did not provide the cut width (botgatecutwidth)", devicenum, rownum)
                end
                if not device.botgatecutspace then
                    return false, string.format("device %d in row %d specified drawbotgatecut = true, but did not provide the cut spacing (botgatecutspace)", devicenum, rownum)
                end
            end
        end
    end
    return true
end

function layout(cell, _P)

    local totalfingers = 0
    for _, row in ipairs(_P.rows) do
        local rowfingers = 0
        for _, device in ipairs(row.devices) do
            rowfingers = rowfingers + device.fingers
        end
        totalfingers = math.max(rowfingers, totalfingers)
    end

    -- calculate total width and height
    local totalwidth = (totalfingers + 2) * _P.gatelength + (totalfingers + 1) * _P.gatespace
    local totalheight = 0
    for _, row in ipairs(_P.rows) do
        totalheight = totalheight + row.width
    end
    totalheight = totalheight + (#_P.rows - 1) * _P.separation

    -- cumulative row heights
    local rowheights = {}
    for i = 1, #_P.rows do
        local row = _P.rows[i]
        if i == 1 then
            rowheights[i] = 0
        end
        rowheights[i + 1] = rowheights[i] + row.width + _P.separation
    end

    local xpitch = _P.gatelength + _P.gatespace

    -- gates
    if _P.splitgates then
        -- FIXME: add gate top and bottom extensions
        for rownum, row in ipairs(_P.rows) do
            local currentfingers = 0
            for devicenum, device in ipairs(row.devices) do
                for finger = 1, device.fingers do
                    geometry.rectanglebltr(cell, generics.other("gate"),
                        point.create(
                            (finger + currentfingers) * (_P.gatelength + _P.gatespace),
                            rowheights[rownum] - ((rownum == 1) and _P.gatesbotextension or row.gatebotextension or 0)
                        ),
                        point.create(
                            (finger + currentfingers) * (_P.gatelength + _P.gatespace) + _P.gatelength,
                            rowheights[rownum] + row.width + ((rownum == #_P.rows) and _P.gatestopextension or row.gatetopextension or 0)
                        )
                    )
                end
                -- update fingers
                currentfingers = currentfingers + device.fingers
            end
            if _P.drawleftstopgate then
                geometry.rectanglebltr(cell, generics.other("gate"),
                    point.create(
                        0,
                        rowheights[rownum] - ((rownum == 1) and _P.gatesbotextension or row.gatebotextension or 0)
                    ),
                    point.create(
                        _P.gatelength,
                        rowheights[rownum] + row.width + ((rownum == #_P.rows) and _P.gatestopextension or row.gatetopextension or 0)
                    )
                )
                geometry.rectanglebltr(cell, generics.other("diffusionbreakgate"),
                    point.create(
                        0,
                        rowheights[rownum] - ((rownum == 1) and _P.gatesbotextension or row.gatebotextension or 0)
                    ),
                    point.create(
                        _P.gatelength,
                        rowheights[rownum] + row.width + ((rownum == #_P.rows) and _P.gatestopextension or row.gatetopextension or 0)
                    )
                )
            end
            if _P.drawrightstopgate then
                geometry.rectanglebltr(cell, generics.other("gate"),
                    point.create(
                        (totalfingers + 1) * (_P.gatelength + _P.gatespace),
                        rowheights[rownum] - ((rownum == 1) and _P.gatesbotextension or row.gatebotextension or 0)
                    ),
                    point.create(
                        (totalfingers + 1) * (_P.gatelength + _P.gatespace) + _P.gatelength,
                        rowheights[rownum] + row.width + ((rownum == #_P.rows) and _P.gatestopextension or row.gatetopextension or 0)
                    )
                )
                geometry.rectanglebltr(cell, generics.other("diffusionbreakgate"),
                    point.create(
                        (totalfingers + 1) * (_P.gatelength + _P.gatespace),
                        rowheights[rownum] - ((rownum == 1) and _P.gatesbotextension or row.gatebotextension or 0)
                    ),
                    point.create(
                        (totalfingers + 1) * (_P.gatelength + _P.gatespace) + _P.gatelength,
                        rowheights[rownum] + row.width + ((rownum == #_P.rows) and _P.gatestopextension or row.gatetopextension or 0)
                    )
                )
            end
        end
    else
        for finger = 1, totalfingers do
            geometry.rectanglebltr(cell, generics.other("gate"),
                point.create(finger * (_P.gatelength + _P.gatespace), -_P.gatesbotextension),
                point.create(finger * (_P.gatelength + _P.gatespace) + _P.gatelength, totalheight + _P.gatestopextension)
            )
        end
        if _P.drawleftstopgate then
            geometry.rectanglebltr(cell, generics.other("gate"),
                point.create(0, -_P.gatesbotextension),
                point.create(_P.gatelength, totalheight + _P.gatestopextension)
            )
            for rownum, row in ipairs(_P.rows) do
                geometry.rectanglebltr(cell, generics.other("diffusionbreakgate"),
                    point.create(0, rowheights[rownum] - (_P.separation - _P.stopgatecutwidth) / 2),
                    point.create(_P.gatelength, rowheights[rownum] + row.width + (_P.separation - _P.stopgatecutwidth) / 2)
                )
                geometry.rectanglebltr(cell, generics.other("gatecut"),
                    point.create(
                        -_P.gatespace / 2,
                        rowheights[rownum] + row.width + (_P.separation - _P.stopgatecutwidth) / 2
                    ),
                    point.create(
                        _P.gatelength + _P.gatespace / 2,
                        rowheights[rownum] + row.width + (_P.separation + _P.stopgatecutwidth) / 2
                    )
                )
                geometry.rectanglebltr(cell, generics.other("gatecut"),
                    point.create(
                        -_P.gatespace / 2,
                        rowheights[rownum] - (_P.separation + _P.stopgatecutwidth) / 2
                    ),
                    point.create(
                        _P.gatelength + _P.gatespace / 2,
                        rowheights[rownum] - (_P.separation - _P.stopgatecutwidth) / 2
                    )
                )
            end
        end
        if _P.drawrightstopgate then
            geometry.rectanglebltr(cell, generics.other("gate"),
                point.create((totalfingers + 1) * (_P.gatelength + _P.gatespace), -_P.gatesbotextension),
                point.create((totalfingers + 1) * (_P.gatelength + _P.gatespace) + _P.gatelength, totalheight + _P.gatestopextension)
            )
            for rownum, row in ipairs(_P.rows) do
                geometry.rectanglebltr(cell, generics.other("diffusionbreakgate"),
                    point.create((totalfingers + 1) * (_P.gatelength + _P.gatespace), rowheights[rownum] - (_P.separation - _P.stopgatecutwidth) / 2),
                    point.create((totalfingers + 1) * (_P.gatelength + _P.gatespace) + _P.gatelength, rowheights[rownum] + row.width + (_P.separation - _P.stopgatecutwidth) / 2)
                )
                geometry.rectanglebltr(cell, generics.other("gatecut"),
                    point.create(
                        (totalfingers + 1) * (_P.gatelength + _P.gatespace) - _P.gatespace / 2,
                        rowheights[rownum] + row.width + (_P.separation - _P.stopgatecutwidth) / 2
                    ),
                    point.create(
                        (totalfingers + 1) * (_P.gatelength + _P.gatespace) + _P.gatelength + _P.gatespace / 2,
                        rowheights[rownum] + row.width + (_P.separation + _P.stopgatecutwidth) / 2
                    )
                )
                geometry.rectanglebltr(cell, generics.other("gatecut"),
                    point.create(
                        (totalfingers + 1) * (_P.gatelength + _P.gatespace) - _P.gatespace / 2,
                        rowheights[rownum] - (_P.separation + _P.stopgatecutwidth) / 2
                    ),
                    point.create(
                        (totalfingers + 1) * (_P.gatelength + _P.gatespace) + _P.gatelength + _P.gatespace / 2,
                        rowheights[rownum] - (_P.separation - _P.stopgatecutwidth) / 2
                    )
                )
            end
        end
    end

    for rownum, row in ipairs(_P.rows) do
        -- active regions
        geometry.rectanglebltr(cell, generics.other("active"),
            point.create(_P.gatelength / 2, rowheights[rownum]),
            point.create(totalwidth - _P.gatelength / 2, rowheights[rownum] + row.width)
        )

        -- channeltype
        local implanttopext = 0
        local implantbotext = 0
        if rownum == 1 then
            implantbotext = _P.implantbotextension
        end
        if rownum == #_P.rows then
            implanttopext = _P.implanttopextension
        end
        geometry.rectanglebltr(cell, generics.implant(row.channeltype),
            point.create(-_P.implantleftextension, rowheights[rownum] - _P.separation / 2 - implantbotext),
            point.create(totalwidth + _P.implantrightextension, rowheights[rownum] + row.width + _P.separation / 2 + implanttopext)
        )

        -- vthtype
        local vthtypetopext = 0
        local vthtypebotext = 0
        if rownum == 1 then
            vthtypebotext = _P.vthtypebotextension
        end
        if rownum == #_P.rows then
            vthtypetopext = _P.vthtypetopextension
        end
        geometry.rectanglebltr(cell, generics.vthtype(row.channeltype, row.vthtype),
            point.create(-_P.vthtypeleftextension, rowheights[rownum] - _P.separation / 2 - vthtypebotext),
            point.create(totalwidth + _P.vthtyperightextension, rowheights[rownum] + row.width + _P.separation / 2 + vthtypetopext)
        )

        local currentfingers = 0
        for _, device in ipairs(row.devices) do
            -- source/drain contacts
            for finger = 1, device.fingers + 1 do
                cell:add_area_anchor_bltr(string.format("%ssourcedrainactive%d", device.name, finger),
                    point.create(
                        _P.gatelength + (_P.gatespace - _P.sdwidth) / 2 + (currentfingers + finger - 1) * (_P.gatelength + _P.gatespace),
                        rowheights[rownum]
                    ),
                    point.create(
                        _P.gatelength + (_P.gatespace - _P.sdwidth) / 2 + (currentfingers + finger - 1) * (_P.gatelength + _P.gatespace) + _P.sdwidth,
                        rowheights[rownum] + row.width
                    )
                )
                local sourcebasey
                local drainbasey
                if row.channeltype == "nmos" then
                    sourcebasey = rowheights[rownum]
                    drainbasey = rowheights[rownum] + row.width - (device.drainsize or row.width)
                else
                    drainbasey = rowheights[rownum]
                    sourcebasey = rowheights[rownum] + row.width - (device.sourcesize or row.width)
                end
                if finger % 2 == 1 then -- source
                    geometry.contactbltr(cell, "sourcedrain",
                        point.create(
                            _P.gatelength + (_P.gatespace - _P.sdwidth) / 2 + (currentfingers + finger - 1) * (_P.gatelength + _P.gatespace),
                            sourcebasey
                        ),
                        point.create(
                            _P.gatelength + (_P.gatespace - _P.sdwidth) / 2 + (currentfingers + finger - 1) * (_P.gatelength + _P.gatespace) + _P.sdwidth,
                            sourcebasey + (device.sourcesize or row.width)
                        )
                    )
                else -- drain
                    geometry.contactbltr(cell, "sourcedrain",
                        point.create(
                            _P.gatelength + (_P.gatespace - _P.sdwidth) / 2 + (currentfingers + finger - 1) * (_P.gatelength + _P.gatespace),
                            drainbasey
                        ),
                        point.create(
                            _P.gatelength + (_P.gatespace - _P.sdwidth) / 2 + (currentfingers + finger - 1) * (_P.gatelength + _P.gatespace) + _P.sdwidth,
                            drainbasey + (device.drainsize or row.width)
                        )
                    )
                end
                cell:add_area_anchor_bltr(string.format("%ssourcedrain%d", device.name, finger),
                    point.create(
                        _P.gatelength + (_P.gatespace - _P.sdwidth) / 2 + (currentfingers + finger - 1) * (_P.gatelength + _P.gatespace),
                        rowheights[rownum]
                    ),
                    point.create(
                        _P.gatelength + (_P.gatespace - _P.sdwidth) / 2 + (currentfingers + finger - 1) * (_P.gatelength + _P.gatespace) + _P.sdwidth,
                        rowheights[rownum] + row.width
                    )
                )
                -- source/drain connections and vias
                local sourceviabasey
                local drainviabasey
                if row.channeltype == "nmos" then
                    if device.connectsourceinverse then
                        sourceviabasey = rowheights[rownum] + row.width - (device.sourceviasize or row.width)
                    else
                        sourceviabasey = rowheights[rownum]
                    end
                    if device.connectdraininverse then
                        drainviabasey = rowheights[rownum]
                    else
                        drainviabasey = rowheights[rownum] + row.width - (device.drainviasize or row.width)
                    end
                else
                    if device.connectsourceinverse then
                        sourceviabasey = rowheights[rownum]
                    else
                        sourceviabasey = rowheights[rownum] + row.width - (device.sourceviasize or row.width)
                    end
                    if device.connectdraininverse then
                        drainviabasey = rowheights[rownum] + row.width - (device.drainviasize or row.width)
                    else
                        drainviabasey = rowheights[rownum]
                    end
                end
                if finger % 2 == 1 then -- source
                    if device.sourcemetal and device.sourcemetal > 1 then
                        geometry.viabltr(cell, 1, device.sourcemetal,
                            point.create(
                                _P.gatelength + (_P.gatespace - _P.sdwidth) / 2 + (currentfingers + finger - 1) * (_P.gatelength + _P.gatespace),
                                sourceviabasey
                            ),
                            point.create(
                                _P.gatelength + (_P.gatespace - _P.sdwidth) / 2 + (currentfingers + finger - 1) * (_P.gatelength + _P.gatespace) + _P.sdwidth,
                                sourceviabasey + (device.sourceviasize or row.width)
                            )
                        )
                    end
                    -- source wires
                    if device.connectsource then
                        if (row.channeltype == "pmos" and not device.connectsourceinverse) or (row.channeltype == "nmos" and device.connectsourceinverse) then
                            geometry.rectanglebltr(cell, generics.metal(device.sourcemetal or 1),
                                point.create(
                                    _P.gatelength + (_P.gatespace - _P.sdwidth) / 2 + (currentfingers + finger - 1) * (_P.gatelength + _P.gatespace),
                                    rowheights[rownum] + row.width
                                ),
                                point.create(
                                    _P.gatelength + (_P.gatespace - _P.sdwidth) / 2 + (currentfingers + finger - 1) * (_P.gatelength + _P.gatespace) + _P.sdwidth,
                                    rowheights[rownum] + row.width + device.connectsourcespace
                                )
                            )
                        else
                            geometry.rectanglebltr(cell, generics.metal(device.sourcemetal or 1),
                                point.create(
                                    _P.gatelength + (_P.gatespace - _P.sdwidth) / 2 + (currentfingers + finger - 1) * (_P.gatelength + _P.gatespace),
                                    rowheights[rownum] - device.connectsourcespace
                                ),
                                point.create(
                                    _P.gatelength + (_P.gatespace - _P.sdwidth) / 2 + (currentfingers + finger - 1) * (_P.gatelength + _P.gatespace) + _P.sdwidth,
                                    rowheights[rownum]
                                )
                            )
                        end
                    end
                    if device.connectextrasource then
                        if (row.channeltype == "nmos" and not device.connectsourceinverse) or (row.channeltype == "pmos" and device.connectsourceinverse) then
                            geometry.rectanglebltr(cell, generics.metal(device.sourcemetal or 1),
                                point.create(
                                    _P.gatelength + (_P.gatespace - _P.sdwidth) / 2 + (currentfingers + finger - 1) * (_P.gatelength + _P.gatespace),
                                    rowheights[rownum] + row.width
                                ),
                                point.create(
                                    _P.gatelength + (_P.gatespace - _P.sdwidth) / 2 + (currentfingers + finger - 1) * (_P.gatelength + _P.gatespace) + _P.sdwidth,
                                    rowheights[rownum] + row.width + device.connectextrasourcespace
                                )
                            )
                        else
                            geometry.rectanglebltr(cell, generics.metal(device.sourcemetal or 1),
                                point.create(
                                    _P.gatelength + (_P.gatespace - _P.sdwidth) / 2 + (currentfingers + finger - 1) * (_P.gatelength + _P.gatespace),
                                    rowheights[rownum] - device.connectextrasourcespace
                                ),
                                point.create(
                                    _P.gatelength + (_P.gatespace - _P.sdwidth) / 2 + (currentfingers + finger - 1) * (_P.gatelength + _P.gatespace) + _P.sdwidth,
                                    rowheights[rownum]
                                )
                            )
                        end
                    end
                else
                    if device.drainmetal and device.drainmetal > 1 then
                        geometry.viabltr(cell, 1, device.drainmetal,
                            point.create(
                                _P.gatelength + (_P.gatespace - _P.sdwidth) / 2 + (currentfingers + finger - 1) * (_P.gatelength + _P.gatespace),
                                drainviabasey
                            ),
                            point.create(
                                _P.gatelength + (_P.gatespace - _P.sdwidth) / 2 + (currentfingers + finger - 1) * (_P.gatelength + _P.gatespace) + _P.sdwidth,
                                drainviabasey + (device.drainviasize or row.width)
                            )
                        )
                    end
                    -- drain wires
                    if device.connectdrain then
                        if (row.channeltype == "pmos" and not device.connectdraininverse) or (row.channeltype == "nmos" and device.connectdraininverse) then
                            geometry.rectanglebltr(cell, generics.metal(device.drainmetal or 1),
                                point.create(
                                    _P.gatelength + (_P.gatespace - _P.sdwidth) / 2 + (currentfingers + finger - 1) * (_P.gatelength + _P.gatespace),
                                    rowheights[rownum] - device.connectdrainspace
                                ),
                                point.create(
                                    _P.gatelength + (_P.gatespace - _P.sdwidth) / 2 + (currentfingers + finger - 1) * (_P.gatelength + _P.gatespace) + _P.sdwidth,
                                    rowheights[rownum]
                                )
                            )
                        else
                            geometry.rectanglebltr(cell, generics.metal(device.drainmetal or 1),
                                point.create(
                                    _P.gatelength + (_P.gatespace - _P.sdwidth) / 2 + (currentfingers + finger - 1) * (_P.gatelength + _P.gatespace),
                                    rowheights[rownum] + row.width
                                ),
                                point.create(
                                    _P.gatelength + (_P.gatespace - _P.sdwidth) / 2 + (currentfingers + finger - 1) * (_P.gatelength + _P.gatespace) + _P.sdwidth,
                                    rowheights[rownum] + row.width + device.connectdrainspace
                                )
                            )
                        end
                    end
                    if device.connectextradrain then
                        if (row.channeltype == "nmos" and not device.connectdraininverse) or (row.channeltype == "pmos" and device.connectdraininverse) then
                            geometry.rectanglebltr(cell, generics.metal(device.drainmetal or 1),
                                point.create(
                                    _P.gatelength + (_P.gatespace - _P.sdwidth) / 2 + (currentfingers + finger - 1) * (_P.gatelength + _P.gatespace),
                                    rowheights[rownum] - device.connectextradrainspace
                                ),
                                point.create(
                                    _P.gatelength + (_P.gatespace - _P.sdwidth) / 2 + (currentfingers + finger - 1) * (_P.gatelength + _P.gatespace) + _P.sdwidth,
                                    rowheights[rownum]
                                )
                            )
                        else
                            geometry.rectanglebltr(cell, generics.metal(device.drainmetal or 1),
                                point.create(
                                    _P.gatelength + (_P.gatespace - _P.sdwidth) / 2 + (currentfingers + finger - 1) * (_P.gatelength + _P.gatespace),
                                    rowheights[rownum] + row.width
                                ),
                                point.create(
                                    _P.gatelength + (_P.gatespace - _P.sdwidth) / 2 + (currentfingers + finger - 1) * (_P.gatelength + _P.gatespace) + _P.sdwidth,
                                    rowheights[rownum] + row.width + device.connectextradrainspace
                                )
                            )
                        end
                    end
                end
            end

            -- source/drain straps
            if device.connectsource then
                if (row.channeltype == "pmos" and not device.connectsourceinverse) or (row.channeltype == "nmos" and device.connectsourceinverse) then
                    geometry.rectanglebltr(cell, generics.metal(device.sourcemetal or 1),
                        point.create(
                            _P.gatelength + (_P.gatespace - _P.sdwidth) / 2 - _P.sdwidth + currentfingers * (_P.gatelength + _P.gatespace) + _P.sdwidth,
                            rowheights[rownum] + row.width + device.connectsourcespace
                        ),
                        point.create(
                            _P.gatelength + (_P.gatespace - _P.sdwidth) / 2 + _P.sdwidth + (currentfingers + device.fingers) * (_P.gatelength + _P.gatespace),
                            rowheights[rownum] + row.width + device.connectsourcespace + device.connectsourcewidth
                        )
                    )
                    cell:add_area_anchor_bltr(string.format("%ssourcestrap", device.name),
                        point.create(
                            _P.gatelength + (_P.gatespace - _P.sdwidth) / 2 - _P.sdwidth + currentfingers * (_P.gatelength + _P.gatespace) + _P.sdwidth,
                            rowheights[rownum] + row.width + device.connectsourcespace
                        ),
                        point.create(
                            _P.gatelength + (_P.gatespace - _P.sdwidth) / 2 + _P.sdwidth + (currentfingers + device.fingers) * (_P.gatelength + _P.gatespace),
                            rowheights[rownum] + row.width + device.connectsourcespace + device.connectsourcewidth
                        )
                    )
                else
                    geometry.rectanglebltr(cell, generics.metal(device.sourcemetal or 1),
                        point.create(
                            _P.gatelength + (_P.gatespace - _P.sdwidth) / 2 - _P.sdwidth + currentfingers * (_P.gatelength + _P.gatespace) + _P.sdwidth,
                            rowheights[rownum] - device.connectsourcespace - device.connectsourcewidth
                        ),
                        point.create(
                            _P.gatelength + (_P.gatespace - _P.sdwidth) / 2 + _P.sdwidth + (currentfingers + device.fingers) * (_P.gatelength + _P.gatespace),
                            rowheights[rownum] - device.connectsourcespace
                        )
                    )
                    cell:add_area_anchor_bltr(string.format("%ssourcestrap", device.name),
                        point.create(
                            _P.gatelength + (_P.gatespace - _P.sdwidth) / 2 - _P.sdwidth + currentfingers * (_P.gatelength + _P.gatespace) + _P.sdwidth,
                            rowheights[rownum] - device.connectsourcespace - device.connectsourcewidth
                        ),
                        point.create(
                            _P.gatelength + (_P.gatespace - _P.sdwidth) / 2 + _P.sdwidth + (currentfingers + device.fingers) * (_P.gatelength + _P.gatespace),
                            rowheights[rownum] - device.connectsourcespace
                        )
                    )
                end
            end
            if device.connectdrain then
                if (row.channeltype == "pmos" and not device.connectdraininverse) or (row.channeltype == "nmos" and device.connectdraininverse) then
                    geometry.rectanglebltr(cell, generics.metal(device.drainmetal or 1),
                        point.create(
                            (currentfingers + 1) * (_P.gatelength + _P.gatespace) + _P.gatelength + (_P.gatespace - _P.sdwidth) / 2,
                            rowheights[rownum] - device.connectdrainspace - device.connectdrainwidth
                        ),
                        point.create(
                            (currentfingers + device.fingers) * (_P.gatelength + _P.gatespace) - (_P.gatespace - _P.sdwidth) / 2,
                            rowheights[rownum] - device.connectdrainspace
                        )
                    )
                    cell:add_area_anchor_bltr(string.format("%sdrainstrap", device.name),
                        point.create(
                            (currentfingers + 1) * (_P.gatelength + _P.gatespace) + _P.gatelength + (_P.gatespace - _P.sdwidth) / 2,
                            rowheights[rownum] - device.connectdrainspace - device.connectdrainwidth
                        ),
                        point.create(
                            (currentfingers + device.fingers) * (_P.gatelength + _P.gatespace) - (_P.gatespace - _P.sdwidth) / 2,
                            rowheights[rownum] - device.connectdrainspace
                        )
                    )
                else
                    geometry.rectanglebltr(cell, generics.metal(device.drainmetal or 1),
                        point.create(
                            (currentfingers + 1) * (_P.gatelength + _P.gatespace) + _P.gatelength + (_P.gatespace - _P.sdwidth) / 2,
                            rowheights[rownum] + row.width + device.connectdrainspace
                        ),
                        point.create(
                            (currentfingers + device.fingers) * (_P.gatelength + _P.gatespace) - (_P.gatespace - _P.sdwidth) / 2,
                            rowheights[rownum] + row.width + device.connectdrainspace + device.connectdrainwidth
                        )
                    )
                    cell:add_area_anchor_bltr(string.format("%sdrainstrap", device.name),
                        point.create(
                            (currentfingers + 1) * (_P.gatelength + _P.gatespace) + _P.gatelength + (_P.gatespace - _P.sdwidth) / 2,
                            rowheights[rownum] + row.width + device.connectdrainspace
                        ),
                        point.create(
                            (currentfingers + device.fingers) * (_P.gatelength + _P.gatespace) - (_P.gatespace - _P.sdwidth) / 2,
                            rowheights[rownum] + row.width + device.connectdrainspace + device.connectdrainwidth
                        )
                    )
                end
            end

            -- extra source/drain straps
            if device.connectextrasource then
                if (row.channeltype == "nmos" and not device.connectsourceinverse) or (row.channeltype == "pmos" and device.connectsourceinverse) then
                    geometry.rectanglebltr(cell, generics.metal(device.sourcemetal or 1),
                        point.create(
                            _P.gatelength + (_P.gatespace - _P.sdwidth) / 2 - _P.sdwidth + currentfingers * (_P.gatelength + _P.gatespace) + _P.sdwidth,
                            rowheights[rownum] + row.width + device.connectextrasourcespace
                        ),
                        point.create(
                            _P.gatelength + (_P.gatespace - _P.sdwidth) / 2 + _P.sdwidth + (currentfingers + device.fingers) * (_P.gatelength + _P.gatespace),
                            rowheights[rownum] + row.width + device.connectextrasourcespace + device.connectextrasourcewidth
                        )
                    )
                    cell:add_area_anchor_bltr(string.format("%sextrasourcestrap", device.name),
                        point.create(
                            _P.gatelength + (_P.gatespace - _P.sdwidth) / 2 - _P.sdwidth + currentfingers * (_P.gatelength + _P.gatespace) + _P.sdwidth,
                            rowheights[rownum] + row.width + device.connectextrasourcespace
                        ),
                        point.create(
                            _P.gatelength + (_P.gatespace - _P.sdwidth) / 2 + _P.sdwidth + (currentfingers + device.fingers) * (_P.gatelength + _P.gatespace),
                            rowheights[rownum] + row.width + device.connectextrasourcespace + device.connectextrasourcewidth
                        )
                    )
                else
                    geometry.rectanglebltr(cell, generics.metal(device.sourcemetal or 1),
                        point.create(
                            _P.gatelength + (_P.gatespace - _P.sdwidth) / 2 - _P.sdwidth + currentfingers * (_P.gatelength + _P.gatespace) + _P.sdwidth,
                            rowheights[rownum] - device.connectextrasourcespace - device.connectextrasourcewidth
                        ),
                        point.create(
                            _P.gatelength + (_P.gatespace - _P.sdwidth) / 2 + _P.sdwidth + (currentfingers + device.fingers) * (_P.gatelength + _P.gatespace),
                            rowheights[rownum] - device.connectextrasourcespace
                        )
                    )
                    cell:add_area_anchor_bltr(string.format("%sextrasourcestrap", device.name),
                        point.create(
                            _P.gatelength + (_P.gatespace - _P.sdwidth) / 2 - _P.sdwidth + currentfingers * (_P.gatelength + _P.gatespace) + _P.sdwidth,
                            rowheights[rownum] - device.connectextrasourcespace - device.connectextrasourcewidth
                        ),
                        point.create(
                            _P.gatelength + (_P.gatespace - _P.sdwidth) / 2 + _P.sdwidth + (currentfingers + device.fingers) * (_P.gatelength + _P.gatespace),
                            rowheights[rownum] - device.connectextrasourcespace
                        )
                    )
                end
            end
            if device.connectextradrain then
                if (row.channeltype == "nmos" and not device.connectdraininverse) or (row.channeltype == "pmos" and device.connectdraininverse) then
                    geometry.rectanglebltr(cell, generics.metal(device.drainmetal or 1),
                        point.create(
                            (currentfingers + 1) * (_P.gatelength + _P.gatespace) + _P.gatelength + (_P.gatespace - _P.sdwidth) / 2,
                            rowheights[rownum] - device.connectextradrainspace - device.connectextradrainwidth
                        ),
                        point.create(
                            (currentfingers + device.fingers) * (_P.gatelength + _P.gatespace) - (_P.gatespace - _P.sdwidth) / 2,
                            rowheights[rownum] - device.connectextradrainspace
                        )
                    )
                    cell:add_area_anchor_bltr(string.format("%sextradrainstrap", device.name),
                        point.create(
                            (currentfingers + 1) * (_P.gatelength + _P.gatespace) + _P.gatelength + (_P.gatespace - _P.sdwidth) / 2,
                            rowheights[rownum] - device.connectextradrainspace - device.connectextradrainwidth
                        ),
                        point.create(
                            (currentfingers + device.fingers) * (_P.gatelength + _P.gatespace) - (_P.gatespace - _P.sdwidth) / 2,
                            rowheights[rownum] - device.connectextradrainspace
                        )
                    )
                else
                    geometry.rectanglebltr(cell, generics.metal(device.drainmetal or 1),
                        point.create(
                            (currentfingers + 1) * (_P.gatelength + _P.gatespace) + _P.gatelength + (_P.gatespace - _P.sdwidth) / 2,
                            rowheights[rownum] + row.width + device.connectextradrainspace
                        ),
                        point.create(
                            (currentfingers + device.fingers) * (_P.gatelength + _P.gatespace) - (_P.gatespace - _P.sdwidth) / 2,
                            rowheights[rownum] + row.width + device.connectextradrainspace + device.connectextradrainwidth
                        )
                    )
                    cell:add_area_anchor_bltr(string.format("%sextradrainstrap", device.name),
                        point.create(
                            (currentfingers + 1) * (_P.gatelength + _P.gatespace) + _P.gatelength + (_P.gatespace - _P.sdwidth) / 2,
                            rowheights[rownum] + row.width + device.connectextradrainspace
                        ),
                        point.create(
                            (currentfingers + device.fingers) * (_P.gatelength + _P.gatespace) - (_P.gatespace - _P.sdwidth) / 2,
                            rowheights[rownum] + row.width + device.connectextradrainspace + device.connectextradrainwidth
                        )
                    )
                end
            end

            -- gate contacts and straps
            -- top gate
            if device.drawtopgate then
                for i = 1, device.fingers do
                    geometry.contactbltr(cell, "gate",
                        point.create(
                            xpitch + (currentfingers + i - 1) * (_P.gatelength + _P.gatespace),
                            rowheights[rownum] + row.width + device.topgatespace
                        ),
                        point.create(
                            xpitch + (currentfingers + i - 1) * (_P.gatelength + _P.gatespace) + _P.gatelength,
                            rowheights[rownum] + row.width + device.topgatespace + device.topgatewidth
                        )
                    )
                end
                if device.topgatemetal and device.topgatemetal > 1 then
                    geometry.viabltr(cell, 1, device.topgatemetal,
                        point.create(
                            xpitch + currentfingers * (_P.gatelength + _P.gatespace) - (device.topgateleftextension or 0),
                            rowheights[rownum] + row.width + device.topgatespace
                        ),
                        point.create(
                            xpitch + (currentfingers + device.fingers) * (_P.gatelength + _P.gatespace) - _P.gatespace + (device.topgaterightextension or 0),
                            rowheights[rownum] + row.width + device.topgatespace + device.topgatewidth
                        )
                    )
                else
                    geometry.rectanglebltr(cell, generics.metal(1),
                        point.create(
                            xpitch + currentfingers * (_P.gatelength + _P.gatespace) - (device.topgateleftextension or 0),
                            rowheights[rownum] + row.width + device.topgatespace
                        ),
                        point.create(
                            xpitch + (currentfingers + device.fingers) * (_P.gatelength + _P.gatespace) - _P.gatespace + (device.topgaterightextension or 0),
                            rowheights[rownum] + row.width + device.topgatespace + device.topgatewidth
                        )
                    )
                end
                cell:add_area_anchor_bltr(string.format("%stopgate", device.name),
                    point.create(
                        xpitch + currentfingers * (_P.gatelength + _P.gatespace) - (device.topgateleftextension or 0),
                        rowheights[rownum] + row.width + device.topgatespace
                    ),
                    point.create(
                        xpitch + (currentfingers + device.fingers) * (_P.gatelength + _P.gatespace) - _P.gatespace + (device.topgaterightextension or 0),
                        rowheights[rownum] + row.width + device.topgatespace + device.topgatewidth
                    )
                )
            end

            -- bottom gate
            if device.drawbotgate then
                for i = 1, device.fingers do
                    geometry.contactbltr(cell, "gate",
                        point.create(
                            xpitch + (currentfingers + i - 1) * (_P.gatelength + _P.gatespace),
                            rowheights[rownum] - device.botgatespace - device.botgatewidth
                        ),
                        point.create(
                            xpitch + (currentfingers + i - 1) * (_P.gatelength + _P.gatespace) + _P.gatelength,
                            rowheights[rownum] - device.botgatespace
                        )
                    )
                end
                if device.botgatemetal and device.botgatemetal > 1 then
                    geometry.viabltr(cell, 1, device.botgatemetal,
                        point.create(
                            xpitch + currentfingers * (_P.gatelength + _P.gatespace) - (device.botgateleftextension or 0),
                            rowheights[rownum] - device.botgatespace - device.botgatewidth
                        ),
                        point.create(
                            xpitch + (currentfingers + device.fingers) * (_P.gatelength + _P.gatespace) - _P.gatespace + (device.botgaterightextension or 0),
                            rowheights[rownum] - device.botgatespace
                        )
                    )
                else
                    geometry.rectanglebltr(cell, generics.metal(1),
                        point.create(
                            xpitch + currentfingers * (_P.gatelength + _P.gatespace) - (device.botgateleftextension or 0),
                            rowheights[rownum] - device.botgatespace - device.botgatewidth
                        ),
                        point.create(
                            xpitch + (currentfingers + device.fingers) * (_P.gatelength + _P.gatespace) - _P.gatespace + (device.botgaterightextension or 0),
                            rowheights[rownum] - device.botgatespace
                        )
                    )
                end
                cell:add_area_anchor_bltr(string.format("%stopgate", device.name),
                    point.create(
                        xpitch + currentfingers * (_P.gatelength + _P.gatespace) - (device.botgateleftextension or 0),
                        rowheights[rownum] - device.botgatespace - device.botgatewidth
                    ),
                    point.create(
                        xpitch + (currentfingers + device.fingers) * (_P.gatelength + _P.gatespace) - _P.gatespace + (device.botgaterightextension or 0),
                        rowheights[rownum] - device.botgatespace
                    )
                )
            end

            -- top gate cut
            if device.drawtopgatecut then
                geometry.rectanglebltr(cell, generics.other("gatecut"),
                    point.create(
                        xpitch + currentfingers * (_P.gatelength + _P.gatespace) - _P.gatespace / 2,
                        rowheights[rownum] + row.width + device.topgatecutspace
                    ),
                    point.create(
                        xpitch + (currentfingers + device.fingers) * (_P.gatelength + _P.gatespace) - _P.gatespace + _P.gatespace / 2,
                        rowheights[rownum] + row.width + device.topgatecutspace + device.topgatecutwidth
                    )
                )
            end

            -- bottom gate cut
            if device.drawbotgatecut then
                geometry.rectanglebltr(cell, generics.other("gatecut"),
                    point.create(
                        xpitch + currentfingers * (_P.gatelength + _P.gatespace) - _P.gatespace / 2,
                        rowheights[rownum] - device.botgatecutspace - device.botgatecutwidth
                    ),
                    point.create(
                        xpitch + (currentfingers + device.fingers) * (_P.gatelength + _P.gatespace) - _P.gatespace + _P.gatespace / 2,
                        rowheights[rownum] - device.botgatecutspace
                    )
                )
            end

            -- diode-connected
            if device.diodeconnected then
                if device.drawtopgate then
                    for finger = 2, device.fingers + 1, 2 do
                        geometry.rectanglebltr(cell, generics.metal(1),
                            point.create(
                                _P.gatelength + (_P.gatespace - _P.sdwidth) / 2 + (currentfingers + finger - 1) * (_P.gatelength + _P.gatespace),
                                rowheights[rownum] + row.width
                            ),
                            point.create(
                                _P.gatelength + (_P.gatespace - _P.sdwidth) / 2 + (currentfingers + finger - 1) * (_P.gatelength + _P.gatespace) + _P.sdwidth,
                                rowheights[rownum] + row.width + device.topgatespace
                            )
                        )
                    end
                end
                if device.drawbotgate then
                    for finger = 2, device.fingers + 1, 2 do
                        geometry.rectanglebltr(cell, generics.metal(1),
                            point.create(
                                _P.gatelength + (_P.gatespace - _P.sdwidth) / 2 + (currentfingers + finger - 1) * (_P.gatelength + _P.gatespace),
                                rowheights[rownum] - device.botgatespace
                            ),
                            point.create(
                                _P.gatelength + (_P.gatespace - _P.sdwidth) / 2 + (currentfingers + finger - 1) * (_P.gatelength + _P.gatespace) + _P.sdwidth,
                                rowheights[rownum]
                            )
                        )
                    end
                end
            end

            -- update fingers
            currentfingers = currentfingers + device.fingers
        end
    end

    -- power bars
    if _P.powermetal > 1 then
        geometry.viabltr(cell, 1, _P.powermetal,
            point.create(0, -_P.powerwidth - _P.powerspace),
            point.create(totalwidth, -_P.powerspace)
        )
        geometry.viabltr(cell, 1, _P.powermetal,
            point.create(0, totalheight + _P.powerspace),
            point.create(totalwidth, totalheight + _P.powerspace + _P.powerwidth)
        )
    else
        geometry.rectanglebltr(cell, generics.metal(1),
            point.create(0, -_P.powerwidth - _P.powerspace),
            point.create(totalwidth, -_P.powerspace)
        )
        geometry.rectanglebltr(cell, generics.metal(1),
            point.create(0, totalheight + _P.powerspace),
            point.create(totalwidth, totalheight + _P.powerspace + _P.powerwidth)
        )
    end
    cell:add_area_anchor_bltr("lowerpowerrail",
        point.create(0, -_P.powerwidth - _P.powerspace),
        point.create(totalwidth, -_P.powerspace)
    )
    cell:add_area_anchor_bltr("upperpowerrail",
        point.create(0, totalheight + _P.powerspace),
        point.create(totalwidth, totalheight + _P.powerspace + _P.powerwidth)
    )

    -- top/bottom gate cut
    if _P.drawtopgatecut then
        geometry.rectanglebltr(cell, generics.other("gatecut"),
            point.create(-_P.gatespace / 2, totalheight + _P.powerspace + (_P.powerwidth - _P.topgatecutwidth) / 2),
            point.create(totalwidth + _P.gatespace / 2, totalheight + _P.powerspace + (_P.powerwidth + _P.topgatecutwidth) / 2)
        )
    end
    if _P.drawbotgatecut then
        geometry.rectanglebltr(cell, generics.other("gatecut"),
            point.create(-_P.gatespace / 2, -_P.powerspace - (_P.powerwidth + _P.botgatecutwidth) / 2),
            point.create(totalwidth + _P.gatespace / 2, -_P.powerspace - (_P.powerwidth - _P.botgatecutwidth) / 2)
        )
    end

    -- left and right polylines
    local leftpolyoffset = 0 * (_P.gatelength + _P.gatespace)
    for _, polyline in ipairs(_P.leftpolylines) do
        if not polyline.length then
            cellerror("basic/stacked_mosfet_array: leftpolyline entry does not have a 'length' field")
        end
        if not polyline.space then
            cellerror("basic/stacked_mosfet_array: leftpolyline entry does not have a 'space' field")
        end
        geometry.rectanglebltr(cell, generics.other("gate"),
            point.create(leftpolyoffset - polyline.space - polyline.length, -_P.gatesbotextension),
            point.create(leftpolyoffset - polyline.space, totalheight + _P.gatestopextension)
        )
        leftpolyoffset = leftpolyoffset - polyline.length - polyline.space
    end
    local rightpolyoffset = (totalfingers + 1) * (_P.gatelength + _P.gatespace) + _P.gatelength
    for _, polyline in ipairs(_P.rightpolylines) do
        if not polyline.length then
            cellerror("basic/mosfet: rightpolyline entry does not have a 'length' field")
        end
        if not polyline.space then
            cellerror("basic/mosfet: rightpolyline entry does not have a 'space' field")
        end
        geometry.rectanglebltr(cell, generics.other("gate"),
            point.create(rightpolyoffset + polyline.space, -_P.gatesbotextension),
            point.create(rightpolyoffset + polyline.space + polyline.length, totalheight + _P.gatestopextension)
        )
        rightpolyoffset = rightpolyoffset + polyline.length + polyline.space
    end

    -- alignment box
    cell:set_alignment_box(
        point.create(
            _P.gatelength + (_P.gatespace - _P.sdwidth) / 2,
            -_P.powerwidth - _P.powerspace
        ),
        point.create(
            _P.gatelength + (_P.gatespace - _P.sdwidth) / 2 + totalfingers * (_P.gatelength + _P.gatespace) + _P.sdwidth,
            totalheight + _P.powerspace + _P.powerwidth
        ),
        point.create(
            _P.gatelength + (_P.gatespace - _P.sdwidth) / 2 + _P.sdwidth,
            -_P.powerspace
        ),
        point.create(
            _P.gatelength + (_P.gatespace - _P.sdwidth) / 2 + totalfingers * (_P.gatelength + _P.gatespace),
            totalheight + _P.powerspace
        )
    )
end

function parameters()
    pcell.add_parameters(
        { "gatelength", technology.get_dimension("Minimum Gate Length"), argtype = "integer" },
        { "gatespace", technology.get_dimension("Minimum Gate XSpace"), argtype = "integer" },
        { "rows", {} },
        { "sdwidth", technology.get_dimension("Minimum M1 Width") },
        { "gatestrapwidth", technology.get_dimension("Minimum M1 Width") },
        { "gatestrapspace", technology.get_dimension("Minimum M1 Space") },
        { "powerwidth", 200 },
        { "powerspace", 200 },
        { "separation", 0 }
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
            return false, string.format("rows don't have the same number of fingers (first row has %d fingers, %d. row has %d fingers", fingersperrow, i, rowfingers[i])
        end
    end

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
            end
            if device.connectsource then
                if not device.connectsourcewidth then
                    return false, string.format("device %d in row %d specified connectsource = true, but did not provide the strap width (connectsourcewidth)", devicenum, rownum)
                end
                if not device.connectsourcespace then
                    return false, string.format("device %d in row %d specified connectsource = true, but did not provide the strap spacing (connectsourcespace)", devicenum, rownum)
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
    for i = 1, totalfingers do
        geometry.rectanglebltr(cell, generics.other("gate"),
            point.create(i * (_P.gatelength + _P.gatespace), 0),
            point.create(i * (_P.gatelength + _P.gatespace) + _P.gatelength, totalheight)
        )
    end

    for rownum, row in ipairs(_P.rows) do
        -- active regions
        geometry.rectanglebltr(cell, generics.other("active"),
            point.create(0, rowheights[rownum]),
            point.create(totalwidth, rowheights[rownum] + row.width)
        )

        -- channeltype
        geometry.rectanglebltr(cell, generics.implant(row.channeltype),
            point.create(0, rowheights[rownum] - _P.separation / 2),
            point.create(totalwidth, rowheights[rownum] + row.width + _P.separation / 2)
        )

        -- vthtype
        geometry.rectanglebltr(cell, generics.vthtype(row.channeltype, row.vthtype),
            point.create(0, rowheights[rownum] - _P.separation / 2),
            point.create(totalwidth, rowheights[rownum] + row.width + _P.separation / 2)
        )

        -- source/drain contacts
        local currentfingers = 0
        for _, device in ipairs(row.devices) do
            for finger = 1, device.fingers + 1 do
                geometry.contactbltr(cell, "sourcedrain",
                    point.create(
                        _P.gatelength + (_P.gatespace - _P.sdwidth) / 2 + (currentfingers + finger - 1) * (_P.gatelength + _P.gatespace),
                        rowheights[rownum]
                    ),
                    point.create(
                        _P.gatelength + (_P.gatespace - _P.sdwidth) / 2 + (currentfingers + finger - 1) * (_P.gatelength + _P.gatespace) + _P.sdwidth,
                        rowheights[rownum] + row.width
                    )
                )
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
                if finger % 2 == 1 then
                    if device.sourcemetal and device.sourcemetal > 1 then
                        geometry.viabltr(cell, 1, device.sourcemetal,
                            point.create(_P.gatelength + (_P.gatespace - _P.sdwidth) / 2 + (currentfingers + finger - 1) * (_P.gatelength + _P.gatespace), rowheights[rownum]),
                            point.create(_P.gatelength + (_P.gatespace - _P.sdwidth) / 2 + (currentfingers + finger - 1) * (_P.gatelength + _P.gatespace) + _P.sdwidth, rowheights[rownum] + row.width)
                        )
                    end
                    if device.connectsource then
                        if device.connectsourceinverse then
                            -- wires
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
                            -- strap
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
                            -- wires
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
                            -- strap
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
                else
                    if device.drainmetal and device.drainmetal > 1 then
                        geometry.viabltr(cell, 1, device.drainmetal,
                            point.create(_P.gatelength + (_P.gatespace - _P.sdwidth) / 2 + (currentfingers + finger - 1) * (_P.gatelength + _P.gatespace), rowheights[rownum]),
                            point.create(_P.gatelength + (_P.gatespace - _P.sdwidth) / 2 + (currentfingers + finger - 1) * (_P.gatelength + _P.gatespace) + _P.sdwidth, rowheights[rownum] + row.width)
                        )
                    end
                    if device.connectdrain then
                        if device.connectdraininverse then
                            -- wires
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
                            -- strap
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
                            -- wires
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
                            -- strap
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
                geometry.rectanglebltr(cell, generics.metal(1),
                    point.create(
                        xpitch + currentfingers * (_P.gatelength + _P.gatespace),
                        rowheights[rownum] + row.width + device.topgatespace
                    ),
                    point.create(
                        xpitch + (currentfingers + device.fingers) * (_P.gatelength + _P.gatespace) - _P.gatespace,
                        rowheights[rownum] + row.width + device.topgatespace + device.topgatewidth
                    )
                )
                cell:add_area_anchor_bltr(string.format("%stopgate", device.name),
                    point.create(
                        xpitch + currentfingers * (_P.gatelength + _P.gatespace),
                        rowheights[rownum] + row.width + device.topgatespace
                    ),
                    point.create(
                        xpitch + (currentfingers + device.fingers) * (_P.gatelength + _P.gatespace) - _P.gatespace,
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
                geometry.rectanglebltr(cell, generics.metal(1),
                    point.create(
                        xpitch + currentfingers * (_P.gatelength + _P.gatespace),
                        rowheights[rownum] - device.botgatespace - device.botgatewidth
                    ),
                    point.create(
                        xpitch + (currentfingers + device.fingers) * (_P.gatelength + _P.gatespace) - _P.gatespace,
                        rowheights[rownum] - device.botgatespace
                    )
                )
                cell:add_area_anchor_bltr(string.format("%stopgate", device.name),
                    point.create(
                        xpitch + currentfingers * (_P.gatelength + _P.gatespace),
                        rowheights[rownum] - device.botgatespace - device.botgatewidth
                    ),
                    point.create(
                        xpitch + (currentfingers + device.fingers) * (_P.gatelength + _P.gatespace) - _P.gatespace,
                        rowheights[rownum] - device.botgatespace
                    )
                )
            end

            -- top gate cut
            if device.drawtopgatecut then
                geometry.rectanglebltr(cell, generics.other("gatecut"),
                    point.create(
                        xpitch + currentfingers * (_P.gatelength + _P.gatespace),
                        rowheights[rownum] + row.width + device.topgatecutspace
                    ),
                    point.create(
                        xpitch + (currentfingers + device.fingers) * (_P.gatelength + _P.gatespace) - _P.gatespace,
                        rowheights[rownum] + row.width + device.topgatecutspace + device.topgatecutwidth
                    )
                )
            end

            -- bottom gate cut
            if device.drawbotgatecut then
                geometry.rectanglebltr(cell, generics.other("gatecut"),
                    point.create(
                        xpitch + currentfingers * (_P.gatelength + _P.gatespace),
                        rowheights[rownum] - _P.separation - device.botgatecutspace - device.botgatecutwidth
                    ),
                    point.create(
                        xpitch + (currentfingers + device.fingers) * (_P.gatelength + _P.gatespace) - _P.gatespace,
                        rowheights[rownum] - _P.separation - device.botgatecutspace
                    )
                )
            end

            -- update fingers
            currentfingers = currentfingers + device.fingers
        end
    end

    -- power bars
    geometry.rectanglebltr(cell, generics.metal(1),
        point.create(0, -_P.powerwidth - _P.powerspace),
        point.create(totalwidth, -_P.powerspace)
    )
    geometry.rectanglebltr(cell, generics.metal(1),
        point.create(0, totalheight + _P.powerspace),
        point.create(totalwidth, totalheight + _P.powerspace + _P.powerwidth)
    )

    -- alignment box
    -- FIXME: better align at the power rails
    cell:set_alignment_box(
        point.create(
            _P.gatelength + (_P.gatespace - _P.sdwidth) / 2,
            0
        ),
        point.create(
            _P.gatelength + (_P.gatespace - _P.sdwidth) / 2 + totalfingers * (_P.gatelength + _P.gatespace) + _P.sdwidth,
            rowheights[#_P.rows] + _P.rows[#_P.rows].width
        ),
        point.create(
            _P.gatelength + (_P.gatespace - _P.sdwidth) / 2 + _P.sdwidth,
            0
        ),
        point.create(
            _P.gatelength + (_P.gatespace - _P.sdwidth) / 2 + totalfingers * (_P.gatelength + _P.gatespace),
            rowheights[#_P.rows] + _P.rows[#_P.rows].width
        )
    )
end

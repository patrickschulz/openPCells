function parameters()
    pcell.add_parameters(
        { "gatelength", 40 },
        { "gatespace", 100 },
        { "gatetracks", 3 },
        { "rows", {} },
        { "sdwidth", 60 },
        { "gatestrapwidth", 60 },
        { "gatestrapspace", 60 },
        { "powerwidth", 200 },
        { "powerspace", 200 }
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
        end
    end
    return true
end

function layout(cell, _P)
    local sourcestrapwidth = 80
    -- derived parameters
    local separation = _P.gatetracks * _P.gatestrapwidth + (_P.gatetracks + 1) * _P.gatestrapspace

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
    totalheight = totalheight + (#_P.rows - 1) * separation

    -- cumulative row heights
    local rowheights = {}
    for i = 1, #_P.rows do
        local row = _P.rows[i]
        if i == 1 then
            rowheights[i] = 0
        end
        rowheights[i + 1] = rowheights[i] + row.width + separation
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
            point.create(0, rowheights[rownum] - separation / 2),
            point.create(totalwidth, rowheights[rownum] + row.width + separation / 2)
        )

        -- vthtype
        geometry.rectanglebltr(cell, generics.vthtype(row.channeltype, row.vthtype),
            point.create(0, rowheights[rownum] - separation / 2),
            point.create(totalwidth, rowheights[rownum] + row.width + separation / 2)
        )

        -- source/drain contacts
        local currentfingers = 0
        for _, device in ipairs(row.devices) do
            for finger = 1, device.fingers + 1 do
                geometry.contactbltr(cell, "sourcedrain",
                    point.create(_P.gatelength + (_P.gatespace - _P.sdwidth) / 2 + (currentfingers + finger - 1) * (_P.gatelength + _P.gatespace), rowheights[rownum]),
                    point.create(_P.gatelength + (_P.gatespace - _P.sdwidth) / 2 + (currentfingers + finger - 1) * (_P.gatelength + _P.gatespace) + _P.sdwidth, rowheights[rownum] + row.width)
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
                            geometry.rectanglebltr(cell, generics.metal(device.drainmetal),
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
                        else
                            -- wires
                            geometry.rectanglebltr(cell, generics.metal(device.drainmetal),
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
                            rowheights[rownum] + row.width + _P.gatestrapspace + (device.topgatetrack - 1) * (_P.gatestrapwidth + _P.gatestrapspace)
                        ),
                        point.create(
                            xpitch + (currentfingers + i - 1) * (_P.gatelength + _P.gatespace) + _P.gatelength,
                            rowheights[rownum] + row.width + device.topgatetrack * (_P.gatestrapwidth + _P.gatestrapspace)
                        )
                    )
                end
                geometry.rectanglebltr(cell, generics.metal(1),
                    point.create(
                        xpitch + currentfingers * (_P.gatelength + _P.gatespace),
                        rowheights[rownum] + row.width + _P.gatestrapspace + (device.topgatetrack - 1) * (_P.gatestrapwidth + _P.gatestrapspace)
                    ),
                    point.create(
                        xpitch + (currentfingers + device.fingers) * (_P.gatelength + _P.gatespace) - _P.gatespace,
                        rowheights[rownum] + row.width + device.topgatetrack * (_P.gatestrapwidth + _P.gatestrapspace)
                    )
                )
            end

            -- bottom gate
            if device.drawbotgate then
                for i = 1, device.fingers do
                    geometry.contactbltr(cell, "gate",
                        point.create(
                            xpitch + (currentfingers + i - 1) * (_P.gatelength + _P.gatespace),
                            rowheights[rownum] - separation + _P.gatestrapspace + (device.botgatetrack - 1) * (_P.gatestrapwidth + _P.gatestrapspace)
                        ),
                        point.create(
                            xpitch + (currentfingers + i - 1) * (_P.gatelength + _P.gatespace) + _P.gatelength,
                            rowheights[rownum] - separation + device.botgatetrack * (_P.gatestrapwidth + _P.gatestrapspace)
                        )
                    )
                end
                geometry.rectanglebltr(cell, generics.metal(1),
                    point.create(
                        xpitch + currentfingers * (_P.gatelength + _P.gatespace),
                        rowheights[rownum] - separation + _P.gatestrapspace + (device.botgatetrack - 1) * (_P.gatestrapwidth + _P.gatestrapspace)
                    ),
                    point.create(
                        xpitch + (currentfingers + device.fingers) * (_P.gatelength + _P.gatespace) - _P.gatespace,
                        rowheights[rownum] - separation + device.botgatetrack * (_P.gatestrapwidth + _P.gatestrapspace)
                    )
                )
            end

            -- top gate cut
            if device.drawtopgatecut then
                geometry.rectanglebltr(cell, generics.other("gatecut"),
                    point.create(
                        xpitch + currentfingers * (_P.gatelength + _P.gatespace),
                        rowheights[rownum] + row.width + _P.gatestrapspace + (device.topgatecuttrack - 1) * (_P.gatestrapwidth + _P.gatestrapspace)
                    ),
                    point.create(
                        xpitch + (currentfingers + device.fingers) * (_P.gatelength + _P.gatespace) - _P.gatespace,
                        rowheights[rownum] + row.width + device.topgatecuttrack * (_P.gatestrapwidth + _P.gatestrapspace)
                    )
                )
            end

            -- bottom gate cut
            if device.drawbotgatecut then
                geometry.rectanglebltr(cell, generics.other("gatecut"),
                    point.create(
                        xpitch + currentfingers * (_P.gatelength + _P.gatespace),
                        rowheights[rownum] - separation + _P.gatestrapspace + (device.botgatecuttrack - 1) * (_P.gatestrapwidth + _P.gatestrapspace)
                    ),
                    point.create(
                        xpitch + (currentfingers + device.fingers) * (_P.gatelength + _P.gatespace) - _P.gatespace,
                        rowheights[rownum] - separation + device.botgatecuttrack * (_P.gatestrapwidth + _P.gatestrapspace)
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
end

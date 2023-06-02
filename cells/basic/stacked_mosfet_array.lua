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
    return true
end

function layout(cell, _P)
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

    for rownum, row in ipairs(_P.rows) do
        -- active regions
        geometry.rectanglebltr(cell, generics.other("active"),
            point.create(0, rowheights[rownum]),
            point.create(totalwidth, rowheights[rownum] + row.width)
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
                        local straptrack = 2
                        geometry.rectanglebltr(cell, generics.metal(device.sourcemetal),
                            point.create(
                                _P.gatelength + (_P.gatespace - _P.sdwidth) / 2 + (currentfingers + finger - 1) * (_P.gatelength + _P.gatespace),
                                rowheights[rownum] - separation + _P.gatestrapspace + (straptrack - 1) * (_P.gatestrapwidth + _P.gatestrapspace)
                            ),
                            point.create(
                                _P.gatelength + (_P.gatespace - _P.sdwidth) / 2 + (currentfingers + finger - 1) * (_P.gatelength + _P.gatespace) + _P.sdwidth,
                                rowheights[rownum]
                            )
                        )
                    end
                else
                    if device.drainmetal and device.drainmetal > 1 then
                        geometry.viabltr(cell, 1, device.drainmetal,
                            point.create(_P.gatelength + (_P.gatespace - _P.sdwidth) / 2 + (currentfingers + finger - 1) * (_P.gatelength + _P.gatespace), rowheights[rownum]),
                            point.create(_P.gatelength + (_P.gatespace - _P.sdwidth) / 2 + (currentfingers + finger - 1) * (_P.gatelength + _P.gatespace) + _P.sdwidth, rowheights[rownum] + row.width)
                        )
                    end
                    if device.connectdrain then
                        local straptrack = 2
                        geometry.rectanglebltr(cell, generics.metal(device.drainmetal),
                            point.create(
                                _P.gatelength + (_P.gatespace - _P.sdwidth) / 2 + (currentfingers + finger - 1) * (_P.gatelength + _P.gatespace),
                                rowheights[rownum] + row.width
                            ),
                            point.create(
                                _P.gatelength + (_P.gatespace - _P.sdwidth) / 2 + (currentfingers + finger - 1) * (_P.gatelength + _P.gatespace) + _P.sdwidth,
                                rowheights[rownum] + row.width + _P.gatestrapspace + (straptrack - 1) * (_P.gatestrapwidth + _P.gatestrapspace)
                            )
                        )
                    end
                end
            end

            -- source/drain straps
            if device.drawsourcestrap then
                local straptrack = 2
                geometry.rectanglebltr(cell, generics.metal(device.sourcemetal or 1),
                    point.create(
                        _P.gatelength + (_P.gatespace - _P.sdwidth) / 2 + currentfingers * (_P.gatelength + _P.gatespace) + _P.sdwidth,
                        rowheights[rownum] - separation + _P.gatestrapspace + (straptrack - 1) * (_P.gatestrapwidth + _P.gatestrapspace)
                    ),
                    point.create(
                        _P.gatelength + (_P.gatespace - _P.sdwidth) / 2 + (currentfingers + device.fingers) * (_P.gatelength + _P.gatespace),
                        rowheights[rownum] - separation + straptrack * (_P.gatestrapwidth + _P.gatestrapspace)
                    )
                )
            end

            if device.drawdrainstrap then
                local straptrack = 2
                geometry.rectanglebltr(cell, generics.metal(device.drainmetal or 1),
                    point.create(
                        (currentfingers + 1) * (_P.gatelength + _P.gatespace) + _P.gatelength + (_P.gatespace - _P.sdwidth) / 2,
                        rowheights[rownum] + row.width + _P.gatestrapspace + (straptrack - 1) * (_P.gatestrapwidth + _P.gatestrapspace)
                    ),
                    point.create(
                        (currentfingers + device.fingers) * (_P.gatelength + _P.gatespace) - (_P.gatespace - _P.sdwidth) / 2,
                        rowheights[rownum] + row.width + straptrack * (_P.gatestrapwidth + _P.gatestrapspace)
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

    -- gates
    for i = 1, totalfingers do
        geometry.rectanglebltr(cell, generics.other("gate"),
            point.create(i * (_P.gatelength + _P.gatespace), 0),
            point.create(i * (_P.gatelength + _P.gatespace) + _P.gatelength, totalheight)
        )
    end

    -- gate contacts and straps
    for rownum, row in ipairs(_P.rows) do
        local currentfingers = 0
        for _, device in ipairs(row.devices) do
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
            currentfingers = currentfingers + device.fingers
        end
    end
end

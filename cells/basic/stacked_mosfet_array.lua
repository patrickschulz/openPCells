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
        { "drawtoppowerrail", true },
        { "drawbotpowerrail", true },
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
    --for i = 2, #rowfingers do
    --    if fingersperrow ~= rowfingers[i] then
    --        return false, string.format("rows don't have the same number of fingers (first row has %d fingers, %d. row has %d fingers)", fingersperrow, i, rowfingers[i])
    --    end
    --end

    local names = {}
    for rownum, row in ipairs(_P.rows) do
        if not row.channeltype then
            return false, string.format("row %d does not have a channeltype", rownum)
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
        end
    end
    return true
end

local function _select_parameter(name, devparam, rowparam, cellparam)
    if devparam[name] == nil then
        if rowparam[name] == nil then
            return cellparam and cellparam[name]
        else
            return rowparam[name]
        end
    else
        return devparam[name]
    end
end

function layout(cell, _P)
    local lastpoint = point.create(0, 0)
    local lastmosfet = nil
    for rownum, row in ipairs(_P.rows) do
        local activebl, activetr
        for devnum, device in ipairs(row.devices) do
            local mosfet = pcell.create_layout("basic/mosfet", device.name, {
                channeltype = row.channeltype,
                flippedwell = row.flippedwell,
                gatelength = row.gatelength,
                gatespace = row.gatespace,
                fwidth = row.width,
                fingers = device.fingers,
                gtopext = _select_parameter("gtopext", device, row),
                gbotext = _select_parameter("gbotext", device, row),
                sdwidth = _select_parameter("sdwidth", device, row, _P),
                connectsource = _select_parameter("connectsource", device, row),
                connectsourceinverse = _select_parameter("connectsourceinverse", device, row),
                connectsourceboth = _select_parameter("connectsourceboth", device, row),
                connectsourcewidth = _select_parameter("connectsourcewidth", device, row),
                connectsourcespace = _select_parameter("connectsourcespace", device, row),
                connectsourceleftext = _select_parameter("connectsourceleftext", device, row),
                connectsourcerightext = _select_parameter("connectsourcerightext", device, row),
                connectsourceotherwidth = _select_parameter("connectsourceotherwidth", device, row),
                connectsourceotherspace = _select_parameter("connectsourceotherspace", device, row),
                sourcemetal = _select_parameter("sourcemetal", device, row),
                connectdrain = _select_parameter("connectdrain", device, row),
                connectdraininverse = _select_parameter("connectdraininverse", device, row),
                connectdrainboth = _select_parameter("connectdrainboth", device, row),
                connectdrainwidth = _select_parameter("connectdrainwidth", device, row),
                connectdrainspace = _select_parameter("connectdrainspace", device, row),
                connectdrainleftext = _select_parameter("connectdrainleftext", device, row),
                connectdrainrightext = _select_parameter("connectdrainrightext", device, row),
                connectdrainotherwidth = _select_parameter("connectdrainotherwidth", device, row),
                connectdrainotherspace = _select_parameter("connectdrainotherspace", device, row),
                drainmetal = _select_parameter("drainmetal", device, row),
                drawtopgate = _select_parameter("drawtopgate", device, row),
                topgatewidth = _select_parameter("topgatewidth", device, row),
                topgatespace = _select_parameter("topgatespace", device, row),
                drawbotgate = _select_parameter("drawbotgate", device, row),
                botgatewidth = _select_parameter("botgatewidth", device, row),
                botgatespace = _select_parameter("botgatespace", device, row),
                diodeconnected = _select_parameter("diodeconnected", device, row),
                shortdevice = _select_parameter("shortdevice", device, row),
                shortdeviceleftoffset = _select_parameter("shortdeviceleftoffset", device, row),
                shortdevicerightoffset = _select_parameter("shortdevicerightoffset", device, row),
            })
            if not lastmosfet then -- first mosfet in row
                mosfet:move_point(mosfet:get_area_anchor("active").bl, lastpoint)
                lastpoint = mosfet:get_area_anchor("active").tl
            else
                mosfet:align_bottom(lastmosfet)
                mosfet:abut_right(lastmosfet)
            end
            lastmosfet = mosfet
            cell:merge_into(mosfet)
            cell:inherit_alignment_box(mosfet)
            cell:inherit_all_anchors_with_prefix(mosfet, device.name .. "_")
            if devnum == 1 then
                activebl = mosfet:get_area_anchor("active").bl
            end
            if devnum == #row.devices then
                activetr = mosfet:get_area_anchor("active").tr
            end
        end
        cell:add_area_anchor_bltr(string.format("active_%d", rownum), activebl, activetr)
        lastpoint:translate_y(_P.separation)
        lastmosfet = nil
    end
end

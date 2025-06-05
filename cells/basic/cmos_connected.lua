function layout(cell, _P)
    local netdef = { "vss", "net1", "net2", "net1", "net1", "net2", "net3", "net3", "net2" }

    local ncontactpos = util.fill_all_with(9, "full")

    local cmos = pcell.create_layout("basic/cmos", "_cmos", {
        gatecontactpos = { "center", "center", "center", "center", "center", "dummy", "lower1", "split_pmosdummy" },
        pcontactpos = { "full", "full", "full", "full", "full", "full", "full", "full", "full" },
        ncontactpos = ncontactpos,
        oxidetype = 1,
        pvthtype = 1,
        nvthtype = 1,
        pwidth = 800,
        nwidth = 600,
        innergatestraps = 3,
        gatelength = 100,
        gatespace = 150,
        separationautocalc = true, -- use 'false' and separation = ... for explicit values
        sdwidth = 80,
        innergatestraps = 3,
        gatestrapwidth = 80,
        gatestrapspace = 80,
        gatecontactsplitshift = 0,
        powerwidth = 200,
        npowerspace = 100,
        ppowerspace = 100,
        pgateext = 200 + 100,
        ngateext = 200 + 100,
        -- well, implant, oxidetypemarker...
        extendalltop = 200,
        extendallbottom = 200,
        extendallleft = 200,
        extendallright = 200,
    })
    cell:merge_into(cmos)

    local connections = {}
    local netmap = {}
    local ignored_nets = { "vss" }
    for sdpos, net in ipairs(netdef) do
        if not util.any_of(net, ignored_nets) then
            if not netmap[net] then
                netmap[net] = #connections + 1
                connections[#connections + 1] = {
                    net = net,
                    sourcedrain = {},
                    metal = 0, -- set properly later
                    width = 100,
                    space = 80,
                }
            end
            local index = netmap[net]
            table.insert(connections[index].sourcedrain, sdpos)
        end
    end
    -- set proper metal layers
    local function _crosses(c1, c2)
        if util.max(c1.sourcedrain) > util.min(c2.sourcedrain) or
           util.max(c2.sourcedrain) > util.min(c1.sourcedrain) then
           return true
        end
    end
    for i, connection in ipairs(connections) do
        local metal = 2
        if connection.metal == 0 then
            for j = 1, #connections do
                if j ~= i then
                    local oc = connections[j]
                    if _crosses(connection, oc) then
                        if oc.metal ~= 0 then
                            metal = oc.metal + 1
                        end
                    end
                end
            end
            connection.metal = metal
        end
    end
    for _, connection in ipairs(connections) do
        geometry.rectanglebltr(cell, generics.metal(connection.metal),
            cmos:get_area_anchor_fmt("nSD%d", util.min(connection.sourcedrain)).bl:translate_y(-connection.space - connection.width),
            cmos:get_area_anchor_fmt("nSD%d", util.max(connection.sourcedrain)).br:translate_y(-connection.space)
        )
        for _, sd in ipairs(connection.sourcedrain) do
            geometry.viabltr(cell, 1, connection.metal,
                cmos:get_area_anchor_fmt("nSD%d", sd).bl,
                cmos:get_area_anchor_fmt("nSD%d", sd).tr
            )
            geometry.rectanglebltr(cell, generics.metal(connection.metal),
                cmos:get_area_anchor_fmt("nSD%d", sd).bl:translate_y(-connection.space),
                cmos:get_area_anchor_fmt("nSD%d", sd).br
            )
        end
    end
end

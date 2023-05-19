function parameters()
    pcell.add_parameters(
        { "numlanes", 64 },
        { "bitsperlane", 32 },
        { "bitresolution", 8 }
    )
end

function layout(memory, _P)
    local dffpref = pcell.create_layout("stdcells/dff", "dffp", { clockpolarity = "positive" })
    local dffnref = pcell.create_layout("stdcells/dff", "dffn", { clockpolarity = "negative" })
    local laneref = object.create("lane")
    local dffs = {}
    for j = 1, _P.bitresolution do
        for k = 1, _P.bitsperlane do
            local dff = laneref:add_child((k % 2 == 1) and dffpref or dffnref, string.format("dff_%d_%d", j, k))
            if k > 1 then
                dff:move_anchor("left", dffs[(j - 1) * _P.bitsperlane + k - 1]:get_anchor("right"))
            elseif j > 1 then
                dff:move_anchor("bottom", dffs[(j - 2) * _P.bitsperlane + 1]:get_anchor("top"))
            end
            if j % 2 == 0 then
                dff:flipy()
            end
            dffs[(j - 1) * _P.bitsperlane + k] = dff
            -- connection to next dff
            if k > 1 then
                geometry.path(laneref, generics.metal(1), 
                    geometry.path_points_yx(dffs[(j - 1) * _P.bitsperlane + k - 1]:get_anchor("Q"), {
                        dffs[(j - 1) * _P.bitsperlane + k]:get_anchor("D")
                    }), 40
                )
            end
        end
        if _P.bitsperlane > 1 then
            geometry.path(laneref, generics.metal(3), {
                dffs[(j - 1) * _P.bitsperlane + 1]:get_anchor("CLK"),
                dffs[(j - 1) * _P.bitsperlane + _P.bitsperlane]:get_anchor("CLK")
            }, 40)
        end
        laneref:add_anchor("D", dffs[(j - 1) * _P.bitsperlane + 1]:get_anchor("D"))
    end
    laneref:set_alignment_box(
        dffs[1]:get_anchor("bottomleft"),
        dffs[_P.bitresolution * _P.bitsperlane]:get_anchor("topright")
    )

    local lanes = {}
    for i = 1, _P.numlanes do
        lanes[i] = memory:add_child(laneref, string.format("lane_%d", i))
        if i % 2 == 0 then 
            lanes[i]:flipy()
        end
        if i > 1 then
            lanes[i]:move_anchor("bottom", lanes[i - 1]:get_anchor("top"))
        end
    end
end

function parameters()
    pcell.add_parameters(
        { "numlanes", 64 },
        { "bitsperlane", 32 },
        { "bitresolution", 8 }
    )
end

function layout(memory, _P)
    local dffpref = pcell.create_layout("stdcells/dff", { clockpolarity = "positive" })
    local dffnref = pcell.create_layout("stdcells/dff", { clockpolarity = "negative" })
    local lane = object.create()
    local dffpname = pcell.add_cell_reference(dffpref, "dffp")
    local dffnname = pcell.add_cell_reference(dffnref, "dffn")
    local dffs = {}
    for j = 1, _P.bitresolution do
        for k = 1, _P.bitsperlane do
            local dff = lane:add_child((k % 2 == 1) and dffpname or dffnname)
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
                geometry.path(lane, generics.metal(1), 
                    geometry.path_points_yx(dffs[(j - 1) * _P.bitsperlane + k - 1]:get_anchor("Q"), {
                        dffs[(j - 1) * _P.bitsperlane + k]:get_anchor("D")
                    }), 40
                )
            end
        end
        geometry.path(lane, generics.metal(3), {
            dffs[(j - 1) * _P.bitsperlane + 1]:get_anchor("CLK"),
            dffs[(j - 1) * _P.bitsperlane + _P.bitsperlane]:get_anchor("CLK")
        }, 40)
        lane:add_anchor("D", dffs[(j - 1) * _P.bitsperlane + 1]:get_anchor("D"))
    end
    lane:set_alignment_box(
        dffs[1]:get_anchor("bottomleft"),
        dffs[_P.bitresolution * _P.bitsperlane]:get_anchor("topright")
    )

    local lanename = pcell.add_cell_reference(lane, "lane")
    local lanes = {}
    for i = 1, _P.numlanes do
        lanes[i] = memory:add_child(lanename)
        if i % 2 == 0 then 
            lanes[i]:flipy()
        end
        if i > 1 then
            lanes[i]:move_anchor("bottom", lanes[i - 1]:get_anchor("top"))
        end
    end
end

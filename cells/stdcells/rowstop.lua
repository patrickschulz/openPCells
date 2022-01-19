function parameters()
    pcell.reference_cell("basic/mosfet")
    pcell.reference_cell("stdcells/base")
    pcell.add_parameters(
        { "glengths", { 40, 40, 40, 40, 40 }, { argtype = "strtable" } },
        { "gspaces", { 90, 90, 90, 90, 90 }, { argtype = "strtable" } },
        { "splitgates", true }
    )
end

function layout(gate, _P)
    local tp = pcell.get_parameters("basic/mosfet")
    local bp = pcell.get_parameters("stdcells/base")
    pcell.push_overwrites("stdcells/base", { leftdummies = 0, rightdummies = 0 })
    local harness = pcell.create_layout("stdcells/harness", { 
        fingers = #_P.glengths,
        drawtransistors = false,
        drawgatecontacts = false,
    })
    pcell.pop_overwrites("stdcells/base")
    gate:merge_into_shallow(harness)
    gate:inherit_alignment_box(harness)

    local separation = bp.numinnerroutes * bp.gstwidth + (bp.numinnerroutes + 1) * bp.gstspace
    local height = bp.pwidth + bp.nwidth + separation + 2 * bp.powerspace + bp.powerwidth + 2 * math.max(tp.cutheight / 2 + bp.gateext, bp.dummycontheight / 2)
    local numgates = #_P.glengths
    local startx = gate:get_anchor("right"):getx() - (bp.glength + bp.gspace) / 2
    local correction = 0
    local shift = 0
    for i = 1, numgates do
        local gl = _P.glengths[i]
        if i > 1 then
            shift = shift + gl + _P.gspaces[i] - (_P.glengths[i] - _P.glengths[i - 1]) / 2
        end
        dprint(i, correction)
        -- gates
        gate:merge_into_shallow(geometry.rectangle(generics.other("gate"), gl, height)
            :translate(startx - shift, 0))
        -- tuck gate marking
        if i == 1 then
            if _P.splitgates then
                gate:merge_into_shallow(geometry.rectangle(generics.other("tuckgatemarker"), gl, height / 2 - tp.cutheight / 2)
                    :translate(startx, (height / 2 + tp.cutheight / 2) / 2))
                gate:merge_into_shallow(geometry.rectangle(generics.other("tuckgatemarker"), gl, height / 2 - tp.cutheight / 2)
                    :translate(startx, -(height / 2 + tp.cutheight / 2) / 2))
            else
                gate:merge_into_shallow(geometry.rectangle(generics.other("tuckgatemarker"), gl, height)
                    :translate(startx, 0))
            end
        end
    end

    -- implants
    gate:merge_into_shallow(geometry.rectanglebltr(generics.other("pimpl"), 
        gate:get_anchor("left"):translate(-200, 0), gate:get_anchor("topright"):translate(0, 200)))
    gate:merge_into_shallow(geometry.rectanglebltr(generics.other("nimpl"), 
        gate:get_anchor("bottomleft"):translate(-200, -200), gate:get_anchor("right")))

    -- gate cuts
    if _P.splitgates then
        gate:merge_into_shallow(geometry.rectangle(generics.other("gatecut"), bp.glength + bp.gspace, tp.cutheight)
            :translate(gate:get_anchor("right"):translate(-(bp.glength + bp.gspace) / 2, 0)))
    end
end

function parameters()
    pcell.reference_cell("basic/mosfet")
    pcell.reference_cell("stdcells/base")
    pcell.reference_cell("stdcells/harness")
    pcell.add_parameters(
        { "glengths", { 40, 40, 40, 40, 40 }, { argtype = "strtable" } },
        { "gspaces", { 90, 90, 90, 90, 90 }, { argtype = "strtable" } },
        { "splitgates", true }
    )
end

function layout(gate, _P)
    local tp = pcell.get_parameters("basic/mosfet")
    local bp = pcell.get_parameters("stdcells/base")
    pcell.push_overwrites("stdcells/harness", { leftdummies = 0, rightdummies = 0 })
    local gatecontactpos = {}
    for i = 1, #_P.glengths do
        gatecontactpos[i] = "unused"
    end
    local harness = pcell.create_layout("stdcells/harness", { 
        gatecontactpos = gatecontactpos,
        drawtransistors = false,
        drawgatecontacts = false,
    })
    pcell.pop_overwrites("stdcells/harness")
    gate:merge_into_shallow(harness)
    gate:inherit_alignment_box(harness)

    local separation = bp.numinnerroutes * bp.routingwidth + (bp.numinnerroutes + 1) * bp.routingspace
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
        geometry.rectanglebltr(
            gate, generics.other("gate"), 
            point.create(startx - shift - gl / 2, -height / 2),
            point.create(startx - shift + gl / 2,  height / 2)
        )
        -- tuck gate marking
        if i == 1 then
            if _P.splitgates then
                geometry.rectanglebltr(
                    gate, generics.other("tuckgatemarker"), 
                    point.create(startx - gl / 2, -(height / 2 + tp.cutheight / 2) / 2 - (height / 2 - tp.cutheight / 2) / 2),
                    point.create(startx + gl / 2,  (height / 2 + tp.cutheight / 2) / 2 + (height / 2 - tp.cutheight / 2) / 2)
                )
                geometry.rectanglebltr(
                    gate, generics.other("tuckgatemarker"), 
                    point.create(startx - gl / 2, -(height / 2 + tp.cutheight / 2) / 2 - (height / 2 - tp.cutheight / 2) / 2),
                    point.create(startx + gl / 2, -(height / 2 + tp.cutheight / 2) / 2 + (height / 2 - tp.cutheight / 2) / 2)
                )
            else
                geometry.rectanglebltr(
                    gate, generics.other("tuckgatemarker"), 
                    point.create(startx - gl / 2, -height / 2),
                    point.create(startx + gl / 2,  height / 2)
                )
            end
        end
    end

    -- implants
    geometry.rectanglebltr(
        gate, generics.implant("p"), 
        gate:get_anchor("left"):translate(-200, 0), 
        gate:get_anchor("topright"):translate(0, 200)
    )
    geometry.rectanglebltr(
        gate, generics.implant("n"), 
        gate:get_anchor("bottomleft"):translate(-200, -200), 
        gate:get_anchor("right")
    )

    -- gate cuts
    if _P.splitgates then
        geometry.rectanglebltr(
            gate, generics.other("gatecut"),
            gate:get_anchor("right"):translate(-(bp.glength + bp.gspace), -tp.cutheight / 2),
            gate:get_anchor("right"):translate(0,  tp.cutheight / 2)
        )
    end
end

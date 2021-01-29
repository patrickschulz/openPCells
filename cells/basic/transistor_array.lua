function parameters()
    pcell.add_parameters({ "fingers(Number of Fingers)", { 4, 4 }, argtype = "numtable" })
    pcell.reference_cell("basic/transistor")
end

function layout(array, _P)
    local bp = pcell.get_parameters("basic/transistor")

    local gatepitch = bp.gatelength + bp.gatespace
    local numtransistors = #_P.fingers
    local numfingers = aux.sum(_P.fingers)
    local gatestrspace = 200

    local ttypes = {}
    local indices = {}
    for i, f in ipairs(_P.fingers) do
        ttypes[i] = {
            topgatestrspace = i * gatestrspace + (i - 1) * bp.topgatestrwidth,
            botgatestrspace = i * gatestrspace + (i - 1) * bp.botgatestrwidth,
        }
        for _ = 1, f / 2 do
            table.insert(indices, i)
        end
    end
    aux.shuffle(indices)
    pcell.push_overwrites("basic/transistor", {
        fingers = 1,
        drawtopgate = true,
        drawbotgate = true,
        gtopext = numtransistors * (gatestrspace + bp.topgatestrwidth),
        gbotext = numtransistors * (gatestrspace + bp.botgatestrwidth),
    })
    for i = 1, #indices do
        local offset = (i - 1) - (2 * #indices - 1) / 2
        local ttype = ttypes[indices[i]]
        array:merge_into(
            pcell.create_layout("basic/transistor", ttype)
            :translate( offset * gatepitch, 0)
        )
        array:merge_into(
            pcell.create_layout("basic/transistor", ttype)
            :translate(-offset * gatepitch, 0)
        )
    end
    pcell.pop_overwrites("basic/transistor")

    -- gate connections
    for i = 1, #ttypes do
        array:merge_into(geometry.rectangle(
            generics.metal(1), numfingers * gatepitch, bp.topgatestrwidth
            ):translate(0, (bp.fwidth + bp.topgatestrwidth) / 2 + i * gatestrspace + (i - 1) * bp.topgatestrwidth)
        )
        array:merge_into(geometry.rectangle(
            generics.metal(1), numfingers * gatepitch, bp.topgatestrwidth
            ):translate(0, -(bp.fwidth + bp.botgatestrwidth) / 2 - i * gatestrspace - (i - 1) * bp.botgatestrwidth)
        )
    end
end

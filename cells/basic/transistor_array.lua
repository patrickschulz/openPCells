function parameters()
    pcell.add_parameters({ "fingers(Number of Fingers)", { 4, 4 }, argtype = "numtable" })
    pcell.inherit_and_bind_all_parameters("basic/transistor")
end

function layout(array, _P)
    local gatepitch = _P.gatelength + _P.gatespace
    local numtransistors = #_P.fingers
    local numfingers = aux.sum(_P.fingers)
    local gatestrspace = 200

    local ttypes = {}
    local indices = {}
    for i, f in ipairs(_P.fingers) do
        ttypes[i] = {
            topgatestrspace = i * gatestrspace + (i - 1) * _P.topgatestrwidth,
            botgatestrspace = i * gatestrspace + (i - 1) * _P.botgatestrwidth,
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
        gtopext = numtransistors * (gatestrspace + _P.topgatestrwidth),
        gbotext = numtransistors * (gatestrspace + _P.botgatestrwidth),
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
            generics.metal(1), numfingers * gatepitch, _P.topgatestrwidth
            ):translate(0, (_P.fwidth + _P.topgatestrwidth) / 2 + i * gatestrspace + (i - 1) * _P.topgatestrwidth)
        )
        array:merge_into(geometry.rectangle(
            generics.metal(1), numfingers * gatepitch, _P.topgatestrwidth
            ):translate(0, -(_P.fwidth + _P.botgatestrwidth) / 2 - i * gatestrspace - (i - 1) * _P.botgatestrwidth)
        )
    end
end

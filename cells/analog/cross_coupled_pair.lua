function parameters()
    pcell.add_parameters(
        { "connmetal", 4 },
        { "connwidth", 60 },
        { "centerdummies", 2 }
    )
end

function layout(ccp, _P)
    local baseopt = {
        fingers = 4,
        fingerwidth = 500,
        gatelength = 100,
        drawtopgate = true,
        topgatestrwidth = _P.connwidth,
        topgatemetal = 4,
        drawdrainvia = true,
        connectdrainmetal = 4,
        connectsource = true
    }

    -- create center dummy
    local dummy = pcell.create_layout("basic/mosfet", "dummymosfet", util.add_options(baseopt, {
        fingers = _P.centerdummies, drawtopgate = false, drawdrainvia = false
    }))
    ccp:merge_into(dummy)

    local left = pcell.create_layout("basic/mosfet", "leftmosfet", baseopt)
    left:align_left(dummy)
    local right = pcell.create_layout("basic/mosfet", "rightmosfet", baseopt)
    right:align_right(dummy)
    ccp:merge_into(left)
    ccp:merge_into(right)

    pcell.pop_overwrites("basic/mosfet")

    local leftgate = left:get_area_anchor("topgatestrap").bl
    local rightgate = right:get_area_anchor("topgatestrap").bl:translate(0, -200)
    --geometry.crossing(
    --    ccp, generics.metal(_P.connmetal), generics.metal(_P.connmetal - 1),
    --    _P.connwidth, leftgate, rightgate, "rectangular-separated", 200
    --)
end

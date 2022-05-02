function parameters()
    pcell.reference_cell("basic/mosfet")
    pcell.add_parameters(
        { "connmetal", 4 },
        { "connwidth", 60 },
        { "centerdummies", 2 }
    )
end

function layout(ccp, _P)
    local bp = pcell.get_parameters("basic/mosfet")
    pcell.push_overwrites("basic/mosfet", {
        fingers = 4,
        fwidth = 500,
        gatelength = 100,
        drawtopgate = true,
        topgatestrwidth = _P.connwidth,
        topgatemetal = 4,
        drawdrainvia = true,
        conndrainmetal = 4,
        connectsource = true
    })

    -- create center dummy
    local dummy = pcell.create_layout("basic/mosfet", { fingers = _P.centerdummies, drawtopgate = false, drawdrainvia = false })
    ccp:merge_into_shallow(dummy)

    local left = pcell.create_layout("basic/mosfet")
    left:move_anchor("sourcedrainmiddlecenterright", dummy:get_anchor("sourcedrainmiddlecenterleft"))
    local right = pcell.create_layout("basic/mosfet")
    right:move_anchor("sourcedrainmiddlecenterleft", dummy:get_anchor("sourcedrainmiddlecenterright"))
    ccp:merge_into_shallow(left)
    ccp:merge_into_shallow(right)

    pcell.pop_overwrites("basic/mosfet")

    local leftgate = left:get_anchor("topgatestrapright")
    local rightgate = right:get_anchor("topgatestrapleft"):copy():translate(0, -200)
    geometry.crossing(
        ccp, generics.metal(_P.connmetal), generics.metal(_P.connmetal - 1),
        _P.connwidth, leftgate, rightgate, "rectangular-separated", 200
    )
end

function parameters()
    --pcell.inherit_and_bind_all_parameters("basic/transistor")
    pcell.inherit_all_parameters("basic/transistor")
    pcell.add_parameters(
        { "connmetal", 4 },
        { "connwidth", 60 },
        { "centerdummies", 2 }
    )
end

function layout(ccp, _P)
    pcell.push_overwrites("basic/transistor", {
        fingers = 4,
        gatelength = _P.gatelength,
        gatespace = _P.gatespace,
        sdwidth = _P.sdwidth,
        sourcesize = 500,
        sourcealign = "bottom",
        drainsize = 500,
        drawtopgate = true,
        topgatestrwidth = _P.connwidth,
        topgatemetal = 4,
        drawdrainvia = true,
        conndrainmetal = 4,
        connectsource = true
    })

    -- create center dummy
    local dummy = pcell.create_layout("basic/transistor", { fingers = _P.centerdummies, drawtopgate = false, drawdrainvia = false })
    ccp:merge_into(dummy)

    local left = pcell.create_layout("basic/transistor")
    left:move_anchor("rightdrainsource", dummy:get_anchor("leftdrainsource"))
    local right = pcell.create_layout("basic/transistor")
    right:move_anchor("leftdrainsource", dummy:get_anchor("rightdrainsource"))
    ccp:merge_into(left)
    ccp:merge_into(right)

    pcell.pop_overwrites("basic/transistor")

    local leftgate = left:get_anchor("topgatestrapright")
    local rightgate = right:get_anchor("topgatestrapleft"):copy():translate(0, -200)
    ccp:merge_into(geometry.crossing(
        generics.metal(_P.connmetal), generics.metal(_P.connmetal - 1),
        _P.connwidth, leftgate, rightgate, "rectangular-separated", 200)
    )
end

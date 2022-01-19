function parameters()
    pcell.reference_cell("basic/mosfet")
    pcell.add_parameters(
        { "ifingers", 4 },
        { "ofingers", 4 },
        { "interdigitate", false }
        --{ "sourcemetal", 2 },
        --{ "outmetal", 3 }
    )
end

function layout(currentmirror, _P)
    local tp = pcell.get_parameters("basic/mosfet")
    pcell.push_overwrites("basic/mosfet", { fwidth=300, gatelength = 60, drawtopgate = true, connectsource = true })
    local diode = pcell.create_layout("basic/mosfet", { fingers = _P.ifingers, connectdrain = true })
    local mirror = pcell.create_layout("basic/mosfet", { fingers = _P.ofingers })
    diode:move_anchor("sourcedrainmiddlecenterright")
    mirror:move_anchor("sourcedrainmiddlecenterleft")
    currentmirror:merge_into_shallow(diode)
    currentmirror:merge_into_shallow(mirror)
    pcell.pop_overwrites("basic/mosfet")

    -- gate connection
    currentmirror:merge_into_shallow(geometry.path(generics.metal(2), {
        diode:get_anchor("lefttopgate"),
        mirror:get_anchor("righttopgate"),
    }, tp.topgatestrwidth))
end

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
    local diode = pcell.create_layout("basic/mosfet", "diode", { fingers = _P.ifingers, connectdrain = true })
    local mirror = pcell.create_layout("basic/mosfet", "mirror", { fingers = _P.ofingers })
    diode:move_anchor("sourcedrainmiddlecenterright")
    mirror:move_anchor("sourcedrainmiddlecenterleft")
    currentmirror:merge_into(diode)
    currentmirror:merge_into(mirror)
    pcell.pop_overwrites("basic/mosfet")

    -- gate connection
    geometry.path(currentmirror, generics.metal(2), {
        diode:get_anchor("lefttopgate"),
        mirror:get_anchor("righttopgate"),
    }, tp.topgatestrwidth)
end

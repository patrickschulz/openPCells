function parameters()
    pcell.reference_cell("basic/transistor")
    pcell.add_parameters(
        { "ifingers", 4 },
        { "ofingers", 4 },
        { "interdigitate", false }
        --{ "sourcemetal", 2 },
        --{ "outmetal", 3 }
    )
end

function layout(currentmirror, _P)
    local tp = pcell.get_parameters("basic/transistor")
    pcell.push_overwrites("basic/transistor", { drawtopgate = true, connectsource = true })
    local diode = pcell.create_layout("basic/transistor", { fingers = _P.ifingers, connectdrain = true })
    local mirror = pcell.create_layout("basic/transistor", { fingers = _P.ofingers })
    diode:move_anchor("rightdrainsource")
    mirror:move_anchor("leftdrainsource")
    currentmirror:merge_into(diode)
    currentmirror:merge_into(mirror)
    pcell.pop_overwrites("basic/transistor")

    -- gate connection
    currentmirror:merge_into(geometry.path(generics.metal(1), {
        diode:get_anchor("lefttopgate"),
        mirror:get_anchor("righttopgate"),
    }, tp.topgatestrwidth))
end

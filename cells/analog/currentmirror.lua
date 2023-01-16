function parameters()
    pcell.add_parameters(
        { "ifingers", 4 },
        { "ofingers", 4 },
        { "interdigitate", false }
        --{ "sourcemetal", 2 },
        --{ "outmetal", 3 }
    )
end

function layout(currentmirror, _P)
    pcell.push_overwrites("basic/mosfet", {
        fwidth = 500,
        connectsource = true,
        connsourcewidth = 200,
        connsourcespace = 100,
        drawtopgate = true,
        drawtopgatestrap = true,
        topgatecompsd = false,
    })
    local diode = pcell.create_layout("basic/mosfet", "diode", {
        fingers = _P.ifingers,
        diodeconnected = true,
    })
    local source = pcell.create_layout("basic/mosfet", "source", {
        fingers = _P.ofingers,
        conndrainmetal = 2,
        drawdrainvia = true,
        connectdrain = true,
    })
    diode:move_anchor("sourcedrainrightbl")
    source:move_anchor("sourcedrainleftbl")
    currentmirror:merge_into(diode)
    currentmirror:merge_into(source)

    geometry.rectanglebltr(currentmirror, generics.metal(1), diode:get_anchor("topgate1bl"), source:get_anchor(string.format("topgate%dtr", _P.ofingers)))
end

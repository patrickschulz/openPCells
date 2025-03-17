local template_lookup = {

    ["basic/mosfet"] =
[[local mosfet = pcell.create_layout("basic/mosfet", "_mosfet", {
    channeltype = "nmos",
    vthtype = 1,
    oxidetype = 1,
    gatelength = 100,
    gatespace = 100,
    fingerwidth = 1000,
    fingers = 8,
    drawtopgate = true,
    topgatewidth = 50,
    topgatespace = 50,
    sourcemetal = 1,
    connectsource = true,
    connectsourcewidth = 200,
    connectsourcespace = 100,
    drainmetal = 3,
    connectdrain = true,
    connectdrainwidth = 80,
    connectdrainspace = 80,
})]],

    ["basic/cmos"] =
[[local cmos = pcell.create_layout("basic/cmos", "_cmos", {
    gatecontactpos = { "center", "upper1", "lower1" },
    pcontactpos = { "power", "inner", "outer", "power" },
    ncontactpos = { "power", "inner", "outer", "power" },
    oxidetype = 1,
    pvthtype = 1,
    nvthtype = 1,
    pwidth = 0,
    nwidth = 0,
    gatelength = 0,
    gatespace = 0,
    separationautocalc = true, -- use 'false' and separation = ... for explicit values
    sdwidth = 0,
    innergatestraps = 3,
    gatestrapwidth = 0,
    gatestrapspace = 0,
    gatecontactsplitshift = 0,
    powerwidth = 0,
    npowerspace = 0,
    ppowerspace = 0,
    pgateext = 0,
    ngateext = 0,
    -- well, implant, oxidetypemarker...
    extendalltop = 0,
    extendallbottom = 0,
    extendallleft = 0,
    extendallright = 0,
})]],

    ["auxiliary/guardring"] =
[[local guardring = pcell.create_layout("auxiliary/guardring", "_guardring", {
    contype = "p",
    holewidth = 5000,
    holeheight = 5000,
    ringwidth = 200,
    -- all extensions can also be specified by inner/outer for more control
    wellextension = 50,
    soiopenextension = 50,
    implantextension = 50,
    -- the well can also be drawn with a hole, see the parameter fillwelldrawhole for this
    fillwell = true,
    drawdeepwell = false,
    deepwelloffset = 0,
})]],

    ["basic/stacked_mosfet_array"] =
[[local row1 = {
    -- almost all parameters of basic/mosfet are accepted here
    -- (exceptions are those that only make sense for individual devices, such as fingers)
    channeltype = "nmos",
    gatelength = 100,
    gatespace = 200,
    width = 1000,
    oxidetype = 2,
    vthtype = 1,
    devices = {
        {
            name = "M1",
            fingers = 2,
            -- all parameters for basic/mosfet are accepted here
        },
        {
            name = "M2",
            fingers = 4,
            -- all parameters for basic/mosfet are accepted here
        },
    }
}
local row2 = ...
local rows = {
    row1,
    row2
}
local array = pcell.create_layout("basic/stacked_mosfet_array", "_array", {
    rows = rows,
    separation = 500,
})]],

    ["basic/polyresistor"] =
[[local resistor = pcell.create_layout("basic/polyresistor", "_resistor", {
    conntype = "none",
    nxfingers = 8,
    nyfingers = 1,
    xspace = 120,
    width = 400,
    length = 500,
    extension = 400,
    extraextension = 100,
    extendimplantx = 100,
    extendimplanty = 120,
    extendlvsmarkerx = 20,
    extendlvsmarkery = 20,
    contactheight = 200,
})]],

    ["auxiliary/metalgrid"] =
[[local metalgrid = pcell.create_layout("auxiliary/metalgrid", "_grid", {
    metalh = 1,
    metalv = 2,
    mhwidth = 500,
    mhspace = 500,
    mvwidth = 500,
    mvspace = 500,
    mhlines = 2,
    mvlines = 2,
})]],

    ["passive/capacitor/mom"] =
[[local metalgrid = pcell.create_layout("passive/capacitor/mom", "_momcap", {
        fingers = 4,
        fingerwidth = 100,
        fingerspace = 100,
        fingerheight = 1000,
        fingeroffset = 100,
        railwidth = 100,
        firstmetal = 1,
        lastmetal = 2,
})]],

    ["passive/inductor/octagonal"] =
[[local inductor = pcell.create_layout("passive/inductor/octagonal", "_inductor", {
    topmetal = -1,
    turns = 3,
    radius = 40000,
    cornerradius = 14000,
    width = 6000,
    separation = 6000,
    extension = 40000,
    viashift = 0,
    viaoverlapextension = 0,
    extsep = 6000,
    allow45 = true,
})]],
    ["basic/ldmos"] =
[[local ldmos = pcell.create_layout("basic/ldmos", "_ldmos", {
    fingers = 4,
    fingerwidth = 2000,
    channeltype = "pmos",
    gatelength = 280,
    gatestrapwidth = 200,
    gatestrapspace = 200,
    gtopext = 100,
    gbotext = 100,
    sourcewidth = 100,
    sourcespace = 120,
    sourceskip = 50,
    drainwidth = 200,
    drainspace = 450,
    extendall = 200,
    drawguardring = true,
    guardringwidth = 200,
    guardringtopsep = 200,
    guardringbottomsep = 200,
    guardringleftsep = 200,
    guardringrightsep = 200,
})]],

}

if not template_lookup[template] then
    print(string.format("template '%s' not found", template))
else
    print(template_lookup[template])
end

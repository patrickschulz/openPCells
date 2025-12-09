local cell = object.create("gasic_comparatorstage")

local commonoptions = {
    vthtype = 1,
    oxidetype = 2,
    flippedwell = false,
    sdwidth = 340,
    equalgatenets = false,
    gatestrapwidth = 340,
    gatestrapspace = 340,
    gatelinewidth = 400,
    gatelinespace = 400,
    gatelineviawidth = 400,
    gatemetal = 1,
    gatelinemetal = 2,
    sourcemetal = 1,
    drainmetal = 1,
    interconnectmetal = 2,
    usesourcestraps = false,
    interconnectlinepos = "offside",
    groupoutputlines = true,
    grouporder = "source_inside",
    drawinnerguardrings = false,
    drawouterguardring = true,
    guardringfilloxidetype = true,
    shortgates = false,
    shortdummies = true,
    outerdummies = 0,
    extendalltop = 200,
    extendallbottom = 200,
    extendallleft = 200,
    extendallright = 200,
}

-- nmos input pair
local inputpair = pcell.create_layout("analog/common_centroid", "_inputpair", util.add_options(commonoptions, {
    pattern = {
        { 1, 1, 1, 1, 1, 2, 2, 2, 2, 2, },
        { 2, 2, 2, 2, 2, 1, 1, 1, 1, 1, },
    },
    channeltype = "nmos",
    fingers = 2,
    fingerwidth = 5000,
    gatelength = 500,
    gatespace = 540,
    fullgatevia = true,
    gatelineviapitch = 800,
    guardringminxsep = 500,
    guardringminysep = 800,
    equalsourcenets = true,
    interconnectlinewidth = 1000,
    outputlinewidth = 2000,
    interconnectlinepos = "inline",
    grouporder = "drain_inside",
}))
cell:merge_into(inputpair)

-- pmos crossing and current mirror at comparator stage
local pmoscrossing = pcell.create_layout("analog/common_centroid", "_pmoscrossing", util.add_options(commonoptions, {
    pattern = {
        { 5, 5, 5, 3, 3, 3, 3, 3, 4, 4, 4, 4, 4, 6, 6, 6 },
        { 0, 1, 1, 1, 1, 1, 1, 1, 2, 2, 2, 2, 2, 2, 2, 0 },
        { 0, 2, 2, 2, 2, 2, 2, 2, 1, 1, 1, 1, 1, 1, 1, 0 },
        { 0, 6, 6, 4, 4, 4, 4, 4, 3, 3, 3, 3, 3, 5, 5, 0 },
    },
    channeltype = "pmos",
    fingers = 2,
    fingerwidth = 1000,
    gatelength = 500,
    gatespace = 540,
    usegateconnections = true,
    gateconnections = { { 1, 3, 5 }, { 2, 4, 6 } },
    diodeconnected = { 3, 4 },
    connectgatetosourcedrain = {
        -- crossing
        { gate = 1, target = "drain2" },
        { gate = 2, target = "drain1" },
        -- diodes
        --{ gate = 1, target = "drain3" },
        --{ gate = 2, target = "drain4" },
    },
    gatelineviapitch = 1000,
    guardringminxsep = 800,
    guardringminysep = 4000,
    spreadinterconnectlines = true,
    interconnectlinewidth = 400,
    outputlinewidth = 1000,
    grouporder = "drain_inside",
    drainordermanual = true,
    drainorder = { 5, 4, 1, 2, 3, 6 },
}))
pmoscrossing:place_top(inputpair)
pmoscrossing:align_center_x(inputpair)
pmoscrossing:translate_y(4000)
cell:merge_into(pmoscrossing)

local nmoscascode = pcell.create_layout("analog/common_centroid", "nmoscascode", util.add_options(commonoptions, {
    pattern = {
        { 2, 2, 2, 2, 2, 2, 2 },
        { 0, 2, 2, 1, 2, 2, 2 },
    },
    channeltype = "nmos",
    fingers = 2,
    fingerwidth = 500,
    xseparation = 1040,
    gatelength = 500,
    gatespace = 540,
    fullgatevia = true,
    equalsourcenets = false,
    sdm1ext = 100,
    equalgatenets = true,
    guardringminxsep = 500,
    guardringminysep = 3200,
    grouporder = "drain_inside",
    interconnectlinewidth = 400,
    outputlinewidth = 2000,
}))
nmoscascode:place_bottom(inputpair)
nmoscascode:align_center_x(inputpair)
nmoscascode:translate_y(-1000)
cell:merge_into(nmoscascode)

local nmossource = pcell.create_layout("analog/common_centroid", "nmossource", util.add_options(commonoptions, {
    pattern = {
        { 2, 2, 2, 2, 2, 2, 2 },
        { 0, 2, 2, 1, 2, 2, 2 },
    },
    channeltype = "nmos",
    fingers = 2,
    fingerwidth = 500,
    equalgatenets = true,
    gatelength = 1000,
    gatespace = 540,
    fullgatevia = true,
    sdm1ext = 100,
    guardringminxsep = 500,
    guardringminysep = 2400,
    interconnectlinewidth = 400,
    outputlinewidth = 2000,
    insertglobalgateline = true,
    globalgatelinesincenter = true,
}))
nmossource:place_bottom(nmoscascode)
nmossource:align_center_x(nmoscascode)
nmossource:translate_y(-2000)
cell:merge_into(nmossource)

local nmosleftrightsource = pcell.create_layout("analog/common_centroid", "nmosleftrightsource", util.add_options(commonoptions, {
    pattern = {
        { 1, 2 },
        { 2, 1 },
    },
    channeltype = "nmos",
    fingers = 2,
    fingerwidth = 500,
    equalgatenets = true,
    gatelength = 1000,
    gatespace = 540,
    fullgatevia = true,
    sdm1ext = 100,
    connectgatetosourcedrain = { { gate = 1, target = "drain1" } },
    guardringminxsep = 500,
    guardringminysep = 2400,
    interconnectlinewidth = 400,
    outputlinewidth = 1000,
}))
nmosleftrightsource:place_bottom(nmossource)
nmosleftrightsource:align_center_x(nmossource)
nmosleftrightsource:translate_y(-2000)
cell:merge_into(nmosleftrightsource)

-- connections
geometry.path_3y(cell, generics.metal(3),
    point.create(
        0.5 * (
            nmoscascode:get_area_anchor("drain2").l +
            nmoscascode:get_area_anchor("drain2").r
        ),
        nmoscascode:get_area_anchor("drain2").t
    ),
    point.create(
        0.5 * (
            inputpair:get_area_anchor("source0_1").l +
            inputpair:get_area_anchor("source0_1").r
        ),
        inputpair:get_area_anchor("source0_1").b
    ),
    2000,
    0.5
)
geometry.path_3y(cell, generics.metal(3),
    point.create(
        0.5 * (
            nmoscascode:get_area_anchor("drain2").l +
            nmoscascode:get_area_anchor("drain2").r
        ),
        nmoscascode:get_area_anchor("drain2").t
    ),
    point.create(
        0.5 * (
            inputpair:get_area_anchor("source0_2").l +
            inputpair:get_area_anchor("source0_2").r
        ),
        inputpair:get_area_anchor("source0_2").b
    ),
    2000,
    0.5
)

geometry.path_3y(cell, generics.metal(3),
    point.create(
        0.5 * (
            nmossource:get_area_anchor("drain1").l +
            nmossource:get_area_anchor("drain1").r
        ),
        nmossource:get_area_anchor("drain1").t
    ),
    point.create(
        0.5 * (
            nmoscascode:get_area_anchor("source1").l +
            nmoscascode:get_area_anchor("source1").r
        ),
        nmoscascode:get_area_anchor("source1").b
    ),
    2000,
    0.5
)

geometry.path_3y(cell, generics.metal(3),
    point.create(
        0.5 * (
            nmossource:get_area_anchor("drain2").l +
            nmossource:get_area_anchor("drain2").r
        ),
        nmossource:get_area_anchor("drain2").t
    ),
    point.create(
        0.5 * (
            nmoscascode:get_area_anchor("source2").l +
            nmoscascode:get_area_anchor("source2").r
        ),
        nmoscascode:get_area_anchor("source2").b
    ),
    2000,
    0.5
)

geometry.path_3y(cell, generics.metal(3),
    point.create(
        0.5 * (
            nmossource:get_area_anchor("gate0").l +
            nmossource:get_area_anchor("gate0").r
        ),
        nmossource:get_area_anchor("gate0").t
    ),
    point.create(
        0.5 * (
            nmoscascode:get_area_anchor("drain1").l +
            nmoscascode:get_area_anchor("drain1").r
        ),
        nmoscascode:get_area_anchor("drain1").b
    ),
    2000,
    0.5
)

return cell

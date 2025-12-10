local cell = object.create("nmosmirror")

local outputlinewidth = 2000

local commonoptions = {
    vthtype = 1,
    oxidetype = 2,
    flippedwell = false,
    fingers = 2,
    sdwidth = 340,
    gatestrapwidth = 340,
    gatestrapspace = 340,
    gatefeedlinewidth = 400,
    gatelinewidth = 400,
    gatelinespace = 400,
    gatelineviawidth = 400,
    interconnectlinewidth = 400,
    outputlinewidth = outputlinewidth,
    gatemetal = 1,
    gatelinemetal = 2,
    sourcemetal = 1,
    drainmetal = 1,
    interconnectmetal = 2,
    usesourcestraps = false,
    sourcestrapsinside = true,
    interconnectlinepos = "offside",
    groupoutputlines = false,
    grouporder = "source_inside",
    drawinnerguardrings = false,
    drawouterguardring = true,
    guardringfilloxidetype = true,
    guardringminxsep = 1000,
    guardringminysep = 1000,
    shortgates = false,
    shortdummies = true,
    outerdummies = 0,
    extendalltop = 200,
    extendallbottom = 200,
    extendallleft = 200,
    extendallright = 200,
}

-- nmos source
local nmossource = pcell.create_layout("analog/common_centroid", "_nmossource", util.add_options(commonoptions, {
    pattern = {
        -- counted from left to right (e.g. 5 is the bias source for the nMOS input pair)
        -- 1, 2, 3, 4, 6, 7: x2
        -- 5: x16
        { 0, 2, 5, 5, 5, 5, 1, 0 },
        { 6, 3, 5, 5, 5, 5, 4, 7 },
        { 7, 4, 5, 5, 5, 5, 3, 6 },
        { 0, 1, 5, 5, 5, 5, 2, 0 },
    },
    channeltype = "nmos",
    fingers = 4,
    fingerwidth = 1250,
    equalsourcenets = true,
    equalgatenets = false,
    gatelength = 1000,
    gatespace = 540,
    gatemetal = 1,
    gatelinemetal = 2,
    sourcemetal = 1,
    drainmetal = 1,
    interconnectmetal = 2,
    usegateconnections = true,
    gateconnections = { { 1, 2, 5 }, { 3, 4 }, { 6, 7 } },
    sourcenets = { source0 = "gnd" },
}))
cell:merge_into(nmossource)

-- nmos cascode
local nmoscascode = pcell.create_layout("analog/common_centroid", "_nmoscascode", util.add_options(commonoptions, {
    pattern = {
        -- counted from left to right (e.g. 5 is the bias source for the nMOS input pair)
        -- 1: x1
        -- 2-7: x8
        { 3, 3, 3, 6, 6, 6, 6, 7, 7, 7, 7, 2, 2, 2 },
        { 4, 4, 4, 3, 4, 5, 2, 0, 0, 0, 0, 5, 5, 5 },
        { 5, 5, 5, 0, 0, 0, 1, 2, 5, 4, 3, 4, 4, 4 },
        { 2, 2, 2, 7, 7, 7, 7, 6, 6, 6, 6, 3, 3, 3 },
    },
    channeltype = "nmos",
    fingers = 4,
    fingerwidth = 2500,
    xseparation = 1040,
    equalgatenets = true,
    equalsourcenets = false,
    gatelength = 500,
    gatespace = 540,
    gatestrapsincenter = false,
    gatemetal = 1,
    gatelinemetal = 2,
    sourcemetal = 1,
    drainmetal = 1,
    interconnectmetal = 2,
    usesourcestraps = false,
}))
nmoscascode:place_top(nmossource)
nmoscascode:align_center_x(nmossource)
nmoscascode:translate_y(8000)
cell:merge_into(nmoscascode)

-- nmos pair
local nmospair = pcell.create_layout("analog/common_centroid", "_nmospair", util.add_options(commonoptions, {
    pattern = {
        { 1, 2, 2, 1 },
        { 2, 1, 1, 2 }
    },
    channeltype = "nmos",
    fingers = 4,
    fingerwidth = 1250,
    equalsourcenets = true,
    equalgatenets = false,
    gatelength = 1000,
    gatespace = 540,
    gatestrapsincenter = false,
    gatemetal = 1,
    gatelinemetal = 2,
    sourcemetal = 1,
    drainmetal = 1,
    interconnectmetal = 2,
    usesourcestraps = true,
    sourcestrapsinside = true,
    groupoutputlines = true,
    grouporder = "source_inside",
    multiplesourcelines = false,
}))
nmospair:place_top(nmoscascode)
nmospair:align_right(nmoscascode)
nmospair:translate_y(2000)
cell:merge_into(nmospair)

-- pmos pair
local pmospair = pcell.create_layout("analog/common_centroid", "_pmospair", util.add_options(commonoptions, {
    pattern = {
        { 1, 2, 2, 1 },
        { 2, 1, 1, 2 }
    },
    channeltype = "pmos",
    fingers = 4,
    fingerwidth = 1250,
    equalgatenets = true,
    gatelength = 1000,
    gatespace = 540,
    gatestrapsincenter = false,
    gatemetal = 1,
    gatelinemetal = 2,
    sourcemetal = 1,
    drainmetal = 1,
    interconnectmetal = 2,
    usesourcestraps = true,
    sourcestrapsinside = true,
    groupoutputlines = true,
    grouporder = "source_inside",
    multiplesourcelines = false,
}))
pmospair:place_top(nmoscascode)
pmospair:align_left(nmoscascode)
pmospair:translate_y(2000)
cell:merge_into(pmospair)

-- pmos cascode
local pmoscascode = pcell.create_layout("analog/common_centroid", "_pmoscascode", util.add_options(commonoptions, {
    pattern = {
        -- counted from left to right (e.g. 5 is the bias source for the pMOS input pair)
        -- 1, 5, 6: x1
        -- 2, 3, 4, 7: x8
        { 4, 3, 3, 3, 3, 4, 4, 4, 4, 3, 3, 3, 3, 4 },
        { 4, 2, 2, 2, 2, 0, 1, 5, 6, 2, 2, 2, 2, 4 },
        { 4, 2, 2, 2, 2, 6, 5, 1, 0, 2, 2, 2, 2, 4 },
        { 4, 3, 3, 3, 3, 4, 4, 4, 4, 3, 3, 3, 3, 4 },
    },
    channeltype = "nmos",
    fingers = 2,
    fingerwidth = 2500,
    equalgatenets = true,
    gatelength = 500,
    gatespace = 540,
    gatestrapsincenter = false,
    gatemetal = 1,
    gatelinemetal = 2,
    sourcemetal = 1,
    drainmetal = 1,
    interconnectmetal = 2,
    usesourcestraps = true,
    sourcestrapsinside = true,
}))
pmoscascode:place_top(nmospair)
pmoscascode:align_center_x(nmoscascode)
pmoscascode:translate_y(2000)
cell:merge_into(pmoscascode)

-- pmos source
local pmossource = pcell.create_layout("analog/common_centroid", "_pmossource", util.add_options(commonoptions, {
    pattern = {
        -- counted from left to right (e.g. 5 is the bias source for the pMOS input pair)
        -- 1, 2, 3, 4, 6: x2
        -- 5, 7: x8
        { 7, 7, 7, 7, 7, 7, 7, 7 },
        { 5, 5, 5, 5, 5, 5, 5, 5 },
        { 0, 3, 4, 6, 1, 2, 0, 0 },
        { 0, 0, 2, 1, 6, 4, 3, 0 },
        { 5, 5, 5, 5, 5, 5, 5, 5 },
        { 7, 7, 7, 7, 7, 7, 7, 7 },
    },
    channeltype = "pmos",
    fingers = 4,
    fingerwidth = 1250,
    equalsourcenets = true,
    equalgatenets = false,
    gatelength = 1000,
    gatespace = 540,
    gatemetal = 1,
    gatelinemetal = 2,
    sourcemetal = 1,
    drainmetal = 1,
    interconnectmetal = 2,
    usegateconnections = true,
    gateconnections = { { 1, 2, 5 }, { 3, 4 }, { 6, 7 } },
    sourcenets = { source0 = "vdd" },
}))
pmossource:place_top(pmoscascode)
pmossource:align_center_x(nmossource)
pmossource:translate_y(2000)
cell:merge_into(pmossource)

-- connect parts

-- nmos source to cascode
local connections = {
    { net = 1, position = 0.5 },
    { net = 2, position = 0.5 },
    { net = 3, position = 0.5 },
    { net = 4, position = 0.5 },
    { net = 5, position = 0.75 },
    { net = 6, position = 0.5 },
    { net = 7, position = 0.25 },
}
for _, c in ipairs(connections) do
    geometry.path_3y(cell, generics.metal(3),
        point.create(
            0.5 * (
                nmossource:get_area_anchor_fmt("drain%d", c.net).l +
                nmossource:get_area_anchor_fmt("drain%d", c.net).r
            ),
            nmossource:get_area_anchor_fmt("drain%d", c.net).t
        ),
        point.create(
            0.5 * (
                nmoscascode:get_area_anchor_fmt("source%d", c.net).l +
                nmoscascode:get_area_anchor_fmt("source%d", c.net).r
            ),
            nmoscascode:get_area_anchor_fmt("source%d", c.net).b
        ),
        outputlinewidth,
        c.position
    )
end

-- nmos cascode to nmos inputpair
geometry.path_3y(cell, generics.metal(3),
    point.create(
        0.5 * (
            nmoscascode:get_area_anchor_fmt("drain%d", 5).l +
            nmoscascode:get_area_anchor_fmt("drain%d", 5).r
        ),
        nmoscascode:get_area_anchor_fmt("drain%d", 5).t
    ),
    point.create(
        0.5 * (
            nmospair:get_area_anchor("source0").l +
            nmospair:get_area_anchor("source0").r
        ),
        nmospair:get_area_anchor("source0").b
    ),
    outputlinewidth,
    0.5
)

-- nmos cascode to pmos inputpair
for _, c in ipairs({
        --{ n = 4, p = 1, },
        --{ n = 6, p = 2 }
    }) do
    geometry.path_3y(cell, generics.metal(3),
        point.create(
            0.5 * (
                nmoscascode:get_area_anchor_fmt("drain%d", c.n).l +
                nmoscascode:get_area_anchor_fmt("drain%d", c.n).r
            ),
            nmoscascode:get_area_anchor_fmt("drain%d", c.n).t
        ),
        point.create(
            0.5 * (
                pmospair:get_area_anchor_fmt("drain%d", c.p).l +
                pmospair:get_area_anchor_fmt("drain%d", c.p).r
            ),
            pmospair:get_area_anchor_fmt("drain%d", c.p).b
        ),
        outputlinewidth,
        0.5
    )
end

-- pmos cascode to pmos inputpair
geometry.path_3y(cell, generics.metal(3),
    point.create(
        0.5 * (
            pmoscascode:get_area_anchor_fmt("drain%d", 3).l +
            pmoscascode:get_area_anchor_fmt("drain%d", 3).r
        ),
        pmoscascode:get_area_anchor_fmt("drain%d", 3).b
    ),
    point.create(
        0.5 * (
            pmospair:get_area_anchor("source0").l +
            pmospair:get_area_anchor("source0").r
        ),
        pmospair:get_area_anchor("source0").t
    ),
    outputlinewidth,
    0.5
)

-- place powergrid
local pwidth = 750
local pspace = 750

local function _insert(t, new)
    for _, e in ipairs(new) do
        table.insert(t, e)
    end
end

local vddshapes = {}
local gndshapes = {}

_insert(vddshapes, pmossource:get_net_shapes("vdd"))
_insert(gndshapes, nmossource:get_net_shapes("gnd"))

local boundary = cell:get_boundary()
local pbl, ptr = util.polygon_rectangular_boundary(boundary)
layouthelpers.place_powergrid(cell,
    pbl, ptr,
    nil, -- no vertical lines
    4, -- horizontal lines: MET4
    0, 0, -- width/space for vertical lines, not needed
    pwidth, pspace, -- width/space
    vddshapes,
    gndshapes
)

return cell

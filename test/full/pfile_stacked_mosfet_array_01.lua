local row1 = {
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
local row2 = {
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
            name = "M3",
            fingers = 2,
            -- all parameters for basic/mosfet are accepted here
        },
        {
            name = "M4",
            fingers = 4,
            -- all parameters for basic/mosfet are accepted here
        },
    }
}
local rows = {
    row1, row2
}
return {
    rows = rows,
    yseparation = 500,
}

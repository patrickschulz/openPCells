local toplevel = object.create("toplevel")

local oscillator1 = pcell.create_layout("analog/ringoscillator", "oscillator1", {
    invfingers = 4,
    numinv = 5,
    invdummies = 1,
    gatelength = 500,
    gatespace = 320,
    pfingerwidth = 2600,
    nfingerwidth = 1800,
    gatestrapwidth = 200,
    gatestrapspace = 200,
    sdwidth = 200,
    powerwidth = 800,
    powerspace = 200,
    connectionwidth = 200,
    feedbackmetal = 3,
    ngateext = 200,
    pgateext = 200,
})
toplevel:add_child(oscillator1, "oscillator1")

return toplevel

function config()
    pcell.set_property("hidden", true)
end

function parameters()
    pcell.add_parameters(
        { "oxidetype(Oxide Type)",                        1 },
        { "pvthtype(PMOS Threshold Voltage Type) ",       1 },
        { "nvthtype(NMOS Threshold Voltage Type)",        1 },
        { "glength(Gate Length)",                         tech.get_dimension("Minimum Gate Length") },
        { "gspace(Gate Spacing)",                         tech.get_dimension("Minimum Gate Space") },
        { "pwidth(PMOS Finger Width)",                    tech.get_dimension("Minimum Gate Width"), even() },
        { "nwidth(NMOS Finger Width)",                    tech.get_dimension("Minimum Gate Width"), even() },
        { "sdwidth(Source/Drain Metal Width)",            tech.get_dimension("Minimum M1 Width"), even() },
        { "gstwidth(Gate Strap Metal Width)",             tech.get_dimension("Minimum M1 Width") },
        { "separation(PMOS/NMOS Separation)",             400 },
        { "powerwidth(Power Rail Metal Width)",           tech.get_dimension("Minimum M1 Width") },
        { "powerspace(Power Rail Space)",                 tech.get_dimension("Minimum M1 Space") },
        { "leftdummies(Number of Left Dummies)",          1 },
        { "rightdummies(Number of Right Dummies)",        1 },
        { "dummycontheight(Dummy Gate Contact Height)",   tech.get_dimension("Minimum M1 Width"), follow = "powerwidth" },
        { "compact(Compact Layout)",                      true },
        { "connectoutput",                                true }
    )
end

function config()
    pcell.set_property("hidden", true)
end

function parameters()
    pcell.add_parameters(
        { "oxidetype(Oxide Type)",                        1 },
        { "pvthtype(PMOS Threshold Voltage Type) ",       1 },
        { "nvthtype(NMOS Threshold Voltage Type)",        1 },
        { "glength(Gate Length)",                       100 },
        { "gspace(Gate Spacing)",                       150 },
        { "pwidth(PMOS Finger Width)",                  500 },
        { "nwidth(NMOS Finger Width)",                  500 },
        { "sdwidth(Source/Drain Metal Width)",           60 },
        { "gstwidth(Gate Strap Metal Width)",            60 },
        { "separation(PMOS/NMOS Separation)",           400 },
        { "powerwidth(Power Rail Metal Width)",         200 },
        { "powerspace(Power Rail Space)",               100 },
        { "leftdummies(Number of Left Dummies)",          1 },
        { "rightdummies(Number of Right Dummies)",        1 },
        { "dummycontheight(Dummy Gate Contact Height)", 100 },
        { "compact(Compact Layout)",                   true }
    )
end

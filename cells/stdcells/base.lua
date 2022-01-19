function config()
    pcell.set_property("hidden", true)
end

function parameters()
    pcell.add_parameters(
        { "oxidetype(Oxide Type)",                             1 },
        { "pvthtype(PMOS Threshold Voltage Type) ",            1 },
        { "nvthtype(NMOS Threshold Voltage Type)",             1 },
        { "glength(Gate Length)",                              tech.get_dimension("Minimum Gate Length") },
        { "gspace(Gate Spacing)",                              tech.get_dimension("Minimum Gate Space") },
        { "pwidth(PMOS Finger Width)",                         tech.get_dimension("Minimum Gate Width"), even() },
        { "nwidth(NMOS Finger Width)",                         tech.get_dimension("Minimum Gate Width"), even() },
        { "sdwidth(Source/Drain Metal Width)",                 tech.get_dimension("Minimum M1 Width"), even() },
        { "gstwidth(Gate Strap Metal Width)",                  tech.get_dimension("Minimum M1 Width") },
        { "gstspace(Gate Strap Metal Space)",                  tech.get_dimension("Minimum M1 Space") },
        { "numinnerroutes(Number of inner M1 routes)",         3, readonly = true },
        { "powerwidth(Power Rail Metal Width)",                tech.get_dimension("Minimum M1 Width") },
        { "powerspace(Power Rail Space)",                      tech.get_dimension("Minimum M1 Space") },
        { "gateext(Gate Extension)",                           0 },
        { "psdheight(PMOS Source/Drain Contact Height)",       0 },
        { "nsdheight(NMOS Source/Drain Contact Height)",       0 },
        { "psdpowerheight(PMOS Source/Drain Contact Height)",  0 },
        { "nsdpowerheight(NMOS Source/Drain Contact Height)",  0 },
        { "leftdummies(Number of Left Dummies)",               0 },
        { "rightdummies(Number of Right Dummies)",             0 },
        { "dummycontheight(Dummy Gate Contact Height)",        tech.get_dimension("Minimum M1 Width") },
        { "drawdummygcut(Draw Dummy Gate Cut)",                false },
        { "compact(Compact Layout)",                           true },
        { "connectoutput",                                     true }
    )
end

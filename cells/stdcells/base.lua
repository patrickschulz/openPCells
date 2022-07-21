function config()
    pcell.set_property("hidden", true)
end

function parameters()
    pcell.add_parameters(
        { "oxidetype(Oxide Type)",                                      1 },
        { "gatemarker(Gate Marker Index)",                              1 },
        { "pvthtype(PMOS Threshold Voltage Type) ",                     1 },
        { "nvthtype(NMOS Threshold Voltage Type)",                      1 },
        { "pmosflippedwell(PMOS Flipped Well) ",                        false },
        { "nmosflippedwell(NMOS Flipped Well)",                         false },
        { "glength(Gate Length)",                                       tech.get_dimension("Minimum Gate Length") },
        { "gspace(Gate Spacing)",                                       tech.get_dimension("Minimum Gate Space") },
        { "sdwidth(Source/Drain Metal Width)",                          tech.get_dimension("Minimum M1 Width"), posvals = even() },
        { "routingwidth(Routing Metal Width)",                          tech.get_dimension("Minimum M1 Width") },
        { "routingspace(Routing Metal Space)",                          tech.get_dimension("Minimum M1 Space") },
        { "pnumtracks(Number of PMOS Routing Tracks)",                  5 },
        { "nnumtracks(Number of NMOS Routing Tracks)",                  5 },
        { "numinnerroutes(Number of inner M1 routes)",                  3 }, -- if you use complex gates (xor, dff), this must be (at least) 3
        { "powerwidth(Power Rail Metal Width)",                         tech.get_dimension("Minimum M1 Width") },
        { "powerspace(Power Rail Space)",                               tech.get_dimension("Minimum M1 Space") },
        { "separation(nMOS/pMOS Separation)",                           0 },
        { "spacesepautocalc(Calculate Power Rail Space/Separation)",    true },
        { "gateext(Gate Extension)",                                    0 },
        { "psdheight(PMOS Source/Drain Contact Height)",                0 },
        { "nsdheight(NMOS Source/Drain Contact Height)",                0 },
        { "psdpowerheight(PMOS Source/Drain Contact Height)",           0 },
        { "nsdpowerheight(NMOS Source/Drain Contact Height)",           0 },
        { "dummycontheight(Dummy Gate Contact Height)",                 tech.get_dimension("Minimum M1 Width") },
        { "drawdummygcut(Draw Dummy Gate Cut)",                         false },
        { "compact(Compact Layout)",                                    true },
        { "connectoutput",                                              true }
    )
end

function parameters()
    pcell.add_parameters(
        { "channeltype(Channel Type)",                                              "nmos", posvals = set("nmos", "pmos"), info = "polarity of the mosfet. Can be either 'nmos' or 'pmos'." },
        { "implant(Threshold Voltage Type)",                                        1, argtype = "integer", posvals = interval(1, inf), info = "threshold voltage index of the device. This is a numeric index, starting from 1 (the default). The interpretation of this is up to the technology file" },
        { "implantalignwithactive",                                                 false, info = "set reference points for implant extensions. If this is false, the implant extensions are autmatically calculated so that the implant covers all gates. With this option enabled, the implant extensions are referenced to the active region. This is useful for having precise control over the implant extensions in mosfet arrays with varying gate heights. This option sets left/right/top/bottom alignment, the dedicated switches can be used for more fine-grained control." },
        { "implantalignleftwithactive",                                             false, follow = "vthtypealignwithactive", info = "set reference point for implant left extensions. If this is false, the implant left extension is autmatically calculated so that the implant covers the left gates. With this option enabled, the implant left extension is referenced to the active region. This is useful for having precise control over the implant extensions in mosfet arrays with varying gate heights" },
        { "implantalignrightwithactive",                                            false, follow = "vthtypealignwithactive", info = "set reference point for implant right extensions. If this is false, the implant right extension is autmatically calculated so that the implant covers the right gates. With this option enabled, the implant right extension is referenced to the active region. This is useful for having precise control over the implant extensions in mosfet arrays with varying gate heights" },
        { "implantaligntopwithactive",                                              false, follow = "vthtypealignwithactive", info = "set reference point for implant top extensions. If this is false, the implant top extension is autmatically calculated so that the implant covers the top part of all gates. With this option enabled, the implant top extension is referenced to the active region. This is useful for having precise control over the implant extensions in mosfet arrays with varying gate heights" },
        { "implantalignbottomwithactive",                                           false, follow = "vthtypealignwithactive", info = "set reference point for implant bottom extensions. If this is false, the implant bottom extension is autmatically calculated so that the implant covers the bottom part of all gates. With this option enabled, the implant bottom extension is referenced to the active region. This is useful for having precise control over the vthtype marker extensions in mosfet arrays with varying gate heights" },
        { "oxidetype(Oxide Thickness Type)",                                        1, argtype = "integer", posvals = interval(1, inf), info = "oxide thickness index of the gate. This is a numeric index, starting from 1 (the default). The interpretation of this is up to the technology file" },
        { "oxidetypealignwithactive",                                               false, info = "set reference points for oxide thickness marker extensions. If this is false, the oxide thickness marker extensions are autmatically calculated so that the oxide thickness marker covers all gates. With this option enabled, the oxide thickness marker extensions are referenced to the active region. This is useful for having precise control over the oxide thickness marker extensions in mosfet arrays with varying gate heights. This option sets left/right/top/bottom alignment, the dedicated switches can be used for more fine-grained control." },
        { "oxidetypealignleftwithactive",                                           false, follow = "oxidetypealignwithactive", info = "set reference point for oxide thickness marker left extensions. If this is false, the oxide thickness marker left extension is autmatically calculated so that the oxide thickness marker covers the left gates. With this option enabled, the oxide thickness marker left extension is referenced to the active region. This is useful for having precise control over the oxide thickness marker extensions in mosfet arrays with varying gate heights" },
        { "oxidetypealignrightwithactive",                                          false, follow = "oxidetypealignwithactive", info = "set reference point for oxide thickness marker right extensions. If this is false, the oxide thickness marker right extension is autmatically calculated so that the oxide thickness marker covers the right gates. With this option enabled, the oxide thickness marker right extension is referenced to the active region. This is useful for having precise control over the oxide thickness marker extensions in mosfet arrays with varying gate heights" },
        { "oxidetypealigntopwithactive",                                            false, follow = "oxidetypealignwithactive", info = "set reference point for oxide thickness marker top extensions. If this is false, the oxide thickness marker top extension is autmatically calculated so that the oxide thickness marker covers the top part of all gates. With this option enabled, the oxide thickness marker top extension is referenced to the active region. This is useful for having precise control over the oxide thickness marker extensions in mosfet arrays with varying gate heights" },
        { "oxidetypealignbottomwithactive",                                         false, follow = "oxidetypealignwithactive", info = "set reference point for oxide thickness marker bottom extensions. If this is false, the oxide thickness marker bottom extension is autmatically calculated so that the oxide thickness marker covers the bottom part of all gates. With this option enabled, the oxide thickness marker bottom extension is referenced to the active region. This is useful for having precise control over the vthtype marker extensions in mosfet arrays with varying gate heights" },
        { "vthtype(Threshold Voltage Type)",                                        1, argtype = "integer", posvals = interval(1, inf), info = "threshold voltage index of the device. This is a numeric index, starting from 1 (the default). The interpretation of this is up to the technology file" },
        { "vthtypealignwithactive",                                                 false, info = "set reference points for vthtype marker extensions. If this is false, the vthtype marker extensions are autmatically calculated so that the vthtype marker covers all gates. With this option enabled, the vthtype marker extensions are referenced to the active region. This is useful for having precise control over the vthtype marker extensions in mosfet arrays with varying gate heights. This option sets left/right/top/bottom alignment, the dedicated switches can be used for more fine-grained control." },
        { "vthtypealignleftwithactive",                                             false, follow = "vthtypealignwithactive", info = "set reference point for vthtype marker left extensions. If this is false, the vthtype marker left extension is autmatically calculated so that the vthtype marker covers the left gates. With this option enabled, the vthtype marker left extension is referenced to the active region. This is useful for having precise control over the vthtype marker extensions in mosfet arrays with varying gate heights" },
        { "vthtypealignrightwithactive",                                            false, follow = "vthtypealignwithactive", info = "set reference point for vthtype marker right extensions. If this is false, the vthtype marker right extension is autmatically calculated so that the vthtype marker covers the right gates. With this option enabled, the vthtype marker right extension is referenced to the active region. This is useful for having precise control over the vthtype marker extensions in mosfet arrays with varying gate heights" },
        { "vthtypealigntopwithactive",                                              false, follow = "vthtypealignwithactive", info = "set reference point for vthtype marker top extensions. If this is false, the vthtype marker top extension is autmatically calculated so that the vthtype marker covers the top part of all gates. With this option enabled, the vthtype marker top extension is referenced to the active region. This is useful for having precise control over the vthtype marker extensions in mosfet arrays with varying gate heights" },
        { "vthtypealignbottomwithactive",                                           false, follow = "vthtypealignwithactive", info = "set reference point for vthtype marker bottom extensions. If this is false, the vthtype marker bottom extension is autmatically calculated so that the vthtype marker covers the bottom part of all gates. With this option enabled, the vthtype marker bottom extension is referenced to the active region. This is useful for having precise control over the vthtype marker extensions in mosfet arrays with varying gate heights" },
        { "gatemarker(Gate Marking Layer Index)",                                   1, argtype = "integer", posvals = interval(1, inf), info = "special marking layer that covers only the gate (the intersection of poly and the active region). This is a numeric index, starting at 1 (the default). The interpretation is up to the technology, typically the first gate marker should be an empty layer" },
        { "mosfetmarker(MOSFET Marking Layer Index)",                               1, argtype = "integer", posvals = interval(1, inf), info = "special marking layer that covers the active region. This is a numeric index, starting at 1 (the default). The interpretation is up to the technology, typically the first gate marker should be an empty layer" },
        { "mosfetmarkeralignatsourcedrain(Align MOSFET Marker at Source/Drain)",    false, info = "set reference points for mosfetmarker extensions. If this is false, the mosfetmarker extensions are autmatically calculated so that the mosfetmarker covers all gates. With this option enabled, the mosfetmarker extensions are referenced to the active region. This is useful for having precise control over the mosfetmarker extensions in mosfet arrays with varying gate heights"  },
        { "flippedwell(Flipped Well)",                                              false, info = "enable if the device is a flipped-well device. The wells are inferred from the channeltype: non-flipped-well: pmos -> n-well, nmos -> p-well and vice versa" },
        { "fingers(Number of Fingers)",                                             1, argtype = "integer", posvals = interval(0, inf), info = "number of gate fingers. The total width of the device is fwidth * fingers" },
        { "fwidth(Finger Width)",                                                   technology.get_dimension("Minimum Gate Width"), argtype = "integer", info = "gate finger width. The total width of the device is fwidth * finger" },
        { "gatelength(Gate Length)",                                                technology.get_dimension("Minimum Gate Length"), argtype = "integer", info = "drawn gate length (channel length)" },
        { "gatespace(Gate Spacing)",                                                technology.get_dimension("Minimum Gate XSpace"), argtype = "integer", info = "gate space between the polysilicon lines" },
        { "actext(Active Extension)",                                               0, info = "left/right active extension. This is added to the calculated width of the active regions, dependent on the number of gates, the finger widths, gate spacing and left/right dummy devices" },
        { "sdwidth(Source/Drain Contact Width)",                                    technology.get_dimension("Minimum M1 Width"), argtype = "integer", info = "width of the source/drain contact regions. Currently, all metals are drawn in the same width, which can be an issue for higher metals as vias might not fit. If this is the case the vias have to be drawn manually. This might change in the future." }, -- FIXME: rename
        { "sdviawidth(Source/Drain Metal Width for Vias)",                          technology.get_dimension("Minimum M1 Width"), argtype = "integer", follow = "sdwidth", info  = "width of the source/drain via regions. Currently, all vias are drawn in the same width, which can be an issue for higher metals as vias might not fit. If this is the case the vias have to be drawn manually. This might change in the future. This parameter follows 'sdwidth'." },
        { "sdmetalwidth(Source/Drain Metal Width)",                                 technology.get_dimension("Minimum M1 Width"), argtype = "integer", follow = "sdviawidth", info = "width of the source/drain metals. This parameter follows 'sdwidth'." },
        { "gtopext(Gate Top Extension)",                                            technology.get_dimension("Minimum Gate Extension"), info = "top gate extension. This extension depends on the automatically calculated gate extensions (which depend for instance on gate contacts). This means that if 'gtopext' is smaller than the automatic extensions, the layout is not changed at all." },
        { "gbotext(Gate Bot Extension)",                                            technology.get_dimension("Minimum Gate Extension"), info = "bot gate extension. This extension depends on the automatically calculated gate extensions (which depend for instance on gate contacts). This means that if 'gbotext' is smaller than the automatic extensions, the layout is not changed at all." },
        { "gtopextadd(Gate Additional Top Extension)",                              0, info = "Unconditional gate top extension (similar to 'gtopext', but always extends)." },
        { "gbotextadd(Gate Additional Bottom Extension)",                           0, info = "Unconditional gate bot extension (similar to 'gbotext', but always extends)." },
        { "drawleftstopgate(Draw Left Stop Gate)",                                  false, info = "draw a gate where one half of it covers the active region, the other does not (left side). This gate is covered with the layer 'diffusionbreakgate'. This is required in some technologies for short-length devices" },
        { "drawrightstopgate(Draw Left Stop Gate)",                                 false, info = "draw a gate where one half of it covers the active region, the other does not (right side). This gate is covered with the layer 'diffusionbreakgate'. This is required in some technologies for short-length devices" },
        { "endleftwithgate(End Left Side With Gate)",                               false, follow = "drawleftstopgate", info = "align the left end of the active region so that only half of the left-most gate covers the active region. Follows 'drawleftstopgate'." },
        { "endrightwithgate(End Right Side With Gate)",                             false, follow = "drawrightstopgate", info = "align the right end of the active region so that only half of the right-most gate covers the active region. Follows 'drawrightstopgate'." },
        { "drawtopgate(Draw Top Gate Contact)",                                     false, info = "draw gate contacts on the upper side of the active region. The contact region width is the gate length, the height is 'topgatewidth'. The space to the active region is 'topgatespace'." },
        { "drawtopgatestrap(Draw Top Gate Strap)",                                  false, follow = "drawtopgate", info = "Connect all top gate contacts by a metal strap. Follows 'drawtopgate'." },
        { "topgatewidth(Top Gate Width)",                                           technology.get_dimension("Minimum M1 Width"), argtype = "integer", info = "Width of the metal strap connecting all top gate contacts." },
        { "topgateleftextension(Top Gate Left Extension)",                          0, info = "Left extension of top gate metal strap. Positive values extend the strap on the left side beyond (to the left) of the gate, negative values in the opposite direction (but this is likely to cause an DRC error). So while negative values are possible, they are probably not useful." },
        { "topgaterightextension(Top Gate Right Extension)",                        0, info = "Right extension of top gate metal strap. Positive values extend the strap on the right side beyond (to the right) of the gate, negative values in the opposite direction (but this is likely to cause an DRC error). So while negative values are possible, they are probably not useful." },
        { "topgatespace(Top Gate Space)",                                           technology.get_dimension("Minimum M1 Space"), argtype = "integer", info = "Space between the active region and the lower edge of the top gate contacts/metal strap" },
        { "topgatemetal(Top Gate Strap Metal)",                                     1, info = "Metal index (can be negative) of the top gate metal straps. If this is higher than 1 and 'drawtopgatevia' is true, vias are drawn." },
        { "drawtopgatevia(Draw Top Gate Via)",                                      false, info = "Enable the drawing of vias on the top gate metal strap. This only makes a difference if 'topgatemetal' is higher than 1." },
        { "topgatecontinuousvia(Top Gate Continuous Via)",                          false, info = "Make the drawn via of the top gate metal strap a continuous via." },
        { "drawbotgate(Draw Bottom Gate Contact)",                                  false, info = "draw gate contacts on the upper side of the active region. The contact region width is the gate length, the height is 'topgatewidth'. The space to the active region is 'topgatespace'." },
        { "drawbotgatestrap(Draw Bottom Gate Strap)",                               false, follow = "drawbotgate" },
        { "botgatewidth(Bottom Gate Width)",                                        technology.get_dimension("Minimum M1 Width"), argtype = "integer", info = "Width of the metal strap connecting all bottom gate contacts." },
        { "botgateleftextension(Bottom Gate Left Extension)",                       0, info = "Left extension of bottom gate metal strap. Positive values extend the strap on the left side beyond (to the left) of the gate, negative values in the opposite direction (but this is likely to cause an DRC error). So while negative values are possible, they are probably not useful." },
        { "botgaterightextension(Bottom Gate Right Extension)",                     0, info = "Right extension of bottom gate metal strap. Positive values extend the strap on the right side beyond (to the right) of the gate, negative values in the opposite direction (but this is likely to cause an DRC error). So while negative values are possible, they are probably not useful." },
        { "botgatespace(Bottom Gate Space)",                                        technology.get_dimension("Minimum M1 Space"), argtype = "integer", info = "Space between the active region and the lower edge of the bottom gate contacts/metal strap" },
        { "botgatemetal(Bottom Gate Strap Metal)",                                  1, info = "Metal index (can be negative) of the bottom gate metal straps. If this is higher than 1 and 'drawbotgatevia' is true, vias are drawn." },
        { "drawbotgatevia(Draw Bottom Gate Via)",                                   false, info = "Enable the drawing of vias on the bottom gate metal strap. This only makes a difference if 'botgatemetal' is higher than 1." },
        { "botgatecontinuousvia(Bottom Gate Continuous Via)",                       false, info = "Make the drawn via of the bottom gate metal strap a continuous via." },
        { "drawtopgatecut(Draw Top Gate Cut)",                                      false, info = "Draw a gate cut rectangle above the active region (the 'top' gates)." },
        { "topgatecutwidth(Top Gate Cut Y Width)",                                  technology.get_dimension("Minimum Gate Cut Height", "Minimum Gate YSpace"), info = "Width of the top gate cut." },
        { "topgatecutspace(Top Gate Cut Y Space)",                                  0, info = "Space between the active region and the top gate cut." },
        { "topgatecutleftext(Top Gate Cut Left Extension)",                         0, info = "Left extension of the top gate cut. Without extension, the gate cut covers the underlying gate in x-direction exactly." },
        { "topgatecutrightext(Top Gate Cut Right Extension)",                       0, info = "Right extension of the top gate cut. Without extension, the gate cut covers the underlying gate in x-direction exactly." },
        { "drawbotgatecut(Draw Top Gate Cut)",                                      false, info = "Draw a gate cut rectangle above the active region (the 'bottom' gates)." },
        { "botgatecutwidth(Top Gate Cut Y Width)",                                  technology.get_dimension("Minimum Gate Cut Height", "Minimum Gate YSpace"), info = "Width of the bottom gate cut." },
        { "botgatecutspace(Top Gate Cut Y Space)",                                  0, info = "Space between the active region and the bottom gate cut." },
        { "botgatecutleftext(Top Gate Cut Left Extension)",                         0, info = "Left extension of the bottom gate cut. Without extension, the gate cut covers the underlying gate in x-direction exactly." },
        { "botgatecutrightext(Top Gate Cut Right Extension)",                       0, info = "Right extension of the bottom gate cut. Without extension, the gate cut covers the underlying gate in x-direction exactly." },
        { "simulatemissinggatecut",                                                 false, info = "Draw the gates with gate cuts as if the technology had no gate cuts (this splits the gates). This is only useful for technologies that support gate cuts." },
        { "drawsourcedrain(Draw Source/Drain Contacts)",                            "both", posvals = set("both", "source", "drain", "none"), info = "Control which source/drain contacts are drawn. The possible values are 'both' (source and drain), 'source', 'drain' or 'none'. More fine-grained control can be obtained by the parameter 'excludesourcedraincontacts'." },
        { "excludesourcedraincontacts(Exclude Source/Drain Contacts)",              {}, argtype = "table", "Define which source/drain contacts get drawn. Set 'drawsourcedrain' to 'both' to use this effectively. The argument to this parameter should be a table with numeric indices. The source/drain regions are enumerated with the left-most starting at 1." },
        { "sourcesize(Source Size)",                                                technology.get_dimension("Minimum Gate Width"), argtype = "integer", follow = "fwidth", info = "Size of the source contact regions. This parameter follows 'fwidth', so per default the contact regions have the width of a transistor finger. For 'sourcesize', only values between 0 and 'fwidth' are allowed. If the size is smaller than 'fwidth', the source contact alignment ('sourcealign') is relevant." },
        { "sourceviasize(Source Via Size)",                                         technology.get_dimension("Minimum Gate Width"), argtype = "integer", follow = "sourcesize", info = "Same as 'sourcesize', but for source vias." },
        { "drainsize(Drain Size)",                                                  technology.get_dimension("Minimum Gate Width"), argtype = "integer", follow = "fwidth", info = "Size of the drain contact regions. This parameter follows 'fwidth', so per default the contact regions have the width of a transistor finger. For 'drainsize', only values between 0 and 'fwidth' are allowed., If the size is smaller than 'fwidth', the drain contact alignment ('drainalign') is relevant." },
        { "drainviasize(Drain Via Size)",                                           technology.get_dimension("Minimum Gate Width"), argtype = "integer", follow = "drainsize", info = "Same as 'drainsize', but for drain vias." },
        { "sourcealign(Source Alignment)",                                          "bottom", posvals = set("top", "bottom"), info = "Alignment of the source contacts. Only relevant when source contacts are smaller than 'fwidth' (see 'sourcesize'). Possible values: 'top' (source contacts grow down from the top into the active region) and 'bottom' (source contact grow up from the bottom into the active region). Typically, one sets 'sourcesize' and 'drainsize' to smaller values than 'fwidth' and uses opposite settings for 'sourcealign' and 'drainalign'." },
        { "sourceviaalign(Source Via Alignment)",                                   "bottom", posvals = set("top", "bottom"), follow = "sourcealign" },
        { "drainalign(Drain Alignment)",                                            "top", posvals = set("top", "bottom"), info = "Same as 'sourcealign' for source vias." },
        { "drainalign(Drain Alignment)",                                            "bottom", posvals = set("top", "bottom"), info = "Alignment of the drain contacts. Only relevant when drain contacts are smaller than 'fwidth' (see 'drainsize'). Possible values: 'top' (drain contacts grow down from the top into the active region) and 'bottom' (drain contact grow up from the bottom into the active region). Typically, one sets 'sourcesize' and 'drainsize' to smaller values than 'fwidth' and uses opposite settings for 'sourcealign' and 'drainalign'." },
        { "drainviaalign(Drain Via Alignment)",                                     "top", posvals = set("top", "bottom"), follow = "drainalign", info = "Same as 'drainalign' for drain vias." },
        { "drawsourcevia(Draw Source Via)",                                         true, info = "Draw required vias from metal 1 to the source metal. Only useful when 'sourcemetal' is not 1." },
        { "drawfirstsourcevia(Draw First Source Via)",                              true, info = "Draw a via on the first source region (counted from the left). This switch can be useful when connecting dummies to other devices." },
        { "drawlastsourcevia(Draw Last Source Via)",                                true, info = "Draw a via on the last source region (counted from the left). This switch can be useful when connecting dummies to other devices." },
        { "connectsource(Connect Source)",                                          false, info = "Connect all parallel source regions by a metal strap. This strap either lies outside or inside of the active region (see parameter 'connectsourceinline'). For nMOS devices, the outer source strap is below the active region, for pMOS devices the outer source strap is above the active region. This can be changed with 'connectsourceinverse')." },
        { "drawsourcestrap(Draw Source Strap)",                                     false, follow = "connectsource", info = "Draw the source strap. This parameter follows 'connectsource', so per default the source strap is drawn. This parameter is useful when the source strap (or what it should connect to) is drawn by some other structures." },
        { "drawsourceconnections(Draw Source Connections)",                         false, follow = "connectsource", info = "Draw the connections to the source strap. This parameter follows 'connectsource', so per default the connections between the source regions and the source strap are drawn. This parameter is rarely useful, only in situations where the source strap is now used but the source is connected." },
        { "connectsourceboth(Connect Source on Both Sides)",                        false, info = "Connect the source on both sides of the active region. The \"other\" source strap is controlled by the connectsourceother* parameters, which all follow the main connectsource* parameters. This means that per default the \"other\" source strap mirrors the main one." },
        { "connectsourcewidth(Source Rails Metal Width)",                           technology.get_dimension("Minimum M1 Width"), argtype = "integer", follow = "sdwidth" },
        { "connectsourcespace(Source Rails Metal Space)",                           technology.get_dimension("Minimum M1 Width"), argtype = "integer" },
        { "connectsourceleftext(Source Rails Metal Left Extension)",                0 },
        { "connectsourcerightext(Source Rails Metal Right Extension)",              0 },
        { "connectsourceotherwidth(Other Source Rails Metal Width)",                technology.get_dimension("Minimum M1 Width"), argtype = "integer", follow = "connectsourcewidth" },
        { "connectsourceotherspace(Other Source Rails Metal Space)",                technology.get_dimension("Minimum M1 Width"), argtype = "integer", follow = "connectsourcespace" },
        { "connectsourceotherleftext(Other Source Rails Metal Left Extension)",     0, follow = "connectsourceleftext", },
        { "connectsourceotherrightext(Other Source Rails Metal Right Extension)",   0, follow = "connectsourcerightext", },
        { "sourcemetal(Source Connection Metal)",                                   1 },
        { "sourceviametal(Source Via Metal)",                                       1, follow = "sourcemetal" },
        { "connectsourceinline(Connect Source Inline of Transistor)",               false },
        { "connectsourceinlineoffset(Offset for Inline Source Connection)",         0 },
        { "connectsourceinverse(Invert Source Strap Locations)",                    false },
        { "connectdrain(Connect Drain)",                                            false },
        { "drawdrainstrap(Draw Drain Strap)",                                       false, follow = "connectdrain" },
        { "drawdrainconnections(Draw Drain Connections)",                           false, follow = "connectdrain" },
        { "connectdrainboth(Connect Drain on Both Sides)",                          false },
        { "connectdrainwidth(Drain Rails Metal Width)",                             technology.get_dimension("Minimum M1 Width"), argtype = "integer", follow = "sdwidth" },
        { "connectdrainspace(Drain Rails Metal Space)",                             technology.get_dimension("Minimum M1 Width"), argtype = "integer" },
        { "connectdrainleftext(Drain Rails Metal Left Extension)",                  0 },
        { "connectdrainrightext(Drain Rails Metal Right Extension)",                0 },
        { "connectdraininverse(Invert Drain Strap Locations)",                      false },
        { "connectdrainotherwidth(Other Drain Rails Metal Width)",                  technology.get_dimension("Minimum M1 Width"), argtype = "integer", follow = "connectdrainwidth" },
        { "connectdrainotherspace(Other Drain Rails Metal Space)",                  technology.get_dimension("Minimum M1 Width"), argtype = "integer", follow = "connectdrainspace" },
        { "connectdrainotherleftext(Other Drain Rails Metal Left Extension)",       0, follow = "connectdrainleftext" },
        { "connectdrainotherrightext(Other Drain Rails Metal Right Extension)",     0, follow = "connectdrainrightext" },
        { "drawdrainvia(Draw Drain Via)",                                           true },
        { "drawfirstdrainvia(Draw First Drain Via)",                                true },
        { "drawlastdrainvia(Draw Last Drain Via)",                                  true },
        { "drainmetal(Drain Connection Metal)",                                     1 },
        { "drainviametal(Drain Via Metal)",                                         1, follow = "drainmetal" },
        { "connectdraininline(Connect Drain Inline of Transistor)",                 false },
        { "connectdraininlineoffset(Offset for Inline Drain Connection)",           0 },
        { "diodeconnected(Diode Connected Transistor)",                             false },
        { "drawextrabotstrap(Draw Extra Bottom Strap)",                             false },
        { "extrabotstrapwidth(Width of Extra Bottom Strap)",                        technology.get_dimension("Minimum M1 Width"), argtype = "integer" },
        { "extrabotstrapspace(Space of Extra Bottom Strap)",                        technology.get_dimension("Minimum M1 Space"), argtype = "integer" },
        { "extrabotstrapmetal(Metal Layer for Extra Bottom Strap)",                 1 },
        { "extrabotstrapleftalign(Left Alignment for Extra Bottom Strap)",          1 },
        { "extrabotstraprightalign(Right Alignment for Extra Bottom Strap)",        1, follow = "fingers" },
        { "drawextratopstrap(Draw Extra Top Strap)",                                false },
        { "extratopstrapwidth(Width of Extra Top Strap)",                           technology.get_dimension("Minimum M1 Width"), argtype = "integer" },
        { "extratopstrapspace(Space of Extra Top Strap)",                           technology.get_dimension("Minimum M1 Space"), argtype = "integer" },
        { "extratopstrapmetal(Metal Layer for Extra Top Strap)",                    1 },
        { "extratopstrapleftalign(Left Alignment for Extra Top Strap)",             1 },
        { "extratopstraprightalign(Right Alignment for Extra Top Strap)",           1, follow = "fingers" },
        { "shortdevice(Short Transistor)",                                          false },
        { "shortdeviceleftoffset(Short Transistor Left Offset)",                    0 },
        { "shortdevicerightoffset(Short Transistor Right Offset)",                  0 },
        { "shortlocation",                                                          "inline", posvals = set("inline", "top", "bottom") },
        { "shortspace",                                                             technology.get_dimension("Minimum M1 Space") },
        { "shortwidth",                                                             technology.get_dimension("Minimum M1 Width") },
        { "drawtopactivedummy",                                                     false },
        { "topactivedummywidth",                                                    80 },
        { "topactivedummysep",                                                      80 },
        { "drawbotactivedummy",                                                     false },
        { "botactivedummywidth",                                                    80 },
        { "botactivedummysep",                                                      80 },
        { "leftfloatingdummies",                                                    0 },
        { "rightfloatingdummies",                                                   0 },
        { "drawactive",                                                             true },
        { "lvsmarker",                                                              1 },
        { "lvsmarkeralignwithactive",                                               false },
        { "extendalltop",                                                           0 },
        { "extendallbottom",                                                        0 },
        { "extendallleft",                                                          0 },
        { "extendallright",                                                         0 },
        { "extendoxidetop",                                                         0, follow = "extendalltop" },
        { "extendoxidebottom",                                                      0, follow = "extendallbottom" },
        { "extendoxideleft",                                                        0, follow = "extendallleft" },
        { "extendoxideright",                                                       0, follow = "extendallright" },
        { "extendvthtypetop",                                                       0, follow = "extendalltop" },
        { "extendvthtypebottom",                                                    0, follow = "extendallbottom" },
        { "extendvthtypeleft",                                                      0, follow = "extendallleft" },
        { "extendvthtyperight",                                                     0, follow = "extendallright" },
        { "extendimplanttop",                                                       0, follow = "extendalltop" },
        { "extendimplantbottom",                                                    0, follow = "extendallbottom" },
        { "extendimplantleft",                                                      0, follow = "extendallleft" },
        { "extendimplantright",                                                     0, follow = "extendallright" },
        { "extendwelltop",                                                          0, follow = "extendalltop" },
        { "extendwellbottom",                                                       0, follow = "extendallbottom" },
        { "extendwellleft",                                                         0, follow = "extendallleft" },
        { "extendwellright",                                                        0, follow = "extendallright" },
        { "extendlvsmarkertop",                                                     0, follow = "extendalltop" },
        { "extendlvsmarkerbottom",                                                  0, follow = "extendallbottom" },
        { "extendlvsmarkerleft",                                                    0, follow = "extendallleft" },
        { "extendlvsmarkerright",                                                   0, follow = "extendallright" },
        { "extendrotationmarkertop",                                                0, follow = "extendalltop" },
        { "extendrotationmarkerbottom",                                             0, follow = "extendallbottom" },
        { "extendrotationmarkerleft",                                               0, follow = "extendallleft" },
        { "extendrotationmarkerright",                                              0, follow = "extendallright" },
        { "drawwell",                                                               true },
        { "drawtopwelltap",                                                         false },
        { "topwelltapwidth",                                                        technology.get_dimension("Minimum M1 Width") },
        { "topwelltapspace",                                                        technology.get_dimension("Minimum M1 Space") },
        { "topwelltapextendleft",                                                   0 },
        { "topwelltapextendright",                                                  0 },
        { "drawbotwelltap",                                                         false },
        { "drawguardring",                                                          false },
        { "guardringwidth",                                                         technology.get_dimension("Minimum M1 Width") },
        { "guardringxsep",                                                          0 },
        { "guardringysep",                                                          0 },
        { "guardringsegments",                                                      { "left", "right", "top", "bottom" } },
        { "guardringfillimplant",                                                   false },
        { "guardringfillwell",                                                      false },
        { "botwelltapwidth",                                                        technology.get_dimension("Minimum M1 Width") },
        { "botwelltapspace",                                                        technology.get_dimension("Minimum M1 Space") },
        { "botwelltapextendleft",                                                   0 },
        { "botwelltapextendright",                                                  0 },
        { "drawstopgatetopgatecut",                                                    false },
        { "drawstopgatebotgatecut",                                                    false },
        { "leftpolylines",                                                          {} },
        { "rightpolylines",                                                         {} },
        { "drawrotationmarker",                                                     false }
    )
end

function check(_P)
    if (_P.gatespace % 2) ~= (_P.sdwidth % 2) then
        return false, "gatespace and sdwidth must both be even or odd"
    end
    if (_P.sdmetalwidth % 2) ~= (_P.sdwidth % 2) then
        return false, string.format("sdmetalwidth and sdwidth must both be even or odd (%d vs %d)", _P.sdmetalwidth, _P.sdwidth)
    end
    if _P.sdviawidth < _P.sdwidth then
        return false, "sdviawidth must not be smaller than sdwidth"
    end
    if _P.sdmetalwidth < _P.sdviawidth then
        return false, "sdmetalwidth must not be smaller than sdviawidth"
    end
    if _P.sourcesize < 0 then
        return false, string.format("sourcesize (%d) can not be negative or larger than 'fwidth' (%d)", _P.sourcesize, _P.fwidth)
    end
    if _P.drainsize < 0 then
        return false, string.format("drainsize (%d) can not be negative or larger than 'fwidth' (%d)", _P.drainsize, _P.fwidth)
    end
    if _P.sourceviasize < 0 then
        return false, string.format("sourceviasize (%d) can not be negative or larger than 'fwidth' (%d)", _P.sourceviasize, _P.fwidth)
    end
    if _P.drainviasize < 0 then
        return false, string.format("drainviasize (%d) can not be negative or larger than 'fwidth' (%d)", _P.drainviasize, _P.fwidth)
    end
    if _P.shortdevice and ((_P.sourcesize % 2) ~= (_P.sdwidth % 2)) then
        return false, "gatespace and sdwidth must both be even or odd when shortdevice is true"
    end
    if not (not _P.endleftwithgate or (_P.gatelength % 2 == 0)) then
        return false, "gatelength must be even when endleftwithgate is true"
    end
    if not (not _P.endrightwithgate or (_P.gatelength % 2 == 0)) then
        return false, "gatelength must be even when endrightwithgate is true"
    end
    if
        _P.shortdevice and
        (_P.shortdeviceleftoffset > 0 or _P.shortdevicerightoffset > 0) and
        (_P.fingers - _P.shortdevicerightoffset - _P.shortdeviceleftoffset <= 0) then
        return false, "can't short device with zero fingers and non-zero short offsets"
    end
    return true
end

function layout(transistor, _P)
    local gatepitch = _P.gatelength + _P.gatespace
    --local leftactext
    --if _P.endleftwithgate then
    --    leftactext = _P.gatespace + _P.gatelength / 2
    --else
    --    leftactext = (_P.gatespace + _P.sdwidth) / 2 + _P.actext
    --end
    --local rightactext
    --if _P.endrightwithgate then
    --    rightactext = _P.gatespace + _P.gatelength / 2
    --else
    --    rightactext = (_P.gatespace + _P.sdwidth) / 2 + _P.actext
    --end
    local leftactext = (_P.gatespace + _P.sdwidth) / 2 + _P.actext
    local rightactext = (_P.gatespace + _P.sdwidth) / 2 + _P.actext
    local leftactauxext = _P.endleftwithgate and _P.gatelength / 2 - _P.sdwidth / 2 + _P.gatespace / 2 or 0
    local rightactauxext = _P.endrightwithgate and _P.gatelength / 2 - _P.sdwidth / 2 + _P.gatespace / 2 or 0
    local activewidth = _P.fingers * _P.gatelength + (_P.fingers - 1) * _P.gatespace + _P.leftfloatingdummies * gatepitch + _P.rightfloatingdummies * gatepitch

    local topgateshift = enable(_P.drawtopgate, _P.topgatespace + _P.topgatewidth)
    local botgateshift = enable(_P.drawbotgate, _P.botgatespace + _P.botgatewidth)
    local gateaddtop = math.max(_P.gtopext, topgateshift) + _P.gtopextadd
    local gateaddbot = math.max(_P.gbotext, botgateshift) + _P.gbotextadd

    local drainshift = enable(_P.connectdrain, _P.connectdrainwidth + _P.connectdrainspace)
    local sourceshift = enable(_P.connectsource, _P.connectsourcewidth + _P.connectsourcespace)
    if _P.channeltype == "pmos" then
        drainshift, sourceshift = sourceshift, drainshift
    end

    local hasgatecut = not _P.simulatemissinggatecut and technology.has_layer(generics.other("gatecut"))

    -- active
    if _P.drawactive then
        geometry.rectanglebltr(transistor, generics.other("active"),
            point.create(-leftactauxext, 0),
            point.create(activewidth + leftactext + rightactext + rightactauxext, _P.fwidth)
        )
        transistor:add_area_anchor_bltr("active",
            point.create(-leftactauxext, 0),
            point.create(activewidth + leftactext + rightactext + rightactauxext, _P.fwidth)
        )
        if _P.drawtopactivedummy then
            geometry.rectanglebltr(transistor, generics.other("active"),
                point.create(-leftactauxext, _P.fwidth + _P.topactivedummysep),
                point.create(activewidth + leftactext + rightactext + rightactauxext, _P.fwidth + _P.topactivedummysep + _P.topactivedummywidth)
            )
        end
        if _P.drawbotactivedummy then
            geometry.rectanglebltr(transistor, generics.other("active"),
                point.create(-leftactauxext, -_P.botactivedummysep - _P.botactivedummywidth),
                point.create(activewidth + leftactext + rightactext + rightactauxext, -_P.botactivedummysep)
            )
        end
    end

    -- gates
    -- base coordinates of a gate
    -- needed throughout the cell by various drawings
    local gateblx = leftactext + _P.leftfloatingdummies * gatepitch
    local gatebly = -gateaddbot
    local gatetrx = gateblx + _P.gatelength
    local gatetry = _P.fwidth + gateaddtop

    if hasgatecut then
        -- gate cut
        if _P.drawtopgatecut then
            geometry.rectanglebltr(transistor,
                generics.other("gatecut"),
                point.create(
                    gateblx - _P.topgatecutleftext,
                    _P.fwidth + _P.topgatecutspace
                ),
                point.create(
                    gatetrx + (_P.fingers - 1) * gatepitch + _P.topgatecutrightext,
                    _P.fwidth + _P.topgatecutspace + _P.topgatecutwidth
                )
            )
        end
        if _P.drawbotgatecut then
            geometry.rectanglebltr(transistor,
                generics.other("gatecut"),
                point.create(
                    gateblx - _P.botgatecutleftext,
                    -_P.botgatecutspace - _P.botgatecutwidth
                ),
                point.create(
                    gatetrx + (_P.fingers - 1) * gatepitch + _P.botgatecutrightext,
                    -_P.botgatecutspace
                )
            )
        end
    else -- not hasgatecut
        if _P.drawtopgatecut then
            gatetry = _P.fwidth + _P.topgatecutspace
        end
        if _P.drawbotgatecut then
            gatebly = -_P.botgatecutspace
        end
    end

    -- main gates
    for i = 1, _P.fingers do
        geometry.rectanglebltr(transistor,
            generics.other("gate"),
            point.create(gateblx + (i - 1) * gatepitch, gatebly),
            point.create(gatetrx + (i - 1) * gatepitch, gatetry)
        )
        -- generic always-available gate anchors
        transistor:add_area_anchor_bltr(
            string.format("gate%d", i),
            point.create(gateblx + (i - 1) * gatepitch, gatebly),
            point.create(gatetrx + (i - 1) * gatepitch, gatetry)
        )
        transistor:add_area_anchor_bltr(
            string.format("gate-%d", i),
            point.create(gateblx + (_P.fingers - i) * gatepitch, gatebly),
            point.create(gatetrx + (_P.fingers - i) * gatepitch, gatetry)
        )
    end
    transistor:add_area_anchor_bltr(
        "leftgate",
        point.create(gateblx + (1 - 1) * gatepitch, gatebly),
        point.create(gatetrx + (1 - 1) * gatepitch, gatetry)
    )
    transistor:add_area_anchor_bltr(
        "rightgate",
        point.create(gateblx + (_P.fingers - 1) * gatepitch, gatebly),
        point.create(gatetrx + (_P.fingers - 1) * gatepitch, gatetry)
    )

    -- gate marker
    for i = 1, _P.fingers do
        geometry.rectanglebltr(transistor,
            generics.other(string.format("gatemarker%d", _P.gatemarker)),
            point.create(gateblx + (i - 1) * gatepitch, gatebly),
            point.create(gatetrx + (i - 1) * gatepitch, gatetry)
        )
    end

    -- left/right gates
    if _P.endleftwithgate then
        geometry.rectanglebltr(transistor,
            generics.other("gate"),
            point.create(gateblx - gatepitch, gatebly),
            point.create(gatetrx - gatepitch, gatetry)
        )
        transistor:add_area_anchor_bltr(
            "endleftgate",
            point.create(gateblx - gatepitch, gatebly),
            point.create(gatetrx - gatepitch, gatetry)
        )
    end
    if _P.endrightwithgate then
        geometry.rectanglebltr(transistor,
            generics.other("gate"),
            point.create(gateblx + _P.fingers * gatepitch, gatebly),
            point.create(gatetrx + _P.fingers * gatepitch, gatetry)
        )
        transistor:add_area_anchor_bltr(
            "endrightgate",
            point.create(gateblx + _P.fingers * gatepitch, gatebly),
            point.create(gatetrx + _P.fingers * gatepitch, gatetry)
        )
    end

    -- mosfet marker
    -- FIXME: check proper alignment after source/drain contacts are placed
    if _P.fingers > 0 then
        if _P.mosfetmarkeralignatsourcedrain then
            geometry.rectanglebltr(transistor,
                generics.other(string.format("mosfetmarker%d", _P.mosfetmarker)),
                point.create(0, 0),
                point.create(_P.fingers * gatepitch, _P.fwidth)
            )
        else
            geometry.rectanglebltr(transistor,
                generics.other(string.format("mosfetmarker%d", _P.mosfetmarker)),
                point.create(leftactext, 0),
                point.create(leftactext + _P.fingers * gatepitch - _P.gatespace,  _P.fwidth)
            )
        end
    end

    -- left and right polylines
    -- FIXME: probably wrong without endleftwithgate == true and endrightwithgate == true
    local leftpolyoffset = gateblx - gatepitch
    for i, polyline in ipairs(_P.leftpolylines) do
        if not polyline.length then
            cellerror("basic/mosfet: leftpolyline entry does not have a 'length' field")
        end
        if not polyline.space then
            cellerror("basic/mosfet: leftpolyline entry does not have a 'space' field")
        end
        geometry.rectanglebltr(transistor,
            generics.other("gate"),
            point.create(leftpolyoffset - polyline.space - polyline.length, gatebly),
            point.create(leftpolyoffset - polyline.space, gatetry)
        )
        transistor:add_area_anchor_bltr(
            string.format("leftpolyline%d", i),
            point.create(leftpolyoffset - polyline.space - polyline.length, gatebly),
            point.create(leftpolyoffset - polyline.space, gatetry)
        )
        leftpolyoffset = leftpolyoffset - polyline.length - polyline.space
    end
    local rightpolyoffset = gatetrx + _P.fingers * gatepitch
    for i, polyline in ipairs(_P.rightpolylines) do
        if not polyline.length then
            cellerror("basic/mosfet: rightpolyline entry does not have a 'length' field")
        end
        if not polyline.space then
            cellerror("basic/mosfet: rightpolyline entry does not have a 'space' field")
        end
        geometry.rectanglebltr(transistor,
            generics.other("gate"),
            point.create(rightpolyoffset + polyline.space, gatebly),
            point.create(rightpolyoffset + polyline.space + polyline.length, gatetry)
        )
        transistor:add_area_anchor_bltr(
            string.format("rightpolyline%d", i),
            point.create(rightpolyoffset + polyline.space, gatebly),
            point.create(rightpolyoffset + polyline.space + polyline.length, gatetry)
        )
        rightpolyoffset = rightpolyoffset + polyline.length + polyline.space
    end

    -- stop gates
    if _P.drawleftstopgate then
        local bly = gatebly
        local try = gatetry
        if _P.drawstopgatetopgatecut then
            try = _P.fwidth + _P.topgatecutspace
            geometry.rectanglebltr(transistor,
                generics.other("gatecut"),
                point.create(
                    gateblx - (_P.leftfloatingdummies + 1) * gatepitch - _P.topgatecutleftext,
                    _P.fwidth + _P.topgatecutspace
                ),
                point.create(
                    gatetrx - (_P.leftfloatingdummies + 1) * gatepitch + _P.topgatecutrightext,
                    _P.fwidth + _P.topgatecutspace + _P.topgatecutwidth
                )
            )
        end
        if _P.drawstopgatebotgatecut then
            bly = -_P.botgatecutspace
            geometry.rectanglebltr(transistor,
                generics.other("gatecut"),
                point.create(
                    gateblx - (_P.leftfloatingdummies + 1) * gatepitch - _P.botgatecutleftext,
                    -_P.botgatecutspace - _P.botgatecutwidth
                ),
                point.create(
                    gatetrx - (_P.leftfloatingdummies + 1) * gatepitch + _P.botgatecutrightext,
                    -_P.botgatecutspace
                )
            )
        end
        geometry.rectanglebltr(transistor,
            generics.other("diffusionbreakgate"),
            point.create(gateblx - (_P.leftfloatingdummies + 1) * gatepitch, bly),
            point.create(gatetrx - (_P.leftfloatingdummies + 1) * gatepitch, try)
        )
        transistor:add_area_anchor_bltr("leftstopgate",
            point.create(gateblx - (_P.leftfloatingdummies + 1) * gatepitch, bly),
            point.create(gatetrx - (_P.leftfloatingdummies + 1) * gatepitch, try)
        )
    end

    if _P.drawrightstopgate then
        local bly = gatebly
        local try = gatetry
        if _P.drawstopgatetopgatecut then
            try = _P.fwidth + _P.topgatecutspace
            geometry.rectanglebltr(transistor,
                generics.other("gatecut"),
                point.create(
                    gateblx + (_P.fingers + _P.rightfloatingdummies) * gatepitch - _P.topgatecutleftext,
                    _P.fwidth + _P.topgatecutspace
                ),
                point.create(
                    gatetrx + (_P.fingers + _P.rightfloatingdummies) * gatepitch + _P.topgatecutrightext,
                    _P.fwidth + _P.topgatecutspace + _P.topgatecutwidth
                )
            )
        end
        if _P.drawstopgatebotgatecut then
            bly = -_P.botgatecutspace
            geometry.rectanglebltr(transistor,
                generics.other("gatecut"),
                point.create(
                    gateblx + (_P.fingers + _P.rightfloatingdummies) * gatepitch - _P.botgatecutleftext,
                    -_P.botgatecutspace - _P.botgatecutwidth
                ),
                point.create(
                    gatetrx + (_P.fingers + _P.rightfloatingdummies) * gatepitch + _P.botgatecutrightext,
                    -_P.botgatecutspace
                )
            )
        end
        geometry.rectanglebltr(transistor,
            generics.other("diffusionbreakgate"),
            point.create(gateblx + (_P.fingers + _P.rightfloatingdummies) * gatepitch, bly),
            point.create(gatetrx + (_P.fingers + _P.rightfloatingdummies) * gatepitch, try)
        )
        transistor:add_area_anchor_bltr("rightstopgate",
            point.create(gateblx + (_P.fingers + _P.rightfloatingdummies) * gatepitch, bly),
            point.create(gatetrx + (_P.fingers + _P.rightfloatingdummies) * gatepitch, try)
        )
    end

    -- floating dummy gates
    for i = 1, _P.leftfloatingdummies do
        geometry.rectanglebltr(transistor,
            generics.other("gate"),
            point.create(gateblx - i * gatepitch, gatebly),
            point.create(gatetrx - i * gatepitch, gatetry)
        )
        geometry.rectanglebltr(transistor,
            generics.other("floatinggatemarker"),
            point.create(gateblx - i * gatepitch, gatebly),
            point.create(gatetrx - i * gatepitch, gatetry)
        )
    end
    for i = 1, _P.rightfloatingdummies do
        geometry.rectanglebltr(transistor,
            generics.other("gate"),
            point.create(gateblx + (_P.fingers + i - 1) * gatepitch, gatebly),
            point.create(gatetrx + (_P.fingers + i - 1) * gatepitch, gatetry)
        )
        geometry.rectanglebltr(transistor,
            generics.other("floatinggatemarker"),
            point.create(gateblx + (_P.fingers + i - 1) * gatepitch, gatebly),
            point.create(gatetrx + (_P.fingers + i - 1) * gatepitch, gatetry)
        )
    end

    -- threshold voltage
    geometry.rectanglebltr(transistor,
        generics.vthtype(_P.channeltype, _P.vthtype),
        point.create(
            _P.vthtypealignleftwithactive and
                -leftactauxext - _P.extendvthtypeleft or
                -leftactauxext - _P.extendvthtypeleft,
            _P.vthtypealignbottomwithactive and
                -_P.extendvthtypebottom or
                gatebly - _P.extendvthtypebottom
        ),
        point.create(
            _P.vthtypealignrightwithactive and
                activewidth + leftactext + rightactext + rightactauxext + _P.extendvthtyperight or
                activewidth + leftactext + rightactext + rightactauxext + _P.extendvthtyperight,
            _P.vthtypealigntopwithactive and
                _P.fwidth + _P.extendvthtypetop or
                gatetry + _P.extendvthtypetop
        )
    )

    -- implant
    geometry.rectanglebltr(transistor,
        generics.implant(_P.channeltype),
        point.create(
            _P.implantalignleftwithactive and
                -leftactauxext - _P.extendimplantleft or
                -leftactauxext - _P.extendimplantleft,
            _P.implantalignbottomwithactive and
                -_P.extendimplantbottom or
                gatebly - _P.extendimplantbottom
        ),
        point.create(
            _P.implantalignrightwithactive and
                activewidth + leftactext + rightactext + rightactauxext + _P.extendimplantright or
                activewidth + leftactext + rightactext + rightactauxext + _P.extendimplantright,
            _P.implantaligntopwithactive and
                _P.fwidth + _P.extendimplanttop or
                gatetry + _P.extendimplanttop
        )
    )

    -- oxide thickness
    geometry.rectanglebltr(transistor,
        generics.oxide(_P.oxidetype),
        point.create(
            _P.oxidetypealignleftwithactive and
                -leftactauxext - _P.extendoxideleft or
                -leftactauxext - _P.extendoxideleft,
            _P.oxidetypealignbottomwithactive and
                -_P.extendoxidebottom or
                gatebly - _P.extendoxidebottom
        ),
        point.create(
            _P.oxidetypealignrightwithactive and
                activewidth + leftactext + rightactext + rightactauxext + _P.extendoxideright or
                activewidth + leftactext + rightactext + rightactauxext + _P.extendoxideright,
            _P.oxidetypealigntopwithactive and
                _P.fwidth + _P.extendoxidetop or
                gatetry + _P.extendoxidetop
        )
    )

    -- rotation marker
    if _P.drawrotationmarker then
        geometry.rectanglebltr(transistor,
            generics.other("rotationmarker"),
            point.create(-leftactauxext - _P.extendrotationmarkerleft, -_P.extendrotationmarkerbottom),
            point.create(activewidth + leftactext + rightactext + rightactauxext + _P.extendrotationmarkerright, _P.fwidth + _P.extendrotationmarkertop)
        )
    end

    -- lvs marker
    if _P.lvsmarkeralignwithactive then
        geometry.rectanglebltr(transistor,
            generics.other(string.format("lvsmarker%d", _P.lvsmarker)),
            point.create(
                -leftactauxext - _P.extendlvsmarkerleft,
                -_P.extendlvsmarkerbottom
            ),
            point.create(
                activewidth + leftactext + rightactext + rightactauxext + _P.extendlvsmarkerright,
                _P.fwidth + _P.extendlvsmarkertop
            )
        )
    else
        geometry.rectanglebltr(transistor,
            generics.other(string.format("lvsmarker%d", _P.lvsmarker)),
            point.create(
                -leftactauxext - _P.extendlvsmarkerleft,
                gatebly - _P.extendlvsmarkerbottom
            ),
            point.create(
                activewidth + leftactext + rightactext + rightactauxext + _P.extendlvsmarkerright,
                gatetry + _P.extendlvsmarkertop
            )
        )
    end

    -- well
    local wellbl = point.create(
        -leftactauxext - _P.extendwellleft,
        -math.max(_P.extendwellbottom, enable(_P.drawbotwelltap, _P.botwelltapspace + _P.botwelltapwidth))
    )
    local welltr = point.create(
        activewidth + leftactext + rightactext + rightactauxext + _P.extendwellright,
        _P.fwidth + math.max(_P.extendwelltop, enable(_P.drawtopwelltap, _P.topwelltapspace + _P.topwelltapwidth))
    )
    if _P.drawwell then
        geometry.rectanglebltr(transistor,
            generics.other(_P.flippedwell and
                (_P.channeltype == "nmos" and "nwell" or "pwell") or
                (_P.channeltype == "nmos" and "pwell" or "nwell")
            ),
            wellbl, welltr
        )
    end
    transistor:add_area_anchor_bltr("well", wellbl, welltr)

    -- well taps
    if _P.drawtopwelltap then
        transistor:merge_into(pcell.create_layout("auxiliary/welltap", "topwelltap", {
            contype = _P.flippedwell and (_P.channeltype == "nmos" and "n" or "p") or (_P.channeltype == "nmos" and "p" or "n"),
            width = activewidth + _P.topwelltapextendleft + _P.topwelltapextendright,
            height = _P.topwelltapwidth,
        }):translate(
            (_P.topwelltapextendright - _P.topwelltapextendleft) / 2,
            _P.fwidth + _P.topwelltapspace
        ))
    end
    if _P.drawbotwelltap then
        transistor:merge_into(pcell.create_layout("auxiliary/welltap", "botwelltap", {
            contype = _P.flippedwell and (_P.channeltype == "nmos" and "n" or "p") or (_P.channeltype == "nmos" and "p" or "n"),
            width = activewidth + _P.botwelltapextendleft + _P.botwelltapextendright,
            height = _P.botwelltapwidth,
        }):translate(
            (_P.topwelltapextendright - _P.topwelltapextendleft) / 2,
            _P.fwidth + _P.topwelltapspace
        ))
    end

    local guardring -- variable needs to be visible for alignment box setting
    if _P.drawguardring then
        guardring = pcell.create_layout("auxiliary/guardring", "guardring", {
            contype = _P.flippedwell and (_P.channeltype == "nmos" and "n" or "p") or (_P.channeltype == "nmos" and "p" or "n"),
            ringwidth = _P.guardringwidth,
            holewidth = activewidth + leftactauxext + leftactext + rightactext + rightactauxext + 2 * _P.guardringxsep,
            holeheight = _P.fwidth + 2 * _P.guardringysep,
            fillwell = true,
            drawsegments = _P.guardringsegments,
            fillwell = _P.guardringfillwell,
            fillimplant = _P.guardringfillimplant,
        })
        guardring:move_point(guardring:get_anchor("innerbottomleft"), point.create(-leftactauxext, 0))
        guardring:translate(-_P.guardringxsep, -_P.guardringysep)
        transistor:merge_into(guardring)
        transistor:add_area_anchor_bltr("outerguardring",
            guardring:get_anchor("outerbottomleft"),
            guardring:get_anchor("outertopright")
        )
        transistor:add_area_anchor_bltr("innerguardring",
            guardring:get_anchor("innerbottomleft"),
            guardring:get_anchor("innertopright")
        )
    end

    -- gate contacts
    if _P.drawtopgate then
        for i = 1, _P.fingers do
            local contactfun = _P.drawtopgatestrap and geometry.contactbarebltr or geometry.contactbltr
            contactfun(transistor,
                "gate",
                point.create(gateblx + (i - 1) * gatepitch, _P.fwidth + _P.topgatespace),
                point.create(gatetrx + (i - 1) * gatepitch, _P.fwidth + _P.topgatespace + _P.topgatewidth)
            )
            transistor:add_area_anchor_bltr(string.format("topgate%d", i),
                point.create(gateblx + (i - 1) * gatepitch, _P.fwidth + _P.topgatespace),
                point.create(gatetrx + (i - 1) * gatepitch, _P.fwidth + _P.topgatespace + _P.topgatewidth)
            )
        end
    end
    if _P.fingers > 0 and _P.drawtopgatestrap then
        local bl = point.create(gateblx + (1 - 1) * gatepitch - _P.topgateleftextension, _P.fwidth + _P.topgatespace)
        local tr = point.create(gatetrx + (_P.fingers - 1) * gatepitch + _P.topgaterightextension, _P.fwidth + _P.topgatespace + _P.topgatewidth)
        geometry.rectanglebltr(transistor, generics.metal(1), bl, tr)
        transistor:add_area_anchor_bltr("topgatestrap", bl, tr)
        if _P.drawtopgatevia and _P.topgatemetal > 1 then
            if _P.topgatecontinuousvia then
                geometry.viabltr_xcontinuous(transistor, 1, _P.topgatemetal, bl, tr)
            else
                geometry.viabltr(transistor, 1, _P.topgatemetal, bl, tr)
            end
        end
    end
    if _P.drawbotgate then
        for i = 1, _P.fingers do
            local contactfun = _P.drawbotgatestrap and geometry.contactbarebltr or geometry.contactbltr
            contactfun(transistor,
                "gate",
                point.create(gateblx + (i - 1) * gatepitch, -_P.botgatespace - _P.botgatewidth),
                point.create(gatetrx + (i - 1) * gatepitch, -_P.botgatespace)
            )
            transistor:add_area_anchor_bltr(string.format("botgate%d", i),
                point.create(gateblx + (i - 1) * gatepitch, -_P.botgatespace - _P.botgatewidth),
                point.create(gatetrx + (i - 1) * gatepitch, -_P.botgatespace)
            )
        end
    end
    if _P.fingers > 0 and _P.drawbotgatestrap then
        local bl = point.create(gateblx + (1 - 1) * gatepitch - _P.botgateleftextension, -_P.botgatespace - _P.botgatewidth)
        local tr = point.create(gatetrx + (_P.fingers - 1) * gatepitch + _P.botgaterightextension, -_P.botgatespace)
        geometry.rectanglebltr(transistor, generics.metal(1), bl, tr)
        transistor:add_area_anchor_bltr("botgatestrap", bl, tr)
        if _P.drawbotgatevia and _P.botgatemetal > 1 then
            if _P.botgatecontinuousvia then
                geometry.viabltr_xcontinuous(transistor, 1, _P.botgatemetal, bl, tr)
            else
                geometry.viabltr(transistor, 1, _P.botgatemetal, bl, tr)
            end
        end
    end

    local sdviashift = (_P.sdviawidth - _P.sdwidth) / 2
    local sdmetalshift = (_P.sdmetalwidth - _P.sdwidth) / 2

    -- source/drain contacts and vias
    local sourceoffset = _P.sourcealign == "top" and _P.fwidth - _P.sourcesize or 0
    local sourceviaoffset = _P.sourceviaalign == "top" and _P.fwidth - _P.sourceviasize or 0
    local drainoffset = _P.drainalign == "top" and _P.fwidth - _P.drainsize or 0
    local drainviaoffset = _P.drainviaalign == "top" and _P.fwidth - _P.drainviasize or 0
    if _P.drawsourcedrain ~= "none" then
        -- source
        if _P.drawsourcedrain == "both" or _P.drawsourcedrain == "source" then
            for i = 1, _P.fingers + 1, 2 do
                local shift = gateblx - (_P.gatespace + _P.sdwidth) / 2 + (i - 1) * gatepitch
                local bl = point.create(shift, sourceoffset)
                local tr = point.create(shift + _P.sdwidth, sourceoffset + _P.sourcesize)
                if not aux.any_of(i, _P.excludesourcedraincontacts) then
                    geometry.contactbarebltr(transistor, "sourcedrain", bl, tr)
                    if _P.drawsourcevia and _P.sourceviametal > 1 and
                       not (i == 1 and not _P.drawfirstsourcevia or
                        i == _P.fingers + 1 and not _P.drawlastsourcevia) then
                        geometry.viabarebltr(transistor, 1, _P.sourceviametal,
                            point.create(shift - sdviashift, sourceviaoffset),
                            point.create(shift + _P.sdviawidth - sdviashift, sourceviaoffset + _P.sourceviasize)
                        )
                    end
                    geometry.rectanglebltr(transistor, generics.metal(1),
                        point.create(shift - sdmetalshift, sourceoffset),
                        point.create(shift + _P.sdmetalwidth - sdmetalshift, sourceoffset + _P.sourcesize)
                    )
                    for metal = 2, _P.sourceviametal do
                        geometry.rectanglebltr(transistor, generics.metal(metal),
                            point.create(shift - sdmetalshift, sourceviaoffset),
                            point.create(shift + _P.sdmetalwidth - sdmetalshift, sourceviaoffset + _P.sourceviasize)
                        )
                    end
                end
                -- anchors
                transistor:add_area_anchor_bltr(string.format("sourcedrain%d", i), bl, tr)
                transistor:add_area_anchor_bltr(string.format("sourcedrain%d", i - _P.fingers - 2), bl, tr)
                transistor:add_area_anchor_bltr(string.format("sourcedrainmetal%d", i),
                    point.create(shift - sdmetalshift, sourceviaoffset),
                    point.create(shift + _P.sdmetalwidth - sdmetalshift, sourceviaoffset + _P.sourceviasize)
                )
                transistor:add_area_anchor_bltr(string.format("sourcedrainmetal%d", i - _P.fingers - 2),
                    point.create(shift - sdmetalshift, sourceviaoffset),
                    point.create(shift + _P.sdmetalwidth - sdmetalshift, sourceviaoffset + _P.sourceviasize)
                )
            end
        end
        -- drain
        if _P.drawsourcedrain == "both" or _P.drawsourcedrain == "drain" then
            for i = 2, _P.fingers + 1, 2 do
                local shift = gateblx - (_P.gatespace + _P.sdwidth) / 2 + (i - 1) * gatepitch
                local bl = point.create(shift, drainoffset)
                local tr = point.create(shift + _P.sdwidth, drainoffset + _P.drainsize)
                if not aux.any_of(i, _P.excludesourcedraincontacts) then
                    geometry.contactbarebltr(transistor, "sourcedrain", bl, tr)
                    if _P.drawdrainvia and _P.drainviametal > 1 and
                       not (i == 2 and not _P.drawfirstdrainvia or
                        i == _P.fingers + 1 and not _P.drawlastdrainvia) then
                        geometry.viabarebltr(transistor, 1, _P.drainviametal,
                            point.create(shift - sdviashift, drainviaoffset),
                            point.create(shift + _P.sdviawidth - sdviashift, drainviaoffset + _P.drainviasize)
                        )
                    end
                    geometry.rectanglebltr(transistor, generics.metal(1),
                        point.create(shift - sdmetalshift, drainoffset),
                        point.create(shift + _P.sdmetalwidth - sdmetalshift, drainoffset + _P.drainsize)
                    )
                    for metal = 2, _P.drainviametal do
                        geometry.rectanglebltr(transistor, generics.metal(metal),
                            point.create(shift - sdmetalshift, drainviaoffset),
                            point.create(shift + _P.sdmetalwidth - sdmetalshift, drainviaoffset + _P.drainviasize)
                        )
                    end
                end
                -- anchors
                transistor:add_area_anchor_bltr(string.format("sourcedrain%d", i), bl, tr)
                transistor:add_area_anchor_bltr(string.format("sourcedrain%d", i - _P.fingers - 2), bl, tr)
                transistor:add_area_anchor_bltr(string.format("sourcedrainmetal%d", i),
                point.create(shift - sdmetalshift, drainviaoffset),
                point.create(shift + _P.sdmetalwidth - sdmetalshift, drainviaoffset + _P.drainviasize)
            )
                transistor:add_area_anchor_bltr(string.format("sourcedrainmetal%d", i - _P.fingers - 2),
                    point.create(shift - sdmetalshift, drainviaoffset),
                    point.create(shift + _P.sdmetalwidth - sdmetalshift, drainviaoffset + _P.drainviasize)
                )
            end
        end
    end

    -- diode connected
    if _P.diodeconnected then
        for i = 2, _P.fingers + 1, 2 do
            if _P.drawtopgatestrap then
                geometry.rectanglebltr(transistor, generics.metal(1),
                    transistor:get_area_anchor(string.format("sourcedrain%d", i)).tl:translate_x(-sdmetalshift),
                    transistor:get_area_anchor(string.format("sourcedrain%d", i)).tr:translate_x(sdmetalshift) ..
                    transistor:get_area_anchor(string.format("topgatestrap", i)).br
                )
            end
            if _P.drawbotgatestrap then
                geometry.rectanglebltr(transistor, generics.metal(1),
                    transistor:get_area_anchor(string.format("sourcedrain%d", i)).bl:translate_x(-sdmetalshift) ..
                    transistor:get_area_anchor(string.format("botgatestrap", i)).tl,
                    transistor:get_area_anchor(string.format("sourcedrain%d", i)).br:translate_x(sdmetalshift)
                )
            end
        end
    end

    -- source connections
    if _P.drawsourceconnections and not _P.connectsourceinline then
        -- connections to strap
        local sourceinvert = (_P.channeltype == "pmos")
        if _P.connectsourceinverse then
            sourceinvert = not sourceinvert
        end
        for i = 1, _P.fingers + 1, 2 do
            local shift = leftactext - (_P.gatespace + _P.sdwidth) / 2 + (i - 1) * gatepitch - sdmetalshift
            if sourceinvert then
                if sourceoffset + _P.sourcesize < _P.fwidth + _P.connectsourcespace then -- don't draw connections if they are malformed
                    if not (i == 1 and not _P.drawfirstsourcevia or i == _P.fingers + 1 and not _P.drawlastsourcevia) then
                        geometry.rectanglebltr(transistor, generics.metal(_P.sourcemetal),
                            point.create(shift, sourceoffset + _P.sourcesize),
                            point.create(shift + _P.sdmetalwidth, _P.fwidth + _P.connectsourcespace)
                        )
                    end
                end
                if _P.connectsourceboth then
                    if -_P.connectsourceotherspace < sourceoffset then -- don't draw connections if they are malformed
                        if not (i == 1 and not _P.drawfirstsourcevia or i == _P.fingers + 1 and not _P.drawlastsourcevia) then
                            geometry.rectanglebltr(transistor, generics.metal(_P.sourcemetal),
                                point.create(shift, -_P.connectsourceotherspace),
                                point.create(shift + _P.sdmetalwidth, sourceoffset)
                            )
                        end
                    end
                end
            else
                if -_P.connectsourcespace < sourceoffset then -- don't draw connections if they are malformed
                    if not (i == 1 and not _P.drawfirstsourcevia or i == _P.fingers + 1 and not _P.drawlastsourcevia) then
                        geometry.rectanglebltr(transistor, generics.metal(_P.sourcemetal),
                            point.create(shift, -_P.connectsourcespace),
                            point.create(shift + _P.sdmetalwidth, sourceoffset)
                        )
                    end
                end
                if _P.connectsourceboth then
                    if sourceoffset + _P.sourcesize < _P.fwidth + _P.connectsourceotherspace then -- don't draw connections if they are malformed
                        if not (i == 1 and not _P.drawfirstsourcevia or i == _P.fingers + 1 and not _P.drawlastsourcevia) then
                            geometry.rectanglebltr(transistor, generics.metal(_P.sourcemetal),
                                point.create(shift, sourceoffset + _P.sourcesize),
                                point.create(shift + _P.sdmetalwidth, _P.fwidth + _P.connectsourceotherspace)
                            )
                        end
                    end
                end
            end
        end
    end

    -- source strap
    if _P.fingers > 0 then
        local blx = leftactext - (_P.gatespace + _P.sdmetalwidth) / 2
        local trx = blx + 2 * (_P.fingers // 2) * gatepitch + _P.sdmetalwidth
        if _P.connectsourceinline then
            local bly
            if _P.channeltype == "nmos" then
                if _P.connectsourceinverse then
                    bly = _P.fwidth - _P.connectsourcewidth - _P.connectsourceinlineoffset
                else
                    bly = _P.connectsourceinlineoffset
                end
            else
                if _P.connectsourceinverse then
                    bly = _P.connectsourceinlineoffset
                else
                    bly = _P.fwidth - _P.connectsourcewidth - _P.connectsourceinlineoffset
                end
            end
            if _P.drawsourcestrap then
                geometry.rectanglebltr(transistor, generics.metal(_P.sourcemetal),
                    point.create(blx - _P.connectsourceleftext, bly),
                    point.create(trx + _P.connectsourcerightext, bly + _P.connectsourcewidth)
                )
            end
            transistor:add_area_anchor_bltr("sourcestrap",
                point.create(blx - _P.connectsourceleftext, bly),
                point.create(trx + _P.connectsourcerightext, bly + _P.connectsourcewidth)
            )
        else
            local bly1, bly2
            if _P.channeltype == "nmos" then
                if _P.connectsourceinverse then
                    bly1 = _P.fwidth + _P.connectsourcespace
                    bly2 = -_P.connectsourceotherspace - _P.connectsourceotherwidth
                else
                    bly1 = -_P.connectsourcespace - _P.connectsourcewidth
                    bly2 = _P.fwidth + _P.connectsourceotherspace
                end
            else
                if _P.connectsourceinverse then
                    bly1 = -_P.connectsourcespace - _P.connectsourcewidth
                    bly2 = _P.fwidth + _P.connectsourceotherspace
                else
                    bly1 = _P.fwidth + _P.connectsourcespace
                    bly2 = -_P.connectsourceotherspace - _P.connectsourceotherwidth
                end
            end
            -- main strap
            if _P.drawsourcestrap then
                geometry.rectanglebltr(transistor, generics.metal(_P.sourcemetal),
                    point.create(blx - _P.connectsourceleftext, bly1),
                    point.create(trx + _P.connectsourcerightext, bly1 + _P.connectsourcewidth)
                )
                if _P.connectsourceboth then
                    -- other strap
                    geometry.rectanglebltr(transistor, generics.metal(_P.sourcemetal),
                        point.create(blx - _P.connectsourceotherleftext, bly2),
                        point.create(trx + _P.connectsourceotherrightext, bly2 + _P.connectsourceotherwidth)
                    )
                end
            end
            -- main anchor
            transistor:add_area_anchor_bltr("sourcestrap",
                point.create(blx - _P.connectsourceleftext, bly1),
                point.create(trx + _P.connectsourcerightext, bly1 + _P.connectsourcewidth)
            )
            if _P.connectsourceboth then
                -- other anchor
                transistor:add_area_anchor_bltr("othersourcestrap",
                    point.create(blx - _P.connectsourceotherleftext, bly2),
                    point.create(trx + _P.connectsourceotherrightext, bly2 + _P.connectsourceotherwidth)
                )
            end
        end
    end

    -- drain connections
    local draininvert = (channeltype == "pmos")
    if _P.connectdraininverse then
        draininvert = not draininvert
    end
    if _P.drawdrainconnections and not _P.connectdraininline then
        -- connections to strap
        local draininvert = (_P.channeltype == "pmos")
        if _P.connectdraininverse then
            draininvert = not draininvert
        end
        for i = 2, _P.fingers + 1, 2 do
            local shift = leftactext - (_P.gatespace + _P.sdwidth) / 2 + (i - 1) * gatepitch - sdmetalshift
            local conndrainoffset = _P.drainmetal > 1 and drainviaoffset or drainoffset
            local conndraintop = _P.drainmetal > 1 and _P.drainviasize or _P.drainsize
            if draininvert then
                if -_P.connectdrainspace < conndrainoffset then -- don't draw connections if they are malformed
                    if not (i == 2 and not _P.drawfirstdrainvia or i == _P.fingers + 1 and not _P.drawlastdrainvia) then
                        geometry.rectanglebltr(transistor, generics.metal(_P.drainmetal),
                            point.create(shift, -_P.connectdrainspace),
                            point.create(shift + _P.sdmetalwidth, conndrainoffset)
                        )
                    end
                end
                if _P.connectdrainboth then
                    if conndrainoffset + conndraintop < _P.fwidth + _P.connectdrainotherspace then -- don't draw connections if they are malformed
                       if not (i == 2 and not _P.drawfirstdrainvia or i == _P.fingers + 1 and not _P.drawlastdrainvia) then
                            geometry.rectanglebltr(transistor, generics.metal(_P.drainmetal),
                                point.create(shift, conndrainoffset + conndraintop),
                                point.create(shift + _P.sdmetalwidth, _P.fwidth + _P.connectdrainotherspace)
                            )
                        end
                    end
                end
            else
                if conndrainoffset + conndraintop < _P.fwidth + _P.connectdrainspace then -- don't draw connections if they are malformed
                   if not (i == 2 and not _P.drawfirstdrainvia or i == _P.fingers + 1 and not _P.drawlastdrainvia) then
                        geometry.rectanglebltr(transistor, generics.metal(_P.drainmetal),
                            point.create(shift, conndrainoffset + conndraintop),
                            point.create(shift + _P.sdmetalwidth, _P.fwidth + _P.connectdrainspace)
                        )
                    end
                end
                if _P.connectdrainboth then
                    if -_P.connectdrainotherspace < conndrainoffset then -- don't draw connections if they are malformed
                        if not (i == 2 and not _P.drawfirstdrainvia or i == _P.fingers + 1 and not _P.drawlastdrainvia) then
                            geometry.rectanglebltr(transistor, generics.metal(_P.drainmetal),
                                point.create(shift, -_P.connectdrainotherspace),
                                point.create(shift + _P.sdmetalwidth, conndrainoffset)
                            )
                        end
                    end
                end
            end
        end
    end

    -- drain strap
    if _P.fingers > 0 then
        local blx = leftactext - (_P.gatespace + _P.sdmetalwidth) / 2 + (2 - 1) * gatepitch
        local trx = leftactext - (_P.gatespace + _P.sdmetalwidth) / 2 + (2 * ((_P.fingers + 1) // 2) - 1) * gatepitch + _P.sdmetalwidth
        if _P.connectdraininline then
            local bly
            if _P.channeltype == "nmos" then
                if _P.connectdraininverse then
                    bly = _P.connectdraininlineoffset
                else
                    bly = _P.fwidth - _P.connectdrainwidth - _P.connectdraininlineoffset
                end
            else
                if _P.connectdraininverse then
                    bly = _P.fwidth - _P.connectdrainwidth - _P.connectdraininlineoffset
                else
                    bly = _P.connectdraininlineoffset
                end
            end
            if _P.drawdrainstrap then
                geometry.rectanglebltr(transistor, generics.metal(_P.drainmetal),
                    point.create(blx - _P.connectdrainleftext, bly),
                    point.create(trx + _P.connectdrainrightext, bly + _P.connectdrainwidth)
                )
            end
            transistor:add_area_anchor_bltr("drainstrap",
                point.create(blx - _P.connectdrainleftext, bly),
                point.create(trx + _P.connectdrainrightext, bly + _P.connectdrainwidth)
            )
        else
            local bly1, bly2
            if _P.channeltype == "nmos" then
                if _P.connectdraininverse then
                    bly1 = -_P.connectdrainspace - _P.connectdrainwidth
                    bly2 = _P.fwidth + _P.connectdrainotherspace
                else
                    bly1 = _P.fwidth + _P.connectdrainspace
                    bly2 = -_P.connectdrainotherspace - _P.connectdrainotherwidth
                end
            else
                if _P.connectdraininverse then
                    bly1 = _P.fwidth + _P.connectdrainspace
                    bly2 = -_P.connectdrainotherspace - _P.connectdrainotherwidth
                else
                    bly1 = -_P.connectdrainspace - _P.connectdrainwidth
                    bly2 = _P.fwidth + _P.connectdrainotherspace
                end
            end
            if _P.drawdrainstrap then
                -- main strap
                geometry.rectanglebltr(transistor, generics.metal(_P.drainmetal),
                    point.create(blx - _P.connectdrainleftext, bly1),
                    point.create(trx + _P.connectdrainrightext, bly1 + _P.connectdrainwidth)
                )
                if _P.connectdrainboth then
                    -- other strap
                    geometry.rectanglebltr(transistor, generics.metal(_P.drainmetal),
                        point.create(blx - _P.connectdrainotherleftext, bly2),
                        point.create(trx + _P.connectdrainotherrightext, bly2 + _P.connectdrainotherwidth)
                    )
                end
            end
            -- main anchor
            transistor:add_area_anchor_bltr("drainstrap",
                point.create(blx - _P.connectdrainleftext, bly1),
                point.create(trx + _P.connectdrainrightext, bly1 + _P.connectdrainwidth)
            )
            -- other anchor
            if _P.connectdrainboth then
                transistor:add_area_anchor_bltr("otherdrainstrap",
                    point.create(blx - _P.connectdrainotherleftext, bly2),
                    point.create(trx + _P.connectdrainotherrightext, bly2 + _P.connectdrainotherwidth)
                )
            end
        end
    end

    -- extra source/drain straps (unconnected, useful for arrays)
    if _P.drawextrabotstrap then
        local blx = leftactext - (_P.gatespace + _P.sdmetalwidth) / 2 + (_P.extrabotstrapleftalign - 1) * gatepitch
        local trx = blx + 2 * (_P.fingers // 2) * gatepitch + (_P.extrabotstraprightalign - _P.fingers) * gatepitch + _P.sdmetalwidth
        geometry.rectanglebltr(transistor, generics.metal(_P.extrabotstrapmetal),
            point.create(blx, -_P.extrabotstrapspace - _P.extrabotstrapwidth),
            point.create(trx, -_P.extrabotstrapspace)
        )
        -- anchors
        transistor:add_area_anchor_bltr("extrabotstrap",
            point.create(blx, -_P.extrabotstrapspace - _P.extrabotstrapwidth),
            point.create(trx, -_P.extrabotstrapspace)
        )
    end
    if _P.drawextratopstrap then
        local blx = leftactext - (_P.gatespace + _P.sdmetalwidth) / 2 + (_P.extrabotstrapleftalign - 1) * gatepitch
        local trx = blx + 2 * (_P.fingers // 2) * gatepitch + (_P.extrabotstraprightalign - _P.fingers) * gatepitch + _P.sdmetalwidth
        geometry.rectanglebltr(transistor, generics.metal(_P.extrabotstrapmetal),
            point.create(blx, _P.fwidth + _P.extratopstrapspace),
            point.create(trx, _P.fwidth + _P.extratopstrapspace + _P.extratopstrapwidth)
        )
        -- anchors
        transistor:add_area_anchor_bltr("extratopstrap",
            point.create(blx, _P.fwidth + _P.extratopstrapspace),
            point.create(trx, _P.fwidth + _P.extratopstrapspace + _P.extratopstrapwidth)
        )
    end

    -- short transistor
    if _P.shortdevice then
        if _P.shortlocation == "inline" then
            geometry.rectanglebltr(transistor, generics.metal(1),
                transistor:get_area_anchor(string.format("sourcedrain%d", 1 + _P.shortdeviceleftoffset)).br:translate(0, (_P.sourcesize - _P.sdwidth) / 2),
                transistor:get_area_anchor(string.format("sourcedrain%d", _P.fingers + 1 - _P.shortdevicerightoffset)).bl:translate(0, (_P.sourcesize + _P.sdwidth) / 2)
            )
        elseif _P.shortlocation == "top" then
            geometry.rectanglebltr(transistor, generics.metal(1),
                transistor:get_area_anchor(string.format("sourcedrain%d", 1 + _P.shortdeviceleftoffset)).tl:translate_y(_P.shortspace),
                transistor:get_area_anchor(string.format("sourcedrain%d", _P.fingers + 1 - _P.shortdevicerightoffset)).tr:translate_y(_P.shortspace + _P.shortwidth)
            )
            for i = 1 + _P.shortdeviceleftoffset, _P.fingers - _P.shortdevicerightoffset + 1 do
                geometry.rectanglebltr(transistor, generics.metal(1),
                    transistor:get_area_anchor(string.format("sourcedrain%d", i)).tl,
                    transistor:get_area_anchor(string.format("sourcedrain%d", i)).tr:translate_y(_P.shortspace)
                )
            end
        elseif _P.shortlocation == "bottom" then
            geometry.rectanglebltr(transistor, generics.metal(1),
                transistor:get_area_anchor(string.format("sourcedrain%d", 1 + _P.shortdeviceleftoffset)).bl:translate_y(-_P.shortspace - _P.shortwidth),
                transistor:get_area_anchor(string.format("sourcedrain%d", _P.fingers + 1 - _P.shortdevicerightoffset)).br:translate_y(-_P.shortspace)
            )
            for i = 1 + _P.shortdeviceleftoffset, _P.fingers - _P.shortdevicerightoffset + 1 do
                geometry.rectanglebltr(transistor, generics.metal(1),
                    transistor:get_area_anchor(string.format("sourcedrain%d", i)).bl:translate_y(-_P.shortspace),
                    transistor:get_area_anchor(string.format("sourcedrain%d", i)).br
                )
            end
        else
            -- can not happen
        end
    end

    -- anchors for source drain active regions
    for i = 1, _P.fingers + 1 do
        local shift = leftactext - (_P.gatespace + _P.sdwidth) / 2 + (i - 1) * gatepitch
        transistor:add_area_anchor_bltr(string.format("sourcedrainactive%d", i),
            point.create(shift, 0),
            point.create(shift + _P.sdwidth, _P.fwidth)
        )
    end

    -- alignmentbox
    if _P.drawguardring then
        transistor:inherit_alignment_box(guardring)
    else
        transistor:set_alignment_box(
            point.create(leftactext - (_P.gatespace + _P.sdwidth) / 2, 0),
            point.create(leftactext - (_P.gatespace + _P.sdwidth) / 2 + (_P.fingers + 1 - 1) * gatepitch, _P.fwidth),
            point.create(leftactext - (_P.gatespace + _P.sdwidth) / 2 + _P.sdwidth, 0),
            point.create(leftactext - (_P.gatespace + _P.sdwidth) / 2 + (_P.fingers + 1 - 1) * gatepitch + _P.sdwidth, _P.fwidth)
        )
    end

    -- special anchors for easier left/right alignment
    transistor:add_area_anchor_bltr(
        "sourcedrainactiveleft",
        transistor:get_area_anchor("sourcedrainactive1").bl,
        transistor:get_area_anchor("sourcedrainactive1").tr
    )
    transistor:add_area_anchor_bltr(
        "sourcedrainactiveright",
        transistor:get_area_anchor(string.format("sourcedrainactive%d", _P.fingers + 1)).bl,
        transistor:get_area_anchor(string.format("sourcedrainactive%d", _P.fingers + 1)).tr
    )
end

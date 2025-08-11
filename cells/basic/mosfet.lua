function parameters()
    pcell.add_parameters(
        { "channeltype(Channel Type)",                                                                  "nmos", posvals = set("nmos", "pmos"), info = "polarity of the mosfet. Can be either 'nmos' or 'pmos'." },
        { "drawimplant",                                                                                true, info = "switch to enable/disable implant drawing. Typically this should be enabled, as a missing implant will most likely cause both the DRC and the LVS to fail. However, in certain situations manual drawing of the implant can be beneficial" },
        { "implantalignwithactive",                                                                     false, info = "set reference points for implant extensions. If this is false, the implant extensions are autmatically calculated so that the implant covers all gates. With this option enabled, the implant extensions are referenced to the active region. This is useful for having precise control over the implant extensions in mosfet arrays with varying gate heights. This option sets left/right/top/bottom alignment, the dedicated switches can be used for more fine-grained control." },
        { "implantalignleftwithactive",                                                                 false, follow = "implantalignwithactive", info = "set reference point for implant left extensions. If this is false, the implant left extension is autmatically calculated so that the implant covers the left gates. With this option enabled, the implant left extension is referenced to the active region. This is useful for having precise control over the implant extensions in mosfet arrays with varying gate heights" },
        { "implantalignrightwithactive",                                                                false, follow = "implantalignwithactive", info = "set reference point for implant right extensions. If this is false, the implant right extension is autmatically calculated so that the implant covers the right gates. With this option enabled, the implant right extension is referenced to the active region. This is useful for having precise control over the implant extensions in mosfet arrays with varying gate heights" },
        { "implantaligntopwithactive",                                                                  false, follow = "implantalignwithactive", info = "set reference point for implant top extensions. If this is false, the implant top extension is autmatically calculated so that the implant covers the top part of all gates. With this option enabled, the implant top extension is referenced to the active region. This is useful for having precise control over the implant extensions in mosfet arrays with varying gate heights" },
        { "implantalignbottomwithactive",                                                               false, follow = "implantalignwithactive", info = "set reference point for implant bottom extensions. If this is false, the implant bottom extension is autmatically calculated so that the implant covers the bottom part of all gates. With this option enabled, the implant bottom extension is referenced to the active region. This is useful for having precise control over the implant extensions marker extensions in mosfet arrays with varying gate heights" },
        { "oxidetype(Oxide Thickness Type)",                                                            1, argtype = "integer", posvals = interval(1, inf), info = "oxide thickness index of the gate. This is a numeric index, starting from 1 (the default). The interpretation of this is up to the technology file" },
        { "oxidetypealignwithactive",                                                                   false, info = "set reference points for oxide thickness marker extensions. If this is false, the oxide thickness marker extensions are autmatically calculated so that the oxide thickness marker covers all gates. With this option enabled, the oxide thickness marker extensions are referenced to the active region. This is useful for having precise control over the oxide thickness marker extensions in mosfet arrays with varying gate heights. This option sets left/right/top/bottom alignment, the dedicated switches can be used for more fine-grained control." },
        { "oxidetypealignleftwithactive",                                                               false, follow = "oxidetypealignwithactive", info = "set reference point for oxide thickness marker left extensions. If this is false, the oxide thickness marker left extension is autmatically calculated so that the oxide thickness marker covers the left gates. With this option enabled, the oxide thickness marker left extension is referenced to the active region. This is useful for having precise control over the oxide thickness marker extensions in mosfet arrays with varying gate heights" },
        { "oxidetypealignrightwithactive",                                                              false, follow = "oxidetypealignwithactive", info = "set reference point for oxide thickness marker right extensions. If this is false, the oxide thickness marker right extension is autmatically calculated so that the oxide thickness marker covers the right gates. With this option enabled, the oxide thickness marker right extension is referenced to the active region. This is useful for having precise control over the oxide thickness marker extensions in mosfet arrays with varying gate heights" },
        { "oxidetypealigntopwithactive",                                                                false, follow = "oxidetypealignwithactive", info = "set reference point for oxide thickness marker top extensions. If this is false, the oxide thickness marker top extension is autmatically calculated so that the oxide thickness marker covers the top part of all gates. With this option enabled, the oxide thickness marker top extension is referenced to the active region. This is useful for having precise control over the oxide thickness marker extensions in mosfet arrays with varying gate heights" },
        { "oxidetypealignbottomwithactive",                                                             false, follow = "oxidetypealignwithactive", info = "set reference point for oxide thickness marker bottom extensions. If this is false, the oxide thickness marker bottom extension is autmatically calculated so that the oxide thickness marker covers the bottom part of all gates. With this option enabled, the oxide thickness marker bottom extension is referenced to the active region. This is useful for having precise control over the vthtype marker extensions in mosfet arrays with varying gate heights" },
        { "vthtype(Threshold Voltage Type)",                                                            1, argtype = "integer", posvals = interval(1, inf), info = "threshold voltage index of the device. This is a numeric index, starting from 1 (the default). The interpretation of this is up to the technology file" },
        { "vthtypealignwithactive",                                                                     false, info = "set reference points for vthtype marker extensions. If this is false, the vthtype marker extensions are autmatically calculated so that the vthtype marker covers all gates. With this option enabled, the vthtype marker extensions are referenced to the active region. This is useful for having precise control over the vthtype marker extensions in mosfet arrays with varying gate heights. This option sets left/right/top/bottom alignment, the dedicated switches can be used for more fine-grained control." },
        { "vthtypealignleftwithactive",                                                                 false, follow = "vthtypealignwithactive", info = "set reference point for vthtype marker left extensions. If this is false, the vthtype marker left extension is autmatically calculated so that the vthtype marker covers the left gates. With this option enabled, the vthtype marker left extension is referenced to the active region. This is useful for having precise control over the vthtype marker extensions in mosfet arrays with varying gate heights" },
        { "vthtypealignrightwithactive",                                                                false, follow = "vthtypealignwithactive", info = "set reference point for vthtype marker right extensions. If this is false, the vthtype marker right extension is autmatically calculated so that the vthtype marker covers the right gates. With this option enabled, the vthtype marker right extension is referenced to the active region. This is useful for having precise control over the vthtype marker extensions in mosfet arrays with varying gate heights" },
        { "vthtypealigntopwithactive",                                                                  false, follow = "vthtypealignwithactive", info = "set reference point for vthtype marker top extensions. If this is false, the vthtype marker top extension is autmatically calculated so that the vthtype marker covers the top part of all gates. With this option enabled, the vthtype marker top extension is referenced to the active region. This is useful for having precise control over the vthtype marker extensions in mosfet arrays with varying gate heights" },
        { "vthtypealignbottomwithactive",                                                               false, follow = "vthtypealignwithactive", info = "set reference point for vthtype marker bottom extensions. If this is false, the vthtype marker bottom extension is autmatically calculated so that the vthtype marker covers the bottom part of all gates. With this option enabled, the vthtype marker bottom extension is referenced to the active region. This is useful for having precise control over the vthtype marker extensions in mosfet arrays with varying gate heights" },
        { "wellalignwithactive",                                                                        false, info = "set reference points for well extensions. If this is false, the well extensions are autmatically calculated so that the well covers all gates. With this option enabled, the well extensions are referenced to the active region. This is useful for having precise control over the well extensions in mosfet arrays with varying gate heights. This option sets left/right/top/bottom alignment, the dedicated switches can be used for more fine-grained control." },
        { "wellalignleftwithactive",                                                                    false, follow = "wellalignwithactive", info = "set reference point for well left extensions. If this is false, the well left extension is autmatically calculated so that the well covers the left gates. With this option enabled, the well left extension is referenced to the active region. This is useful for having precise control over the well extensions in mosfet arrays with varying gate heights" },
        { "wellalignrightwithactive",                                                                   false, follow = "wellalignwithactive", info = "set reference point for well right extensions. If this is false, the well right extension is autmatically calculated so that the well covers the right gates. With this option enabled, the well right extension is referenced to the active region. This is useful for having precise control over the well extensions in mosfet arrays with varying gate heights" },
        { "wellaligntopwithactive",                                                                     false, follow = "wellalignwithactive", info = "set reference point for well top extensions. If this is false, the well top extension is autmatically calculated so that the well covers the top part of all gates. With this option enabled, the well top extension is referenced to the active region. This is useful for having precise control over the well extensions in mosfet arrays with varying gate heights" },
        { "wellalignbottomwithactive",                                                                  false, follow = "wellalignwithactive", info = "set reference point for well bottom extensions. If this is false, the well bottom extension is autmatically calculated so that the well covers the bottom part of all gates. With this option enabled, the well bottom extension is referenced to the active region. This is useful for having precise control over the well extensions in mosfet arrays with varying gate heights" },
        { "gatemarker(Gate Marking Layer Index)",                                                       1, argtype = "integer", posvals = interval(1, inf), info = "special marking layer that covers only the gate (the intersection of poly and the active region). This is a numeric index, starting at 1 (the default). The interpretation is up to the technology, typically the first gate marker should be an empty layer" },
        { "mosfetmarker(MOSFET Marking Layer Index)",                                                   1, argtype = "integer", posvals = interval(1, inf), info = "special marking layer that covers the active region. This is a numeric index, starting at 1 (the default). The interpretation is up to the technology, typically the first gate marker should be an empty layer" },
        { "mosfetmarkeralignatsourcedrain(Align MOSFET Marker at Source/Drain)",                        false, info = "set reference points for mosfetmarker extensions. If this is false, the mosfetmarker extensions are autmatically calculated so that the mosfetmarker covers all gates. With this option enabled, the mosfetmarker extensions are referenced to the active region. This is useful for having precise control over the mosfetmarker extensions in mosfet arrays with varying gate heights"  },
        { "flippedwell(Flipped Well)",                                                                  false, info = "enable if the device is a flipped-well device. The wells are inferred from the channeltype: non-flipped-well: pmos -> n-well, nmos -> p-well and vice versa" },
        { "fingers(Number of Fingers)",                                                                 1, argtype = "integer", posvals = interval(0, inf), info = "number of gate fingers. The total width of the device is fingerwidth * fingers" },
        { "fingerwidth(Finger Width)",                                                                       technology.get_dimension("Minimum Gate Width"), argtype = "integer", info = "gate finger width. The total width of the device is fingerwidth * finger" },
        { "gatelength(Gate Length)",                                                                    technology.get_dimension("Minimum Gate Length"), argtype = "integer", info = "drawn gate length (channel length)" },
        { "gatespace(Gate Spacing)",                                                                    technology.get_dimension("Minimum Gate XSpace"), argtype = "integer", info = "gate space between the polysilicon lines" },
        { "allow_poly_connections",                                                                     technology.get_option("Allow Poly Routing") },
        { "actext(Active Extension)",                                                                   0, info = "left/right active extension. This is added to the calculated width of the active regions, dependent on the number of gates, the finger widths, gate spacing and left/right dummy devices" },
        { "sdwidth(Source/Drain Contact Width)",                                                        technology.get_dimension("Minimum M1 Width"), argtype = "integer", info = "width of the source/drain contact regions. Currently, all metals are drawn in the same width, which can be an issue for higher metals as vias might not fit. If this is the case the vias have to be drawn manually. This might change in the future." }, -- FIXME: rename
        { "sdviawidth(Source/Drain Metal Width for Vias)",                                              technology.get_dimension("Minimum M1 Width"), argtype = "integer", follow = "sdwidth", info  = "width of the source/drain via regions. Currently, all vias are drawn in the same width, which can be an issue for higher metals as vias might not fit. If this is the case the vias have to be drawn manually. This might change in the future. This parameter follows 'sdwidth'." },
        { "sdmetalwidth(Source/Drain Metal Width)",                                                     technology.get_dimension("Minimum M1 Width"), argtype = "integer", follow = "sdviawidth", info = "width of the source/drain metals. This parameter follows 'sdviawidth'." },
        { "interweavevias",                                                                             false },
        { "alternateinterweaving",                                                                      false },
        { "minviaxspace",                                                                               0 },
        { "minviayspace",                                                                               0 },
        { "gtopext(Gate Top Extension)",                                                                technology.get_dimension("Minimum Gate Extension"), info = "top gate extension. This extension depends on the automatically calculated gate extensions (which depend for instance on gate contacts). This means that if 'gtopext' is smaller than the automatic extensions, the layout is not changed at all." },
        { "gbotext(Gate Bottom Extension)",                                                                technology.get_dimension("Minimum Gate Extension"), info = "bottom gate extension. This extension depends on the automatically calculated gate extensions (which depend for instance on gate contacts). This means that if 'gbotext' is smaller than the automatic extensions, the layout is not changed at all." },
        { "gtopextadd(Gate Additional Top Extension)",                                                  0, info = "Unconditional gate top extension (similar to 'gtopext', but always extends)." },
        { "gbotextadd(Gate Additional Bottom Extension)",                                               0, info = "Unconditional gate bottom extension (similar to 'gbotext', but always extends)." },
        { "gatetopabsoluteheight(Gate Absolute Top Height)",                                            0, info = "Alternative gate top extension parameter. If this is non-zero, it overwrites any gate extension values and applies the given height to the gate height (measured from the active region)", },
        { "gatebotabsoluteheight(Gate Absolute Bottom Height)",                                         0, info = "Alternative gate bottom extension parameter. If this is non-zero, it overwrites any gate extension values and applies the given height to the gate height (measured from the active region)", },
        { "drawleftstopgate(Draw Left Stop Gate)",                                                      false, info = "draw a gate where one half of it covers the active region, the other does not (left side). This gate is covered with the layer 'diffusionbreakgate'. This is required in some technologies for short-length devices" },
        { "drawrightstopgate(Draw Left Stop Gate)",                                                     false, info = "draw a gate where one half of it covers the active region, the other does not (right side). This gate is covered with the layer 'diffusionbreakgate'. This is required in some technologies for short-length devices" },
        { "endleftwithgate(End Left Side With Gate)",                                                   false, follow = "drawleftstopgate", info = "align the left end of the active region so that only half of the left-most gate covers the active region. Follows 'drawleftstopgate'." },
        { "endrightwithgate(End Right Side With Gate)",                                                 false, follow = "drawrightstopgate", info = "align the right end of the active region so that only half of the right-most gate covers the active region. Follows 'drawrightstopgate'." },
        { "leftendgatelength(Left End Gate Length)",                                                    0, follow = "gatelength" },
        { "leftendgatespace(Left End Gate Space)",                                                      0, follow = "gatespace" },
        { "rightendgatelength(Right End Gate Length)",                                                  0, follow = "gatelength" },
        { "rightendgatespace(Right End Gate Space)",                                                    0, follow = "gatespace" },
        { "drawtopgate(Draw Top Gate Contact)",                                                         false, info = "draw gate contacts on the upper side of the active region. The contact region width is the gate length, the height is 'topgatewidth'. The space to the active region is 'topgatespace'." },
        { "drawtopgatestrap(Draw Top Gate Strap)",                                                      false, follow = "drawtopgate", info = "Connect all top gate contacts by a metal strap. Follows 'drawtopgate'." },
        { "topgatewidth(Top Gate Width)",                                                               technology.get_dimension("Minimum M1 Width"), argtype = "integer", info = "Width of the metal strap connecting all top gate contacts." },
        { "topgateleftextension(Top Gate Left Extension)",                                              0, info = "Left extension of top gate metal strap. Positive values extend the strap on the left side beyond (to the left) of the gate, negative values in the opposite direction (but this is likely to cause an DRC error). So while negative values are possible, they are probably not useful." },
        { "topgaterightextension(Top Gate Right Extension)",                                            0, info = "Right extension of top gate metal strap. Positive values extend the strap on the right side beyond (to the right) of the gate, negative values in the opposite direction (but this is likely to cause an DRC error). So while negative values are possible, they are probably not useful." },
        { "topgatespace(Top Gate Space)",                                                               technology.get_dimension("Minimum M1 Space"), argtype = "integer", info = "Space between the active region and the lower edge of the top gate contacts/metal strap" },
        { "topgatemetal(Top Gate Strap Metal)",                                                         1, info = "Metal index (can be negative) of the top gate metal straps. If this is higher than 1 and 'drawtopgatevia' is true, vias are drawn." },
        { "drawtopgatevia(Draw Top Gate Via)",                                                          true, info = "Enable the drawing of vias on the top gate metal strap. This only makes a difference if 'topgatemetal' is higher than 1." },
        { "topgatecontinuousvia(Top Gate Continuous Via)",                                              false, info = "Make the drawn via of the top gate metal strap a continuous via." },
        { "drawbotgate(Draw Bottom Gate Contact)",                                                      false, info = "draw gate contacts on the upper side of the active region. The contact region width is the gate length, the height is 'topgatewidth'. The space to the active region is 'topgatespace'." },
        { "drawbotgatestrap(Draw Bottom Gate Strap)",                                                   false, follow = "drawbotgate" },
        { "botgatewidth(Bottom Gate Width)",                                                            technology.get_dimension("Minimum M1 Width"), argtype = "integer", info = "Width of the metal strap connecting all bottom gate contacts." },
        { "botgateleftextension(Bottom Gate Left Extension)",                                           0, info = "Left extension of bottom gate metal strap. Positive values extend the strap on the left side beyond (to the left) of the gate, negative values in the opposite direction (but this is likely to cause an DRC error). So while negative values are possible, they are probably not useful." },
        { "botgaterightextension(Bottom Gate Right Extension)",                                         0, info = "Right extension of bottom gate metal strap. Positive values extend the strap on the right side beyond (to the right) of the gate, negative values in the opposite direction (but this is likely to cause an DRC error). So while negative values are possible, they are probably not useful." },
        { "botgatespace(Bottom Gate Space)",                                                            technology.get_dimension("Minimum M1 Space"), argtype = "integer", info = "Space between the active region and the lower edge of the bottom gate contacts/metal strap" },
        { "botgatemetal(Bottom Gate Strap Metal)",                                                      1, info = "Metal index (can be negative) of the bottom gate metal straps. If this is higher than 1 and 'drawbotgatevia' is true, vias are drawn." },
        { "drawbotgatevia(Draw Bottom Gate Via)",                                                       true, info = "Enable the drawing of vias on the bottom gate metal strap. This only makes a difference if 'botgatemetal' is higher than 1." },
        { "botgatecontinuousvia(Bottom Gate Continuous Via)",                                           false, info = "Make the drawn via of the bottom gate metal strap a continuous via." },
        { "drawtopgatecut(Draw Top Gate Cut)",                                                          false, info = "Draw a gate cut rectangle above the active region (the 'top' gates)." },
        { "topgatecutheight(Top Gate Cut Y Height)",                                                    technology.get_dimension("Minimum Gate Cut Height", "Minimum Gate YSpace"), info = "Width of the top gate cut." },
        { "topgatecutspace(Top Gate Cut Y Space)",                                                      0, info = "Space between the active region and the top gate cut." },
        { "topgatecutleftext(Top Gate Cut Left Extension)",                                             0, info = "Left extension of the top gate cut. Without extension, the gate cut covers the underlying gate in x-direction exactly." },
        { "topgatecutrightext(Top Gate Cut Right Extension)",                                           0, info = "Right extension of the top gate cut. Without extension, the gate cut covers the underlying gate in x-direction exactly." },
        { "drawbotgatecut(Draw Top Gate Cut)",                                                          false, info = "Draw a gate cut rectangle above the active region (the 'bottom' gates)." },
        { "botgatecutheight(Top Gate Cut Y Height)",                                                    technology.get_dimension("Minimum Gate Cut Height", "Minimum Gate YSpace"), info = "Width of the bottom gate cut." },
        { "botgatecutspace(Top Gate Cut Y Space)",                                                      0, info = "Space between the active region and the bottom gate cut." },
        { "botgatecutleftext(Top Gate Cut Left Extension)",                                             0, info = "Left extension of the bottom gate cut. Without extension, the gate cut covers the underlying gate in x-direction exactly." },
        { "botgatecutrightext(Top Gate Cut Right Extension)",                                           0, info = "Right extension of the bottom gate cut. Without extension, the gate cut covers the underlying gate in x-direction exactly." },
        { "simulatemissinggatecut",                                                                     false, info = "Draw the gates with gate cuts as if the technology had no gate cuts (this splits the gates). This is only useful for technologies that support gate cuts." },
        { "drawsourcedrain(Draw Source/Drain Contacts)",                                                "both", posvals = set("both", "source", "drain", "none"), info = "Control which source/drain contacts are drawn. The possible values are 'both' (source and drain), 'source', 'drain' or 'none'. More fine-grained control can be obtained by the parameter 'excludesourcedraincontacts'." },
        { "excludesourcedraincontacts(Exclude Source/Drain Contacts)",                                  {}, argtype = "table", info = "Define which source/drain contacts get drawn. Set 'drawsourcedrain' to 'both' to use this effectively. The argument to this parameter should be a table with numeric indices. The source/drain regions are enumerated with the left-most starting at 1." },
        { "sourcesize(Source Size)",                                                                    technology.get_dimension("Minimum Gate Width"), argtype = "integer", follow = "fingerwidth", info = "Size of the source contact regions. This parameter follows 'fingerwidth', so per default the contact regions have the width of a transistor finger. For 'sourcesize', only values between 0 and 'fingerwidth' are allowed. If the size is smaller than 'fingerwidth', the source contact alignment ('sourcealign') is relevant." },
        { "sourceviasize(Source Via Size)",                                                             technology.get_dimension("Minimum Gate Width"), argtype = "integer", follow = "sourcesize", info = "Same as 'sourcesize', but for source vias." },
        { "drainsize(Drain Size)",                                                                      technology.get_dimension("Minimum Gate Width"), argtype = "integer", follow = "fingerwidth", info = "Size of the drain contact regions. This parameter follows 'fingerwidth', so per default the contact regions have the width of a transistor finger. For 'drainsize', only values between 0 and 'fingerwidth' are allowed., If the size is smaller than 'fingerwidth', the drain contact alignment ('drainalign') is relevant." },
        { "drainviasize(Drain Via Size)",                                                               technology.get_dimension("Minimum Gate Width"), argtype = "integer", follow = "drainsize", info = "Same as 'drainsize', but for drain vias." },
        { "sourcealign(Source Alignment)",                                                              "bottom", posvals = set("top", "bottom", "center"), info = "Alignment of the source contacts. Only relevant when source contacts are smaller than 'fingerwidth' (see 'sourcesize'). Possible values: 'top' (source contacts grow down from the top into the active region) and 'bottom' (source contact grow up from the bottom into the active region). Typically, one sets 'sourcesize' and 'drainsize' to smaller values than 'fingerwidth' and uses opposite settings for 'sourcealign' and 'drainalign'." },
        { "sourceviaalign(Source Via Alignment)",                                                       "bottom", posvals = set("top", "bottom", "center"), follow = "sourcealign" },
        { "drainalign(Drain Alignment)",                                                                "top", posvals = set("top", "bottom", "center"), info = "Alignment of the drain contacts. Only relevant when drain contacts are smaller than 'fingerwidth' (see 'drainsize'). Possible values: 'top' (drain contacts grow down from the top into the active region) and 'bottom' (drain contact grow up from the bottom into the active region). Typically, one sets 'sourcesize' and 'drainsize' to smaller values than 'fingerwidth' and uses opposite settings for 'sourcealign' and 'drainalign'." },
        { "drainviaalign(Drain Via Alignment)",                                                         "top", posvals = set("top", "bottom", "center"), follow = "drainalign", info = "Same as 'drainalign' for drain vias." },
        { "drawsourcevia(Draw Source Via)",                                                             true, info = "Draw required vias from metal 1 to the source metal. Only useful when 'sourcemetal' is not 1." },
        { "drawfirstsourcevia(Draw First Source Via)",                                                  true, info = "Draw a via on the first source region (counted from the left). This switch can be useful when connecting dummies to other devices." },
        { "drawlastsourcevia(Draw Last Source Via)",                                                    true, info = "Draw a via on the last source region (counted from the left). This switch can be useful when connecting dummies to other devices." },
        { "connectsource(Connect Source)",                                                              false, info = "Connect all parallel source regions by a metal strap. This strap either lies outside or inside of the active region (see parameter 'connectsourceinline'). For nMOS devices, the outer source strap is below the active region, for pMOS devices the outer source strap is above the active region. This can be changed with 'connectsourceinverse')." },
        { "drawsourcestrap(Draw Source Strap)",                                                         false, follow = "connectsource", info = "Draw the source strap. This parameter follows 'connectsource', so per default the source strap is drawn. This parameter is useful when the source strap (or what it should connect to) is drawn by some other structures." },
        { "drawsourceconnections(Draw Source Connections)",                                             false, follow = "connectsource", info = "Draw the connections to the source strap. This parameter follows 'connectsource', so per default the connections between the source regions and the source strap are drawn. This parameter is rarely useful, only in situations where the source strap is now used but the source is connected." },
        { "connectsourceboth(Connect Source on Both Sides)",                                            false, info = "Connect the source on both sides of the active region. The \"other\" source strap is controlled by the connectsourceother* parameters, which all follow the main connectsource* parameters. This means that per default the \"other\" source strap mirrors the main one." },
        { "connectsourcewidth(Source Rails Metal Width)",                                               technology.get_dimension("Minimum M1 Width"), argtype = "integer", follow = "sdwidth" },
        { "connectsourcespace(Source Rails Metal Space)",                                               technology.get_dimension("Minimum M1 Width"), argtype = "integer" },
        { "connectsourceleftext(Source Rails Metal Left Extension)",                                    0 },
        { "connectsourcerightext(Source Rails Metal Right Extension)",                                  0 },
        { "connectsourceautooddext(Source Rails Automatic Odd-Fingered Extension)",                     false },
        { "connectsourceotherwidth(Other Source Rails Metal Width)",                                    technology.get_dimension("Minimum M1 Width"), argtype = "integer", follow = "connectsourcewidth" },
        { "connectsourceotherspace(Other Source Rails Metal Space)",                                    technology.get_dimension("Minimum M1 Width"), argtype = "integer", follow = "connectsourcespace" },
        { "connectsourceotherleftext(Other Source Rails Metal Left Extension)",                         0, follow = "connectsourceleftext", },
        { "connectsourceotherrightext(Other Source Rails Metal Right Extension)",                       0, follow = "connectsourcerightext", },
        { "connectsourceotherautooddext(Other Source Rails Automatic Odd-Fingered Extension)",          false },
        { "sourcemetal(Source Connection Metal)",                                                       1 },
        { "sourcestartmetal(Source Connection First Metal)",                                            1, follow = "sourcemetal" },
        { "sourceendmetal(Source Connection Last Metal)",                                               1, follow = "sourcemetal" },
        { "sourceviametal(Source Via Metal)",                                                           1, follow = "sourceendmetal" },
        { "connectsourceinline(Connect Source Inline of Transistor)",                                   false },
        { "connectsourceinlineoffset(Offset for Inline Source Connection)",                             0 },
        { "splitsourcevias(Split Source Vias for Inline Source Connection)",                            false },
        { "flipsourcedrainstraps(Flip Source/Drain Straps)",                                            false },
        { "connectsourceinverse(Invert Source Strap Locations)",                                        false, follow = "flipsourcedrainstraps" },
        { "connectdrain(Connect Drain)",                                                                false },
        { "drawdrainstrap(Draw Drain Strap)",                                                           false, follow = "connectdrain" },
        { "drawdrainconnections(Draw Drain Connections)",                                               false, follow = "connectdrain" },
        { "connectdrainboth(Connect Drain on Both Sides)",                                              false },
        { "connectdrainwidth(Drain Rails Metal Width)",                                                 technology.get_dimension("Minimum M1 Width"), argtype = "integer", follow = "sdwidth" },
        { "connectdrainspace(Drain Rails Metal Space)",                                                 technology.get_dimension("Minimum M1 Width"), argtype = "integer" },
        { "connectdrainleftext(Drain Rails Metal Left Extension)",                                      0 },
        { "connectdrainrightext(Drain Rails Metal Right Extension)",                                    0 },
        { "connectdrainautooddext(Drain Rails Automatic Odd-Fingered Extension)",                       false },
        { "connectdraininverse(Invert Drain Strap Locations)",                                          false, follow = "flipsourcedrainstraps" },
        { "connectdrainotherwidth(Other Drain Rails Metal Width)",                                      technology.get_dimension("Minimum M1 Width"), argtype = "integer", follow = "connectdrainwidth" },
        { "connectdrainotherspace(Other Drain Rails Metal Space)",                                      technology.get_dimension("Minimum M1 Width"), argtype = "integer", follow = "connectdrainspace" },
        { "connectdrainotherleftext(Other Drain Rails Metal Left Extension)",                           0, follow = "connectdrainleftext" },
        { "connectdrainotherrightext(Other Drain Rails Metal Right Extension)",                         0, follow = "connectdrainrightext" },
        { "connectdrainotherautooddext(Other Drain Rails Automatic Odd-Fingered Extension)",            false },
        { "drawdrainvia(Draw Drain Via)",                                                               true },
        { "drawfirstdrainvia(Draw First Drain Via)",                                                    true },
        { "drawlastdrainvia(Draw Last Drain Via)",                                                      true },
        { "drainmetal(Drain Connection Metal)",                                                         1 },
        { "drainstartmetal(Drain Connection First Metal)",                                              1, follow = "drainmetal" },
        { "drainendmetal(Drain Connection Last Metal)",                                                 1, follow = "drainmetal" },
        { "drainviametal(Drain Via Metal)",                                                             1, follow = "drainendmetal" },
        { "connectdraininline(Connect Drain Inline of Transistor)",                                     false },
        { "connectdraininlineoffset(Offset for Inline Drain Connection)",                               0 },
        { "splitdrainvias(Split Drain Vias for Inline Drain Connection)",                               false },
        { "diodeconnected(Diode Connected Transistor)",                                                 false },
        { "diodeconnectedreversed(Reverse Diode Connections)",                                          false },
        { "drawextrabotstrap(Draw Extra Bottom Strap)",                                                 false },
        { "extrabotstrapwidth(Width of Extra Bottom Strap)",                                            technology.get_dimension("Minimum M1 Width"), argtype = "integer" },
        { "extrabotstrapspace(Space of Extra Bottom Strap)",                                            technology.get_dimension("Minimum M1 Space"), argtype = "integer" },
        { "extrabotstrapmetal(Metal Layer for Extra Bottom Strap)",                                     1 },
        { "extrabotstrapleftextension(Left Extension for Extra Bottom Strap)",                          0 },
        { "extrabotstraprightextension(Left Extension for Extra Bottom Strap)",                         0 },
        { "extrabotstrapleftalign(Left Alignment for Extra Bottom Strap)",                              1 },
        { "extrabotstraprightalign(Right Alignment for Extra Bottom Strap)",                            1, follow = "fingers" },
        { "drawextratopstrap(Draw Extra Top Strap)",                                                    false },
        { "extratopstrapwidth(Width of Extra Top Strap)",                                               technology.get_dimension("Minimum M1 Width"), argtype = "integer" },
        { "extratopstrapspace(Space of Extra Top Strap)",                                               technology.get_dimension("Minimum M1 Space"), argtype = "integer" },
        { "extratopstrapmetal(Metal Layer for Extra Top Strap)",                                        1 },
        { "extratopstrapleftextension(Left Extension for Extra Top Strap)",                             0 },
        { "extratopstraprightextension(Left Extension for Extra Top Strap)",                            0 },
        { "extratopstrapleftalign(Left Alignment for Extra Top Strap)",                                 1 },
        { "extratopstraprightalign(Right Alignment for Extra Top Strap)",                               1, follow = "fingers" }
    )
    -- split necessary because of lua limitations.
    -- FIXME: split at sensible locations (group parameters)
    pcell.add_parameters(
        { "shortdevice(Short Transistor)",                                                              false },
        { "shortdeviceleftoffset(Short Transistor Left Offset)",                                        0 },
        { "shortdevicerightoffset(Short Transistor Right Offset)",                                      0 },
        { "shortsourcegate(Short Source with Gate)",                                                    false },
        { "shortdraingate(Short Drain with Gate)",                                                      false },
        { "shortlocation",                                                                              "inline", posvals = set("inline", "top", "bottom") },
        { "shortspace",                                                                                 technology.get_dimension("Minimum M1 Space") },
        { "shortwidth",                                                                                 technology.get_dimension("Minimum M1 Width") },
        { "drawleftactivedummy",                                                                        false },
        { "leftactivedummywidth",                                                                       technology.get_optional_dimension("Minimum Active Width") },
        { "leftactivedummyspace",                                                                       technology.get_optional_dimension("Minimum Active Width") },
        { "drawrightactivedummy",                                                                       false },
        { "rightactivedummywidth",                                                                      technology.get_optional_dimension("Minimum Active Width") },
        { "rightactivedummyspace",                                                                      technology.get_optional_dimension("Minimum Active Width") },
        { "drawtopactivedummy",                                                                         false },
        { "topactivedummywidth",                                                                        technology.get_optional_dimension("Minimum Active Width") },
        { "topactivedummyspace",                                                                        technology.get_optional_dimension("Minimum Active Width") },
        { "drawbottomactivedummy",                                                                      false },
        { "bottomactivedummywidth",                                                                     technology.get_optional_dimension("Minimum Active Width") },
        { "bottomactivedummyspace",                                                                     technology.get_optional_dimension("Minimum Active Width") },
        { "leftfloatingdummies",                                                                        0 },
        { "rightfloatingdummies",                                                                       0 },
        { "drawactive",                                                                                 true },
        { "lvsmarker",                                                                                  1, info = "special marking layer to mark device features for LVS. Typically used for mosfets with 5 and 6 terminals (including well diodes). Per default this includes the guardring around the device, as this defines the geometry of the diodes. This can be changed with the parameter 'lvsmarkerincludeguardring'. This marker is always drawn, the parameter is a numeric value, starting at 1." },
        { "lvsmarkerincludeguardring",                                                                  true, },
        { "lvsmarkeralignwithactive",                                                                   false },
        { "extendall",                                                                                  0 },
        { "extendalltop",                                                                               0, follow = "extendall" },
        { "extendallbottom",                                                                            0, follow = "extendall" },
        { "extendallleft",                                                                              0, follow = "extendall" },
        { "extendallright",                                                                             0, follow = "extendall" },
        { "extendoxidetypetop",                                                                         0, follow = "extendalltop" },
        { "extendoxidetypebottom",                                                                      0, follow = "extendallbottom" },
        { "extendoxidetypeleft",                                                                        0, follow = "extendallleft" },
        { "extendoxidetyperight",                                                                       0, follow = "extendallright" },
        { "extendvthtypetop",                                                                           0, follow = "extendalltop" },
        { "extendvthtypebottom",                                                                        0, follow = "extendallbottom" },
        { "extendvthtypeleft",                                                                          0, follow = "extendallleft" },
        { "extendvthtyperight",                                                                         0, follow = "extendallright" },
        { "extendimplanttop",                                                                           0, follow = "extendalltop" },
        { "extendimplantbottom",                                                                        0, follow = "extendallbottom" },
        { "extendimplantleft",                                                                          0, follow = "extendallleft" },
        { "extendimplantright",                                                                         0, follow = "extendallright" },
        { "extendwelltop",                                                                              0, follow = "extendalltop" },
        { "extendwellbottom",                                                                           0, follow = "extendallbottom" },
        { "extendwellleft",                                                                             0, follow = "extendallleft" },
        { "extendwellright",                                                                            0, follow = "extendallright" },
        { "extendlvsmarkertop",                                                                         0, follow = "extendalltop" },
        { "extendlvsmarkerbottom",                                                                      0, follow = "extendallbottom" },
        { "extendlvsmarkerleft",                                                                        0, follow = "extendallleft" },
        { "extendlvsmarkerright",                                                                       0, follow = "extendallright" },
        { "extendrotationmarkertop",                                                                    0, follow = "extendalltop" },
        { "extendrotationmarkerbottom",                                                                 0, follow = "extendallbottom" },
        { "extendrotationmarkerleft",                                                                   0, follow = "extendallleft" },
        { "extendrotationmarkerright",                                                                  0, follow = "extendallright" },
        { "extendanalogmarkertop",                                                                      0, follow = "extendalltop" },
        { "extendanalogmarkerbottom",                                                                   0, follow = "extendallbottom" },
        { "extendanalogmarkerleft",                                                                     0, follow = "extendallleft" },
        { "extendanalogmarkerright",                                                                    0, follow = "extendallright" },
        { "drawwell",                                                                                   true },
        { "drawtopwelltap",                                                                             false },
        { "topwelltapwidth",                                                                            technology.get_dimension("Minimum M1 Width") },
        { "topwelltapspace",                                                                            technology.get_dimension("Minimum M1 Space") },
        { "topwelltapextendleft",                                                                       0 },
        { "topwelltapextendright",                                                                      0 },
        { "drawbotwelltap",                                                                             false },
        { "drawguardring",                                                                              false },
        { "guardringrespectactivedummy",                                                                false },
        { "guardringwidth",                                                                             technology.get_dimension("Minimum M1 Width") },
        { "guardringsep",                                                                               0 },
        { "guardringleftsep",                                                                           0, follow = "guardringsep" },
        { "guardringrightsep",                                                                          0, follow = "guardringsep" },
        { "guardringtopsep",                                                                            0, follow = "guardringsep" },
        { "guardringbottomsep",                                                                         0, follow = "guardringsep" },
        { "guardringsegments",                                                                          { "left", "right", "top", "bottom" } },
        { "guardringfillimplant",                                                                       false },
        { "guardringfillwell",                                                                          false },
        { "guardringwellinnerextension",                                                                0 },
        { "guardringwellouterextension",                                                                0 },
        { "guardringimplantinnerextension",                                                             0 },
        { "guardringimplantouterextension",                                                             0 },
        { "guardringsoiopeninnerextension",                                                             0 },
        { "guardringsoiopenouterextension",                                                             0 },
        { "botwelltapwidth",                                                                            technology.get_dimension("Minimum M1 Width") },
        { "botwelltapspace",                                                                            technology.get_dimension("Minimum M1 Space") },
        { "botwelltapextendleft",                                                                       0 },
        { "botwelltapextendright",                                                                      0 },
        { "drawstopgatetopgatecut",                                                                     false },
        { "drawstopgatebotgatecut",                                                                     false },
        { "excludestopgatesfromcutregions",                                                             true },
        { "leftpolylines",                                                                              {} },
        { "rightpolylines",                                                                             {} },
        { "drawrotationmarker",                                                                         false },
        { "drawanalogmarker",                                                                           false }
    )
end

function anchors()
    pcell.add_area_anchor_documentation(
        "active",
        "region of the active diffusion",
        "drawactive == true"
    )
    pcell.add_area_anchor_documentation(
        "implant",
        "region of the implant"
    )
    pcell.add_area_anchor_documentation(
        "well",
        "region of the well"
    )
    pcell.add_area_anchor_documentation(
        "leftactivedummy",
        "region of the left dummy active diffusion",
        "(drawactive == true) and (drawleftactivedummy == true)"
    )
    pcell.add_area_anchor_documentation(
        "rightactivedummy",
        "region of the right dummy active diffusion",
        "(drawactive == true) and (drawrightactivedummy == true)"
    )
    pcell.add_area_anchor_documentation(
        "topactivedummy",
        "region of the top dummy active diffusion",
        "(drawactive == true) and (drawtopactivedummy == true)"
    )
    pcell.add_area_anchor_documentation(
        "bottomactivedummy",
        "region of the bottom dummy active diffusion",
        "(drawactive == true) and (drawbottomactivedummy == true)"
    )
    pcell.add_area_anchor_documentation(
        "gate%d",
        "drawn gate, one for every finger (gate1, gate2, ...). Counting starts at 1 and left, going right",
        "fingers > 0"
    )
    pcell.add_area_anchor_documentation(
        "gate-%d",
        "drawn gate, inverse anchor, one for every finger (gate-1, gate-2, ...). Counting starts at -1 and right, going left",
        "fingers > 0"
    )
    pcell.add_area_anchor_documentation(
        "leftgate",
        "left-most gate anchor (like gate1, but always present)"
    )
    pcell.add_area_anchor_documentation(
        "rightgate",
        "right-most gate anchor (like gate-1, but always present)"
    )
    pcell.add_area_anchor_documentation(
        "topgate%d",
        "anchor of the nth top gate. Like gate%d, but only includes the part of the gate that is covered the top gate strap",
        "drawtopgate == true"
    )
    pcell.add_area_anchor_documentation(
        "botgate%d",
        "anchor of the nth bottom gate. Like gate%d, but only includes the part of the gate that is covered the bottom gate strap",
        "drawbotgate == true"
    )
    pcell.add_area_anchor_documentation(
        "topgatestrap",
        "anchor of the top gate strap",
        "fingers > 0 and drawtopgatestrap"
    )
    pcell.add_area_anchor_documentation(
        "botgatestrap",
        "anchor of the bottom gate strap",
        "drawbotgate == true",
        "fingers > 0 and drawbotgatestrap"
    )
    pcell.add_area_anchor_documentation(
        "endleftgate",
        "anchor of left end gate (not gate1)",
        "endleftgate == true"
    )
    pcell.add_area_anchor_documentation(
        "endrightgate",
        "anchor of right end gate (not gate-1)",
        "endrightgate == true"
    )
    pcell.add_area_anchor_documentation(
        "leftpolyline%d",
        "anchor of nth left poly line",
        "leftpolylines has at least one entry"
    )
    pcell.add_area_anchor_documentation(
        "rightpolyline%d",
        "anchor of nth right poly line",
        "rightpolylines has at least one entry"
    )
    pcell.add_area_anchor_documentation(
        "leftstopgate",
        "anchor of left stop gate (not gate1). Identical to endleftgate",
        "drawleftstopgate == true"
    )
    pcell.add_area_anchor_documentation(
        "rightstopgate",
        "anchor of right stop gate (not gate1). Identical to endrightgate",
        "drawrightstopgate == true"
    )
    pcell.add_area_anchor_documentation(
        "sourcedrainactive%d",
        "anchor of nth source/drain active region (independent of metal), starting counting from the left. For most use-cases, the area anchor 'sourcedrain%d' is better suited",
        "fingers > 1"
    )
    pcell.add_area_anchor_documentation(
        "sourcedrainactive-%d",
        "anchor of nth source/drain active region (independent of metal), starting counting from the right. For most use-cases, the area anchor 'sourcedrain%d' is better suited",
        "fingers > 1"
    )
    pcell.add_area_anchor_documentation(
        "sourcedrainactiveleft",
        "most-left active source/drain region. Useful for alignment"
    )
    pcell.add_area_anchor_documentation(
        "sourcedrainactiveright",
        "most-right active source/drain region. Useful for alignment"
    )
    pcell.add_area_anchor_documentation(
        "sourcedrain%d",
        "anchor of nth source/drain region (covered by metal). Both source and drain regions are included, but only if both are drawn, e.g. with drawsourcedrain == \"source\", only every second anchor will be present",
        "drawsourcedrain ~= none"
    )
    pcell.add_area_anchor_documentation(
        "sourcedrain-%d",
        "anchor of nth source/drain region (covered by metal), starting counting at the right side",
        "drawsourcedrain ~= none"
    )
    pcell.add_area_anchor_documentation(
        "sourcedrainmetal%d",
        "like sourcedrain%d, but dependent on the size of the source/drain via",
        "drawsourcedrain ~= none"
    )
    pcell.add_area_anchor_documentation(
        "sourcedrainmetal-%d",
        "like sourcedrain%d, but dependent on the size of the source/drain via. Starting counting at the right side",
        "drawsourcedrain ~= none"
    )
    pcell.add_area_anchor_documentation(
        "sourcestrap",
        "region of the source strap connecting all source regions",
        "fingers > 0"
    )
    pcell.add_area_anchor_documentation(
        "othersourcestrap",
        "region of the other source strap (on the opposite side) connecting all source regions",
        "(fingers > 0) and (connectsourceboth == true)"
    )
    pcell.add_area_anchor_documentation(
        "drainstrap",
        "region of the drain strap connecting all drain regions",
        "fingers > 0"
    )
    pcell.add_area_anchor_documentation(
        "otherdrainstrap",
        "region of the other drain strap (on the opposite side) connecting all drain regions",
        "(fingers > 0) and (connectdrainboth == true)"
    )
    pcell.add_area_anchor_documentation(
        "extratopstrap",
        "region of the extra top metal strap",
        "drawextratopstrap"
    )
    pcell.add_area_anchor_documentation(
        "extrabotstrap",
        "region of the extra bottom metal strap",
        "drawextrabotstrap"
    )
    pcell.add_area_anchor_documentation(
        "innerguardring",
        "inner boundary region of the guardring",
        "drawguardring"
    )
    pcell.add_area_anchor_documentation(
        "outerguardring",
        "outer boundary region of the guardring",
        "drawguardring"
    )
end

function check(_P)
    if (_P.gatespace % 2) ~= (_P.sdwidth % 2) then
        return false, string.format("gatespace and sdwidth must both be even or odd (%d vs. %d)", _P.gatespace, _P.sdwidth)
    end
    if (_P.sdmetalwidth % 2) ~= (_P.sdwidth % 2) then
        return false, string.format("sdmetalwidth and sdwidth must both be even or odd (%d vs. %d)", _P.sdmetalwidth, _P.sdwidth)
    end
    if _P.sdviawidth < _P.sdwidth then
        return false, string.format("sdviawidth must not be smaller than sdwidth (%d vs. %d)", _P.sdviawidth, _P.sdwidth)
    end
    if _P.sdmetalwidth < _P.sdviawidth then
        return false, string.format("sdmetalwidth must not be smaller than sdviawidth (%d vs. %d)", _P.sdmetalwidth, _P.sdviawidth)
    end
    if _P.sourcesize < 0 then
        return false, string.format("sourcesize (%d) can not be negative or larger than 'fingerwidth' (%d)", _P.sourcesize, _P.fingerwidth)
    end
    if _P.drainsize < 0 then
        return false, string.format("drainsize (%d) can not be negative or larger than 'fingerwidth' (%d)", _P.drainsize, _P.fingerwidth)
    end
    if _P.sourceviasize < 0 then
        return false, string.format("sourceviasize (%d) can not be negative or larger than 'fingerwidth' (%d)", _P.sourceviasize, _P.fingerwidth)
    end
    if _P.drainviasize < 0 then
        return false, string.format("drainviasize (%d) can not be negative or larger than 'fingerwidth' (%d)", _P.drainviasize, _P.fingerwidth)
    end
    if _P.shortdevice and ((_P.sourcesize % 2) ~= (_P.sdwidth % 2)) then
        return false, string.format("sourcesize and sdwidth must both be even or odd when shortdevice is true (%d vs. %d)", _P.sourcesize, _P.sdwidth)
    end
    if not (not _P.endleftwithgate or (_P.gatelength % 2 == 0)) then
        return false, string.format("gatelength must be even when endleftwithgate is true (gatelength: %d)", _P.gatelength)
    end
    if not (not _P.endrightwithgate or (_P.gatelength % 2 == 0)) then
        return false, string.format("gatelength must be even when endrightwithgate is true (gatelength: %d)", _P.gatelength)
    end
    if _P.leftendgatelength % 2 ~= 0 then
        return false, string.format("leftendgatelength must be even (%d)", _P.leftendgatelength)
    end
    if _P.rightendgatelength % 2 ~= 0 then
        return false, string.format("rightendgatelength must be even", _P.rightendgatelength)
    end
    if _P.diodeconnected and not (_P.drawtopgate or _P.drawbotgate) then
        return false, "if the device is diode-connected, the top or bottom gate strap needs to be present"
    end
    if _P.shortdevice then
        if
            (_P.shortdeviceleftoffset > 0 or _P.shortdevicerightoffset > 0) and
            (_P.fingers - _P.shortdevicerightoffset - _P.shortdeviceleftoffset <= 0) then
            return false, string.format("the sum of left/right short offsets (%d/%d) can't be equal to or larger than the number of fingers (%d)", _P.shortdeviceleftoffset, _P.shortdevicerightoffset, _P.fingers)
        end
    end
    if _P.shortsourcegate and (not (_P.drawtopgate and _P.drawtopgatestrap) and not (_P.drawbotgate and _P.drawbotgatestrap)) then
        return false, "if shortsourcegate is true, drawtopgate and drawtopgatestrap also have to be true"
    end
    return true
end

function layout(transistor, _P)
    local gatepitch = _P.gatelength + _P.gatespace
    local leftactext = (_P.gatespace + _P.sdwidth) / 2 + _P.actext
    local rightactext = (_P.gatespace + _P.sdwidth) / 2 + _P.actext
    local leftactauxext = _P.endleftwithgate and (-(_P.gatespace + _P.sdwidth) / 2 + _P.leftendgatespace + _P.leftendgatelength / 2) or 0
    local rightactauxext = _P.endrightwithgate and (-(_P.gatespace + _P.sdwidth) / 2 + _P.rightendgatespace + _P.rightendgatelength / 2) or 0
    local activewidth = _P.fingers * _P.gatelength + (_P.fingers - 1) * _P.gatespace + _P.leftfloatingdummies * gatepitch + _P.rightfloatingdummies * gatepitch

    local topgateshift = enable(_P.drawtopgate, _P.topgatespace + _P.topgatewidth)
    local botgateshift = enable(_P.drawbotgate, _P.botgatespace + _P.botgatewidth)
    local gateaddtop = math.max(_P.gtopext, topgateshift) + _P.gtopextadd
    local gateaddbottom = math.max(_P.gbotext, botgateshift) + _P.gbotextadd
    if _P.gatetopabsoluteheight > 0 then
        gateaddtop = _P.gatetopabsoluteheight
    end
    if _P.gatebotabsoluteheight > 0 then
        gateaddbottom = _P.gatebotabsoluteheight
    end

    local hasgatecut = not _P.simulatemissinggatecut and technology.has_layer(generics.other, "gatecut")

    -- active
    if _P.drawactive then
        geometry.rectanglebltr(transistor, generics.active(),
            point.create(-leftactauxext, 0),
            point.create(activewidth + leftactext + rightactext + rightactauxext, _P.fingerwidth)
        )
        transistor:add_anchor_line_y("activetop", _P.fingerwidth)
        transistor:add_anchor_line_y("activebottom", 0)
        transistor:add_area_anchor_bltr("active",
            point.create(-leftactauxext, 0),
            point.create(activewidth + leftactext + rightactext + rightactauxext, _P.fingerwidth)
        )
        if _P.drawleftactivedummy then
            transistor:add_area_anchor_bltr("leftactivedummy",
                point.create(-leftactauxext - _P.leftactivedummyspace - _P.leftactivedummywidth, 0),
                point.create(-leftactauxext - _P.leftactivedummyspace, _P.fingerwidth)
            )
            geometry.rectanglebltr(transistor, generics.active(),
                transistor:get_area_anchor("leftactivedummy").bl,
                transistor:get_area_anchor("leftactivedummy").tr
            )
        end
        if _P.drawrightactivedummy then
            transistor:add_area_anchor_bltr("rightactivedummy",
                point.create(activewidth + leftactext + rightactext + rightactauxext + _P.rightactivedummyspace, 0),
                point.create(activewidth + leftactext + rightactext + rightactauxext + _P.rightactivedummyspace + _P.rightactivedummywidth, _P.fingerwidth)
            )
            geometry.rectanglebltr(transistor, generics.active(),
                transistor:get_area_anchor("rightactivedummy").bl,
                transistor:get_area_anchor("rightactivedummy").tr
            )
        end
        if _P.drawtopactivedummy then
            transistor:add_area_anchor_bltr("topactivedummy",
                point.create(-leftactauxext, _P.fingerwidth + _P.topactivedummyspace),
                point.create(activewidth + leftactext + rightactext + rightactauxext, _P.fingerwidth + _P.topactivedummyspace + _P.topactivedummywidth)
            )
            geometry.rectanglebltr(transistor, generics.active(),
                transistor:get_area_anchor("topactivedummy").bl,
                transistor:get_area_anchor("topactivedummy").tr
            )
        end
        if _P.drawbottomactivedummy then
            transistor:add_area_anchor_bltr("bottomactivedummy",
                point.create(-leftactauxext, -_P.bottomactivedummyspace - _P.bottomactivedummywidth),
                point.create(activewidth + leftactext + rightactext + rightactauxext, -_P.bottomactivedummyspace)
            )
            geometry.rectanglebltr(transistor, generics.active(),
                transistor:get_area_anchor("bottomactivedummy").bl,
                transistor:get_area_anchor("bottomactivedummy").tr
            )
        end
    end

    -- gates
    -- base coordinates of a gate
    -- needed throughout the cell by various drawings
    local gateblx = leftactext + _P.leftfloatingdummies * gatepitch
    local gatebly = -gateaddbottom
    local gatetrx = gateblx + _P.gatelength
    local gatetry = _P.fingerwidth + gateaddtop

    if hasgatecut then
        -- gate cut
        if _P.fingers > 0 and _P.drawtopgatecut then
            geometry.rectanglebltr(transistor,
                generics.other("gatecut"),
                point.create(
                    gateblx - _P.topgatecutleftext,
                    _P.fingerwidth + _P.topgatecutspace
                ),
                point.create(
                    gatetrx + (_P.fingers - 1) * gatepitch + _P.topgatecutrightext,
                    _P.fingerwidth + _P.topgatecutspace + _P.topgatecutheight
                )
            )
        end
        if _P.fingers > 0 and _P.drawbotgatecut then
            geometry.rectanglebltr(transistor,
                generics.other("gatecut"),
                point.create(
                    gateblx - _P.botgatecutleftext,
                    -_P.botgatecutspace - _P.botgatecutheight
                ),
                point.create(
                    gatetrx + (_P.fingers - 1) * gatepitch + _P.botgatecutrightext,
                    -_P.botgatecutspace
                )
            )
        end
    else -- not hasgatecut
        if _P.drawtopgatecut then
            gatetry = _P.fingerwidth + _P.topgatecutspace
        end
        if _P.drawbotgatecut then
            gatebly = -_P.botgatecutspace
        end
    end

    -- main gates
    for i = 1, _P.fingers do
        geometry.rectanglebltr(transistor,
            generics.gate(),
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
        transistor:add_area_anchor_bltr(
            "endleftgate",
            point.create(gateblx - _P.leftfloatingdummies * gatepitch - _P.leftendgatelength - _P.leftendgatespace, gatebly),
            point.create(gatetrx - _P.leftfloatingdummies * gatepitch - _P.gatelength - _P.leftendgatespace, gatetry)
        )
        geometry.rectanglebltr(transistor,
            generics.gate(),
            transistor:get_area_anchor("endleftgate").bl,
            transistor:get_area_anchor("endleftgate").tr
        )
    end
    if _P.endrightwithgate then
        transistor:add_area_anchor_bltr(
            "endrightgate",
            point.create(gateblx + _P.rightfloatingdummies * gatepitch - _P.gatespace + _P.rightendgatespace + _P.fingers * gatepitch, gatebly),
            point.create(gatetrx + _P.rightfloatingdummies * gatepitch - _P.gatespace + _P.rightendgatespace - _P.gatelength + _P.rightendgatelength + _P.fingers * gatepitch, gatetry)
        )
        geometry.rectanglebltr(transistor,
            generics.gate(),
            transistor:get_area_anchor("endrightgate").bl,
            transistor:get_area_anchor("endrightgate").tr
        )
    end

    -- mosfet marker
    -- FIXME: check proper alignment after source/drain contacts are placed
    if _P.fingers > 0 then
        if _P.mosfetmarkeralignatsourcedrain then
            geometry.rectanglebltr(transistor,
                generics.other(string.format("mosfetmarker%d", _P.mosfetmarker)),
                point.create(0, 0),
                point.create(_P.fingers * gatepitch, _P.fingerwidth)
            )
        else
            geometry.rectanglebltr(transistor,
                generics.other(string.format("mosfetmarker%d", _P.mosfetmarker)),
                point.create(leftactext, 0),
                point.create(leftactext + _P.fingers * gatepitch - _P.gatespace,  _P.fingerwidth)
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
            generics.gate(),
            point.create(leftpolyoffset - polyline.space - polyline.length, gatebly),
            point.create(leftpolyoffset - polyline.space, gatetry)
        )
        if polyline.isstopgate then
            geometry.rectanglebltr(transistor,
                generics.other("diffusionbreakgate"),
                point.create(leftpolyoffset - polyline.space - polyline.length, gatebly),
                point.create(leftpolyoffset - polyline.space, gatetry)
            )
        end
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
            generics.gate(),
            point.create(rightpolyoffset + polyline.space, gatebly),
            point.create(rightpolyoffset + polyline.space + polyline.length, gatetry)
        )
        if polyline.isstopgate then
            geometry.rectanglebltr(transistor,
                generics.other("diffusionbreakgate"),
                point.create(rightpolyoffset + polyline.space, gatebly),
                point.create(rightpolyoffset + polyline.space + polyline.length, gatetry)
            )
        end
        transistor:add_area_anchor_bltr(
            string.format("rightpolyline%d", i),
            point.create(rightpolyoffset + polyline.space, gatebly),
            point.create(rightpolyoffset + polyline.space + polyline.length, gatetry)
        )
        rightpolyoffset = rightpolyoffset + polyline.length + polyline.space
    end

    -- stop gates
    if _P.drawleftstopgate then
        if _P.drawstopgatetopgatecut then
            geometry.rectanglebltr(transistor,
                generics.other("gatecut"),
                point.create(
                    transistor:get_area_anchor("endleftgate").l - _P.topgatecutleftext,
                    _P.fingerwidth + _P.topgatecutspace
                ),
                point.create(
                    transistor:get_area_anchor("endleftgate").r + _P.topgatecutrightext,
                    _P.fingerwidth + _P.topgatecutspace + _P.topgatecutheight
                )
            )
        end
        if _P.drawstopgatebotgatecut then
            geometry.rectanglebltr(transistor,
                generics.other("gatecut"),
                point.create(
                    transistor:get_area_anchor("endleftgate").l - _P.botgatecutleftext,
                    -_P.botgatecutspace - _P.botgatecutheight
                ),
                point.create(
                    transistor:get_area_anchor("endleftgate").r + _P.botgatecutrightext,
                    -_P.botgatecutspace
                )
            )
        end
        local byoffset = 0
        local tyoffset = 0
        if _P.excludestopgatesfromcutregions then
            if _P.drawstopgatetopgatecut then
                tyoffset = -gateaddtop + _P.topgatecutspace
            end
            if _P.drawstopgatebotgatecut then
                byoffset = gateaddbottom - _P.botgatecutspace
            end
        end
        geometry.rectanglebltr(transistor,
            generics.other("diffusionbreakgate"),
            transistor:get_area_anchor("endleftgate").bl:translate_y(byoffset),
            transistor:get_area_anchor("endleftgate").tr:translate_y(tyoffset)
        )
        transistor:add_area_anchor_bltr("leftstopgate",
            transistor:get_area_anchor("endleftgate").bl,
            transistor:get_area_anchor("endleftgate").tr
        )
    end

    if _P.drawrightstopgate then
        if _P.drawstopgatetopgatecut then
            geometry.rectanglebltr(transistor,
                generics.other("gatecut"),
                point.create(
                    transistor:get_area_anchor("endrightgate").l - _P.topgatecutleftext,
                    _P.fingerwidth + _P.topgatecutspace
                ),
                point.create(
                    transistor:get_area_anchor("endrightgate").r + _P.topgatecutrightext,
                    _P.fingerwidth + _P.topgatecutspace + _P.topgatecutheight
                )
            )
        end
        if _P.drawstopgatebotgatecut then
            geometry.rectanglebltr(transistor,
                generics.other("gatecut"),
                point.create(
                    transistor:get_area_anchor("endrightgate").l - _P.botgatecutleftext,
                    -_P.botgatecutspace - _P.botgatecutheight
                ),
                point.create(
                    transistor:get_area_anchor("endrightgate").r + _P.botgatecutrightext,
                    -_P.botgatecutspace
                )
            )
        end
        local byoffset = 0
        local tyoffset = 0
        if _P.excludestopgatesfromcutregions then
            if _P.drawstopgatetopgatecut then
                tyoffset = -gateaddtop + _P.topgatecutspace
            end
            if _P.drawstopgatebotgatecut then
                byoffset = gateaddbottom - _P.botgatecutspace
            end
        end
        geometry.rectanglebltr(transistor,
            generics.other("diffusionbreakgate"),
            transistor:get_area_anchor("endrightgate").bl:translate_y(byoffset),
            transistor:get_area_anchor("endrightgate").tr:translate_y(tyoffset)
        )
        transistor:add_area_anchor_bltr("rightstopgate",
            transistor:get_area_anchor("endrightgate").bl,
            transistor:get_area_anchor("endrightgate").tr
        )
    end

    -- floating dummy gates
    for i = 1, _P.leftfloatingdummies do
        geometry.rectanglebltr(transistor,
            generics.gate(),
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
            generics.gate(),
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
                _P.fingerwidth + _P.extendvthtypetop or
                gatetry + _P.extendvthtypetop
        )
    )

    -- implant
    local implantbl = point.create(
        _P.implantalignleftwithactive and
            -leftactauxext - _P.extendimplantleft or
            -leftactauxext - _P.extendimplantleft,
        _P.implantalignbottomwithactive and
            -_P.extendimplantbottom or
            gatebly - _P.extendimplantbottom
    )
    local implanttr = point.create(
        _P.implantalignrightwithactive and
            activewidth + leftactext + rightactext + rightactauxext + _P.extendimplantright or
            activewidth + leftactext + rightactext + rightactauxext + _P.extendimplantright,
        _P.implantaligntopwithactive and
            _P.fingerwidth + _P.extendimplanttop or
            gatetry + _P.extendimplanttop
    )
    if _P.drawimplant then
        geometry.rectanglebltr(transistor, generics.implant(_P.channeltype), implantbl, implanttr)
    end
    transistor:add_area_anchor_bltr("implant", implantbl, implanttr)

    -- oxide thickness
    geometry.rectanglebltr(transistor,
        generics.oxide(_P.oxidetype),
        point.create(
            _P.oxidetypealignleftwithactive and
                -leftactauxext - _P.extendoxidetypeleft or
                -leftactauxext - _P.extendoxidetypeleft,
            _P.oxidetypealignbottomwithactive and
                -_P.extendoxidetypebottom or
                gatebly - _P.extendoxidetypebottom
        ),
        point.create(
            _P.oxidetypealignrightwithactive and
                activewidth + leftactext + rightactext + rightactauxext + _P.extendoxidetyperight or
                activewidth + leftactext + rightactext + rightactauxext + _P.extendoxidetyperight,
            _P.oxidetypealigntopwithactive and
                _P.fingerwidth + _P.extendoxidetypetop or
                gatetry + _P.extendoxidetypetop
        )
    )

    -- rotation marker
    if _P.drawrotationmarker then
        geometry.rectanglebltr(transistor,
            generics.other("rotationmarker"),
            point.create(-leftactauxext - _P.extendrotationmarkerleft, -_P.extendrotationmarkerbottom),
            point.create(activewidth + leftactext + rightactext + rightactauxext + _P.extendrotationmarkerright, _P.fingerwidth + _P.extendrotationmarkertop)
        )
    end

    -- analog marker
    if _P.drawanalogmarker then
        if _P.drawguardring then
            if _P.guardringrespectactivedummy then
                geometry.rectanglebltr(transistor,
                    generics.other("analogmarker"),
                    point.create(
                        -leftactauxext - _P.guardringleftsep - _P.guardringwidth - _P.leftactivedummywidth - _P.leftactivedummyspace,
                        -_P.guardringbottomsep - _P.guardringwidth - _P.bottomactivedummywidth - _P.bottomactivedummyspace
                    ),
                    point.create(
                        activewidth + leftactext + rightactext + rightactauxext + _P.guardringrightsep + _P.guardringwidth + _P.rightactivedummywidth + _P.rightactivedummyspace,
                        _P.fingerwidth + _P.guardringtopsep + _P.guardringwidth + _P.topactivedummywidth + _P.topactivedummyspace
                    )
                )
            else
                geometry.rectanglebltr(transistor,
                    generics.other("analogmarker"),
                    point.create(
                        -leftactauxext - _P.guardringleftsep - _P.guardringwidth,
                        -_P.guardringbottomsep - _P.guardringwidth
                    ),
                    point.create(
                        activewidth + leftactext + rightactext + rightactauxext + _P.guardringrightsep + _P.guardringwidth,
                        _P.fingerwidth + _P.guardringtopsep + _P.guardringwidth
                    )
                )
            end
        else
            geometry.rectanglebltr(transistor,
                generics.other("analogmarker"),
                point.create(
                    -leftactauxext - _P.extendanalogmarkerleft,
                    -_P.extendanalogmarkerbottom
                ),
                point.create(
                    activewidth + leftactext + rightactext + rightactauxext + _P.extendanalogmarkerright,
                    _P.fingerwidth + _P.extendanalogmarkertop
                )
            )
        end
    end

    -- lvs marker
    if _P.lvsmarkerincludeguardring then
        if _P.guardringrespectactivedummy then
            geometry.rectanglebltr(transistor,
                generics.other(string.format("lvsmarker%d", _P.lvsmarker)),
                point.create(
                    -leftactauxext - _P.guardringleftsep - _P.guardringwidth - _P.leftactivedummywidth - _P.leftactivedummyspace - _P.extendlvsmarkerleft,
                    -_P.guardringbottomsep - _P.guardringwidth - _P.bottomactivedummywidth - _P.bottomactivedummyspace - _P.extendlvsmarkerbottom
                ),
                point.create(
                    activewidth + leftactext + rightactext + rightactauxext + _P.guardringrightsep + _P.guardringwidth + _P.rightactivedummywidth + _P.rightactivedummyspace + _P.extendlvsmarkerright,
                    _P.fingerwidth + _P.guardringtopsep + _P.guardringwidth + _P.topactivedummywidth + _P.topactivedummyspace + _P.extendlvsmarkertop
                )
            )
        else
            geometry.rectanglebltr(transistor,
                generics.other(string.format("lvsmarker%d", _P.lvsmarker)),
                point.create(
                    -leftactauxext - _P.guardringleftsep - _P.guardringwidth - _P.extendlvsmarkerleft,
                    -_P.guardringbottomsep - _P.guardringwidth - _P.extendlvsmarkerbottom
                ),
                point.create(
                    activewidth + leftactext + rightactext + rightactauxext + _P.guardringrightsep + _P.guardringwidth + _P.extendlvsmarkerright,
                    _P.fingerwidth + _P.guardringtopsep + _P.guardringwidth + _P.extendlvsmarkertop
                )
            )
        end
    else
        if _P.lvsmarkeralignwithactive then
            geometry.rectanglebltr(transistor,
                generics.other(string.format("lvsmarker%d", _P.lvsmarker)),
                point.create(
                    -leftactauxext - _P.extendlvsmarkerleft,
                    -_P.extendlvsmarkerbottom
                ),
                point.create(
                    activewidth + leftactext + rightactext + rightactauxext + _P.extendlvsmarkerright,
                    _P.fingerwidth + _P.extendlvsmarkertop
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
    end

    -- well
    local wellbl = point.create(
        _P.wellalignleftwithactive and
            -leftactauxext - _P.extendwellleft or
            -leftactauxext - _P.extendwellleft,
        (_P.wellalignbottomwithactive and 0 or gatebly)
            - math.max(_P.extendwellbottom, enable(_P.drawbotwelltap, _P.botwelltapspace + _P.botwelltapwidth))
    )
    local welltr = point.create(
        _P.wellalignrightwithactive and
            activewidth + leftactext + rightactext + rightactauxext + _P.extendwellright or
            activewidth + leftactext + rightactext + rightactauxext + _P.extendwellright,
        (_P.wellaligntopwithactive and _P.fingerwidth or gatetry)
            + math.max(_P.extendwelltop, enable(_P.drawtopwelltap, _P.topwelltapspace + _P.topwelltapwidth))
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
            width = activewidth + leftactext + leftactauxext + rightactext + rightactauxext + _P.topwelltapextendleft + _P.topwelltapextendright,
            height = _P.topwelltapwidth,
        }):translate(
            (_P.topwelltapextendright - _P.topwelltapextendleft) / 2,
            _P.fingerwidth + _P.topwelltapspace
        ))
    end
    if _P.drawbotwelltap then
        transistor:merge_into(pcell.create_layout("auxiliary/welltap", "botwelltap", {
            contype = _P.flippedwell and (_P.channeltype == "nmos" and "n" or "p") or (_P.channeltype == "nmos" and "p" or "n"),
            width = activewidth + leftactext + leftactauxext + rightactext + rightactauxext + _P.botwelltapextendleft + _P.botwelltapextendright,
            height = _P.botwelltapwidth,
        }):translate(
            (_P.botwelltapextendright - _P.botwelltapextendleft) / 2,
            -_P.botwelltapwidth - _P.botwelltapspace
        ))
    end

    local guardring -- variable needs to be visible for alignment box setting
    if _P.drawguardring then
        if _P.guardringrespectactivedummy then
            guardring = pcell.create_layout("auxiliary/guardring", "guardring", {
                contype = _P.flippedwell and (_P.channeltype == "nmos" and "n" or "p") or (_P.channeltype == "nmos" and "p" or "n"),
                ringwidth = _P.guardringwidth,
                holewidth = activewidth + leftactauxext + leftactext + rightactext + rightactauxext + _P.guardringleftsep + _P.guardringrightsep + _P.leftactivedummywidth + _P.leftactivedummyspace + _P.rightactivedummywidth + _P.rightactivedummyspace,
                holeheight = _P.fingerwidth + _P.guardringtopsep + _P.guardringbottomsep + _P.topactivedummywidth + _P.topactivedummyspace + _P.bottomactivedummywidth + _P.bottomactivedummyspace,
                fillwell = true,
                drawsegments = _P.guardringsegments,
                fillwell = _P.guardringfillwell,
                fillinnerimplant = _P.guardringfillimplant,
                innerimplantpolarity = _P.channeltype == "nmos" and "n" or "p",
                wellinnerextension = _P.guardringwellinnerextension,
                wellouterextension = _P.guardringwellouterextension,
                implantinnerextension = _P.guardringimplantinnerextension,
                implantouterextension = _P.guardringimplantouterextension,
                soiopeninnerextension = _P.guardringsoiopeninnerextension,
                soiopenouterextension = _P.guardringsoiopenouterextension,
            })
            guardring:move_point(guardring:get_area_anchor("innerboundary").bl, point.create(-leftactauxext - _P.leftactivedummywidth - _P.leftactivedummyspace, - _P.bottomactivedummywidth - _P.bottomactivedummyspace))
            guardring:translate(-_P.guardringleftsep, -_P.guardringbottomsep)
        else
            guardring = pcell.create_layout("auxiliary/guardring", "guardring", {
                contype = _P.flippedwell and (_P.channeltype == "nmos" and "n" or "p") or (_P.channeltype == "nmos" and "p" or "n"),
                ringwidth = _P.guardringwidth,
                holewidth = activewidth + leftactauxext + leftactext + rightactext + rightactauxext + _P.guardringleftsep + _P.guardringrightsep,
                holeheight = _P.fingerwidth + _P.guardringtopsep + _P.guardringbottomsep,
                fillwell = true,
                drawsegments = _P.guardringsegments,
                fillwell = _P.guardringfillwell,
                fillinnerimplant = _P.guardringfillimplant,
                innerimplantpolarity = _P.channeltype == "nmos" and "n" or "p",
                wellinnerextension = _P.guardringwellinnerextension,
                wellouterextension = _P.guardringwellouterextension,
                implantinnerextension = _P.guardringimplantinnerextension,
                implantouterextension = _P.guardringimplantouterextension,
                soiopeninnerextension = _P.guardringsoiopeninnerextension,
                soiopenouterextension = _P.guardringsoiopenouterextension,
            })
            guardring:move_point(guardring:get_area_anchor("innerboundary").bl, point.create(-leftactauxext, 0))
            guardring:translate(-_P.guardringleftsep, -_P.guardringbottomsep)
        end
        transistor:merge_into(guardring)
        transistor:add_area_anchor_bltr("outerguardring",
            guardring:get_area_anchor("outerboundary").bl,
            guardring:get_area_anchor("outerboundary").tr
        )
        transistor:add_area_anchor_bltr("innerguardring",
            guardring:get_area_anchor("innerboundary").bl,
            guardring:get_area_anchor("innerboundary").tr
        )
    end

    -- gate contacts
    local gatecontacttype = _P.drawrotationmarker and "gaterotated" or "gate"
    if _P.drawtopgate then
        if _P.allow_poly_connections then
            local contactfun = _P.drawtopgatestrap and geometry.contactbarebltr or geometry.contactbltr
            contactfun(transistor,
                gatecontacttype,
                point.create(gateblx + (1 - 1) * gatepitch, _P.fingerwidth + _P.topgatespace),
                point.create(gatetrx + (_P.fingers - 1) * gatepitch, _P.fingerwidth + _P.topgatespace + _P.topgatewidth),
                string.format(
                    "top gate contact:\n    x parameters: gatelength (%d)\n    y parameters: topgatewidth (%d)",
                    _P.gatelength, _P.topgatewidth
                )
            )
        else
            for i = 1, _P.fingers do
                local contactfun = _P.drawtopgatestrap and geometry.contactbarebltr or geometry.contactbltr
                contactfun(transistor,
                    gatecontacttype,
                    point.create(gateblx + (i - 1) * gatepitch, _P.fingerwidth + _P.topgatespace),
                    point.create(gatetrx + (i - 1) * gatepitch, _P.fingerwidth + _P.topgatespace + _P.topgatewidth),
                    string.format(
                        "top gate contact:\n    x parameters: gatelength (%d)\n    y parameters: topgatewidth (%d)",
                        _P.gatelength, _P.topgatewidth
                    )
                )
                transistor:add_area_anchor_bltr(string.format("topgate%d", i),
                    point.create(gateblx + (i - 1) * gatepitch, _P.fingerwidth + _P.topgatespace),
                    point.create(gatetrx + (i - 1) * gatepitch, _P.fingerwidth + _P.topgatespace + _P.topgatewidth)
                )
            end
        end
    end
    if _P.fingers > 0 and _P.drawtopgatestrap then
        local bl = point.create(gateblx + (1 - 1) * gatepitch - _P.topgateleftextension, _P.fingerwidth + _P.topgatespace)
        local tr = point.create(gatetrx + (_P.fingers - 1) * gatepitch + _P.topgaterightextension, _P.fingerwidth + _P.topgatespace + _P.topgatewidth)
        geometry.rectanglebltr(transistor, generics.metal(1), bl, tr)
        transistor:add_area_anchor_bltr("topgatestrap", bl, tr)
        if _P.allow_poly_connections then
            geometry.rectanglebltr(transistor, generics.gate(), bl, point.create(tr:getx(), gatetry))
        end
        if _P.drawtopgatevia and _P.topgatemetal > 1 then
            if _P.topgatecontinuousvia then
                geometry.viabltr_xcontinuous(transistor, 1, _P.topgatemetal, bl, tr)
            else
                geometry.viabltr(transistor, 1, _P.topgatemetal, bl, tr,
                    string.format(
                        "top gate strap via:\n    x parameters:\n        gatelength (%d)\n        (fingers - 1) * (gatelength + gatespace) (%d)\n        topgateleftextension (%d)\n        topgaterightextension (%d)\n    y parameters:\n        topgatewidth (%d)",
                        _P.gatelength, (_P.fingers - 1) * gatepitch, _P.topgateleftextension, _P.topgaterightextension, _P.topgatewidth
                    )
                )
            end
        end
    end
    if _P.drawbotgate then
        if _P.allow_poly_connections then
            local contactfun = _P.drawbotgatestrap and geometry.contactbarebltr or geometry.contactbltr
            contactfun(transistor,
                gatecontacttype,
                point.create(gateblx + (1 - 1) * gatepitch, -_P.botgatespace - _P.botgatewidth),
                point.create(gatetrx + (_P.fingers - 1) * gatepitch, -_P.botgatespace),
                string.format("bot gate contact:\n    x parameters: gatelength (%d)\n    y parameters: botgatewidth (%d)", _P.gatelength, _P.botgatewidth)
            )
        else
            for i = 1, _P.fingers do
                local contactfun = _P.drawbotgatestrap and geometry.contactbarebltr or geometry.contactbltr
                contactfun(transistor,
                    gatecontacttype,
                    point.create(gateblx + (i - 1) * gatepitch, -_P.botgatespace - _P.botgatewidth),
                    point.create(gatetrx + (i - 1) * gatepitch, -_P.botgatespace),
                    string.format("bot gate contact:\n    x parameters: gatelength (%d)\n    y parameters: botgatewidth (%d)", _P.gatelength, _P.botgatewidth)
                )
                transistor:add_area_anchor_bltr(string.format("botgate%d", i),
                    point.create(gateblx + (i - 1) * gatepitch, -_P.botgatespace - _P.botgatewidth),
                    point.create(gatetrx + (i - 1) * gatepitch, -_P.botgatespace)
                )
            end
        end
    end
    if _P.fingers > 0 and _P.drawbotgatestrap then
        local bl = point.create(gateblx + (1 - 1) * gatepitch - _P.botgateleftextension, -_P.botgatespace - _P.botgatewidth)
        local tr = point.create(gatetrx + (_P.fingers - 1) * gatepitch + _P.botgaterightextension, -_P.botgatespace)
        geometry.rectanglebltr(transistor, generics.metal(1), bl, tr)
        transistor:add_area_anchor_bltr("botgatestrap", bl, tr)
        if _P.allow_poly_connections then
            geometry.rectanglebltr(transistor, generics.gate(), point.create(bl:getx(), gatebly), tr)
        end
        if _P.drawbotgatevia and _P.botgatemetal > 1 then
            if _P.botgatecontinuousvia then
                geometry.viabltr_xcontinuous(transistor, 1, _P.botgatemetal, bl, tr)
            else
                geometry.viabltr(transistor, 1, _P.botgatemetal, bl, tr,
                    string.format("bot gate strap via:\n    x parameters:\n        gatelength (%d)\n        fingers * (gatelength + gatespace) (%d)\n        botgateleftextension (%d)\n        botgaterightextension (%d)\n    y parameters:\n        botgatewidth (%d)", _P.gatelength, _P.fingers * gatepitch, _P.botgateleftextension, _P.botgaterightextension, _P.botgatewidth)
                )
            end
        end
    end

    local sdviashift = (_P.sdviawidth - _P.sdwidth) / 2
    local sdmetalshift = (_P.sdmetalwidth - _P.sdwidth) / 2

    -- source/drain contacts and vias
    local sourceoffset
    local sourceviaoffset
    if _P.sourcealign == "top" then
        sourceoffset = _P.fingerwidth - _P.sourcesize
    elseif _P.sourcealign == "bottom" then
        sourceoffset = 0
    else -- center
        sourceoffset = (_P.fingerwidth - _P.sourceviasize) / 2
    end
    if _P.sourceviaalign == "top" then
        sourceviaoffset = _P.fingerwidth - _P.sourceviasize
    elseif _P.sourceviaalign == "bottom" then
        sourceviaoffset = 0
    else -- center
        sourceviaoffset = (_P.fingerwidth - _P.sourceviasize) / 2
    end
    local drainoffset
    local drainviaoffset
    if _P.drainalign == "top" then
        drainoffset = _P.fingerwidth - _P.drainsize
    elseif _P.drainalign == "bottom" then
        drainoffset = 0
    else -- center
        drainoffset = (_P.fingerwidth - _P.drainviasize) / 2
    end
    if _P.drainviaalign == "top" then
        drainviaoffset = _P.fingerwidth - _P.drainviasize
    elseif _P.drainviaalign == "bottom" then
        drainviaoffset = 0
    else -- center
        drainviaoffset = (_P.fingerwidth - _P.drainviasize) / 2
    end
    local splitsourceviasize = (_P.sourceviasize - _P.connectsourcewidth) / 2
    local splitsourceviaoffset
    if _P.channeltype == "nmos" then
        if _P.connectsourceinverse then
            splitsourceviaoffset = _P.fingerwidth - _P.connectsourcewidth - _P.connectsourceinlineoffset
        else
            splitsourceviaoffset = _P.connectsourceinlineoffset
        end
    else
        if _P.connectsourceinverse then
            splitsourceviaoffset = _P.connectsourceinlineoffset
        else
            splitsourceviaoffset = _P.fingerwidth - _P.connectsourcewidth - _P.connectsourceinlineoffset
        end
    end
    local splitdrainviasize = (_P.drainviasize - _P.connectdrainwidth) / 2
    local splitdrainviaoffset
    if _P.channeltype == "nmos" then
        if _P.connectdraininverse then
            splitdrainviaoffset = _P.connectdraininlineoffset
        else
            splitdrainviaoffset = _P.fingerwidth - _P.connectdrainwidth - _P.connectdraininlineoffset
        end
    else
        if _P.connectdraininverse then
            splitdrainviaoffset = _P.fingerwidth - _P.connectdrainwidth - _P.connectdraininlineoffset
        else
            splitdrainviaoffset = _P.connectdraininlineoffset
        end
    end
    local contacttype = _P.drawrotationmarker and "sourcedrainrotated" or "sourcedrain"
    -- values for interweaved via cuts
    if _P.drawsourcedrain ~= "none" then
        -- source
        if _P.drawsourcedrain == "both" or _P.drawsourcedrain == "source" then
            for i = 1, _P.fingers + 1, 2 do
                local shift = gateblx - (_P.gatespace + _P.sdwidth) / 2 + (i - 1) * gatepitch
                local bl = point.create(shift, sourceoffset)
                local tr = point.create(shift + _P.sdwidth, sourceoffset + _P.sourcesize)
                local debugstr = string.format("source/drain contacts:\n    x parameters: sdwidth (%d)\n    y parameters: sourcesize (%d)", _P.sdwidth, _P.sourcesize)
                if not util.any_of(i, _P.excludesourcedraincontacts) then
                    geometry.contactbarebltr(transistor, contacttype, bl, tr, debugstr)
                    if _P.drawsourcevia and _P.sourceviametal > 1 and
                        not (i == 1 and not _P.drawfirstsourcevia or i == _P.fingers + 1 and not _P.drawlastsourcevia) then
                        for metal = 1, _P.sourceviametal - 1 do
                            if _P.interweavevias and metal + 1 <= _P.sourceviametal then
                                local alternate = false
                                local viatable = geometry.calculate_viabltr(
                                    metal, metal + 1,
                                    point.create(shift - sdviashift, sourceviaoffset),
                                    point.create(shift + _P.sdviawidth - sdviashift, sourceviaoffset + _P.sourceviasize),
                                    _P.minviaxspace, _P.minviayspace
                                )
                                for _, viaentry in ipairs(viatable) do
                                    local numcuts = viaentry.yrep
                                    local cutxoffset = viaentry.xoffset
                                    local cutyoffset = viaentry.yoffset
                                    local cutwidth = viaentry.width
                                    local cutheight = viaentry.width
                                    local cutspace = viaentry.yspace
                                    local cutlayer = viaentry.layer
                                    if _P.alternateinterweaving and alternate then
                                        numcuts = numcuts - 1
                                        cutyoffset = cutyoffset + math.floor((viaentry.yspace + viaentry.width) / 2)
                                        alternate = not alternate
                                    end
                                    for i = 1, numcuts do
                                        geometry.rectanglebltr(transistor, cutlayer,
                                            point.create(shift - sdviashift + cutxoffset, sourceviaoffset + cutyoffset + (i - 1) * (cutspace + cutheight)),
                                            point.create(shift - sdviashift + cutxoffset + cutwidth, sourceviaoffset + cutyoffset + (i - 1) * (cutspace + cutheight) + cutheight)
                                        )
                                    end
                                end
                            else
                                if metal < _P.sourceviametal - 1 then
                                    geometry.viabarebltr(transistor, metal, metal + 1,
                                        point.create(shift - sdviashift, sourceviaoffset),
                                        point.create(shift + _P.sdviawidth - sdviashift, sourceviaoffset + _P.sourceviasize),
                                        string.format(
                                            "source via:\n    x parameters: sdviawidth (%d)\n    y parameters: sourceviasize (%d)",
                                            _P.sdviawidth, _P.sourceviasize
                                        )
                                    )
                                else
                                    if _P.splitsourcevias then
                                        geometry.viabarebltr(transistor, _P.sourceviametal - 1, _P.sourceviametal,
                                            point.create(shift - sdviashift, sourceviaoffset),
                                            point.create(shift + _P.sdviawidth - sdviashift, splitsourceviaoffset)
                                        )
                                        geometry.viabarebltr(transistor, _P.sourceviametal - 1, _P.sourceviametal,
                                            point.create(shift - sdviashift, splitsourceviaoffset + _P.connectsourcewidth),
                                            point.create(shift + _P.sdviawidth - sdviashift, sourceviaoffset + _P.sourceviasize)
                                        )
                                    else
                                        geometry.viabarebltr(transistor, _P.sourceviametal - 1, _P.sourceviametal,
                                            point.create(shift - sdviashift, sourceviaoffset),
                                            point.create(shift + _P.sdviawidth - sdviashift, sourceviaoffset + _P.sourceviasize),
                                            string.format(
                                                "source via:\n    x parameters: sdviawidth (%d)\n    y parameters: sourceviasize (%d)",
                                                _P.sdviawidth, _P.sourceviasize
                                            )
                                        )
                                    end
                                end
                            end
                        end
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
                if not util.any_of(i, _P.excludesourcedraincontacts) then
                    geometry.contactbarebltr(
                        transistor, contacttype, bl, tr,
                        string.format(
                            "drain contact:\n    x parameters: sdwidth (%d)\n    y parameters: drainsize (%d)",
                            _P.sdwidth, _P.drainsize
                        )
                    )
                    if _P.drawdrainvia and _P.drainviametal > 1 and
                        not (i == 2 and not _P.drawfirstdrainvia or i == _P.fingers + 1 and not _P.drawlastdrainvia) then
                        for metal = 1, _P.drainviametal - 1 do
                            if _P.interweavevias and metal + 1 <= _P.drainviametal then
                                local alternate = true
                                local viatable = geometry.calculate_viabltr(
                                    metal, metal + 1,
                                    point.create(shift - sdviashift, drainviaoffset),
                                    point.create(shift + _P.sdviawidth - sdviashift, drainviaoffset + _P.drainviasize),
                                    _P.minviaxspace, _P.minviayspace
                                )
                                for _, viaentry in ipairs(viatable) do
                                    local numcuts = viaentry.yrep - 1
                                    local cutxoffset = viaentry.xoffset
                                    local cutyoffset = math.floor(viaentry.yoffset + (viaentry.yspace + viaentry.width) / 2)
                                    local cutwidth = viaentry.width
                                    local cutheight = viaentry.width
                                    local cutspace = viaentry.yspace
                                    local cutlayer = viaentry.layer
                                    if _P.alternateinterweaving and alternate then
                                        numcuts = numcuts - 1
                                        cutyoffset = cutyoffset + math.floor((viaentry.yspace + viaentry.width) / 2)
                                        alternate = not alternate
                                    end
                                    for i = 1, numcuts do
                                        geometry.rectanglebltr(transistor, cutlayer,
                                            point.create(shift - sdviashift + cutxoffset, drainviaoffset + cutyoffset + (i - 1) * (cutspace + cutheight)),
                                            point.create(shift - sdviashift + cutxoffset + cutwidth, drainviaoffset + cutyoffset + (i - 1) * (cutspace + cutheight) + cutheight)
                                        )
                                    end
                                end
                            else
                                if metal < _P.drainviametal - 1 then
                                    geometry.viabarebltr(transistor, metal, metal + 1,
                                        point.create(shift - sdviashift, drainviaoffset),
                                        point.create(shift + _P.sdviawidth - sdviashift, drainviaoffset + _P.drainviasize),
                                        string.format(
                                            "drain via:\n    x parameters: sdviawidth (%d)\n    y parameters: drainviasize (%d)",
                                            _P.sdviawidth, _P.drainviasize
                                        )
                                    )
                                else
                                    if _P.splitdrainvias then
                                        geometry.viabarebltr(transistor, _P.drainviametal - 1, _P.drainviametal,
                                            point.create(shift - sdviashift, splitdrainviaoffset - splitdrainviasize),
                                            point.create(shift + _P.sdviawidth - sdviashift, splitdrainviaoffset)
                                        )
                                        geometry.viabarebltr(transistor, _P.drainviametal - 1, _P.drainviametal,
                                            point.create(shift - sdviashift, splitdrainviaoffset + _P.connectdrainwidth),
                                            point.create(shift + _P.sdviawidth - sdviashift, splitdrainviaoffset + _P.connectdrainwidth + splitdrainviasize)
                                        )
                                    else
                                        geometry.viabarebltr(transistor, _P.drainviametal - 1, _P.drainviametal,
                                            point.create(shift - sdviashift, drainviaoffset),
                                            point.create(shift + _P.sdviawidth - sdviashift, drainviaoffset + _P.drainviasize),
                                            string.format(
                                                "drain via:\n    x parameters: sdviawidth (%d)\n    y parameters: drainviasize (%d)",
                                                _P.sdviawidth, _P.drainviasize
                                            )
                                        )
                                    end
                                end
                            end
                        end
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
        local startindex = _P.diodeconnectedreversed and 1 or 2
        for i = startindex, _P.fingers + 1, 2 do
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
                if sourceoffset + _P.sourcesize < _P.fingerwidth + _P.connectsourcespace then -- don't draw connections if they are malformed
                    if not (i == 1 and not _P.drawfirstsourcevia or i == _P.fingers + 1 and not _P.drawlastsourcevia) then
                        for sourcemetal = _P.sourcestartmetal, _P.sourceendmetal do
                            geometry.rectanglebltr(transistor, generics.metal(sourcemetal),
                                point.create(shift, sourceoffset + _P.sourcesize),
                                point.create(shift + _P.sdmetalwidth, _P.fingerwidth + _P.connectsourcespace)
                            )
                        end
                    end
                end
                if _P.connectsourceboth then
                    if -_P.connectsourceotherspace < sourceoffset then -- don't draw connections if they are malformed
                        if not (i == 1 and not _P.drawfirstsourcevia or i == _P.fingers + 1 and not _P.drawlastsourcevia) then
                            for sourcemetal = _P.sourcestartmetal, _P.sourceendmetal do
                                geometry.rectanglebltr(transistor, generics.metal(sourcemetal),
                                    point.create(shift, -_P.connectsourceotherspace),
                                    point.create(shift + _P.sdmetalwidth, sourceoffset)
                                )
                            end
                        end
                    end
                end
            else
                if -_P.connectsourcespace < sourceoffset then -- don't draw connections if they are malformed
                    if not (i == 1 and not _P.drawfirstsourcevia or i == _P.fingers + 1 and not _P.drawlastsourcevia) then
                        for sourcemetal = _P.sourcestartmetal, _P.sourceendmetal do
                            geometry.rectanglebltr(transistor, generics.metal(sourcemetal),
                                point.create(shift, -_P.connectsourcespace),
                                point.create(shift + _P.sdmetalwidth, sourceoffset)
                            )
                        end
                    end
                end
                if _P.connectsourceboth then
                    if sourceoffset + _P.sourcesize < _P.fingerwidth + _P.connectsourceotherspace then -- don't draw connections if they are malformed
                        if not (i == 1 and not _P.drawfirstsourcevia or i == _P.fingers + 1 and not _P.drawlastsourcevia) then
                            for sourcemetal = _P.sourcestartmetal, _P.sourceendmetal do
                                geometry.rectanglebltr(transistor, generics.metal(sourcemetal),
                                    point.create(shift, sourceoffset + _P.sourcesize),
                                    point.create(shift + _P.sdmetalwidth, _P.fingerwidth + _P.connectsourceotherspace)
                                )
                            end
                        end
                    end
                end
            end
        end
    end

    -- source strap
    if _P.fingers > 0 then
        local leftext = _P.connectsourceleftext
        local rightext = _P.connectsourcerightext
        if _P.connectsourceautooddext then
            rightext = rightext + gatepitch
        end
        local blx = leftactext - (_P.gatespace + _P.sdmetalwidth) / 2
        local trx = blx + 2 * (_P.fingers // 2) * gatepitch + _P.sdmetalwidth
        if _P.connectsourceinline then
            local bly
            if _P.channeltype == "nmos" then
                if _P.connectsourceinverse then
                    bly = _P.fingerwidth - _P.connectsourcewidth - _P.connectsourceinlineoffset
                else
                    bly = _P.connectsourceinlineoffset
                end
            else
                if _P.connectsourceinverse then
                    bly = _P.connectsourceinlineoffset
                else
                    bly = _P.fingerwidth - _P.connectsourcewidth - _P.connectsourceinlineoffset
                end
            end
            if _P.drawsourcestrap then
                for sourcemetal = _P.sourcestartmetal, _P.sourceendmetal do
                    geometry.rectanglebltr(transistor, generics.metal(sourcemetal),
                        point.create(blx - leftext, bly),
                        point.create(trx + rightext, bly + _P.connectsourcewidth)
                    )
                end
            end
            transistor:add_area_anchor_bltr("sourcestrap",
                point.create(blx - leftext, bly),
                point.create(trx + rightext, bly + _P.connectsourcewidth)
            )
        else
            local bly1, bly2
            if _P.channeltype == "nmos" then
                if _P.connectsourceinverse then
                    bly1 = _P.fingerwidth + _P.connectsourcespace
                    bly2 = -_P.connectsourceotherspace - _P.connectsourceotherwidth
                else
                    bly1 = -_P.connectsourcespace - _P.connectsourcewidth
                    bly2 = _P.fingerwidth + _P.connectsourceotherspace
                end
            else
                if _P.connectsourceinverse then
                    bly1 = -_P.connectsourcespace - _P.connectsourcewidth
                    bly2 = _P.fingerwidth + _P.connectsourceotherspace
                else
                    bly1 = _P.fingerwidth + _P.connectsourcespace
                    bly2 = -_P.connectsourceotherspace - _P.connectsourceotherwidth
                end
            end
            -- main strap
            if _P.drawsourcestrap then
                for sourcemetal = _P.sourcestartmetal, _P.sourceendmetal do
                    geometry.rectanglebltr(transistor, generics.metal(sourcemetal),
                        point.create(blx - leftext, bly1),
                        point.create(trx + rightext, bly1 + _P.connectsourcewidth)
                    )
                    if _P.connectsourceboth then
                        -- other strap
                        geometry.rectanglebltr(transistor, generics.metal(sourcemetal),
                            point.create(blx - _P.connectsourceotherleftext, bly2),
                            point.create(trx + _P.connectsourceotherrightext, bly2 + _P.connectsourceotherwidth)
                        )
                    end
                end
            end
            -- main anchor
            transistor:add_area_anchor_bltr("sourcestrap",
                point.create(blx - leftext, bly1),
                point.create(trx + rightext, bly1 + _P.connectsourcewidth)
            )
            if _P.connectsourceboth then
                -- other anchor
                transistor:add_area_anchor_bltr("othersourcestrap",
                    point.create(blx - _P.connectsourceotherleftext, bly2),
                    point.create(trx + _P.connectsourceotherrightext, bly2 + _P.connectsourceotherwidth)
                )
                if bly1 < bly2 then
                    transistor:add_area_anchor_bltr("uppersourcestrap",
                        point.create(blx - leftext, bly2),
                        point.create(trx + rightext, bly2 + _P.connectsourcewidth)
                    )
                    transistor:add_area_anchor_bltr("lowersourcestrap",
                        point.create(blx - leftext, bly1),
                        point.create(trx + rightext, bly1 + _P.connectsourcewidth)
                    )
                else
                    transistor:add_area_anchor_bltr("lowersourcestrap",
                        point.create(blx - leftext, bly2),
                        point.create(trx + rightext, bly2 + _P.connectsourceotherwidth)
                    )
                    transistor:add_area_anchor_bltr("uppersourcestrap",
                        point.create(blx - leftext, bly1),
                        point.create(trx + rightext, bly1 + _P.connectsourcewidth)
                    )
                end
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
            local conndrainoffset = _P.drainstartmetal > 1 and drainviaoffset or drainoffset
            local conndraintop = _P.drainstartmetal > 1 and _P.drainviasize or _P.drainsize
            if draininvert then
                if -_P.connectdrainspace < conndrainoffset then -- don't draw connections if they are malformed
                    if not (i == 2 and not _P.drawfirstdrainvia or i == _P.fingers + 1 and not _P.drawlastdrainvia) then
                        for drainmetal = _P.drainstartmetal, _P.drainendmetal do
                            geometry.rectanglebltr(transistor, generics.metal(drainmetal),
                                point.create(shift, -_P.connectdrainspace),
                                point.create(shift + _P.sdmetalwidth, conndrainoffset)
                            )
                        end
                    end
                end
                if _P.connectdrainboth then
                    if conndrainoffset + conndraintop < _P.fingerwidth + _P.connectdrainotherspace then -- don't draw connections if they are malformed
                       if not (i == 2 and not _P.drawfirstdrainvia or i == _P.fingers + 1 and not _P.drawlastdrainvia) then
                            for drainmetal = _P.drainstartmetal, _P.drainendmetal do
                                geometry.rectanglebltr(transistor, generics.metal(drainmetal),
                                    point.create(shift, conndrainoffset + conndraintop),
                                    point.create(shift + _P.sdmetalwidth, _P.fingerwidth + _P.connectdrainotherspace)
                                )
                            end
                        end
                    end
                end
            else
                if conndrainoffset + conndraintop < _P.fingerwidth + _P.connectdrainspace then -- don't draw connections if they are malformed
                   if not (i == 2 and not _P.drawfirstdrainvia or i == _P.fingers + 1 and not _P.drawlastdrainvia) then
                        for drainmetal = _P.drainstartmetal, _P.drainendmetal do
                            geometry.rectanglebltr(transistor, generics.metal(drainmetal),
                                point.create(shift, conndrainoffset + conndraintop),
                                point.create(shift + _P.sdmetalwidth, _P.fingerwidth + _P.connectdrainspace)
                            )
                        end
                    end
                end
                if _P.connectdrainboth then
                    if -_P.connectdrainotherspace < conndrainoffset then -- don't draw connections if they are malformed
                        if not (i == 2 and not _P.drawfirstdrainvia or i == _P.fingers + 1 and not _P.drawlastdrainvia) then
                            for drainmetal = _P.drainstartmetal, _P.drainendmetal do
                                geometry.rectanglebltr(transistor, generics.metal(drainmetal),
                                    point.create(shift, -_P.connectdrainotherspace),
                                    point.create(shift + _P.sdmetalwidth, conndrainoffset)
                                )
                            end
                        end
                    end
                end
            end
        end
    end

    -- drain strap
    if _P.fingers > 0 then
        local leftext = _P.connectdrainleftext
        local rightext = _P.connectdrainrightext
        if _P.connectdrainautooddext then
            leftext = leftext + gatepitch
        end
        local blx = leftactext - (_P.gatespace + _P.sdmetalwidth) / 2 + (2 - 1) * gatepitch
        local trx = leftactext - (_P.gatespace + _P.sdmetalwidth) / 2 + (2 * ((_P.fingers + 1) // 2) - 1) * gatepitch + _P.sdmetalwidth
        if _P.connectdraininline then
            local bly
            if _P.channeltype == "nmos" then
                if _P.connectdraininverse then
                    bly = _P.connectdraininlineoffset
                else
                    bly = _P.fingerwidth - _P.connectdrainwidth - _P.connectdraininlineoffset
                end
            else
                if _P.connectdraininverse then
                    bly = _P.fingerwidth - _P.connectdrainwidth - _P.connectdraininlineoffset
                else
                    bly = _P.connectdraininlineoffset
                end
            end
            if _P.drawdrainstrap then
                for drainmetal = _P.drainstartmetal, _P.drainendmetal do
                    geometry.rectanglebltr(transistor, generics.metal(drainmetal),
                        point.create(blx - leftext, bly),
                        point.create(trx + rightext, bly + _P.connectdrainwidth)
                    )
                end
            end
            transistor:add_area_anchor_bltr("drainstrap",
                point.create(blx - leftext, bly),
                point.create(trx + rightext, bly + _P.connectdrainwidth)
            )
        else
            local bly1, bly2
            if _P.channeltype == "nmos" then
                if _P.connectdraininverse then
                    bly1 = -_P.connectdrainspace - _P.connectdrainwidth
                    bly2 = _P.fingerwidth + _P.connectdrainotherspace
                else
                    bly1 = _P.fingerwidth + _P.connectdrainspace
                    bly2 = -_P.connectdrainotherspace - _P.connectdrainotherwidth
                end
            else
                if _P.connectdraininverse then
                    bly1 = _P.fingerwidth + _P.connectdrainspace
                    bly2 = -_P.connectdrainotherspace - _P.connectdrainotherwidth
                else
                    bly1 = -_P.connectdrainspace - _P.connectdrainwidth
                    bly2 = _P.fingerwidth + _P.connectdrainotherspace
                end
            end
            if _P.drawdrainstrap then
                -- main strap
                for drainmetal = _P.drainstartmetal, _P.drainendmetal do
                    geometry.rectanglebltr(transistor, generics.metal(drainmetal),
                        point.create(blx - leftext, bly1),
                        point.create(trx + rightext, bly1 + _P.connectdrainwidth)
                    )
                    if _P.connectdrainboth then
                        -- other strap
                        geometry.rectanglebltr(transistor, generics.metal(drainmetal),
                            point.create(blx - _P.connectdrainotherleftext, bly2),
                            point.create(trx + _P.connectdrainotherrightext, bly2 + _P.connectdrainotherwidth)
                        )
                    end
                end
            end
            -- main anchor
            transistor:add_area_anchor_bltr("drainstrap",
                point.create(blx - leftext, bly1),
                point.create(trx + rightext, bly1 + _P.connectdrainwidth)
            )
            -- other anchor
            if _P.connectdrainboth then
                transistor:add_area_anchor_bltr("otherdrainstrap",
                    point.create(blx - _P.connectdrainotherleftext, bly2),
                    point.create(trx + _P.connectdrainotherrightext, bly2 + _P.connectdrainotherwidth)
                )
                if bly1 < bly2 then
                    transistor:add_area_anchor_bltr("upperdrainstrap",
                        point.create(blx - leftext, bly2),
                        point.create(trx + rightext, bly2 + _P.connectdrainwidth)
                    )
                    transistor:add_area_anchor_bltr("lowerdrainstrap",
                        point.create(blx - leftext, bly1),
                        point.create(trx + rightext, bly1 + _P.connectdrainwidth)
                    )
                else
                    transistor:add_area_anchor_bltr("lowerdrainstrap",
                        point.create(blx - leftext, bly2),
                        point.create(trx + rightext, bly2 + _P.connectdrainotherwidth)
                    )
                    transistor:add_area_anchor_bltr("upperdrainstrap",
                        point.create(blx - leftext, bly1),
                        point.create(trx + rightext, bly1 + _P.connectdrainwidth)
                    )
                end
            end
        end
    end

    -- extra source/drain straps (unconnected, useful for arrays)
    if _P.drawextrabotstrap then
        local blx = leftactext - (_P.gatespace + _P.sdmetalwidth) / 2 - _P.extrabotstrapleftextension + (_P.extrabotstrapleftalign - 1) * gatepitch
        local trx = leftactext - (_P.gatespace + _P.sdmetalwidth) / 2 + _P.extrabotstraprightextension + 2 * (_P.fingers // 2) * gatepitch + (_P.extrabotstraprightalign - _P.fingers) * gatepitch + _P.sdmetalwidth
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
        local blx = leftactext - (_P.gatespace + _P.sdmetalwidth) / 2 - _P.extratopstrapleftextension + (_P.extratopstrapleftalign - 1) * gatepitch
        local trx = leftactext - (_P.gatespace + _P.sdmetalwidth) / 2 + _P.extratopstraprightextension + 2 * (_P.fingers // 2) * gatepitch + (_P.extratopstraprightalign - _P.fingers) * gatepitch + _P.sdmetalwidth
        geometry.rectanglebltr(transistor, generics.metal(_P.extrabotstrapmetal),
            point.create(blx, _P.fingerwidth + _P.extratopstrapspace),
            point.create(trx, _P.fingerwidth + _P.extratopstrapspace + _P.extratopstrapwidth)
        )
        -- anchors
        transistor:add_area_anchor_bltr("extratopstrap",
            point.create(blx, _P.fingerwidth + _P.extratopstrapspace),
            point.create(trx, _P.fingerwidth + _P.extratopstrapspace + _P.extratopstrapwidth)
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

    if _P.shortsourcegate then
        if _P.drawtopgate and _P.drawtopgatestrap then
            geometry.rectanglebltr(transistor, generics.metal(1),
                point.create(
                    transistor:get_area_anchor_fmt("sourcedrain%d", 1).l,
                    transistor:get_area_anchor("topgatestrap").b
                ),
                point.create(
                    transistor:get_area_anchor_fmt("sourcedrain%d", -1).r,
                    transistor:get_area_anchor("topgatestrap").t
                )
            )
            for i = 1, _P.fingers + 1, 2 do
                geometry.rectanglebltr(transistor, generics.metal(1),
                    transistor:get_area_anchor_fmt("sourcedrain%d", i).tl,
                    point.create(
                        transistor:get_area_anchor_fmt("sourcedrain%d", i).r,
                        transistor:get_area_anchor("topgatestrap").b
                    )
                )
            end
        end
        if _P.drawbotgate and _P.drawbotgatestrap then
            geometry.rectanglebltr(transistor, generics.metal(1),
                point.create(
                    transistor:get_area_anchor_fmt("sourcedrain%d", 1).l,
                    transistor:get_area_anchor("botgatestrap").b
                ),
                point.create(
                    transistor:get_area_anchor_fmt("sourcedrain%d", -1).r,
                    transistor:get_area_anchor("botgatestrap").t
                )
            )
            for i = 1, _P.fingers + 1, 2 do
                geometry.rectanglebltr(transistor, generics.metal(1),
                    point.create(
                        transistor:get_area_anchor_fmt("sourcedrain%d", i).l,
                        transistor:get_area_anchor("botgatestrap").t
                    ),
                    transistor:get_area_anchor_fmt("sourcedrain%d", i).br
                )
            end
        end
    end

    if _P.shortdraingate then
        if _P.drawtopgate and _P.drawtopgatestrap then
            if _P.fingers > 2 then
                geometry.rectanglebltr(transistor, generics.metal(1),
                    point.create(
                        transistor:get_area_anchor_fmt("sourcedrain%d", 2).l,
                        transistor:get_area_anchor("topgatestrap").b
                    ),
                    point.create(
                        transistor:get_area_anchor_fmt("sourcedrain%d", -2).r,
                        transistor:get_area_anchor("topgatestrap").t
                    )
                )
            else
                geometry.rectanglebltr(transistor, generics.metal(1),
                    point.create(
                        transistor:get_area_anchor("topgatestrap").l,
                        transistor:get_area_anchor("topgatestrap").b
                    ),
                    point.create(
                        transistor:get_area_anchor_fmt("sourcedrain%d", 2).r,
                        transistor:get_area_anchor("topgatestrap").t
                    )
                )
            end
            for i = 2, _P.fingers + 1, 2 do
                geometry.rectanglebltr(transistor, generics.metal(1),
                    transistor:get_area_anchor_fmt("sourcedrain%d", i).tl,
                    point.create(
                        transistor:get_area_anchor_fmt("sourcedrain%d", i).r,
                        transistor:get_area_anchor("topgatestrap").b
                    )
                )
            end
        end
        if _P.drawbotgate and _P.drawbotgatestrap then
            if _P.fingers > 2 then
                geometry.rectanglebltr(transistor, generics.metal(1),
                    point.create(
                        transistor:get_area_anchor_fmt("sourcedrain%d", 2).l,
                        transistor:get_area_anchor("botgatestrap").b
                    ),
                    point.create(
                        transistor:get_area_anchor_fmt("sourcedrain%d", -2).r,
                        transistor:get_area_anchor("botgatestrap").t
                    )
                )
            else
                geometry.rectanglebltr(transistor, generics.metal(1),
                    point.create(
                        transistor:get_area_anchor("botgatestrap").l,
                        transistor:get_area_anchor("botgatestrap").b
                    ),
                    point.create(
                        transistor:get_area_anchor_fmt("sourcedrain%d", 2).r,
                        transistor:get_area_anchor("botgatestrap").t
                    )
                )
            end
            for i = 2, _P.fingers + 1, 2 do
                geometry.rectanglebltr(transistor, generics.metal(1),
                    point.create(
                        transistor:get_area_anchor_fmt("sourcedrain%d", i).l,
                        transistor:get_area_anchor("botgatestrap").t
                    ),
                    transistor:get_area_anchor_fmt("sourcedrain%d", i).br
                )
            end
        end
    end


    -- anchors for source drain active regions
    for i = 1, _P.fingers + 1 do
        local shift = leftactext - (_P.gatespace + _P.sdwidth) / 2 + (i - 1) * gatepitch
        transistor:add_area_anchor_bltr(string.format("sourcedrainactive%d", i),
            point.create(shift, 0),
            point.create(shift + _P.sdwidth, _P.fingerwidth)
        )
        transistor:add_area_anchor_bltr(string.format("sourcedrainactive%d", i - _P.fingers - 2),
            point.create(shift, 0),
            point.create(shift + _P.sdwidth, _P.fingerwidth)
        )
    end

    -- alignmentbox
    if _P.drawguardring then
        transistor:inherit_alignment_box(guardring)
    else
        transistor:set_alignment_box(
            point.create(leftactext - (_P.gatespace + _P.sdwidth) / 2, 0),
            point.create(leftactext - (_P.gatespace + _P.sdwidth) / 2 + (_P.fingers + 1 - 1) * gatepitch, _P.fingerwidth),
            point.create(leftactext - (_P.gatespace + _P.sdwidth) / 2 + _P.sdwidth, 0),
            point.create(leftactext - (_P.gatespace + _P.sdwidth) / 2 + (_P.fingers + 1 - 1) * gatepitch + _P.sdwidth, _P.fingerwidth)
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


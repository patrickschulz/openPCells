function info()
    local detail = {
        "This cell implements a metal-oxide-semiconductor (MOS) transistor.",
        "It is the basic building block of CMOS circuits and used by various other opc cells such as 'basic/cmos' or 'basic/stacked_mosfet_array'.",
        "This cell is also useful on its own and meant to be employed for implementing single transistors.",
        "It tries to mimic typical pcell behaviour often found for elementary MOSFET devices in PDKs, so it can connect source/drain regions, draw multiple fingers, gate straps, guardrings etc.",
        "This cell features more than 300 parameters, but most of them are only required for special cases.",
        "If the technology files are set up properly, a simple call with parameters like 'fingers = 8' and 'fingerwidth = 500' shoud be sufficient for a DRC-clean transistor."
    }
    local example = [[{
    channeltype = "nmos",
    oxidetype = 2,
    gatelength = 200,
    gatespace = 200,
    fingerwidth = 1500,
    fingers = 8,
}]]
    return {
        brief = "Basic cell for the implementation of a MOSFET.",
        detail = detail,
        example = example,
    }
end

function parameters()
    pcell.add_parameters(
        { "channeltype(Channel Type)",                                                                  "nmos", posvals = set("nmos", "pmos"), info = "polarity of the mosfet. Can be either 'nmos' or 'pmos'." },
        { "drawimplant",                                                                                true, info = "switch to enable/disable implant drawing. Typically this should be enabled, as a missing implant will most likely cause both the DRC and the LVS to fail. However, in certain situations manual drawing of the implant can be beneficial" },
        { "implantalignwithactive",                                                                     false, info = "set reference points for implant extensions. If this is false, the implant extensions are autmatically calculated so that the implant covers all gates. With this option enabled, the implant extensions are referenced to the active region. This is useful for having precise control over the implant extensions in mosfet arrays with varying gate heights. This option sets left/right/top/bottom alignment, the dedicated switches can be used for more fine-grained control." },
        { "implantalignleftwithactive",                                                                 false, follow = "implantalignwithactive", info = "set reference point for implant left extensions. If this is false, the implant left extension is autmatically calculated so that the implant covers the left gates. With this option enabled, the implant left extension is referenced to the active region. This is useful for having precise control over the implant extensions in mosfet arrays with varying gate heights" },
        { "implantalignrightwithactive",                                                                false, follow = "implantalignwithactive", info = "set reference point for implant right extensions. If this is false, the implant right extension is autmatically calculated so that the implant covers the right gates. With this option enabled, the implant right extension is referenced to the active region. This is useful for having precise control over the implant extensions in mosfet arrays with varying gate heights" },
        { "implantaligntopwithactive",                                                                  false, follow = "implantalignwithactive", info = "set reference point for implant top extensions. If this is false, the implant top extension is autmatically calculated so that the implant covers the top part of all gates. With this option enabled, the implant top extension is referenced to the active region. This is useful for having precise control over the implant extensions in mosfet arrays with varying gate heights" },
        { "implantalignbottomwithactive",                                                               false, follow = "implantalignwithactive", info = "set reference point for implant bottom extensions. If this is false, the implant bottom extension is autmatically calculated so that the implant covers the bottom part of all gates. With this option enabled, the implant bottom extension is referenced to the active region. This is useful for having precise control over the implant extensions marker extensions in mosfet arrays with varying gate heights" },
        { "implantrespectpolylines",                                                                    true },
        { "drawoxidetype",                                                                              true, info = "switch to enable/disable oxidetype drawing. Typically this should be enabled, as a missing oxidetype might cause the LVS to misinterpret the device. However, in certain situations manual drawing of the oxidetype can be beneficial." },
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
        { "mosfetmarkerincludefloatingdummies",                                                         true },
        { "mosfetmarkeralignatsourcedrain(Align MOSFET Marker at Source/Drain)",                        false, info = "set reference points for mosfetmarker extensions. If this is false, the mosfetmarker extensions are autmatically calculated so that the mosfetmarker covers all gates. With this option enabled, the mosfetmarker extensions are referenced to the active region. This is useful for having precise control over the mosfetmarker extensions in mosfet arrays with varying gate heights"  },
        { "flippedwell(Flipped Well)",                                                                  false, info = "enable if the device is a flipped-well device. The wells are inferred from the channeltype: non-flipped-well: pmos -> n-well, nmos -> p-well and vice versa" },
        { "fingers(Number of Fingers)",                                                                 2, argtype = "integer", posvals = interval(0, inf), info = "number of gate fingers. The total width of the device is fingerwidth * fingers" },
        { "fingerwidth(Finger Width)",                                                                  technology.get_dimension("Minimum Gate Width"), argtype = "integer", info = "gate finger width. The total width of the device is fingerwidth * finger" },
        { "gatelength(Gate Length)",                                                                    technology.get_dimension("Minimum Gate Length"), argtype = "integer", info = "drawn gate length (channel length)" },
        { "gatespace(Gate Spacing)",                                                                    technology.get_dimension("Minimum Gate XSpace", "Minimum Gate Space"), argtype = "integer", info = "gate space between the polysilicon lines" },
        { "allow_poly_connections",                                                                     technology.has_feature("allow_poly_routing") },
        { "minimum_gate_contact_size",                                                                  technology.get_dimension("Minimum Gate Contact Region Size") },
        { "topgatepolyextension",                                                                       0 },
        { "topgatepolyleftrightextension",                                                              technology.get_optional_dimension("Gate Contact Poly XExtension", 0), follow = "topgatepolyextension" },
        { "topgatepolyleftextension",                                                                   technology.get_optional_dimension("Gate Contact Poly XExtension", 0), follow = "topgatepolyleftrightextension" },
        { "topgatepolyrightextension",                                                                  technology.get_optional_dimension("Gate Contact Poly XExtension", 0), follow = "topgatepolyleftrightextension" },
        { "topgatepolytopbottomextension",                                                              technology.get_optional_dimension("Gate Contact Poly YExtension", 0), follow = "topgatepolyextension" },
        { "topgatepolytopextension",                                                                    technology.get_optional_dimension("Gate Contact Poly YExtension", 0), follow = "topgatepolytopbottomextension" },
        { "topgatepolybottomextension",                                                                 technology.get_optional_dimension("Gate Contact Poly YExtension", 0), follow = "topgatepolytopbottomextension" },
        { "botgatepolyextension",                                                                       0 },
        { "botgatepolyleftrightextension",                                                              technology.get_optional_dimension("Gate Contact Poly XExtension", 0), follow = "botgatepolyextension" },
        { "botgatepolyleftextension",                                                                   technology.get_optional_dimension("Gate Contact Poly XExtension", 0), follow = "botgatepolyleftrightextension" },
        { "botgatepolyrightextension",                                                                  technology.get_optional_dimension("Gate Contact Poly XExtension", 0), follow = "botgatepolyleftrightextension" },
        { "botgatepolytopbottomextension",                                                              technology.get_optional_dimension("Gate Contact Poly YExtension", 0), follow = "botgatepolyextension" },
        { "botgatepolytopextension",                                                                    technology.get_optional_dimension("Gate Contact Poly YExtension", 0), follow = "botgatepolytopbottomextension" },
        { "botgatepolybottomextension",                                                                 technology.get_optional_dimension("Gate Contact Poly YExtension", 0), follow = "botgatepolytopbottomextension" },
        { "actext(Active Extension)",                                                                   technology.get_optional_dimension("Minimum Device Minimum Active Extension", 0), info = "left/right active extension. This is added to the calculated width of the active regions, dependent on the number of gates, the finger widths, gate spacing and left/right dummy devices" },
        { "sdwidth(Source/Drain Contact Width)",                                                        technology.get_dimension("Minimum Source/Drain Contact Region Size"), argtype = "integer", info = "width of the source/drain contact regions. Currently, all metals are drawn in the same width, which can be an issue for higher metals as vias might not fit. If this is the case the vias have to be drawn manually. This might change in the future." },
        { "sdmetalwidth(Source/Drain Metal Width)",                                                     technology.get_dimension_max("Minimum Source/Drain Contact Region Size", "Minimum M1 Width"), argtype = "integer", follow = "sdwidth", info = "width of the source/drain metals. This parameter follows 'sdwidth'." },
        { "sdm1botext",                                                                                 0, argtype = "integer", info = "extend the source/drain metal 1 region (bottom). This is useful for meeting minimum area requirements for devices with small finger widths" },
        { "sdm1topext",                                                                                 0, argtype = "integer", info = "extend the source/drain metal 1 region (top). This is useful for meeting minimum area requirements for devices with small finger widths" },
        { "sdmxbotext",                                                                                 0, argtype = "integer", follow = "sdm1botext", info = "extend the inter-level (not M1, not highest metal) source/drain metal region (bottom). This is useful for meeting minimum area requirements for devices with small finger widths" },
        { "sdmxtopext",                                                                                 0, argtype = "integer", follow = "sdm1topext", info = "extend the inter-level (not M1, not highest metal) source/drain metal region (top). This is useful for meeting minimum area requirements for devices with small finger widths" },
        { "sdmetalwidths",                                                                              {}, info = "width of source/drain metals, given as an array with one entry per metal. Missing entries are taken from 'sdmetalwidth'" },
        { "interweavevias",                                                                             false },
        { "alternateinterweaving",                                                                      true },
        { "minviaxspace",                                                                               0 },
        { "minviayspace",                                                                               0 },
        { "gtopext(Gate Top Extension)",                                                                technology.get_dimension("Minimum Gate Extension"), info = "top gate extension. This extension depends on the automatically calculated gate extensions (which depend for instance on gate contacts). This means that if 'gtopext' is smaller than the automatic extensions, the layout is not changed at all." },
        { "gbotext(Gate Bottom Extension)",                                                             technology.get_dimension("Minimum Gate Extension"), info = "bottom gate extension. This extension depends on the automatically calculated gate extensions (which depend for instance on gate contacts). This means that if 'gbotext' is smaller than the automatic extensions, the layout is not changed at all." },
        { "gtopextadd(Gate Additional Top Extension)",                                                  0, info = "Unconditional gate top extension (similar to 'gtopext', but always extends)." },
        { "gbotextadd(Gate Additional Bottom Extension)",                                               0, info = "Unconditional gate bottom extension (similar to 'gbotext', but always extends)." },
        { "gatetopabsoluteheight(Gate Absolute Top Height)",                                            0, info = "Alternative gate top extension parameter. If this is non-zero, it overwrites any gate extension values and applies the given height to the gate height (measured from the active region)", },
        { "gatebotabsoluteheight(Gate Absolute Bottom Height)",                                         0, info = "Alternative gate bottom extension parameter. If this is non-zero, it overwrites any gate extension values and applies the given height to the gate height (measured from the active region)", },
        { "drawleftstopgate(Draw Left Stop Gate)",                                                      false, info = "draw a gate where one half of it covers the active region, the other does not (left side). This gate is covered with the layer 'diffusionbreakgate'. This is required in some technologies for short-length devices" },
        { "drawrightstopgate(Draw Left Stop Gate)",                                                     false, info = "draw a gate where one half of it covers the active region, the other does not (right side). This gate is covered with the layer 'diffusionbreakgate'. This is required in some technologies for short-length devices" },
        { "endleftwithgate(End Left Side With Gate)",                                                   false, follow = "drawleftstopgate", info = "align the left end of the active region so that only half of the left-most gate covers the active region. Follows 'drawleftstopgate'." },
        { "endrightwithgate(End Right Side With Gate)",                                                 false, follow = "drawrightstopgate", info = "align the right end of the active region so that only half of the right-most gate covers the active region. Follows 'drawrightstopgate'." },
        { "leftendgatelength(Left End Gate Length)",                                                    technology.get_dimension("Minimum Gate Length"), follow = "gatelength" },
        { "leftendgatespace(Left End Gate Space)",                                                      technology.get_dimension("Minimum Gate XSpace", "Minimum Gate Space"), follow = "gatespace" },
        { "rightendgatelength(Right End Gate Length)",                                                  technology.get_dimension("Minimum Gate Length"), follow = "gatelength" },
        { "rightendgatespace(Right End Gate Space)",                                                    technology.get_dimension("Minimum Gate XSpace", "Minimum Gate Space"), follow = "gatespace" },
        { "drawtopgate(Draw Top Gate Contact)",                                                         false, info = "draw gate contacts on the upper side of the active region. The contact region width is the gate length, the height is 'topgatewidth'. The space to the active region is 'topgatespace'." },
        { "drawtopgatestrap(Draw Top Gate Strap)",                                                      false, follow = "drawtopgate", info = "Connect all top gate contacts by a metal strap. Follows 'drawtopgate'. If this is false but 'drawtopgate' is true then no metal is drawn, which will probably result in DRC errors. This option is meant for situations where the gate strap is drawn manually." },
        { "topgateadjustforsdstraps",                                                                   true },
        { "topgatewidth(Top Gate Width)",                                                               technology.get_dimension("Minimum M1 Width"), argtype = "integer", info = "Width of the metal strap connecting all top gate contacts." },
        { "topgateleftextension(Top Gate Left Extension)",                                              0, info = "Left extension of top gate metal strap. Positive values extend the strap on the left side beyond (to the left) of the gate, negative values in the opposite direction (but this is likely to cause an DRC error). So while negative values are possible, they are probably not useful." },
        { "topgaterightextension(Top Gate Right Extension)",                                            0, info = "Right extension of top gate metal strap. Positive values extend the strap on the right side beyond (to the right) of the gate, negative values in the opposite direction (but this is likely to cause an DRC error). So while negative values are possible, they are probably not useful." },
        { "topgateminwidth(Top Gate Strap Minimum Width)",                                              0 },
        { "topgatespace(Top Gate Space)",                                                               technology.get_dimension("Minimum M1 Space"), argtype = "integer", info = "Space between the active region and the lower edge of the top gate contacts/metal strap" },
        { "topgatemetal(Top Gate Strap Metal)",                                                         1, info = "Metal index (can be negative) of the top gate metal straps. If this is higher than 1 and 'drawtopgatevia' is true, vias are drawn." },
        { "drawtopgatevia(Draw Top Gate Via)",                                                          true, info = "Enable the drawing of vias on the top gate metal strap. This only makes a difference if 'topgatemetal' is higher than 1." },
        { "topgatecontinuousvia(Top Gate Continuous Via)",                                              false, info = "Make the drawn via of the top gate metal strap a continuous via." },
        { "drawbotgate(Draw Bottom Gate Contact)",                                                      false, info = "draw gate contacts on the upper side of the active region. The contact region width is the gate length, the height is 'topgatewidth'. The space to the active region is 'topgatespace'." },
        { "drawbotgatestrap(Draw Bottom Gate Strap)",                                                   false, follow = "drawbotgate", info = "Connect all bottom gate contacts by a metal strap. Follows 'drawbotgate'. If this is false but 'drawbotgate' is true then no metal is drawn, which will probably result in DRC errors. This option is meant for situations where the gate strap is drawn manually." },
        { "botgateadjustforsdstraps",                                                                   true },
        { "botgatewidth(Bottom Gate Width)",                                                            technology.get_dimension("Minimum M1 Width"), argtype = "integer", info = "Width of the metal strap connecting all bottom gate contacts." },
        { "botgateleftextension(Bottom Gate Left Extension)",                                           0, info = "Left extension of bottom gate metal strap. Positive values extend the strap on the left side beyond (to the left) of the gate, negative values in the opposite direction (but this is likely to cause an DRC error). So while negative values are possible, they are probably not useful." },
        { "botgaterightextension(Bottom Gate Right Extension)",                                         0, info = "Right extension of bottom gate metal strap. Positive values extend the strap on the right side beyond (to the right) of the gate, negative values in the opposite direction (but this is likely to cause an DRC error). So while negative values are possible, they are probably not useful." },
        { "botgateminwidth(Bottom Gate Strap Minimum Width)",                                           0 },
        { "botgatespace(Bottom Gate Space)",                                                            technology.get_dimension("Minimum M1 Space"), argtype = "integer", info = "Space between the active region and the lower edge of the bottom gate contacts/metal strap" },
        { "botgatemetal(Bottom Gate Strap Metal)",                                                      1, info = "Metal index (can be negative) of the bottom gate metal straps. If this is higher than 1 and 'drawbotgatevia' is true, vias are drawn." },
        { "drawbotgatevia(Draw Bottom Gate Via)",                                                       true, info = "Enable the drawing of vias on the bottom gate metal strap. This only makes a difference if 'botgatemetal' is higher than 1." },
        { "botgatecontinuousvia(Bottom Gate Continuous Via)",                                           false, info = "Make the drawn via of the bottom gate metal strap a continuous via." },
        { "drawtopgatecut(Draw Top Gate Cut)",                                                          false, info = "Draw a gate cut rectangle above the active region (the 'top' gates)." },
        { "topgatecutheight(Top Gate Cut Y Height)",                                                    technology.get_dimension("Minimum Gate Cut Height", "Minimum Gate YSpace", "Minimum Gate Space"), info = "Width of the top gate cut." },
        { "topgatecutspace(Top Gate Cut Y Space)",                                                      0, info = "Space between the active region and the top gate cut." },
        { "topgatecutleftext(Top Gate Cut Left Extension)",                                             0, info = "Left extension of the top gate cut. Without extension, the gate cut covers the underlying gate in x-direction exactly." },
        { "topgatecutrightext(Top Gate Cut Right Extension)",                                           0, info = "Right extension of the top gate cut. Without extension, the gate cut covers the underlying gate in x-direction exactly." },
        { "drawbotgatecut(Draw Top Gate Cut)",                                                          false, info = "Draw a gate cut rectangle above the active region (the 'bottom' gates)." },
        { "botgatecutheight(Top Gate Cut Y Height)",                                                    technology.get_dimension("Minimum Gate Cut Height", "Minimum Gate YSpace", "Minimum Gate Space"), info = "Width of the bottom gate cut." },
        { "botgatecutspace(Top Gate Cut Y Space)",                                                      0, info = "Space between the active region and the bottom gate cut." },
        { "botgatecutleftext(Top Gate Cut Left Extension)",                                             0, info = "Left extension of the bottom gate cut. Without extension, the gate cut covers the underlying gate in x-direction exactly." },
        { "botgatecutrightext(Top Gate Cut Right Extension)",                                           0, info = "Right extension of the bottom gate cut. Without extension, the gate cut covers the underlying gate in x-direction exactly." },
        { "simulatemissinggatecut",                                                                     false, info = "Draw the gates with gate cuts as if the technology had no gate cuts (this splits the gates). This is only useful for technologies that support gate cuts." },
        { "drawsourcedrain(Draw Source/Drain Contacts)",                                                "both", posvals = set("both", "source", "drain", "none"), info = "Control which source/drain contacts are drawn. The possible values are 'both' (source and drain), 'source', 'drain' or 'none'. More fine-grained control can be obtained by the parameter 'excludesourcedraincontacts'." },
        { "excludesourcedraincontacts(Exclude Source/Drain Contacts)",                                  {}, argtype = "table", info = "Define which source/drain contacts get drawn. Set 'drawsourcedrain' to 'both' to use this effectively. The argument to this parameter should be a table with numeric indices. The source/drain regions are enumerated with the left-most starting at 1." },
        { "sourcesize(Source Size)",                                                                    technology.get_dimension("Minimum Gate Width"), argtype = "integer", follow = "fingerwidth", info = "Size of the source contact regions. This parameter follows 'fingerwidth', so per default the contact regions have the width of a transistor finger. 'sourcesize' can be larger than 'fingerwidth'. If the size is smaller than 'fingerwidth', the source contact alignment ('sourcealign') is relevant." },
        { "sourceviasize(Source Via Size)",                                                             technology.get_dimension("Minimum Gate Width"), argtype = "integer", follow = "sourcesize", info = "Same as 'sourcesize', but for source vias." },
        { "drainsize(Drain Size)",                                                                      technology.get_dimension("Minimum Gate Width"), argtype = "integer", follow = "fingerwidth", info = "Size of the drain contact regions. This parameter follows 'fingerwidth', so per default the contact regions have the width of a transistor finger. 'drainsize' can be larger than 'fingerwidth'., If the size is smaller than 'fingerwidth', the drain contact alignment ('drainalign') is relevant." },
        { "drainviasize(Drain Via Size)",                                                               technology.get_dimension("Minimum Gate Width"), argtype = "integer", follow = "drainsize", info = "Same as 'drainsize', but for drain vias." },
        { "sourcealign(Source Alignment)",                                                              "bottom", posvals = set("top", "bottom", "center"), info = "Alignment of the source contacts. Only relevant if source contacts are smaller than 'fingerwidth' (see 'sourcesize'). Possible values: 'top' (source contacts grow down from the top into the active region) and 'bottom' (source contact grow up from the bottom into the active region). Typically, one sets 'sourcesize' and 'drainsize' to smaller values than 'fingerwidth' and uses opposite settings for 'sourcealign' and 'drainalign'." },
        { "sourceviaalign(Source Via Alignment)",                                                       "bottom", posvals = set("top", "bottom", "center"), follow = "sourcealign" },
        { "drainalign(Drain Alignment)",                                                                "top", posvals = set("top", "bottom", "center"), info = "Alignment of the drain contacts. Only relevant if drain contacts are smaller than 'fingerwidth' (see 'drainsize'). Possible values: 'top' (drain contacts grow down from the top into the active region) and 'bottom' (drain contact grow up from the bottom into the active region). Typically, one sets 'sourcesize' and 'drainsize' to smaller values than 'fingerwidth' and uses opposite settings for 'sourcealign' and 'drainalign'." },
        { "drainviaalign(Drain Via Alignment)",                                                         "top", posvals = set("top", "bottom", "center"), follow = "drainalign", info = "Same as 'drainalign' for drain vias." },
        { "drawsourcevia(Draw Source Via)",                                                             true, info = "Draw required vias from metal 1 to the source metal. Only useful if 'sourcemetal' is not 1." },
        { "drawfirstsourcevia(Draw First Source Via)",                                                  true, info = "Draw a via on the first source region (counted from the left). This switch can be useful if connecting dummies to other devices." },
        { "drawlastsourcevia(Draw Last Source Via)",                                                    true, info = "Draw a via on the last source region (counted from the left). This switch can be useful if connecting dummies to other devices." },
        { "connectsource(Connect Source)",                                                              false, info = "Connect all parallel source regions by a metal strap. This strap either lies outside or inside of the active region (see parameter 'connectsourceinline'). For nMOS devices, the outer source strap is below the active region, for pMOS devices the outer source strap is above the active region. This can be changed with 'connectsourceinverse')." },
        { "drawsourcestrap(Draw Source Strap)",                                                         false, follow = "connectsource", info = "Draw the source strap. This parameter follows 'connectsource', so per default the source strap is drawn. This parameter is useful if the source strap (or what it should connect to) is drawn by some other structures." },
        { "drawsourceconnections(Draw Source Connections)",                                             false, follow = "connectsource", info = "Draw the connections to the source strap. This parameter follows 'connectsource', so per default the connections between the source regions and the source strap are drawn. This parameter is rarely useful, only in situations where the source strap is not used but the source is connected." },
        { "connectsourceboth(Connect Source on Both Sides)",                                            false, info = "Connect the source on both sides of the active region. The \"other\" source strap is controlled by the connectsourceother* parameters, which all follow the main connectsource* parameters. This means that per default the \"other\" source strap mirrors the main one." },
        { "connectsourcewidth(Source Rails Metal Width)",                                               technology.get_dimension("Minimum M1 Width"), argtype = "integer", follow = "sdwidth" },
        { "connectsourcetopwidth(Source Rails Top Metal Width)",                                        technology.get_dimension("Minimum M1 Width"), argtype = "integer", follow = "connectsourcewidth", info = "width of the top metal of the source strap ('sourcestraptopmetal'), only used if it is higher than 'sourceendmetal'. If not given, it is the maximum of 'connectsourcewidth' and the minimum width of the top metal" },
        { "connectsourcewidths(Source Rails Metal Widths)",                                             {}, argtype = "table", info = "width of the source strap per metal (indexed by the metal number). Missing entries are taken from 'connectsourcewidth' and 'connectsourcetopwidth'" },
        { "connectsourcespace(Source Rails Metal Space)",                                               technology.get_dimension("Minimum M1 Width"), argtype = "integer" },
        { "connectsourceleftext(Source Rails Metal Left Extension)",                                    0 },
        { "connectsourcerightext(Source Rails Metal Right Extension)",                                  0 },
        { "connectsourceminwidth(Source Rails Minimum Width)",                                          0 },
        { "connectsourceautooddext(Source Rails Automatic Odd-Fingered Extension)",                     false },
        { "connectsourcefullwidth(Source Rails Full Width)",                                            false },
        { "connectsourceotherwidth(Other Source Rails Metal Width)",                                    technology.get_dimension("Minimum M1 Width"), argtype = "integer", follow = "connectsourcewidth" },
        { "connectsourceothertopwidth(Other Source Rails Top Metal Width)",                             technology.get_dimension("Minimum M1 Width"), argtype = "integer", follow = "connectsourcetopwidth" },
        { "connectsourceotherwidths(Other Source Rails Metal Widths)",                                  {}, argtype = "table", info = "like 'connectsourcewidths', for the other source strap. Missing entries are taken from 'connectsourceotherwidth' and 'connectsourceothertopwidth'" },
        { "connectsourceotherspace(Other Source Rails Metal Space)",                                    technology.get_dimension("Minimum M1 Width"), argtype = "integer", follow = "connectsourcespace" },
        { "connectsourceotherleftext(Other Source Rails Metal Left Extension)",                         0, follow = "connectsourceleftext", },
        { "connectsourceotherrightext(Other Source Rails Metal Right Extension)",                       0, follow = "connectsourcerightext", },
        { "connectsourceotherminwidth(Other Source Rails Minimum Width)",                               0, follow = "connectsourceminwidth" },
        { "connectsourceotherautooddext(Other Source Rails Automatic Odd-Fingered Extension)",          false },
        { "sourcemetal(Source Connection Metal)",                                                       1, info = "Highest metal of all source connections. In the default settings, vias are placed on the active source regions of the transistor, up to 'sourcemetal'. Additionally (if present), the source connection strap is drawn in this metal. This is a wrapper parameter, finer control can be achieved with 'sourcestartmetal' and 'sourceendmetal' (for the start/end of the via stack on the source strap), and 'sourceviametal' (which controls the highest metal on the active source regions." },
        { "sourcestartmetal(Source Connection First Metal)",                                            1, follow = "sourcemetal", info = "Lowest metal of the source strap placed beside (above/below) the transistor. A stack of vias is placed on the source strap (which starts on 'sourcestartmetal') and goes up to 'sourceendmetal'. The source strap metals are controlled with 'sourcestartmetal' and 'sourceendmetal'. All source metals can be easily controlled by 'sourcemetal'." },
        { "sourceendmetal(Source Connection Last Metal)",                                               1, follow = "sourcemetal", info = "Highest metal of the source strap placed beside (above/below) the transistor. A stack of vias is placed on the source strap (which starts on 'sourcestartmetal') and goes up to 'sourceendmetal'. The source strap metals are controlled with 'sourcestartmetal' and 'sourceendmetal'. All source metals can be easily controlled by 'sourcemetal'." },
        { "restrictsourcemetalstostrap",                                                                true },
        { "sourceviametal(Source Via Metal)",                                                           1, follow = "sourcestartmetal", info = "Highest metal of the source regions directly on the transistor. A stack of vias is placed on the metal-1-region of the source terminals, which goes up to the value of this parameter. The source strap metals are controlled with 'sourcestartmetal' and 'sourceendmetal'. All source metals can be easily controlled by 'sourcemetal'." },
        { "sourcestraptopmetal(Source Strap Top Metal)",                                                1, follow = "sourceendmetal" },
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
        { "connectdraintopwidth(Drain Rails Top Metal Width)",                                          technology.get_dimension("Minimum M1 Width"), argtype = "integer", follow = "connectdrainwidth", info = "width of the top metal of the drain strap ('drainstraptopmetal'), only used if it is higher than 'drainendmetal'. If not given, it is the maximum of 'connectdrainwidth' and the minimum width of the top metal" },
        { "connectdrainwidths(Drain Rails Metal Widths)",                                               {}, argtype = "table", info = "width of the drain strap per metal (indexed by the metal number). Missing entries are taken from 'connectdrainwidth' and 'connectdraintopwidth'" },
        { "connectdrainspace(Drain Rails Metal Space)",                                                 technology.get_dimension("Minimum M1 Width"), argtype = "integer" },
        { "connectdrainleftext(Drain Rails Metal Left Extension)",                                      0 },
        { "connectdrainrightext(Drain Rails Metal Right Extension)",                                    0 },
        { "connectdrainminwidth(Drain Rails Minimum Width)",                                            0 },
        { "connectdrainautooddext(Drain Rails Automatic Odd-Fingered Extension)",                       false },
        { "connectdrainfullwidth(Drain Rails Full Width)",                                              false },
        { "connectdraininverse(Invert Drain Strap Locations)",                                          false, follow = "flipsourcedrainstraps" },
        { "connectdrainotherwidth(Other Drain Rails Metal Width)",                                      technology.get_dimension("Minimum M1 Width"), argtype = "integer", follow = "connectdrainwidth" },
        { "connectdrainothertopwidth(Other Drain Rails Top Metal Width)",                               technology.get_dimension("Minimum M1 Width"), argtype = "integer", follow = "connectdraintopwidth" },
        { "connectdrainotherwidths(Other Drain Rails Metal Widths)",                                    {}, argtype = "table", info = "like 'connectdrainwidths', for the other drain strap. Missing entries are taken from 'connectdrainotherwidth' and 'connectdrainothertopwidth'" },
        { "connectdrainotherspace(Other Drain Rails Metal Space)",                                      technology.get_dimension("Minimum M1 Width"), argtype = "integer", follow = "connectdrainspace" },
        { "connectdrainotherleftext(Other Drain Rails Metal Left Extension)",                           0, follow = "connectdrainleftext" },
        { "connectdrainotherrightext(Other Drain Rails Metal Right Extension)",                         0, follow = "connectdrainrightext" },
        { "connectdrainotherminwidth(Other Drain Rails Minimum Width)",                                 0, follow = "connectdrainminwidth" },
        { "connectdrainotherautooddext(Other Drain Rails Automatic Odd-Fingered Extension)",            false },
        { "drawdrainvia(Draw Drain Via)",                                                               true },
        { "drawfirstdrainvia(Draw First Drain Via)",                                                    true },
        { "drawlastdrainvia(Draw Last Drain Via)",                                                      true },
        { "drainmetal(Drain Connection Metal)",                                                         1, info = "Highest metal of all drain connections. In the default settings, vias are placed on the active drain regions of the transistor, up to 'drainmetal'. Additionally (if present), the drain connection strap is drawn in this metal. This is a wrapper parameter, finer control can be achieved with 'drainstartmetal' and 'drainendmetal' (for the start/end of the via stack on the drain strap), and 'drainviametal' (which controls the highest metal on the active drain regions." },
        { "drainstartmetal(Drain Connection First Metal)",                                              1, follow = "drainmetal", info = "Lowest metal of the drain strap placed beside (above/below) the transistor. A stack of vias is placed on the drain strap (which starts on 'drainstartmetal') and goes up to 'drainendmetal'. The drain strap metals are controlled with 'drainstartmetal' and 'drainendmetal'. All drain metals can be easily controlled by 'drainmetal'." },
        { "drainendmetal(Drain Connection Last Metal)",                                                 1, follow = "drainmetal", info = "Highest metal of the drain strap placed beside (above/below) the transistor. A stack of vias is placed on the drain strap (which starts on 'sourcestartmetal') and goes up to 'sourceendmetal'. The source strap metals are controlled with 'sourcestartmetal' and 'sourceendmetal'. All source metals can be easily controlled by 'sourcemetal'." },
        { "restrictdrainmetalstostrap",                                                                 true },
        { "drainviametal(Drain Via Metal)",                                                             1, follow = "drainstartmetal", info = "Highest metal of the drain regions directly on the transistor. A stack of vias is placed on the metal-1-region of the drain terminals, which goes up to the value of this parameter. The drain strap metals are controlled with 'drainstartmetal' and 'drainendmetal'. All drain metals can be easily controlled by 'drainmetal'." },
        { "drainstraptopmetal(Drain Strap Top Metal)",                                                  1, follow = "drainendmetal" },
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
        { "drawactivedummies",                                                                          false },
        { "activedummywidth",                                                                           technology.get_optional_dimension("Minimum Active Width", 0) },
        { "activedummyspace",                                                                           technology.get_optional_dimension("Minimum Active Space", 0) },
        { "drawleftactivedummy",                                                                        false, follow = "drawactivedummies" },
        { "leftactivedummywidth",                                                                       technology.get_optional_dimension("Minimum Active Width", 0), follow = "activedummywidth" },
        { "leftactivedummyspace",                                                                       technology.get_optional_dimension("Minimum Active Space", 0), follow = "activedummyspace" },
        { "drawrightactivedummy",                                                                       false, follow = "drawactivedummies" },
        { "rightactivedummywidth",                                                                      technology.get_optional_dimension("Minimum Active Width", 0), follow = "activedummywidth" },
        { "rightactivedummyspace",                                                                      technology.get_optional_dimension("Minimum Active Space", 0), follow = "activedummyspace" },
        { "drawtopactivedummy",                                                                         false, follow = "drawactivedummies" },
        { "topactivedummywidth",                                                                        technology.get_optional_dimension("Minimum Active Width", 0), follow = "activedummywidth" },
        { "topactivedummyspace",                                                                        technology.get_optional_dimension("Minimum Active Space", 0), follow = "activedummyspace" },
        { "drawbottomactivedummy",                                                                      false, follow = "drawactivedummies" },
        { "bottomactivedummywidth",                                                                     technology.get_optional_dimension("Minimum Active Width", 0), follow = "activedummywidth" },
        { "bottomactivedummyspace",                                                                     technology.get_optional_dimension("Minimum Active Space", 0), follow = "activedummyspace" },
        { "leftfloatingdummies",                                                                        0 },
        { "rightfloatingdummies",                                                                       0 },
        { "floatingdummygatelength",                                                                    technology.get_dimension("Minimum Gate Length"), argtype = "integer", follow = "gatelength", info = "drawn floating dummy gate length (channel length)" },
        { "floatingdummygatespace",                                                                     technology.get_dimension("Minimum Gate XSpace", "Minimum Gate Space"), argtype = "integer", follow = "gatespace", info = "floating dummy gate space between the polysilicon lines" },
        { "drawactive",                                                                                 true },
        { "lvsmarker",                                                                                  1, info = "special marking layer to mark device features for LVS. Typically used for mosfets with 5 and 6 terminals (including well diodes). Per default this includes the guardring around the device, as this defines the geometry of the diodes. This can be changed with the parameter 'lvsmarkerincludeguardring'. This marker is always drawn, the parameter is a numeric value, starting at 1." },
        { "lvsmarkerincludeguardring",                                                                  true, info = "the lvs marker covers the guardring (outer boundary plus the lvs marker extensions), if a guardring is drawn. Without a guardring (or if this is false) the lvs marker covers the active region (see 'lvsmarkeralignwithactive')." },
        { "lvsmarkeralignwithactive",                                                                   false, info = "if the lvs marker covers the active region (no guardring or 'lvsmarkerincludeguardring' is false), align it with the active region in y. Otherwise it spans the gates in y." },
        { "extendall",                                                                                  0 },
        { "extendalltop",                                                                               0, follow = "extendall" },
        { "extendallbottom",                                                                            0, follow = "extendall" },
        { "extendallleft",                                                                              0, follow = "extendall" },
        { "extendallright",                                                                             0, follow = "extendall" },
        { "extendoxidetypetop",                                                                         technology.get_dimension("Minimum Oxide Extension"), follow = "extendalltop" },
        { "extendoxidetypebottom",                                                                      technology.get_dimension("Minimum Oxide Extension"), follow = "extendallbottom" },
        { "extendoxidetypeleft",                                                                        technology.get_dimension("Minimum Oxide Extension"), follow = "extendallleft" },
        { "extendoxidetyperight",                                                                       technology.get_dimension("Minimum Oxide Extension"), follow = "extendallright" },
        { "extendvthtypetop",                                                                           technology.get_optional_dimension("Minimum Vthtype Extension", 0), follow = "extendalltop" },
        { "extendvthtypebottom",                                                                        technology.get_optional_dimension("Minimum Vthtype Extension", 0), follow = "extendallbottom" },
        { "extendvthtypeleft",                                                                          technology.get_optional_dimension("Minimum Vthtype Extension", 0), follow = "extendallleft" },
        { "extendvthtyperight",                                                                         technology.get_optional_dimension("Minimum Vthtype Extension", 0), follow = "extendallright" },
        { "extendimplanttop",                                                                           technology.get_dimension("Minimum Implant Extension"), follow = "extendalltop" },
        { "extendimplantbottom",                                                                        technology.get_dimension("Minimum Implant Extension"), follow = "extendallbottom" },
        { "extendimplantleft",                                                                          technology.get_dimension("Minimum Implant Extension"), follow = "extendallleft" },
        { "extendimplantright",                                                                         technology.get_dimension("Minimum Implant Extension"), follow = "extendallright" },
        { "extendwelltop",                                                                              technology.get_dimension("Minimum Well Extension"), follow = "extendalltop" },
        { "extendwellbottom",                                                                           technology.get_dimension("Minimum Well Extension"), follow = "extendallbottom" },
        { "extendwellleft",                                                                             technology.get_dimension("Minimum Well Extension"), follow = "extendallleft" },
        { "extendwellright",                                                                            technology.get_dimension("Minimum Well Extension"), follow = "extendallright" },
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
        { "guardringrespectactivedummies",                                                              true },
        { "guardringrespectgatestraps",                                                                 true },
        { "guardringrespectgateextensions",                                                             true },
        { "guardringrespectsourcestraps",                                                               true },
        { "guardringrespectdrainstraps",                                                                true },
        { "guardringrespectpolylines",                                                                  true },
        { "guardringwidth",                                                                             technology.get_dimension("Minimum Active Contact Region Size") },
        { "guardringsep",                                                                               technology.get_dimension("Minimum Active Space") },
        { "guardringleftsep",                                                                           technology.get_dimension("Minimum Active Space"), follow = "guardringsep" },
        { "guardringrightsep",                                                                          technology.get_dimension("Minimum Active Space"), follow = "guardringsep" },
        { "guardringtopsep",                                                                            technology.get_dimension("Minimum Active Space"), follow = "guardringsep" },
        { "guardringbottomsep",                                                                         technology.get_dimension("Minimum Active Space"), follow = "guardringsep" },
        { "guardringsegments",                                                                          { "left", "right", "top", "bottom" } },
        { "guardringfillimplant",                                                                       false },
        { "guardringfillwell",                                                                          false, follow = "flippedwell" },
        { "guardringdrawoxidetype",                                                                     true },
        { "guardringfilloxidetype",                                                                     true },
        { "guardringoxidetype",                                                                         1, follow = "oxidetype" },
        { "guardringwellinnerextension",                                                                technology.get_dimension("Minimum Well Extension") },
        { "guardringwellouterextension",                                                                technology.get_dimension("Minimum Well Extension") },
        { "guardringimplantinnerextension",                                                             technology.get_dimension("Minimum Implant Extension") },
        { "guardringimplantouterextension",                                                             technology.get_dimension("Minimum Implant Extension") },
        { "guardringsoiopeninnerextension",                                                             technology.get_optional_dimension("Minimum Soiopen Extension", 0) },
        { "guardringsoiopenouterextension",                                                             technology.get_optional_dimension("Minimum Soiopen Extension", 0) },
        { "guardringoxidetypeinnerextension",                                                           technology.get_dimension("Minimum Oxide Extension") },
        { "guardringoxidetypeouterextension",                                                           technology.get_dimension("Minimum Oxide Extension") },
        { "connectguardringtosource",                                                                   false },
        { "guardringconnectionmethod",                                                                  "strap", posvals = set("strap", "individual") },
        { "guardring_enable_horizontal_net_strips",                                                     true },
        { "guardring_enable_vertical_net_strips",                                                       false },
        { "botwelltapwidth",                                                                            technology.get_dimension("Minimum M1 Width") },
        { "botwelltapspace",                                                                            technology.get_dimension("Minimum M1 Space") },
        { "botwelltapextendleft",                                                                       0 },
        { "botwelltapextendright",                                                                      0 },
        { "drawstopgatetopgatecut",                                                                     false },
        { "drawstopgatebotgatecut",                                                                     false },
        { "excludestopgatesfromcutregions",                                                             true },
        { "leftpolylines",                                                                              {}, info = "Specifies additional poly (gate not over active) lines left of the device. The table should containt entries like this: '{ length = 80, space = 120 }'." },
        { "rightpolylines",                                                                             {}, info = "Specifies additional poly (gate not over active) lines right of the device. The table should containt entries like this: '{ length = 80, space = 120 }'." },
        { "drawrotationmarker",                                                                         false },
        { "rotationmarkerincludeguardring",                                                             true, info = "the rotation marker covers the guardring (outer boundary plus the rotation marker extensions), if a guardring is drawn. Without a guardring (or if this is false) the rotation marker covers the active region (see 'rotationmarkeralignwithactive')." },
        { "rotationmarkeralignwithactive",                                                              false, info = "if the rotation marker covers the active region (no guardring or 'rotationmarkerincludeguardring' is false), align it with the active region in y. Otherwise it spans the gates in y." },
        { "drawanalogmarker",                                                                           false },
        { "analogmarkerincludeguardring",                                                               true, info = "the analog marker covers the guardring (outer boundary plus the analog marker extensions), if a guardring is drawn. Without a guardring (or if this is false) the analog marker covers the active region." },
        { "analogmarkeralignwithactive",                                                                true, info = "if the analog marker covers the active region (no guardring or 'analogmarkerincludeguardring' is false), align it with the active region in y. Otherwise it spans the gates in y (like the lvs marker with 'lvsmarkeralignwithactive' = false)." },
        -- FIXME: checkshorts should be true, but this needs better logic
        { "checkshorts",                                                                                false },
        { "strapextentmode",                                                                            "allmetals", posvals = set("allmetals", "samemetal"), info = "how other shapes (gate straps, guardring) account for source/drain straps with different widths per metal: 'allmetals' uses the widest strap metal, 'samemetal' only considers strap metals on the same metals as the shape in question" },
        { "gatenet",                                                                                    nil, info = "add net identification to gate straps" },
        { "sourcenet",                                                                                  nil, info = "add net identification to source straps" },
        { "drainnet",                                                                                   nil, info = "add net identification to drain straps" },
        { "bulknet",                                                                                    "", info = "add net identification to the bulk contacts (guardring/welltaps)" },
        { "netlabelsizehint",                                                                           technology.get_optional_dimension("Default Label Size", 0) },
        { "instancename",                                                                               nil, info = "draw an instance name in a non-physical text layer. This has no relevance for the device, it is merely a identification/debugging help for layouting." },
        { "instancenameincenter",                                                                       false, info = "put the instance name in the center of the active region, not on the lower left corner" },
        { "instancelabelsizehint",                                                                      technology.get_optional_dimension("Default Label Size", 0), info = "Label size hint for instance label." },
        { "drawinstancebox",                                                                            false },
        { "instancebox_includeguardring",                                                               true },
        { "grid",                                                                                       0, info = "put all access shapes (gate straps, source straps, guardring metals, etc.) on the specified grid. If this parameter is 0 it is ignored, otherwise the relevant shapes are shifted according to the grid. Therefore the given relevenat spacing (e.g. connectsourcespace) become minimal values, not exact values." },
        { "centershapegrid",                                                                            true, info = "use the center of the rectangular access shapes as grid targets, not the edges. This is useful if access shapes are conneted by paths whose center lines lie on the grid. This is the default bevavior." },
        { "shapegrid",                                                                                  0, info = "ensure that all shapes lie on the given grid (if greater than zero). This option modifies every parameter to achieve this. This option is different from 'grid', which concerns only the access shapes such as source straps. The 'shapegrid' option affects everything and is only intended for small values. The motivation is to ensure that (for instance) relevant shapes widths/heights can be divided by, say, 2." }
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
        "oxide",
        "region of the oxide type layer"
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

function check_pre(_P)
    if not technology.has_metal(_P.sourcestartmetal) then
        return false,
            string.format(
                "'sourcestartmetal' is %d, but the technology node does not have a metal %d",
                _P.sourcestartmetal,
                _P.sourcestartmetal
            )
    end
    if not technology.has_metal(_P.sourceendmetal) then
        return false,
            string.format(
                "'sourceendmetal' is %d, but the technology node does not have a metal %d",
                _P.sourceendmetal,
                _P.sourceendmetal
            )
    end
    if not technology.has_metal(_P.drainstartmetal) then
        return false,
            string.format(
                "'drainstartmetal' is %d, but the technology node does not have a metal %d",
                _P.drainstartmetal,
                _P.drainstartmetal
            )
    end
    if not technology.has_metal(_P.drainendmetal) then
        return false,
            string.format(
                "'drainendmetal' is %d, but the technology node does not have a metal %d",
                _P.drainendmetal,
                _P.drainendmetal
            )
    end
    if not technology.has_metal(_P.topgatemetal) then
        return false,
            string.format(
                "'topgatemetal' is %d, but the technology node does not have a metal %d",
                _P.topgatemetal,
                _P.topgatemetal
            )
    end
    if not technology.has_metal(_P.botgatemetal) then
        return false,
            string.format(
                "'botgatemetal' is %d, but the technology node does not have a metal %d",
                _P.botgatemetal,
                _P.botgatemetal
            )
    end
    return true
end

local function _get_metal_width(metal)
    local metalstr = string.format("Minimum M%d Width", metal)
        local viastr
    if metal > 1 then
        viastr = string.format("Minimum M%dM%d Viawidth", metal - 1, metal)
    end
    return technology.get_dimension_max(metalstr, viastr)
end

-- widths of all metals of a source/drain strap (indexed by metal)
-- entries of 'widthtable' take precedence, the top metal uses 'topwidth' (only if it is above the end metal)
local function _get_strap_widths(widthtable, startmetal, endmetal, topmetal, width, topwidth)
    local widths = {}
    for metal = startmetal, topmetal do
        if widthtable[metal] then
            widths[metal] = widthtable[metal]
        elseif metal == topmetal and topmetal > endmetal then
            widths[metal] = topwidth
        else
            widths[metal] = width
        end
    end
    return widths
end

-- y ranges of all metals of a source/drain strap
-- 'inner' is the strap edge that is kept fixed, the metals extend from there in 'direction' (-1: down, 1: up)
local function _get_strap_yranges(widths, inner, direction)
    local bottoms = {}
    local tops = {}
    for metal, width in pairs(widths) do
        if direction < 0 then
            bottoms[metal] = inner - width
            tops[metal] = inner
        else
            bottoms[metal] = inner
            tops[metal] = inner + width
        end
    end
    return bottoms, tops
end

-- x ranges of all metals of a source/drain strap (indexed by metal)
-- the strap spans from the first to the last connected source/drain region ('blx'/'trx', aligned with the
-- source/drain metal of the respective metal) plus the extensions; if this is shorter than 'minwidth', the strap
-- is extended equally on both sides (all metals of the strap then have the same x range)
local function _get_strap_xranges(metalwidths, startmetal, topmetal, gatespace, blx, trx, leftext, rightext, minwidth)
    local lefts = {}
    local rights = {}
    for metal = startmetal, topmetal do
        local shift = (gatespace + metalwidths[metal]) / 2
        local width = trx + rightext + metalwidths[metal] - blx + leftext
        local extraleftext = 0
        local extrarightext = 0
        if width < minwidth then
            extraleftext, extrarightext = util.ratio_split_multiple_of(minwidth - width, 1, 1)
        end
        lefts[metal] = blx - shift - leftext - extraleftext
        rights[metal] = trx - shift + rightext + extrarightext + metalwidths[metal]
    end
    return lefts, rights
end

-- x bounds of a source/drain strap: first and last connected source/drain region ('blx'/'trx', see
-- _get_strap_xranges) and the extensions of the main strap (including the automatic odd-fingered extension)
local function _get_sdstrap_xbounds(_P, kind, gateblx, gatepitch)
    local blx
    local trx
    local leftext
    local rightext
    if kind == "source" then
        leftext = _P.connectsourceleftext
        rightext = _P.connectsourcerightext
        if _P.connectsourceautooddext then
            rightext = rightext + gatepitch
        end
        if _P.connectsourcefullwidth then
            blx = gateblx
            trx = blx + _P.fingers * gatepitch
        else
            blx = gateblx
            trx = blx + 2 * (_P.fingers // 2) * gatepitch
        end
    else -- drain
        leftext = _P.connectdrainleftext
        rightext = _P.connectdrainrightext
        if _P.connectdrainautooddext then
            leftext = leftext + gatepitch
        end
        if _P.connectdrainfullwidth then
            blx = gateblx
            trx = blx + _P.fingers * gatepitch
        else
            blx = gateblx + (2 - 1) * gatepitch
            trx = blx + (2 * ((_P.fingers + 1) // 2) - 2) * gatepitch
        end
    end
    return blx, trx, leftext, rightext
end

-- x extent (leftmost/rightmost edge) of a source/drain strap as seen by a shape on the metals 'firstmetal' to
-- 'lastmetal' (modes as in _get_strap_extent), nil if no strap metal is considered
local function _get_strap_xextent(lefts, rights, mode, firstmetal, lastmetal)
    local left
    local right
    for metal, l in pairs(lefts) do
        if mode == "allmetals" or (metal >= firstmetal and metal <= lastmetal) then
            left = left and math.min(left, l) or l
            right = right and math.max(right, rights[metal]) or rights[metal]
        end
    end
    return left, right
end

-- x ranges of a gate strap: the metal strap (gate contacts plus extensions, extended equally on both sides if it
-- is shorter than 'minwidth') and the poly below it (only drawn with 'allow_poly_connections')
local function _get_gatestrap_xrange(_P, gateblx, gatetrx, gatepitch, leftext, rightext, minwidth, polyleftext, polyrightext)
    local contactext = (_P.minimum_gate_contact_size - _P.gatelength) / 2
    local contactleftext = math.max(leftext, contactext)
    local contactrightext = math.max(rightext, contactext)
    local width = gatetrx + (_P.fingers - 1) * gatepitch + contactrightext - gateblx + contactleftext
    local extraleftext = 0
    local extrarightext = 0
    if width < minwidth then
        extraleftext, extrarightext = util.ratio_split_multiple_of(minwidth - width, 1, 1)
    end
    local left = gateblx - contactleftext - extraleftext
    local right = gatetrx + (_P.fingers - 1) * gatepitch + contactrightext + extrarightext
    local polyleft = gateblx - extraleftext - math.max(polyleftext, contactext)
    local polyright = gatetrx + (_P.fingers - 1) * gatepitch + extrarightext + math.max(polyrightext, contactext)
    return left, right, polyleft, polyright
end

-- extent (maximum width) of a source/drain strap as seen by a shape on the metals 'firstmetal' to 'lastmetal'
-- (mode 'allmetals': all strap metals are considered, mode 'samemetal': only strap metals within this range)
local function _get_strap_extent(widths, mode, firstmetal, lastmetal)
    local extent = 0
    for metal, width in pairs(widths) do
        if mode == "allmetals" or (metal >= firstmetal and metal <= lastmetal) then
            extent = math.max(extent, width)
        end
    end
    return extent
end

-- gate/gate strap space extensions due to outer source/drain straps (if the gate metal is not below the via metal),
-- inline straps lie inside the active region and don't push the gate straps
local function _get_gate_sdstrap_spaces(_P, sourcestrapwidths, sourceotherstrapwidths, drainstrapwidths, drainotherstrapwidths, topgatemetal, botgatemetal)
    local topgatesdstrapspace = 0
    if _P.drawtopgate then
        if _P.channeltype == "nmos" then
            if _P.drawdrainconnections and not _P.connectdraininline and not _P.connectdraininverse then
                local space = _P.connectdrainspace + _get_strap_extent(drainstrapwidths, _P.strapextentmode, 1, topgatemetal)
                if _P.topgatemetal >= _P.drainviametal then
                    topgatesdstrapspace = math.max(topgatesdstrapspace, space)
                end
            end
            if _P.drawsourceconnections and not _P.connectsourceinline and _P.connectsourceinverse then
                local space = _P.connectsourcespace + _get_strap_extent(sourcestrapwidths, _P.strapextentmode, 1, topgatemetal)
                if _P.topgatemetal >= _P.sourceviametal then
                    topgatesdstrapspace = math.max(topgatesdstrapspace, space)
                end
            end
            if _P.drawsourceconnections and not _P.connectsourceinline and _P.connectsourceboth then
                local space = _P.connectsourceotherspace + _get_strap_extent(sourceotherstrapwidths, _P.strapextentmode, 1, topgatemetal)
                if _P.topgatemetal >= _P.sourceviametal then
                    topgatesdstrapspace = math.max(topgatesdstrapspace, space)
                end
            end
        else -- _P.channeltype == "pmos"
            if _P.drawsourceconnections and not _P.connectsourceinline and not _P.connectsourceinverse then
                local space = _P.connectsourcespace + _get_strap_extent(sourcestrapwidths, _P.strapextentmode, 1, topgatemetal)
                if _P.topgatemetal >= _P.sourceviametal then
                    topgatesdstrapspace = math.max(topgatesdstrapspace, space)
                end
            end
            if _P.drawdrainconnections and not _P.connectdraininline and _P.connectdraininverse then
                local space = _P.connectdrainspace + _get_strap_extent(drainstrapwidths, _P.strapextentmode, 1, topgatemetal)
                if _P.topgatemetal >= _P.drainviametal then
                    topgatesdstrapspace = math.max(topgatesdstrapspace, space)
                end
            end
            if _P.drawdrainconnections and not _P.connectdraininline and _P.connectdrainboth then
                local space = _P.connectdrainotherspace + _get_strap_extent(drainotherstrapwidths, _P.strapextentmode, 1, topgatemetal)
                if _P.topgatemetal >= _P.drainviametal then
                    topgatesdstrapspace = math.max(topgatesdstrapspace, space)
                end
            end
        end
    end
    local botgatesdstrapspace = 0
    if _P.drawbotgate then
        if _P.channeltype == "nmos" then
            if _P.drawsourceconnections and not _P.connectsourceinline and not _P.connectsourceinverse then
                if _P.botgatemetal >= _P.sourceviametal then
                    botgatesdstrapspace = _P.connectsourcespace + _get_strap_extent(sourcestrapwidths, _P.strapextentmode, 1, botgatemetal)
                end
            end
            if _P.drawdrainconnections and not _P.connectdraininline and _P.connectdraininverse then
                local space = _P.connectdrainspace + _get_strap_extent(drainstrapwidths, _P.strapextentmode, 1, botgatemetal)
                if _P.botgatemetal >= _P.drainviametal then
                    botgatesdstrapspace = math.max(botgatesdstrapspace, space)
                end
            end
            if _P.drawdrainconnections and not _P.connectdraininline and _P.connectdrainboth then
                local space = _P.connectdrainotherspace + _get_strap_extent(drainotherstrapwidths, _P.strapextentmode, 1, botgatemetal)
                if _P.botgatemetal >= _P.drainviametal then
                    botgatesdstrapspace = math.max(botgatesdstrapspace, space)
                end
            end
        else -- _P.channeltype == "pmos"
            if _P.drawdrainconnections and not _P.connectdraininline and not _P.connectdraininverse then
                if _P.botgatemetal >= _P.drainviametal then
                    botgatesdstrapspace = _P.connectdrainspace + _get_strap_extent(drainstrapwidths, _P.strapextentmode, 1, botgatemetal)
                end
            end
            if _P.drawsourceconnections and not _P.connectsourceinline and _P.connectsourceinverse then
                local space = _P.connectsourcespace + _get_strap_extent(sourcestrapwidths, _P.strapextentmode, 1, botgatemetal)
                if _P.botgatemetal >= _P.sourceviametal then
                    botgatesdstrapspace = math.max(botgatesdstrapspace, space)
                end
            end
            if _P.drawsourceconnections and not _P.connectsourceinline and _P.connectsourceboth then
                local space = _P.connectsourceotherspace + _get_strap_extent(sourceotherstrapwidths, _P.strapextentmode, 1, botgatemetal)
                if _P.botgatemetal >= _P.sourceviametal then
                    botgatesdstrapspace = math.max(botgatesdstrapspace, space)
                end
            end
        end
    end
    return topgatesdstrapspace, botgatesdstrapspace
end

-- present source/drain contacts (drawn terminal and not excluded), ascending region indices
-- note: the 'sourcedrain%d' anchors exist for all regions of a drawn terminal, also for excluded ones
local function _get_sdcontacts(_P)
    local sdcontacts = { source = {}, drain = {}, all = {} }
    for i = 1, _P.fingers + 1 do
        local kind = (i % 2 == 1) and "source" or "drain"
        if (_P.drawsourcedrain == "both" or _P.drawsourcedrain == kind) and not util.any_of(i, _P.excludesourcedraincontacts) then
            sdcontacts[kind][#sdcontacts[kind] + 1] = i
            sdcontacts.all[#sdcontacts.all + 1] = i
        end
    end
    return sdcontacts
end

function process_parameters(_P, explicit)
    if not explicit.connectsourcewidth then
        _P.connectsourcewidth = technology.get_dimension(string.format("Minimum M%d Width", _P.sourceendmetal))
    end
    if not explicit.connectsourcespace then
        _P.connectsourcespace = technology.get_dimension(string.format("Minimum M%d Space", _P.sourceendmetal))
    end
    if not explicit.connectdrainwidth then
        _P.connectdrainwidth = technology.get_dimension(string.format("Minimum M%d Width", _P.drainendmetal))
    end
    if not explicit.connectdrainspace then
        _P.connectdrainspace = technology.get_dimension(string.format("Minimum M%d Space", _P.drainendmetal))
    end
    if not explicit.connectsourcewidth and _P.sdmetalwidths[_P.sourceendmetal] then
        _P.connectsourcewidth = _P.sdmetalwidths[_P.sourceendmetal]
    end
    if not explicit.connectdrainwidth and _P.sdmetalwidths[_P.drainendmetal] then
        _P.connectdrainwidth = _P.sdmetalwidths[_P.drainendmetal]
    end
    -- other straps: follow the computed values of the main straps (results of process_parameters() are not propagated to followers)
    if not explicit.connectsourceotherwidth then
        _P.connectsourceotherwidth = _P.connectsourcewidth
    end
    if not explicit.connectsourceotherspace then
        _P.connectsourceotherspace = _P.connectsourcespace
    end
    if not explicit.connectdrainotherwidth then
        _P.connectdrainotherwidth = _P.connectdrainwidth
    end
    if not explicit.connectdrainotherspace then
        _P.connectdrainotherspace = _P.connectdrainspace
    end
    -- top metals of the straps: at least as wide as the strap, but also respect the metal width
    if not explicit.connectsourcetopwidth then
        _P.connectsourcetopwidth = math.max(_P.connectsourcewidth, _get_metal_width(_P.sourcestraptopmetal))
    end
    if not explicit.connectsourceothertopwidth then
        _P.connectsourceothertopwidth = math.max(_P.connectsourceotherwidth, _get_metal_width(_P.sourcestraptopmetal))
    end
    if not explicit.connectdraintopwidth then
        _P.connectdraintopwidth = math.max(_P.connectdrainwidth, _get_metal_width(_P.drainstraptopmetal))
    end
    if not explicit.connectdrainothertopwidth then
        _P.connectdrainothertopwidth = math.max(_P.connectdrainotherwidth, _get_metal_width(_P.drainstraptopmetal))
    end
    -- FIXME: also include drainviametal, take maximum distance
    if not explicit.topgatewidth then
        _P.topgatewidth = math.max(technology.get_dimension("Minimum M1 Width"), _get_metal_width(_P.topgatemetal))
    end
    if not explicit.topgatespace and _P.topgatemetal < _P.sourceviametal then
        _P.topgatespace = technology.get_dimension(string.format("Minimum M%d Space", _P.topgatemetal))
    end
    if not explicit.botgatewidth then
        _P.botgatewidth = math.max(technology.get_dimension("Minimum M1 Width"), _get_metal_width(_P.botgatemetal))
    end
    if not explicit.botgatespace and _P.botgatemetal < _P.sourceviametal then
        _P.botgatespace = technology.get_dimension(string.format("Minimum M%d Space", _P.botgatemetal))
    end
end

-- runs after process_parameters(), changes also explicit parameters:
-- with 'grid' > 0 the given spacings are minimum values, the strap/gate spaces are increased to put the access shapes on the grid,
-- with 'shapegrid' > 0 all relevant parameters are put on the shape grid (after the grid adjustment)
function process_parameters_override(_P, explicit)
    -- modify spacings to put access shapes on grid
    if _P.grid > 0 then
        if _P.centershapegrid then
            -- strap centers (y, relative to the bottom edge of the active region), inline straps lie inside the active region
            local function _strap_is_bottom(kind)
                local inverse
                if kind == "source" then
                    inverse = _P.connectsourceinverse
                else
                    inverse = _P.connectdraininverse
                end
                return ((_P.channeltype == "nmos") == (kind == "source")) ~= inverse
            end
            local function _strap_center(kind)
                local width = _P[string.format("connect%swidth", kind)]
                if _P[string.format("connect%sinline", kind)] then
                    local offset = _P[string.format("connect%sinlineoffset", kind)]
                    if _strap_is_bottom(kind) then
                        return offset + width / 2
                    else
                        return _P.fingerwidth - offset - width / 2
                    end
                else
                    local space = _P[string.format("connect%sspace", kind)]
                    if _strap_is_bottom(kind) then
                        return -space - width / 2
                    else
                        return _P.fingerwidth + space + width / 2
                    end
                end
            end
            if _P.drawsourcestrap and _P.drawdrainstrap then
                if not _P.connectsourceinline and not _P.connectdraininline then
                    -- distances of the strap centers to the active region (each on its own side)
                    local sourcecenter = _P.connectsourcespace + _P.connectsourcewidth / 2
                    local draincenter = _P.connectdrainspace + _P.connectdrainwidth / 2
                    if _P.connectsourceinverse ~= _P.connectdraininverse then
                        -- source and drain on the same side: only the outer strap is moved (outwards)
                        local centercenterspace = math.abs(sourcecenter - draincenter)
                        local additional_space = util.fix_to_grid_abs_higher(centercenterspace, _P.grid) - centercenterspace
                        if sourcecenter > draincenter then
                            _P.connectsourcespace = _P.connectsourcespace + additional_space
                        else
                            _P.connectdrainspace = _P.connectdrainspace + additional_space
                        end
                    else
                        -- source and drain on different sides
                        local centercenterspace = sourcecenter + _P.fingerwidth + draincenter
                        local additional_space = util.fix_to_grid_abs_higher(centercenterspace, _P.grid) - centercenterspace
                        local s1, s2 = util.ratio_split_multiple_of(additional_space, 1, 1)
                        _P.connectsourcespace = _P.connectsourcespace + s1
                        _P.connectdrainspace = _P.connectdrainspace + s2
                    end
                elseif _P.connectsourceinline and _P.connectdraininline then
                    -- both straps inline: move them apart (balanced), but never out of the active region
                    local sourcecenter = _strap_center("source")
                    local draincenter = _strap_center("drain")
                    local centercenterspace = math.abs(sourcecenter - draincenter)
                    local additional_space = util.fix_to_grid_abs_higher(centercenterspace, _P.grid) - centercenterspace
                    local lower, upper = "source", "drain"
                    if draincenter < sourcecenter then
                        lower, upper = "drain", "source"
                    end
                    local moves = {}
                    moves.source = additional_space // 2
                    moves.drain = additional_space - moves.source
                    -- room to the active edges (the lower strap moves down, the upper strap moves up)
                    local lowerroom = _strap_center(lower) - _P[string.format("connect%swidth", lower)] / 2
                    local upperroom = _P.fingerwidth - _strap_center(upper) - _P[string.format("connect%swidth", upper)] / 2
                    if moves[lower] > lowerroom then
                        moves[upper] = moves[upper] + moves[lower] - lowerroom
                        moves[lower] = lowerroom
                    end
                    if moves[upper] > upperroom then
                        moves[lower] = moves[lower] + moves[upper] - upperroom
                        moves[upper] = upperroom
                    end
                    -- if there is not enough room the straps are moved anyway, this is reported by check()
                    -- the offsets are measured from the edge of the strap side (bottom or top)
                    for _, entry in ipairs({ { kind = lower, direction = -1 }, { kind = upper, direction = 1 } }) do
                        local name = string.format("connect%sinlineoffset", entry.kind)
                        if _strap_is_bottom(entry.kind) then
                            _P[name] = _P[name] + entry.direction * moves[entry.kind]
                        else
                            _P[name] = _P[name] - entry.direction * moves[entry.kind]
                        end
                    end
                else
                    -- one inline strap: the inline strap stays, the outer strap is moved (outwards)
                    local inline, outer = "source", "drain"
                    if _P.connectdraininline then
                        inline, outer = "drain", "source"
                    end
                    local centercenterspace = math.abs(_strap_center(inline) - _strap_center(outer))
                    local additional_space = util.fix_to_grid_abs_higher(centercenterspace, _P.grid) - centercenterspace
                    local name = string.format("connect%sspace", outer)
                    _P[name] = _P[name] + additional_space
                end
            else
                -- FIXME: this probably does not make any sense, as the grid-based only works if all access shapes are available
                --        perhaps this should be enforced through parameter checks
                _P.connectsourcespace = util.fix_to_grid_abs_higher(_P.connectsourcespace + _P.connectsourcewidth / 2, _P.grid) - _P.connectsourcewidth / 2
                _P.connectdrainspace = util.fix_to_grid_abs_higher(_P.connectdrainspace + _P.connectdrainwidth / 2, _P.grid) - _P.connectdrainwidth / 2
            end
            -- gate straps: on grid relative to the nearest source/drain strap (after the straps have been moved)
            if _P.drawtopgate or _P.drawbotgate then
                local sourcestrapwidths = _get_strap_widths(_P.connectsourcewidths, _P.sourcestartmetal, _P.sourceendmetal, _P.sourcestraptopmetal, _P.connectsourcewidth, _P.connectsourcetopwidth)
                local sourceotherstrapwidths = _get_strap_widths(_P.connectsourceotherwidths, _P.sourcestartmetal, _P.sourceendmetal, _P.sourcestraptopmetal, _P.connectsourceotherwidth, _P.connectsourceothertopwidth)
                local drainstrapwidths = _get_strap_widths(_P.connectdrainwidths, _P.drainstartmetal, _P.drainendmetal, _P.drainstraptopmetal, _P.connectdrainwidth, _P.connectdraintopwidth)
                local drainotherstrapwidths = _get_strap_widths(_P.connectdrainotherwidths, _P.drainstartmetal, _P.drainendmetal, _P.drainstraptopmetal, _P.connectdrainotherwidth, _P.connectdrainothertopwidth)
                local topgatesdstrapspace, botgatesdstrapspace = _get_gate_sdstrap_spaces(_P,
                    sourcestrapwidths, sourceotherstrapwidths, drainstrapwidths, drainotherstrapwidths,
                    technology.resolve_metal(_P.topgatemetal), technology.resolve_metal(_P.botgatemetal)
                )
                local lowestcenter, highestcenter
                for _, kind in ipairs({ "source", "drain" }) do
                    if _P[string.format("draw%sstrap", kind)] then
                        local center = _strap_center(kind)
                        lowestcenter = lowestcenter and math.min(lowestcenter, center) or center
                        highestcenter = highestcenter and math.max(highestcenter, center) or center
                    end
                end
                if lowestcenter then
                    if _P.drawtopgate then
                        local gatecenter = _P.fingerwidth + _P.topgatespace + enable(_P.topgateadjustforsdstraps, topgatesdstrapspace) + _P.topgatewidth / 2
                        local centercenterspace = gatecenter - highestcenter
                        _P.topgatespace = _P.topgatespace + util.fix_to_grid_higher(centercenterspace, _P.grid) - centercenterspace
                    end
                    if _P.drawbotgate then
                        local gatecenter = -_P.botgatespace - enable(_P.botgateadjustforsdstraps, botgatesdstrapspace) - _P.botgatewidth / 2
                        local centercenterspace = lowestcenter - gatecenter
                        _P.botgatespace = _P.botgatespace + util.fix_to_grid_higher(centercenterspace, _P.grid) - centercenterspace
                    end
                end
            end
        else
            -- only adjust spacing, edge alignment to grid is enforced via parameter checks
            _P.connectsourcespace = util.fix_to_grid_abs_higher(_P.connectsourcespace, _P.grid)
            _P.connectdrainspace = util.fix_to_grid_abs_higher(_P.connectdrainspace, _P.grid)
            _P.topgatespace = util.fix_to_grid_abs_higher(_P.topgatespace, _P.grid)
            _P.botgatespace = util.fix_to_grid_abs_higher(_P.botgatespace, _P.grid)
        end
    end
    -- check all parameters against the 'shapegrid'
    local fixlist = {
        "fingerwidth",
        "gatelength",
        "gatespace",
        "minimum_gate_contact_size",
        "topgatepolyleftrightextension",
        "topgatepolyleftextension",
        "topgatepolyrightextension",
        "topgatepolytopbottomextension",
        "topgatepolytopextension",
        "topgatepolybottomextension",
        "botgatepolyleftrightextension",
        "botgatepolyleftextension",
        "botgatepolyrightextension",
        "botgatepolytopbottomextension",
        "botgatepolytopextension",
        "botgatepolybottomextension",
        "actext",
        "sdwidth",
        "sdmetalwidth",
        "sdm1botext",
        "sdm1topext",
        "sdmxbotext",
        "sdmxtopext",
        "minviaxspace",
        "minviayspace",
        "gtopext",
        "gbotext",
        "gtopextadd",
        "gbotextadd",
        "gatetopabsoluteheight",
        "gatebotabsoluteheight",
        "leftendgatelength",
        "leftendgatespace",
        "rightendgatelength",
        "rightendgatespace",
        "topgatewidth",
        "topgateleftextension",
        "topgaterightextension",
        "topgatespace",
        "botgatewidth",
        "botgateleftextension",
        "botgaterightextension",
        "botgatespace",
        "topgatecutheight",
        "topgatecutspace",
        "topgatecutleftext",
        "topgatecutrightext",
        "botgatecutheight",
        "botgatecutspace",
        "botgatecutleftext",
        "botgatecutrightext",
        "sourcesize",
        "sourceviasize",
        "drainsize",
        "drainviasize",
        "connectsourcewidth",
        "connectsourcespace",
        "connectsourceleftext",
        "connectsourcerightext",
        "connectsourceotherwidth",
        "connectsourceotherspace",
        "connectsourceotherleftext",
        "connectsourceotherrightext",
        "connectsourceinlineoffset",
        "connectdrainwidth",
        "connectdrainspace",
        "connectdrainleftext",
        "connectdrainrightext",
        "connectdrainotherwidth",
        "connectdrainotherspace",
        "connectdrainotherleftext",
        "connectdrainotherrightext",
        "connectdraininlineoffset",
        "extrabotstrapwidth",
        "extrabotstrapspace",
        "extrabotstrapleftextension",
        "extrabotstraprightextension",
        "extratopstrapwidth",
        "extratopstrapspace",
        "extratopstrapleftextension",
        "extratopstraprightextension",
        "shortspace",
        "shortwidth",
        "activedummywidth",
        "activedummyspace",
        "leftactivedummywidth",
        "leftactivedummyspace",
        "rightactivedummywidth",
        "rightactivedummyspace",
        "topactivedummywidth",
        "topactivedummyspace",
        "bottomactivedummywidth",
        "bottomactivedummyspace",
        "extendall",
        "extendalltop",
        "extendallbottom",
        "extendallleft",
        "extendallright",
        "extendoxidetypetop",
        "extendoxidetypebottom",
        "extendoxidetypeleft",
        "extendoxidetyperight",
        "extendvthtypetop",
        "extendvthtypebottom",
        "extendvthtypeleft",
        "extendvthtyperight",
        "extendimplanttop",
        "extendimplantbottom",
        "extendimplantleft",
        "extendimplantright",
        "extendwelltop",
        "extendwellbottom",
        "extendwellleft",
        "extendwellright",
        "extendlvsmarkertop",
        "extendlvsmarkerbottom",
        "extendlvsmarkerleft",
        "extendlvsmarkerright",
        "extendrotationmarkertop",
        "extendrotationmarkerbottom",
        "extendrotationmarkerleft",
        "extendrotationmarkerright",
        "extendanalogmarkertop",
        "extendanalogmarkerbottom",
        "extendanalogmarkerleft",
        "extendanalogmarkerright",
        "topwelltapwidth",
        "topwelltapspace",
        "topwelltapextendleft",
        "topwelltapextendright",
        "guardringwidth",
        "guardringsep",
        "guardringleftsep",
        "guardringrightsep",
        "guardringtopsep",
        "guardringbottomsep",
        "guardringwellinnerextension",
        "guardringwellouterextension",
        "guardringimplantinnerextension",
        "guardringimplantouterextension",
        "guardringsoiopeninnerextension",
        "guardringsoiopenouterextension",
        "guardringoxidetypeinnerextension",
        "guardringoxidetypeouterextension",
        "botwelltapwidth",
        "botwelltapspace",
        "botwelltapextendleft",
        "botwelltapextendright",
    }
    if _P.shapegrid > 0 then
        for _, k in ipairs(fixlist) do
            _P[k] = util.fix_to_grid_abs_higher(_P[k], _P.shapegrid)
        end
    end
end

function check(_P)
    -- a guardring that fills its oxidetype replaces the device oxidetype, so it has to be the same
    if _P.drawguardring and _P.guardringdrawoxidetype and _P.guardringfilloxidetype and _P.guardringoxidetype ~= _P.oxidetype then
        return false, string.format("if the guardring fills its oxidetype ('guardringfilloxidetype'), 'guardringoxidetype' (%d) must be equal to 'oxidetype' (%d)", _P.guardringoxidetype, _P.oxidetype)
    end
    -- other straps only exist for outer straps
    if _P.connectsourceboth and _P.connectsourceinline then
        return false, "'connectsourceboth' can not be used together with 'connectsourceinline' (the other source strap is only drawn for outer source straps)"
    end
    if _P.connectdrainboth and _P.connectdraininline then
        return false, "'connectdrainboth' can not be used together with 'connectdraininline' (the other drain strap is only drawn for outer drain straps)"
    end
    -- stop gates are placed on the end gates
    if _P.drawleftstopgate and not _P.endleftwithgate then
        return false, "'drawleftstopgate' requires 'endleftwithgate' (the left stop gate is drawn on the left end gate)"
    end
    if _P.drawrightstopgate and not _P.endrightwithgate then
        return false, "'drawrightstopgate' requires 'endrightwithgate' (the right stop gate is drawn on the right end gate)"
    end
    if (_P.gatespace % 2) ~= (_P.sdwidth % 2) then
        return false, string.format("gatespace and sdwidth must both be even or odd (%d vs. %d)", _P.gatespace, _P.sdwidth)
    end
    if (_P.sdmetalwidth % 2) ~= (_P.sdwidth % 2) then
        return false, string.format("sdmetalwidth and sdwidth must both be even or odd (%d vs. %d)", _P.sdmetalwidth, _P.sdwidth)
    end
    if _P.sdmetalwidth < _P.sdwidth then
        return false, string.format("sdmetalwidth must not be smaller than sdwidth (%d vs. %d)", _P.sdmetalwidth, _P.sdwidth)
    end
    if _P.sourcesize < 0 then
        return false, string.format("sourcesize (%d) can not be negative", _P.sourcesize)
    end
    if _P.drainsize < 0 then
        return false, string.format("drainsize (%d) can not be negative", _P.drainsize)
    end
    if _P.sourceviasize < 0 or _P.sourceviasize > _P.sourcesize then
        return false, string.format("sourceviasize (%d) can not be negative or larger than 'sourcesize' (%d)", _P.sourceviasize, _P.sourcesize)
    end
    if _P.drainviasize < 0 or _P.drainviasize > _P.drainsize then
        return false, string.format("drainviasize (%d) can not be negative or larger than 'drainsize' (%d)", _P.drainviasize, _P.drainsize)
    end
    if _P.sourceendmetal < _P.sourcestartmetal then
        return false, string.format("the source end metal must be larger than or equal to the source start metal, got %d and %d", _P.sourceendmetal, _P.sourcestartmetal)
    end
    if _P.sourcestraptopmetal < _P.sourceendmetal then
        return false, string.format("the source strap top metal must be larger than or equal to the source end metal, got %d and %d", _P.sourcestraptopmetal, _P.sourceendmetal)
    end
    if _P.drainendmetal < _P.drainstartmetal then
        return false, string.format("the drain end metal must be larger than or equal to the drain start metal, got %d and %d", _P.drainendmetal, _P.drainstartmetal)
    end
    if _P.drainstraptopmetal < _P.drainendmetal then
        return false, string.format("the drain strap top metal must be larger than or equal to the drain end metal, got %d and %d", _P.drainstraptopmetal, _P.drainendmetal)
    end
    -- FIXME: the short check is incomplete and partly wrong (MOSFET_REVIEW.md 2.5), it should be replaced:
    --   current problems:
    --     - compares 'sourcemetal == topgatemetal' only, ignoring the side of the strap (false alarm for a source strap
    --       below the device and a top gate strap), the metal ranges and 'topgateadjustforsdstraps'
    --     - the bottom gate strap is not checked, the drain branch is empty, other straps are missing
    --   a correct check, for every gate strap (top/bottom) against every source/drain strap on the same side:
    --     - gate straps: top/bottom gate strap, occupying metal 1 to 'topgatemetal'/'botgatemetal' (vias to the
    --       gate contacts), y range: fingerwidth + topgatespace (+ push from _get_gate_sdstrap_spaces() if
    --       'topgateadjustforsdstraps') + topgatewidth, mirrored for the bottom gate
    --     - source/drain straps: main straps (connectsource/connectdrain, side from channeltype and
    --       connect*inverse), other straps (connect*both, on the opposite side), occupying '*startmetal' to
    --       '*straptopmetal', y range: connect*space / connect*otherspace + strap extent (_get_strap_extent() with
    --       the per-metal width tables); inline straps lie inside the active region and are not relevant
    --     - shorts only if the metal ranges overlap and the y ranges overlap
    --     - intended connections are excluded: shortsourcegate (source - gate), shortdraingate (drain - gate),
    --       diodeconnected (drain - gate, source - gate with diodeconnectedreversed)
    --   not covered yet (separate cases): source/drain connections (vertical metals from the regions to the straps)
    --   crossing a gate strap that lies between the active region and the strap, extra top/bottom straps
    --   (extratopstrap/extrabotstrap), guardring connections:
    --     - 'individual' (metal 1 bars from the guardring to the source regions, on the side of the main source strap):
    --       gate straps and drain straps on metal 1 on that side are an error already (independent of 'checkshorts',
    --       see the guardring checks below); still missing: shortdevice with shortlocation 'top'/'bottom' (harmless,
    --       source and drain are shorted anyway), extra straps (extratopstrap/extrabotstrap) on metal 1
    --       (shortsourcegate/shortdraingate only draw on the gate strap side, which is an error already)
    --     - 'strap' (bar on 'sourcestraptopmetal' from the source strap to the guardring, via stack 1 to
    --       'sourcestraptopmetal' on the guardring): crosses everything between the source strap and the guardring on
    --       these metals, e.g. a gate strap pushed outwards ('*gateadjustforsdstraps') or the other drain strap
    --   once the check is correct, 'checkshorts' should default to true (FIXME at the parameter definition)
    if _P.checkshorts then
        if _P.drawtopgate then
            if _P.sourcemetal == _P.topgatemetal then
                local sourcestrapwidths = _get_strap_widths(_P.connectsourcewidths, _P.sourcestartmetal, _P.sourceendmetal, _P.sourcestraptopmetal, _P.connectsourcewidth, _P.connectsourcetopwidth)
                local sourcestrapextent = _get_strap_extent(sourcestrapwidths, _P.strapextentmode, 1, technology.resolve_metal(_P.topgatemetal))
                if _P.topgatespace <= sourcestrapextent + _P.connectsourcespace then
                    return false, string.format("if source and gate metals are equal the straps must be apart from each other to avoid shorts (topgatespace: %d > source strap width: %d + connectsourcespace: %d", _P.topgatespace, sourcestrapextent, _P.connectsourcespace)
                end
            end
            if _P.drainmetal == _P.topgatemetal then
            end
        end
    end
    if _P.shortdevice and ((_P.sourcesize % 2) ~= (_P.sdwidth % 2)) then
        return false, string.format("sourcesize and sdwidth must both be even or odd if shortdevice is true (%d vs. %d)", _P.sourcesize, _P.sdwidth)
    end
    if not (not _P.endleftwithgate or (_P.gatelength % 2 == 0)) then
        return false, string.format("gatelength must be even if endleftwithgate is true (gatelength: %d)", _P.gatelength)
    end
    if not (not _P.endrightwithgate or (_P.gatelength % 2 == 0)) then
        return false, string.format("gatelength must be even if endrightwithgate is true (gatelength: %d)", _P.gatelength)
    end
    if _P.leftendgatelength % 2 ~= 0 then
        return false, string.format("leftendgatelength must be even (%d)", _P.leftendgatelength)
    end
    if _P.rightendgatelength % 2 ~= 0 then
        return false, string.format("rightendgatelength must be even (%d)", _P.rightendgatelength)
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
        return false, "if shortsourcegate is true, drawtopgate and drawtopgatestrap or drawbotgate and drawbotgatestrap also have to be true"
    end
    -- two inline straps on grid: process_parameters_override() moves them apart, but only within the active region
    if _P.grid > 0 and _P.centershapegrid and _P.drawsourcestrap and _P.drawdrainstrap and
        _P.connectsourceinline and _P.connectdraininline then
        local sourcebly, drainbly
        if (_P.channeltype == "nmos") ~= _P.connectsourceinverse then
            sourcebly = _P.connectsourceinlineoffset
        else
            sourcebly = _P.fingerwidth - _P.connectsourcewidth - _P.connectsourceinlineoffset
        end
        if (_P.channeltype == "nmos") ~= _P.connectdraininverse then
            drainbly = _P.fingerwidth - _P.connectdrainwidth - _P.connectdraininlineoffset
        else
            drainbly = _P.connectdraininlineoffset
        end
        local centercenterspace = math.abs((sourcebly + _P.connectsourcewidth / 2) - (drainbly + _P.connectdrainwidth / 2))
        if centercenterspace % _P.grid ~= 0 or
            sourcebly < 0 or sourcebly + _P.connectsourcewidth > _P.fingerwidth or
            drainbly < 0 or drainbly + _P.connectdrainwidth > _P.fingerwidth then
            return false, string.format("the inline source and drain straps can not be put on the grid (%d) within the active region (fingerwidth: %d, connectsourcewidth: %d, connectdrainwidth: %d): the center distance of the straps must be a multiple of the grid, the straps can only be moved apart up to the edges of the active region", _P.grid, _P.fingerwidth, _P.connectsourcewidth, _P.connectdrainwidth)
        end
    end
    -- source and drain straps on the same side (exactly one of them inverted) need separate metals
    if _P.drawsourcestrap and _P.drawdrainstrap and not _P.connectsourceinline and not _P.connectdraininline and
        (_P.connectsourceinverse ~= _P.connectdraininverse) then
        if not (_P.sourcestartmetal > _P.drainstraptopmetal or _P.drainstartmetal > _P.sourcestraptopmetal) then
            return false, string.format("source and drain straps are on the same side of the device (only one of 'connectsourceinverse' (%s) and 'connectdraininverse' (%s) is set), therefore they need different metals: the first metal of one strap must be higher than the last metal of the other strap (source strap: metals %d to %d, drain strap: metals %d to %d)", _P.connectsourceinverse, _P.connectdraininverse, _P.sourcestartmetal, _P.sourcestraptopmetal, _P.drainstartmetal, _P.drainstraptopmetal)
        end
    end
    -- per-metal width tables must only define metals that are present
    local sdmetalmax = 0
    for _, kind in ipairs({ "source", "drain" }) do
        local metalmax = _P[kind .. "viametal"]
        if not _P["restrict" .. kind .. "metalstostrap"] then
            metalmax = math.max(metalmax, _P[kind .. "endmetal"])
        end
        sdmetalmax = math.max(sdmetalmax, metalmax)
    end
    for metal in pairs(_P.sdmetalwidths) do
        if math.type(metal) ~= "integer" or metal < 1 or metal > sdmetalmax then
            return false, string.format("'sdmetalwidths' defines a width for metal %s, but source/drain metals are only present on metals 1 to %d ('sourceviametal'/'drainviametal', or the strap metals if 'restrictsourcemetalstostrap'/'restrictdrainmetalstostrap' is false). Strap metals are set with 'connectsourcewidths'/'connectdrainwidths'", metal, sdmetalmax)
        end
    end
    for _, kind in ipairs({ "source", "drain" }) do
        for _, other in ipairs({ "", "other" }) do
            local tablename = string.format("connect%s%swidths", kind, other)
            local startmetal = _P[kind .. "startmetal"]
            local topmetal = _P[kind .. "straptopmetal"]
            for metal in pairs(_P[tablename]) do
                if other == "other" and not _P[string.format("connect%sboth", kind)] then
                    return false, string.format("'%s' is set, but there is no other %s strap ('connect%sboth' is false)", tablename, kind, kind)
                end
                if math.type(metal) ~= "integer" or metal < startmetal or metal > topmetal then
                    return false, string.format("'%s' defines a width for metal %s, but the %s strap only uses metals %d ('%sstartmetal') to %d ('%sstraptopmetal')", tablename, metal, kind, startmetal, kind, topmetal, kind)
                end
            end
        end
    end
    if _P.connectguardringtosource then
        if _P.guardringconnectionmethod == "strap" then
            if _P.connectsourceinline then
                return false, "'connectguardringtosource' (with method == 'strap') can not be used with 'inline' source strap connections."
            end
        else -- "individual"
            -- the individual connections are metal 1 bars from the guardring to the source regions on the side of the
            -- (main) source strap, a gate strap (always on metal 1) or a drain strap on metal 1 on this side is shorted
            -- (other shapes are not checked, see the FIXME for the short check)
            local connectionsbottom = (_P.channeltype == "nmos") ~= _P.connectsourceinverse
            local side = connectionsbottom and "bottom" or "top"
            local gatestrap
            if connectionsbottom then
                gatestrap = _P.drawbotgatestrap
            else
                gatestrap = _P.drawtopgatestrap
            end
            if _P.fingers > 0 and gatestrap then
                return false, string.format(
                    "'connectguardringtosource' (with method == 'individual') connects the source regions on the %s side with metal 1, which is shorted by the %s gate strap. Use method 'strap' or place the gate strap on the other side.",
                    side, side
                )
            end
            if _P.fingers > 0 and _P.drawdrainstrap and not _P.connectdraininline and _P.drainstartmetal == 1 then
                local drainbottom = (_P.channeltype == "nmos") == _P.connectdraininverse
                if drainbottom == connectionsbottom or _P.connectdrainboth then
                    return false, string.format(
                        "'connectguardringtosource' (with method == 'individual') connects the source regions on the %s side with metal 1, which is shorted by the drain strap on this side (drain strap starts on metal 1). Use method 'strap', place the drain strap on the other side or start it on a higher metal ('drainstartmetal').",
                        side
                    )
                end
            end
        end
    end
    if _P.grid > 0 then
        if not _P.centershapegrid then
            if _P.connectsource and not util.is_on_grid(_P.connectsourcewidth, _P.grid) then
                return false, string.format(
                    "if access shape edges are put on grid (_P.centershapegrid == false), the source strap width must be a multiple of the grid: %d (connectsourcewidth) - %d (grid)",
                    _P.connectsourcewidth, _P.grid
                )
            end
            if _P.connectdrain and not util.is_on_grid(_P.connectdrainwidth, _P.grid) then
                return false, string.format(
                    "if access shape edges are put on grid (_P.centershapegrid == false), the drain strap width must be a multiple of the grid: %d (connectdrainwidth) - %d (grid)",
                    _P.connectdrainwidth, _P.grid
                )
            end
            if _P.drawtopgate and not util.is_on_grid(_P.topgatewidth, _P.grid) then
                return false, string.format(
                    "if access shape edges are put on grid (_P.centershapegrid == false), the topgate strap width must be a multiple of the grid: %d (topgatewidth) - %d (grid)",
                    _P.topgatewidth, _P.grid
                )
            end
            if _P.drawbotgate and not util.is_on_grid(_P.botgatewidth, _P.grid) then
                return false, string.format(
                    "if access shape edges are put on grid (_P.centershapegrid == false), the botgate strap width must be a multiple of the grid: %d (botgatewidth) - %d (grid)",
                    _P.botgatewidth, _P.grid
                )
            end
        end
    end
    return true
end

function layout(transistor, _P)
    local gatepitch = _P.gatelength + _P.gatespace
    local sdcontacts = _get_sdcontacts(_P)

    -- per-metal widths of the source/drain straps
    local sourcestrapwidths = _get_strap_widths(_P.connectsourcewidths, _P.sourcestartmetal, _P.sourceendmetal, _P.sourcestraptopmetal, _P.connectsourcewidth, _P.connectsourcetopwidth)
    local sourceotherstrapwidths = _get_strap_widths(_P.connectsourceotherwidths, _P.sourcestartmetal, _P.sourceendmetal, _P.sourcestraptopmetal, _P.connectsourceotherwidth, _P.connectsourceothertopwidth)
    local drainstrapwidths = _get_strap_widths(_P.connectdrainwidths, _P.drainstartmetal, _P.drainendmetal, _P.drainstraptopmetal, _P.connectdrainwidth, _P.connectdraintopwidth)
    local drainotherstrapwidths = _get_strap_widths(_P.connectdrainotherwidths, _P.drainstartmetal, _P.drainendmetal, _P.drainstraptopmetal, _P.connectdrainotherwidth, _P.connectdrainothertopwidth)
    -- the gate straps occupy metal 1 to the gate strap metal
    local topgatemetal = technology.resolve_metal(_P.topgatemetal)
    local botgatemetal = technology.resolve_metal(_P.botgatemetal)

    -- calculate gate/gate strap space extensions due to source/drain straps
    local topgatesdstrapspace, botgatesdstrapspace = _get_gate_sdstrap_spaces(_P, sourcestrapwidths, sourceotherstrapwidths, drainstrapwidths, drainotherstrapwidths, topgatemetal, botgatemetal)

    local topgatespace = _P.topgatespace + enable(_P.topgateadjustforsdstraps, topgatesdstrapspace)
    local botgatespace = _P.botgatespace + enable(_P.botgateadjustforsdstraps, botgatesdstrapspace)

    local topgateshift = enable(_P.drawtopgate, topgatespace + _P.topgatewidth)
    local botgateshift = enable(_P.drawbotgate, botgatespace + _P.botgatewidth)
    local gateaddtop = math.max(_P.gtopext, topgateshift) + _P.gtopextadd
    local gateaddbottom = math.max(_P.gbotext, botgateshift) + _P.gbotextadd
    if _P.gatetopabsoluteheight > 0 then
        gateaddtop = _P.gatetopabsoluteheight
    end
    if _P.gatebotabsoluteheight > 0 then
        gateaddbottom = _P.gatebotabsoluteheight
    end

    local hasgatecut = not _P.simulatemissinggatecut and technology.has_feature("has_gatecut")

    -- active
    local activewidth = _P.fingers * _P.gatelength + (_P.fingers - 1) * _P.gatespace
    if _P.leftfloatingdummies > 0 then
        activewidth = activewidth + _P.leftfloatingdummies * (_P.floatingdummygatelength + _P.floatingdummygatespace)
    end
    if _P.rightfloatingdummies > 0 then
        activewidth = activewidth + _P.rightfloatingdummies * (_P.floatingdummygatelength + _P.floatingdummygatespace)
    end
    local leftactext
    if _P.endleftwithgate then
        leftactext = _P.leftendgatespace + _P.leftendgatelength / 2
    else
        leftactext = (_P.gatespace + _P.sdwidth) / 2 + _P.actext
    end
    local rightactext
    if _P.endrightwithgate then
        rightactext = _P.rightendgatespace + _P.rightendgatelength / 2
    else
        rightactext = (_P.gatespace + _P.sdwidth) / 2 + _P.actext
    end
    local activeshift = -_P.leftfloatingdummies * (_P.floatingdummygatelength + _P.floatingdummygatespace)

    local activebl = point.create(-leftactext + activeshift, 0)
    local activetr = point.create(activewidth + rightactext + activeshift, _P.fingerwidth)
    if _P.drawactive then
        transistor:add_area_anchor_bltr("active", activebl, activetr)
        geometry.rectangleareaanchor(transistor, generics.active(), "active")
        transistor:add_anchor_line_y("activetop", _P.fingerwidth)
        transistor:add_anchor_line_y("activebottom", 0)
        if _P.drawleftactivedummy then
            transistor:add_area_anchor_bltr("leftactivedummy",
                point.create(activebl:getx() - _P.leftactivedummyspace - _P.leftactivedummywidth, activebl:gety()),
                point.create(activebl:getx() - _P.leftactivedummyspace, activetr:gety())
            )
            geometry.rectangleareaanchor(transistor, generics.active(), "leftactivedummy")
        end
        if _P.drawrightactivedummy then
            transistor:add_area_anchor_bltr("rightactivedummy",
                point.create(activetr:getx() + _P.rightactivedummyspace, activebl:gety()),
                point.create(activetr:getx() + _P.rightactivedummyspace + _P.rightactivedummywidth, activetr:gety())
            )
            geometry.rectangleareaanchor(transistor, generics.active(), "rightactivedummy")
        end
        if _P.drawtopactivedummy then
            transistor:add_area_anchor_bltr("topactivedummy",
                point.create(activebl:getx(), activetr:gety() + _P.topactivedummyspace),
                point.create(activetr:getx(), activetr:gety() + _P.topactivedummyspace + _P.topactivedummywidth)
            )
            geometry.rectangleareaanchor(transistor, generics.active(), "topactivedummy")
        end
        if _P.drawbottomactivedummy then
            transistor:add_area_anchor_bltr("bottomactivedummy",
                point.create(activebl:getx(), activebl:gety() - _P.bottomactivedummyspace - _P.bottomactivedummywidth),
                point.create(activetr:getx(), activebl:gety() - _P.bottomactivedummyspace)
            )
            geometry.rectangleareaanchor(transistor, generics.active(), "bottomactivedummy")
        end
    end

    -- gates
    -- base coordinates of a gate
    -- needed throughout the cell by various drawings
    local gateblx = 0
    local gatebly = -gateaddbottom
    local gatetrx = gateblx + _P.gatelength
    local gatetry = _P.fingerwidth + gateaddtop

    if hasgatecut then
        -- gate cut
        if _P.fingers > 0 and _P.drawtopgatecut then
            geometry.rectanglebltr(transistor,
                generics.feol("gatecut"),
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
                generics.feol("gatecut"),
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
        -- (simulated) missing gate cuts: the gates end at the cuts (but are never extended)
        if _P.drawtopgatecut then
            gatetry = math.min(gatetry, _P.fingerwidth + _P.topgatecutspace)
        end
        if _P.drawbotgatecut then
            gatebly = math.max(gatebly, -_P.botgatecutspace)
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
    transistor:add_area_anchor_bltr("gateboundingbox",
        point.create(gateblx, gatebly),
        point.create(gatetrx + (_P.fingers - 1) * gatepitch, gatetry)
    )
    transistor:add_anchor_line_y("gatetop", gatetry)
    transistor:add_anchor_line_y("gatebottom", gatebly)
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
            generics.marker("gate", _P.gatemarker),
            point.create(gateblx + (i - 1) * gatepitch, gatebly),
            point.create(gatetrx + (i - 1) * gatepitch, gatetry)
        )
    end

    -- left/right gates
    if _P.endleftwithgate then
        local lgatebly = gatebly
        local lgatetry = gatetry
        if _P.drawstopgatetopgatecut and not hasgatecut then
            lgatetry = math.min(lgatetry, _P.fingerwidth + _P.topgatecutspace)
        end
        if _P.drawstopgatebotgatecut and not hasgatecut then
            lgatebly = math.max(lgatebly, -_P.botgatecutspace)
        end
        transistor:add_area_anchor_bltr(
            "endleftgate",
            point.create(gateblx - _P.leftfloatingdummies * (_P.floatingdummygatelength + _P.floatingdummygatespace) - _P.leftendgatelength - _P.leftendgatespace, lgatebly),
            point.create(gatetrx - _P.leftfloatingdummies * (_P.floatingdummygatelength + _P.floatingdummygatespace) - _P.gatelength - _P.leftendgatespace, lgatetry)
        )
        geometry.rectanglebltr(transistor,
            generics.gate(),
            transistor:get_area_anchor("endleftgate").bl,
            transistor:get_area_anchor("endleftgate").tr
        )
    end
    if _P.endrightwithgate then
        local lgatebly = gatebly
        local lgatetry = gatetry
        if _P.drawstopgatetopgatecut and not hasgatecut then
            lgatetry = math.min(lgatetry, _P.fingerwidth + _P.topgatecutspace)
        end
        if _P.drawstopgatebotgatecut and not hasgatecut then
            lgatebly = math.max(lgatebly, -_P.botgatecutspace)
        end
        transistor:add_area_anchor_bltr(
            "endrightgate",
            point.create(gateblx + _P.rightfloatingdummies * (_P.floatingdummygatelength + _P.floatingdummygatespace) - _P.gatespace + _P.rightendgatespace + _P.fingers * gatepitch, lgatebly),
            point.create(gatetrx + _P.rightfloatingdummies * (_P.floatingdummygatelength + _P.floatingdummygatespace) - _P.gatespace + _P.rightendgatespace - _P.gatelength + _P.rightendgatelength + _P.fingers * gatepitch, lgatetry)
        )
        geometry.rectanglebltr(transistor,
            generics.gate(),
            transistor:get_area_anchor("endrightgate").bl,
            transistor:get_area_anchor("endrightgate").tr
        )
    end

    -- mosfet marker
    if _P.fingers > 0 then
        if _P.mosfetmarkeralignatsourcedrain then
            geometry.rectanglebltr(transistor,
                generics.marker("mosfet", _P.mosfetmarker),
                activebl,
                activetr
            )
        else
            if _P.mosfetmarkerincludefloatingdummies then
                geometry.rectanglebltr(transistor,
                    generics.marker("mosfet", _P.mosfetmarker),
                    point.create(gateblx - _P.leftfloatingdummies * (_P.floatingdummygatelength + _P.floatingdummygatespace), activebl:gety()),
                    point.create(gateblx + _P.fingers * gatepitch + _P.rightfloatingdummies * (_P.floatingdummygatelength + _P.floatingdummygatespace) - _P.gatespace, activetr:gety())
                )
            else
                geometry.rectanglebltr(transistor,
                    generics.marker("mosfet", _P.mosfetmarker),
                    point.create(gateblx, activebl:gety()),
                    point.create(gateblx + _P.fingers * gatepitch - _P.gatespace, activetr:gety())
                )
            end
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
                generics.feol("diffusionbreakgate"),
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
                generics.feol("diffusionbreakgate"),
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
        if hasgatecut and _P.drawstopgatetopgatecut then
            geometry.rectanglebltr(transistor,
                generics.feol("gatecut"),
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
        if hasgatecut and _P.drawstopgatebotgatecut then
            geometry.rectanglebltr(transistor,
                generics.feol("gatecut"),
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
        local diffusionbreakbly = transistor:get_area_anchor("endleftgate").b
        local diffusionbreaktry = transistor:get_area_anchor("endleftgate").t
        if _P.excludestopgatesfromcutregions then
            -- the diffusion break ends at the gate cuts (real or simulated)
            if _P.drawstopgatetopgatecut then
                diffusionbreaktry = math.min(diffusionbreaktry, _P.fingerwidth + _P.topgatecutspace)
            end
            if _P.drawstopgatebotgatecut then
                diffusionbreakbly = math.max(diffusionbreakbly, -_P.botgatecutspace)
            end
        end
        geometry.rectanglebltr(transistor,
            generics.feol("diffusionbreakgate"),
            point.create(transistor:get_area_anchor("endleftgate").l, diffusionbreakbly),
            point.create(transistor:get_area_anchor("endleftgate").r, diffusionbreaktry)
        )
        transistor:add_area_anchor_bltr("leftstopgate",
            transistor:get_area_anchor("endleftgate").bl,
            transistor:get_area_anchor("endleftgate").tr
        )
    end

    if _P.drawrightstopgate then
        if hasgatecut and _P.drawstopgatetopgatecut then
            geometry.rectanglebltr(transistor,
                generics.feol("gatecut"),
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
        if hasgatecut and _P.drawstopgatebotgatecut then
            geometry.rectanglebltr(transistor,
                generics.feol("gatecut"),
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
        local diffusionbreakbly = transistor:get_area_anchor("endrightgate").b
        local diffusionbreaktry = transistor:get_area_anchor("endrightgate").t
        if _P.excludestopgatesfromcutregions then
            -- the diffusion break ends at the gate cuts (real or simulated)
            if _P.drawstopgatetopgatecut then
                diffusionbreaktry = math.min(diffusionbreaktry, _P.fingerwidth + _P.topgatecutspace)
            end
            if _P.drawstopgatebotgatecut then
                diffusionbreakbly = math.max(diffusionbreakbly, -_P.botgatecutspace)
            end
        end
        geometry.rectanglebltr(transistor,
            generics.feol("diffusionbreakgate"),
            point.create(transistor:get_area_anchor("endrightgate").l, diffusionbreakbly),
            point.create(transistor:get_area_anchor("endrightgate").r, diffusionbreaktry)
        )
        transistor:add_area_anchor_bltr("rightstopgate",
            transistor:get_area_anchor("endrightgate").bl,
            transistor:get_area_anchor("endrightgate").tr
        )
    end

    -- floating dummy gates
    for i = 1, _P.leftfloatingdummies do
        local blx = gateblx - i * (_P.floatingdummygatelength + _P.floatingdummygatespace)
        local bly = gatebly
        local trx = blx + _P.floatingdummygatelength
        local try = gatetry
        geometry.rectanglebltr(transistor,
            generics.gate(),
            point.create(blx, bly),
            point.create(trx, try)
        )
        geometry.rectanglebltr(transistor,
            generics.marker("floatinggate"),
            point.create(blx, bly),
            point.create(trx, try)
        )
    end
    for i = 1, _P.rightfloatingdummies do
        local blx = gateblx + _P.fingers * gatepitch - _P.gatespace + i * (_P.floatingdummygatelength + _P.floatingdummygatespace) - _P.floatingdummygatelength
        local bly = gatebly
        local trx = blx + _P.floatingdummygatelength
        local try = gatetry
        geometry.rectanglebltr(transistor,
            generics.gate(),
            point.create(blx, bly),
            point.create(trx, try)
        )
        geometry.rectanglebltr(transistor,
            generics.marker("floatinggate"),
            point.create(blx, bly),
            point.create(trx, try)
        )
    end

    -- alignment target for well, implants, threshold voltage modificators etc.
    local leftgatealign = math.min(
        gateblx
            - _P.leftfloatingdummies * (_P.floatingdummygatelength + _P.floatingdummygatespace)
            - enable(_P.endleftwithgate, _P.leftendgatelength + _P.leftendgatespace),
        activebl:getx()
    )
    local rightgatealign = math.max(
        gatetrx
            + (_P.fingers - 1) * gatepitch
            + _P.rightfloatingdummies * (_P.floatingdummygatelength + _P.floatingdummygatespace)
            + enable(_P.endrightwithgate, _P.rightendgatelength + _P.rightendgatespace),
        activetr:getx()
    )

    -- threshold voltage
    geometry.rectanglebltr(transistor,
        generics.vthtype(_P.channeltype, _P.vthtype),
        point.create(
            _P.vthtypealignleftwithactive and
                activebl:getx() - _P.extendvthtypeleft or
                leftgatealign - _P.extendvthtypeleft,
            _P.vthtypealignbottomwithactive and
                activebl:gety() - _P.extendvthtypebottom or
                gatebly - _P.extendvthtypebottom
        ),
        point.create(
            _P.vthtypealignrightwithactive and
                activetr:getx() + _P.extendvthtyperight or
                rightgatealign + _P.extendvthtyperight,
            _P.vthtypealigntopwithactive and
                activetr:gety() + _P.extendvthtypetop or
                gatetry + _P.extendvthtypetop
        )
    )

    -- implant
    local implantbl = point.create(
        _P.implantalignleftwithactive and
            activebl:getx() - _P.extendimplantleft or
            leftgatealign - _P.extendimplantleft,
        _P.implantalignbottomwithactive and
            activebl:gety() - _P.extendimplantbottom or
            gatebly - _P.extendimplantbottom
    )
    local implanttr = point.create(
        _P.implantalignrightwithactive and
            activetr:getx() + _P.extendimplantright or
            rightgatealign + _P.extendimplantright,
        _P.implantaligntopwithactive and
            activetr:gety() + _P.extendimplanttop or
            gatetry + _P.extendimplanttop
    )
    if _P.implantrespectpolylines then
        local leftskip = 0
        for _, entry in ipairs(_P.leftpolylines) do
            leftskip = leftskip + entry.space + entry.length
        end
        local rightskip = 0
        for _, entry in ipairs(_P.rightpolylines) do
            rightskip = rightskip + entry.space + entry.length
        end
        implantbl:translate_x(-leftskip)
        implanttr:translate_x(rightskip)
    end
    if _P.drawimplant and not _P.drawguardring then -- if a guardring is present, it draws the inner/MOSFET implant
        geometry.rectanglebltr(transistor, generics.implant(_P.channeltype), implantbl, implanttr)
    end
    transistor:add_area_anchor_bltr("implant", implantbl, implanttr)

    -- oxide thickness
    local oxidebl = point.create(
        _P.oxidetypealignleftwithactive and
            activebl:getx() - _P.extendoxidetypeleft or
            leftgatealign - _P.extendoxidetypeleft,
        _P.oxidetypealignbottomwithactive and
            activebl:gety() - _P.extendoxidetypebottom or
            gatebly - _P.extendoxidetypebottom
    )
    local oxidetr = point.create(
        _P.oxidetypealignrightwithactive and
            activetr:getx() + _P.extendoxidetyperight or
            rightgatealign + _P.extendoxidetyperight,
        _P.oxidetypealigntopwithactive and
            activetr:gety() + _P.extendoxidetypetop or
            gatetry + _P.extendoxidetypetop
    )
    -- if a guardring fills its oxidetype (always the same as the device oxidetype, see check()), it draws the inner/MOSFET oxidetype
    if _P.drawoxidetype and not (_P.drawguardring and _P.guardringdrawoxidetype and _P.guardringfilloxidetype) then
        geometry.rectanglebltr(transistor, generics.oxide(_P.oxidetype), oxidebl, oxidetr)
    end
    transistor:add_area_anchor_bltr("oxide", oxidebl, oxidetr)

    -- prepare metal width table
    local sourcemetalwidths = {}
    local sourcemetalshifts = {}
    local drainmetalwidths = {}
    local drainmetalshifts = {}
    for i = 1, _P.sourcestraptopmetal do
        if i > _P.sourceendmetal and i > _P.sourceviametal then
            -- strap-only metals (no source metals on the device) are aligned with the strap end metal
            sourcemetalwidths[i] = sourcemetalwidths[_P.sourceendmetal]
        else
            sourcemetalwidths[i] = _P.sdmetalwidths[i] or _P.sdmetalwidth
        end
        sourcemetalshifts[i] = (sourcemetalwidths[i] - _P.sdwidth) / 2
    end
    for i = 1, _P.drainstraptopmetal do
        if i > _P.drainendmetal and i > _P.drainviametal then
            -- strap-only metals (no drain metals on the device) are aligned with the strap end metal
            drainmetalwidths[i] = drainmetalwidths[_P.drainendmetal]
        else
            drainmetalwidths[i] = _P.sdmetalwidths[i] or _P.sdmetalwidth
        end
        drainmetalshifts[i] = (drainmetalwidths[i] - _P.sdwidth) / 2
    end

    -- guardring extensions (space between the active region and the guardring hole, without the separations),
    -- calculated here as they are also used by the analog and lvs markers
    local guardringleftext_activedummy = 0
    local guardringrightext_activedummy = 0
    local guardringtopext_activedummy = 0
    local guardringbotext_activedummy = 0
    local guardringtopext_gateextensions = 0
    local guardringbotext_gateextensions = 0
    local guardringleftext_gatestraps = 0
    local guardringrightext_gatestraps = 0
    local guardringtopext_gatestraps = 0
    local guardringbotext_gatestraps = 0
    local guardringleftext_sourcestraps = 0
    local guardringrightext_sourcestraps = 0
    local guardringtopext_sourcestraps = 0
    local guardringbotext_sourcestraps = 0
    local guardringleftext_drainstraps = 0
    local guardringrightext_drainstraps = 0
    local guardringtopext_drainstraps = 0
    local guardringbotext_drainstraps = 0
    if _P.guardringrespectactivedummies then
        if _P.drawtopactivedummy then
            guardringtopext_activedummy = _P.topactivedummywidth + _P.topactivedummyspace
        end
        if _P.drawbottomactivedummy then
            guardringbotext_activedummy = _P.bottomactivedummywidth + _P.bottomactivedummyspace
        end
        if _P.drawleftactivedummy then
            guardringleftext_activedummy = _P.leftactivedummywidth + _P.leftactivedummyspace
        end
        if _P.drawrightactivedummy then
            guardringrightext_activedummy = _P.rightactivedummywidth + _P.rightactivedummyspace
        end
    end
    if _P.guardringrespectgateextensions then
        guardringtopext_gateextensions = gatetry - _P.fingerwidth
        guardringbotext_gateextensions = -gatebly
    end
    if _P.guardringrespectgatestraps then
        if _P.drawtopgatestrap then
            guardringtopext_gatestraps = topgatespace + _P.topgatewidth + _P.topgatepolytopextension
        end
        if _P.drawbotgatestrap then
            guardringbotext_gatestraps = botgatespace + _P.botgatewidth + _P.botgatepolybottomextension
        end
        -- the x ranges of the gate straps (metal and, with poly connections, the poly below the strap)
        local gatestrapranges = {}
        if _P.fingers > 0 and _P.drawtopgatestrap then
            local left, right, polyleft, polyright = _get_gatestrap_xrange(_P, gateblx, gatetrx, gatepitch,
                _P.topgateleftextension, _P.topgaterightextension, _P.topgateminwidth,
                _P.topgatepolyleftextension, _P.topgatepolyrightextension
            )
            gatestrapranges[#gatestrapranges + 1] = { left, right }
            if _P.allow_poly_connections then
                gatestrapranges[#gatestrapranges + 1] = { polyleft, polyright }
            end
        end
        if _P.fingers > 0 and _P.drawbotgatestrap then
            local left, right, polyleft, polyright = _get_gatestrap_xrange(_P, gateblx, gatetrx, gatepitch,
                _P.botgateleftextension, _P.botgaterightextension, _P.botgateminwidth,
                _P.botgatepolyleftextension, _P.botgatepolyrightextension
            )
            gatestrapranges[#gatestrapranges + 1] = { left, right }
            if _P.allow_poly_connections then
                gatestrapranges[#gatestrapranges + 1] = { polyleft, polyright }
            end
        end
        for _, range in ipairs(gatestrapranges) do
            guardringleftext_gatestraps = math.max(guardringleftext_gatestraps, activebl:getx() - range[1])
            guardringrightext_gatestraps = math.max(guardringrightext_gatestraps, range[2] - activetr:getx())
        end
    end
    local guardringtopmetal = 1 -- the guardring metals (auxiliary/guardring is only drawn with metal 1)
    if _P.guardringrespectsourcestraps then
        if _P.drawsourceconnections and not _P.connectsourceinline then
            if _P.channeltype == "nmos" then
                if _P.connectsourceinverse then
                    if _P.connectsourceboth then
                        guardringbotext_sourcestraps = _P.connectsourceotherspace + _get_strap_extent(sourceotherstrapwidths, _P.strapextentmode, 1, guardringtopmetal)
                    end
                    guardringtopext_sourcestraps = _P.connectsourcespace + _get_strap_extent(sourcestrapwidths, _P.strapextentmode, 1, guardringtopmetal)
                else -- not _P.connectsourceinverse
                    guardringbotext_sourcestraps = _P.connectsourcespace + _get_strap_extent(sourcestrapwidths, _P.strapextentmode, 1, guardringtopmetal)
                    if _P.connectsourceboth then
                        guardringtopext_sourcestraps = _P.connectsourceotherspace + _get_strap_extent(sourceotherstrapwidths, _P.strapextentmode, 1, guardringtopmetal)
                    end
                end
            else -- _P.channeltype == "pmos"
                if _P.connectsourceinverse then
                    guardringbotext_sourcestraps = _P.connectsourcespace + _get_strap_extent(sourcestrapwidths, _P.strapextentmode, 1, guardringtopmetal)
                    if _P.connectsourceboth then
                        guardringtopext_sourcestraps = _P.connectsourceotherspace + _get_strap_extent(sourceotherstrapwidths, _P.strapextentmode, 1, guardringtopmetal)
                    end
                else -- not _P.connectsourceinverse
                    if _P.connectsourceboth then
                        guardringbotext_sourcestraps = _P.connectsourceotherspace + _get_strap_extent(sourceotherstrapwidths, _P.strapextentmode, 1, guardringtopmetal)
                    end
                    guardringtopext_sourcestraps = _P.connectsourcespace + _get_strap_extent(sourcestrapwidths, _P.strapextentmode, 1, guardringtopmetal)
                end
            end
        end
        -- x extent of the main and the other strap (all strap metals or only the guardring metals, see 'strapextentmode')
        if _P.fingers > 0 and _P.drawsourcestrap then
            local blx, trx, leftext, rightext = _get_sdstrap_xbounds(_P, "source", gateblx, gatepitch)
            local straplefts, straprights = _get_strap_xranges(sourcemetalwidths, _P.sourcestartmetal, _P.sourcestraptopmetal, _P.gatespace, blx, trx, leftext, rightext, _P.connectsourceminwidth)
            local left, right = _get_strap_xextent(straplefts, straprights, _P.strapextentmode, 1, guardringtopmetal)
            if left then
                guardringleftext_sourcestraps = math.max(0, activebl:getx() - left)
                guardringrightext_sourcestraps = math.max(0, right - activetr:getx())
            end
            if _P.connectsourceboth and not _P.connectsourceinline then
                straplefts, straprights = _get_strap_xranges(sourcemetalwidths, _P.sourcestartmetal, _P.sourcestraptopmetal, _P.gatespace, blx, trx, _P.connectsourceotherleftext, _P.connectsourceotherrightext, _P.connectsourceotherminwidth)
                left, right = _get_strap_xextent(straplefts, straprights, _P.strapextentmode, 1, guardringtopmetal)
                if left then
                    guardringleftext_sourcestraps = math.max(guardringleftext_sourcestraps, activebl:getx() - left)
                    guardringrightext_sourcestraps = math.max(guardringrightext_sourcestraps, right - activetr:getx())
                end
            end
        end
    end
    if _P.guardringrespectdrainstraps then
        if _P.drawdrainconnections and not _P.connectdraininline then
            if _P.channeltype == "nmos" then
                if _P.connectdraininverse then
                    if _P.connectdrainboth then
                        guardringtopext_drainstraps = _P.connectdrainotherspace + _get_strap_extent(drainotherstrapwidths, _P.strapextentmode, 1, guardringtopmetal)
                    end
                    guardringbotext_drainstraps = _P.connectdrainspace + _get_strap_extent(drainstrapwidths, _P.strapextentmode, 1, guardringtopmetal)
                else -- not _P.connectdraininverse
                    guardringtopext_drainstraps = _P.connectdrainspace + _get_strap_extent(drainstrapwidths, _P.strapextentmode, 1, guardringtopmetal)
                    if _P.connectdrainboth then
                        guardringbotext_drainstraps = _P.connectdrainotherspace + _get_strap_extent(drainotherstrapwidths, _P.strapextentmode, 1, guardringtopmetal)
                    end
                end
            else -- _P.channeltype == "pmos"
                if _P.connectdraininverse then
                    guardringtopext_drainstraps = _P.connectdrainspace + _get_strap_extent(drainstrapwidths, _P.strapextentmode, 1, guardringtopmetal)
                    if _P.connectdrainboth then
                        guardringbotext_drainstraps = _P.connectdrainotherspace + _get_strap_extent(drainotherstrapwidths, _P.strapextentmode, 1, guardringtopmetal)
                    end
                else -- not _P.connectdraininverse
                    if _P.connectdrainboth then
                        guardringtopext_drainstraps = _P.connectdrainotherspace + _get_strap_extent(drainotherstrapwidths, _P.strapextentmode, 1, guardringtopmetal)
                    end
                    guardringbotext_drainstraps = _P.connectdrainspace + _get_strap_extent(drainstrapwidths, _P.strapextentmode, 1, guardringtopmetal)
                end
            end
        end
        -- x extent of the main and the other strap (all strap metals or only the guardring metals, see 'strapextentmode')
        if _P.fingers > 0 and _P.drawdrainstrap then
            local blx, trx, leftext, rightext = _get_sdstrap_xbounds(_P, "drain", gateblx, gatepitch)
            local straplefts, straprights = _get_strap_xranges(drainmetalwidths, _P.drainstartmetal, _P.drainstraptopmetal, _P.gatespace, blx, trx, leftext, rightext, _P.connectdrainminwidth)
            local left, right = _get_strap_xextent(straplefts, straprights, _P.strapextentmode, 1, guardringtopmetal)
            if left then
                guardringleftext_drainstraps = math.max(0, activebl:getx() - left)
                guardringrightext_drainstraps = math.max(0, right - activetr:getx())
            end
            if _P.connectdrainboth and not _P.connectdraininline then
                straplefts, straprights = _get_strap_xranges(drainmetalwidths, _P.drainstartmetal, _P.drainstraptopmetal, _P.gatespace, blx, trx, _P.connectdrainotherleftext, _P.connectdrainotherrightext, _P.connectdrainotherminwidth)
                left, right = _get_strap_xextent(straplefts, straprights, _P.strapextentmode, 1, guardringtopmetal)
                if left then
                    guardringleftext_drainstraps = math.max(guardringleftext_drainstraps, activebl:getx() - left)
                    guardringrightext_drainstraps = math.max(guardringrightext_drainstraps, right - activetr:getx())
                end
            end
        end
    end
    local guardringleftext_polylines = 0
    local guardringrightext_polylines = 0
    if _P.guardringrespectpolylines then
        for _, entry in ipairs(_P.leftpolylines) do
            guardringleftext_polylines = guardringleftext_polylines + entry.space + entry.length
        end
        for _, entry in ipairs(_P.rightpolylines) do
            guardringrightext_polylines = guardringrightext_polylines + entry.space + entry.length
        end
    end
    local guardringleftext = math.max(
        guardringleftext_activedummy,
        guardringleftext_gatestraps,
        guardringleftext_sourcestraps,
        guardringleftext_drainstraps,
        guardringleftext_polylines
    )
    local guardringrightext = math.max(
        guardringrightext_activedummy,
        guardringrightext_gatestraps,
        guardringrightext_sourcestraps,
        guardringrightext_drainstraps,
        guardringrightext_polylines
    )
    local guardringtopext = math.max(
        guardringtopext_activedummy,
        guardringtopext_gateextensions,
        guardringtopext_gatestraps,
        guardringtopext_sourcestraps,
        guardringtopext_drainstraps
    )
    local guardringbotext = math.max(
        guardringbotext_activedummy,
        guardringbotext_gateextensions,
        guardringbotext_gatestraps,
        guardringbotext_sourcestraps,
        guardringbotext_drainstraps
    )
    -- outer boundary of the guardring
    local guardringouterbl = point.create(
        activebl:getx() - guardringleftext - _P.guardringleftsep - _P.guardringwidth,
        activebl:gety() - guardringbotext - _P.guardringbottomsep - _P.guardringwidth
    )
    local guardringoutertr = point.create(
        activetr:getx() + guardringrightext + _P.guardringrightsep + _P.guardringwidth,
        activetr:gety() + guardringtopext + _P.guardringtopsep + _P.guardringwidth
    )

    -- rotation marker
    if _P.drawrotationmarker then
        if _P.rotationmarkerincludeguardring and _P.drawguardring then
            geometry.rectanglebltr(transistor,
                generics.marker("rotation"),
                guardringouterbl:copy():translate(-_P.extendrotationmarkerleft, -_P.extendrotationmarkerbottom),
                guardringoutertr:copy():translate(_P.extendrotationmarkerright, _P.extendrotationmarkertop)
            )
        else
            if _P.rotationmarkeralignwithactive then
                geometry.rectanglebltr(transistor,
                    generics.marker("rotation"),
                    point.create(
                        activebl:getx() - _P.extendrotationmarkerleft,
                        activebl:gety() - _P.extendrotationmarkerbottom
                    ),
                    point.create(
                        activetr:getx() + _P.extendrotationmarkerright,
                        activetr:gety() + _P.extendrotationmarkertop
                    )
                )
            else
                geometry.rectanglebltr(transistor,
                    generics.marker("rotation"),
                    point.create(
                        activebl:getx() - _P.extendrotationmarkerleft,
                        gatebly - _P.extendrotationmarkerbottom
                    ),
                    point.create(
                        activetr:getx() + _P.extendrotationmarkerright,
                        gatetry + _P.extendrotationmarkertop
                    )
                )
            end
        end
    end

    -- analog marker
    if _P.drawanalogmarker then
        if _P.analogmarkerincludeguardring and _P.drawguardring then
            geometry.rectanglebltr(transistor,
                generics.marker("analog"),
                guardringouterbl:copy():translate(-_P.extendanalogmarkerleft, -_P.extendanalogmarkerbottom),
                guardringoutertr:copy():translate(_P.extendanalogmarkerright, _P.extendanalogmarkertop)
            )
        else
            if _P.analogmarkeralignwithactive then
                geometry.rectanglebltr(transistor,
                    generics.marker("analog"),
                    point.create(
                        activebl:getx() - _P.extendanalogmarkerleft,
                        activebl:gety() - _P.extendanalogmarkerbottom
                    ),
                    point.create(
                        activetr:getx() + _P.extendanalogmarkerright,
                        activetr:gety() + _P.extendanalogmarkertop
                    )
                )
            else
                geometry.rectanglebltr(transistor,
                    generics.marker("analog"),
                    point.create(
                        activebl:getx() - _P.extendanalogmarkerleft,
                        gatebly - _P.extendanalogmarkerbottom
                    ),
                    point.create(
                        activetr:getx() + _P.extendanalogmarkerright,
                        gatetry + _P.extendanalogmarkertop
                    )
                )
            end
        end
    end

    -- lvs marker
    if _P.lvsmarkerincludeguardring and _P.drawguardring then
        geometry.rectanglebltr(transistor,
            generics.marker("lvs", _P.lvsmarker),
            guardringouterbl:copy():translate(-_P.extendlvsmarkerleft, -_P.extendlvsmarkerbottom),
            guardringoutertr:copy():translate(_P.extendlvsmarkerright, _P.extendlvsmarkertop)
        )
    else
        if _P.lvsmarkeralignwithactive then
            geometry.rectanglebltr(transistor,
                generics.marker("lvs", _P.lvsmarker),
                point.create(
                    activebl:getx() - _P.extendlvsmarkerleft,
                    activebl:gety() - _P.extendlvsmarkerbottom
                ),
                point.create(
                    activetr:getx() + _P.extendlvsmarkerright,
                    activetr:gety() + _P.extendlvsmarkertop
                )
            )
        else
            geometry.rectanglebltr(transistor,
                generics.marker("lvs", _P.lvsmarker),
                point.create(
                    activebl:getx() - _P.extendlvsmarkerleft,
                    gatebly - _P.extendlvsmarkerbottom
                ),
                point.create(
                    activetr:getx() + _P.extendlvsmarkerright,
                    gatetry + _P.extendlvsmarkertop
                )
            )
        end
    end

    -- well taps
    -- the well taps don't draw their own wells, their well regions are covered by the main well (see below)
    local welltaps = {}
    if _P.drawtopwelltap then
        local welltap = pcell.create_layout("auxiliary/welltap", "topwelltap", {
            contype = _P.flippedwell and (_P.channeltype == "nmos" and "n" or "p") or (_P.channeltype == "nmos" and "p" or "n"),
            width = activetr:getx() - activebl:getx() + _P.topwelltapextendleft + _P.topwelltapextendright,
            height = _P.topwelltapwidth,
            drawwell = false,
        })
        welltap:translate(
            activebl:getx() - _P.topwelltapextendleft,
            _P.fingerwidth + _P.topwelltapspace
        )
        welltaps[#welltaps + 1] = welltap
    end
    if _P.drawbotwelltap then
        local welltap = pcell.create_layout("auxiliary/welltap", "botwelltap", {
            contype = _P.flippedwell and (_P.channeltype == "nmos" and "n" or "p") or (_P.channeltype == "nmos" and "p" or "n"),
            width = activetr:getx() - activebl:getx() + _P.botwelltapextendleft + _P.botwelltapextendright,
            height = _P.botwelltapwidth,
            drawwell = false,
        })
        welltap:translate(
            activebl:getx() - _P.botwelltapextendleft,
            -_P.botwelltapwidth - _P.botwelltapspace
        )
        welltaps[#welltaps + 1] = welltap
    end

    -- well
    local wellbl = point.create(
        _P.wellalignleftwithactive and
            activebl:getx() - _P.extendwellleft or
            leftgatealign - _P.extendwellleft,
        (_P.wellalignbottomwithactive and activebl:gety() or gatebly)
            - math.max(_P.extendwellbottom, enable(_P.drawbotwelltap, _P.botwelltapspace + _P.botwelltapwidth))
    )
    local welltr = point.create(
        _P.wellalignrightwithactive and
            activetr:getx() + _P.extendwellright or
            rightgatealign + _P.extendwellright,
        (_P.wellaligntopwithactive and activetr:gety() or gatetry)
            + math.max(_P.extendwelltop, enable(_P.drawtopwelltap, _P.topwelltapspace + _P.topwelltapwidth))
    )
    -- the well is one rectangle that also covers the well regions of the well taps
    for _, welltap in ipairs(welltaps) do
        local wellanchor = welltap:get_area_anchor("well")
        wellbl = point.create(math.min(wellbl:getx(), wellanchor.l), math.min(wellbl:gety(), wellanchor.b))
        welltr = point.create(math.max(welltr:getx(), wellanchor.r), math.max(welltr:gety(), wellanchor.t))
    end
    if _P.drawwell and not _P.drawguardring then
        geometry.rectanglebltr(transistor,
            generics.well(_P.flippedwell and
                (_P.channeltype == "nmos" and "n" or "p") or
                (_P.channeltype == "nmos" and "p" or "n")
            ),
            wellbl, welltr
        )
    end
    transistor:add_area_anchor_bltr("well", wellbl, welltr)
    for _, welltap in ipairs(welltaps) do
        transistor:merge_into(welltap)
    end

    -- gate contacts
    local gatecontacttype = _P.drawrotationmarker and "gaterotated" or "gate"
    local contactfun = geometry.contactbarebltr2
    local contactext = math.max(0, (_P.minimum_gate_contact_size - _P.gatelength) / 2)
    if _P.drawtopgate then
        if _P.allow_poly_connections then
            contactfun(transistor,
                gatecontacttype,
                point.create(gateblx + (1 - 1) * gatepitch, _P.fingerwidth + topgatespace - _P.topgatepolybottomextension),
                point.create(gatetrx + (_P.fingers - 1) * gatepitch, _P.fingerwidth + topgatespace + _P.topgatewidth + _P.topgatepolytopextension),
                point.create(gateblx + (1 - 1) * gatepitch - contactext, _P.fingerwidth + topgatespace),
                point.create(gatetrx + (_P.fingers - 1) * gatepitch + contactext, _P.fingerwidth + topgatespace + _P.topgatewidth),
                string.format(
                    "top gate contact:\n    x parameters: gatelength (%d)\n    y parameters: topgatewidth (%d)",
                    _P.gatelength, _P.topgatewidth
                )
            )
        else
            for i = 1, _P.fingers do
                contactfun(transistor,
                    gatecontacttype,
                    point.create(gateblx + (i - 1) * gatepitch, _P.fingerwidth + topgatespace - _P.topgatepolybottomextension),
                    point.create(gatetrx + (i - 1) * gatepitch, _P.fingerwidth + topgatespace + _P.topgatewidth + _P.topgatepolytopextension),
                    point.create(gateblx + (i - 1) * gatepitch - contactext, _P.fingerwidth + topgatespace),
                    point.create(gatetrx + (i - 1) * gatepitch + contactext, _P.fingerwidth + topgatespace + _P.topgatewidth),
                    string.format(
                        "top gate contact:\n    x parameters: gatelength (%d)\n    y parameters: topgatewidth (%d)",
                        _P.gatelength, _P.topgatewidth
                    )
                )
                transistor:add_area_anchor_bltr(string.format("topgate%d", i),
                    point.create(gateblx + (i - 1) * gatepitch, _P.fingerwidth + topgatespace),
                    point.create(gatetrx + (i - 1) * gatepitch, _P.fingerwidth + topgatespace + _P.topgatewidth)
                )
            end
        end
    end
    if _P.fingers > 0 and _P.drawtopgatestrap then
        local contactleftext = math.max(_P.topgateleftextension, (_P.minimum_gate_contact_size - _P.gatelength) / 2)
        local contactrightext = math.max(_P.topgaterightextension, (_P.minimum_gate_contact_size - _P.gatelength) / 2)
        local left, right, polyleft, polyright = _get_gatestrap_xrange(_P, gateblx, gatetrx, gatepitch,
            _P.topgateleftextension, _P.topgaterightextension, _P.topgateminwidth,
            _P.topgatepolyleftextension, _P.topgatepolyrightextension
        )
        local bl = point.create(left, _P.fingerwidth + topgatespace)
        local tr = point.create(right, _P.fingerwidth + topgatespace + _P.topgatewidth)
        geometry.rectanglebltr(transistor, generics.metal(1), bl, tr)
        transistor:add_area_anchor_bltr("topgatestrap", bl, tr)
        if rawget(_P, "gatenet") then
            transistor:mark_area_anchor_as_net("topgatestrap", _P.gatenet, generics.metal(_P.topgatemetal))
            transistor:add_label(_P.gatenet, generics.metal(_P.topgatemetal),
                point.create(
                    0.5 * (transistor:get_area_anchor("topgatestrap").l + transistor:get_area_anchor("topgatestrap").r),
                    0.5 * (transistor:get_area_anchor("topgatestrap").b + transistor:get_area_anchor("topgatestrap").t)
                ),
                _P.netlabelsizehint
            )
        end
        if _P.allow_poly_connections then
            geometry.rectanglebltr(transistor, generics.gate(),
                point.create(polyleft, bl:gety() - _P.topgatepolybottomextension),
                point.create(polyright, gatetry + _P.topgatepolytopextension)
            )
        end
        if _P.drawtopgatevia and _P.topgatemetal > 1 then
            if _P.topgatecontinuousvia then
                geometry.viabltr_xcontinuous(transistor, 1, _P.topgatemetal, bl, tr)
            else
                geometry.viabltr(transistor, 1, _P.topgatemetal, bl, tr,
                    string.format(
                        "top gate strap via:\n    x parameters:\n        gatelength (%d)\n        (fingers - 1) * (gatelength + gatespace) (%d)\n        top gate left extension (%d)\n        top gate right extension (%d)\n    y parameters:\n        topgatewidth (%d)",
                        _P.gatelength, (_P.fingers - 1) * gatepitch, contactleftext, contactrightext, _P.topgatewidth
                    )
                )
            end
        end
    end
    if _P.drawbotgate then
        if _P.allow_poly_connections then
            contactfun(transistor,
                gatecontacttype,
                point.create(gateblx + (1 - 1) * gatepitch, -botgatespace - _P.botgatewidth - _P.botgatepolybottomextension),
                point.create(gatetrx + (_P.fingers - 1) * gatepitch, -botgatespace + _P.botgatepolytopextension),
                point.create(gateblx + (1 - 1) * gatepitch - contactext, -botgatespace - _P.botgatewidth),
                point.create(gatetrx + (_P.fingers - 1) * gatepitch + contactext, -botgatespace),
                string.format("bot gate contact:\n    x parameters: gatelength (%d)\n    y parameters: botgatewidth (%d)", _P.gatelength, _P.botgatewidth)
            )
        else
            for i = 1, _P.fingers do
                contactfun(transistor,
                    gatecontacttype,
                    point.create(gateblx + (i - 1) * gatepitch, -botgatespace - _P.botgatewidth - _P.botgatepolybottomextension),
                    point.create(gatetrx + (i - 1) * gatepitch, -botgatespace + _P.botgatepolytopextension),
                    point.create(gateblx + (i - 1) * gatepitch - contactext, -botgatespace - _P.botgatewidth),
                    point.create(gatetrx + (i - 1) * gatepitch + contactext, -botgatespace),
                    string.format("bot gate contact:\n    x parameters: gatelength (%d)\n    y parameters: botgatewidth (%d)", _P.gatelength, _P.botgatewidth)
                )
                transistor:add_area_anchor_bltr(string.format("botgate%d", i),
                    point.create(gateblx + (i - 1) * gatepitch, -botgatespace - _P.botgatewidth),
                    point.create(gatetrx + (i - 1) * gatepitch, -botgatespace)
                )
            end
        end
    end
    if _P.fingers > 0 and _P.drawbotgatestrap then
        local contactleftext = math.max(_P.botgateleftextension, (_P.minimum_gate_contact_size - _P.gatelength) / 2)
        local contactrightext = math.max(_P.botgaterightextension, (_P.minimum_gate_contact_size - _P.gatelength) / 2)
        local left, right, polyleft, polyright = _get_gatestrap_xrange(_P, gateblx, gatetrx, gatepitch,
            _P.botgateleftextension, _P.botgaterightextension, _P.botgateminwidth,
            _P.botgatepolyleftextension, _P.botgatepolyrightextension
        )
        local bl = point.create(left, -botgatespace - _P.botgatewidth)
        local tr = point.create(right, -botgatespace)
        geometry.rectanglebltr(transistor, generics.metal(1), bl, tr)
        transistor:add_area_anchor_bltr("botgatestrap", bl, tr)
        if rawget(_P, "gatenet") then
            transistor:mark_area_anchor_as_net("botgatestrap", _P.gatenet, generics.metal(_P.botgatemetal))
            transistor:add_label(_P.gatenet, generics.metal(_P.botgatemetal),
                point.create(
                    0.5 * (transistor:get_area_anchor("botgatestrap").l + transistor:get_area_anchor("botgatestrap").r),
                    0.5 * (transistor:get_area_anchor("botgatestrap").b + transistor:get_area_anchor("botgatestrap").t)
                ),
                _P.netlabelsizehint
            )
        end
        if _P.allow_poly_connections then
            geometry.rectanglebltr(transistor, generics.gate(),
                point.create(polyleft, gatebly - _P.botgatepolybottomextension),
                point.create(polyright, tr:gety() + _P.botgatepolytopextension)
            )
        end
        if _P.drawbotgatevia and _P.botgatemetal > 1 then
            if _P.botgatecontinuousvia then
                geometry.viabltr_xcontinuous(transistor, 1, _P.botgatemetal, bl, tr)
            else
                geometry.viabltr(transistor, 1, _P.botgatemetal, bl, tr,
                    string.format("bot gate strap via:\n    x parameters:\n        gatelength (%d)\n        fingers * (gatelength + gatespace) (%d)\n        bottom gate left extension (%d)\n        bottom gate right extension (%d)\n    y parameters:\n        botgatewidth (%d)", _P.gatelength, _P.fingers * gatepitch, contactleftext, contactrightext, _P.botgatewidth)
                )
            end
        end
    end

    -- source/drain contacts and vias
    local sourceoffset
    local sourceviaoffset
    if _P.sourcealign == "top" then
        sourceoffset = _P.fingerwidth - _P.sourcesize
    elseif _P.sourcealign == "bottom" then
        sourceoffset = 0
    else -- center
        sourceoffset = (_P.fingerwidth - _P.sourcesize) / 2
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
        drainoffset = (_P.fingerwidth - _P.drainsize) / 2
    end
    if _P.drainviaalign == "top" then
        drainviaoffset = _P.fingerwidth - _P.drainviasize
    elseif _P.drainviaalign == "bottom" then
        drainviaoffset = 0
    else -- center
        drainviaoffset = (_P.fingerwidth - _P.drainviasize) / 2
    end
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
    -- interweaved vias: the via cuts of source and drain are staggered, one terminal gets one cut less (shifted by
    -- half a cut pitch). This is done up to the highest common via metal of source and drain. Without
    -- 'alternateinterweaving' the drain always gets the reduced cuts, with it the terminals alternate per via level,
    -- starting with full cuts on the source for metal 1 to metal 2
    local interweavemetal = math.min(_P.sourceviametal, _P.drainviametal)
    local function _interweave_reduced(kind, metal)
        if _P.alternateinterweaving and metal % 2 == 0 then
            return kind == "source"
        else
            return kind == "drain"
        end
    end
    if _P.drawsourcedrain ~= "none" then
        -- source
        if _P.drawsourcedrain == "both" or _P.drawsourcedrain == "source" then
            for i = 1, _P.fingers + 1, 2 do
                local shift = gateblx - (_P.gatespace + _P.sdwidth) / 2 + (i - 1) * gatepitch
                local sdactivebl = point.create(shift - _P.actext, sourceoffset)
                local sdactivetr = point.create(shift + _P.actext + _P.sdwidth, sourceoffset + _P.sourcesize)
                local metalbl = point.create(shift, sourceoffset)
                local metaltr = point.create(shift + _P.sdwidth, sourceoffset + _P.sourcesize)
                local debugstr = string.format(
                    "source/drain contacts:\n    x parameters: sdwidth (%d)\n    y parameters: sourcesize (%d)",
                    _P.sdwidth, _P.sourcesize
                )
                if not util.any_of(i, _P.excludesourcedraincontacts) then
                    if _P.sourcesize > _P.fingerwidth then
                        geometry.rectanglebltr(transistor, generics.active(), sdactivebl, sdactivetr)
                    end
                    geometry.contactbarebltr2(transistor, contacttype, sdactivebl, sdactivetr, metalbl, metaltr, debugstr)
                    -- the vias and the metals above metal 1 are only drawn together (no floating metals)
                    local drawsourcevias = _P.drawsourcevia and _P.sourceviametal > 1 and
                        not (i == 1 and not _P.drawfirstsourcevia or i == _P.fingers + 1 and not _P.drawlastsourcevia)
                    if drawsourcevias then
                        for metal = 1, _P.sourceviametal - 1 do
                            if _P.interweavevias and metal + 1 <= interweavemetal then
                                -- the via array has the width of the narrower metal, both metals are centered on the source region,
                                -- so the cuts are placed relative to the left edge of the narrower metal
                                local viatable = geometry.calculate_viabltr2(
                                    metal, metal + 1,
                                    point.create(
                                        shift - sourcemetalshifts[metal],
                                        sourceviaoffset
                                    ),
                                    point.create(
                                        shift + sourcemetalwidths[metal] - sourcemetalshifts[metal],
                                        sourceviaoffset + _P.sourceviasize
                                    ),
                                    point.create(
                                        shift - sourcemetalshifts[metal + 1],
                                        sourceviaoffset
                                    ),
                                    point.create(
                                        shift + sourcemetalwidths[metal + 1] - sourcemetalshifts[metal + 1],
                                        sourceviaoffset + _P.sourceviasize
                                    ),
                                    _P.minviaxspace, _P.minviayspace
                                )
                                for _, viaentry in ipairs(viatable) do
                                    local numcuts = viaentry.yrep
                                    local cutxoffset = viaentry.xoffset
                                    local cutyoffset = viaentry.yoffset
                                    local cutwidth = viaentry.width
                                    local cutheight = viaentry.height
                                    local cutspace = viaentry.yspace
                                    local cutlayer = viaentry.layer
                                    -- don't reduce single cuts (the via level would not be connected)
                                    if _interweave_reduced("source", metal) and numcuts > 1 then
                                        numcuts = numcuts - 1
                                        cutyoffset = cutyoffset + math.floor((viaentry.yspace + viaentry.height) / 2)
                                    end
                                    for xi = 1, viaentry.xrep do
                                        local cutx = shift - math.min(sourcemetalshifts[metal], sourcemetalshifts[metal + 1]) + cutxoffset + (xi - 1) * (viaentry.xspace + cutwidth)
                                        for yi = 1, numcuts do
                                            geometry.rectanglebltr(transistor, cutlayer,
                                                point.create(
                                                    cutx,
                                                    sourceviaoffset + cutyoffset + (yi - 1) * (cutspace + cutheight)
                                                ),
                                                point.create(
                                                    cutx + cutwidth,
                                                    sourceviaoffset + cutyoffset + (yi - 1) * (cutspace + cutheight) + cutheight
                                                )
                                            )
                                        end
                                    end
                                end
                            else
                                if metal < _P.sourceviametal - 1 then
                                    geometry.viabarebltr2(transistor, metal, metal + 1,
                                        point.create(
                                            shift - sourcemetalshifts[metal],
                                            sourceviaoffset
                                        ),
                                        point.create(
                                            shift + sourcemetalwidths[metal] - sourcemetalshifts[metal],
                                            sourceviaoffset + _P.sourceviasize
                                        ),
                                        point.create(
                                            shift - sourcemetalshifts[metal + 1],
                                            sourceviaoffset
                                        ),
                                        point.create(
                                            shift + sourcemetalwidths[metal + 1] - sourcemetalshifts[metal + 1],
                                            sourceviaoffset + _P.sourceviasize
                                        ),
                                        string.format(
                                            "source via:\n    x parameters: sourcemetalwidth 1 (%d) / sourcemetalwidth 2 (%d)\n    y parameters: sourceviasize (%d)",
                                            sourcemetalwidths[metal], sourcemetalwidths[metal + 1], _P.sourceviasize
                                        )
                                    )
                                else
                                    if _P.splitsourcevias then
                                        -- split vias: only the parts of the via region below and above the inline strap
                                        local splitparts = {
                                            { sourceviaoffset, splitsourceviaoffset },
                                            { splitsourceviaoffset + _P.connectsourcewidth, sourceviaoffset + _P.sourceviasize },
                                        }
                                        for _, part in ipairs(splitparts) do
                                            if part[2] > part[1] then
                                                geometry.viabarebltr2(transistor, _P.sourceviametal - 1, _P.sourceviametal,
                                                    point.create(
                                                        shift - sourcemetalshifts[_P.sourceviametal - 1],
                                                        part[1]
                                                    ),
                                                    point.create(
                                                        shift + sourcemetalwidths[_P.sourceviametal - 1] - sourcemetalshifts[_P.sourceviametal - 1],
                                                        part[2]
                                                    ),
                                                    point.create(
                                                        shift - sourcemetalshifts[_P.sourceviametal],
                                                        part[1]
                                                    ),
                                                    point.create(
                                                        shift + sourcemetalwidths[_P.sourceviametal] - sourcemetalshifts[_P.sourceviametal],
                                                        part[2]
                                                    ),
                                                    string.format(
                                                        "source split via:\n    x parameters: sourcemetalwidth 1 (%d) / sourcemetalwidth 2 (%d)\n    y parameters: part of sourceviasize (%d) not covered by the inline strap (%d)",
                                                        sourcemetalwidths[_P.sourceviametal - 1], sourcemetalwidths[_P.sourceviametal], part[2] - part[1], _P.connectsourcewidth
                                                    )
                                                )
                                            end
                                        end
                                    else
                                        geometry.viabarebltr2(transistor, _P.sourceviametal - 1, _P.sourceviametal,
                                            point.create(
                                                shift - sourcemetalshifts[_P.sourceviametal - 1],
                                                sourceviaoffset
                                            ),
                                            point.create(
                                                shift + sourcemetalwidths[_P.sourceviametal - 1] - sourcemetalshifts[_P.sourceviametal - 1],
                                                sourceviaoffset + _P.sourceviasize
                                            ),
                                            point.create(
                                                shift - sourcemetalshifts[_P.sourceviametal],
                                                sourceviaoffset
                                            ),
                                            point.create(
                                                shift + sourcemetalwidths[_P.sourceviametal] - sourcemetalshifts[_P.sourceviametal],
                                                sourceviaoffset + _P.sourceviasize
                                            ),
                                            string.format(
                                                "source via:\n    x parameters: sourcemetalwidth 1 (%d) / sourcemetalwidth 2 (%d)\n    y parameters: sourceviasize (%d)",
                                                sourcemetalwidths[_P.sourceviametal - 1], sourcemetalwidths[_P.sourceviametal], _P.sourceviasize
                                            )
                                        )
                                    end
                                end
                            end
                        end
                    end
                    -- metal 1
                    geometry.rectanglebltr(transistor, generics.metal(1),
                        point.create(shift - sourcemetalshifts[1], sourceoffset - _P.sdm1botext),
                        point.create(shift + sourcemetalwidths[1] - sourcemetalshifts[1], sourceoffset + _P.sourcesize + _P.sdm1topext)
                    )
                    if drawsourcevias then
                        -- inter-level metals
                        for metal = 2, _P.sourceviametal - 1 do
                            geometry.rectanglebltr(transistor, generics.metal(metal),
                                point.create(shift - sourcemetalshifts[metal], sourceviaoffset - _P.sdmxbotext),
                                point.create(shift + sourcemetalwidths[metal] - sourcemetalshifts[metal], sourceviaoffset + _P.sourceviasize + _P.sdmxtopext)
                            )
                        end
                        -- top via metal
                        geometry.rectanglebltr(transistor, generics.metal(_P.sourceviametal),
                            point.create(shift - sourcemetalshifts[_P.sourceviametal], sourceviaoffset),
                            point.create(shift + sourcemetalwidths[_P.sourceviametal] - sourcemetalshifts[_P.sourceviametal], sourceviaoffset + _P.sourceviasize)
                        )
                    end
                end
                -- anchors
                transistor:add_area_anchor_bltr(string.format("sourcedrain%d", i), metalbl, metaltr)
                transistor:add_area_anchor_bltr(string.format("sourcedrain%d", i - _P.fingers - 2), metalbl, metaltr)
                transistor:add_area_anchor_bltr(string.format("sourcedrainmetal%d", i),
                    point.create(shift - sourcemetalshifts[_P.sourceviametal], sourceviaoffset),
                    point.create(shift + sourcemetalwidths[_P.sourceviametal] - sourcemetalshifts[_P.sourceviametal], sourceviaoffset + _P.sourceviasize)
                )
                transistor:add_area_anchor_bltr(string.format("sourcedrainmetal%d", i - _P.fingers - 2),
                    point.create(shift - sourcemetalshifts[_P.sourceviametal], sourceviaoffset),
                    point.create(shift + sourcemetalwidths[_P.sourceviametal] - sourcemetalshifts[_P.sourceviametal], sourceviaoffset + _P.sourceviasize)
                )
            end
        end
        -- drain
        if _P.drawsourcedrain == "both" or _P.drawsourcedrain == "drain" then
            for i = 2, _P.fingers + 1, 2 do
                local shift = gateblx - (_P.gatespace + _P.sdwidth) / 2 + (i - 1) * gatepitch
                local sdactivebl = point.create(shift - _P.actext, drainoffset)
                local sdactivetr = point.create(shift + _P.actext + _P.sdwidth, drainoffset + _P.drainsize)
                local metalbl = point.create(shift, drainoffset)
                local metaltr = point.create(shift + _P.sdwidth, drainoffset + _P.drainsize)
                local debugstr = string.format(
                    "drain contact:\n    x parameters: sdwidth (%d)\n    y parameters: drainsize (%d)",
                    _P.sdwidth, _P.drainsize
                )
                if not util.any_of(i, _P.excludesourcedraincontacts) then
                    if _P.drainsize > _P.fingerwidth then
                        geometry.rectanglebltr(transistor, generics.active(), sdactivebl, sdactivetr)
                    end
                    geometry.contactbarebltr2(transistor, contacttype, sdactivebl, sdactivetr, metalbl, metaltr, debugstr)
                    -- the vias and the metals above metal 1 are only drawn together (no floating metals)
                    local drawdrainvias = _P.drawdrainvia and _P.drainviametal > 1 and
                        not (i == 2 and not _P.drawfirstdrainvia or i == _P.fingers + 1 and not _P.drawlastdrainvia)
                    if drawdrainvias then
                        for metal = 1, _P.drainviametal - 1 do
                            if _P.interweavevias and metal + 1 <= interweavemetal then
                                -- the via array has the width of the narrower metal, both metals are centered on the drain region,
                                -- so the cuts are placed relative to the left edge of the narrower metal
                                local viatable = geometry.calculate_viabltr2(
                                    metal, metal + 1,
                                    point.create(shift - drainmetalshifts[metal], drainviaoffset),
                                    point.create(shift + drainmetalwidths[metal] - drainmetalshifts[metal], drainviaoffset + _P.drainviasize),
                                    point.create(shift - drainmetalshifts[metal + 1], drainviaoffset),
                                    point.create(shift + drainmetalwidths[metal + 1] - drainmetalshifts[metal + 1], drainviaoffset + _P.drainviasize),
                                    _P.minviaxspace, _P.minviayspace
                                )
                                for _, viaentry in ipairs(viatable) do
                                    local numcuts = viaentry.yrep
                                    local cutxoffset = viaentry.xoffset
                                    local cutyoffset = viaentry.yoffset
                                    local cutwidth = viaentry.width
                                    local cutheight = viaentry.height
                                    local cutspace = viaentry.yspace
                                    local cutlayer = viaentry.layer
                                    -- don't reduce single cuts (the via level would not be connected)
                                    if _interweave_reduced("drain", metal) and numcuts > 1 then
                                        numcuts = numcuts - 1
                                        cutyoffset = cutyoffset + math.floor((viaentry.yspace + viaentry.height) / 2)
                                    end
                                    for xi = 1, viaentry.xrep do
                                        local cutx = shift - math.min(drainmetalshifts[metal], drainmetalshifts[metal + 1]) + cutxoffset + (xi - 1) * (viaentry.xspace + cutwidth)
                                        for yi = 1, numcuts do
                                            geometry.rectanglebltr(transistor, cutlayer,
                                                point.create(cutx, drainviaoffset + cutyoffset + (yi - 1) * (cutspace + cutheight)),
                                                point.create(cutx + cutwidth, drainviaoffset + cutyoffset + (yi - 1) * (cutspace + cutheight) + cutheight)
                                            )
                                        end
                                    end
                                end
                            else -- not _P.interweavevias
                                if metal < _P.drainviametal - 1 then
                                    geometry.viabarebltr2(transistor, metal, metal + 1,
                                        point.create(shift - drainmetalshifts[metal], drainviaoffset),
                                        point.create(shift + drainmetalwidths[metal] - drainmetalshifts[metal], drainviaoffset + _P.drainviasize),
                                        point.create(shift - drainmetalshifts[metal + 1], drainviaoffset),
                                        point.create(shift + drainmetalwidths[metal + 1] - drainmetalshifts[metal + 1], drainviaoffset + _P.drainviasize),
                                        string.format(
                                            "drain via:\n    x parameters: drainmetalwidth 1 (%d) / drainmetalwidth 2\n    y parameters: drainviasize (%d)",
                                            drainmetalwidths[metal], drainmetalwidths[metal + 1], _P.drainviasize
                                        )
                                    )
                                else
                                    if _P.splitdrainvias then
                                        -- split vias: only the parts of the via region below and above the inline strap
                                        local splitparts = {
                                            { drainviaoffset, splitdrainviaoffset },
                                            { splitdrainviaoffset + _P.connectdrainwidth, drainviaoffset + _P.drainviasize },
                                        }
                                        for _, part in ipairs(splitparts) do
                                            if part[2] > part[1] then
                                                geometry.viabarebltr2(transistor, _P.drainviametal - 1, _P.drainviametal,
                                                    point.create(
                                                        shift - drainmetalshifts[_P.drainviametal - 1],
                                                        part[1]
                                                    ),
                                                    point.create(
                                                        shift + drainmetalwidths[_P.drainviametal - 1] - drainmetalshifts[_P.drainviametal - 1],
                                                        part[2]
                                                    ),
                                                    point.create(
                                                        shift - drainmetalshifts[_P.drainviametal],
                                                        part[1]
                                                    ),
                                                    point.create(
                                                        shift + drainmetalwidths[_P.drainviametal] - drainmetalshifts[_P.drainviametal],
                                                        part[2]
                                                    ),
                                                    string.format(
                                                        "drain split via:\n    x parameters: drainmetalwidth 1 (%d) / drainmetalwidth 2 (%d)\n    y parameters: part of drainviasize (%d) not covered by the inline strap (%d)",
                                                        drainmetalwidths[_P.drainviametal - 1], drainmetalwidths[_P.drainviametal], part[2] - part[1], _P.connectdrainwidth
                                                    )
                                                )
                                            end
                                        end
                                    else
                                        geometry.viabarebltr2(transistor, _P.drainviametal - 1, _P.drainviametal,
                                            point.create(
                                                shift - drainmetalshifts[_P.drainviametal - 1],
                                                drainviaoffset
                                            ),
                                            point.create(
                                                shift + drainmetalwidths[_P.drainviametal - 1] - drainmetalshifts[_P.drainviametal - 1],
                                                drainviaoffset + _P.drainviasize
                                            ),
                                            point.create(
                                                shift - drainmetalshifts[_P.drainviametal],
                                                drainviaoffset
                                            ),
                                            point.create(
                                                shift + drainmetalwidths[_P.drainviametal] - drainmetalshifts[_P.drainviametal],
                                                drainviaoffset + _P.drainviasize
                                            ),
                                            string.format(
                                                "drain via:\n    x parameters: drainmetalwidth 1 (%d) / drainmetalwidth 2 (%d)\n    y parameters: drainviasize (%d)",
                                                drainmetalwidths[_P.drainviametal - 1], drainmetalwidths[_P.drainviametal], _P.drainviasize
                                            )
                                        )
                                    end
                                end
                            end
                        end
                    end
                    -- metal 1
                    geometry.rectanglebltr(transistor, generics.metal(1),
                        point.create(shift - drainmetalshifts[1], drainoffset - _P.sdm1botext),
                        point.create(shift + drainmetalwidths[1] - drainmetalshifts[1], drainoffset + _P.drainsize + _P.sdm1topext)
                    )
                    if drawdrainvias then
                        -- inter-level metals
                        for metal = 2, _P.drainviametal - 1 do
                            geometry.rectanglebltr(transistor, generics.metal(metal),
                                point.create(shift - drainmetalshifts[metal], drainviaoffset - _P.sdmxbotext),
                                point.create(shift + drainmetalwidths[metal] - drainmetalshifts[metal], drainviaoffset + _P.drainviasize + _P.sdmxtopext)
                            )
                        end
                        geometry.rectanglebltr(transistor, generics.metal(_P.drainviametal),
                            point.create(shift - drainmetalshifts[_P.drainviametal], drainviaoffset),
                            point.create(shift + drainmetalwidths[_P.drainviametal] - drainmetalshifts[_P.drainviametal], drainviaoffset + _P.drainviasize)
                        )
                    end
                end
                -- anchors
                transistor:add_area_anchor_bltr(string.format("sourcedrain%d", i), metalbl, metaltr)
                transistor:add_area_anchor_bltr(string.format("sourcedrain%d", i - _P.fingers - 2), metalbl, metaltr)
                transistor:add_area_anchor_bltr(string.format("sourcedrainmetal%d", i),
                point.create(shift - drainmetalshifts[_P.drainviametal], drainviaoffset),
                point.create(shift + drainmetalwidths[_P.drainviametal] - drainmetalshifts[_P.drainviametal], drainviaoffset + _P.drainviasize)
            )
                transistor:add_area_anchor_bltr(string.format("sourcedrainmetal%d", i - _P.fingers - 2),
                    point.create(shift - drainmetalshifts[_P.drainviametal], drainviaoffset),
                    point.create(shift + drainmetalwidths[_P.drainviametal] - drainmetalshifts[_P.drainviametal], drainviaoffset + _P.drainviasize)
                )
            end
        end
    end

    -- diode connected
    if _P.diodeconnected then
        local regions = _P.diodeconnectedreversed and sdcontacts.source or sdcontacts.drain
        local metalshifts = _P.diodeconnectedreversed and sourcemetalshifts or drainmetalshifts
        for _, i in ipairs(regions) do
            if _P.drawtopgatestrap then
                geometry.rectanglebltr(transistor, generics.metal(1),
                    transistor:get_area_anchor(string.format("sourcedrain%d", i)).tl:translate_x(-metalshifts[1]),
                    transistor:get_area_anchor(string.format("sourcedrain%d", i)).tr:translate_x(metalshifts[1]) ..
                    transistor:get_area_anchor(string.format("topgatestrap", i)).br
                )
            end
            if _P.drawbotgatestrap then
                geometry.rectanglebltr(transistor, generics.metal(1),
                    transistor:get_area_anchor(string.format("sourcedrain%d", i)).bl:translate_x(-metalshifts[1]) ..
                    transistor:get_area_anchor(string.format("botgatestrap", i)).tl,
                    transistor:get_area_anchor(string.format("sourcedrain%d", i)).br:translate_x(metalshifts[1])
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
            local shift = gateblx - (_P.gatespace + _P.sdwidth) / 2 + (i - 1) * gatepitch
            local connsourceoffset = _P.sourcestartmetal > 1 and sourceviaoffset or sourceoffset
            local connsourcetop = _P.sourcestartmetal > 1 and _P.sourceviasize or _P.sourcesize
            if sourceinvert then
                if connsourceoffset + connsourcetop < _P.fingerwidth + _P.connectsourcespace then -- don't draw connections if they are malformed
                    if not (i == 1 and not _P.drawfirstsourcevia or i == _P.fingers + 1 and not _P.drawlastsourcevia) then
                        if _P.restrictsourcemetalstostrap then
                            local extrashift = -sourcemetalshifts[_P.sourceviametal]
                            geometry.rectanglebltr(transistor, generics.metal(_P.sourceviametal),
                                point.create(shift + extrashift, connsourceoffset + connsourcetop),
                                point.create(shift + extrashift + sourcemetalwidths[_P.sourceviametal], _P.fingerwidth + _P.connectsourcespace)
                            )
                        else
                            for sourcemetal = _P.sourcestartmetal, _P.sourceendmetal do
                                local extrashift = -sourcemetalshifts[sourcemetal]
                                geometry.rectanglebltr(transistor, generics.metal(sourcemetal),
                                    point.create(shift + extrashift, connsourceoffset + connsourcetop),
                                    point.create(shift + extrashift + sourcemetalwidths[sourcemetal], _P.fingerwidth + _P.connectsourcespace)
                                )
                            end
                        end
                    end
                end
                if _P.connectsourceboth then
                    if -_P.connectsourceotherspace < connsourceoffset then -- don't draw connections if they are malformed
                        if not (i == 1 and not _P.drawfirstsourcevia or i == _P.fingers + 1 and not _P.drawlastsourcevia) then
                            if _P.restrictsourcemetalstostrap then
                                local extrashift = -sourcemetalshifts[_P.sourceviametal]
                                geometry.rectanglebltr(transistor, generics.metal(_P.sourceviametal),
                                    point.create(shift + extrashift, -_P.connectsourceotherspace),
                                    point.create(shift + extrashift + sourcemetalwidths[_P.sourceviametal], connsourceoffset)
                                )
                            else
                                for sourcemetal = _P.sourcestartmetal, _P.sourceendmetal do
                                    local extrashift = -sourcemetalshifts[sourcemetal]
                                    geometry.rectanglebltr(transistor, generics.metal(sourcemetal),
                                        point.create(shift + extrashift, -_P.connectsourceotherspace),
                                        point.create(shift + extrashift + sourcemetalwidths[sourcemetal], connsourceoffset)
                                    )
                                end
                            end
                        end
                    end
                end
            else
                if -_P.connectsourcespace < connsourceoffset then -- don't draw connections if they are malformed
                    if not (i == 1 and not _P.drawfirstsourcevia or i == _P.fingers + 1 and not _P.drawlastsourcevia) then
                        if _P.restrictsourcemetalstostrap then
                            local extrashift = -sourcemetalshifts[_P.sourceviametal]
                            geometry.rectanglebltr(transistor, generics.metal(_P.sourceviametal),
                                point.create(shift + extrashift, -_P.connectsourcespace),
                                point.create(shift + extrashift + sourcemetalwidths[_P.sourceviametal], connsourceoffset)
                            )
                        else
                            for sourcemetal = _P.sourcestartmetal, _P.sourceendmetal do
                                local extrashift = -sourcemetalshifts[sourcemetal]
                                geometry.rectanglebltr(transistor, generics.metal(sourcemetal),
                                    point.create(shift + extrashift, -_P.connectsourcespace),
                                    point.create(shift + extrashift + sourcemetalwidths[sourcemetal], connsourceoffset)
                                )
                            end
                        end
                    end
                end
                if _P.connectsourceboth then
                    if connsourceoffset + connsourcetop < _P.fingerwidth + _P.connectsourceotherspace then -- don't draw connections if they are malformed
                        if not (i == 1 and not _P.drawfirstsourcevia or i == _P.fingers + 1 and not _P.drawlastsourcevia) then
                            if _P.restrictsourcemetalstostrap then
                                local extrashift = -sourcemetalshifts[_P.sourceviametal]
                                geometry.rectanglebltr(transistor, generics.metal(_P.sourceviametal),
                                    point.create(shift + extrashift, connsourceoffset + connsourcetop),
                                    point.create(shift + extrashift + sourcemetalwidths[_P.sourceviametal], _P.fingerwidth + _P.connectsourceotherspace)
                                )
                            else
                                for sourcemetal = _P.sourcestartmetal, _P.sourceendmetal do
                                    local extrashift = -sourcemetalshifts[sourcemetal]
                                    geometry.rectanglebltr(transistor, generics.metal(sourcemetal),
                                        point.create(shift + extrashift, connsourceoffset + connsourcetop),
                                        point.create(shift + extrashift + sourcemetalwidths[sourcemetal], _P.fingerwidth + _P.connectsourceotherspace)
                                    )
                                end
                            end
                        end
                    end
                end
            end
        end
    end

    -- source strap
    if _P.fingers > 0 then
        local blx, trx, leftext, rightext = _get_sdstrap_xbounds(_P, "source", gateblx, gatepitch)
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
            -- per-metal strap extents, the bottom edge is kept fixed
            local strapwidths = sourcestrapwidths
            local strapbottoms, straptops = _get_strap_yranges(strapwidths, bly, 1)
            local straplefts, straprights = _get_strap_xranges(sourcemetalwidths, _P.sourcestartmetal, _P.sourcestraptopmetal, _P.gatespace, blx, trx, leftext, rightext, _P.connectsourceminwidth)
            if _P.drawsourcestrap then
                -- main strap
                for sourcemetal = _P.sourcestartmetal, _P.sourceendmetal do
                    geometry.rectanglebltr(transistor, generics.metal(sourcemetal),
                        point.create(straplefts[sourcemetal], strapbottoms[sourcemetal]),
                        point.create(straprights[sourcemetal], straptops[sourcemetal])
                    )
                end
                for sourcemetal = _P.sourcestartmetal, _P.sourceendmetal - 1 do
                    geometry.viabarebltr2(transistor, sourcemetal, sourcemetal + 1,
                        point.create(straplefts[sourcemetal], strapbottoms[sourcemetal]),
                        point.create(straprights[sourcemetal], straptops[sourcemetal]),
                        point.create(straplefts[sourcemetal + 1], strapbottoms[sourcemetal + 1]),
                        point.create(straprights[sourcemetal + 1], straptops[sourcemetal + 1])
                    )
                end
                if _P.sourceendmetal < _P.sourcestraptopmetal then
                    for sourcemetal = _P.sourceendmetal, _P.sourcestraptopmetal - 1 do
                        geometry.rectanglebltr(transistor, generics.metal(sourcemetal + 1),
                            point.create(straplefts[sourcemetal + 1], strapbottoms[sourcemetal + 1]),
                            point.create(straprights[sourcemetal + 1], straptops[sourcemetal + 1])
                        )
                        geometry.viabarebltr2(transistor, sourcemetal, sourcemetal + 1,
                            point.create(straplefts[sourcemetal], strapbottoms[sourcemetal]),
                            point.create(straprights[sourcemetal], straptops[sourcemetal]),
                            point.create(straplefts[sourcemetal + 1], strapbottoms[sourcemetal + 1]),
                            point.create(straprights[sourcemetal + 1], straptops[sourcemetal + 1])
                        )
                    end
                end
            end
            -- place anchor on highest-metal strap
            transistor:add_area_anchor_bltr("sourcestrap",
                point.create(straplefts[_P.sourceendmetal], strapbottoms[_P.sourceendmetal]),
                point.create(straprights[_P.sourceendmetal], straptops[_P.sourceendmetal])
            )
            if rawget(_P, "sourcenet") then
                transistor:mark_area_anchor_as_net("sourcestrap", _P.sourcenet, generics.metal(_P.sourcestraptopmetal))
                transistor:add_label(_P.sourcenet, generics.metal(_P.sourcestraptopmetal),
                    point.create(
                        0.5 * (transistor:get_area_anchor("sourcestrap").l + transistor:get_area_anchor("sourcestrap").r),
                        0.5 * (transistor:get_area_anchor("sourcestrap").b + transistor:get_area_anchor("sourcestrap").t)
                    ),
                    _P.netlabelsizehint
                )
            end
        else -- not _P.connectsourceinline
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
            -- per-metal strap extents, the strap edges facing the device are kept fixed
            local strapwidths1 = sourcestrapwidths
            local strapbottoms1, straptops1
            if bly1 < 0 then -- strap below the device
                strapbottoms1, straptops1 = _get_strap_yranges(strapwidths1, bly1 + _P.connectsourcewidth, -1)
            else
                strapbottoms1, straptops1 = _get_strap_yranges(strapwidths1, bly1, 1)
            end
            local strapwidths2 = sourceotherstrapwidths
            local strapbottoms2, straptops2
            if bly2 < 0 then -- strap below the device
                strapbottoms2, straptops2 = _get_strap_yranges(strapwidths2, bly2 + _P.connectsourceotherwidth, -1)
            else
                strapbottoms2, straptops2 = _get_strap_yranges(strapwidths2, bly2, 1)
            end
            local straplefts1, straprights1 = _get_strap_xranges(sourcemetalwidths, _P.sourcestartmetal, _P.sourcestraptopmetal, _P.gatespace, blx, trx, leftext, rightext, _P.connectsourceminwidth)
            local straplefts2, straprights2 = _get_strap_xranges(sourcemetalwidths, _P.sourcestartmetal, _P.sourcestraptopmetal, _P.gatespace, blx, trx, _P.connectsourceotherleftext, _P.connectsourceotherrightext, _P.connectsourceotherminwidth)
            -- main strap
            if _P.drawsourcestrap then
                for sourcemetal = _P.sourcestartmetal, _P.sourceendmetal do
                    geometry.rectanglebltr(transistor, generics.metal(sourcemetal),
                        point.create(straplefts1[sourcemetal], strapbottoms1[sourcemetal]),
                        point.create(straprights1[sourcemetal], straptops1[sourcemetal])
                    )
                    if _P.connectsourceboth then
                        -- other strap
                        geometry.rectanglebltr(transistor, generics.metal(sourcemetal),
                            point.create(straplefts2[sourcemetal], strapbottoms2[sourcemetal]),
                            point.create(straprights2[sourcemetal], straptops2[sourcemetal])
                        )
                    end
                end
                -- vias between start and end metal on source strap
                for sourcemetal = _P.sourcestartmetal, _P.sourceendmetal - 1 do
                    geometry.viabarebltr2(transistor, sourcemetal, sourcemetal + 1,
                        point.create(straplefts1[sourcemetal], strapbottoms1[sourcemetal]),
                        point.create(straprights1[sourcemetal], straptops1[sourcemetal]),
                        point.create(straplefts1[sourcemetal + 1], strapbottoms1[sourcemetal + 1]),
                        point.create(straprights1[sourcemetal + 1], straptops1[sourcemetal + 1])
                    )
                end
                if _P.connectsourceboth then
                    -- vias between start and end metal on other source strap
                    for sourcemetal = _P.sourcestartmetal, _P.sourceendmetal - 1 do
                        geometry.viabarebltr2(transistor, sourcemetal, sourcemetal + 1,
                            point.create(straplefts2[sourcemetal], strapbottoms2[sourcemetal]),
                            point.create(straprights2[sourcemetal], straptops2[sourcemetal]),
                            point.create(straplefts2[sourcemetal + 1], strapbottoms2[sourcemetal + 1]),
                            point.create(straprights2[sourcemetal + 1], straptops2[sourcemetal + 1])
                        )
                    end
                end
                -- additional vias to higher metal on source strap
                for sourcemetal = _P.sourceendmetal, _P.sourcestraptopmetal - 1 do
                    geometry.rectanglebltr(transistor, generics.metal(sourcemetal + 1),
                        point.create(straplefts1[sourcemetal + 1], strapbottoms1[sourcemetal + 1]),
                        point.create(straprights1[sourcemetal + 1], straptops1[sourcemetal + 1])
                    )
                    geometry.viabarebltr2(transistor, sourcemetal, sourcemetal + 1,
                        point.create(straplefts1[sourcemetal], strapbottoms1[sourcemetal]),
                        point.create(straprights1[sourcemetal], straptops1[sourcemetal]),
                        point.create(straplefts1[sourcemetal + 1], strapbottoms1[sourcemetal + 1]),
                        point.create(straprights1[sourcemetal + 1], straptops1[sourcemetal + 1])
                    )
                end
                -- additional vias to higher metal on other source strap
                if _P.connectsourceboth then
                    for sourcemetal = _P.sourceendmetal, _P.sourcestraptopmetal - 1 do
                        geometry.rectanglebltr(transistor, generics.metal(sourcemetal + 1),
                            point.create(straplefts2[sourcemetal + 1], strapbottoms2[sourcemetal + 1]),
                            point.create(straprights2[sourcemetal + 1], straptops2[sourcemetal + 1])
                        )
                        geometry.viabarebltr2(transistor, sourcemetal, sourcemetal + 1,
                            point.create(straplefts2[sourcemetal], strapbottoms2[sourcemetal]),
                            point.create(straprights2[sourcemetal], straptops2[sourcemetal]),
                            point.create(straplefts2[sourcemetal + 1], strapbottoms2[sourcemetal + 1]),
                            point.create(straprights2[sourcemetal + 1], straptops2[sourcemetal + 1])
                        )
                    end
                end
            end
            -- main anchor
            local shift = (_P.gatespace + sourcemetalwidths[_P.sourceendmetal]) / 2
            transistor:add_area_anchor_bltr("sourcestrap",
                point.create(straplefts1[_P.sourceendmetal], strapbottoms1[_P.sourceendmetal]),
                point.create(straprights1[_P.sourceendmetal], straptops1[_P.sourceendmetal])
            )
            if rawget(_P, "sourcenet") then
                transistor:mark_area_anchor_as_net("sourcestrap", _P.sourcenet, generics.metal(_P.sourcestraptopmetal))
                transistor:add_label(_P.sourcenet, generics.metal(_P.sourcestraptopmetal),
                    point.create(
                        0.5 * (transistor:get_area_anchor("sourcestrap").l + transistor:get_area_anchor("sourcestrap").r),
                        0.5 * (transistor:get_area_anchor("sourcestrap").b + transistor:get_area_anchor("sourcestrap").t)
                    ),
                    _P.netlabelsizehint
                )
            end
            if _P.connectsourceboth then
                -- other anchor
                transistor:add_area_anchor_bltr("othersourcestrap",
                    point.create(straplefts2[_P.sourceendmetal], strapbottoms2[_P.sourceendmetal]),
                    point.create(straprights2[_P.sourceendmetal], straptops2[_P.sourceendmetal])
                )
                if rawget(_P, "sourcenet") then
                    transistor:mark_area_anchor_as_net("othersourcestrap", _P.sourcenet, generics.metal(_P.sourcestraptopmetal))
                    transistor:add_label(_P.sourcenet, generics.metal(_P.sourcestraptopmetal),
                        point.create(
                            0.5 * (transistor:get_area_anchor("othersourcestrap").l + transistor:get_area_anchor("othersourcestrap").r),
                            0.5 * (transistor:get_area_anchor("othersourcestrap").b + transistor:get_area_anchor("othersourcestrap").t)
                        ),
                        _P.netlabelsizehint
                    )
                end
                if bly1 < bly2 then
                    transistor:add_area_anchor_bltr("uppersourcestrap",
                        point.create(blx - shift - leftext, bly2),
                        point.create(trx - shift + rightext + sourcemetalwidths[_P.sourceendmetal], bly2 + _P.connectsourcewidth)
                    )
                    transistor:add_area_anchor_bltr("lowersourcestrap",
                        point.create(blx - shift - leftext, bly1),
                        point.create(trx - shift + rightext + sourcemetalwidths[_P.sourceendmetal], bly1 + _P.connectsourcewidth)
                    )
                else
                    transistor:add_area_anchor_bltr("lowersourcestrap",
                        point.create(blx - shift - leftext, bly2),
                        point.create(trx - shift + rightext + sourcemetalwidths[_P.sourceendmetal], bly2 + _P.connectsourceotherwidth)
                    )
                    transistor:add_area_anchor_bltr("uppersourcestrap",
                        point.create(blx - shift - leftext, bly1),
                        point.create(trx - shift + rightext + sourcemetalwidths[_P.sourceendmetal], bly1 + _P.connectsourcewidth)
                    )
                end
            end
        end
    end

    -- drain connections
    if _P.drawdrainconnections and not _P.connectdraininline then
        -- connections to strap
        local draininvert = (_P.channeltype == "pmos")
        if _P.connectdraininverse then
            draininvert = not draininvert
        end
        for i = 2, _P.fingers + 1, 2 do
            local shift = gateblx - (_P.gatespace + _P.sdwidth) / 2 + (i - 1) * gatepitch
            local conndrainoffset = _P.drainstartmetal > 1 and drainviaoffset or drainoffset
            local conndraintop = _P.drainstartmetal > 1 and _P.drainviasize or _P.drainsize
            if draininvert then
                if -_P.connectdrainspace < conndrainoffset then -- don't draw connections if they are malformed
                    if not (i == 2 and not _P.drawfirstdrainvia or i == _P.fingers + 1 and not _P.drawlastdrainvia) then
                        if _P.restrictdrainmetalstostrap then
                            local extrashift = -drainmetalshifts[_P.drainviametal]
                            geometry.rectanglebltr(transistor, generics.metal(_P.drainviametal),
                                point.create(shift + extrashift, -_P.connectdrainspace),
                                point.create(shift + extrashift + drainmetalwidths[_P.drainviametal], conndrainoffset)
                            )
                        else
                            for drainmetal = _P.drainstartmetal, _P.drainendmetal do
                                local extrashift = -drainmetalshifts[drainmetal]
                                geometry.rectanglebltr(transistor, generics.metal(drainmetal),
                                    point.create(shift + extrashift, -_P.connectdrainspace),
                                    point.create(shift + extrashift + drainmetalwidths[drainmetal], conndrainoffset)
                                )
                            end
                        end
                    end
                end
                if _P.connectdrainboth then
                    if conndrainoffset + conndraintop < _P.fingerwidth + _P.connectdrainotherspace then -- don't draw connections if they are malformed
                       if not (i == 2 and not _P.drawfirstdrainvia or i == _P.fingers + 1 and not _P.drawlastdrainvia) then
                            if _P.restrictdrainmetalstostrap then
                                local extrashift = -drainmetalshifts[_P.drainviametal]
                                geometry.rectanglebltr(transistor, generics.metal(_P.drainviametal),
                                    point.create(shift + extrashift, conndrainoffset + conndraintop),
                                    point.create(shift + extrashift + drainmetalwidths[_P.drainviametal], _P.fingerwidth + _P.connectdrainotherspace)
                                )
                            else
                                for drainmetal = _P.drainstartmetal, _P.drainendmetal do
                                    local extrashift = -drainmetalshifts[drainmetal]
                                    geometry.rectanglebltr(transistor, generics.metal(drainmetal),
                                        point.create(shift + extrashift, conndrainoffset + conndraintop),
                                        point.create(shift + extrashift + drainmetalwidths[drainmetal], _P.fingerwidth + _P.connectdrainotherspace)
                                    )
                                end
                            end
                        end
                    end
                end
            else
                if conndrainoffset + conndraintop < _P.fingerwidth + _P.connectdrainspace then -- don't draw connections if they are malformed
                   if not (i == 2 and not _P.drawfirstdrainvia or i == _P.fingers + 1 and not _P.drawlastdrainvia) then
                        if _P.restrictdrainmetalstostrap then
                                local extrashift = -drainmetalshifts[_P.drainviametal]
                                geometry.rectanglebltr(transistor, generics.metal(_P.drainviametal),
                                    point.create(shift + extrashift, conndrainoffset + conndraintop),
                                    point.create(shift + extrashift + drainmetalwidths[_P.drainviametal], _P.fingerwidth + _P.connectdrainspace)
                                )
                        else
                            for drainmetal = _P.drainstartmetal, _P.drainendmetal do
                                local extrashift = -drainmetalshifts[drainmetal]
                                geometry.rectanglebltr(transistor, generics.metal(drainmetal),
                                    point.create(shift + extrashift, conndrainoffset + conndraintop),
                                    point.create(shift + extrashift + drainmetalwidths[drainmetal], _P.fingerwidth + _P.connectdrainspace)
                                )
                            end
                        end
                    end
                end
                if _P.connectdrainboth then
                    if -_P.connectdrainotherspace < conndrainoffset then -- don't draw connections if they are malformed
                        if not (i == 2 and not _P.drawfirstdrainvia or i == _P.fingers + 1 and not _P.drawlastdrainvia) then
                            if _P.restrictdrainmetalstostrap then
                                local extrashift = -drainmetalshifts[_P.drainviametal]
                                geometry.rectanglebltr(transistor, generics.metal(_P.drainviametal),
                                    point.create(shift + extrashift, -_P.connectdrainotherspace),
                                    point.create(shift + extrashift + drainmetalwidths[_P.drainviametal], conndrainoffset)
                                )
                            else
                                for drainmetal = _P.drainstartmetal, _P.drainendmetal do
                                    local extrashift = -drainmetalshifts[drainmetal]
                                    geometry.rectanglebltr(transistor, generics.metal(drainmetal),
                                        point.create(shift + extrashift, -_P.connectdrainotherspace),
                                        point.create(shift + extrashift + drainmetalwidths[drainmetal], conndrainoffset)
                                    )
                                end
                            end
                        end
                    end
                end
            end
        end
    end

    -- drain strap
    if _P.fingers > 0 then
        local blx, trx, leftext, rightext = _get_sdstrap_xbounds(_P, "drain", gateblx, gatepitch)
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
            -- per-metal strap extents, the bottom edge is kept fixed
            local strapwidths = drainstrapwidths
            local strapbottoms, straptops = _get_strap_yranges(strapwidths, bly, 1)
            local straplefts, straprights = _get_strap_xranges(drainmetalwidths, _P.drainstartmetal, _P.drainstraptopmetal, _P.gatespace, blx, trx, leftext, rightext, _P.connectdrainminwidth)
            if _P.drawdrainstrap then
                -- main strap
                for drainmetal = _P.drainstartmetal, _P.drainendmetal do
                    geometry.rectanglebltr(transistor, generics.metal(drainmetal),
                        point.create(straplefts[drainmetal], strapbottoms[drainmetal]),
                        point.create(straprights[drainmetal], straptops[drainmetal])
                    )
                end
                for drainmetal = _P.drainstartmetal, _P.drainendmetal - 1 do
                    geometry.viabarebltr2(transistor, drainmetal, drainmetal + 1,
                        point.create(straplefts[drainmetal], strapbottoms[drainmetal]),
                        point.create(straprights[drainmetal], straptops[drainmetal]),
                        point.create(straplefts[drainmetal + 1], strapbottoms[drainmetal + 1]),
                        point.create(straprights[drainmetal + 1], straptops[drainmetal + 1])
                    )
                end
                -- additional vias to higher metal on drain strap
                if _P.drainendmetal < _P.drainstraptopmetal then
                    for drainmetal = _P.drainendmetal, _P.drainstraptopmetal - 1 do
                        geometry.rectanglebltr(transistor, generics.metal(drainmetal + 1),
                            point.create(straplefts[drainmetal + 1], strapbottoms[drainmetal + 1]),
                            point.create(straprights[drainmetal + 1], straptops[drainmetal + 1])
                        )
                        geometry.viabarebltr2(transistor, drainmetal, drainmetal + 1,
                            point.create(straplefts[drainmetal], strapbottoms[drainmetal]),
                            point.create(straprights[drainmetal], straptops[drainmetal]),
                            point.create(straplefts[drainmetal + 1], strapbottoms[drainmetal + 1]),
                            point.create(straprights[drainmetal + 1], straptops[drainmetal + 1])
                        )
                    end
                end
            end
            transistor:add_area_anchor_bltr("drainstrap",
                point.create(straplefts[_P.drainendmetal], strapbottoms[_P.drainendmetal]),
                point.create(straprights[_P.drainendmetal], straptops[_P.drainendmetal])
            )
            if rawget(_P, "drainnet") then
                transistor:mark_area_anchor_as_net("drainstrap", _P.drainnet, generics.metal(_P.drainstraptopmetal))
                transistor:add_label(_P.drainnet, generics.metal(_P.drainstraptopmetal),
                    point.create(
                        0.5 * (transistor:get_area_anchor("drainstrap").l + transistor:get_area_anchor("drainstrap").r),
                        0.5 * (transistor:get_area_anchor("drainstrap").b + transistor:get_area_anchor("drainstrap").t)
                    ),
                    _P.netlabelsizehint
                )
            end
        else -- not _P.connectdraininline
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
            -- per-metal strap extents, the strap edges facing the device are kept fixed
            local strapwidths1 = drainstrapwidths
            local strapbottoms1, straptops1
            if bly1 < 0 then -- strap below the device
                strapbottoms1, straptops1 = _get_strap_yranges(strapwidths1, bly1 + _P.connectdrainwidth, -1)
            else
                strapbottoms1, straptops1 = _get_strap_yranges(strapwidths1, bly1, 1)
            end
            local strapwidths2 = drainotherstrapwidths
            local strapbottoms2, straptops2
            if bly2 < 0 then -- strap below the device
                strapbottoms2, straptops2 = _get_strap_yranges(strapwidths2, bly2 + _P.connectdrainotherwidth, -1)
            else
                strapbottoms2, straptops2 = _get_strap_yranges(strapwidths2, bly2, 1)
            end
            local straplefts1, straprights1 = _get_strap_xranges(drainmetalwidths, _P.drainstartmetal, _P.drainstraptopmetal, _P.gatespace, blx, trx, leftext, rightext, _P.connectdrainminwidth)
            local straplefts2, straprights2 = _get_strap_xranges(drainmetalwidths, _P.drainstartmetal, _P.drainstraptopmetal, _P.gatespace, blx, trx, _P.connectdrainotherleftext, _P.connectdrainotherrightext, _P.connectdrainotherminwidth)
            if _P.drawdrainstrap then
                -- main strap
                for drainmetal = _P.drainstartmetal, _P.drainendmetal do
                    geometry.rectanglebltr(transistor, generics.metal(drainmetal),
                        point.create(straplefts1[drainmetal], strapbottoms1[drainmetal]),
                        point.create(straprights1[drainmetal], straptops1[drainmetal])
                    )
                    if _P.connectdrainboth then
                        -- other strap
                        geometry.rectanglebltr(transistor, generics.metal(drainmetal),
                            point.create(straplefts2[drainmetal], strapbottoms2[drainmetal]),
                            point.create(straprights2[drainmetal], straptops2[drainmetal])
                        )
                    end
                end
                -- vias between start and end metal on drain strap
                for drainmetal = _P.drainstartmetal, _P.drainendmetal - 1 do
                    geometry.viabarebltr2(transistor, drainmetal, drainmetal + 1,
                        point.create(straplefts1[drainmetal], strapbottoms1[drainmetal]),
                        point.create(straprights1[drainmetal], straptops1[drainmetal]),
                        point.create(straplefts1[drainmetal + 1], strapbottoms1[drainmetal + 1]),
                        point.create(straprights1[drainmetal + 1], straptops1[drainmetal + 1])
                    )
                end
                if _P.connectdrainboth then
                    -- vias between start and end metal on other drain strap
                    for drainmetal = _P.drainstartmetal, _P.drainendmetal - 1 do
                        geometry.viabarebltr2(transistor, drainmetal, drainmetal + 1,
                            point.create(straplefts2[drainmetal], strapbottoms2[drainmetal]),
                            point.create(straprights2[drainmetal], straptops2[drainmetal]),
                            point.create(straplefts2[drainmetal + 1], strapbottoms2[drainmetal + 1]),
                            point.create(straprights2[drainmetal + 1], straptops2[drainmetal + 1])
                        )
                    end
                end
                -- additional vias to higher metal on drain strap
                if _P.drainendmetal < _P.drainstraptopmetal then
                    for drainmetal = _P.drainendmetal, _P.drainstraptopmetal - 1 do
                        geometry.rectanglebltr(transistor, generics.metal(drainmetal + 1),
                            point.create(straplefts1[drainmetal + 1], strapbottoms1[drainmetal + 1]),
                            point.create(straprights1[drainmetal + 1], straptops1[drainmetal + 1])
                        )
                        geometry.viabarebltr2(transistor, drainmetal, drainmetal + 1,
                            point.create(straplefts1[drainmetal], strapbottoms1[drainmetal]),
                            point.create(straprights1[drainmetal], straptops1[drainmetal]),
                            point.create(straplefts1[drainmetal + 1], strapbottoms1[drainmetal + 1]),
                            point.create(straprights1[drainmetal + 1], straptops1[drainmetal + 1])
                        )
                    end
                end
                if _P.connectdrainboth then
                    -- additional vias to higher metal on other drain strap
                    if _P.drainendmetal < _P.drainstraptopmetal then
                        for drainmetal = _P.drainendmetal, _P.drainstraptopmetal - 1 do
                            geometry.rectanglebltr(transistor, generics.metal(drainmetal + 1),
                                point.create(straplefts2[drainmetal + 1], strapbottoms2[drainmetal + 1]),
                                point.create(straprights2[drainmetal + 1], straptops2[drainmetal + 1])
                            )
                            geometry.viabarebltr2(transistor, drainmetal, drainmetal + 1,
                                point.create(straplefts2[drainmetal], strapbottoms2[drainmetal]),
                                point.create(straprights2[drainmetal], straptops2[drainmetal]),
                                point.create(straplefts2[drainmetal + 1], strapbottoms2[drainmetal + 1]),
                                point.create(straprights2[drainmetal + 1], straptops2[drainmetal + 1])
                            )
                        end
                    end
                end
            end
            -- main anchor
            local shift = (_P.gatespace + drainmetalwidths[_P.drainendmetal]) / 2
            transistor:add_area_anchor_bltr("drainstrap",
                point.create(straplefts1[_P.drainendmetal], strapbottoms1[_P.drainendmetal]),
                point.create(straprights1[_P.drainendmetal], straptops1[_P.drainendmetal])
            )
            if rawget(_P, "drainnet") then
                transistor:mark_area_anchor_as_net("drainstrap", _P.drainnet, generics.metal(_P.drainstraptopmetal))
                transistor:add_label(_P.drainnet, generics.metal(_P.drainstraptopmetal),
                    point.create(
                        0.5 * (transistor:get_area_anchor("drainstrap").l + transistor:get_area_anchor("drainstrap").r),
                        0.5 * (transistor:get_area_anchor("drainstrap").b + transistor:get_area_anchor("drainstrap").t)
                    ),
                    _P.netlabelsizehint
                )
            end
            -- other anchor
            if _P.connectdrainboth then
                transistor:add_area_anchor_bltr("otherdrainstrap",
                    point.create(straplefts2[_P.drainendmetal], strapbottoms2[_P.drainendmetal]),
                    point.create(straprights2[_P.drainendmetal], straptops2[_P.drainendmetal])
                )
                if rawget(_P, "drainnet") then
                    transistor:mark_area_anchor_as_net("otherdrainstrap", _P.drainnet, generics.metal(_P.drainstraptopmetal))
                    transistor:add_label(_P.drainnet, generics.metal(_P.drainstraptopmetal),
                        point.create(
                            0.5 * (transistor:get_area_anchor("otherdrainstrap").l + transistor:get_area_anchor("otherdrainstrap").r),
                            0.5 * (transistor:get_area_anchor("otherdrainstrap").b + transistor:get_area_anchor("otherdrainstrap").t)
                        ),
                        _P.netlabelsizehint
                    )
                end
                if bly1 < bly2 then
                    transistor:add_area_anchor_bltr("upperdrainstrap",
                        point.create(blx - shift - leftext, bly2),
                        point.create(trx - shift + rightext + drainmetalwidths[_P.drainendmetal], bly2 + _P.connectdrainwidth)
                    )
                    transistor:add_area_anchor_bltr("lowerdrainstrap",
                        point.create(blx - shift - leftext, bly1),
                        point.create(trx - shift + rightext + drainmetalwidths[_P.drainendmetal], bly1 + _P.connectdrainwidth)
                    )
                else
                    transistor:add_area_anchor_bltr("lowerdrainstrap",
                        point.create(blx - shift - leftext, bly2),
                        point.create(trx - shift + rightext + drainmetalwidths[_P.drainendmetal], bly2 + _P.connectdrainotherwidth)
                    )
                    transistor:add_area_anchor_bltr("upperdrainstrap",
                        point.create(blx - shift - leftext, bly1),
                        point.create(trx - shift + rightext + drainmetalwidths[_P.drainendmetal], bly1 + _P.connectdrainwidth)
                    )
                end
            end -- connect both drains
        end -- _P.connectdraininline
    end -- fingers > 0

    -- extra source/drain straps (unconnected, useful for arrays)
    local maxmetalextension = math.max(drainmetalwidths[_P.drainendmetal], sourcemetalwidths[_P.sourceendmetal])
    if _P.drawextrabotstrap then
        local blx = gateblx - (_P.gatespace + maxmetalextension) / 2 - _P.extrabotstrapleftextension + (_P.extrabotstrapleftalign - 1) * gatepitch
        local trx = gateblx - (_P.gatespace + maxmetalextension) / 2 + _P.extrabotstraprightextension + 2 * (_P.fingers // 2) * gatepitch + (_P.extrabotstraprightalign - _P.fingers) * gatepitch + maxmetalextension
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
        local blx = gateblx - (_P.gatespace + maxmetalextension) / 2 - _P.extratopstrapleftextension + (_P.extratopstrapleftalign - 1) * gatepitch
        local trx = gateblx - (_P.gatespace + maxmetalextension) / 2 + _P.extratopstraprightextension + 2 * (_P.fingers // 2) * gatepitch + (_P.extratopstraprightalign - _P.fingers) * gatepitch + maxmetalextension
        geometry.rectanglebltr(transistor, generics.metal(_P.extratopstrapmetal),
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
        -- present regions between the offsets
        local regions = {}
        for _, i in ipairs(sdcontacts.all) do
            if i >= 1 + _P.shortdeviceleftoffset and i <= _P.fingers + 1 - _P.shortdevicerightoffset then
                regions[#regions + 1] = i
            end
        end
        local first = regions[1]
        local last = regions[#regions]
        if _P.shortlocation == "inline" then
            if #regions > 1 then
                geometry.rectanglebltr(transistor, generics.metal(1),
                    transistor:get_area_anchor(string.format("sourcedrain%d", first)).br:translate(0, (_P.sourcesize - _P.shortwidth) / 2),
                    transistor:get_area_anchor(string.format("sourcedrain%d", last)).bl:translate(0, (_P.sourcesize + _P.shortwidth) / 2)
                )
            end
        elseif _P.shortlocation == "top" then
            if #regions > 0 then
                geometry.rectanglebltr(transistor, generics.metal(1),
                    transistor:get_area_anchor(string.format("sourcedrain%d", first)).tl:translate_y(_P.shortspace),
                    transistor:get_area_anchor(string.format("sourcedrain%d", last)).tr:translate_y(_P.shortspace + _P.shortwidth)
                )
            end
            for _, i in ipairs(regions) do
                geometry.rectanglebltr(transistor, generics.metal(1),
                    transistor:get_area_anchor(string.format("sourcedrain%d", i)).tl,
                    transistor:get_area_anchor(string.format("sourcedrain%d", i)).tr:translate_y(_P.shortspace)
                )
            end
        elseif _P.shortlocation == "bottom" then
            if #regions > 0 then
                geometry.rectanglebltr(transistor, generics.metal(1),
                    transistor:get_area_anchor(string.format("sourcedrain%d", first)).bl:translate_y(-_P.shortspace - _P.shortwidth),
                    transistor:get_area_anchor(string.format("sourcedrain%d", last)).br:translate_y(-_P.shortspace)
                )
            end
            for _, i in ipairs(regions) do
                geometry.rectanglebltr(transistor, generics.metal(1),
                    transistor:get_area_anchor(string.format("sourcedrain%d", i)).bl:translate_y(-_P.shortspace),
                    transistor:get_area_anchor(string.format("sourcedrain%d", i)).br
                )
            end
        else
            -- can not happen
        end
    end

    -- short source or drain regions to a gate strap: a bar on the gate strap (from the first to the last region,
    -- a single region is connected to the gate strap) and a connection from every region to the gate strap
    local function _short_to_gatestrap(regions, strapname, istop)
        if #regions == 0 then
            return
        end
        local strap = transistor:get_area_anchor(strapname)
        local first = transistor:get_area_anchor_fmt("sourcedrain%d", regions[1])
        local last = transistor:get_area_anchor_fmt("sourcedrain%d", regions[#regions])
        local barleft, barright
        if #regions > 1 then
            barleft, barright = first.l, last.r
        else
            barleft = math.min(first.l, strap.l)
            if first.r > strap.l then
                barright = first.r
            else
                barright = strap.r
            end
        end
        geometry.rectanglebltr(transistor, generics.metal(1),
            point.create(barleft, strap.b),
            point.create(barright, strap.t)
        )
        for _, i in ipairs(regions) do
            local region = transistor:get_area_anchor_fmt("sourcedrain%d", i)
            if istop then
                geometry.rectanglebltr(transistor, generics.metal(1),
                    region.tl,
                    point.create(region.r, strap.b)
                )
            else
                geometry.rectanglebltr(transistor, generics.metal(1),
                    point.create(region.l, strap.t),
                    region.br
                )
            end
        end
    end

    if _P.shortsourcegate then
        if _P.drawtopgate and _P.drawtopgatestrap then
            _short_to_gatestrap(sdcontacts.source, "topgatestrap", true)
        end
        if _P.drawbotgate and _P.drawbotgatestrap then
            _short_to_gatestrap(sdcontacts.source, "botgatestrap", false)
        end
    end

    if _P.shortdraingate then
        if _P.drawtopgate and _P.drawtopgatestrap then
            _short_to_gatestrap(sdcontacts.drain, "topgatestrap", true)
        end
        if _P.drawbotgate and _P.drawbotgatestrap then
            _short_to_gatestrap(sdcontacts.drain, "botgatestrap", false)
        end
    end

    -- guardring
    local guardring -- variable needs to be visible for alignment box setting
    if _P.drawguardring then
        -- hole sizes are calculated without seperations, these are added in the instatiation
        local holewidth = activetr:getx() - activebl:getx()
        local holeheight = activetr:gety() - activebl:gety()
        holewidth = holewidth + guardringleftext + guardringrightext
        holeheight = holeheight + guardringtopext + guardringbotext
        guardring = pcell.create_layout("auxiliary/guardring", "guardring", {
            contype = _P.flippedwell and (_P.channeltype == "nmos" and "n" or "p") or (_P.channeltype == "nmos" and "p" or "n"),
            ringwidth = _P.guardringwidth,
            holewidth = holewidth + _P.guardringleftsep + _P.guardringrightsep,
            holeheight = holeheight + _P.guardringtopsep + _P.guardringbottomsep,
            drawsegments = _P.guardringsegments,
            drawwell = _P.drawwell,
            fillwell = not _P.flippedwell or _P.guardringfillwell,
            fillinnerimplant = true,
            innerimplantpolarity = _P.channeltype == "nmos" and "n" or "p",
            drawoxidetype = _P.guardringdrawoxidetype,
            filloxidetype = _P.guardringfilloxidetype,
            oxidetype = _P.guardringoxidetype,
            wellinnerextension = _P.guardringwellinnerextension,
            wellouterextension = _P.guardringwellouterextension,
            implantinnerextension = _P.guardringimplantinnerextension,
            implantouterextension = _P.guardringimplantouterextension,
            oxidetypeinnerextension = _P.guardringoxidetypeinnerextension,
            oxidetypeouterextension = _P.guardringoxidetypeouterextension,
            soiopeninnerextension = _P.guardringsoiopeninnerextension,
            soiopenouterextension = _P.guardringsoiopenouterextension,
            -- nets
            net = _P.bulknet,
            addtopnet = _P.guardring_enable_horizontal_net_strips,
            addbottomnet = _P.guardring_enable_horizontal_net_strips,
            addleftnet = _P.guardring_enable_vertical_net_strips,
            addrightnet = _P.guardring_enable_vertical_net_strips,
        })
        local gtargetx = activebl:getx() - guardringleftext
        local gtargety = -guardringbotext
        guardring:move_point(guardring:get_area_anchor("innerboundary").bl, point.create(gtargetx, gtargety))
        guardring:translate(-_P.guardringleftsep, -_P.guardringbottomsep)
        transistor:merge_into(guardring)
        transistor:inherit_net_shapes(guardring)
        transistor:add_area_anchor_bltr("outerguardring",
            guardring:get_area_anchor("outerboundary").bl,
            guardring:get_area_anchor("outerboundary").tr
        )
        transistor:add_area_anchor_bltr("innerguardring",
            guardring:get_area_anchor("innerboundary").bl,
            guardring:get_area_anchor("innerboundary").tr
        )
        -- FIXME: very rudimentaty, does not check properly for source metals, location of source straps etc.
        if _P.connectguardringtosource then
            local target
            if _P.channeltype == "nmos" then
                if _P.connectsourceinverse then
                    target = "t"
                else
                    target = "b"
                end
            else -- "pmos"
                if _P.connectsourceinverse then
                    target = "b"
                else
                    target = "t"
                end
            end
            if _P.guardringconnectionmethod == "strap" then
                local sourceanchor = transistor:get_area_anchor("sourcestrap")
                geometry.rectanglepoints(transistor, generics.metal(_P.sourcestraptopmetal),
                    point.create(
                        0.5 * (sourceanchor.l + sourceanchor.r) - _P.connectsourcewidth / 2,
                        transistor:get_area_anchor("innerguardring")[target]
                    ),
                    point.create(
                        0.5 * (sourceanchor.l + sourceanchor.r) + _P.connectsourcewidth / 2,
                        sourceanchor[target]
                    )
                )
                if _P.sourcestraptopmetal > 1 then
                    geometry.viapoints(transistor, 1, _P.sourcestraptopmetal,
                        point.create(
                            0.5 * (sourceanchor.l + sourceanchor.r) - _P.connectsourcewidth / 2,
                            transistor:get_area_anchor("outerguardring")[target]
                        ),
                        point.create(
                            0.5 * (sourceanchor.l + sourceanchor.r) + _P.connectsourcewidth / 2,
                            transistor:get_area_anchor("innerguardring")[target]
                        )
                    )
                end
            else -- "individual"
                for _, i in ipairs(sdcontacts.source) do
                    local sourceanchor = transistor:get_area_anchor_fmt("sourcedrain%d", i)
                    geometry.rectanglepoints(transistor, generics.metal(1),
                        point.create(
                            sourceanchor.l,
                            transistor:get_area_anchor("innerguardring")[target]
                        ),
                        point.create(
                            sourceanchor.r,
                            sourceanchor[target]
                        )
                    )
                end
            end
        end
    end

    -- anchors for source drain active regions
    for i = 1, _P.fingers + 1 do
        local shift = gateblx - (_P.gatespace + _P.sdwidth) / 2 + (i - 1) * gatepitch
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
            point.create(gateblx - (_P.gatespace + _P.sdwidth) / 2, 0),
            point.create(gateblx - (_P.gatespace + _P.sdwidth) / 2 + (_P.fingers + 1 - 1) * gatepitch, _P.fingerwidth),
            point.create(gateblx - (_P.gatespace + _P.sdwidth) / 2 + _P.sdwidth, 0),
            point.create(gateblx - (_P.gatespace + _P.sdwidth) / 2 + (_P.fingers + 1 - 1) * gatepitch + _P.sdwidth, _P.fingerwidth)
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

    -- pins
    -- FIXME: implement add_pin_from_area_anchor
    if _P.fingers > 0 then
        -- prioritize top gate strap if both are present
        -- FIXME: this does not really make sense, but pins are just new as I'm writing this comment
        if _P.drawtopgatestrap then
            transistor:inherit_area_anchor_as(transistor, "topgatestrap", "gate")
            --transistor:add_pin_from_area_anchor("gate", "topgatestrap")
        elseif _P.drawbotgatestrap then
            transistor:inherit_area_anchor_as(transistor, "botgatestrap", "gate")
            --transistor:add_pin_from_area_anchor("gate", "botgatestrap")
        end
        if _P.drawdrainstrap then
            transistor:inherit_area_anchor_as(transistor, "drainstrap", "drain")
            --transistor:add_pin_from_area_anchor("drain", "drainstrap")
        end
        if _P.drawsourcestrap then
            transistor:inherit_area_anchor_as(transistor, "sourcestrap", "source")
            --transistor:add_pin_from_area_anchor("source", "sourcestrap")
        end
    end

    -- instance name (uses the active region coordinates, the 'active' anchor only exists with 'drawactive')
    if rawget(_P, "instancename") then
        local pt
        if _P.instancenameincenter then
            pt = point.create(
                0.5 * (activebl:getx() + activetr:getx()),
                0.5 * (activebl:gety() + activetr:gety())
            )
        else
            pt = activebl:copy()
        end
        transistor:add_label(
            _P.instancename,
            generics.other("text"),
            pt,
            _P.instancelabelsizehint
        )
    end

    -- instance box
    if _P.drawinstancebox then
        if _P.instancebox_includeguardring and _P.drawguardring then
            geometry.rectanglebltr(transistor, generics.other("text"),
                transistor:get_area_anchor("outerguardring").bl,
                transistor:get_area_anchor("outerguardring").tr
            )
        else
            geometry.rectanglebltr(transistor, generics.other("text"),
                activebl,
                activetr
            )
        end
    end
end

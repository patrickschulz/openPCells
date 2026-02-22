return {
    outline = {
        name = "_outline",
        layer = {
            gds = { layer = 255, purpose = 255 },
            SKILL = { layer = "_outline", purpose = "drawing" },
            debug = { layer = "_outline" },
        }
    },
    special = {
        name = "_special",
        layer = {
            gds = { layer = 0, purpose = 0 },
            SKILL = { layer = "_special", purpose = "drawing" },
            debug = { layer = "_special" },
        }
    },
    text = {
        name = "text",
        layer = {
            gds = { layer = 234, purpose = 0 },
            SKILL = { layer = "text", purpose = "drawing" },
            debug = { layer = "text" },
            json = { layer = "text" },
        }
    },
    active = {
        name = "active",
        layer = {
            gds = { layer = 1, purpose = 0 },
            SKILL = { layer = "active", purpose = "drawing" },
            debug = { layer = "active" },
            svg = { style = "active", order = 2, color = "38c316" },
            json = { layer = "active" },
        }
    },
    nwell = {
        name = "nwell",
        layer = {
            gds = { layer = 3, purpose = 0 },
            SKILL = { layer = "nwell", purpose = "drawing" },
            debug = { layer = "nwell" },
            svg = { color = "ccffff", order = 1, nooutline = true },
            json = { layer = "nwell" },
        }
    },
    deepnwell = {
        name = "deepnwell",
        layer = {
            gds = { layer = 33, purpose = 0 },
            SKILL = { layer = "deepnwell", purpose = "drawing" },
            debug = { layer = "deepnwell" },
            svg = { color = "ccffff", order = 1 },
            json = { layer = "deepnwell" },
        }
    },
    pimplant = {
        name = "pimplant",
        layer = {
            gds = { layer = 4, purpose = 0 },
            SKILL = { layer = "pimplant", purpose = "drawing" },
            debug = { layer = "pimplant" },
            svg = { color = "333333", ignore = true },
            json = { layer = "pimplant" },
        }
    },
    nimplant = {
        name = "nimplant",
        layer = {
            gds = { layer = 5, purpose = 0 },
            SKILL = { layer = "nimplant", purpose = "drawing" },
            debug = { layer = "nimplant" },
            svg = { color = "333333", ignore = true },
            json = { layer = "nimplant" },
        }
    },
    gate = {
        name = "poly",
        layer = {
            gds = { layer = 6, purpose = 0 },
            SKILL = { layer = "poly", purpose = "drawing" },
            debug = { layer = "poly" },
            svg = { style = "gate", order = 3, color = "ff0000" },
            json = { layer = "gate" },
        }
    },
    contactactive = {
        name = "contactactive",
        layer = {
            gds = { layer = 7, purpose = 0 },
            SKILL = { layer = "contactactive", purpose = "drawing" },
            debug = { layer = "contactactive" },
            svg = { style = "contactactive", order = 5, color = "ffff00" },
            json = { layer = "contactactive" },
        }
    },
    contactsourcedrain = {
        name = "contactsourcedrain",
        layer = {
            gds = { layer = 7, purpose = 0 },
            SKILL = { layer = "contactsourcedrain", purpose = "drawing" },
            debug = { layer = "contactsourcedrain" },
            svg = { style = "contactsourcedrain", order = 5, color = "ffff00" },
            json = { layer = "contactsourcedrain" },
        }
    },
    contactgate = {
        name = "contactgate",
        layer = {
            gds = { layer = 7, purpose = 0 },
            SKILL = { layer = "contactgate", purpose = "drawing" },
            debug = { layer = "contactgate" },
            svg = { style = "contactgate", order = 5, color = "ffffff" },
            json = { layer = "contactgate" },
        }
    },
    M1 = {
        name = "metal1",
        layer = {
            gds = { layer = 8, purpose = 0 },
            SKILL = { layer = "metal1", purpose = "drawing" },
            debug = { layer = "metal1" },
            svg = { style = "metal1", order = 4, color = "0000ff" },
            json = { layer = "M1" },
        }
    },
    M1exclude = {},
    viacutM1M2 = {
        name = "via1",
        layer = {
            gds = { layer = 9, purpose = 0 },
            SKILL = { layer = "via1", purpose = "drawing" },
            debug = { layer = "via1" },
            svg = { style = "via1", order = 7, color = "fff000" },
            json = { layer = "viacutM1M2" },
        }
    },
    M2 = {
        name = "metal2",
        layer = {
            gds = { layer = 10, purpose = 0 },
            SKILL = { layer = "metal2", purpose = "drawing" },
            debug = { layer = "metal2" },
            svg = { style = "metal2", order = 6, color = "ff00ff" },
            json = { layer = "M2" },
        }
    },
    M2exclude = {},
    viacutM2M3 = {
        name = "via2",
        layer = {
            gds = { layer = 11, purpose = 0 },
            SKILL = { layer = "via2", purpose = "drawing" },
            debug = { layer = "via2" },
            svg = { color = "ff1212" },
            json = { layer = "viacutM2M3" },
        }
    },
    M3 = {
        name = "metal3",
        layer = {
            gds = { layer = 12, purpose = 0 },
            SKILL = { layer = "metal3", purpose = "drawing" },
            debug = { layer = "metal3" },
            svg = { color = "ff1212", order = 8 },
            json = { layer = "M3" },
        }
    },
    M3exclude = {},
    viacutM3M4 = {
        name = "via3",
        layer = {
            gds = { layer = 13, purpose = 0 },
            SKILL = { layer = "via3", purpose = "drawing" },
            debug = { layer = "via3" },
            svg = { color = "ffffff" },
        }
    },
    M4 = {
        name = "metal4",
        layer = {
            gds = { layer = 14, purpose = 0 },
            SKILL = { layer = "metal4", purpose = "drawing" },
            debug = { layer = "metal4" },
            svg = { color = "808080" },
        }
    },
    M4exclude = {},
    viacutM4M5 = {
        name = "via4",
        layer = {
            gds = { layer = 15, purpose = 0 },
            SKILL = { layer = "via4", purpose = "drawing" },
            debug = { layer = "via4" },
            svg = { color = "ffffff" },
        }
    },
    M5 = {
        name = "metal5",
        layer = {
            gds = { layer = 16, purpose = 0 },
            SKILL = { layer = "metal5", purpose = "drawing" },
            debug = { layer = "metal5" },
            svg = { color = "0080ff" },
        }
    },
    M5exclude = {},
    viacutM5M6 = {
        name = "via5",
        layer = {
            gds = { layer = 17, purpose = 0 },
            SKILL = { layer = "via5", purpose = "drawing" },
            debug = { layer = "via5" },
            svg = { color = "ffffff" },
        }
    },
    M6 = {
        name = "metal6",
        layer = {
            gds = { layer = 18, purpose = 0 },
            SKILL = { layer = "metal6", purpose = "drawing" },
            debug = { layer = "metal6" },
            svg = { color = "ff0000" },
        }
    },
    M6exclude = {},
    viacutM6M7 = {
        name = "via6",
        layer = {
            gds = { layer = 19, purpose = 0 },
            SKILL = { layer = "via6", purpose = "drawing" },
            debug = { layer = "via6" },
            svg = { color = "ffffff" },
        }
    },
    M7 = {
        name = "metal7",
        layer = {
            gds = { layer = 20, purpose = 0 },
            SKILL = { layer = "metal7", purpose = "drawing" },
            debug = { layer = "metal7" },
            svg = { color = "8000ff" },
        }
    },
    M7exclude = {},
    viacutM7M8 = {
        name = "via7",
        layer = {
            gds = { layer = 21, purpose = 0 },
            SKILL = { layer = "via7", purpose = "drawing" },
            debug = { layer = "via7" },
            svg = { color = "ffffff" },
        }
    },
    M8 = {
        name = "metal8",
        layer = {
            gds = { layer = 22, purpose = 0 },
            SKILL = { layer = "metal8", purpose = "drawing" },
            debug = { layer = "metal8" },
            svg = { color = "008000" },
        }
    },
    M8exclude = {},
    viacutM8M9 = {
        name = "via8",
        layer = {
            gds = { layer = 23, purpose = 0 },
            SKILL = { layer = "via8", purpose = "drawing" },
            debug = { layer = "via8" },
            svg = { color = "ffffff" },
        }
    },
    M9 = {
        name = "metal9",
        layer = {
            gds = { layer = 24, purpose = 0 },
            SKILL = { layer = "metal9", purpose = "drawing" },
            debug = { layer = "metal9" },
            svg = { color = "ff00ff" },
        }
    },
    M9exclude = {},
    viacutM9M10 = {
        name = "via9",
        layer = {
            gds = { layer = 25, purpose = 0 },
            SKILL = { layer = "via9", purpose = "drawing" },
            debug = { layer = "via9" },
            svg = { color = "ffffff" },
        }
    },
    M10 = {
        name = "metal10",
        layer = {
            gds = { layer = 26, purpose = 0 },
            SKILL = { layer = "metal10", purpose = "drawing" },
            debug = { layer = "metal10" },
            svg = { color = "8000ff" },
        }
    },
    M10exclude = {},
    -- ports
    M1port = {
        name = "metal1port",
        layer = {
            gds = { layer = 8, purpose = 1 },
            SKILL = { layer = "metal1", purpose = "label" },
            debug = { layer = "metal1" },
            svg = { style = "metal1", order = 4, color = "0000ff" },
        }
    },
    M2port = {
        name = "metal2port",
        layer = {
            gds = { layer = 10, purpose = 1 },
            SKILL = { layer = "metal2", purpose = "label" },
            debug = { layer = "metal2" },
            svg = { style = "metal2", order = 6, color = "bb0077" },
        }
    },
    M3port = {
        name = "metal3port",
        layer = {
            gds = { layer = 12, purpose = 1 },
            SKILL = { layer = "metal3", purpose = "label" },
            debug = { layer = "metal3" },
            svg = { style = "metal3", color = "ff1212" },
        }
    },
    M4port = {
        name = "metal4port",
        layer = {
            gds = { layer = 14, purpose = 1 },
            SKILL = { layer = "metal4", purpose = "label" },
            debug = { layer = "metal4" },
            svg = { style = "metal4", color = "808080" },
        }
    },
    M5port = {
        name = "metal5port",
        layer = {
            gds = { layer = 16, purpose = 1 },
            SKILL = { layer = "metal5", purpose = "label" },
            debug = { layer = "metal5" },
            svg = { style = "metal5", color = "0080ff" },
        }
    },
    M6port = {
        name = "metal6port",
        layer = {
            gds = { layer = 18, purpose = 1 },
            SKILL = { layer = "metal6", purpose = "label" },
            debug = { layer = "metal6" },
            svg = { style = "metal6", color = "ff0000" },
        }
    },
    M7port = {
        name = "metal7port",
        layer = {
            gds = { layer = 20, purpose = 1 },
            SKILL = { layer = "metal7", purpose = "label" },
            debug = { layer = "metal7" },
            svg = { style = "metal7", color = "8000ff" },
        }
    },
    M8port = {
        name = "metal8port",
        layer = {
            gds = { layer = 22, purpose = 1 },
            SKILL = { layer = "metal8", purpose = "label" },
            debug = { layer = "metal8" },
            svg = { style = "metal8", color = "008000" },
        }
    },
    M9port = {
        name = "metal9port",
        layer = {
            gds = { layer = 24, purpose = 1 },
            SKILL = { layer = "metal9", purpose = "label" },
            debug = { layer = "metal9" },
            svg = { style = "metal9", color = "ff00ff" },
        }
    },
    M10port = {
        name = "metal10port",
        layer = {
            gds = { layer = 26, purpose = 1 },
            SKILL = { layer = "metal10", purpose = "label" },
            debug = { layer = "metal10" },
            svg = { style = "metal10", color = "8000ff" },
        }
    },
    nwellport = {
        name = "nwellport",
        layer = {
            gds = { layer = 3, purpose = 1 },
            SKILL = { layer = "nwell", purpose = "label" },
            debug = { layer = "nwell" },
            svg = { color = "ccffff", order = 1 },
        }
    },
    gatecut = {
        name = "gatecut",
        layer = {
            gds = { layer = 27, purpose = 0 },
            SKILL = { layer = "gatecut", purpose = "drawing" },
            debug = { layer = "gatecut" },
            svg = { color = "8000ff", order = 1 },
        }
    },
    silicideblocker = {
        name = "silicideblocker",
        layer = {
            gds = { layer = 28, purpose = 0 },
            SKILL = { layer = "silicideblocker", purpose = "drawing" },
            debug = { layer = "silicideblocker" },
            svg = { color = "ffffff", order = 1 },
        },
    },
    -- unused layers
    oxide1 = {},
    oxide2 = {},
    gatemarker1 = {},
    vthtypen1 = {},
    vthtypen2 = {},
    vthtypen3 = {},
    vthtypen4 = {},
    vthtypen5 = {},
    vthtypep1 = {},
    vthtypep2 = {},
    vthtypep3 = {},
    vthtypep4 = {},
    vthtypep5 = {},
    mosfetmarker1 = {},
    lvsmarker1 = {},
    lvsmarker2 = {},
    pwell = {},
    deeppwell = {},
    soiopen = {},
    tuckgatemarker = {},
    padopening = {},
    polyres = {},
    nres = {},
    pwellport = {},
    diffusionbreakgate = {},
    inductormarker = {},
    inductorlvsmarker = {},
    subblock = {},
    rotationmarker = {},
    polyresistorlvsmarker1 = {},
}

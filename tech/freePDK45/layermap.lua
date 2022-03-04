return {
    special = {
        name = "_special",
        layer = {
            gds   = { layer = 235,        purpose = 235 },
            SKILL = { layer = "OUTLINE",  purpose = "drawing" },
            magic = { layer = "_special", purpose = "drawing" },
        },
    },
    soiopen = {},
    pimplant = {
        name = "pimplant",
        layer = {
            gds   = { layer = 5,          purpose = 0 },
            SKILL = { layer = "pimplant", purpose = "drawing" },
            magic = { layer = "pimplant", purpose = "drawing" },
        }
    },
    nimplant = {
        name = "nimplant",
        layer = {
            gds   = { layer = 4,       purpose = 0 },
            SKILL = { layer = "NPLUS", purpose = "drawing" },
            magic = { layer = "NPLUS", purpose = "drawing" },
        }
    },
    pwell = {
        name = "pwell",
        layer = {
            gds   = { layer = 2,       purpose = 0 },
            SKILL = { layer = "pwell", purpose = "drawing" },
            magic = { layer = "pwell", purpose = "drawing" },
        }
    },
    nwell = {
        name = "nwell",
        layer = {
            gds   = { layer = 3,       purpose = 0 },
            SKILL = { layer = "nwell", purpose = "drawing" },
            magic = { layer = "nwell", purpose = "drawing" },
        }
    },
    oxide1 = {},
    vthtypen1 = {},
    vthtypep1 = {},
    deeppwell = {},
    deepnwell = {},
    active = {
        name = "active",
        layer = {
            gds   = { layer = 1,        purpose = 0 },
            SKILL = { layer = "active", purpose = "drawing" },
            magic = { layer = "active", purpose = "drawing" },
            svg   = { color = "rgb(0, 204, 102)", opacity = 1.0, fill = true, order = 3 },
        },
    },
    gate = {
        name = "poly",
        layer = {
            gds   = { layer =    9,   purpose =         0 },
            SKILL = { layer = "poly", purpose = "drawing" },
            magic = { layer = "poly", purpose = "drawing" },
            svg   = { color = "rgb(255, 0, 0)", opacity = 1.0, fill = true, order = 3 },
        },
    },
    gatecut = {},
    tuckgatemarker = {},
    contactactive = {
        name = "contact",
        layer = {
            gds   = { layer = 10,    purpose = 0 },
            SKILL = { layer = "contact" , purpose = "drawing" },
            magic = { layer = "contact" , purpose = "drawing" },
            svg   = { color = "yellow", opacity = 1.0, fill = true, order = 6 },
        },
    },
    contactsourcedrain = {
        name = "contact",
        layer = {
            gds   = { layer = 10,    purpose = 0 },
            SKILL = { layer = "contact" , purpose = "drawing" },
            magic = { layer = "contact" , purpose = "drawing" },
            svg   = { color = "yellow", opacity = 1.0, fill = true, order = 6 },
        },
    },
    contactgate = {
        name = "contact",
        layer = {
            gds   = { layer = 10,    purpose = 0 },
            SKILL = { layer = "contact" , purpose = "drawing" },
            magic = { layer = "contact" , purpose = "drawing" },
            svg   = { color = "yellow", opacity = 1.0, fill = true, order = 6 },
        },
    },
    M1 = {
        name = "metal1",
        layer = {
            gds   = { layer = 11,       purpose = 0 },
            SKILL = { layer = "metal1", purpose = "drawing" },
            magic = { layer = "metal1", purpose = "drawing" },
            svg   = { color = "blue", opacity = 1.0, fill = true, order = 5 },
        }
    },
    M2 = {
        name = "metal2",
        layer = {
            gds   = { layer = 13,   purpose = 0 },
            SKILL = { layer = "metal2", purpose = "drawing" },
            magic = { layer = "metal2", purpose = "drawing" },
            svg   = { color = "rgb(255, 0, 255)", opacity = 0.5, fill = true, order = 6 },
        }
    },
    M3 = {
        name = "metal3",
        layer = {
            gds   = { layer = 15,       purpose = 0 },
            SKILL = { layer = "metal3", purpose = "drawing" },
            magic = { layer = "metal3", purpose = "drawing" },
        }
    },
    M4 = {
        name = "metal4",
        layer = {
            gds   = { layer = 17,       purpose = 0 },
            SKILL = { layer = "metal4", purpose = "drawing" },
            magic = { layer = "metal4", purpose = "drawing" },
        }
    },
    M5 = {
        name = "metal5",
        layer = {
            gds   = { layer = 19,       purpose = 0 },
            SKILL = { layer = "metal5", purpose = "drawing" },
            magic = { layer = "metal5", purpose = "drawing" },
        }
    },
    M6 = {
        name = "metal6",
        layer = {
            gds   = { layer = 21,       purpose = 0 },
            SKILL = { layer = "metal6", purpose = "drawing" },
            magic = { layer = "metal6", purpose = "drawing" },
        }
    },
    M7 = {
        name = "metal7",
        layer = {
            gds   = { layer = 23,       purpose = 0 },
            SKILL = { layer = "metal7", purpose = "drawing" },
            magic = { layer = "metal7", purpose = "drawing" },
        }
    },
    M8 = {
        name = "metal8",
        layer = {
            gds   = { layer = 25,       purpose = 0 },
            SKILL = { layer = "metal8", purpose = "drawing" },
            magic = { layer = "metal8", purpose = "drawing" },
        }
    },
    M9 = {
        name = "metal9",
        layer = {
            gds   = { layer = 27,       purpose = 0 },
            SKILL = { layer = "metal9", purpose = "drawing" },
            magic = { layer = "metal9", purpose = "drawing" },
        }
    },
    M10 = {
        name = "metal10",
        layer = {
            gds   = { layer = 29,       purpose = 0 },
            SKILL = { layer = "metal10", purpose = "drawing" },
            magic = { layer = "metal10", purpose = "drawing" },
        }
    },
    viacutM1M2 = {
        name = "via1",
        layer = {
            gds   = { layer =   12,    purpose = 0 },
            SKILL = { layer = "via1" , purpose = "drawing" },
            magic = { layer = "via1" , purpose = "drawing" },
        },
    },
    --[[
    M1port = {
        name = "M1port",
        layer = {
            gds   = { layer = 11,   purpose = 2 },
            SKILL = { layer = "M1", purpose = "label" },
            magic = { layer = "M1", purpose = "label" },
            svg   = { color = "blue", opacity = 1.0, fill = true, order = 5 },
        }
    },
    --]]
    padopening = {}
}

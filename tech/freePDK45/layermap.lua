return {
    special = {
        map {
            name = "_special",
            lpp = {
                gds   = { layer = 235,        purpose = 235 },
                SKILL = { layer = "OUTLINE",  purpose = "drawing" },
                magic = { layer = "_special", purpose = "drawing" },
            },
        },
    },
    soiopen = {},
    pimpl = {
        map {
            name = "pimplant",
            lpp = {
                gds   = { layer = 5,          purpose = 0 },
                SKILL = { layer = "pimplant", purpose = "drawing" },
                magic = { layer = "pimplant", purpose = "drawing" },
            }
        }
    },
    nimpl = {
        map {
            name = "nimplant",
            lpp = {
                gds   = { layer = 4,       purpose = 0 },
                SKILL = { layer = "NPLUS", purpose = "drawing" },
                magic = { layer = "NPLUS", purpose = "drawing" },
            }
        }
    },
    pwell = {
        map {
            name = "pwell",
            lpp = {
                gds   = { layer = 2,       purpose = 0 },
                SKILL = { layer = "pwell", purpose = "drawing" },
                magic = { layer = "pwell", purpose = "drawing" },
            }
        }
    },
    nwell = {
        map {
            name = "nwell",
            lpp = {
                gds   = { layer = 3,       purpose = 0 },
                SKILL = { layer = "nwell", purpose = "drawing" },
                magic = { layer = "nwell", purpose = "drawing" },
            }
        }
    },
    deeppwell = {},
    deepnwell = {},
    feol = {
        map(function(settings) -- well
            local lut = {
                nmos = {
                    name = "pwell",
                    lpp = {
                        gds   = { layer = 2,       purpose = 0 },
                        SKILL = { layer = "pwell", purpose = "drawing" },
                        magic = { layer = "pwell", purpose = "drawing" },
                    }
                },
                pmos = {
                    name = "nwell",
                    lpp = {
                        gds   = { layer = 3,       purpose = 0 },
                        SKILL = { layer = "nwell", purpose = "drawing" },
                        magic = { layer = "nwell", purpose = "drawing" },
                    }
                },
            }
            return {
                name = lut[settings.channeltype].name,
                lpp = lut[settings.channeltype].lpp,
                left   = 55,
                right  = 55,
                top    = settings.expand.top and 55 or 0,
                bottom = settings.expand.bottom and 55 or 0,
            }
        end),
    },
    active = {
        map { -- active
            name = "active",
            lpp = {
                gds   = { layer = 1,        purpose = 0 },
                SKILL = { layer = "active", purpose = "drawing" },
                magic = { layer = "active", purpose = "drawing" },
                svg   = { color = "rgb(0, 204, 102)", opacity = 1.0, fill = true, order = 3 },
            },
        },
    },
    gate = {
        map { -- poly silicon
            name = "poly",
            lpp = {
                gds   = { layer =    9,   purpose =         0 },
                SKILL = { layer = "poly", purpose = "drawing" },
                magic = { layer = "poly", purpose = "drawing" },
                svg   = { color = "rgb(255, 0, 0)", opacity = 1.0, fill = true, order = 3 },
            },
        },
    },
    gatecut = {},
    tuckgatemarker = {},
    contactactive = {
        array {
            name = "contact",
            lpp = {
                gds   = { layer = 10,    purpose = 0 },
                SKILL = { layer = "contact" , purpose = "drawing" },
                magic = { layer = "contact" , purpose = "drawing" },
                svg   = { color = "yellow", opacity = 1.0, fill = true, order = 6 },
            },
            width = 65,
            height = 65,
            xspace = 75,
            yspace = 75,
            xencl = 35,
            yencl = 35
        },
    },
    contactsourcedrain = {
        array {
            name = "contact",
            lpp = {
                gds   = { layer = 10,    purpose = 0 },
                SKILL = { layer = "contact" , purpose = "drawing" },
                magic = { layer = "contact" , purpose = "drawing" },
                svg   = { color = "yellow", opacity = 1.0, fill = true, order = 6 },
            },
            width = 65,
            height = 65,
            xspace = 75,
            yspace = 75,
            xencl = 0,
            yencl = 0
        },
    },
    contactgate = {
        array {
            name = "contact",
            lpp = {
                gds   = { layer = 10,    purpose = 0 },
                SKILL = { layer = "contact" , purpose = "drawing" },
                magic = { layer = "contact" , purpose = "drawing" },
                svg   = { color = "yellow", opacity = 1.0, fill = true, order = 6 },
            },
            width = 65,
            height = 65,
            xspace = 75,
            yspace = 75,
            xencl = 35,
            yencl = 35,
            fallback = { width = 65, height = 65 }
        },
    },
    M1 = {
        map {
            name = "metal1",
            lpp = {
                gds   = { layer = 11,       purpose = 0 },
                SKILL = { layer = "metal1", purpose = "drawing" },
                magic = { layer = "metal1", purpose = "drawing" },
                svg   = { color = "blue", opacity = 1.0, fill = true, order = 5 },
            }
        }
    },
    M2 = {
        map {
            name = "metal2",
            lpp = {
                gds   = { layer = 13,   purpose = 0 },
                SKILL = { layer = "metal2", purpose = "drawing" },
                magic = { layer = "metal2", purpose = "drawing" },
                svg   = { color = "rgb(255, 0, 255)", opacity = 0.5, fill = true, order = 6 },
            }
        }
    },
    M3 = {
        map {
            name = "metal3",
            lpp = {
                gds   = { layer = 15,       purpose = 0 },
                SKILL = { layer = "metal3", purpose = "drawing" },
                magic = { layer = "metal3", purpose = "drawing" },
            }
        }
    },
    M4 = {
        map {
            name = "metal4",
            lpp = {
                gds   = { layer = 17,       purpose = 0 },
                SKILL = { layer = "metal4", purpose = "drawing" },
                magic = { layer = "metal4", purpose = "drawing" },
            }
        }
    },
    M5 = {
        map {
            name = "metal5",
            lpp = {
                gds   = { layer = 19,       purpose = 0 },
                SKILL = { layer = "metal5", purpose = "drawing" },
                magic = { layer = "metal5", purpose = "drawing" },
            }
        }
    },
    M6 = {
        map {
            name = "metal6",
            lpp = {
                gds   = { layer = 21,       purpose = 0 },
                SKILL = { layer = "metal6", purpose = "drawing" },
                magic = { layer = "metal6", purpose = "drawing" },
            }
        }
    },
    M7 = {
        map {
            name = "metal7",
            lpp = {
                gds   = { layer = 23,       purpose = 0 },
                SKILL = { layer = "metal7", purpose = "drawing" },
                magic = { layer = "metal7", purpose = "drawing" },
            }
        }
    },
    M8 = {
        map {
            name = "metal8",
            lpp = {
                gds   = { layer = 25,       purpose = 0 },
                SKILL = { layer = "metal8", purpose = "drawing" },
                magic = { layer = "metal8", purpose = "drawing" },
            }
        }
    },
    M9 = {
        map {
            name = "metal9",
            lpp = {
                gds   = { layer = 27,       purpose = 0 },
                SKILL = { layer = "metal9", purpose = "drawing" },
                magic = { layer = "metal9", purpose = "drawing" },
            }
        }
    },
    M10 = {
        map {
            name = "metal10",
            lpp = {
                gds   = { layer = 29,       purpose = 0 },
                SKILL = { layer = "metal10", purpose = "drawing" },
                magic = { layer = "metal10", purpose = "drawing" },
            }
        }
    },
    viaM1M2 = {
        array {
            name = "via1",
            lpp = {
                gds   = { layer =   12,    purpose = 0 },
                SKILL = { layer = "via1" , purpose = "drawing" },
                magic = { layer = "via1" , purpose = "drawing" },
            },
            width        = {    40,    40,    80,    40 },
            height       = {    40,    40,    40,    80 },
            xspace       = {    94,    94,   114,   114 },
            yspace       = {    94,    94,   114,   114 },
            xencl        = {     0,    30,    40,    40 },
            yencl        = {    30,     0,    40,    40 },
            conductivity = {     1,     1,     2,     2 },
            noneedtofit  = { false, false, false, false },
            fallback = { width = 40, height = 40 },
        }
    },
    M1port = {
        map {
            name = "M1port",
            lpp = {
                gds   = { layer = 11,   purpose = 2 },
                SKILL = { layer = "M1", purpose = "label" },
                magic = { layer = "M1", purpose = "label" },
                svg   = { color = "blue", opacity = 1.0, fill = true, order = 5 },
            }
        }
    },
    padopening = {}
}

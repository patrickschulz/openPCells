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
    --[[
    soiopen = {
        map {
            name = "HYBRID",
            lpp = {
                gds   = { layer = 800,      purpose = 11 },
                SKILL = { layer = "HYBRID", purpose = "drawing" },
                magic = { layer = "HYBRID", purpose = "drawing" },
            }
        }
    },
    --]]
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
        --[[
        map(function(settings) -- threshold voltage
            local lut = {
                nmos = {
                    [1] = { -- slvtn
                        name = "SLVTN",
                        lpp = {
                            gds   = { layer = 212,     purpose = 52        },
                            SKILL = { layer = "SLVTN", purpose = "drawing" },
                            magic = { layer = "SLVTN", purpose = "drawing" },
                        }
                    },
                    [2] = { -- lvtn
                        name = "LVTN",
                        lpp = {
                            gds   = { layer = 780,    purpose = 11        },
                            SKILL = { layer = "LVTN", purpose = "drawing" },
                            magic = { layer = "LVTN", purpose = "drawing" },
                        }
                    },
                    [3] = { -- rvtn
                        name = "RVTN",
                        lpp = {
                            gds   = { layer = 780,    purpose = 177       },
                            SKILL = { layer = "RVTN", purpose = "drawing" },
                            magic = { layer = "RVTN", purpose = "drawing" },
                        }
                    },
                    [4] = { -- hvtn
                        name = "HVTN",
                        lpp = {
                            gds   = { layer = 12,    purpose = 106        },
                            SKILL = { layer = "HVTN", purpose = "drawing" },
                            magic = { layer = "HVTN", purpose = "drawing" },
                        }
                    },
                },
                pmos = {
                    [1] = { -- slvtp
                        name = "SLVTP",
                        lpp = {
                            gds   = { layer = 212,     purpose = 53        },
                            SKILL = { layer = "SLVTP", purpose = "drawing" },
                            magic = { layer = "SLVTP", purpose = "drawing" },
                        }
                    },
                    [2] = { -- lvtp
                        name = "LVTP",
                        lpp = {
                            gds   = { layer = 200,    purpose = 14        },
                            SKILL = { layer = "LVTP", purpose = "drawing" },
                            magic = { layer = "LVTP", purpose = "drawing" },
                        }
                    },
                    [3] = { -- rvtp
                        name = "RVTP",
                        lpp = {
                            gds   = { layer = 780,    purpose = 178       },
                            SKILL = { layer = "RVTP", purpose = "drawing" },
                            magic = { layer = "RVTP", purpose = "drawing" },
                        }
                    },
                    [4] = { -- hvtp
                        name = "HVTP",
                        lpp = {
                            gds   = { layer = 200,    purpose = 17        },
                            SKILL = { layer = "HVTP", purpose = "drawing" },
                            magic = { layer = "HVTP", purpose = "drawing" },
                        }
                    },
                }
            }
            return {
                name = lut[settings.channeltype][settings.vthtype].name,
                lpp = lut[settings.channeltype][settings.vthtype].lpp,
                left   = 100,
                right  = 100,
                top    = settings.expand.top and 100 or 0,
                bottom = settings.expand.bottom and 100 or 0,
            }
        end),
        --]]
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
        --[[
        map(function(settings) -- implant
            local lut = {
                nmos = {
                    name = "NPLUS",
                    lpp = {
                        gds   = { layer = 1008,    purpose = 0 },
                        SKILL = { layer = "NPLUS", purpose = "drawing" },
                        magic = { layer = "NPLUS", purpose = "drawing" },
                        svg   = { color = "black", opacity = 1.0, fill = false, order = 13 },
                    }
                },
                pmos = {
                    name = "PPLUS",
                    lpp = {
                        gds   = { layer = 780,     purpose = 47 },
                        SKILL = { layer = "PPLUS", purpose = "drawing" },
                        magic = { layer = "PPLUS", purpose = "drawing" },
                        svg   = { color = "black", opacity = 1.0, fill = false, order = 13 },
                    }
                }
            }
            return {
                name = lut[settings.channeltype].name,
                lpp = lut[settings.channeltype].lpp,
                left   = 100,
                right  = 100,
                top    = settings.expand.top and 100 or 0,
                bottom = settings.expand.bottom and 100 or 0,
            }
        end),
        --]]
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
    --[==[
    polyres = {
        map {
            name = "OP",
            lpp = {
                gds   = { layer = 37,  purpose = 0 },
                SKILL = { layer = "OP", purpose = "drawing" },
                magic = { layer = "OP", purpose = "drawing" },
            }
        },
    },
    nres = {
        map {
            name = "NPLUS",
            lpp = {
                gds   = { layer = 1008,    purpose = 0 },
                SKILL = { layer = "NPLUS", purpose = "drawing" },
                magic = { layer = "NPLUS", purpose = "drawing" },
            }
        },
        map {
            name = "NRES",
            lpp = {
                gds   = { layer = 800,    purpose = 13 },
                SKILL = { layer = "NRES", purpose = "drawing" },
                magic = { layer = "NRES", purpose = "drawing" },
            }
        },
    },
    padopening = {
        map {
            name = "RS",
            lpp = {
                gds   = { layer = 4328, purpose = 0 },
                SKILL = { layer = "RS", purpose = "drawing" },
                magic = { layer = "RS", purpose = "drawing" },
            }
        },
    },
    contactnwell = {
        array {
            name = "CA",
            lpp = {
                gds      = { layer =   14,  purpose = 0 },
                SKILL = { layer = "CA" , purpose = "drawing" },
                magic    = { layer = "CA" , purpose = "drawing" },
                svg      = { color = "yellow", opacity = 1.0, fill = true, order = 6 },
            },
            width = 40,
            height = 40,
            xspace = 160,
            yspace = 160,
            xencl = 30,
            yencl = 30
        },
    },
    --]==]
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
    --[==[
    M3 = {
        map {
            name = "C1",
            lpp = {
                gds      = { layer = 187,   purpose = 0 },
                SKILL = { layer = "C1", purpose = "drawing" },
                magic    = { layer = "C1", purpose = "drawing" },
                svg      = { color = "rgb(255, 128, 0)", opacity = 0.5, fill = true, order = 7 },
            }
        }
    },
    M4 = {
        map {
            name = "C2",
            lpp = {
                gds      = { layer = 197,   purpose = 0 },
                SKILL = { layer = "C2", purpose = "drawing" },
                magic    = { layer = "C2", purpose = "drawing" },
            }
        }
    },
    M5 = {
        map {
            name = "C3",
            lpp = {
                gds      = { layer = 140,   purpose = 0 },
                SKILL = { layer = "C3", purpose = "drawing" },
                magic    = { layer = "C3", purpose = "drawing" },
            }
        }
    },
    M6 = {
        map {
            name = "C4",
            lpp = {
                gds      = { layer = 41,   purpose = 0 },
                SKILL = { layer = "C4", purpose = "drawing" },
                magic    = { layer = "C4", purpose = "drawing" },
            }
        }
    },
    M7 = {
        map {
            name = "C5",
            lpp = {
                gds      = { layer = 141,   purpose = 0 },
                SKILL = { layer = "C5", purpose = "drawing" },
                magic    = { layer = "C5", purpose = "drawing" },
            }
        }
    },
    M8 = {
        map {
            name = "JA",
            lpp = {
                gds      = { layer = 4349,   purpose = 0 },
                SKILL = { layer = "JA", purpose = "drawing" },
                magic    = { layer = "JA", purpose = "drawing" },
            }
        }
    },
    M9 = {
        map {
            name = "QA",
            lpp = {
                gds      = { layer = 139,   purpose = 0 },
                SKILL = { layer = "QA", purpose = "drawing" },
                magic    = { layer = "QA", purpose = "drawing" },
            }
        }
    },
    M10 = {
        map {
            name = "QB",
            lpp = {
                gds      = { layer = 39,   purpose = 0 },
                SKILL = { layer = "QB", purpose = "drawing" },
                magic    = { layer = "QB", purpose = "drawing" },
                svg      = { color = "blue", opacity = 0.5, fill = true, order = 10 },
            }
        }
    },
    M11 = {
        map {
            name = "LB",
            lpp = {
                gds   = { layer = 69,   purpose = 0 },
                SKILL = { layer = "LB", purpose = "drawing" },
                magic = { layer = "LB", purpose = "drawing" },
                svg   = { color = "red", opacity = 0.5, fill = true, order = 11 },
            }
        }
    },
    --]==]
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
    --[==[
    viaM2M3 = {
        array {
            name = "AY",
            lpp = {
                gds   = { layer =  213,  purpose = 0 },
                SKILL = { layer = "AY" , purpose = "drawing" },
                magic = { layer = "AY" , purpose = "drawing" },
            },
            width        = {    40,    40 },
            height       = {    40,    40 },
            xspace       = {    94,    94 },
            yspace       = {    94,    94 },
            xencl        = {     0,    34 },
            yencl        = {    34,     0 },
            conductivity = {     1,     1 },
            noneedtofit  = { false, false, false, false },
            fallback = { width = 40, height = 40 },
        }
    },
    viaM3M4 = {
        array {
            name = "A1",
            lpp = {
                gds   = { layer =  188,  purpose = 0 },
                SKILL = { layer = "A1" , purpose = "drawing" },
                magic = { layer = "A1" , purpose = "drawing" },
            },
            width = 44,
            height = 44,
            xspace = 90,
            yspace = 90,
            xencl = 10,
            yencl = 20,
            noneedtofit = true
        }
    },
    viaM4M5 = {
        array {
            name = "A2",
            lpp = {
                gds   = { layer =  138,  purpose = 0 },
                SKILL = { layer = "A2" , purpose = "drawing" },
                magic = { layer = "A2" , purpose = "drawing" },
            },
            width = 44,
            height = 44,
            xspace = 90,
            yspace = 90,
            xencl = 10,
            yencl = 20,
            noneedtofit = true
        }
    },
    viaM5M6 = {
        array {
            name = "A3",
            lpp = {
                gds   = { layer =  152,  purpose = 0 },
                SKILL = { layer = "A3" , purpose = "drawing" },
                magic = { layer = "A3" , purpose = "drawing" },
            },
            width = 44,
            height = 44,
            xspace = 90,
            yspace = 90,
            xencl = 10,
            yencl = 20,
            noneedtofit = true
        }
    },
    viaM6M7 = {
        array {
            name = "A4",
            lpp = {
                gds   = { layer =  153,  purpose = 0 },
                SKILL = { layer = "A4" , purpose = "drawing" },
                magic = { layer = "A4" , purpose = "drawing" },
            },
            width = 44,
            height = 44,
            xspace = 90,
            yspace = 90,
            xencl = 10,
            yencl = 20,
            noneedtofit = true
        }
    },
    viaM7M8 = {
        array {
            name = "YS",
            lpp = {
                gds   = { layer =   33,  purpose = 0 },
                SKILL = { layer = "YS" , purpose = "drawing" },
                magic = { layer = "YS" , purpose = "drawing" },
            },
            width = 414,
            height = 414,
            xspace = 396,
            yspace = 396,
            xencl = 60,
            yencl = 60
        }
    },
    viaM8M9 = {
        array {
            name = "JV",
            lpp = {
                gds   = { layer =   54,  purpose = 0 },
                SKILL = { layer = "JV" , purpose = "drawing" },
                magic = { layer = "JV" , purpose = "drawing" },
            },
            width = 1200,
            height = 1200,
            xspace = 1200,
            yspace = 1200,
            xencl = 600,
            yencl = 600
        },
    },
    viaM9M10 = {
        array {
            name = "JW",
            lpp = {
                gds   = { layer =   55,  purpose = 0 },
                SKILL = { layer = "JW" , purpose = "drawing" },
                magic = { layer = "JW" , purpose = "drawing" },
            },
            width = 1200,
            height = 1200,
            xspace = 1200,
            yspace = 1200,
            xencl = 600,
            yencl = 600
        },
    },
    viaM10M11 = {
        array {
            name = "VV",
            lpp = {
                gds   = { layer =   70,  purpose = 0 },
                SKILL = { layer = "VV" , purpose = "drawing" },
                magic = { layer = "VV" , purpose = "drawing" },
                svg   = { color = "green", opacity = 0.5, fill = true, order = 10 },
            },
            width = 2700,
            height = 2700,
            xspace = 1800,
            yspace = 1800,
            xencl = 450,
            yencl = 450
        },
    },
    -- ports
    nwellport = {
        map {
            name = "NWport",
            lpp = {
                gds   = { layer = 4,   purpose = 20 },
                SKILL = { layer = "NW", purpose = "label" },
                magic = { layer = "NW", purpose = "label" },
            }
        }
    },
    pwellport = {
        map {
            name = "PWport",
            lpp = {
                gds   = { layer = 62,   purpose = 10 },
                SKILL = { layer = "SXCUT", purpose = "label" },
                magic = { layer = "SXCUT", purpose = "label" },
            }
        }
    },
    --]==]
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
    --[==[
    M2port = {
        map {
            name = "M2port",
            lpp = {
                gds   = { layer = 17,   purpose = 20 },
                SKILL = { layer = "M2", purpose = "label" },
                magic = { layer = "M2", purpose = "label" },
                svg   = { color = "blue", opacity = 1.0, fill = true, order = 5 },
            }
        }
    },
    M3port = {
        map {
            name = "M3port",
            lpp = {
                gds   = { layer = 187,  purpose = 20 },
                SKILL = { layer = "C1", purpose = "label" },
                magic = { layer = "C1", purpose = "label" },
                svg   = { color = "orange", opacity = 1.0, fill = true, order = 5 },
            }
        }
    },
    M4port = {
        map {
            name = "M4port",
            lpp = {
                gds   = { layer = 197,  purpose = 20 },
                SKILL = { layer = "C2", purpose = "label" },
                magic = { layer = "C2", purpose = "label" },
                svg   = { color = "orange", opacity = 1.0, fill = true, order = 5 },
            }
        }
    },
    M5port = {
        map {
            name = "M5port",
            lpp = {
                gds   = { layer = 140,  purpose = 20 },
                SKILL = { layer = "C3", purpose = "label" },
                magic = { layer = "C3", purpose = "label" },
                svg   = { color = "orange", opacity = 1.0, fill = true, order = 5 },
            }
        }
    },
    M6port = {
        map {
            name = "M6port",
            lpp = {
                gds   = { layer =  41,  purpose = 20 },
                SKILL = { layer = "C4", purpose = "label" },
                magic = { layer = "C4", purpose = "label" },
                svg   = { color = "orange", opacity = 1.0, fill = true, order = 5 },
            }
        }
    },
    M7port = {
        map {
            name = "M7port",
            lpp = {
                gds   = { layer = 141,  purpose = 20 },
                SKILL = { layer = "C5", purpose = "label" },
                magic = { layer = "C5", purpose = "label" },
                svg   = { color = "orange", opacity = 1.0, fill = true, order = 5 },
            }
        }
    },
    M11port = {
        map {
            name = "M11port",
            lpp = {
                gds   = { layer = 69,  purpose = 20 },
                SKILL = { layer = "LB", purpose = "label" },
                magic = { layer = "LB", purpose = "label" },
                svg   = { color = "orange", opacity = 1.0, fill = true, order = 5 },
            }
        }
    },
    --]==]
}

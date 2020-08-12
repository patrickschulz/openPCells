return {
    contactactive = {
        layers = {
            {
                lpp = {
                    gds      = { layer = 66,       purpose = 44 }, 
                    virtuoso = { layer = "licon1", purpose = "drawing" },
                    svg      = { color = "yellow", opacity = 0.4, fill = true},
                }
            },
        },
        width = 0.17,
        height = 0.17, 
        xspace = 0.17, 
        yspace = 0.17, 
        xencl = 0.04, 
        yencl = 0.04
    },
    contactgate = {
        layers = {
            {
                lpp = {
                    gds      = { layer = 66,     purpose = 20 },
                    virtuoso = { layer = "poly", purpose = "drawing", },
                },
                enlarge = 0.1
            },
            {
                lpp = {
                    gds      = { layer = 95,      purpose = 20 },
                    virtuoso = { layer = "npc", purpose = "drawing", },
                },
                enlarge = 0.1
            },
            {
                lpp = {
                    gds      = { layer = 66,   purpose = 44 },
                    virtuoso = { layer = "licon1", purpose = "drawing", },
                },
            },
        },
        width = 0.17,
        height = 0.17, 
        xspace = 0.25, 
        yspace = 0.17, 
        xencl = 0.04, 
        yencl = 0.08
    },
    viaM1M2 = {
        layers = {
            lpp = {
                gds      = { layer = 67,     purpose = 44 },
                virtuoso = { layer = "mcon", purpose = "drawing", },
            },
        },
        width = 0.17,
        height = 0.17, 
        xspace = 0.25, 
        yspace = 0.17, 
        xencl = 0.04, 
        yencl = 0.08
    },
    viaM2M3 = {
        layers = {
            lpp = {
                gds      = { layer = 68,      purpose = 44 },
                virtuoso = { layer = "via", purpose = "drawing", },
            },
        },
        width = 0.17,
        height = 0.17, 
        xspace = 0.25, 
        yspace = 0.17, 
        xencl = 0.04, 
        yencl = 0.08
    },
    viaM3M4 = {
        layers = {
            lpp = {
                gds      = { layer = 69,     purpose = 44 },
                virtuoso = { layer = "via2", purpose = "drawing", },
            },
        },
        width = 0.17,
        height = 0.17, 
        xspace = 0.25, 
        yspace = 0.17, 
        xencl = 0.04, 
        yencl = 0.08
    },
    viaM4M5 = {
        layers = {
            lpp = {
                gds      = { layer = 70,     purpose = 44 },
                virtuoso = { layer = "via3", purpose = "drawing", },
            },
        },
        width = 0.17,
        height = 0.17, 
        xspace = 0.25, 
        yspace = 0.17, 
        xencl = 0.04, 
        yencl = 0.08
    },
    viaM5M6 = {
        layers = {
            lpp = {
                gds      = { layer = 71,     purpose = 44 },
                virtuoso = { layer = "via4", purpose = "drawing" },
            },
        },
        width = 0.17,
        height = 0.17, 
        xspace = 0.25, 
        yspace = 0.17, 
        xencl = 0.04, 
        yencl = 0.08
    },
}

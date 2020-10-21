return {
    contactactive = {
        layers = {
            {
                lpp = {
                    gds      = { layer = 66,       purpose = 44 }, 
                    virtuoso = { layer = "licon1", purpose = "drawing" },
                    magic    = { layer = "licon1", purpose = "drawing" },
                    svg      = { color = "yellow", opacity = 0.4, fill = true},
                }
            },
        },
        width = 170,
        height = 170, 
        xspace = 170, 
        yspace = 170, 
        xencl = 40, 
        yencl = 40
    },
    contactgate = {
        layers = {
            {
                lpp = {
                    gds      = { layer = 66,     purpose = 20 },
                    virtuoso = { layer = "poly", purpose = "drawing", },
                    magic    = { layer = "poly", purpose = "drawing", },
                },
                enlarge = 100
            },
            {
                lpp = {
                    gds      = { layer = 95,      purpose = 20 },
                    virtuoso = { layer = "npc", purpose = "drawing", },
                    magic    = { layer = "npc", purpose = "drawing", },
                },
                enlarge = 100
            },
            {
                lpp = {
                    gds      = { layer = 66,   purpose = 44 },
                    virtuoso = { layer = "licon1", purpose = "drawing", },
                    magic    = { layer = "licon1", purpose = "drawing", },
                },
            },
        },
        width = 170,
        height = 170, 
        xspace = 250, 
        yspace = 170, 
        xencl = 40, 
        yencl = 80
    },
    viaM1M2 = {
        layers = {
            {
                lpp = {
                    gds      = { layer = 67,     purpose = 44 },
                    virtuoso = { layer = "mcon", purpose = "drawing", },
                    magic    = { layer = "mcon", purpose = "drawing", },
                },
            },
        },
        width = 170,
        height = 170, 
        xspace = 250, 
        yspace = 170, 
        xencl = 40, 
        yencl = 80
    },
    viaM2M3 = {
        layers = {
            {
                lpp = {
                    gds      = { layer = 68,      purpose = 44 },
                    virtuoso = { layer = "via", purpose = "drawing", },
                    magic    = { layer = "via", purpose = "drawing", },
                },
            },
        },
        width = 150,
        height = 150, 
        xspace = 170, 
        yspace = 170, 
        xencl = 55, 
        yencl = 55
    },
    viaM3M4 = {
        layers = {
            {
                lpp = {
                    gds      = { layer = 69,     purpose = 44 },
                    virtuoso = { layer = "via2", purpose = "drawing", },
                    magic    = { layer = "via2", purpose = "drawing", },
                },
            },
        },
        width = 200,
        height = 200, 
        xspace = 200, 
        yspace = 200, 
        xencl = 40, 
        yencl = 40
    },
    viaM4M5 = {
        layers = {
            {
                lpp = {
                    gds      = { layer = 70,     purpose = 44 },
                    virtuoso = { layer = "via3", purpose = "drawing", },
                    magic    = { layer = "via3", purpose = "drawing", },
                },
            },
        },
        width = 200,
        height = 200, 
        xspace = 200, 
        yspace = 200, 
        xencl = 60, 
        yencl = 60
    },
    viaM5M6 = {
        layers = {
            {
                lpp = {
                    gds      = { layer = 71,     purpose = 44 },
                    virtuoso = { layer = "via4", purpose = "drawing" },
                    magic    = { layer = "via4", purpose = "drawing" },
                },
            },
        },
        width = 800,
        height = 800, 
        xspace = 800, 
        yspace = 800, 
        xencl = 190, 
        yencl = 190
    },
}

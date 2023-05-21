return {
    buf = {
        width = 4,
        pinoffsets = {
            I = { x = 0.0, y = 0.0 },
            O = { x = 3.5, y = 0.0 },
        },
    },
    cinv = {
        width = 3,
        pinoffsets = {
            I = { x = 1.0, y = 0.0 },
            EP = { x = 2.0, y = 1.0 },
            EN = { x = 2.0, y = -1.0 },
            O = { x = 1.0, y = 0.0 },
        },
    },
    not_gate = {
        width = 2,
        pinoffsets = {
            I = { x = 0.0, y = 0.0 },
            O = { x = 1.0, y = 0.0 },
        },
    },
    nand_gate = {
        width = 3,
        pinoffsets = {
            A = { x = 0.0, y = -1.0 },
            B = { x = 1.0, y = 1.0 },
            O = { x = 2.0, y = 0.0 },
        },
    },
    nor_gate = {
        width = 3,
        pinoffsets = {
            A = { x = 0.0, y = -1.0 },
            B = { x = 1.0, y = 1.0 },
            O = { x = 2.0, y = 0.0 },
        },
    },
    or_gate = {
        width = 5,
        pinoffsets = {
            A = { x = 0.0, y = -1.0 },
            B = { x = 1.0, y = 1.0 },
            O = { x = 4.5, y = 0.0 },
        },
    },
    and_gate = {
        width = 5,
        pinoffsets = {
            A = { x = 0.0, y = -1.0 },
            B = { x = 1.0, y = 1.0 },
            O = { x = 4.5, y = 0.0 },
        },
    },
    xor_gate = {
        width = 11,
        pinoffsets = {
            A = { x = 0.0, y = -1.0 },
        },
    },
    dffpq = {
        width = 22,
        pinoffsets = {
            CLK = { x = 0.0, y = -1.0 },
            D = { x = 0.0, y = 1.0 },
            Q = { x = 21.0, y = 0.0 },
        },
        blockages = {
            {
                { x = -1, y = 1, z = 2},
                { x = 6, y = 1, z = 2},
            },
            {
                { x = 3, y = 0, z = 2},
                { x = 18, y = 0, z = 2},
            },
            {
                { x = 1, y = -1, z = 2},
                { x = 18, y = -1, z = 2},
            },
        }
    },
    dffnq = {
        width = 22,
        pinoffsets = {
            CLK = { x = 0.0, y = -1.0 },
            D = { x = 0.0, y = 1.0 },
            Q = { x = 21.0, y = 0.0 },
        },
        blockages = {
            {
                { x = -1, y = 1, z = 2},
                { x = 6, y = 1, z = 2},
            },
            {
                { x = 3, y = 0, z = 2},
                { x = 18, y = 0, z = 2},
            },
            {
                { x = 1, y = -1, z = 2},
                { x = 18, y = -1, z = 2},
            },
        }
    },
    dffprq = {
        width = 25,
        pinoffsets = {
            CLK = { x = 0.0, y = -1.0 },
            D = { x = 0.0, y = 1.0 },
            Q = { x = 24.0, y = 0.0 },
            RST = { x = 15.5, y = 0.0 },
        },
        blockages = {
            {
                { x = -1, y = 1, z = 2},
                { x = 6, y = 1, z = 2},
            },
            {
                { x = 1, y = -1, z = 2},
                { x = 20, y = -1, z = 2},
            },
            {
                { x = 3, y = 0, z = 2},
                { x = 8, y = 0, z = 2},
                { x = 8, y = 1, z = 2},
                { x = 19, y = 1, z = 2},
            },
            {
                { x = 10, y = 0, z = 2},
                { x = 21, y = 0, z = 2},
            },
        }
    },
    dffnrq = {
        width = 25,
        pinoffsets = {
            CLK = { x = 0.0, y = -1.0 },
            D = { x = 0.0, y = 1.0 },
            Q = { x = 24.0, y = 0.0 },
            RST = { x = 15.5, y = 0.0 },
        },
        blockages = {
            {
                { x = -1, y = 1, z = 2},
                { x = 6, y = 1, z = 2},
            },
            {
                { x = 1, y = -1, z = 2},
                { x = 20, y = -1, z = 2},
            },
            {
                { x = 3, y = 0, z = 2},
                { x = 8, y = 0, z = 2},
                { x = 8, y = 1, z = 2},
                { x = 19, y = 1, z = 2},
            },
            {
                { x = 10, y = 0, z = 2},
                { x = 21, y = 0, z = 2},
            },
        }
    },
    dffpsq = {
        width = 26,
        pinoffsets = {
            CLK = { x = 0.0, y = -1.0 },
            D = { x = 0.0, y = 1.0 },
            Q = { x = 25.0, y = 0.0 },
            SET = { x = 16.5, y = 0.0 },
        },
    },
    dffnsq = {
        width = 26,
        pinoffsets = {
            CLK = { x = 0.0, y = -1.0 },
            D = { x = 0.0, y = 1.0 },
            Q = { x = 25.0, y = 0.0 },
            SET = { x = 16.5, y = 0.0 },
        },
    },
}

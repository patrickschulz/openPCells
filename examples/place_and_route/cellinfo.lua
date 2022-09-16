return {
    dffpq = {
        width = 23,
        pinoffsets = {
            CLK = { x = 1, y = -1 },
            D = { x = 1, y = 1 },
            Q = { x = 22, y = 0 },
        },
        blockages = {
            {
                { x = 0, y = 1, z = 2},
                { x = 1, y = 1, z = 2},
            },
            {
                { x = 2, y = 1, z = 2},
                { x = 7, y = 1, z = 2},
            },
            {
                { x = 4, y = 0, z = 2},
                { x = 19, y = 0, z = 2},
            },
            {
                { x = 2, y = -1, z = 2},
                { x = 20, y = -1, z = 2},
            },
        }
    },
    dffnq = {
        width = 23,
        pinoffsets = {
            CLK = { x = 1, y = -1 },
            D = { x = 1, y = 1 },
            Q = { x = 22, y = 0 },
        },
        blockages = {
            {
                { x = 0, y = 1, z = 2},
                { x = 1, y = 1, z = 2},
            },
            {
                { x = 2, y = 1, z = 2},
                { x = 7, y = 1, z = 2},
            },
            {
                { x = 4, y = 0, z = 2},
                { x = 19, y = 0, z = 2},
            },
            {
                { x = 2, y = -1, z = 2},
                { x = 20, y = -1, z = 2},
            },
        }
    },
    dffprq = {
        width = 26,
        pinoffsets = {
            CLK = { x = 1, y = -1 },
            D = { x = 1, y = 1 },
            Q = { x = 25, y = 0 },
            RST = { x = 16, y = 0 },
        },
        blockages = {
            {
                { x = 0, y = 1, z = 2},
                { x = 1, y = 1, z = 2},
            },
            {
                { x = 2, y = 1, z = 2},
                { x = 7, y = 1, z = 2},
            },
            {
                { x = 2, y = -1, z = 2},
                { x = 21, y = -1, z = 2},
            },
            {
                { x = 4, y = 0, z = 2},
                { x = 9, y = 0, z = 2},
                { x = 9, y = 1, z = 2},
                { x = 20, y = 1, z = 2},
            },
            {
                { x = 11, y = 0, z = 2},
                { x = 22, y = 0, z = 2},
            },
        }
    },
    dffnrq = {
        width = 26,
        pinoffsets = {
            CLK = { x = 1, y = -1 },
            D = { x = 1, y = 1 },
            Q = { x = 25, y = 0 },
            RST = { x = 16, y = 0 },
        },
        blockages = {
            {
                { x = 0, y = 1, z = 2},
                { x = 1, y = 1, z = 2},
            },
            {
                { x = 2, y = 1, z = 2},
                { x = 7, y = 1, z = 2},
            },
            {
                { x = 2, y = -1, z = 2},
                { x = 21, y = -1, z = 2},
            },
            {
                { x = 4, y = 0, z = 2},
                { x = 9, y = 0, z = 2},
                { x = 9, y = 1, z = 2},
                { x = 20, y = 1, z = 2},
            },
            {
                { x = 11, y = 0, z = 2},
                { x = 22, y = 0, z = 2},
            },
        }
    },
    dffpsq = {
        width = 25,
        pinoffsets = {
            CLK = { x = 0, y = -1 },
            D = { x = 0, y = 1 },
            Q = { x = 25, y = 0 },
            SET = { x = 16, y = 0 },
        },
    },
    dffnsq = {
        width = 25,
        pinoffsets = {
            CLK = { x = 0, y = -1 },
            D = { x = 0, y = 1 },
            Q = { x = 25, y = 0 },
            SET = { x = 16, y = 0 },
        },
    },
    not_gate = {
        width = 2,
        pinoffsets = {
            I = { x = 0, y = 0 },
            O = { x = 1, y = 0 },
        },
    },
    nand_gate = {
        width = 3,
        pinoffsets = {
            A = { x = 0, y = -1 },
            B = { x = 1, y = 1 },
            O = { x = 2, y = 0 },
        },
    },
    nor_gate = {
        width = 3,
        pinoffsets = {
            A = { x = 0, y = -1 },
            B = { x = 1, y = 1 },
            O = { x = 2, y = 0 },
        },
    },
    or_gate = {
        width = 5,
        pinoffsets = {
            A = { x = 0, y = -1 },
            B = { x = 1, y = 1 },
            O = { x = 4, y = 0 },
        },
    },
    and_gate = {
        width = 5,
        pinoffsets = {
            A = { x = 0, y = -1 },
            B = { x = 1, y = 1 },
            O = { x = 4, y = 0 },
        },
    },
    xor_gate = {
        width = 10,
        pinoffsets = {
            A = { x = 0, y = -1 },
            B = { x = 0, y = 1 },
            O = { x = 3, y = 0 },
        },
    },
}

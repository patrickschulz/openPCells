return {
    not_gate = {
        width = 2,
        pinoffsets = {
            I = { x = 0, y = 0 },
            O = { x = 1, y = 0 }
        },
    },
    nand_gate = {
        width = 3,
        pinoffsets = {
            A = { x = 0, y = -1 },
            B = { x = 1, y = 1 },
            O = { x = 2, y = 0 }
        },
    },
    nor_gate = {
        width = 3,
        pinoffsets = {
            A = { x = 0, y = -1 },
            B = { x = 1, y = 1 },
            O = { x = 2, y = 0 }
        },
    },
    xor_gate = {
        width = 10,
        pinoffsets = {
            A = { x = 0, y = 0 },
            B = { x = 1, y = 0 },
            O = { x = 10, y = 0 }
        },
    },
    xnor_gate = {
        width = 11,
        pinoffsets = {
            A = { x = 0, y = 0 },
            B = { x = 1, y = 0 },
            O = { x = 10, y = 0 }
        },
    },
    dffpq = {
        width = 22,
        pinoffsets = {
            CLK = { x = 0, y = -1 },
            D = { x = 0, y = 1 },
            Q = { x = 21, y = 0 },
        },
        blockages = {
            {
                { x = 0, y = 1, z = 2},
                { x = 6, y = 1, z = 2},
            },
            {
                { x = 3, y = 0, z = 2},
                { x = 17, y = 0, z = 2},
            },
            {
                { x = 1, y = -1, z = 2},
                { x = 17, y = -1, z = 2},
            },
        }
    },
    dffnq = {
        width = 22,
        pinoffsets = {
            CLK = { x = 0, y = -1 },
            D = { x = 0, y = 1 },
            Q = { x = 21, y = 0 },
        },
        blockages = {
            {
                { x = 0, y = 1, z = 2},
                { x = 6, y = 1, z = 2},
            },
            {
                { x = 3, y = 0, z = 2},
                { x = 17, y = 0, z = 2},
            },
            {
                { x = 1, y = -1, z = 2},
                { x = 17, y = -1, z = 2},
            },
        }
    },
    dffprq = {
        width = 25,
        pinoffsets = {
            CLK = { x = 0, y = -1 },
            D = { x = 0, y = 1 },
            Q = { x = 20, y = 0 }
        },
        blockages = {
            {
                { x = 0, y = 1, z = 2},
                { x = 6, y = 1, z = 2},
            },
            {
                { x = 2, y = -1, z = 2},
                { x = 22, y = -1, z = 2},
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
    dffprsq = {
        width = 25,
        pinoffsets = {
            CLK = { x = 0, y = 0 },
            D = { x = 0, y = 0 },
            Q = { x = 20, y = 0 }
        },
    },
}

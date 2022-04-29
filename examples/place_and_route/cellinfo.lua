return {
    not_gate = {
        width = 2,
        pinoffsets = {
            I = { x = 0, y = 0 },
            O = { x = 1, y = 0 }
        },
    },
    nand_gate = {
        width = 2,
        pinoffsets = {
            A = { x = 0, y = 0 },
            B = { x = 1, y = 0 },
            O = { x = 2, y = 0 }
        },
    },
    nor_gate = {
        width = 2,
        pinoffsets = { 
            A = { x = 0, y = 0 },
            B = { x = 1, y = 0 },
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
            CLK = { x = 0, y = 0 },
            D = { x = 0, y = 0 },
            Q = { x = 20, y = 0 },
        },
    },
    dffnq = {
        width = 22,
        pinoffsets = {
            CLK = { x = 0, y = 0 },
            D = { x = 0, y = 0 },
            Q = { x = 20, y = 0 }
        },
    },
    dffprq = {
        width = 25,
        pinoffsets = {
            CLK = { x = 0, y = 0 },
            D = { x = 0, y = 0 },
            Q = { x = 20, y = 0 }
        },
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

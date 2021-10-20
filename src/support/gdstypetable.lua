local M = {}

M.recordtypes = {
    HEADER          = { name = "HEADER",        code = 0x00 },
    BGNLIB          = { name = "BGNLIB",        code = 0x01 },
    LIBNAME         = { name = "LIBNAME",       code = 0x02 },
    UNITS           = { name = "UNITS",         code = 0x03 },
    ENDLIB          = { name = "ENDLIB",        code = 0x04 },
    BGNSTR          = { name = "BGNSTR",        code = 0x05 },
    STRNAME         = { name = "STRNAME",       code = 0x06 },
    ENDSTR          = { name = "ENDSTR",        code = 0x07 },
    BOUNDARY        = { name = "BOUNDARY",      code = 0x08 },
    PATH            = { name = "PATH",          code = 0x09 },
    SREF            = { name = "SREF",          code = 0x0a },
    AREF            = { name = "AREF",          code = 0x0b },
    TEXT            = { name = "TEXT",          code = 0x0c },
    LAYER           = { name = "LAYER",         code = 0x0d },
    DATATYPE        = { name = "DATATYPE",      code = 0x0e },
    WIDTH           = { name = "WIDTH",         code = 0x0f },
    XY              = { name = "XY",            code = 0x10 },
    ENDEL           = { name = "ENDEL",         code = 0x11 },
    SNAME           = { name = "SNAME",         code = 0x12 },
    COLROW          = { name = "COLROW",        code = 0x13 },
    TEXTNODE        = { name = "TEXTNODE",      code = 0x14 },
    NODE            = { name = "NODE",          code = 0x15 },
    TEXTTYPE        = { name = "TEXTTYPE",      code = 0x16 },
    PRESENTATION    = { name = "PRESENTATION",  code = 0x17 },
    SPACING         = { name = "SPACING",       code = 0x18 },
    STRING          = { name = "STRING",        code = 0x19 },
    STRANS          = { name = "STRANS",        code = 0x1a },
    MAG             = { name = "MAG",           code = 0x1b },
    ANGLE           = { name = "ANGLE",         code = 0x1c },
    UINTEGER        = { name = "UINTEGER",      code = 0x1d },
    USTRING         = { name = "USTRING",       code = 0x1e },
    REFLIBS         = { name = "REFLIBS",       code = 0x1f },
    FONTS           = { name = "FONTS",         code = 0x20 },
    PATHTYPE        = { name = "PATHTYPE",      code = 0x21 },
    GENERATIONS     = { name = "GENERATIONS",   code = 0x22 },
    ATTRTABLE       = { name = "ATTRTABLE",     code = 0x23 },
    STYPTABLE       = { name = "STYPTABLE",     code = 0x24 },
    STRTYPE         = { name = "STRTYPE",       code = 0x25 },
    ELFLAGS         = { name = "ELFLAGS",       code = 0x26 },
    ELKEY           = { name = "ELKEY",         code = 0x27 },
    LINKTYPE        = { name = "LINKTYPE",      code = 0x28 },
    LINKKEYS        = { name = "LINKKEYS",      code = 0x29 },
    NODETYPE        = { name = "NODETYPE",      code = 0x2a },
    PROPATTR        = { name = "PROPATTR",      code = 0x2b },
    PROPVALUE       = { name = "PROPVALUE",     code = 0x2c },
    BOX             = { name = "BOX",           code = 0x2d },
    BOXTYPE         = { name = "BOXTYPE",       code = 0x2e },
    PLEX            = { name = "PLEX",          code = 0x2f },
    BGNEXTN         = { name = "BGNEXTN",       code = 0x30 },
    ENDEXTN         = { name = "ENDEXTN",       code = 0x31 },
    TAPENUM         = { name = "TAPENUM",       code = 0x32 },
    TAPECODE        = { name = "TAPECODE",      code = 0x33 },
    STRCLASS        = { name = "STRCLASS",      code = 0x34 },
    RESERVED        = { name = "RESERVED",      code = 0x35 },
    FORMAT          = { name = "FORMAT",        code = 0x36 },
    MASK            = { name = "MASK",          code = 0x37 },
    ENDMASKS        = { name = "ENDMASKS",      code = 0x38 },
    LIBDIRSIZE      = { name = "LIBDIRSIZE",    code = 0x39 },
    SRFNAME         = { name = "SRFNAME",       code = 0x3a },
    LIBSECUR        = { name = "LIBSECUR",      code = 0x3b },
}
M.recordtypesnames = {}
for k, v in pairs(M.recordtypes) do
    M.recordtypesnames[v.code] = v.name
end
M.recordtypescodes = {}
for k, v in pairs(M.recordtypes) do
    M.recordtypescodes[v.name] = v.code
end

M.datatypes = {
    NONE                = 0x00,
    BIT_ARRAY           = 0x01,
    TWO_BYTE_INTEGER    = 0x02,
    FOUR_BYTE_INTEGER   = 0x03,
    FOUR_BYTE_REAL      = 0x04,
    EIGHT_BYTE_REAL     = 0x05,
    ASCII_STRING        = 0x06,
}

return M

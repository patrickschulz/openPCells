local cell = object.create()

local libname = "GF22FDX_SC8T_104CPP_BASE_CSC20SL"
local invref = pcell.create_layout(string.format("%s/SC8T_INVX1_CSC20SL", libname))
local invname = pcell.add_cell_reference(invref, "inv")
local andref = pcell.create_layout(string.format("%s/SC8T_AN2X1_CSC20SL", libname))
local andname = pcell.add_cell_reference(andref, "and")
local orref = pcell.create_layout(string.format("%s/SC8T_OR2X1_CSC20SL", libname))
local orname = pcell.add_cell_reference(orref, "or")
local xorref = pcell.create_layout(string.format("%s/SC8T_XOR2X1_CSC20SL", libname))
local xorname = pcell.add_cell_reference(xorref, "xor")
local dffref = pcell.create_layout(string.format("%s/SC8T_DFFX1_CSC20SL", libname))
local dffname = pcell.add_cell_reference(dffref, "dff")

local fill1ref = pcell.create_layout(string.format("%s/SC8T_FILLX1_CSC20SL", libname))
local fill1name = pcell.add_cell_reference(fill1ref, "fillx1")
local fill2ref = pcell.create_layout(string.format("%s/SC8T_FILLX2_CSC20SL", libname))
local fill2name = pcell.add_cell_reference(fill2ref, "fillx2")
local fill3ref = pcell.create_layout(string.format("%s/SC8T_FILLX3_CSC20SL", libname))
local fill3name = pcell.add_cell_reference(fill3ref, "fillx3")
local fill4ref = pcell.create_layout(string.format("%s/SC8T_FILLX4_CSC20SL", libname))
local fill4name = pcell.add_cell_reference(fill4ref, "fillx4")
local fill5ref = pcell.create_layout(string.format("%s/SC8T_FILLX5_CSC20SL", libname))
local fill5name = pcell.add_cell_reference(fill5ref, "fillx5")

local fillers = {
    fill1name,
    fill2name,
    fill3name,
    fill4name,
    fill5name,
}

local cellnames = {}
local lut = {
    invname,
    andname,
    orname,
    xorname,
    dffname
}
for i = 1, 10000 do
    cellnames[i] = lut[math.random(1, #lut)]
end

placement.digital_auto(cell, 104, 1000 * 104, cellnames, fillers)

return cell

return {
    active = { layer = { number = 65, name = "diff" }, purpose = { number = 20, name = "drawing" } },
    nimpl = { layer = { number = 93, name = "nsdm" }, purpose = { number = 44, name = "drawing" } },
    pimpl = { layer = { number = 94, name = "psdm" }, purpose = { number = 20, name = "drawing" } },
    soiopen = "UNUSED",
    nwell = { layer = { number = 64, name = "nwell" }, purpose = { number = 20, name = "drawing" } },
    pwell = "UNUSED",
    gate = { layer = { number = 66, name = "poly" }, purpose = { number = 20, name = "drawing" } },
    M1 = { layer = { number = 67, name = "li1" }, purpose = { number = 20, name = "drawing" } },
    wellcont = { layer = { number = 66, name = "licon1" }, purpose = { number = 44, name = "drawing" } },
}
--[[
tap,drawing,65:44,"Active (diffusion) area (type equal to the well/substrate underneath) (i.e., N+ and P+)"
dnwell,drawing,64:18,Deep n-well region
pwbm,drawing,19:44,Regions (in UHVI) blocked from p-well implant (DE MOS devices only)
pwde,drawing,124:20,Regions to receive p-well drain-extended implants
hvtr,drawing,18:20,High-Vt RF transistor implant
hvtp,drawing,78:44,High-Vt LVPMOS implant
ldntm,drawing,11:44,N-tip implant on SONOS devices
hvi,drawing,75:20,High voltage (5.0V) thick oxide gate regions
tunm,drawing,80:20,SONOS device tunnel implant
lvtn,drawing,125:44,Low-Vt NMOS device
hvntm,drawing,125:20,High voltage N-tip implant
rpm,drawing,86:20,300 ohms/square polysilicon resistor implant
urpm,drawing,79:20,2000 ohms/square polysilicon resistor implant
npc,drawing,95:20,Nitride poly cut (under licon1 areas)
mcon,drawing,67:44,Contact from local interconnect to metal1
met1,"drawing, text",68:20,Metal 1
via,drawing,68:44,Contact from metal 1 to metal 2
met2,"drawing, text",69:20,Metal 2
via2,drawing,69:44,Contact from metal 2 to metal 3
met3,"drawing, text",70:20,Metal 3
via3,drawing,70:44,Contact from metal 3 to metal 4
met4,"drawing, text",71:20,Metal 4
via4,drawing,71:44,Contact from metal 4 to metal 5
met5,"drawing, text",72:20,Metal 5
pad,"drawing, text",76:20,Passivation cut (opening over pads)
nsm,drawing,61:20,Nitride seal mask
capm,drawing,89:44,MiM capacitor plate over metal 3
cap2m,drawing,97:44,MiM capacitor plate over metal 4
vhvi,drawing,74:21,12V nominal (16V max) node identifier
uhvi,drawing,74:22,20V nominal node identifier
npn,drawing,82:20,Base region identifier for NPN devices
inductor,drawing,82:24,Identifier for inductor regions
capacitor,drawing,82:64,Identifier for interdigitated (vertical parallel plate (vpp)) capacitors
pnp,drawing,82:44,Base nwell region identifier for PNP devices
LVS prune,drawing,84:44,Exemption from LVS check (used in e-test modules only)
ncm,drawing,92:44,N-core implant
padCenter,drawing,81:20,Pad center marker
target,drawing,76:44,Metal fuse target
--]]

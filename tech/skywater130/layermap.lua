return {
    oxide1  = {},
    vthtype1  = {},
    contactsourcedrain = {
        name = "licon1",
        layer = {
            gds      = { layer = 66,       purpose = 44 },
            virtuoso = { layer = "licon1", purpose = "drawing" },
            magic    = { layer = "licon1", purpose = "drawing" },
            svg      = { color = "yellow", fill = true, order = 5 },
        },
    },
    contactgate = {
        name = "licon1",
        layer = {
            gds      = { layer = 66,   purpose = 44 },
            virtuoso = { layer = "licon1", purpose = "drawing", },
            magic    = { layer = "licon1", purpose = "drawing", },
            svg      = { color = "yellow", fill = true},
        },
    },
    active = {
        name = "diff",
        layer = {
            gds      = { layer = 65,    purpose = 20 },
            virtuoso = { layer ="diff", purpose = "drawing" },
            magic    = { layer ="diff", purpose = "drawing" },
            svg      = { color ="green", fill = true, order = 2 },
        },
    },
    nimpl = {
        name = "nsdm",
        layer = {
            gds      = { layer = 93,    purpose = 44 },
            virtuoso = { layer ="nsdm", purpose = "drawing" },
            magic    = { layer ="nsdm", purpose = "drawing" },
            svg      = { color ="black", opacity = 1, fill = false  },
        },
    },
    pimpl = {
        name = "psdm",
        layer = {
            gds      = { layer = 94,    purpose = 20 },
            virtuoso = { layer ="psdm", purpose = "drawing" },
            magic    = { layer ="psdm", purpose = "drawing" },
        },
    },
    soiopen = {},
    nwell = {
        name = "nwell",
        layer = {
            gds      = { layer = 64,     purpose = 20 },
            virtuoso = { layer ="nwell", purpose = "drawing" },
            magic    = { layer ="nwell", purpose = "drawing" },
            svg      = { color ="yellow", opacity = 0.1, fill = true },
        },
    },
    pwell = {},
    deepnwell = {
        name = "dnwell",
        layer = {
            gds      = { layer = 64,       purpose = 18 },
            virtuoso = { layer = "dnwell", purpose = "drawing" },
            magic    = { layer = "dnwell", purpose = "drawing" },
        },
    },
    gate = {
        name = "poly",
        layer = {
            gds      = { layer = 66,    purpose = 20 },
            virtuoso = { layer ="poly", purpose = "drawing" },
            magic    = { layer ="poly", purpose = "drawing" },
            svg      = { color ="red",  fill = true, order = 3 },
        },
    },
    M1 = {
        name = "li1",
        layer = {
            gds      = { layer = 67,    purpose = 20 },
            virtuoso = { layer ="li1",  purpose = "drawing" },
            magic    = { layer ="li1",  purpose = "drawing" },
            svg      = { color ="blue", fill = true, order = 4 },
        },
    },
    viacutM1M2 = {
        name = "mcon",
        layer = {
            gds      = { layer = 67,     purpose = 44 },
            virtuoso = { layer = "mcon", purpose = "drawing", },
            magic    = { layer = "mcon", purpose = "drawing", },
        },
    },
    M2 = {
        name = "met1",
        layer = {
            gds      = { layer = 68,    purpose = 20 },
            virtuoso = { layer ="met1", purpose = "drawing", },
            magic    = { layer ="met1", purpose = "drawing", },
        },
    },
    viacutM2M3 = {
        name = "via",
        layer = {
            gds      = { layer = 68,      purpose = 44 },
            virtuoso = { layer = "via", purpose = "drawing", },
            magic    = { layer = "via", purpose = "drawing", },
        },
    },
    M3 = {
        name = "met2",
        layer = {
            gds      = { layer = 69,    purpose = 20 },
            virtuoso = { layer ="met2", purpose = "drawing", },
            magic    = { layer ="met2", purpose = "drawing", },
        },
    },
    viacutM3M4 = {
        name = "via2",
        layer = {
            gds      = { layer = 69,     purpose = 44 },
            virtuoso = { layer = "via2", purpose = "drawing", },
            magic    = { layer = "via2", purpose = "drawing", },
        },
    },
    M4 = {
        name = "met3",
        layer = {
            gds      = { layer = 70,    purpose = 20 },
            virtuoso = { layer ="met3", purpose = "drawing", },
            magic    = { layer ="met3", purpose = "drawing", },
        },
    },
    viacutM4M5 = {
        name = "via3",
        layer = {
            gds      = { layer = 70,     purpose = 44 },
            virtuoso = { layer = "via3", purpose = "drawing", },
            magic    = { layer = "via3", purpose = "drawing", },
        },
    },
    M5 = {
        name = "met4",
        layer = {
            gds      = { layer = 71, purpose = 20 },
            virtuoso = { layer = "met4", purpose = "drawing", },
            magic    = { layer = "met4", purpose = "drawing", },
            svg      = { color = "blue", opacity = 0.5, fill = true, order = 1 },
        },
    },
    viacutM5M6 = {
        name = "via4",
        layer = {
            gds      = { layer = 71,     purpose = 44 },
            virtuoso = { layer = "via4", purpose = "drawing" },
            magic    = { layer = "via4", purpose = "drawing" },
            svg      = { color = "white", opacity = 0.5, fill = true, order = 1 },
        },
    },
    M6 = {
        name = "met5",
        layer = {
            gds      = { layer = 72,     purpose = 20        },
            virtuoso = { layer = "met5", purpose = "drawing" },
            magic    = { layer = "met5", purpose = "drawing" },
            svg      = { color = "red",  opacity = 0.5, fill = true, order = 2 },
        }
    },
    padopening = {
        name = "pad",
        layer = {
            gds      = { layer = 76,    purpose = 20        },
            virtuoso = { layer = "pad", purpose = "drawing" },
            magic    = { layer = "pad", purpose = "drawing" },
            svg      = { color = "red",  opacity = 0.5, fill = true, order = 2 },
        },
    },
    --inductor  = { layer = { number = 82, name = "inductor"  }, purpose = { number = 24, name = "drawing" } },
    --momcap    = { layer = { number = 82, name = "capacitor" }, purpose = { number = 64, name = "drawing" } },
    --polyres1  = { layer = { number = 86, name = "rpm"       }, purpose = { number = 20, name = "drawing" } },
    --polyres2  = { layer = { number = 79, name = "urpm"      }, purpose = { number = 20, name = "drawing" } },
    gatecut   = {},
}

-- processed (some are only present in the viarules file)
--[[
nsdm,drawing,93:44,N+ source/drain implant
psdm,drawing,94:20,P+ source/drain implant
poly,"drawing, text",66:20,Polysilicon
nwell,drawing,64:20,N-well region
li1,"drawing, text",67:20,Local interconnect
met1,"drawing, text",68:20,Metal 1
met2,"drawing, text",69:20,Metal 2
met3,"drawing, text",70:20,Metal 3
met4,"drawing, text",71:20,Metal 4
met5,"drawing, text",72:20,Metal 5
dnwell,drawing,64:18,Deep n-well region
pad,"drawing, text",76:20,Passivation cut (opening over pads)
npc,drawing,95:20,Nitride poly cut (under licon1 areas)
licon1,drawing,66:44,Contact to local interconnect
mcon,drawing,67:44,Contact from local interconnect to metal1
via,drawing,68:44,Contact from metal 1 to metal 2
via2,drawing,69:44,Contact from metal 2 to metal 3
via3,drawing,70:44,Contact from metal 3 to metal 4
via4,drawing,71:44,Contact from metal 4 to metal 5
inductor,drawing,82:24,Identifier for inductor regions
capacitor,drawing,82:64,Identifier for interdigitated (vertical parallel plate (vpp)) capacitors
rpm,drawing,86:20,300 ohms/square polysilicon resistor implant
urpm,drawing,79:20,2000 ohms/square polysilicon resistor implant
--]]

-- unprocessed
--[[
Layer name,Purpose,GDS layer:datatype,Description
diff,"drawing, text",65:20,Active (diffusion) area (type opposite of well/substrate underneath)
tap,drawing,65:44,"Active (diffusion) area (type equal to the well/substrate underneath) (i.e., N+ and P+)"
pwbm,drawing,19:44,Regions (in UHVI) blocked from p-well implant (DE MOS devices only)
pwde,drawing,124:20,Regions to receive p-well drain-extended implants
hvtr,drawing,18:20,High-Vt RF transistor implant
hvtp,drawing,78:44,High-Vt LVPMOS implant
ldntm,drawing,11:44,N-tip implant on SONOS devices
hvi,drawing,75:20,High voltage (5.0V) thick oxide gate regions
tunm,drawing,80:20,SONOS device tunnel implant
lvtn,drawing,125:44,Low-Vt NMOS device
hvntm,drawing,125:20,High voltage N-tip implant
nsm,drawing,61:20,Nitride seal mask
capm,drawing,89:44,MiM capacitor plate over metal 3
cap2m,drawing,97:44,MiM capacitor plate over metal 4
vhvi,drawing,74:21,12V nominal (16V max) node identifier
uhvi,drawing,74:22,20V nominal node identifier
npn,drawing,82:20,Base region identifier for NPN devices
pnp,drawing,82:44,Base nwell region identifier for PNP devices
LVS prune,drawing,84:44,Exemption from LVS check (used in e-test modules only)
ncm,drawing,92:44,N-core implant
padCenter,drawing,81:20,Pad center marker
target,drawing,76:44,Metal fuse target
,,,
areaid.sl,identifier,81:1,Seal ring identifier
areaid.ce,identifier,81:2,Memory (SRAM) core cell identifier
areaid.fe,identifier,81:3,Pads in padframe identifier
areaid.sc,identifier,81:4,Standard cell identifier
areaid.sf,identifier,81:6,Signal pad diffusion identifier (for latchup DRC checks)
areaid.sl,identifier,81:7,Signal pad well identifier (for latchup DRC checks)
areaid.sr,identifier,81:8,Signal pad metal (for latchup DRC checks)
areaid.mt,identifier,81:10,Location of e-test modules within the frame
areaid.dt,identifier,81:11,Location of dice within the frame
areaid.ft,identifier,81:12,Boundary of the frame
areaid.ww,identifier,81:13,Waffle window (used to prevent waffle shifting)
areaid.ld,identifier,81:14,Low tap density (15um between taps) area.  Must be at least 50um from padframe
areaid.ns,identifier,81:15,Non-critical side.  Blocks stress DRC rules
areaid.ij,identifier,81:17,Identification for areas susceptible to injection
areaid.zr,identifier,81:18,Zener diode identifier
areaid.ed,identifier,81:19,ESD device identifier
areaid.de,identifier,81:23,Diode identifier
areaid.rd,identifier,81:24,RDL probe pad (not used in this process)
areaid.dn,identifier,81:50,Dead zone (used in seal ring only  for stress DRC)
areaid.cr,identifier,81:51,Critical corner (used in seal ring only for stress DRC)
areaid.cd,identifier,81:52,Critical side (used in seal ring only for stress DRC)
areaid.st,identifier,81:53,Substrate cut.  Idendifies areas to be considered as isolated substrate
areaid.op,identifier,81:54,OPC drop.  Block automatic OPC (for fab blocks and lithocal structures)
areaid.en,identifier,81:57,Extended drain identifier
areaid.en20,identifier,81:58,20V Extended drain identifier
areaid.le,identifier,81:60,3.3V native NMOS identifier (absence indicates a 5V native NMOS)
areaid.hl,identifier,81:63,HV nwell.  Identifies nwells with thin oxide devices connected to high voltage
areaid.sd,identifier,81:70,subcircuit identifier (for LVS extraction)
areaid.po,identifier,81:81,Photodiode device identifier
areaid.it,identifier,81:84,IP exempt from DFM rules
areaid.et,identifier,81:101,e-test module identifier
areaid.lvt,identifier,81:108,Low-Vt identifier
areaid.re,identifier,81:125,RF diode identifier
,,,
fom,dummy,22:23,
,,,
poly,gate,66:9,
,,,
poly,model,66:83,(Text type)
,,,
poly,resistor,66:13,
diff,resistor,65:13,
pwell,resistor,64:13,
li1,resistor,67:13,
,,,
diff,high voltage,65:8,
,,,
met4,fuse,71:17,
,,,
inductor,terminal1,82:26,
inductor,terminal2,82:27,
inductor,terminal3,82:28,
,,,
li1,block,67:10,
met1,block,68:10,
met2,block,69:10,
met3,block,70:10,
met4,block,71:10,
met5,block,72:10,
,,,
prBndry,boundary,235:4,
diff,boundary,65:4,
tap,boundary,65:60,
mcon,boundary,67:60,
poly,boundary,66:4,
via,boundary,68:60,
via2,boundary,69:60,
via3,boundary,70:60,
via4,boundary,71:60,
,,,
li1,label,67:5,(Text type)
met1,label,68:5,(Text type)
met2,label,69:5,(Text type)
met3,label,70:5,(Text type)
met4,label,71:5,(Text type)
met5,label,72:5,(Text type)
poly,label,66:5,(Text type)
diff,label,65:6,(Text type)
pwell,label,64:59,(Text and data type)
pwelliso,label,44:5,(Text type)
pad,label,76:5,(Text type)
tap,label,65:5,
nwell,label,64:5,
inductor,label,82:25,
,,,
text,label,83:44,(Text type)
,,,
li1,net,67:23,(Text type)
met1,net,68:23,(Text type)
met2,net,69:23,(Text type)
met3,net,70:23,(Text type)
met4,net,71:23,(Text type)
met5,net,72:23,(Text type)
poly,net,66:23,(Text type)
diff,net,65:23,(Text type)
,,,
li1,pin,67:16,(Text and data)
met1,pin,68:16,(Text and data)
met2,pin,69:16,(Text and data)
met3,pin,70:16,(Text and data)
met4,pin,71:16,(Text and data)
met5,pin,72:16,(Text and data)
poly,pin,66:16,(Text and data)
diff,pin,65:16,(Text and data)
nwell,pin,64:16,(Text type)
pad,pin,76:16,(Text and data)
pwell,pin,122:16,(Text and data)
pwelliso,pin,44:16,(Text and data)
,,,
nwell,pin,64:0,(Text type)
poly,pin,66:0,(Text type)
li1,pin,67:0,(Text type)
met1,pin,68:0,(Text type)
met2,pin,69:0,(Text type)
met3,pin,70:0,(Text type)
met4,pin,71:0,(Text type)
met5,pin,72:0,(Text type)
pad,pin,76:0,(Text type)
pwell,pin,122:0,(Text type)
,,,
diff,cut,65:14,
poly,cut,66:14,
li1,cut,67:14,
met1,cut,68:14,
met2,cut,69:14,
met3,cut,70:14,
met4,cut,71:14,
met5,cut,72:14,
pwell,cut,,
,,,
met5,probe,72:25,
met4,probe,71:25,
met3,probe,70:25,
met2,probe,69:25,
met1,probe,68:25,
li1,probe,67:25,
poly,probe,66:25,
,,,
poly,short,66:15,
li1,short,67:15,
met1,short,68:15,
met2,short,69:15,
met3,short,70:15,
met4,short,71:15,
met5,short,72:15,
,,,
Mask level data,,,
,,,
cncm,mask,17:0,N-core implant mask
crpm,mask,96:0,Resistor Protect mask
cpdm,mask,37:0,Pad mask
cnsm,mask,22:0,Nitride seal mask
cmm5,mask,59:0,Metal 5 mask
cviam4,mask,58:0,Via 4 mask
cmm4,mask,51:0,Metal 4 mask
cviam3,mask,50:0,Via 3 mask
cmm3,mask,34:0,Metal 3 mask
cviam2,mask,44:0,Via 2 mask
cmm2,mask,41:0,Metal 2 mask
cviam,mask,40:0,Via mask
cmm1,mask,36:0,Metal 1 mask
ctm1,mask,35:0,Contact mask
cli1m,mask,56:0,Local interconnect mask
clicm1,mask,43:0,Local interconnect contact mask
cpsdm,mask,32:0,P+ Implant mask
cnsdm,mask,30:0,N+ Implant mask
cldntm,mask,11:0,Lightly-doped N-tip implant mask
cnpc,mask,49:0,Nitride poly cut mask
chvntm,mask,39:0,High voltage N-tip implant mask
cntm,mask,27:0,N-tip implant mask
cp1m,mask,28:0,Poly 1 mask
clvom,mask,46:0,Low Voltage oxide mask
conom,mask,88:0,ONO Mask
ctunm,mask,20:0,Tunnel mask
chvtrm,mask,98:0,HLow VT PCh Radio mask
chvtpm,mask,97:0,High Vt Pch mask
clvtnm,mask,25:0,Low Vt Nch mask
cnwm,mask,21:0,Nwell mask
cdnm,mask,48:0,Deep nwell mask
cfom,mask,23:0,Field oxide mask
,,,
cfom,drawing,22:20,
clvtnm,drawing,25:44,
chvtpm,drawing,88:44,
conom,drawing,87:44,
clvom,drawing,45:20,
cntm,drawing,26:20,
chvntm,drawing,38:20,
cnpc,drawing,44:20,
cnsdm,drawing,29:20,
cpsdm,drawing,31:20,
cli1m,drawing,115:44,
cviam3,drawing,112:20,
cviam4,drawing,117:20,
cncm,drawing,96:44,
,,,
cntm,mask add,26:21,
clvtnm,mask add,25:43,
chvtpm,mask add,97:43,
cli1m,mask add,115:43,
clicm1,mask add,106:43,
cpsdm,mask add,31:21,
cnsdm,mask add,29:21,
cp1m,mask add,33:43,
cfom,mask add,22:21,
,,,
cntm,mask drop,26:22,
clvtnm,mask drop,25:42,
chvtpm,mask drop,97:42,
cli1m,mask drop,115:42,
clicm1,mask drop,106:42,
cpsdm,mask drop,31:22,
cnsdm,mask drop,29:22,
cp1m,mask drop,33:42,
cfom,mask drop,22:22,
,,,
cmm4,waffle drop,112:4,
cmm3,waffle drop,107:24,
cmm2,waffle drop,105:52,
cmm1,waffle drop,62:24,
cp1m,waffle drop,33:24,
cfom,waffle drop,22:24,
cmm5,waffle drop,117:4,
--]]

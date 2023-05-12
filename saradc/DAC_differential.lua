local cell = object.create("toplevel")

-- basic mos parameters
local gatelength = 20
local gatespace = 84
local fingerwidth = 500
local nfetvthtype = 1
local pfetvthtype = 3
local sdwidth = 40
local sdspace = 80
local powerwidth = 3 * sdwidth
local powerspace = 3 * sdspace

-- switch_network parameters
local buffingers = 2
local switchfingers = 8

-- buf_array parameters
local buff1ingers = 4
local buff2ingers = 2

-- cap_array parameters
local bits = 6
local rwidth = 100


-- sample and hold up
local sample_and_hold_up = pcell.create_layout("SAR_ADC/sample_and_hold", "sample_and_hold_up", {
    buffingers = buffingers,
    gatelength = gatelength,
    gatespace = gatespace,
    fingerwidth = fingerwidth,
    nfetvthtype = nfetvthtype,
    pfetvthtype = pfetvthtype,
    sdwidth = sdwidth,
    sdspace = sdspace,
    gstrwidth = sdwidth,
    gstrspace = sdspace,
    powerwidth = powerwidth,
    powerspace = powerspace
})
cell:merge_into_shallow(sample_and_hold_up:flatten())

-- sample and hold down
local sample_and_hold_down = sample_and_hold_up:copy()
sample_and_hold_down:move_anchor("top", sample_and_hold_up:get_anchor("bottom"))
cell:merge_into_shallow(sample_and_hold_down:flatten())

-- buf array
local buf_array = pcell.create_layout("SAR_ADC/buf_array", "buf_array", {
    buf1fingers = buf1fingers,
    buf2fingers = buf2fingers,
    gatelength = gatelength,
    gatespace = gatespace,
    fingerwidth = fingerwidth,
    nfetvthtype = nfetvthtype,
    pfetvthtype = pfetvthtype,
    sdwidth = sdwidth,
    sdspace = sdspace,
    gstrwidth = sdwidth,
    gstrspace = sdspace,
    powerwidth = powerwidth,
    powerspace = powerspace
})
buf_array:move_anchor("right", sample_and_hold_up:get_anchor("bottomleft"):translate(-100,0))
cell:merge_into_shallow(buf_array:flatten())

-- switch network up
local swupref = pcell.create_layout("SAR_ADC/switch_network_up", "swupref", {
    buffingers = buffingers,
    switchfingers = switchfingers,
    gatelength = gatelength,
    gatespace = gatespace,
    fingerwidth = fingerwidth,
    nfetvthtype = nfetvthtype,
    pfetvthtype = pfetvthtype,
    sdwidth = sdwidth,
    sdspace = sdspace,
    gstrwidth = sdwidth,
    gstrspace = sdspace,
    powerwidth = powerwidth,
    powerspace = powerspace
})

local swups = {}
for i = 1, bits +1 do
    if i == 1 then
        local swup = swupref:copy()
        swup:move_anchor("left", sample_and_hold_up:get_anchor("right"):translate(200,0))
        swups[1] = swup
        cell:merge_into_shallow(swup)
    end
    if i > 1 then
        local swup = swupref:copy()
        swup:move_anchor("left", swups[i-1]:get_anchor("right"):translate( 400, 0))	
        cell:merge_into_shallow(swup)
        swups[i] = swup
    end	
end

-- switch network down
local swdownref = pcell.create_layout("SAR_ADC/switch_network_down", "swdownref", {
    buffingers = buffingers,
    switchfingers = switchfingers,
    gatelength = gatelength,
    gatespace = gatespace,
    fingerwidth = fingerwidth,
    nfetvthtype = nfetvthtype,
    pfetvthtype = pfetvthtype,
    sdwidth = sdwidth,
    sdspace = sdspace,
    gstrwidth = sdwidth,
    gstrspace = sdspace,
    powerwidth = powerwidth,
    powerspace = powerspace
})

local swdowns = {}
for i = 1, bits +1 do
    local swdown = swdownref:copy()
    swdown:move_anchor("topleft", swups[i]:get_anchor("bottomleft"))
    swdowns[i] = swdown
    cell:merge_into_shallow(swdown)
end

-- cap array up
local cap_array_up = pcell.create_layout("SAR_ADC/cap_array", "cap_array_up", {
    bits = bits,
    rwidth = rwidth
})
if bits >=6 then
    cap_array_up:move_anchor("s5bc", swups[ bits - 5 ]:get_anchor("vouttc"):translate( 0 , 100 * bits - 100))
elseif bits == 4 then
    cap_array_up:move_anchor("s3bc", swups[ 1 ]:get_anchor("vouttc"):translate( 0 , 200))
end
cell:merge_into_shallow(cap_array_up:flatten())

-- cap array down
local cap_array_down = cap_array_up:copy()
cap_array_down:mirror_at_xaxis()
if bits >=6 then
    cap_array_down:move_anchor("s5bc", swdowns[ bits - 5 ]:get_anchor("voutbc"):translate(0, - 100 * bits + 100)) -- bug here. mirror affecting anchor
elseif bits == 4 then
    cap_array_down:move_anchor("s3bc", swdowns[ 1 ]:get_anchor("voutbc"):translate(0, - 200)) -- bug here. mirror affecting anchor
end
cell:merge_into_shallow(cap_array_down:flatten())


-- connect VDD
geometry.path(cell, generics.metal(1),{
    buf_array:get_anchor("VDD1cr"),
    swups[bits + 1]:get_anchor("VDDcl")
},  powerwidth)
geometry.path(cell, generics.metal(1),{
    buf_array:get_anchor("VDD2cr"),
    swdowns[bits + 1]:get_anchor("VDDcl")
},  powerwidth)
geometry.path_cshape(cell, generics.metal(1),
buf_array:get_anchor("VDD1cl"), 
buf_array:get_anchor("VDD2cl"), 
buf_array:get_anchor("VDD2cl"):translate(-powerspace, 0), 
powerwidth)

-- connect VSS
geometry.path(cell, generics.metal(1),{
    buf_array:get_anchor("VSS1cr"),
    swups[bits + 1]:get_anchor("VSScl")
},  powerwidth)
geometry.path(cell, generics.metal(1),{
    buf_array:get_anchor("VSS2cr"),
    swdowns[bits + 1]:get_anchor("VSScl")
},  powerwidth)
geometry.path_cshape(cell, generics.metal(1),
swups[bits + 1]:get_anchor("VSScr"), 
swdowns[bits + 1]:get_anchor("VSScr"), 
swdowns[bits + 1]:get_anchor("VSScr"):translate( powerspace, 0), 
powerwidth)

-- connect sample
geometry.path(cell, generics.metal(2),{
    sample_and_hold_up:get_anchor("samplebl"),
    sample_and_hold_up:get_anchor("VDDtl"):translate( - 0.5 * sdwidth, sdspace )
},  sdwidth)
geometry.path(cell, generics.metal(2),{
    sample_and_hold_down:get_anchor("sampletl"),
    sample_and_hold_down:get_anchor("VSSbl"):translate( - 0.5 * sdwidth, - sdspace )
},  sdwidth)

for i = 1, 0.5 * bits do
    geometry.path(cell, generics.metal(2),{
        swups[i]:get_anchor("samplebl"),
        swups[i]:get_anchor("VDDtl"):translate(- 0.5 * sdspace - 0.5 * sdwidth, sdspace )
    },  sdwidth)
    geometry.path(cell, generics.metal(2),{
        swdowns[i]:get_anchor("sampletl"),
        swdowns[i]:get_anchor("VSSbl"):translate(- 0.5 * sdspace - 0.5 * sdwidth, - sdspace )
    },  sdwidth)
end
for i = 0.5 * bits + 1, bits + 1 do
    geometry.path(cell, generics.metal(2),{
        swups[i]:get_anchor("sampletl"),
        swups[i]:get_anchor("VSSbl"):translate(- 0.5 * sdspace - 0.5 * sdwidth, - sdspace )
    },  sdwidth)
    geometry.path(cell, generics.metal(2),{
        swdowns[i]:get_anchor("samplebl"),
        swdowns[i]:get_anchor("VDDtl"):translate(- 0.5 * sdspace - 0.5 * sdwidth, sdspace )
    },  sdwidth)
end
geometry.path(cell, generics.metal(2),{
    buf_array:get_anchor("out1tl"),
    swups[0.5 * bits]:get_anchor("VDDtl"):translate(- 0.5 * sdspace, sdspace )
},  sdwidth)
geometry.path(cell, generics.metal(2),{
    buf_array:get_anchor("out2bl"),
    swups[bits + 1]:get_anchor("VSSbl"):translate(- 0.5 * sdspace, - sdspace )
},  sdwidth)
geometry.path(cell, generics.metal(2),{
    buf_array:get_anchor("out4tl"),
    swdowns[bits + 1]:get_anchor("VDDtl"):translate(- 0.5 * sdspace, sdspace )
},  sdwidth)
geometry.path(cell, generics.metal(2),{
    buf_array:get_anchor("out3bl"),
    swdowns[0.5 * bits]:get_anchor("VSSbl"):translate(- 0.5 * sdspace, - sdspace )
},  sdwidth)

-- connect DN to D0
for i = 1, bits do
    geometry.path_cshape(cell, generics.metal(3),
    swups[i]:get_anchor("datacr"), 
    swdowns[i]:get_anchor("databr"):translate( - 0.5 * sdwidth, 0 ), 
    swdowns[i]:get_anchor("databr"):translate( - 0.5 * sdwidth, 0 ), 
    sdwidth)
end

-- connect Ddummy
geometry.path_cshape(cell, generics.metal(1),
swups[bits + 1]:get_anchor("datacr"), 
swdowns[bits + 1]:get_anchor("datacr"), 
swdowns[bits + 1]:get_anchor("datacr"):translate( 2 * sdwidth, 0 ), 
sdwidth)

-- connect vinn and vinp
geometry.path(cell, generics.metal(4),{
    swups[1]:get_anchor("vintl"),
    swups[bits+1]:get_anchor("vintr")
},  sdwidth)
geometry.path(cell, generics.metal(4),{
    swdowns[1]:get_anchor("vintl"),
    swdowns[bits+1]:get_anchor("vintr")
},  sdwidth)

-- connect VCM
geometry.viabltr(cell, 1, 4, 
sample_and_hold_up:get_anchor("vindownbl"),
sample_and_hold_up:get_anchor("vindowntr")
)

geometry.viabltr(cell, 1, 4, 
sample_and_hold_down:get_anchor("vinupbl"),
sample_and_hold_down:get_anchor("vinuptr")
)

geometry.path(cell, generics.metal(4),{
    sample_and_hold_up:get_anchor("vindowntl"),
    sample_and_hold_down:get_anchor("vinupbl")
},  sdwidth)


-- connect REF
geometry.path(cell, generics.metal(5),{
    swups[1]:get_anchor("REFtl"),
    swups[bits+1]:get_anchor("REFtr")
},  sdwidth)
geometry.path(cell, generics.metal(5),{
    swdowns[1]:get_anchor("REFbl"),
    swdowns[bits+1]:get_anchor("REFbr")
},  sdwidth)

geometry.path_cshape(cell, generics.metal(5),
swups[bits+1]:get_anchor("REFtr"), 
swdowns[bits+1]:get_anchor("REFbr"), 
swups[bits+1]:get_anchor("REFtr"):translate(3*powerspace, 0), 
sdwidth)
-- connect GND
geometry.path(cell, generics.metal(5),{
    swups[1]:get_anchor("GNDbl"),
    swdowns[bits+1]:get_anchor("GNDtr")
},  sdwidth)
-- connect voutp
geometry.path_cshape(cell, generics.metal(3),
cap_array_up:get_anchor("voutbr"),
sample_and_hold_up:get_anchor("vouttc"),
sample_and_hold_up:get_anchor("vouttc"),
rwidth)
-- connect voutn
geometry.path_cshape(cell, generics.metal(3),
cap_array_down:get_anchor("voutbr"),
sample_and_hold_down:get_anchor("voutbc"),
sample_and_hold_down:get_anchor("voutbc"),
rwidth)

-- connect sdummy
geometry.path_cshape(cell, generics.metal(3),
swups[bits+1]:get_anchor("vouttc"), 
cap_array_up:get_anchor("sdummybc"):translate(0, 0.5 * sdwidth), 
swups[bits+1]:get_anchor("vouttc"), 
sdwidth)
geometry.path_cshape(cell, generics.metal(3),
swdowns[bits+1]:get_anchor("voutbc"), 
cap_array_down:get_anchor("sdummybc"):translate(0, - 0.5 * sdwidth), 
swdowns[bits+1]:get_anchor("vouttc"), 
sdwidth)

-- connect sN to s0 between switches and cap array
for i = 1, bits  do
    geometry.path_cshape(cell, generics.metal(3),
    swups[i]:get_anchor("vouttc"), 
    cap_array_up:get_anchor(string.format("s%dbc", bits-i)):translate(0, 0.5 * sdwidth), 
    swups[i]:get_anchor("vouttc"), 
    sdwidth)
    geometry.path_cshape(cell, generics.metal(3),
    swdowns[i]:get_anchor("voutbc"), 
    cap_array_down:get_anchor(string.format("s%dbc", bits-i)):translate(0, - 0.5 * sdwidth), 
    swdowns[i]:get_anchor("vouttc"), 
    sdwidth)
end

-- VSS port virtual
cell:add_port("VSS", generics.otherport("nwell"), point.create(-1000, 0))
cell:add_port("VSS", generics.metalport(1), point.create(0, -1370))
for i = 1, bits +2  do
    cell:add_port("VSS", generics.otherport("nwell"), point.create(3832 * i - 3832, 0))
end

-- add port
cell:add_port("VDD", generics.metalport(1), buf_array:get_anchor("VDD1cc"))
cell:add_port("VSS", generics.metalport(1), buf_array:get_anchor("VSS1cc"))
cell:add_port("REF", generics.metalport(5), swups[bits+1]:get_anchor("REFcc"))
cell:add_port("GND", generics.metalport(5), swups[bits+1]:get_anchor("GNDcc"))
cell:add_port("VCM", generics.metalport(4), sample_and_hold_up:get_anchor("vindowncc"))
cell:add_port("sample", generics.metalport(2), buf_array:get_anchor("samplecc"))
cell:add_port("vinp", generics.metalport(4), swdowns[bits+1]:get_anchor("vincc"))
cell:add_port("vinn", generics.metalport(4), swups[bits+1]:get_anchor("vincc"))
for i = 1, bits  do
    cell:add_port(string.format("D<%d>", bits-i), generics.metalport(3), swups[i]:get_anchor("datacr"):translate( 0.5 * sdwidth, 0))
end
cell:add_port("voutp", generics.metalport(3), cap_array_up:get_anchor("voutcc"))
cell:add_port("voutn", generics.metalport(3), cap_array_down:get_anchor("voutcc"))

return cell

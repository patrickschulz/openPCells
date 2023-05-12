local cell = object.create("toplevel")

local buffingers = 2
local switchfingers = 8
local gatelength = 20
local gatespace = 84
local fingerwidth = 500
local nfetvthtype = 1
local pfetvthtype = 3
local sdwidth = 40
local sdspace = 80


local swup7 = pcell.create_layout("SAR_ADC/switch_network_up", "swup7", {
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
	powerwidth = 3 * sdwidth,
	powerspace = 3 * sdspace
})

cell:merge_into_shallow(swup7:flatten())

--[[

cell:add_port("VDD", generics.metalport(1), swup7:get_anchor("VDD"))
cell:add_port("VSS", generics.metalport(1), swup7:get_anchor("VSS"))
cell:add_port("sample", generics.metalport(1), swup7:get_anchor("sample"))
cell:add_port("vin", generics.metalport(2), swup7:get_anchor("vin"))
cell:add_port("vout", generics.metalport(3), swup7:get_anchor("vout"))
cell:add_port("data", generics.metalport(1), swup7:get_anchor("data"))
cell:add_port("REF", generics.metalport(1), swup7:get_anchor("REF"))
cell:add_port("GND", generics.metalport(1), swup7:get_anchor("GND"))
cell:add_port("VSS", generics.otherport("nwell"), point.create(0, -1500))


--]]


return swup7


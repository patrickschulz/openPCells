local cell = object.create("toplevel")

local buffingers = 2
local gatelength = 20
local gatespace = 84
local fingerwidth = 500
local nfetvthtype = 1
local pfetvthtype = 3
local sdwidth = 40
local sdspace = 80

pcell.push_overwrites("basic/mosfet", { actext = 100 })

local sample_and_hold = pcell.create_layout("SAR_ADC/sample_and_hold", "sample_and_hold", {
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
	powerwidth = 3 * sdwidth,
	powerspace = 3 * sdspace

})
cell:merge_into(sample_and_hold)

pcell.pop_overwrites("basic/mosfet")

return sample_and_hold

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
local bits = 8
local rwidth = 100

-- cap array up
local cap_array_up = pcell.create_layout("SAR_ADC/cap_array", "cap_array_up", {
    bits = bits,
    rwidth = rwidth
})
cell:merge_into(cap_array_up)

return cell

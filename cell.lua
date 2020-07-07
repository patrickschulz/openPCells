--[[
local scripthome = "/home/pschulz/path/"
package.path = package.path .. string.format(";%s/?.lua", scripthome) .. string.format(";%s/interface/?.lua", scripthome)

local point = require "point"
local object = require "object"
local layout = require "layout"
local virtuoso = require "interface.virtuoso"
--]]

local M = {}

local celllist = {
    "transistor"
}

local cellcode = {}
for _, cell in ipairs(celllist) do
    cellcode[cell] = dofile(string.format("cells/%s.lua", cell))
end

function M.create(name, options)
    local func = cellcode[name]
    return func()
end

return M

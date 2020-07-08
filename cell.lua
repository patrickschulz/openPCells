--[[
local scripthome = "/home/pschulz/path/"
package.path = package.path .. string.format(";%s/?.lua", scripthome) .. string.format(";%s/interface/?.lua", scripthome)

local point = require "point"
local object = require "object"
local layout = require "layout"
local virtuoso = require "interface.virtuoso"
--]]

local M = {}

local installpath = "/home/pschulz/path"

local celllist = {
    "transistor",
    "momcap"
}

local cellcode = {}
for _, cell in ipairs(celllist) do
    cellcode[cell] = dofile(string.format("%s/cells/%s.lua", installpath, cell))
end

function M.create(name, options)
    local func = cellcode[name]
    if not func then return nil end
    return func()
end

return M

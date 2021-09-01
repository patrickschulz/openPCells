local entries = {}
local entryfunc = function(t) table.insert(entries, t) end
store_multiple = entryfunc
store_multiple_string = entryfunc
store = entryfunc
switch = entryfunc
section = entryfunc
consumer_string = entryfunc

local cmdoptions = require "cmdoptions"

print([[
.TH opc 1 "26 Aug 2021" "1.0" "opc man page"
.SH NAME
opc \- parametric and technology-independent IC layout generator
.SH SYNOPSIS
opc [--cell cellname] [--technology technology] [--export export]
.SH DESCRIPTION
.B opc 
is a technology-independent layout generator for integrated circuits with support for parametric cells.
]])

-- print options
for _, entry in ipairs(entries) do
    if type(entry) == "string" then
        print(entry)
    else
        if entry.short then
            if entry.long then
                print(string.format('.IP "%s,%s"', entry.short, entry.long))
            else
                print(string.format('.IP "%s"', entry.short))
            end
        else
            print(string.format('.IP "%s"', entry.long))
        end
        print(entry.help)
    end
end

print([[
.SH AUTHOR
Patrick Kurth <p.kurth@posteo.de>
]])

local entries = {}
local entryfunc = function(what) 
    return function(t) table.insert(entries, { short = t.short, long = t.long, help = t.help, what = what }) end
end
store_multiple = entryfunc()
store_multiple_string = entryfunc()
store = entryfunc("arg")
switch = entryfunc()
section = function(s) table.insert(entries, s) end
consumer_string = entryfunc()

local cmdoptions = _load_module("cmdoptions")

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
        print(string.format('.SS "%s"', entry))
    else
        local fmt = '.IP "\\fB\\%s\\fR %s" 4'
        local entryfmt = ""
        if entry.short and entry.long then
            entryfmt = string.format("%s,%s", entry.short, entry.long)
        elseif entry.short then
            entryfmt = string.format("%s", entry.short)
        elseif entry.long then
            entryfmt = string.format("%s", entry.long)
        end
        local argfmt = ""
        if entry.what then
            argfmt = string.format("\\fI%s\\fR", entry.what)
        end
        print(string.format(fmt, entryfmt, argfmt))
        print(entry.help)
    end
    print()
end

print([[
.SH AUTHOR
Patrick Kurth <p.kurth@posteo.de>
]])

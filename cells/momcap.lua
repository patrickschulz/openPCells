local scripthome = "/home/pschulz/path"

package.path = package.path .. string.format(";%s/?.lua", scripthome) .. string.format(";%s/interface/?.lua", scripthome)

local layout = require "layout"
local virtuoso = require "virtuoso"

local fingers = 8
local alternating = nil
local fwidth = 0.05
local fspace = 0.05
local flength = 1.0
local foffset = 0.1
local finger = 1
local rwidth = 0.1
--[[
    letseq(
        (   
            (metallist MSCLayoutGetMetalList(start end))
            (mod 1)
        )
        ; draw finger
        foreach(layer metallist
            let(
                (color shapes)
                when(layer == "M1"
                    color = list(nil 'first "mask1Color" 'second "mask2Color" 'rfirst "mask1Color" 'rsecond "mask2Color")
                )
                when(layer == "M2"
                    color = list(nil 'first "mask2Color" 'second "mask1Color" 'rfirst "mask1Color" 'rsecond "mask2Color")
                )
                shapes = MSCLayoutCreateRectangle(pcCellView
                    ?layer layer
                    ?width fwidth
                    ?height flength
                    ?xrep finger + 1
                    ?xpitch 2 * (fwidth + fspace)
                    ?yoffset mod * 0.5 * foffset
                )
                unless(color == nil
                    MSCLayoutColorShapes(shapes color->first)
                )
                shapes = MSCLayoutCreateRectangle(pcCellView
                    ?layer layer
                    ?width fwidth
                    ?height flength
                    ?xrep finger
                    ?xpitch 2 * (fwidth + fspace)
                    ?yoffset -mod * 0.5 * foffset
                )
                unless(color == nil
                    MSCLayoutColorShapes(shapes color->second)
                )
                when(alternating
                    mod = -mod
                )               
                ; draw rails
                shapes = MSCLayoutCreateRectangle(pcCellView
                    ?layer layer
                    ?width (2 * finger + 1) * (fwidth + fspace)
                    ?height rwidth
                    ?yrep 2
                    ?ypitch 2 * foffset + flength
                )
                unless(color == nil
                    MSCLayoutColorShapes(list(car(shapes)) color->rfirst)
                    MSCLayoutColorShapes(list(cadr(shapes)) color->rsecond)
                )
            ) ; let
        ) ; foreach
    ); let 
) ; pcDefinePCell
--]]

local pts = layout.rectangle({x = 0, y = 0}, 1, 2)
print(pts)

--virtuoso.print_points(pts)

local M = {}

local meta = {}
meta.__index = meta

function M.create()
    local self = {
        objects = {},
    }
    setmetatable(self, meta)
    return self
end

function meta.add(self, cell)
    table.insert(self.objects, cell)
end
M.add = meta.add

local function _get_alignment_box(self)
    local bl, tr
    for _, entry in ipairs(self.objects) do
        if object.is_object(entry) then
            if not bl then
                bl = entry:get_alignment_anchor("outerbl")
                tr = entry:get_alignment_anchor("outertr")
                print(bl, tr)
            else
                local cbl = entry:get_alignment_anchor("outerbl")
                local ctr = entry:get_alignment_anchor("outertr")
                local blx = math.min(bl:getx(), cbl:getx())
                local bly = math.min(bl:gety(), cbl:gety())
                local trx = math.max(tr:getx(), ctr:getx())
                local try = math.max(tr:gety(), ctr:gety())
                bl:setx(blx)
                bl:sety(bly)
                tr:setx(trx)
                tr:sety(try)
            end
        else -- nested alignmentgroup
            local gbl, btr = _get_alignment_box(entry)
        end
    end
    return bl, tr
end

function meta.abut_right(self, reference)
    local bl, tr = _get_alignment_box(self)
    print(bl, tr)
end

return M

-- This is the pseudo generics module used by the technology module to load layer map files
-- This should only be loaded by the technology module when loading layer maps.
-- The real generics module is created by the lua part of the technology module.

local M = {}

function M.metal(index)
    return string.format("M%d", index)
end

function M.mptmetal(index, maskindex)
    return string.format("M%d_%d", index, maskindex)
end

function M.metalport(index)
    return string.format("M%dport", index)
end

function M.metalfill(index)
    return string.format("M%dfill", index)
end

function M.mptmetalfill(index, maskindex)
    return string.format("M%d_%dfill", index, maskindex)
end

function M.metalexclude(index)
    return string.format("M%dexclude", index)
end

function M.viacut(index1, index2)
    return string.format("viacutM%dM%d", index1, index2)
end

function M.contact(region)
    return string.format("contact%s", region)
end

function M.oxide(index)
    return string.format("oxide%d", index)
end

function M.implant(region)
    return string.format("%simplant", region)
end

function M.well(region, type)
    local rtype
    if not type or type == "regular" then
        rtype = ""
    else
        rtype = type
    end
    return string.format("%s%swell", rtype, region)
end

function M.vthtype(type, index)
    return string.format("vthtype%s%d", type, index)
end

function M.active()
    return "active"
end

function M.gate()
    return "gate"
end

function M.feol(what)
    return what
end

function M.beol(what)
    return what
end

function M.marker(type, index)
    return string.format("%smarker%d", type, index)
end

function M.other(what)
    return what
end

function M.exclude(what)
    return string.format("%sexclude", what)
end

function M.fill(what)
    return string.format("%sfill", what)
end

function M.otherport(what)
    return string.format("%sport", what)
end

function M.outline()
    return "outline"
end

function M.special()
    return "special"
end

function M.text()
    return "text"
end

return M

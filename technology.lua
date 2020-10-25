local M = {}

local layermap
local config

-- make relative metal (negative indices) absolute
function M.translate_metals(cell)
    for _, s in cell:iter(function(S) return S.lpp:is_type("metal") end) do
        if s.lpp.value < 0 then
            s.lpp.value = config.metals + s.lpp.value + 1
        end
    end
    for _, s in cell:iter(function(S) return S.lpp:is_type("via") end) do
        if s.lpp.value.from < 0 then
            s.lpp.value.from = config.metals + s.lpp.value.from + 1
        end
        if s.lpp.value.to < 0 then
            s.lpp.value.to = config.metals + s.lpp.value.to + 1
        end
        -- reorder
        if s.lpp.value.from > s.lpp.value.to then
            s.lpp.value.from, s.lpp.value.to = s.lpp.value.to, s.lpp.value.from
        end
    end
end

function M.place_via_conductors(cell)
    for i, S in cell:iter() do
        if S.lpp:is_type("via") then
            local m1, m2 = S.lpp:get()
            local s1 = S:copy()
            s1.lpp = generics.metal(m1)
            local s2 = S:copy()
            s2.lpp = generics.metal(m2)
            cell:add_shape(s1)
            cell:add_shape(s2)
        elseif S.lpp:is_type("contact") then
            -- FIXME: can't place active contact surrounding as this needs more data than available here
            local smetal = S:copy()
            smetal.lpp = generics.metal(1)
            cell:add_shape(smetal)
        end
    end
end

function M.split_vias(cell)
    for i, S in cell:iter(function(S) return S:is_lpp_type("via") end) do
        local from, to = S.lpp:get()
        for i = from, to - 1 do
            local sc = S:copy()
            sc.lpp = generics.via(i, i + 1)
            cell:add_shape(sc)
        end
        cell:remove_shape(i)
    end
end

local function _get_lpp(lpp, interface)
    if type(lpp) == "function" then
        lpp = lpp()
    end
    if not lpp[interface] then
        error(string.format("no layer information for '%s' for interface '%s'", layer, interface), 0)
    end
    return lpp[interface]
end

function M.translate(cell, interface)
    for i, S in cell:iter() do
        local layer = S.lpp:str()
        local mappings = layermap[layer]
        if not mappings then
            error(string.format("no layer information for '%s'\nif the layer is not provided, set it to {}", layer), 0)
        end
        for _, entry in ipairs(mappings) do
            local lpp = entry.lpp
            if entry.action == "map" then
                if type(lpp) == "function" then
                    lpp = lpp(S.lpp:get())
                end
                if lpp then
                    local new = S:copy()
                    new.lpp = generics.mapped(_get_lpp(lpp, interface))
                    if entry.xsize > 0 or entry.ysize > 0 then
                        new:resize(entry.xsize, entry.ysize)
                    end
                    cell:add_shape(new)
                end
            elseif entry.action == "array" then
                local width = S:width()
                local height = S:height()
                local c = S:center()
                local xrep = math.max(1, math.floor((width + entry.xspace - 2 * entry.xencl) / (entry.width + entry.xspace)))
                local yrep = math.max(1, math.floor((height + entry.yspace - 2 * entry.yencl) / (entry.height + entry.yspace)))
                local xpitch = entry.width + entry.xspace
                local ypitch = entry.height + entry.yspace
                local enlarge = 0
                local cut = geometry.multiple(
                    geometry.rectangle(generics.mapped(_get_lpp(lpp, interface)), entry.width + enlarge, entry.height + enlarge),
                    xrep, yrep, xpitch, ypitch
                )
                cell:merge_into(cut:translate(c:unwrap()))
            end
        end
        cell:remove_shape(i)
    end
end

function M.fix_to_grid(cell)
    for _, s in cell:iter() do
        for _, pt in pairs(s.points) do
            pt:fix(config.grid)
        end
    end
end

local function _load_layermap(name)
    local env = {
        map = function(entry)
            return {
                action = "map",
                lpp = entry.lpp,
                xsize = entry.xsize or 0,
                ysize = entry.ysize or 0,
            }
        end,
        array = function(entry)
            return {
                action = "array",
                lpp = entry.lpp,
                width = entry.width,
                height = entry.height,
                xspace = entry.xspace,
                yspace = entry.yspace,
                xencl = entry.xencl,
                yencl = entry.yencl,
            }
        end,
        refer = function(reference)
            return function()
                return layermap[reference]
            end
        end,
    }
    local chunk, msg = loadfile(
        string.format("%s/tech/%s/layermap.lua", _get_opc_home(), name, layermap),
        "t", env
    )
    if not chunk then
        error(string.format("error while loading layermap for technology '%s': %s", name, msg), 0)
    end
    local status, ret = pcall(chunk)
    if not status then
        error(string.format("semantic error in layermap for technology '%s': %s", name, ret))
    end
    return ret
end

local function _load_config(name)
    local chunk, msg = loadfile(string.format("%s/tech/%s/config.lua", _get_opc_home(), name))
    if not chunk then
        error(string.format("error while loading configuration for technology '%s': %s", name, msg), 0)
    end
    local status, ret = pcall(chunk)
    if not status then
        error(string.format("semantic error in configuration for technology '%s': %s", name, ret))
    end
    return ret
end


function M.load(name)
    layermap = _load_layermap(name)
    config   = _load_config(name)
end

return M

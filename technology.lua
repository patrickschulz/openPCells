local M = {}

local layermap
local viarules
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

local function _map_layer(S, interface)
    local layer = S.lpp:str()
    local t = layermap[layer]
    if t == "UNUSED" then
        return false
    end
    if not t then
        print(string.format("no layer information for '%s'\nif the layer is not provided, set it to 'UNUSED'", layer))
        os.exit(1)
    end
    if not t[interface] then
        print(string.format("no layer information for '%s' for interface '%s'", layer, interface))
        os.exit(1)
    end
    S.lpp = generics.mapped(t[interface])
    return true
end

function M.map_layers(cell, interface)
    for i, S in cell:iter() do
        if S.lpp.typ ~= "mapped" then
            local used = _map_layer(S, interface)
            if not used then
                table.remove(cell.shapes, i)
            end
        end
    end
end

local function _get_viaspec(layer)
    local t = viarules[layer]
    if not t then
        print(string.format("no via geometry specification for '%s'", layer))
        os.exit(1)
    end
    return t
end

local function _place_metals(cell, s)
    if s.lpp:is_type("via") then
        local m1, m2 = s.lpp:get()
        local s1 = s:copy()
        s1.lpp = generics.metal(m1)
        local s2 = s:copy()
        s2.lpp = generics.metal(m2)
        cell:add_shape(s1)
        cell:add_shape(s2)
    elseif s.lpp:is_type("contact") then
        local semi = s.lpp:get()
        local ssemi = s:copy()
        ssemi.lpp = generics.other(semi)
        local smetal = s:copy()
        smetal.lpp = generics.metal(1)
        cell:add_shape(ssemi)
        cell:add_shape(smetal)
    end
end

local function _place_vias(cell, s, interface)
    local layer = s.lpp:str()
    local viaspec = _get_viaspec(layer)
    local width = s:width()
    local height = s:height()
    local c = s:center()
    local xrep = math.max(1, math.floor((width + viaspec.xspace - 2 * viaspec.xencl) / (viaspec.width + viaspec.xspace)))
    local yrep = math.max(1, math.floor((height + viaspec.yspace - 2 * viaspec.yencl) / (viaspec.height + viaspec.yspace)))
    local xpitch = viaspec.width + viaspec.xspace
    local ypitch = viaspec.height + viaspec.yspace
    for _, lay in ipairs(viaspec.layers) do
        local enlarge = lay.enlarge or 0.0
        local o = geometry.multiple(
            geometry.rectangle(generics.mapped(lay.lpp[interface]), viaspec.width + enlarge, viaspec.height + enlarge),
            xrep, yrep, xpitch, ypitch
        )
        cell:merge_into(o:translate(c:unwrap()))
    end
end

function M.split_vias(cell)
    for i, s in cell:iter(function(s) return s:is_lpp_type("via") end) do
        table.remove(cell.shapes, i)
        local from, to = s.lpp:get()
        for i = from, to - 1 do
            local sc = s:copy()
            sc.lpp = generics.via(i, i + 1)
            cell:add_shape(sc)
        end
    end
end

function M.create_via_geometries(cell, interface)
    if #cell:find(
            function(s) 
                return (s:is_lpp_type("via") or s:is_lpp_type("contact")) and s:is_type("polygon") 
            end
        ) > 0 then
        print("sorry, via translation of polygons is currently not supported")
        os.exit(1)
    end
    for i, s in cell:iter(function(s) return s:is_lpp_type("via") or s:is_lpp_type("contact") end) do
        table.remove(cell.shapes, i)
        _place_metals(cell, s)
        _place_vias(cell, s, interface)
    end
end

function M.fix_to_grid(cell)
    for _, s in cell:iter() do
        for _, pt in pairs(s.points) do
            pt:fix(config.grid)
        end
    end
end

local function _load_technology_file(name, what)
    local status, ret = pcall(dofile, string.format("%s/tech/%s/%s.lua", _get_opc_home(), name, what))
    if not status then
        print(ret)
        print(string.format("no %s for technology '%s' found", what, name))
        os.exit(exitcodes.technotfound)
    end
    return ret
end

function M.load(name)
    layermap = _load_technology_file(name, "layermap")
    viarules = _load_technology_file(name, "viarules")
    config   = _load_technology_file(name, "config")
end

return M

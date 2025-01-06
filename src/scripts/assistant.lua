local color = {
    black       = "30",
    red         = "31",
    green       = "32",
    yellow      = "33",
    blue        = "34",
    purple      = "35",
    cyan        = "36",
    white       = "37",
    normal      = "0",
}

local function _write_escape_color(content)
    io.write(string.char(0x1b) .. "[" .. content .. "m")
end

local function _set_color(colorstr)
    _write_escape_color(color[colorstr])
end

local function _reset_color()
    _write_escape_color("0")
end

local function _set_bold(colorstr)
    _write_escape_color("1")
end
---------------------------
-- end of color module
---------------------------

local function add_empty_entry(state, name)
    table.insert(state.entries, { opcname = name, empty = true })
end

-- iterate through the table instead of direct access via []
-- this allows for checking keys that are false
local function _config_has(config, key)
    for k, v in pairs(config) do
        if k == key then
            return true
        end
    end
    return false
end

local function _check_layer(layermap, name, options)
    local layer = layermap[name]
    local isvalid = true
    if layer then
        if options.askname and not layer.name then
            isvalid = false
        end
        if options.askGDS and not layer.layer.gds then
            isvalid = false
        end
        if options.askSKILL and not layer.layer.SKILL then
            isvalid = false
        end
    else
        isvalid = false
    end
    return isvalid
end

local function _count_kv(t)
    local count = 0
    for k, v in pairs(t) do
        count = count + 1
    end
    return count
end

local function _check_empty_layer(layermap, name)
    local layer = layermap[name]
    if not layer then
        return false
    end
    return _count_kv(layer) == 0
end

local function _move_layers_to_state(state, layermap, ignorelist)
    for k, v in pairs(layermap) do
        local insert = true
        for _, ignore in ipairs(ignorelist) do
            if k == ignore then
                insert = false
            end
        end
        if insert then
            if _count_kv(v) == 0 then
                table.insert(state.entries, { opcname = k, empty = true })
            else
                local new = {
                    opcname = k,
                    name = v.name,
                    order = v.order,
                    gds = v.layer and v.layer.gds,
                    SKILL = v.layer and v.layer.SKILL,
                }
                table.insert(state.entries, new)
            end
        end
    end
end

local function load(state, options)
    local config = dofile(string.format("tech/%s/config.lua", state.libname))
    local layermap = dofile(string.format("tech/%s/layermap.lua", state.libname))
    if _config_has(config, "substrate_dopand") then
        state.substrate_dopand = config.substrate_dopand
        -- FIXME: check well layers
    end
    -- check assistant options (needs to be done first, as some layers might include gds data, some might not)
    for opcname, entry in pairs(layermap) do
        if not entry.layer then -- empty layer
        else
            if entry.name then
                options.askname = true
            end
            if entry.layer.gds then
                options.askGDS = true
            end
            if entry.layer.SKILL then
                options.askSKILL = true
            end
        end
    end
    local ignorelist = {}
    if _config_has(config, "FEOL_method") then
        if config.FEOL_method == "active_plus_implant" then
            state.FEOL_method = config.FEOL_method
            if _check_layer(layermap, "active", options) and
               _check_layer(layermap, "nimplant", options) and
               _check_layer(layermap, "pimplant", options) then
                state.ignore_FEOL_method = true
            else
                print("The FEOL method is set to 'active_plus_implant', but not all relevant layers ('active', 'nimplant' and 'pimplant') were properly set. You will be asked for FEOL configuration again.")
                table.insert(ignorelist, "active")
                table.insert(ignorelist, "nimplant")
                table.insert(ignorelist, "pimplant")
            end
        -- FIXME:
        --elseif config.FEOL_method == "dedicated_active" then
        --elseif config.FEOL_method == "asymmetric_active" then
        --else
        end

        -- FIXME: check active/implant layers
    end
    if _config_has(config, "has_triple_well") then
        state.has_triple_well = config.has_triple_well
        state.ignore_triple_well = true
    end
    if _config_has(config, "is_SOI") then
        state.ignore_SOI = true
        if config.is_SOI then
            if _check_layer(layermap, "soiopen", options) then
                state.is_SOI = true
            else
                state.ignore_SOI = false
                print("the config states that this node is an SOI technology, but the 'soiopen' layer is either not present or defect. You will be prompted for SOI information again.")
            end
        end
    end
    if _config_has(config, "has_gatecut") then
        if state.has_gatecut then
            if _check_layer(layermap, "gatecut", options) then
                state.has_gatecut = true
                state.ignore_gatecut = true
            else
                print("the config states that this node has a gate cut layer, but the 'gatecut' layer is either not present or defect. You will be prompted for gate cut layer information again")
                state.ignore_gatecut = false
                table.insert(ignorelist, "gatecut")
            end
        else
            if not layermap["gatecut"] then
                add_empty_entry(state, "gatecut")
                table.insert(ignorelist, "gatecut")
                state.has_gatecut = false
                state.ignore_gatecut = true
            else
                if _check_empty_layer(layermap, "gatecut") then
                    state.has_gatecut = false
                    state.ignore_gatecut = true
                else
                    print("the config states that no gate cut mask layers exist, but a non-empty gate cut layer definition was given in the layermap file. You will be prompted for gate cut information again.")
                    state.ignore_gatecut = false
                end
            end
        end
    end
    if config.metals then
        -- check that all metals are present
        local metals_valid = true
        for i = 1, config.metals do
            if not _check_layer(layermap, string.format("M%d", i), options) then
                metals_valid = false
            end
        end
        if metals_valid then
            state.nummetals = config.metals
        else
            print("The metal stack is not properly set up. You will be prompted again for metal information.")
        end
    end
    _move_layers_to_state(state, layermap, ignorelist)
end

local function create_file(path)
    return {
        file = io.open(path, "w"),
        indent = 0,
        increase_indent = function(self)
            self.indent = self.indent + 1
        end,
        decrease_indent = function(self)
            self.indent = self.indent - 1
        end,
        write_indent = function(self)
            self.file:write(string.rep(" ", 4 * self.indent))
        end,
        write = function(self, content)
            self.write_indent(self)
            self.file:write(content)
        end,
        writeline = function(self, content)
            self.write_indent(self)
            self.file:write(content)
            self.file:write("\n")
        end,
        close = function(self)
            self.file:close()
        end,
    }
end

local function _write_config(file, state)
    file:writeline("return {")
    file:increase_indent()
    if state.substrate_dopand then
        file:writeline(string.format("substrate_dopand = \"%s\",", state.substrate_dopand))
    end
    file:writeline(string.format("has_triple_well = %s,", state.has_triple_well and "true" or "false"))
    file:writeline(string.format("is_SOI = %s,", state.is_SOI and "true" or "false"))
    if state.FEOL_method then
        file:writeline(string.format("FEOL_method = \"%s\",", state.FEOL_method))
    end
    file:writeline(string.format("has_gatecut = %s,", state.has_gatecut and "true" or "false"))
    if state.nummetals then
        file:writeline(string.format("metals = %d,", state.nummetals))
    end
    file:decrease_indent()
    file:writeline("}")
end

local function _write_layermapfile(file, state)
    file:writeline("return {")
    file:increase_indent()
    for _, entry in ipairs(state.entries) do
        if entry.empty then
            file:writeline(string.format("%s = {},", entry.opcname))
        else
            file:writeline(string.format("%s = {", entry.opcname))
            file:increase_indent()
            file:writeline("layer = {")
            file:increase_indent()
            if entry.gds then
                file:writeline(string.format("gds = { layer = %d, purpose = %d },", entry.gds.layer, entry.gds.purpose))
            end
            if entry.SKILL then
                file:writeline(string.format("SKILL = { layer = %s, purpose = %s },", entry.SKILL.layer, entry.SKILL.purpose))
            end
            file:decrease_indent()
            file:writeline("}")
            file:decrease_indent()
            file:writeline("},")
        end
    end
    file:decrease_indent()
    file:writeline("}")
end

local function save(state)
    if not state.libname then
        print("you requested a save but no saveable progress is present")
    else
        local libname = state.libname
        --[[
        if state.already_defined then
            libname = state.libname .. ".new"
            _set_color("red")
            print(string.format("the library is being saved at tech/%s. If you want to overwrite the old library (without the '.new' suffix), rename the new library", libname))
            _reset_color()
        end
        --]]
        -- prepare directory
        filesystem.mkdir("tech")
        filesystem.mkdir(string.format("tech/%s", libname))
        -- write config
        print(string.format("writing to tech/%s/config.lua", libname))
        local configfile = create_file(string.format("tech/%s/config.lua", libname))
        _write_config(configfile, state)
        configfile:close()
        -- write layermap
        print(string.format("writing to tech/%s/layermap.lua", libname))
        local layermapfile = create_file(string.format("tech/%s/layermap.lua", state.libname))
        _write_layermapfile(layermapfile, state)
        layermapfile:close()
    end
end

local function _get(state)
    local answer = io.read()
    if answer == "!save" then
        save(state)
        return ""
    else
        return answer
    end
end

local function _check_yesno(answer)
    return
        answer == "y" or
        answer == "ye" or
        answer == "yes" or
        answer == "n" or
        answer == "no"
end


local function _yesnobase(state, defaultyes, prompt)
    local answer
    while true do
        io.write(string.format("%s: ", prompt))
        if defaultyes then
            io.write("(Yes/no): ")
        else
            io.write("(yes/No): ")
        end
        answer = _get(state)
        if not (answer == "" or _check_yesno(answer)) then
            print("please answer 'yes' or 'no' or with an empty line")
        else
            break
        end
    end
    if answer == "" then
        return defaultyes and true or false
    end
    return (answer == "y") or (answer == "ye") or (answer == "yes")
end

local function yesno(state, prompt)
    return _yesnobase(state, true, prompt)
end

local function noyes(state, prompt)
    return _yesnobase(state, false, prompt)
end

local function question(state, prompt)
    local answer = ""
    while answer == "" do
        io.write(string.format("%s: ", prompt))
        answer = _get(state)
    end
    return answer
end

local function tconcat(t, sep, pre, post)
    local r = {}
    for _, element in ipairs(t) do
        table.insert(r, string.format("%s%s%s", pre or "", element, post or ""))
    end
    return table.concat(r, sep)
end

local function _is_one_of(value, t)
    for _, e in ipairs(t) do
        if e == value then
            return true
        end
    end
    return false
end

local function choice(state, prompt, choices)
    while true do
        io.write(string.format("%s (possible choices: %s): ", prompt, tconcat(choices, ", ", "'", "'")))
        local answer = _get(state)
        if not _is_one_of(answer, choices) then
            print("please answer with one of the given choices")
        else
            return answer
        end
    end
    return nil
end

local function number(state, prompt)
    local answer = ""
    while true do
        io.write(string.format("%s: ", prompt))
        answer = _get(state)
        if answer and string.match(answer, "^%d+$") then
            break
        else
            print("please answer with a number")
        end
    end
    return tonumber(answer)
end

local function _ask_layer_base(state, name, prompt, options)
    print(prompt)
    local entry = { opcname = name }
    if options.askname then
        entry.name = question(state, "What is this layer called")
    end
    if options.askGDS then
        entry.gds = {
            layer = number(state, "What is it's GDSII layer number"),
            purpose = number(state, "What is it's GDSII purpose number"),
        }
    end
    if options.askSKILL then
        entry.SKILL = {
            layer = question(state, "What is it's SKILL layer name"),
            purpose = question(state, "What is it's SKILL purpose name"),
        }
    end
    table.insert(state.entries, entry)
end

local function ask_layer(state, name, prompt, options)
    print()
    _ask_layer_base(state, name, prompt, options)
end

local function ask_opt_layer(state, name, ask, prompt, options, func)
    print()
    if func(state, ask) then
        ask_layer(state, name, prompt, options)
    else
        add_empty_entry(state, name)
    end
end

local function ask_opt_layer_yes(state, name, ask, prompt, options)
    ask_opt_layer(state, name, ask, prompt, state, options, yesno)
end

local function ask_opt_layer_no(state, name, ask, prompt, options)
    ask_opt_layer(state, name, ask, prompt, options, noyes)
end

local function has_layer(state, name)
    for _, entry in ipairs(state.entries) do
        if entry.opcname == name then
            return true
        end
    end
    return false
end

print("Hello, this is the technology file assistant.")
print("I will ask you a few questions to help you create the technology file.")
print("All questions will prompt you for an answer, you can enter some characters and give the answer by hitting return.")
print("Some questions will be yes/no, where the default will be marked like this: (Yes/no) -> yes is the default. This can be affirmed by hitting return on an empty line")
print("Some questions on the other hand will require a full answer. If a default is available, it will be shown in braces (like this).")
print()
_set_color("red")
io.write("Currently, no auto-saving mechanisms are implemented. If you need to save your progress at any time, you can type ")
_set_bold()
io.write("'!save'")
_reset_color()
_set_color("red")
print(" as an answer to any question.")
_reset_color()
print()
print("Let's get started:")

-- data state
local state = {
    entries = {},
}

-- assistant options
local options = {}

state.libname = question(state, "What is the name of the library")
if filesystem.exists(string.format("tech/%s", state.libname)) then
    print()
    print("this library already exists, reading content")
    load(state, options)
    print()
    state.already_defined = true
end
print("Usually it is helpful to set up at least the GDSII (and perhaps virtuoso) information.")

local askoptions
if state.already_defined then
    print("the following assistant questions were detected while loading the previous tech state:")
    print(string.format("ask GDS layer information:    %s", options.askGDS and "true" or "false"))
    print(string.format("ask SKILL layer information:  %s", options.askSKILL and "true" or "false"))
    print(string.format("ask layer name:               %s", options.askname and "true" or "false"))
    askoptions = not yesno(state, "Are these options correct?")
else
    askoptions = true
end

if askoptions then
    options.askGDS = yesno(state, "Do you want to specify GDS layer information for the layers?")
    options.askSKILL = yesno(state, "Do you want to specify SKILL layer information for the layers?")
    options.askname = yesno(state, "For debugging purposes, it can be useful to assign a name for every layer. Do you want to be asked for layer names?")
end

if not options.askGDS and not options.askSKILL then
    _set_color("red")
    _set_bold()
    print("the current options don't ask for any actual layer data. This is an error, exiting.")
    _reset_color()
    return 1
end

-- SOI
if not state.ignore_SOI then
    state.is_SOI = noyes(state, "Is this process a silicon-on-insulator (SOI) process?")
    if state.is_SOI then
        ask_layer(
            state,
            "soiopen", 
            "SOI processes have a layer to cut the oxide between both silicon sheets.",
            options
        )
    end
    print()
end

-- wells
print("Let's discuss substrate dopings and wells")
if not state.substrate_dopand then
    state.substrate_dopand = choice(state, "What is the dopand type of the substrate?", { "p-substrate", "n-substrate" })
else
    print(string.format("substrate dopand type is already defined: '%s'", state.substrate_dopand))
end
if not state.ignore_triple_well then
    state.has_triple_well = yesno(state, "Is this node a triple-well process?")
else
    print(string.format("the process's support of triple-wells is already defined as '%s'", state.has_triple_well))
end
-- main wells
if state.substrate_dopand == "p-substrate" then
    if not has_layer(state, "nwell") then
        ask_layer(
            state,
            "nwell", 
            "The n-well layer is used to form n-doped areas",
            options
        )
    end
else
    if not has_layer(state, "pwell") then
        ask_layer(
            state,
            "pwell", 
            "The p-well layer is used to form p-doped areas",
            options
        )
    end
end
-- deep wells
if state.has_triple_well then
    if state.substrate_dopand == "p-substrate" then
        if not has_layer(state, "deepnwell") then
            ask_layer(
                state,
                "deepnwell", 
                "The deep-n-well layer is used to form isolated p-wells",
                options
            )
        end
    else
        if not has_layer(state, "deeppwell") then
            ask_layer(
                state,
                "deeppwell", 
                "The deep-p-wells layer is used to form isolated n-wells",
                options
            )
        end
    end
end
print("wells configuration is completed.")
print()

-- active
if not state.FEOL_method then
    print()
    print("Let's discuss active transistor regions. In some process, there is a generic 'active' region turned into n-plus or p-plus by additional marking layers (three layers in total) ('active_plus_implant'). In other processes, there are dedicated n-plus and p-plus active layers (two layers) ('dedicated_active'). Lastly, there are also processes where only n- or p-implants are marked and active regions without markings are the opposite (also two layers) ('asymmetric_active').")
    state.FEOL_method = choice(state, "Which active/implant method does this technology use?", { "active_plus_implant", "dedicated_active", "asymmetric_active" })
else
    print(string.format("the FEOL method for specifying MOSFET source/drain regions and other active areas is already defined as '%s'", state.FEOL_method))
end

if not state.ignore_FEOL_method then
    if state.FEOL_method == "active_plus_implant" then
        ask_layer(
            state,
            "active", 
            "Let's talk about the active layer.",
            options
        )
        ask_layer(
            state,
            "nimplant", 
            "Let's talk about the n-plus implant marking layer.",
            options
        )
        ask_layer(
            state,
            "pimplant", 
            "Let's talk about the p-plus implant marking layer.",
            options
        )
    elseif state.FEOL_method == "dedicated_active" then
    elseif state.FEOL_method == "asymmetric_active" then
    else
        -- error, can't happen
    end
end

-- gate layer
if not has_layer(state, "gate") then
    ask_layer(
        state,
        "gate", 
        "Let's talk about the gate layer",
        options
    )
end

-- gate cut layer
if not state.ignore_gatecut then
    state.has_gatecut = noyes(state, "Does this process have a mask layer to cut gates?")
    if state.has_gatecut then
        ask_layer(
            state,
            "gatecut", 
            "Let's talk about the gate cut layer",
            options
        )
    else
        add_empty_entry(
            state,
            "gatecut"
        )
    end
end

print()
print("Let us move on to the metal stack")

-- FIXME: vias
if not state.nummetals then
    state.nummetals = number(state, "How many metals does this metal stack have (ALL metals, including top-level layers for pads etc. as well as common interconnect layers above gates and active regions)?")
    for i = 1, state.nummetals do
        ask_layer(
            state,
            string.format("M%d", i),
            string.format("Metal %d", i),
            options
        )
    end
end

save(state)

local function _write_techfile(file, tech)
    local _write_nl = function(fmt, ...)
        if ... then
            file:write(string.format(fmt, ...))
        else

            file:write(fmt)
        end
        file:write("\n")
    end

    file:write("return {\n")
    for _, entry in ipairs(tech.entries) do
        if entry.empty then
            _write_nl("    %s = {},", entry.opcname)
        else
            file:write(string.format("    %s = {\n", entry.opcname))
            file:write("        map {\n")
            file:write("            lpp = {\n")
            if entry.gds then
                file:write(string.format("                gds = { layer = %d, purpose = %d },\n", entry.gds.layer, entry.gds.purpose))
            end
            file:write("            }\n")
            file:write("        }\n")
            file:write("    },\n")
        end
    end
    file:write("}\n")
end

local function yesno(prompt)
    io.write(string.format("%s (Yes/no): ", prompt))
    local answer = io.read()
    if answer == "n" or answer == "no" then
        return false
    else
        return true
    end
end

local function noyes(prompt)
    io.write(string.format("%s (yes/No): ", prompt))
    local answer = io.read()
    if answer == "y" or answer == "yes" then
        return true
    else
        return false
    end
end

local function question(prompt)
    local answer = ""
    while answer == "" do
        io.write(string.format("%s?: ", prompt))
        answer = io.read()
    end
    return answer
end

local function number(prompt)
    local answer = ""
    while answer == "" or not string.match(answer, "^(%d+)$") do
        io.write(string.format("%s?: ", prompt))
        answer = io.read()
    end
    return tonumber(answer)
end

local function _ask_layer_base(name, prompt, tech, options)
    print(prompt)
    local entry = { opcname = name }
    if options.askname then
        entry.name = question("What is this layer called")
    end
    if options.askGDS then
        entry.gds = {
            layer = number("What is it's GDSII layer number"),
            purpose = number("What is it's GDSII purpose number"),
        }
    end
    if options.askSKILL then
        entry.SKILL = {
            layer = question("What is it's SKILL layer name"),
            purpose = question("What is it's SKILL purpose name"),
        }
    end
    table.insert(tech.entries, entry)
end

local function _ask_layer(name, prompt, tech, options)
    print()
    _ask_layer_base(name, prompt, tech, options)
end

local function _ask_opt_layer(name, ask, prompt, tech, options)
    print()
    if yesno(ask) then
        _ask_layer(name, prompt, tech, options)
    else
        table.insert(tech.entries, { opcname = name, empty = true })
    end
end

print("Hello, this is the technology file assistant.")
print("I will ask you a few questions to help you create the technology file.")
print("All questions will prompt you for an answer, you can enter some characters and give the answer by hitting return.")
print("Some questions will be yes/no, where the default will be marked like this: (Yes/no) -> yes is the default. This can be affirmed by hitting return on an empty line")
print("Some questions on the other hand will require a full answer. If a default is available, it will be shown in braces (like this).")
print()
print("Let's get started:")
local libname = question("What is the name of the library")
--if filesystem.exists(string.format("tech/%s", libname)) then
--    print("error: this library already exists")
--    return 1
--end
print("Usually it is helpful to set up at least the GDSII (and perhaps virtuoso) information.")

local options = {}
options.askGDS = yesno("Do you want to specify GDS layer information for the layers")
options.askSKILL = yesno("Do you want to specify SKILL layer information for the layers")
options.askname = yesno("For debugging purposes, it can be useful to assign a name for every layer. Do you want to be asked for layer names")

filesystem.mkdir(string.format("tech/%s", libname))
print(string.format("writing to tech/%s/layermap.lua", libname))
local file = io.open(string.format("tech/%s/layermap.lua", libname), "w")
local tech = { entries = {} }

print()
print("Let us start with the front-end-of-line:")

-- SOI
_ask_opt_layer(
    "soiopen", 
    "Is this process a silicon-on-insulator (SOI) process",
    "SOI processes have a layer to cut the oxide between both silicon sheets.",
    tech, options
)

-- gates
_ask_layer(
    "gate", 
    "Let's talk about the gate layer",
    tech, options
)

-- gate cut
_ask_opt_layer(
    "gatecut", 
    "Does this process have a mask layer to cut gates",
    "Let's talk about the gate layer",
    tech, options
)

print()
print("Let us move on to the metal stack")

tech.nummetals = number("How many metals does this metal stack have (ALL metals, including any possible top-level aluminum interconnect layer")
for i = 1, tech.nummetals do
    _ask_layer(
        string.format("M%d", i),
        string.format("Metal %d", i),
        tech, options
    )
end

_write_techfile(file, tech)
file:close()

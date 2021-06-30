-- luacheck: globals run_test

_load_module("testsuite/support")

-- set default path for technology files
technology.add_techpath(string.format("%s/tech", _get_opc_home()))

local enabled = {}
local all = true
for _, v in ipairs(arg) do
    enabled[v] = true
    -- if any args are found, run only selected tests
    all = false
end

-- module loading tests
if all or enabled["module"] then
    print("running module test...")
    run_test("module", "all")
end

-- graphic checks
if all or enabled["graphics"] then
    print("running graphics test...")
    run_test("graphics", "line")
    run_test("graphics", "circle")
    --run_test("graphics", "bresenham_arc")
end

-- support checks
if all or enabled["support"] then
    print("running support systems test...")
    run_test("support", "bind")
    run_test("support", "reduce")
end

-- geometry checks
if all or enabled["geometry"] then
    print("running geometry test...")
    run_test("geometry", "path")
    run_test("geometry", "path_xy")
    --run_test("geometry", "any_angle_path")
end

-- pcell checks
--[[
if all or enabled["pcell"] then
    print("running pcell test...")
    run_test("pcell", "inheritance")
end
--]]

-- point checks
if all or enabled["point"] then
    print("running point test...")
    run_test("point", "basic")
end

-- object checks
if all or enabled["object"] then
    print("running object test...")
    run_test("object", "all")
end

-- util checks
if all or enabled["util"] then
    print("running util test...")
    run_test("util", "all")
end

-- cell checks
if all or enabled["cells"] then
    print("running cells test...")
    run_test("cells", "all")
end

-- union checks
if all or enabled["union"] then
    print("running union test...")
    run_test("union", "all")
end

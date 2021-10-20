-- luacheck: globals run_test

local testsupport = _load_module("testsuite/support")

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
    testsupport.run_test("module", "all")
end

-- graphic checks
if all or enabled["graphics"] then
    print("running graphics test...")
    testsupport.run_test("graphics", "line")
    testsupport.run_test("graphics", "circle")
    --run_test("graphics", "bresenham_arc")
end

-- support checks
if all or enabled["support"] then
    print("running support systems test...")
    testsupport.run_test("support", "bind")
    testsupport.run_test("support", "reduce")
end

-- geometry checks
if all or enabled["geometry"] then
    print("running geometry test...")
    testsupport.run_test("geometry", "path")
    testsupport.run_test("geometry", "path_xy")
    --run_test("geometry", "any_angle_path")
end

-- pcell checks
--[[
if all or enabled["pcell"] then
    print("running pcell test...")
    testsupport.run_test("pcell", "inheritance")
end
--]]

-- point checks
if all or enabled["point"] then
    print("running point test...")
    testsupport.run_test("point", "basic")
end

-- object checks
if all or enabled["object"] then
    print("running object test...")
    testsupport.run_test("object", "all")
end

-- util checks
if all or enabled["util"] then
    print("running util test...")
    testsupport.run_test("util", "all")
end

-- cell checks
if all or enabled["cells"] then
    print("running cells test...")
    testsupport.run_test("cells", "all")
end

-- union checks
if all or enabled["union"] then
    print("running union test...")
    testsupport.run_test("union", "all")
end

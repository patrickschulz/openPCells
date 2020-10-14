_load_module("testsuite/support")

local enabled = {}
local all = true
for _, v in ipairs(arg) do
    enabled[v] = true
    -- if any args are found, run only selected tests
    all = false 
end

-- module loading tests
if all or enabled["module"] then
    print("running module test")
    local modules = {
        { 
            module = "testsuite/moduletest/correct",
            status = true
        },
        { 
            module = "testsuite/moduletest/syntaxerror",
            status = false
        },
        { 
            module = "testsuite/moduletest/semanticerror",
            status = false
        },
    }
    for _, pair in ipairs(modules) do
        local status, M = pcall(_load_module, pair.module)
        assert(status == pair.status)
    end
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
    run_test("geometry", "any_angle_path")
end

-- pcell checks
if all or enabled["pcell"] then
    print("running pcell test...")
    run_test("pcell", "inheritance")
end

-- point checks
if all or enabled["point"] then
    print("running point test...")
    run_test("point", "basic")
end

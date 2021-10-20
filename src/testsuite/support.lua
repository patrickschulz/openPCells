-- luacheck: globals dofile check_number check_point check_points colorize report run_test
local M = {}

local function check_number(val, ref)
    if type(val) ~= "number" then
        return nil, string.format("value is not a number: %s", val)
    end
    if val ~= ref then
        return nil, string.format("numbers do not match: %d vs %d", val, ref)
    end
    return true
end

local function check_point(pt, ref)
    if pt ~= ref then
        local px, py = pt:unwrap()
        local rx, ry = ref:unwrap()
        return nil, string.format("point does not match: (%d, %d) vs. (%d, %d)", px, py, rx, ry)
    end
    return true
end

local function check_points(pts, ref)
    if #pts ~= #ref then
        return nil, string.format("number of points does not match: %d vs %d", #pts, #ref)
    end
    for i = 1, #pts do
        if pts[i] ~= ref[i] then
            local px, py = pts[i]:unwrap()
            local rx, ry = ref[i]:unwrap()
            return nil, string.format("point does not match: (%d, %d) vs. (%d, %d)", px, py, rx, ry)
        end
    end
    return true
end

local reporttab
local function report(what, result, msg)
    table.insert(reporttab, { what = what, result = result, msg = msg })
end

local function colorize(msg, color)
    local colortable = {
        black   = "30",
        red     = "31",
        green   = "32",
        yellow  = "33",
        blue    = "34",
        magenta = "35",
        cyan    = "36",
        white   = "37",
    }
    local pre  = string.char(27, 91) .. colortable[color] .. "m"
    local post = string.char(27, 91) .. "0m"
    return string.format("%s%s%s", pre, msg, post)
end

function M.run_test(module, test)
    -- reset reporttab
    reporttab = {}
    print(string.format("  * %s: ", test))
    local env = {
        _get_opc_home = _get_opc_home,
        ipairs = ipairs,
        pcall = pcall,
        point = point,
        graphics = graphics,
        reduce = reduce,
        geometry = geometry,
        generics = generics,
        util = util,
        technology = technology,
        pcell = pcell,
        union = union,
        string = string,
        bind = bind,
        report = report,
        check_number = check_number,
        check_point = check_point,
        check_points = check_points,
    }
    local chunk, msg = loadfile(
        string.format("%s/src/testsuite/%s/%s.lua", _get_opc_home(), module, test),
        "t",
        env
    )
    if chunk then
        chunk()
    else
        print(chunk, msg)
        return
    end
    for _, r in ipairs(reporttab) do
        if r.result then
            local msg = string.format("    x %s: ", r.what) .. "success"
            print(colorize(msg, "green"))
        else
            local msg = string.format("    x %s: ", r.what) .. string.format("failure: %s", r.msg)
            print(colorize(msg, "red"))
        end
    end
    --[[
    if status then
        print("success")
    else
        print(string.format("failure: %s", msg))
    end
    --]]
end

return M

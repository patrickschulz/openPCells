function error(fmt, ...)
    print(string.format(fmt, ...))
    os.exit(1)
end

function check_number(val, ref)
    if type(val) ~= "number" then
        error("value is not a number: %s", val)
    end
    if val ~= ref then
        error("numbers do not match: %d vs %d", val, ref)
    end
end

function check_points(pts, ref, ignoreorder)
    if #pts ~= #ref then
        error("number of points does not match: %d vs %d", #pts, #ref)
    end
    for i = 1, #pts do
        if pts[i] ~= ref[i] then
            local px, py = pts[i]:unwrap()
            local rx, ry = ref[i]:unwrap()
            error("point does not match: (%d, %d) vs. (%d, %d)", px, py, rx, ry)
        end
    end
end

function run_test(module, test)
    local status = dofile(string.format("testsuite/%s/%s.lua", module, test))
    print(string.format("  * %s: %s", test, status and "success" or "failure"))
end

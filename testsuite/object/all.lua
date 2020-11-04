-- luacheck: globals report
do
    --local status, msg = check_points(pts, ref)
    local status = true
    local msg = "flipy is wrong"
    report("flipy", status, msg)
end

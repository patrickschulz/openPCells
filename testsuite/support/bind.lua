-- bind first argument
do
    local div = function(a, b) return a / b end
    local div10by = bind(div, 1, 10)
    local status, msg = check_number(div10by(2), 5)
    report("first argument", status, msg)
end

-- bind second argument
do
    local div = function(a, b) return a / b end
    local divby2 = bind(div, 2, 2)
    local status, msg = check_number(divby2(10), 5)
    report("second argument", status, msg)
end

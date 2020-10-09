-- bind first argument
do
    local div = function(a, b) return a / b end
    local div10by = bind(div, 1, 10)
    check_number(div10by(2), 5)
end

-- bind second argument
do
    local div = function(a, b) return a / b end
    local divby2 = bind(div, 2, 2)
    check_number(divby2(10), 5)
end

-- if all test ran positively, we reach this point
return true

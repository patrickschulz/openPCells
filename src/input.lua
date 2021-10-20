local M = {}

function M.yesno(prompt)
    io.write(string.format("%s (Yes/no): ", prompt))
    local answer = io.read()
    if answer == "n" or answer == "no" then
        return false
    else
        return true
    end
end

function M.noyes(prompt)
    io.write(string.format("%s (yes/No): ", prompt))
    local answer = io.read()
    if answer == "y" or answer == "yes" then
        return true
    else
        return false
    end
end

function M.question(prompt)
    local answer = ""
    while answer == "" do
        io.write(string.format("%s?: ", prompt))
        answer = io.read()
    end
    return answer
end

function M.number(prompt)
    local answer = ""
    while answer == "" or not string.match(answer, "^(%d+)$") do
        io.write(string.format("%s?: ", prompt))
        answer = io.read()
    end
    return tonumber(answer)
end

return M

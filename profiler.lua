local M = {}

local lastcalled = {}
local data = {}
local info = {}

function M.start()
    local logcall = function(event)
        local funcinfo = debug.getinfo(2)
        if funcinfo.what ~= "Lua" then return end
        local name = funcinfo.name
        if not name then return end
        if event == "call" then
            lastcalled[name] = os.clock()
        elseif event == "return" then
            if lastcalled[name] then
                local time = os.clock() - lastcalled[name]
                if not data[name] then data[name] = { time = 0, count = 0 } end
                data[name].time = data[name].time + time
                data[name].count = data[name].count + 1
            end
        end
        --[[
        local name = funcinfo.name
        local namewhat = funcinfo.namewhat
        if name then
            if not data[name] then 
                data[name] = 0 
            end
            if not info[name] then
                info[name] = {
                    source = funcinfo.source
                }
            end
            data[name] = data[name] + 1
        end
        --]]
    end
    debug.sethook(logcall, "cr")
end

function M.stop()
    debug.sethook()
end

function M.display()
    local sorted = {}
    for k, v in pairs(data) do
        table.insert(sorted, { name = k, data = v })
    end
    table.sort(sorted, function(lhs, rhs) return lhs.data.time < rhs.data.time end)
    for _, entry in ipairs(sorted) do
        print(string.format("%30s: %10f (%d)", entry.name, entry.data.time, entry.data.count))
    end
end

return M

local M = {}

local lastcalled = {}
local data = {}
local info = {}
local cfunctions = {}

function M.register_cfunction(module, name, func)
    cfunctions[func] = { name = name, source = "@" .. module }
end

function M.start()
    local logcall = function(event)
        local funcinfo = debug.getinfo(2)
        if not funcinfo.name then return end
        local key
        local name
        local source
        if funcinfo.what == "Lua" then
            key = funcinfo.name .. funcinfo.source
            name = funcinfo.name
            source = funcinfo.source .. ":lua"
        else
            if cfunctions[funcinfo.func] then
                key = funcinfo.func
                name = cfunctions[funcinfo.func].name
                source = cfunctions[funcinfo.func].source .. ":C"
            else
                key = funcinfo.name .. funcinfo.source
                name = funcinfo.name
                source = funcinfo.source .. ":C"
            end
        end
        if event == "call" then
            if not info[key] then
                info[key] = { 
                    name = name,
                    source = source,
                }
            end
            lastcalled[key] = os.clock()
        elseif event == "return" then
            if lastcalled[key] then
                local time = os.clock() - lastcalled[key]
                if not data[key] then data[key] = { time = 0, calls = 0 } end
                data[key].time = data[key].time + time
                data[key].calls = data[key].calls + 1
            end
        end
    end
    debug.sethook(logcall, "cr")
end

function M.stop()
    debug.sethook()
end

function M.display()
    local sorted = {}
    local widths = {
        name = 0,
        source = 0,
        calls = 5, -- see above comment (fit "Calls")
    }
    local totaltime = 0
    for k, v in pairs(data) do
        table.insert(sorted, { key = k, data = v })
        widths.calls = math.max(widths.calls, math.floor(math.log(v.calls, 10)) + 1)
        totaltime = totaltime + v.time
    end
    for _, entry in pairs(info) do
        widths.name = math.max(widths.name, string.len(entry.name))
        widths.source = math.max(widths.source, string.len(entry.source))
    end
    table.sort(sorted, function(lhs, rhs) return lhs.data.time < rhs.data.time end)
    local entryfmt = string.format(" %%-%ds %%-%ds %%%dd %%10f %%10.2f", widths.name, widths.source, widths.calls)
    local headerfmt = string.format(" %%-%ds %%-%ds %%%ds %%10s %%10s", widths.name, widths.source, widths.calls)
    local header = string.format(headerfmt, "Function", "Module", "Calls", "Time", "% Time")
    print(header)
    print(string.rep("-", string.len(header)))
    for _, entry in ipairs(sorted) do
        local percentage = entry.data.time / totaltime * 100
        if percentage >= 1 then
            print(string.format(entryfmt,
                info[entry.key].name, 
                info[entry.key].source,
                entry.data.calls,
                entry.data.time, 
                percentage
            ))
        end
    end
end

return M

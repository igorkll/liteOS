local advmath = require("advmath")
local background = {}
background.listens = {}
background.timers = {}
background.log = {}

function background.addListen(func)
    table.insert(background.listens, func)
end

function background.removeListen(func)
    for index, value in ipairs(background.listens) do
        if value == func then
            table.remove(background.listens, index)
        end
    end
end

function background.addTimer(func, time)
    table.insert(background.timers, {func = func, time = time, lasttime = computer.uptime()})
end

function background.removeTimer(func)
    for index, value in ipairs(background.timers) do
        if value.func == func then
            table.remove(background.timers, index)
        end
    end
end

function background.call(func, ...)
    local data = {pcall(func, ...)}
    if not data[1] then
        table.insert(background.log, {err = data[2]})
        return table.unpack(data)
    end
    return table.unpack(data, 2)
end

do
    local pullSignal = computer.pullSignal
    function computer.pullSignal(time)
        time = time or math.huge

        local startTime = computer.uptime()
        while computer.uptime() - startTime <= time do
            for index, value in ipairs(background.timers) do --timers
                if computer.uptime() - value.lasttime >= value.time then
                    value.lasttime = computer.uptime()
                    background.call(value.func)
                end
            end


            local waittime = time - (computer.uptime() - startTime) --подсчет сколько времяни остолось до ближайшего таймера
            for index, value in ipairs(background.timers) do
                local ltime = value.time - (computer.uptime() - value.lasttime)
                if ltime < waittime then
                    waittime = ltime
                end
            end
            waittime = advmath.clamp(waittime, 0, math.huge)

            local data = {pullSignal(waittime)}
            if #data > 0 then
                for index, value in ipairs(background.listens) do
                    background.call(value, table.unpack(data))
                end
                return table.unpack(data)
            end
        end
    end
end

return background
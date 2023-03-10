local background = {}
background.listens = {}
background.timers = {}

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

do
    local pullSignal = computer.pullSignal
    function computer.pullSignal(time)
        time = time or math.huge

        local startTime = computer.uptime()
        while computer.uptime() - startTime <= time do
            local data = {pullSignal(0.5)}
            if #data > 0 then
                for index, value in ipairs(background.listens) do
                    value(table.unpack(data))
                end
                return table.unpack(data)
            end
            for index, value in ipairs(background.timers) do
                if computer.uptime() - value.lasttime >= value.time then
                    value.lasttime = computer.uptime()
                    value.func()
                end
            end
        end
    end
end

return background
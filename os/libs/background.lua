local background = {}
background.listens = {}

function background.addListen(func)
    table.insert(background.listens, func)
end

function background.removeListen(func)
    for index, value in ipairs(listens) do
        if value == func then
            table.remove(background.listens, index)
        end
    end
end

do
    local pullSignal = computer.pullSignal
    function computer.pullSignal(time)
        local data = {pullSignal(time)}
        for index, value in ipairs(background.listens) do
            value(table.unpack(data))
        end
        return table.unpack(data)
    end
end

return background
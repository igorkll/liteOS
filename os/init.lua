-------------------------------------------fake globals

fakeglobals = {
    components = {}
}

setmetatable(_G, function(tbl, key)
    for key, value in pairs(fakeglobals) do
        if value[key] then
            return value[key]
        end
    end
end)

-------------------------------------------background

do
    local listens = {}
    function addListen(func)
        table.insert(listens, func)
    end

    function removeListen(func)
        for index, value in ipairs(listens) do
            if value == func then
                table.remove(listens, index)
            end
        end
    end


    do
        local pullSignal = computer.pullSignal
        function computer.pullSignal(time)
            local data = {pullSignal(time)}
            for index, value in ipairs(listens) do
                value(table.unpack(data))
            end
            return table.unpack(data)
        end
    end
end

-------------------------------------------global components

function refreshComponentList()
    fakeglobals.components = {}
    for address, ctype in component.list() do
        fakeglobals.components[ctype] = component.proxy(address)
    end
end

addListen(function(eventType)
    if eventType == "component_removed" or eventType == "component_added" then
        refreshComponentList()
    end
end)

-------------------------------------------fs

function readFile(fs, path)
    checkArg(1, fs, "table", "string")
    checkArg(2, path, "string")

    if type(fs) == "string" then fs = component.proxy(fs) end
    local file, err = fs.open(path, "rb")
    if not file then return nil, err or "unknown" end

    local buffer = ""
    repeat
        local data = fs.read(file, math.huge)
        buffer = buffer .. (data or "")
    until not data
    fs.close(file)
    return buffer
end

function saveFile(fs, path, data)
    checkArg(1, fs, "table", "string")
    checkArg(2, path, "string")
    checkArg(3, data, "string")

    if type(fs) == "string" then fs = component.proxy(fs) end
    local file, err = fs.open(path, "wb")
    if not file then return nil, err or "unknown" end

    fs.write(file, data)
    fs.close(file)
    return buffer
end

-------------------------------------------libs

function require(name)
    
end

-------------------------------------------graphic

do --инициализация графической системмы
    gpu.bind(component.list("screen")())
    local rx, ry = gpu.maxResolution()

    if gpu.setActiveBuffer then --если версия open computers поддерживает буферы
        gpu.setActiveBuffer(0) --лутще их удалить, малоли что там будет
        gpu.freeAllBuffers()
    end

    gpu.setDepth(1) --сброс палитры
    gpu.setDepth(gpu.maxDepth())

    gpu.setResolution(rx, ry) --ставим максимальное разрешения

    gpu.setBackground(0) --цвета по умалчанию
    gpu.setForeground(0xFFFFFF)

    gpu.fill(1, 1, rx, ry, " ") --очистка экрана
end

-------------------------------------------
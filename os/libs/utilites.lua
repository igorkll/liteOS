function readFile(fs, path)
    checkArg(1, fs, "table", "string")
    checkArg(2, path, "string")

    if type(fs) == "string" then fs = component.proxy(fs) end
    if not fs.exists(path) then return nil, "file not found" end
    if fs.isDirectory(path) then return nil, "is directory" end
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
    return true
end

-------------------------------------------------

local function getPath()
    local info

    for runLevel = 0, math.huge do
        info = debug.getinfo(runLevel)

        if info then
            if info.what == "main" then
                return info.source:sub(2, -1)
            end
        else
            error("Failed to get debug info for runlevel " .. runLevel)
        end
    end
end

-------------------------------------------------

function math.round(number)
    return math.floor(number + 0.5)
end

-------------------------------------------------

function os.sleep(time)
    local inTime = computer.uptime()
    while computer.uptime() - inTime < time do
        computer.pullSignal(time - (computer.uptime() - inTime))
    end
end

-------------------------------------------------

function table.contains(tbl, element)
    for _, value in pairs(tbl) do
        if value == element then
            return true
        end
    end
    return false
end

function table.removeMatches(tbl, v)
    for index, value in ipairs(tbl) do
        if value == v then
            table.remove(tbl, index)
        end
    end
    return false
end

function table.removeAllMatches(tbl, v)
    for key, value in pairs(tbl) do
        if value == v then
            tbl[key] = nil
        end
    end
    return false
end
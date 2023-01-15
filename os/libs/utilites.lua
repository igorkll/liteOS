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

function math.round(number)
    return math.floor(number + 0.5)
end
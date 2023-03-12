local fs = require("filesystem")
local env = require("env")

----------------------------------------

local programs = {}
programs.paths = {"/executable", "/data/executable"}

function programs.list()
    local list = {}
    for _, folder in ipairs(programs.paths) do
        for _, path in ipairs(fs.list(folder)) do
            table.insert(list, {path = fs.concat(folder, path), name = fs.hideExtension(fs.name(path))})
        end
    end
    return list
end

function programs.find(name)
    if name:sub(1, 1) == "/" and fs.exists(name) then
        if not fs.isDirectory(name) then
            return name
        else
            local fullfilepath = fs.concat(name, "main.lua")
            if fs.exists(fullfilepath) and not fs.isDirectory(fullfilepath) then
                return fullfilepath
            end
        end        
    end
    for _, path in ipairs(programs.paths) do
        local fullpath = fs.concat(path, name)
        if fs.exists(fullpath .. ".lua") then
            return fullpath .. ".lua"
        end

        local fullfilepath = fs.concat(path, name, "main.lua")
        if fs.exists(fullpath) and fs.isDirectory(fullpath) and
        fs.exists(fullfilepath) and not fs.isDirectory(fullfilepath) then
            return fullfilepath
        end
    end
end

function programs.loadText(text, name, envtbl)
    return load(text, name, "bt", envtbl or env.createProgrammEnv())
end

function programs.load(name, envtbl)
    local path = programs.find(name)
    local text, err = fs.readFile(path)
    if not text then return nil, err end
    return programs.loadText(text, "=" .. path, envtbl)
end

function programs.run(name, ...)
    local code, err = programs.load(name)
    if not code then return nil, err or "unknown" end
    return pcall(code, ...)
end

function programs.execute(name, ...)
    local code, err = programs.load(name)
    if not code then return nil, err or "unknown" end
    return xpcall(code, debug.traceback, ...)
end

return programs